package quest

import (
	"fmt"
	"testing"

	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
)

func TestLocalQuestPrerequisiteReadFailuresStopEveryEntryPoint(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "character_data", "character_tasks", "character_activities",
		"character_inventory", "item_instances", "faction_list", "faction_values", "zone", "quest_globals",
		"quest_runtime_script_state", "npc_types", "quests")
	for _, query := range []string{
		`INSERT INTO character_data (id,account_id,name,class,race,level,gender,deity) VALUES (7001,1,'Questreader',5,1,60,0,1)`,
		`INSERT INTO zone (zoneidnumber,short_name,long_name) VALUES (123,'testzone','Test Zone')`,
		`INSERT INTO npc_types (id,name) VALUES (9001,'Source')`,
		`INSERT INTO quests (zone,name,lua_content,enabled) VALUES ('testzone','Source',
 'function event_say(e) error("EXECUTION MUST NOT BE REACHED") end
 function event_trade(e) error("EXECUTION MUST NOT BE REACHED") end',1)`,
	} {
		_, err := raw.ExecContext(ctx, query)
		require.NoError(t, err)
	}
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	runtime := QuestTurnInContext{SpawnInstanceID: 6001}
	read, err := s.loadQuestReadContext(7001, 9001, "testzone", runtime)
	require.NoError(t, err)
	require.Equal(t, uint8(5), read.Player.Class)
	require.Equal(t, int32(123), read.ZoneID)
	require.Empty(t, read.Player.Tasks)
	require.Empty(t, read.Player.Inventory)
	require.Empty(t, read.Globals)
	require.Empty(t, read.ScriptState, "a genuinely new actor still has empty state")
	for _, query := range []string{
		`INSERT INTO character_tasks (charid,taskid,slot,type) VALUES (7001,42,0,0)`,
		`INSERT INTO character_activities (charid,taskid,activityid,donecount,completed) VALUES (7001,42,3,0,0)`,
		`INSERT INTO item_instances (id,item_id,quantity,charges,owner_id,owner_type) VALUES (8801,14372,1,1,7001,0)`,
		`INSERT INTO character_inventory (character_id,bag,slot,item_instance_id) VALUES (7001,0,22,8801)`,
		`INSERT INTO faction_list (id,name,base) VALUES (404,'Stored standing',50)`,
		`INSERT INTO faction_values (char_id,faction_id,current_value) VALUES (7001,404,-150)`,
		`INSERT INTO quest_globals (charid,npcid,zoneid,name,value) VALUES
 (7001,9001,123,'local_stage','2'), (7001,9001,999,'other_zone','hidden'),
 (7001,9001,0,'shared_stage','1')`,
		`INSERT INTO quest_runtime_script_state
 (owner_character_id,zone_name,instance_id,spawn_instance_id,npc_type_id,state_json)
 VALUES (7001,'testzone',0,6001,9001,'{"stage":2}')`,
	} {
		_, err := raw.ExecContext(ctx, query)
		require.NoError(t, err)
	}
	read, err = s.loadQuestReadContext(7001, 9001, "testzone", runtime)
	require.NoError(t, err)
	require.Equal(t, map[int]bool{42: true}, read.Player.Tasks)
	require.Equal(t, map[string]bool{taskActivityKey(42, 3): true}, read.Player.Activities)
	require.Equal(t, map[int]int{14372: 1}, read.Player.Inventory)
	require.Equal(t, -100, read.Player.Factions[404], "quest Ally policy must not rewrite stored standings")
	require.Equal(t, map[string]string{"local_stage": "2", "shared_stage": "1"}, read.Globals)
	require.Equal(t, float64(2), read.ScriptState["stage"])
	_, err = raw.ExecContext(ctx, `INSERT INTO quest_runtime_script_state
 (owner_character_id,zone_name,instance_id,spawn_instance_id,npc_type_id,state_json)
 VALUES (7001,'testzone',0,?,0,'{}')`, PlayerRuntimeSpawnInstanceID)
	require.NoError(t, err)
	entryPoints := map[string]func() error{
		"hail": func() error { _, err := s.GetNPCQuestInfoWithContext(7001, 9001, "testzone", runtime); return err },
		"keyword": func() error {
			_, err := s.ProcessKeywordWithContext(7001, 9001, "testzone", "hail", runtime)
			return err
		},
		"trade": func() error {
			_, err := s.ProcessTurnInWithContext(7001, 9001, "testzone", []int{14372}, QuestCurrency{}, runtime)
			return err
		},
		"NPC event": func() error {
			_, _, err := s.ProcessRuntimeEvent(7001, 9001, 6001, "testzone", RuntimeEventSpawn, nil)
			return err
		},
		"player event": func() error {
			_, _, err := s.ProcessPlayerRuntimeEvent(7001, "testzone", 0, RuntimeEventEnterZone, nil, nil)
			return err
		},
	}
	for _, tc := range []struct{ table, column, stage string }{
		{"character_data", "name", "load quest character"},
		{"character_tasks", "taskid", "load quest tasks"},
		{"character_activities", "activityid", "load quest activities"},
		{"character_inventory", "item_instance_id", "load quest inventory"},
		{"faction_values", "current_value", "load quest factions"},
		{"zone", "zoneidnumber", "load quest zone"},
		{"quest_globals", "value", "load quest globals"},
		{"quest_runtime_script_state", "state_json", "load quest actor state"},
	} {
		t.Run(tc.table, func(t *testing.T) {
			// All DDL is confined to connection-local temporary clones. Never
			// drop a clone and expose the persistent table below it.
			_, err := raw.ExecContext(ctx, fmt.Sprintf("ALTER TABLE `%s` RENAME COLUMN `%s` TO broken_column", tc.table, tc.column))
			require.NoError(t, err)
			t.Cleanup(func() {
				_, err := raw.ExecContext(ctx, fmt.Sprintf("ALTER TABLE `%s` RENAME COLUMN broken_column TO `%s`", tc.table, tc.column))
				require.NoError(t, err)
			})
			for name, call := range entryPoints {
				t.Run(name, func(t *testing.T) { require.ErrorContains(t, call(), tc.stage) })
			}
		})
	}
	t.Run("actor identity mismatch", func(t *testing.T) {
		_, err := raw.ExecContext(ctx, `UPDATE quest_runtime_script_state SET npc_type_id=9002 WHERE owner_character_id=7001`)
		require.NoError(t, err)
		for name, call := range entryPoints {
			t.Run(name, func(t *testing.T) { require.ErrorContains(t, call(), "belongs to NPC 9002") })
		}
	})
}
