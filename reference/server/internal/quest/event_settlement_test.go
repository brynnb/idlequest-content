package quest

import (
	"context"
	"encoding/json"
	"errors"
	"testing"

	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
)

func TestLocalQuestEventWriteFailureRollsBackStateAndRewards(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "character_data", "character_tasks", "character_activities",
		"character_inventory", "item_instances", "faction_list", "faction_values", "zone", "quest_globals",
		"quest_runtime_script_state", "npc_types", "quests", "quest_lua_modules", "character_currency")
	for _, query := range []string{
		`INSERT INTO character_data (id,account_id,name,class,race,level,gender,deity,exp) VALUES (7001,1,'Questreader',5,1,60,0,1,0)`,
		`INSERT INTO zone (zoneidnumber,short_name,long_name) VALUES (123,'testzone','Test Zone')`,
		`INSERT INTO npc_types (id,name) VALUES (9001,'Source')`,
		`INSERT INTO character_currency (id,platinum,gold,silver,copper) VALUES (7001,0,0,0,0)`,
	} {
		_, err := raw.ExecContext(ctx, query)
		require.NoError(t, err)
	}
	source := `local attempts = 0
local keyed = {[1]=0, [1.5]=10, ["#1"]=100}
local alias = keyed
local function award(p)
 assert(alias == keyed)
 attempts = attempts + 1
 for key,value in pairs(keyed) do keyed[key]=value+1 end
 assert(keyed[1] == attempts and keyed[1.5] == 10+attempts and keyed["#1"] == 100+attempts)
 eq.set_global("stage", "done", 5, "F")
 p:AddEXP(100)
 p:AddMoneyToPP(0,0,0,1)
end
function event_say(e) award(e.other) end
function event_spawn(e) award(e.other) end
function event_waypoint_arrive(e) assert(e.wp == 7) award(e.other) end
function event_waypoint_depart(e) assert(e.wp == 7) award(e.other) end
function event_enter_zone(e) award(e.self) end`
	for _, name := range []string{"Source", "player"} {
		_, err := raw.ExecContext(ctx, `INSERT INTO quests (zone,name,lua_content,enabled) VALUES ('testzone',?,?,1)`, name, source)
		require.NoError(t, err)
	}
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	published, failEffects := 0, false
	s.PrepareRuntimeEffects = func(characterID uint32, npcID int32, zone string, runtime QuestTurnInContext, capture *QuestCapture) (*RuntimeEffectSettlement, error) {
		if capture.WaypointProgress != nil {
			require.Equal(t, 7, capture.WaypointProgress.Waypoint)
		}
		return &RuntimeEffectSettlement{
			Persist: func(ctx context.Context, tx *stmtcache.Tx) error {
				if _, err := tx.ExecContext(ctx, "UPDATE character_data SET cur_hp=77 WHERE id=?", characterID); err != nil {
					return err
				}
				if failEffects {
					return errors.New("effect write failed")
				}
				return nil
			},
			Publish: func() { published++ },
		}, nil
	}
	_, err := raw.ExecContext(ctx, `INSERT INTO quests (zone,name,lua_content,enabled) VALUES
 ('testzone','script_init',?,1), ('encounters','registered',?,1)`,
		`eq.load_encounter("registered")`,
		`local attempts = 10
local function record(e) attempts = attempts + 1 end
function event_encounter_load(e)
 eq.register_npc_event(Event.spawn, 9001, record)
 eq.register_player_event(Event.enter_zone, record)
end`)
	require.NoError(t, err)
	runtime := QuestTurnInContext{SpawnInstanceID: 6001}
	for name, invoke := range map[string]func() error{
		"hail": func() error { _, err := s.GetNPCQuestInfoWithContext(7001, 9001, "testzone", runtime); return err },
		"keyword": func() error {
			_, err := s.ProcessKeywordWithContext(7001, 9001, "testzone", "hail", runtime)
			return err
		},
		"NPC event": func() error {
			_, _, err := s.ProcessRuntimeEvent(7001, 9001, 6001, "testzone", RuntimeEventSpawn, nil)
			return err
		},
		"waypoint arrival": func() error {
			capture, _, err := s.ProcessRuntimeEvent(7001, 9001, 6001, "testzone", RuntimeEventWaypointArrive, map[string]any{"wp": 7, "__quest_waypoint_progress": &QuestWaypointProgress{Waypoint: 7}})
			if err == nil {
				require.Equal(t, &QuestWaypointProgress{Waypoint: 7}, capture.WaypointProgress)
			}
			return err
		},
		"waypoint departure": func() error {
			capture, _, err := s.ProcessRuntimeEvent(7001, 9001, 6001, "testzone", RuntimeEventWaypointDepart, map[string]any{"wp": 7, "__quest_waypoint_progress": &QuestWaypointProgress{Waypoint: 7, Depart: true}})
			if err == nil {
				require.Equal(t, &QuestWaypointProgress{Waypoint: 7, Depart: true}, capture.WaypointProgress)
			}
			return err
		},
		"player event": func() error {
			_, _, err := s.ProcessPlayerRuntimeEvent(7001, "testzone", 0, RuntimeEventEnterZone, nil, nil)
			return err
		},
	} {
		t.Run(name, func(t *testing.T) {
			published = 0
			for _, query := range []string{"DELETE FROM quest_globals", "DELETE FROM quest_runtime_script_state", "UPDATE character_data SET exp=0,cur_hp=0 WHERE id=7001", "UPDATE character_currency SET platinum=0 WHERE id=7001"} {
				_, err := raw.ExecContext(ctx, query)
				require.NoError(t, err)
			}
			preflightCalls := 0
			s.ValidateRuntimeCapture = func(characterID uint32, npcID int32, zone string, runtime QuestTurnInContext, capture *QuestCapture) error {
				preflightCalls++
				require.Equal(t, uint32(7001), characterID)
				require.Equal(t, "testzone", zone)
				require.EqualValues(t, 100, capture.Exp)
				return errors.New("effect unavailable")
			}
			require.ErrorContains(t, invoke(), "effect unavailable")
			s.ValidateRuntimeCapture = nil
			require.Equal(t, 1, preflightCalls)
			failEffects = true
			require.ErrorContains(t, invoke(), "effect write failed")
			failEffects = false
			require.Zero(t, published)
			for _, query := range []string{"SELECT COUNT(*) FROM quest_globals", "SELECT COUNT(*) FROM quest_runtime_script_state", "SELECT exp FROM character_data WHERE id=7001", "SELECT cur_hp FROM character_data WHERE id=7001", "SELECT platinum FROM character_currency WHERE id=7001"} {
				var value int
				require.NoError(t, raw.QueryRowContext(ctx, query).Scan(&value))
				require.Zero(t, value, "preflight failure committed: %s", query)
			}
			_, err := raw.ExecContext(ctx, `ALTER TABLE character_currency RENAME COLUMN platinum TO unavailable_platinum`)
			require.NoError(t, err)
			err = invoke()
			_, restoreErr := raw.ExecContext(ctx, `ALTER TABLE character_currency RENAME COLUMN unavailable_platinum TO platinum`)
			require.NoError(t, restoreErr)
			assert.Error(t, err, "failed persistence must not report quest success")
			for _, query := range []string{"SELECT COUNT(*) FROM quest_globals", "SELECT COUNT(*) FROM quest_runtime_script_state", "SELECT exp FROM character_data WHERE id=7001", "SELECT platinum FROM character_currency WHERE id=7001"} {
				var value int
				require.NoError(t, raw.QueryRowContext(ctx, query).Scan(&value))
				assert.Zero(t, value, query)
			}
			require.NoError(t, invoke(), "a retry after recovery must still work")
			require.Equal(t, 1, published)
			var hp int
			require.NoError(t, raw.QueryRowContext(ctx, "SELECT cur_hp FROM character_data WHERE id=7001").Scan(&hp))
			require.Equal(t, 77, hp)
			var platinum, exp int
			require.NoError(t, raw.QueryRowContext(ctx, "SELECT platinum FROM character_currency WHERE id=7001").Scan(&platinum))
			require.NoError(t, raw.QueryRowContext(ctx, "SELECT exp FROM character_data WHERE id=7001").Scan(&exp))
			assert.Equal(t, 1, platinum)
			assert.Equal(t, 100, exp)
			// Main and encounter handlers use the same variable name, but must
			// retain separate durable state rather than the merged projection.
			stateKey := int64(6001)
			if name == "player event" {
				stateKey = PlayerRuntimeSpawnInstanceID
			}
			var encoded []byte
			require.NoError(t, raw.QueryRowContext(ctx, `SELECT state_json FROM quest_runtime_script_state WHERE owner_character_id=7001 AND zone_name='testzone' AND spawn_instance_id=?`, stateKey).Scan(&encoded))
			var state map[string]any
			require.NoError(t, json.Unmarshal(encoded, &state))
			assert.Equal(t, float64(1), state["upvalue:attempts"])
			if name == "NPC event" || name == "player event" {
				encounter := "registered"
				if name == "player event" {
					encounter = "player:registered"
				}
				require.NoError(t, raw.QueryRowContext(ctx, `SELECT state_json FROM quest_runtime_script_state WHERE owner_character_id=7001 AND zone_name='testzone' AND spawn_instance_id=?`, encounterRuntimeStateKey(encounter)).Scan(&encoded))
				require.NoError(t, json.Unmarshal(encoded, &state))
				assert.Equal(t, float64(11), state["upvalue:attempts"])
			}
			// A new VM must restore typed table keys through the real SQL JSON
			// boundary, not merely serialize a plausible first-event snapshot.
			require.NoError(t, invoke())
			require.Equal(t, 2, published)
			require.NoError(t, raw.QueryRowContext(ctx, `SELECT state_json FROM quest_runtime_script_state WHERE owner_character_id=7001 AND zone_name='testzone' AND spawn_instance_id=?`, stateKey).Scan(&encoded))
			state = nil
			require.NoError(t, json.Unmarshal(encoded, &state))
			require.Equal(t, float64(2), state["upvalue:attempts"])
		})
	}
}
