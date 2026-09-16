package quest

import (
	"math"
	"sort"
	"strconv"
	"strings"

	lua "github.com/yuin/gopher-lua"
)

const scriptStateNumberKey = "\x00quest:number:"
const scriptStateStringKey = "\x00quest:string:"

// JSON object keys are strings, whereas Lua distinguishes numeric and string
// keys. Keep that distinction without truncating fractional numeric keys.
// Escape the reserved prefixes too, so arbitrary script strings round-trip.
func encodeScriptStateKey(key lua.LValue) (string, bool) {
	switch key := key.(type) {
	case lua.LString:
		value := string(key)
		if strings.HasPrefix(value, "#") || strings.HasPrefix(value, "\x00") {
			return scriptStateStringKey + value, true
		}
		return value, true
	case lua.LNumber:
		value := float64(key)
		if math.IsNaN(value) || math.IsInf(value, 0) {
			return "", false
		}
		// Preserve the existing representation for ordinary integer keys, so
		// unchanged quest arrays do not acquire a new storage format on save.
		integer := strconv.FormatFloat(value, 'f', -1, 64)
		if _, err := strconv.Atoi(integer); err == nil {
			return "#" + integer, true
		}
		return scriptStateNumberKey + strconv.FormatFloat(value, 'g', -1, 64), true
	}
	return "", false
}

func decodeScriptStateKey(key string) lua.LValue {
	if strings.HasPrefix(key, scriptStateStringKey) {
		return lua.LString(strings.TrimPrefix(key, scriptStateStringKey))
	}
	if strings.HasPrefix(key, scriptStateNumberKey) {
		if value, err := strconv.ParseFloat(strings.TrimPrefix(key, scriptStateNumberKey), 64); err == nil && !math.IsNaN(value) && !math.IsInf(value, 0) {
			return lua.LNumber(value)
		}
	}
	// Existing saved quest state encoded integral keys as #<integer>. Read it
	// unchanged; already-collided historical string/numeric keys are unrecoverable.
	if strings.HasPrefix(key, "#") {
		if value, err := strconv.Atoi(strings.TrimPrefix(key, "#")); err == nil {
			return lua.LNumber(value)
		}
	}
	return lua.LString(key)
}

// scriptStateUpvalues visits the script's closure graph, not just the current
// callback. This keeps keys stable when different events share a helper. Lua
// upvalue identity distinguishes aliases from independent factory closures;
// visited functions also terminate recursive helper cycles.
func scriptStateUpvalues(L *lua.LState, handler *lua.LFunction) map[string]*lua.Upvalue {
	type binding struct {
		name, path string
		value      *lua.Upvalue
	}
	var bindings []binding
	seenFunctions := map[*lua.LFunction]bool{}
	seenValues := map[*lua.Upvalue]bool{}
	seenTables := map[*lua.LTable]bool{L.G.Global: true}
	var visit func(*lua.LFunction, string)
	var visitTable func(*lua.LTable, string)
	visitTable = func(table *lua.LTable, path string) {
		if seenTables[table] {
			return
		}
		seenTables[table] = true
		// Tables may contain module methods or nested helper collections, and
		// may point back to themselves. Only stable string/number keys identify
		// paths; function/userdata keys are not durable script identifiers.
		type child struct {
			key   string
			value lua.LValue
		}
		var children []child
		table.ForEach(func(key, value lua.LValue) {
			if value.Type() != lua.LTFunction && value.Type() != lua.LTTable {
				return
			}
			var name string
			switch key := key.(type) {
			case lua.LString:
				name = "string:" + strconv.Quote(string(key))
			case lua.LNumber:
				name = "number:" + strconv.FormatFloat(float64(key), 'g', -1, 64)
			default:
				return
			}
			children = append(children, child{name, value})
		})
		sort.Slice(children, func(i, j int) bool { return children[i].key < children[j].key })
		for _, child := range children {
			childPath := path + "[" + child.key + "]"
			switch value := child.value.(type) {
			case *lua.LFunction:
				visit(value, childPath)
			case *lua.LTable:
				visitTable(value, childPath)
			}
		}
	}
	visit = func(fn *lua.LFunction, path string) {
		if fn == nil || fn.IsG || fn.Proto == nil || seenFunctions[fn] {
			return
		}
		seenFunctions[fn] = true
		for index, name := range fn.Proto.DbgUpvalues {
			if index >= len(fn.Upvalues) || fn.Upvalues[index] == nil {
				continue
			}
			value := fn.Upvalues[index]
			childPath := path + "/" + strconv.Itoa(index) + ":" + name
			if child, ok := value.Value().(*lua.LFunction); ok {
				visit(child, childPath)
				continue
			}
			if table, ok := value.Value().(*lua.LTable); ok {
				visitTable(table, childPath)
			}
			if !seenValues[value] {
				seenValues[value] = true
				bindings = append(bindings, binding{name, childPath, value})
			}
		}
	}
	// Global iteration order is not a persistence identifier. Sort roots before
	// choosing a canonical path for each shared closure/upvalue.
	roots := map[string]*lua.LFunction{}
	L.G.Global.ForEach(func(key, value lua.LValue) {
		if name, ok := key.(lua.LString); ok {
			if fn, ok := value.(*lua.LFunction); ok && !fn.IsG {
				roots[string(name)] = fn
			}
		}
	})
	names := make([]string, 0, len(roots))
	for name := range roots {
		names = append(names, name)
	}
	sort.Strings(names)
	for _, name := range names {
		visit(roots[name], name)
	}
	visit(handler, "@handler") // Encounter callbacks can be anonymous.
	// Visit global tables after existing function roots to preserve established
	// paths for closures that are reachable both directly and through a module.
	globalTables := map[string]*lua.LTable{}
	L.G.Global.ForEach(func(key, value lua.LValue) {
		if name, ok := key.(lua.LString); ok {
			if table, ok := value.(*lua.LTable); ok {
				globalTables[string(name)] = table
			}
		}
	})
	names = names[:0]
	for name := range globalTables {
		names = append(names, name)
	}
	sort.Strings(names)
	for _, name := range names {
		visitTable(globalTables[name], name)
	}
	counts := map[string]int{}
	for _, entry := range bindings {
		counts[entry.name]++
	}
	result := map[string]*lua.Upvalue{}
	for _, entry := range bindings {
		key := "upvalue:" + entry.name
		if counts[entry.name] > 1 {
			// Legacy name-only state cannot identify independent same-name
			// variables. Never copy that ambiguous value into both closures.
			key = "closure:" + entry.path
		}
		result[key] = entry.value
	}
	return result
}
