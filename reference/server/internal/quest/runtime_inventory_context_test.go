package quest

import (
	"testing"

	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
)

func TestQuestPlayerProjectionPreservesEligibilityAndTradeView(t *testing.T) {
	player := PlayerInfo{Name: "Reader", Class: 5, ClassName: "Shadow Knight", Race: 1,
		RaceName: "Human", Level: 60, Tasks: map[int]bool{42: true},
		Activities: map[string]bool{"42:3": true}, Factions: map[int]int{404: -2000},
		Inventory: map[int]int{14372: 1, 14371: 2}}
	view := player.questPlayerProxy(7001, nil)
	require.Equal(t, uint32(7001), view.ID)
	require.Equal(t, player.Name, view.Name)
	require.Equal(t, player.Class, view.ClassID)
	require.Equal(t, player.Race, view.RaceID)
	require.Equal(t, player.ClassName, view.CharClass)
	require.Equal(t, player.RaceName, view.CharRace)
	require.Equal(t, 60, view.CharLevel)
	require.Equal(t, player.Tasks, view.Tasks)
	require.Equal(t, player.Activities, view.Activities)
	require.Equal(t, player.Factions, view.Factions)
	require.Equal(t, map[int]bool{14372: true, 14371: true}, view.Inventory)
	trade := player.questPlayerProxy(7001, []int{14372, 14371})
	require.Equal(t, map[int]bool{14371: true}, trade.Inventory)
	require.True(t, view.Inventory[14372], "a trade view must not mutate another event")
	require.Equal(t, map[int]int{14372: 1, 14371: 2}, player.Inventory)
}

func TestLocalRuntimeEventsSeeAuthoritativePlayerInventory(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "character_data", "character_tasks", "character_activities",
		"character_inventory", "item_instances", "faction_list", "faction_values", "zone", "quest_globals",
		"quest_runtime_script_state", "npc_types", "quests", "quest_lua_modules")
	for _, query := range []string{
		`INSERT INTO character_data (id,account_id,name,class,race,level,gender,deity) VALUES (7001,1,'Questreader',5,1,60,0,1)`,
		`INSERT INTO zone (zoneidnumber,short_name,long_name) VALUES (123,'testzone','Test Zone')`,
		`INSERT INTO npc_types (id,name) VALUES (9001,'Source')`,
		`INSERT INTO item_instances (id,item_id,quantity,charges,owner_id,owner_type) VALUES (8801,14372,1,1,7001,0)`,
		`INSERT INTO character_inventory (character_id,bag,slot,item_instance_id) VALUES (7001,0,22,8801)`,
		`INSERT INTO item_instances (id,item_id,quantity,charges,owner_id,owner_type) VALUES (8802,13019,3,1,7001,0)`,
		`INSERT INTO character_inventory (character_id,bag,slot,item_instance_id) VALUES (7001,0,23,8802)`,
	} {
		_, err := raw.ExecContext(ctx, query)
		require.NoError(t, err)
	}
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	t.Run("stack quantities survive a partial offer", func(t *testing.T) {
		player, err := s.getPlayerInfo(7001)
		require.NoError(t, err)
		require.Equal(t, 3, player.Inventory[13019], "count items, not occupied slots")
		require.True(t, player.questPlayerProxy(7001, []int{13019}).Inventory[13019])
		require.False(t, player.questPlayerProxy(7001, []int{13019, 13019, 13019}).Inventory[13019])
	})
	for _, tc := range []struct{ name, handler, actor string }{
		{"Source", "event_spawn", "e.other"},
		{"player", "event_enter_zone", "e.self"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			source := `function ` + tc.handler + `(e)
 assert(` + tc.actor + `:HasItem(14372), "carried prerequisite missing from runtime player")
 assert(not ` + tc.actor + `:HasItem(14371), "absent prerequisite must stay absent")
end`
			_, err := raw.ExecContext(ctx, `INSERT INTO quests (zone,name,lua_content,enabled) VALUES ('testzone',?,?,1)`, tc.name, source)
			require.NoError(t, err)
			if tc.name == "player" {
				_, _, err = s.ProcessPlayerRuntimeEvent(7001, "testzone", 0, RuntimeEventEnterZone, nil, nil)
			} else {
				_, _, err = s.ProcessRuntimeEvent(7001, 9001, 6001, "testzone", RuntimeEventSpawn, nil)
			}
			require.NoError(t, err)
		})
	}
}
