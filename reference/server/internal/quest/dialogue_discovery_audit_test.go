package quest

import (
	"database/sql"
	"encoding/json"
	"os"
	"path/filepath"
	"reflect"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/yuin/gopher-lua/ast"
	"github.com/yuin/gopher-lua/parse"
)

// Audit effective enabled source as well as overrides: upstream Lua may use
// different dialogue shapes, and an override-only audit cannot bound the gaps.
func TestAuditDatabaseDialogueShapes(t *testing.T) {
	if os.Getenv("IDLEQUEST_E2E_CONTENT_AUDIT") != "true" {
		t.Skip("explicit content audit only")
	}
	dsn := questRuntimeMatrixDSN(t)
	if dsn == "" {
		t.Skip("quest database configuration unavailable")
	}
	database, err := sql.Open("mysql", dsn)
	require.NoError(t, err)
	defer database.Close()
	rows, err := database.Query(`SELECT zone, name, lua_content FROM quests WHERE enabled=1 AND lua_content IS NOT NULL AND lua_content != '' ORDER BY zone, name`)
	require.NoError(t, err)
	defer rows.Close()
	zones := ClassicKunarkQuestZoneSet()
	files, handlers, outliers := 0, 0, 0
	for rows.Next() {
		var zone, name, source string
		require.NoError(t, rows.Scan(&zone, &name, &source))
		if !zones[strings.ToLower(zone)] {
			continue
		}
		files++
		chunk, err := parse.Parse(strings.NewReader(normalizeLegacyTurnInCurrencySyntax(source)), zone+"/"+name)
		require.NoError(t, err, "%s/%s", zone, name)
		if scriptDefinesLuaHandler(source, "event_say") {
			handlers++
		}
		shapes := classifyDialogueMessageAccess(chunk)
		if len(shapes["outsideDirectLiteralFindi"]) > 0 {
			outliers++
			data, err := json.Marshal(shapes)
			require.NoError(t, err)
			t.Logf("%s/%s %s", zone, name, data)
		}
	}
	require.NoError(t, rows.Err())
	require.Positive(t, files)
	t.Logf("Enabled Classic/Kunark source: %d files, %d say handlers, %d message-shape outliers; classification only, not gameplay verification", files, handlers, outliers)
}

// Source classification, not execution or P99 certification. Opt-in avoids
// making the ordinary mechanics suite a corpus-wide content audit.
func TestAuditOverrideDialogueShapes(t *testing.T) {
	if os.Getenv("IDLEQUEST_E2E_CONTENT_AUDIT") != "true" {
		t.Skip("explicit content audit only")
	}
	report := struct {
		Files         int                         `json:"files"`
		Handlers      int                         `json:"namedHandlers"`
		Nested        map[string][]string         `json:"nestedMessageConditions"`
		Assigned      []string                    `json:"assignedHandlers"`
		Unparsed      []string                    `json:"parseFailures"`
		MessageShapes map[string]map[string][]int `json:"messageAccessShapes"`
	}{Nested: map[string][]string{}, MessageShapes: map[string]map[string][]int{}}
	err := filepath.WalkDir("overrides/lua", func(path string, entry os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if entry.IsDir() || !strings.HasSuffix(path, ".lua") {
			return nil
		}
		report.Files++
		data, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		chunk, err := parse.Parse(strings.NewReader(normalizeLegacyTurnInCurrencySyntax(string(data))), path)
		if err != nil {
			report.Unparsed = append(report.Unparsed, path)
			return nil
		}
		for _, stmt := range chunk {
			switch node := stmt.(type) {
			case *ast.FuncDefStmt:
				if name, ok := node.Name.Func.(*ast.IdentExpr); ok && name.Value == "event_say" {
					report.Handlers++
					if nested := nestedDialogueConditions(node.Func.Stmts, false); len(nested) > 0 {
						report.Nested[path] = nested
					}
				}
			case *ast.AssignStmt:
				for _, lhs := range node.Lhs {
					if name, ok := lhs.(*ast.IdentExpr); ok && name.Value == "event_say" {
						report.Assigned = append(report.Assigned, path)
					}
				}
			}
		}
		if shapes := classifyDialogueMessageAccess(chunk); len(shapes) > 0 {
			report.MessageShapes[path] = shapes
		}
		return nil
	})
	require.NoError(t, err)
	data, err := json.Marshal(report)
	require.NoError(t, err)
	t.Log(string(data))
}

// Classify syntax before expanding inference. A message field passed through
// a variable/helper, equality test or dynamic findi argument needs review;
// this does not claim all such expressions represent player choices.
func classifyDialogueMessageAccess(chunk []ast.Stmt) map[string][]int {
	known := map[*ast.AttrGetExpr]bool{}
	for _, stmt := range chunk {
		def, ok := stmt.(*ast.FuncDefStmt)
		if !ok {
			continue
		}
		name, ok := def.Name.Func.(*ast.IdentExpr)
		if !ok || name.Value != "event_say" {
			continue
		}
		walkDialogueSyntax(reflect.ValueOf(def.Func.Stmts), func(value any) {
			call, ok := value.(*ast.FuncCallExpr)
			if !ok || len(dialogueConditionKeywords(call)) == 0 {
				return
			}
			if field, ok := call.Receiver.(*ast.AttrGetExpr); ok {
				known[field] = true
			}
		})
	}
	result := map[string][]int{}
	walkDialogueSyntax(reflect.ValueOf(chunk), func(value any) {
		field, ok := value.(*ast.AttrGetExpr)
		if !ok {
			return
		}
		key, ok := field.Key.(*ast.StringExpr)
		if !ok || key.Value != "message" || known[field] {
			return
		}
		result["outsideDirectLiteralFindi"] = append(result["outsideDirectLiteralFindi"], field.Line())
	})
	return result
}

// Test-only AST traversal: syntax nodes have no parent/back-reference cycles.
func walkDialogueSyntax(value reflect.Value, visit func(any)) {
	if !value.IsValid() {
		return
	}
	if value.Kind() != reflect.Interface && value.CanInterface() {
		visit(value.Interface())
	}
	switch value.Kind() {
	case reflect.Interface, reflect.Pointer:
		if !value.IsNil() {
			walkDialogueSyntax(value.Elem(), visit)
		}
	case reflect.Slice:
		for i := 0; i < value.Len(); i++ {
			walkDialogueSyntax(value.Index(i), visit)
		}
	case reflect.Struct:
		for i := 0; i < value.NumField(); i++ {
			if value.Type().Field(i).IsExported() {
				walkDialogueSyntax(value.Field(i), visit)
			}
		}
	}
}

func TestDialogueMessageShapeClassification(t *testing.T) {
	chunk, err := parse.Parse(strings.NewReader(`
function helper(e) if e.message:findi("helper") then return true end end
function event_say(e)
  if e.message:findi("direct") then end
  if e.message:findi(variable) then end
  if e.message == "exact" then end
  local text = e.message
end`), "classification")
	require.NoError(t, err)
	require.Equal(t, []int{2, 5, 6, 7}, classifyDialogueMessageAccess(chunk)["outsideDirectLiteralFindi"])
}

func nestedDialogueConditions(stmts []ast.Stmt, insideMessage bool) []string {
	var result []string
	for _, stmt := range stmts {
		switch node := stmt.(type) {
		case *ast.IfStmt:
			keywords := dialogueConditionKeywords(node.Condition)
			if insideMessage {
				result = append(result, keywords...)
			}
			result = append(result, nestedDialogueConditions(node.Then, insideMessage || len(keywords) > 0)...)
			// Else/elseif does not imply that this condition matched.
			result = append(result, nestedDialogueConditions(node.Else, insideMessage)...)
		case *ast.DoBlockStmt:
			result = append(result, nestedDialogueConditions(node.Stmts, insideMessage)...)
		case *ast.WhileStmt:
			result = append(result, nestedDialogueConditions(node.Stmts, insideMessage)...)
		case *ast.RepeatStmt:
			result = append(result, nestedDialogueConditions(node.Stmts, insideMessage)...)
		case *ast.NumberForStmt:
			result = append(result, nestedDialogueConditions(node.Stmts, insideMessage)...)
		case *ast.GenericForStmt:
			result = append(result, nestedDialogueConditions(node.Stmts, insideMessage)...)
		}
	}
	return result
}
