package quest

import (
	"context"
	"errors"
	"testing"

	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
)

func TestLocalQuestHandInEffectFailureRollsBackPayment(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "character_data", "character_currency", "character_inventory",
		"item_instances", "zone", "quest_runtime_script_state", "quest_turnin_transactions")
	for _, query := range []string{
		"INSERT INTO character_data (id,account_id,name,cur_hp) VALUES (7001,1,'Healed',40)",
		"INSERT INTO character_currency (id,gold) VALUES (7001,10)",
		"INSERT INTO zone (zoneidnumber,short_name,long_name) VALUES (123,'testzone','Test Zone')",
	} {
		_, err := raw.ExecContext(ctx, query)
		require.NoError(t, err)
	}
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	fail, published := true, 0
	s.PrepareRuntimeEffects = func(uint32, int32, string, QuestTurnInContext, *QuestCapture) (*RuntimeEffectSettlement, error) {
		return &RuntimeEffectSettlement{
			Persist: func(ctx context.Context, tx *stmtcache.Tx) error {
				if _, err := tx.ExecContext(ctx, "UPDATE character_data SET cur_hp=77 WHERE id=7001"); err != nil {
					return err
				}
				if fail {
					return errors.New("effect persistence failed")
				}
				return nil
			},
			Publish: func() { published++ },
		}, nil
	}
	capture := NewQuestCapture()
	capture.ScriptState["stage"] = 1
	invoke := func() error {
		_, _, err := s.settleQuestTurnIn(ctx, "heal-donation", 7001, 9001, "testzone",
			QuestTurnInContext{SpawnInstanceID: 6001}, nil, QuestCurrency{Gold: 10}, RewardSummary{}, capture, nil)
		return err
	}
	require.ErrorContains(t, invoke(), "effect persistence failed")
	for query, expected := range map[string]int{
		"SELECT cur_hp FROM character_data WHERE id=7001":   40,
		"SELECT gold FROM character_currency WHERE id=7001": 10,
		"SELECT COUNT(*) FROM quest_runtime_script_state":   0,
		"SELECT COUNT(*) FROM quest_turnin_transactions":    0,
	} {
		var value int
		require.NoError(t, raw.QueryRowContext(ctx, query).Scan(&value))
		require.Equal(t, expected, value)
	}
	require.Zero(t, published)
	fail = false
	require.NoError(t, invoke())
	require.Equal(t, 1, published)
	require.Error(t, invoke(), "duplicate hand-in must not apply its effect again")
	require.Equal(t, 1, published)
	for query, expected := range map[string]int{
		"SELECT cur_hp FROM character_data WHERE id=7001":   77,
		"SELECT gold FROM character_currency WHERE id=7001": 0,
		"SELECT COUNT(*) FROM quest_runtime_script_state":   1,
		"SELECT COUNT(*) FROM quest_turnin_transactions":    1,
	} {
		var value int
		require.NoError(t, raw.QueryRowContext(ctx, query).Scan(&value))
		require.Equal(t, expected, value)
	}
}
