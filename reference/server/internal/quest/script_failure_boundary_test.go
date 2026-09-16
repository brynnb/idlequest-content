package quest

import (
	"testing"

	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
)

func TestLocalQuestScriptFailureBoundary(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "quests", "quest_lua_modules")
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	event := &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{ID: 7001}}
	t.Run("nullable empty script", func(t *testing.T) {
		_, err := raw.ExecContext(ctx, `INSERT INTO quests (zone,name,lua_content,enabled) VALUES ('qcat','empty',NULL,1)`)
		require.NoError(t, err)
		capture, err := s.executeEvent("say", "empty", 9001, "qcat", event)
		require.NoError(t, err, "nullable source is absence, not a storage failure")
		require.Nil(t, capture)
	})
	for _, tc := range []struct {
		name, source string
		fails        bool
	}{
		{"valid", `function event_say(e) e.self:Say("hello") end`, false},
		{"syntax", `function event_say(e) this is not Lua end`, true},
		{"execution", `function event_say(e) e.other:SummonItem(14366); error("deliberate failure") end`, true},
		{"actor", `function event_say(e) eq.get_entity_list():GetNPCByNPCTypeID(9002) end`, true},
	} {
		t.Run(tc.name, func(t *testing.T) {
			_, err := raw.ExecContext(ctx, `INSERT INTO quests (zone,name,lua_content,enabled) VALUES ('qcat',?,?,1)`, tc.name, tc.source)
			require.NoError(t, err)
			capture, err := s.executeEvent("say", tc.name, 9001, "qcat", event)
			if tc.fails {
				require.Error(t, err, "failed Lua must not look like absent dialogue")
				require.Nil(t, capture, "partial rewards must not escape")
			} else {
				require.NoError(t, err)
				require.Equal(t, []string{"hello"}, capture.Responses)
			}
		})
	}
	t.Run("absent", func(t *testing.T) {
		capture, err := s.executeEvent("say", "absent", 9001, "qcat", event)
		require.NoError(t, err)
		require.Nil(t, capture)
		_, found, err := s.loadModuleFromDB("absent")
		require.NoError(t, err)
		require.False(t, found)
	})
	t.Run("module schema failure", func(t *testing.T) {
		// Change only this test connection's default schema to a read-only
		// system schema with no quest table. Do not drop the temporary table:
		// doing so would expose the real table it shadows. Close immediately
		// afterward; the unavailable-store error contains quest_lua_modules.
		_, err := raw.ExecContext(ctx, "USE information_schema")
		require.NoError(t, err)
		_, found, err := s.loadModuleFromDB("required")
		require.Error(t, err)
		require.False(t, found)
	})
	require.NoError(t, raw.Close())
	t.Run("database unavailable", func(t *testing.T) {
		_, err := s.loadScriptFromDB("qcat", "valid")
		require.Error(t, err)
		capture, err := s.executeEvent("say", "valid", 9001, "qcat", event)
		require.Error(t, err)
		require.Nil(t, capture)
	})
}

func TestLocalEncounterDiscoveryFailureIsNotCachedAsAbsent(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "quests", "npc_types")
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	_, err := raw.ExecContext(ctx, "INSERT INTO npc_types (id,name) VALUES (9001,'NoDirectScript')")
	require.NoError(t, err)
	_, err = raw.ExecContext(ctx, `INSERT INTO quests (zone,name,lua_content,enabled) VALUES
 ('qcat','script_init',?,1), ('encounters','broken',?,1)`,
		`eq.load_encounter("broken")`,
		`function event_encounter_load(e)
 error("temporary failure")
 eq.register_npc_event(Event.say, 9001, function(e) e.self:Say("hello") end)
end`)
	require.NoError(t, err)
	found, err := s.HasRuntimeEvent(9001, "qcat", RuntimeEventSay)
	require.ErrorContains(t, err, "temporary failure")
	require.False(t, found)
	require.Empty(t, s.handlerCache)
	_, err = raw.ExecContext(ctx, `UPDATE quests SET lua_content=? WHERE zone='encounters' AND name='broken'`,
		`function event_encounter_load(e)
 eq.register_npc_event(Event.say, 9001, function(e) e.self:Say("hello") end)
end`)
	require.NoError(t, err)
	found, err = s.HasRuntimeEvent(9001, "qcat", RuntimeEventSay)
	require.NoError(t, err)
	require.True(t, found, "retry must discover the recovered handler, not an error cached as false")
}
