package overrides_test

import (
	"os"
	"path/filepath"
	"testing"

	quest "idlequest/internal/quest"
	"idlequest/internal/quest/overrides"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestScriptsLoadsEmbeddedLuaOverrides(t *testing.T) {
	scripts, err := overrides.Scripts()
	if err != nil {
		t.Fatalf("overrides.Scripts() error = %v", err)
	}
	if len(scripts) == 0 {
		t.Fatal("expected at least one embedded Lua override")
	}
	for _, script := range scripts {
		if script.Zone == "" || script.Name == "" {
			t.Fatalf("script has empty zone/name: %+v", script)
		}
		if script.Lua == "" {
			t.Fatalf("script %s/%s has empty Lua", script.Zone, script.Name)
		}
	}
}

func TestExterminatorQalantirDoesNotAwardInvalidItemZero(t *testing.T) {
	scripts, err := overrides.Scripts()
	require.NoError(t, err)

	found := map[string]bool{}
	for _, script := range scripts {
		if script.Origin != "modified-upstream" || script.Name != "Exterminator_Qalantir" {
			continue
		}
		if script.Zone != "freportw" && script.Zone != "freeporteast" {
			continue
		}
		found[script.Zone] = true
		assert.NotContains(t, script.Lua, "SummonItem(0)")
		assert.Contains(t, script.Lua, "GiveCash(1,2,1,0)")
		assert.Contains(t, script.Lua, "AddEXP(50)")
	}
	assert.Equal(t, map[string]bool{"freportw": true, "freeporteast": true}, found)
}

func TestScriptsExecuteRuntimeSmoke(t *testing.T) {
	scripts, err := overrides.Scripts()
	if err != nil {
		t.Fatalf("overrides.Scripts() error = %v", err)
	}
	dataDir := t.TempDir()
	modulesDir := filepath.Join(dataDir, "lua_modules")
	if err := os.MkdirAll(modulesDir, 0o755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(modulesDir, "items.lua"), []byte(`
local items = {}
function items.check_turn_in(trade, required) return false end
function items.return_items(self, other, trade) end
return items
`), 0o644); err != nil {
		t.Fatal(err)
	}
	bridge := quest.NewLuaBridge(dataDir)
	// Maintained scripts share the same embedded modules as the importer.
	// Keep the empty-trade items fixture, but load real dependencies rather than
	// making every script self-contained just for this smoke check.
	modules, err := overrides.Modules()
	require.NoError(t, err)
	bridge.ModuleLoader = func(name string) (string, bool, error) {
		for _, module := range modules {
			if module.Name == name && module.Enabled {
				return module.Lua, true, nil
			}
		}
		return "", false, nil
	}
	for _, script := range scripts {
		t.Run(script.Zone+"/"+script.Name, func(t *testing.T) {
			event := &quest.LuaEvent{
				NPC:     &quest.NPCProxy{ID: 1, Name: script.Name},
				Player:  &quest.PlayerProxy{ID: 2, Name: "Tester", Tasks: map[int]bool{}},
				Globals: map[string]string{},
				Message: "hail",
				Trade:   &quest.TradeProxy{Items: []int{999999}},
				// Smoke checks run in an explicitly empty scoped world. Real
				// cross-actor behavior is covered by the quest/world fixtures.
				ResolveNPC: func(quest.QuestNPCQuery) (*quest.NPCProxy, error) { return nil, nil },
			}
			if _, err := bridge.ExecuteEventFromSource(script.Lua, "event_say", event); err != nil {
				t.Fatalf("event_say failed: %v", err)
			}
			if _, err := bridge.ExecuteTradeFromSource(script.Lua, event); err != nil {
				t.Fatalf("event_trade failed: %v", err)
			}
		})
	}
}

func TestP99JebLumsedEnchanterEpicTurnIns(t *testing.T) {
	scripts, err := overrides.Scripts()
	require.NoError(t, err)

	var source string
	for _, script := range scripts {
		if script.Origin == "modified-upstream" && script.Zone == "burningwood" && script.Name == "a_sarnak_imitator" {
			source = script.Lua
			break
		}
	}
	require.NotEmpty(t, source, "expected a Classic/Kunark-only Jeb Lumsed override")

	bridge := quest.NewLuaBridge(filepath.Join("..", "upstream", "projecteq"))
	tests := []struct {
		name       string
		turnInItem int
		rewardItem int
	}{
		{name: "Copy of Notes awards Jeb's Seal", turnInItem: 10603, rewardItem: 10604},
		{name: "Bundle of Staves awards Staff of the Serpent", turnInItem: 10639, rewardItem: 10650},
	}

	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			capture, err := bridge.ExecuteTradeFromSource(source, &quest.LuaEvent{
				NPC:     &quest.NPCProxy{ID: 87065, Name: "a sarnak imitator"},
				Player:  &quest.PlayerProxy{ID: 101, Name: "Enchanter", ClassID: 14, CharLevel: 50, Tasks: map[int]bool{}},
				Globals: map[string]string{},
				Trade:   &quest.TradeProxy{Items: []int{test.turnInItem}},
			})
			require.NoError(t, err)
			assert.Equal(t, []quest.QuestReward{{ItemID: test.rewardItem, Count: 1}}, capture.Items)
			require.NotEmpty(t, capture.Responses)
		})
	}
}
