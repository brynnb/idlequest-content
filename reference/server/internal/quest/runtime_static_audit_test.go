package quest

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
	lua "github.com/yuin/gopher-lua"
)

type luaRuntimeAPICall struct {
	File string
	API  string
}

// TestOverrideLuaUsesBoundRuntimeAPIs is a cheap repo-level guard for
// IdleQuest-authored and converted Perl Lua overrides. The DB-backed runtime
// matrix executes enabled quest rows, but it requires MySQL. This static audit
// catches newly added override files that reference bridge APIs which do not
// exist at all.
// Binding existence is not behavior coverage; deferred APIs are tracked by
// runtime_capabilities.go and rejected by strict behavior tests.
func TestOverrideLuaUsesBoundRuntimeAPIs(t *testing.T) {
	repoRoot := filepath.Clean("../..")
	bridgeSource, err := os.ReadFile(filepath.Join(repoRoot, "internal/quest/lua_bridge.go"))
	require.NoError(t, err)
	moduleSource, err := os.ReadFile(filepath.Join(repoRoot, "internal/quest/upstream/projecteq/lua_modules/items.lua"))
	require.NoError(t, err)

	supported := supportedLuaRuntimeAPIsForAudit(string(bridgeSource), string(moduleSource))
	calls, err := collectOverrideLuaRuntimeAPICalls(filepath.Join(repoRoot, "internal/quest/overrides/lua"))
	require.NoError(t, err)

	var unsupported []luaRuntimeAPICall
	for _, call := range calls {
		if !supported[call.API] {
			unsupported = append(unsupported, call)
		}
	}
	sort.Slice(unsupported, func(i, j int) bool {
		if unsupported[i].API == unsupported[j].API {
			return unsupported[i].File < unsupported[j].File
		}
		return unsupported[i].API < unsupported[j].API
	})
	if len(unsupported) > 0 {
		var lines []string
		for _, call := range unsupported {
			lines = append(lines, fmt.Sprintf("%s uses %s", call.File, call.API))
		}
		t.Fatalf("override Lua references unsupported quest runtime APIs:\n%s", strings.Join(lines, "\n"))
	}
}

func supportedLuaRuntimeAPIsForAudit(bridgeSource, itemsModuleSource string) map[string]bool {
	out := map[string]bool{}
	for api := range deferredRuntimeAPIs {
		out[api] = true
	}

	// Inspect actual registered names, including helpers extracted into other Go
	// files. Registration defines capabilities; it does not execute quest effects.
	L := lua.NewState()
	defer L.Close()
	NewLuaBridge(".").registerEqGlobal(L, NewQuestCapture(), &LuaEvent{})
	L.GetGlobal("eq").(*lua.LTable).ForEach(func(key, value lua.LValue) {
		if name, ok := key.(lua.LString); ok && value != lua.LNil {
			out["eq."+string(name)] = true
		}
	})
	for _, match := range regexp.MustCompile(`function\s+items\.([A-Za-z_][A-Za-z0-9_]*)\s*\(`).FindAllStringSubmatch(itemsModuleSource, -1) {
		out["item_lib."+match[1]] = true
	}
	for _, match := range regexp.MustCompile(`L\.SetField\(entityList,\s*"([A-Za-z_][A-Za-z0-9_]*)"`).FindAllStringSubmatch(bridgeSource, -1) {
		out["entity_list."+match[1]] = true
	}
	for _, match := range regexp.MustCompile(`case\s+((?:"[A-Za-z_][A-Za-z0-9_]*"(?:,\s*)?)+):`).FindAllStringSubmatch(bridgeSource, -1) {
		for _, quoted := range regexp.MustCompile(`"([A-Za-z_][A-Za-z0-9_]*)"`).FindAllStringSubmatch(match[1], -1) {
			out["e.self:"+quoted[1]] = true
			out["e.other:"+quoted[1]] = true
		}
	}

	// Constants/tables exposed by registerEqConstants or as globals; these are
	// not callable functions but still appear as eq.* references in Lua source.
	for _, name := range []string{"Class", "Race"} {
		out["eq."+name] = true
	}
	return out
}

func collectOverrideLuaRuntimeAPICalls(root string) ([]luaRuntimeAPICall, error) {
	var calls []luaRuntimeAPICall
	err := filepath.WalkDir(root, func(path string, entry os.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if entry.IsDir() || !strings.HasSuffix(entry.Name(), ".lua") {
			return nil
		}
		content, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		rel, _ := filepath.Rel(root, path)
		calls = append(calls, scanLuaRuntimeAPICalls(rel, stripLuaCommentsForAudit(string(content)))...)
		return nil
	})
	return calls, err
}

func scanLuaRuntimeAPICalls(file, source string) []luaRuntimeAPICall {
	var calls []luaRuntimeAPICall
	for _, match := range regexp.MustCompile(`\beq\.([A-Za-z_][A-Za-z0-9_]*)`).FindAllStringSubmatch(source, -1) {
		calls = append(calls, luaRuntimeAPICall{File: file, API: "eq." + match[1]})
	}
	for _, match := range regexp.MustCompile(`\beq\.get_entity_list\(\):([A-Za-z_][A-Za-z0-9_]*)\s*\(`).FindAllStringSubmatch(source, -1) {
		calls = append(calls, luaRuntimeAPICall{File: file, API: "entity_list." + match[1]})
	}

	itemAliases := map[string]bool{"item_lib": true}
	for _, match := range regexp.MustCompile(`(?:local\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*require\(["']items["']\)`).FindAllStringSubmatch(source, -1) {
		itemAliases[match[1]] = true
	}
	for alias := range itemAliases {
		for _, match := range regexp.MustCompile(`\b`+regexp.QuoteMeta(alias)+`\.([A-Za-z_][A-Za-z0-9_]*)\s*\(`).FindAllStringSubmatch(source, -1) {
			calls = append(calls, luaRuntimeAPICall{File: file, API: "item_lib." + match[1]})
		}
	}

	for _, match := range regexp.MustCompile(`\be\.(self|other):([A-Za-z_][A-Za-z0-9_]*)\s*\(`).FindAllStringSubmatch(source, -1) {
		calls = append(calls, luaRuntimeAPICall{File: file, API: "e." + match[1] + ":" + match[2]})
	}
	return calls
}

func stripLuaCommentsForAudit(source string) string {
	source = regexp.MustCompile(`(?s)--\[\[.*?\]\]`).ReplaceAllString(source, "")
	lines := strings.Split(source, "\n")
	for i, line := range lines {
		if idx := strings.Index(line, "--"); idx >= 0 {
			lines[i] = line[:idx]
		}
	}
	return strings.Join(lines, "\n")
}
