package quest

import (
	"encoding/json"
	"fmt"
	"sort"
	"strings"

	lua "github.com/yuin/gopher-lua"
)

const tableAliasStateKey = "lua:table-aliases"

type luaTableAlias struct {
	Destination []string `json:"destination"`
	Source      []string `json:"source"`
}

func captureLuaTableAliases(L *lua.LState, fn *lua.LFunction, capture *QuestCapture) {
	roots := map[string]lua.LValue{}
	for key, value := range scriptStateUpvalues(L, fn) {
		roots[key] = value.Value()
	}
	L.G.Global.ForEach(func(key, value lua.LValue) {
		if name, ok := key.(lua.LString); ok {
			roots["global:"+string(name)] = value
		}
	})
	keys := make([]string, 0, len(roots))
	for key := range roots {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	seen := map[*lua.LTable][]string{}
	aliases := []luaTableAlias{}
	var visit func(lua.LValue, []string)
	visit = func(value lua.LValue, path []string) {
		table, ok := value.(*lua.LTable)
		if !ok {
			return
		}
		if previous, ok := seen[table]; ok {
			aliases = append(aliases, luaTableAlias{path, previous})
			return
		}
		seen[table] = path
		children := map[string]lua.LValue{}
		table.ForEach(func(key, value lua.LValue) {
			if encoded, ok := encodeScriptStateKey(key); ok {
				children[encoded] = value
			}
		})
		keys := make([]string, 0, len(children))
		for key := range children {
			keys = append(keys, key)
		}
		sort.Strings(keys)
		for _, key := range keys {
			visit(children[key], append(append([]string(nil), path...), key))
		}
	}
	for _, key := range keys {
		// Alias metadata only describes values the existing serializer supports.
		// It does not make cyclic tables or executable objects persistable.
		if _, ok := serializableLuaPrimitive(roots[key]); ok {
			visit(roots[key], []string{key})
		}
	}
	// Replace even with an empty list: a later event may deliberately separate
	// formerly shared tables. Equal contents never imply shared identity.
	capture.ScriptState[tableAliasStateKey] = aliases
}

func restoreLuaTableAliases(L *lua.LState, fn *lua.LFunction, state map[string]any) error {
	value, exists := state[tableAliasStateKey]
	if !exists { // Older state has no recoverable alias identity.
		return nil
	}
	encoded, err := json.Marshal(value)
	if err != nil {
		return fmt.Errorf("encode quest table aliases: %w", err)
	}
	var aliases []luaTableAlias
	if err := json.Unmarshal(encoded, &aliases); err != nil {
		return fmt.Errorf("decode quest table aliases: %w", err)
	}
	upvalues := scriptStateUpvalues(L, fn)
	resolve := func(path []string) lua.LValue {
		if len(path) == 0 {
			return lua.LNil
		}
		var value lua.LValue = lua.LNil
		if upvalue := upvalues[path[0]]; upvalue != nil {
			value = upvalue.Value()
		} else if strings.HasPrefix(path[0], "global:") {
			value = L.GetGlobal(strings.TrimPrefix(path[0], "global:"))
		}
		for _, key := range path[1:] {
			table, ok := value.(*lua.LTable)
			if !ok {
				return lua.LNil
			}
			value = table.RawGet(decodeScriptStateKey(key))
		}
		return value
	}
	for _, alias := range aliases {
		source, ok := resolve(alias.Source).(*lua.LTable)
		if !ok {
			return fmt.Errorf("quest table alias source is unavailable: %v", alias.Source)
		}
		if _, ok := resolve(alias.Destination).(*lua.LTable); !ok {
			return fmt.Errorf("quest table alias destination is unavailable: %v", alias.Destination)
		}
		path := alias.Destination
		if len(path) == 1 {
			if upvalue := upvalues[path[0]]; upvalue != nil {
				upvalue.SetValue(source)
			} else {
				L.SetGlobal(strings.TrimPrefix(path[0], "global:"), source)
			}
		} else {
			parent := resolve(path[:len(path)-1]).(*lua.LTable)
			parent.RawSet(decodeScriptStateKey(path[len(path)-1]), source)
		}
	}
	return nil
}
