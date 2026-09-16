package quest

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	lua "github.com/yuin/gopher-lua"
	"github.com/yuin/gopher-lua/ast"
	"github.com/yuin/gopher-lua/parse"
)

const dialogueProbeName = "__idlequest_dialogue_probe"

type dialogueCandidate struct {
	keyword string
	branch  int
}

// DiscoverDialogueOptions evaluates original Lua control flow, not an imitation
// of its conditions. Each candidate gets a fresh VM and a deep-copied event.
// A probe stops execution on entering the candidate's branch, before its body
// runs. Ancestor branches execute only in the isolated preview; their effects
// are captured and discarded, never persisted.
// Reachability is not a promise that a subsequent hand-in will be accepted.
func (b *LuaBridge) DiscoverDialogueOptions(source string, event *LuaEvent) ([]DialogueOption, error) {
	chunk, err := parse.Parse(strings.NewReader(normalizeLegacyTurnInCurrencySyntax(source)), "dialogue")
	if err != nil {
		return nil, err
	}
	var candidates []dialogueCandidate
	branch := 0
	for _, stmt := range chunk {
		if def, ok := stmt.(*ast.FuncDefStmt); ok {
			if name, ok := def.Name.Func.(*ast.IdentExpr); ok && name.Value == "event_say" {
				instrumentDialogue(def.Func.Stmts, &candidates, &branch, nil)
			}
		}
	}
	if len(candidates) == 0 {
		return nil, nil
	}
	// One total deadline, including initialization and all candidate handlers.
	// Never multiply the normal per-event timeout by the number of options.
	if len(candidates) > 64 {
		return nil, fmt.Errorf("dialogue exceeds 64 candidate limit: %d", len(candidates))
	}
	proto, err := lua.Compile(chunk, "dialogue")
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(context.Background(), 100*time.Millisecond)
	defer cancel()
	previewBridge := *b
	previewBridge.ExecutionTimeout = 0 // The shared discovery deadline owns these VMs.
	var options []DialogueOption
	seen := map[string]bool{}
	for _, candidate := range candidates {
		key := strings.ToLower(candidate.keyword)
		if key == "hail" || seen[key] {
			continue
		}
		copyEvent, err := cloneDialogueEvent(event)
		if err != nil {
			return nil, err
		}
		copyEvent.Message = candidate.keyword
		reached := 0
		L, e, _, err := previewBridge.prepareStateWithLoader(copyEvent, func(L *lua.LState) error {
			L.SetContext(ctx)
			// Discovery must not gain process/file IO through Lua's standard
			// libraries. The existing module loader still supplies quest modules.
			for _, name := range []string{"os", "io", "debug", "dofile", "loadfile"} {
				L.SetGlobal(name, lua.LNil)
			}
			loaded := L.GetField(L.GetGlobal("package"), "loaded")
			for _, name := range []string{"os", "io", "debug"} {
				L.SetField(loaded, name, lua.LNil)
			}
			L.SetGlobal(dialogueProbeName, L.NewFunction(func(L *lua.LState) int {
				id := L.CheckInt(1)
				if id != candidate.branch {
					return 0 // Traverse ancestor gates in the isolated preview only.
				}
				reached = id
				L.RaiseError("dialogue branch reached")
				return 0
			}))
			return L.CallByParam(lua.P{Fn: L.NewFunctionFromProto(proto), Protect: true})
		})
		if err != nil {
			return nil, err
		}
		fn := L.GetGlobal("event_say")
		if fn.Type() != lua.LTFunction {
			L.Close()
			return nil, fmt.Errorf("dialogue handler is not a function")
		}
		if err := applyLuaScriptState(L, fn.(*lua.LFunction), copyEvent.ScriptState); err != nil {
			L.Close()
			return nil, err
		}
		err = L.CallByParam(lua.P{Fn: fn, Protect: true}, e)
		L.Close()
		if ctx.Err() != nil {
			return nil, fmt.Errorf("dialogue discovery: %w", ctx.Err())
		}
		if reached == 0 && err != nil {
			return nil, fmt.Errorf("dialogue candidate %q: %w", candidate.keyword, err)
		}
		if reached == candidate.branch {
			seen[key] = true
			options = append(options, DialogueOption{Text: candidate.keyword, Keyword: candidate.keyword})
		}
	}
	return options, nil
}

func applyDialogueGlobals(event *LuaEvent, capture *QuestCapture) {
	if event.Globals == nil {
		event.Globals = map[string]string{}
	}
	for name, update := range capture.Globals {
		if update.Delete {
			delete(event.Globals, name)
		} else {
			event.Globals[name] = update.Value
		}
	}
}

func cloneDialogueEvent(event *LuaEvent) (*LuaEvent, error) {
	if event == nil {
		return nil, fmt.Errorf("dialogue requires an event")
	}
	copyEvent := *event
	if event.NPC != nil {
		npc := *event.NPC
		npc.Capture = nil
		copyEvent.NPC = &npc
	}
	if event.Player != nil {
		player := *event.Player
		player.Capture = nil
		copyEvent.Player = &player
	}
	// Dialogue does not inherit a trade/corpse/item operation or its capture.
	copyEvent.Trade, copyEvent.Corpse, copyEvent.Item, copyEvent.Door = nil, nil, nil, nil
	if event.Fields != nil {
		copyEvent.Fields = make(map[string]any, len(event.Fields))
		for key, value := range event.Fields {
			if key != "__quest_npc_resolver" && key != "__quest_npc_enumerator" && key != "__quest_npc_combat_reader" {
				copyEvent.Fields[key] = value
			}
		}
	}
	data, err := json.Marshal(copyEvent)
	if err != nil {
		return nil, err
	}
	var cloned LuaEvent
	err = json.Unmarshal(data, &cloned)
	// The resolver is a server-owned read capability, not serializable state.
	// Resolved actors are copied by npcLookup before any Lua code sees them.
	cloned.ResolveNPC = event.ResolveNPC
	cloned.ListNPCs = event.ListNPCs
	cloned.ReadTimer = event.ReadTimer
	cloned.ReadNPCCombat = event.ReadNPCCombat
	return &cloned, err
}

func instrumentDialogue(stmts []ast.Stmt, candidates *[]dialogueCandidate, branch *int, ancestors []string) {
	for _, stmt := range stmts {
		switch node := stmt.(type) {
		case *ast.IfStmt:
			keywords := dialogueConditionKeywords(node.Condition)
			routingOnly := dialogueRoutingOnly(node.Then)
			phrases := keywords
			if len(keywords) > 0 && len(ancestors) > 0 {
				phrases = nil
				for _, parent := range ancestors {
					for _, child := range keywords {
						phrase := parent + " " + child
						if strings.Contains(strings.ToLower(parent), strings.ToLower(child)) {
							phrase = parent
						} else if strings.Contains(strings.ToLower(child), strings.ToLower(parent)) {
							phrase = child
						}
						phrases = append(phrases, phrase)
						if len(phrases) > 64 {
							break
						}
					}
					if len(phrases) > 64 {
						break
					}
				}
			}
			if len(keywords) > 0 {
				*branch++
				if !routingOnly {
					for _, keyword := range phrases {
						*candidates = append(*candidates, dialogueCandidate{keyword, *branch})
					}
				}
				probe := &ast.FuncCallStmt{Expr: &ast.FuncCallExpr{Func: &ast.IdentExpr{Value: dialogueProbeName}, Args: []ast.Expr{&ast.NumberExpr{Value: fmt.Sprint(*branch)}}}}
				node.Then = append([]ast.Stmt{probe}, node.Then...)
			}
			childAncestors := ancestors
			if len(keywords) > 0 {
				childAncestors = phrases
			}
			instrumentDialogue(node.Then, candidates, branch, childAncestors)
			instrumentDialogue(node.Else, candidates, branch, ancestors)
		case *ast.DoBlockStmt:
			instrumentDialogue(node.Stmts, candidates, branch, ancestors)
		case *ast.WhileStmt:
			instrumentDialogue(node.Stmts, candidates, branch, ancestors)
		case *ast.RepeatStmt:
			instrumentDialogue(node.Stmts, candidates, branch, ancestors)
		case *ast.NumberForStmt:
			instrumentDialogue(node.Stmts, candidates, branch, ancestors)
		case *ast.GenericForStmt:
			instrumentDialogue(node.Stmts, candidates, branch, ancestors)
		}
	}
}

// A branch containing only further message choices is a routing prefix, not
// an independently useful response (for example Serena's bare "follow").
// Preserve branches with their own statements or a real fallback response.
func dialogueRoutingOnly(stmts []ast.Stmt) bool {
	nested, own := false, false
	var visit func([]ast.Stmt)
	visit = func(stmts []ast.Stmt) {
		for _, stmt := range stmts {
			switch node := stmt.(type) {
			case *ast.IfStmt:
				if len(dialogueConditionKeywords(node.Condition)) > 0 {
					nested = true
				} else {
					visit(node.Then)
				}
				visit(node.Else)
			case *ast.DoBlockStmt:
				visit(node.Stmts)
			case *ast.WhileStmt:
				visit(node.Stmts)
			case *ast.RepeatStmt:
				visit(node.Stmts)
			case *ast.NumberForStmt:
				visit(node.Stmts)
			case *ast.GenericForStmt:
				visit(node.Stmts)
			default:
				own = true
			}
		}
	}
	visit(stmts)
	return nested && !own
}

func dialogueConditionKeywords(expr ast.Expr) []string {
	switch node := expr.(type) {
	case *ast.FuncCallExpr:
		if node.Method != "findi" || len(node.Args) != 1 {
			return nil
		}
		field, ok := node.Receiver.(*ast.AttrGetExpr)
		if !ok {
			return nil
		}
		key, ok := field.Key.(*ast.StringExpr)
		if !ok || key.Value != "message" {
			return nil
		}
		if text, ok := node.Args[0].(*ast.StringExpr); ok && strings.TrimSpace(text.Value) != "" {
			return []string{text.Value}
		}
	case *ast.LogicalOpExpr:
		return append(dialogueConditionKeywords(node.Lhs), dialogueConditionKeywords(node.Rhs)...)
	case *ast.RelationalOpExpr:
		return append(dialogueConditionKeywords(node.Lhs), dialogueConditionKeywords(node.Rhs)...)
	}
	return nil
}
