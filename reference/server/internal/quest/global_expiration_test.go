package quest

import (
	"testing"
	"time"

	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
)

func TestQuestGlobalDurationUnits(t *testing.T) {
	const now = int64(1780000000)
	for duration, seconds := range map[string]int64{
		"S5": 5, "m30": 1800, "H1": 3600, "D2": 172800, "Y1": 31556926,
		"S0": 0, "S-1": -1, "invalid": 0, "M": 0,
	} {
		t.Run(duration, func(t *testing.T) {
			expiry := questGlobalExpiration(duration, now)
			require.NotNil(t, expiry)
			require.Equal(t, now+seconds, *expiry)
		})
	}
	for _, duration := range []string{"F", "f", ""} {
		require.Nil(t, questGlobalExpiration(duration, now))
	}
}

func TestLocalQuestGlobalsExcludeExpiredFlags(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "quest_globals")
	now := time.Now().Unix()
	_, err := raw.ExecContext(ctx, `INSERT INTO quest_globals (charid,npcid,zoneid,name,value,expdate) VALUES
 (7001,9001,123,'forever','1',NULL),
 (7001,9001,123,'expired','1',?),
 (7001,9001,123,'future','1',?),
 (7002,9001,123,'other_character','1',NULL)`, now-60, now+600)
	require.NoError(t, err)
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	globals, err := s.getGlobals(7001, 9001, 123)
	require.NoError(t, err)
	require.Equal(t, map[string]string{"forever": "1", "future": "1"}, globals)
}

func TestLocalSharedGlobalClaimRejectsStaleCallerAndRollsBackReward(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "quest_globals", "quest_runtime_script_state", "character_currency")
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	expires := time.Now().Unix() + 60
	_, err := raw.ExecContext(ctx, `INSERT INTO quest_globals(charid,npcid,zoneid,name,value,expdate) VALUES(0,9001,123,'invitation','1',?)`, expires)
	require.NoError(t, err)
	_, err = raw.ExecContext(ctx, `INSERT INTO character_currency(id,gold) VALUES(7001,0),(7002,0)`)
	require.NoError(t, err)
	bridge := NewLuaBridge("upstream/projecteq")
	claim := func(owner uint32) *QuestCapture {
		t.Helper()
		values, snapshot, err := s.getGlobalsWithSnapshot(owner, 9001, 123)
		require.NoError(t, err)
		e := armorEvent()
		e.Player.ID = owner
		e.Globals, e.GlobalSnapshot = values, snapshot
		capture, err := bridge.ExecuteSayFromSource(`function event_say(e)
if eq.get_qglobals().invitation == "1" then
  eq.del_global("invitation")
  e.other:AddMoneyToPP(0,0,1,0,true)
end
end`, e)
		require.NoError(t, err)
		return capture
	}
	// Both callers saw the same live invitation before either settled.
	first, stale := claim(7001), claim(7002)
	_, err = s.persistQuestEventCapture(7001, 9001, 123, "testzone", QuestTurnInContext{SpawnInstanceID: 6001}, first)
	require.NoError(t, err)
	_, err = s.persistQuestEventCapture(7002, 9001, 123, "testzone", QuestTurnInContext{SpawnInstanceID: 6001}, stale)
	require.ErrorContains(t, err, "invitation changed or expired")
	for owner, want := range map[uint32]int{7001: 1, 7002: 0} {
		var gold int
		require.NoError(t, raw.QueryRowContext(ctx, "SELECT gold FROM character_currency WHERE id=?", owner).Scan(&gold))
		require.Equal(t, want, gold)
	}
	// Reopening the shared invitation invalidates the old expiry/scope preimage,
	// even when its string value happens to be identical.
	_, err = raw.ExecContext(ctx, `INSERT INTO quest_globals(charid,npcid,zoneid,name,value,expdate) VALUES(0,9001,123,'invitation','1',?)`, expires+60)
	require.NoError(t, err)
	_, err = s.persistQuestEventCapture(7002, 9001, 123, "testzone", QuestTurnInContext{SpawnInstanceID: 6001}, stale)
	require.ErrorContains(t, err, "invitation changed or expired")
	fresh := claim(7002)
	_, err = raw.ExecContext(ctx, "UPDATE quest_globals SET expdate=? WHERE name='invitation'", time.Now().Unix()-1)
	require.NoError(t, err)
	_, err = s.persistQuestEventCapture(7002, 9001, 123, "testzone", QuestTurnInContext{SpawnInstanceID: 6001}, fresh)
	require.ErrorContains(t, err, "invitation changed or expired")
}

func TestLocalQuestGlobalWritesPreserveDuration(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "quest_globals", "quest_runtime_script_state")
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	for _, transactional := range []bool{false, true} {
		t.Run(map[bool]string{false: "runtime", true: "turnin"}[transactional], func(t *testing.T) {
			capture := NewQuestCapture()
			capture.Globals["temporary"] = GlobalUpdate{Name: "temporary", Value: "1", Options: 5, Duration: "M30"}
			capture.Globals["permanent"] = GlobalUpdate{Name: "permanent", Value: "1", Options: 5, Duration: "F"}
			before := time.Now().Unix()
			if transactional {
				tx, err := s.db.BeginTx(ctx, nil)
				require.NoError(t, err)
				defer tx.Rollback()
				err = s.persistQuestCaptureTx(ctx, tx, 7001, 9001, 123, "testzone", QuestTurnInContext{SpawnInstanceID: 6001}, capture)
				require.NoError(t, err)
				require.NoError(t, tx.Commit())
			} else {
				_, err := s.persistQuestEventCapture(7001, 9001, 123, "testzone", QuestTurnInContext{SpawnInstanceID: 6001}, capture)
				require.NoError(t, err)
			}
			var expiry *int64
			require.NoError(t, raw.QueryRowContext(ctx, `SELECT expdate FROM quest_globals WHERE charid=7001 AND npcid=0 AND zoneid=0 AND name='temporary'`).Scan(&expiry))
			require.NotNil(t, expiry, "a timed quest flag must not be permanent")
			require.GreaterOrEqual(t, *expiry, before+1800)
			require.LessOrEqual(t, *expiry, time.Now().Unix()+1800)
			require.NoError(t, raw.QueryRowContext(ctx, `SELECT expdate FROM quest_globals WHERE charid=7001 AND npcid=0 AND zoneid=0 AND name='permanent'`).Scan(&expiry))
			require.Nil(t, expiry)
		})
	}
}

func TestLocalQuestGlobalDeletionUsesVisibleScope(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "quest_globals", "quest_runtime_script_state")
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	for _, transactional := range []bool{false, true} {
		t.Run(map[bool]string{false: "runtime", true: "turnin"}[transactional], func(t *testing.T) {
			// Replace only these temporary fixture rows before each path.
			_, err := raw.ExecContext(ctx, `REPLACE INTO quest_globals (charid,npcid,zoneid,name,value) VALUES
 (7001,9001,123,'stage','local'), (0,9001,123,'stage','shared-character'),
 (7001,0,123,'stage','shared-NPC'), (7001,9001,0,'stage','shared-zone'),
 (0,0,0,'stage','shared-all'),
 (7002,9001,123,'stage','other-character'),
 (7001,9002,123,'stage','other-NPC'),
 (7001,9001,456,'stage','other-zone'),
 (7001,9001,123,'different-name','preserved')`)
			require.NoError(t, err)
			capture := NewQuestCapture()
			capture.Globals["stage"] = GlobalUpdate{Name: "stage", Delete: true}
			if transactional {
				tx, err := s.db.BeginTx(ctx, nil)
				require.NoError(t, err)
				defer tx.Rollback()
				require.NoError(t, s.persistQuestCaptureTx(ctx, tx, 7001, 9001, 123, "testzone", QuestTurnInContext{SpawnInstanceID: 6001}, capture))
				require.NoError(t, tx.Commit())
			} else {
				_, err := s.persistQuestEventCapture(7001, 9001, 123, "testzone", QuestTurnInContext{SpawnInstanceID: 6001}, capture)
				require.NoError(t, err)
			}
			rows, err := raw.QueryContext(ctx, `SELECT value FROM quest_globals ORDER BY value`)
			require.NoError(t, err)
			defer rows.Close()
			var remaining []string
			for rows.Next() {
				var value string
				require.NoError(t, rows.Scan(&value))
				remaining = append(remaining, value)
			}
			require.NoError(t, rows.Err())
			require.ElementsMatch(t, []string{"other-character", "other-NPC", "other-zone", "preserved"}, remaining)
		})
	}
}
