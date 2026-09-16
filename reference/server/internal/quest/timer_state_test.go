package quest

import (
	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
	"testing"
)

func TestLuaTimerReadsOverlayOrderedMutationsAndRejectMissingReader(t *testing.T) {
	event := &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{ID: 101}, ReadTimer: func(name string) (bool, bool, error) { return name == "persisted", name == "persisted", nil }}
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
assert(eq.is_paused_timer("persisted"))
eq.resume_timer("persisted")
assert(not eq.is_paused_timer("persisted"))
eq.set_timer("new",60000)
eq.pause_timer("new")
assert(eq.is_paused_timer("new"))
eq.stop_all_timers()
assert(not eq.is_paused_timer("new"))
eq.pause_timer("absent")
assert(not eq.is_paused_timer("absent"))
e.self:Say("timer reads match")
end`, event)
	require.NoError(t, err)
	require.Contains(t, capture.Responses, "timer reads match")
	event.ReadTimer = nil
	_, err = NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
pcall(function() eq.is_paused_timer("unknown") end)
e.other:SummonItem(1001)
end`, event)
	require.ErrorContains(t, err, "timer state reader is unavailable")
	_, err = NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
eq.set_timer("known",60000)
eq.pause_timer("known")
assert(eq.is_paused_timer("known"))
end`, event)
	require.NoError(t, err, "a fully specified in-event timer needs no persisted fallback")
}

func TestLocalQuestTimerReaderIsScopedAndDistinguishesMissingFromUnavailable(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "quest_runtime_timers")
	s := &Service{db: stmtcache.New(raw).SetCaching(false)}
	_, err := raw.ExecContext(ctx, `INSERT INTO quest_runtime_timers (owner_character_id,zone_name,instance_id,spawn_instance_id,npc_type_id,timer_name,interval_ms,next_fire_at,paused_at,remaining_ms) VALUES (101,'qeynos',3,5001,9001,'paused',60000,NOW(6),NOW(6),30000)`)
	require.NoError(t, err)
	for _, scope := range []struct {
		owner    uint32
		zone     string
		instance int
		spawn    int64
		npc      int32
		found    bool
	}{
		{101, "qeynos", 3, 5001, 9001, true}, {202, "qeynos", 3, 5001, 9001, false},
		{101, "qeynos", 4, 5001, 9001, false}, {101, "qeynos", 3, 5002, 9001, false},
		{101, "qeynos", 3, 5001, 9002, false}, {101, "freeport", 3, 5001, 9001, false},
	} {
		exists, paused, err := s.questTimerReader(scope.owner, scope.npc, scope.zone, scope.instance, scope.spawn)("paused")
		require.NoError(t, err)
		require.Equal(t, scope.found, exists)
		require.Equal(t, scope.found, paused)
	}
	exists, paused, err := s.questTimerReader(101, 9001, "qeynos", 3, 5001)("missing")
	require.NoError(t, err)
	require.False(t, exists)
	require.False(t, paused)
	_, err = raw.ExecContext(ctx, "UPDATE quest_runtime_timers SET paused_at=NULL WHERE owner_character_id=101")
	require.NoError(t, err)
	exists, paused, err = s.questTimerReader(101, 9001, "qeynos", 3, 5001)("paused")
	require.NoError(t, err)
	require.True(t, exists)
	require.False(t, paused)
	require.NoError(t, raw.Close())
	_, _, err = s.questTimerReader(101, 9001, "qeynos", 3, 5001)("paused")
	require.Error(t, err, "storage failure must not look like an unpaused timer")
}
