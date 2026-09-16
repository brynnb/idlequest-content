package quest

import (
	"encoding/json"
	"errors"
	"strings"
	"testing"

	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
)

func TestQuestEffectIntentValidatesAndOwnsPayload(t *testing.T) {
	payload := json.RawMessage(`{"commands":[]}`)
	intent, err := NewQuestEffectIntent(123, "airplane", 2, 1, payload)
	require.NoError(t, err)
	payload[0] = '!'
	require.True(t, json.Valid(intent.Payload))
	for _, change := range []func(*QuestEffectIntent){
		func(i *QuestEffectIntent) { i.CharacterID = 0 },
		func(i *QuestEffectIntent) { i.DeliveryID = "bad" },
		func(i *QuestEffectIntent) { i.InstanceID = -1 },
		func(i *QuestEffectIntent) { i.PayloadVersion = 0 },
		func(i *QuestEffectIntent) { i.ZoneName = " " },
		func(i *QuestEffectIntent) { i.Payload = nil },
		func(i *QuestEffectIntent) {
			i.Payload = json.RawMessage(strings.Repeat(" ", maxQuestEffectPayloadBytes+1))
		},
	} {
		copy := intent
		change(&copy)
		require.Error(t, copy.validate())
	}
}

func TestLocalCompletedQuestEffectLookupRejectsPendingCancelledAndForeignScope(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t)
	testutil.TemporaryQuestEffectOutbox(t, ctx, raw)
	database := stmtcache.New(raw).SetCaching(false)
	intent, err := NewQuestEffectIntent(101, "freportw", 2, 1, json.RawMessage(`{"commands":[]}`))
	require.NoError(t, err)
	tx, err := database.BeginTx(ctx, nil)
	require.NoError(t, err)
	require.NoError(t, PersistQuestEffectIntentTx(ctx, tx, intent))
	require.NoError(t, tx.Commit())
	read := func(owner uint32, zone string, instance int) *QuestEffectIntent {
		got, err := LoadCompletedQuestEffectIntent(ctx, database, intent.DeliveryID, owner, zone, instance)
		require.NoError(t, err)
		return got
	}
	require.Nil(t, read(101, "freportw", 2), "pending is not authorization")
	tx, err = database.BeginTx(ctx, nil)
	require.NoError(t, err)
	require.NoError(t, CompleteQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 101, "freportw", 2, func(QuestEffectIntent) error { return nil }))
	require.NoError(t, tx.Commit())
	completed := read(101, "freportw", 2)
	require.NotNil(t, completed)
	// MySQL JSON columns normalize whitespace; compare payload meaning and
	// retain exact comparisons for all authority-bearing scope fields.
	require.JSONEq(t, string(intent.Payload), string(completed.Payload))
	copy := *completed
	copy.Payload = intent.Payload
	require.Equal(t, intent, copy)
	require.Nil(t, read(102, "freportw", 2))
	require.Nil(t, read(101, "freportn", 2))
	require.Nil(t, read(101, "freportw", 3))
	// Defensive read also rejects contradictory historical/corrupt receipts.
	_, err = raw.ExecContext(ctx, `UPDATE quest_effect_outbox SET cancelled_at=CURRENT_TIMESTAMP(6) WHERE delivery_id=?`, intent.DeliveryID)
	require.NoError(t, err)
	require.Nil(t, read(101, "freportw", 2))
}

func TestLocalQuestEffectCancellationIsScopedAtomicAndNotSuccess(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t)
	testutil.TemporaryQuestEffectOutbox(t, ctx, raw)
	database := stmtcache.New(raw).SetCaching(false)
	intent, err := NewQuestEffectIntent(101, "qeynos", 0, 1, json.RawMessage(`{"commands":[]}`))
	require.NoError(t, err)
	tx, err := database.BeginTx(ctx, nil)
	require.NoError(t, err)
	require.NoError(t, PersistQuestEffectIntentTx(ctx, tx, intent))
	require.NoError(t, tx.Commit())
	validated := 0
	validate := func(stored QuestEffectIntent) error {
		validated++
		require.Equal(t, intent.DeliveryID, stored.DeliveryID)
		return nil
	}
	tx, err = database.BeginTx(ctx, nil)
	require.NoError(t, err)
	_, err = CancelQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 102, "qeynos", 0, "actor-unavailable", validate)
	require.Error(t, err)
	_, err = CancelQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 101, "qeynos", 1, "actor-unavailable", validate)
	require.Error(t, err)
	require.Zero(t, validated)
	_, err = CancelQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 101, "qeynos", 0, "actor-unavailable", func(QuestEffectIntent) error { return errors.New("actor still alive") })
	require.ErrorContains(t, err, "still alive")
	changed, err := CancelQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 101, "qeynos", 0, "actor-unavailable", validate)
	require.NoError(t, err)
	require.True(t, changed)
	require.NoError(t, tx.Rollback())
	pending, err := LoadPendingQuestEffectIntents(ctx, database, 101, 10)
	require.NoError(t, err)
	require.Len(t, pending, 1, "rollback retains the pending command")
	tx, err = database.BeginTx(ctx, nil)
	require.NoError(t, err)
	changed, err = CancelQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 101, "qeynos", 0, "actor-unavailable", validate)
	require.NoError(t, err)
	require.True(t, changed)
	changed, err = CancelQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 101, "qeynos", 0, "another-reason", validate)
	require.NoError(t, err)
	require.False(t, changed)
	err = CompleteQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 101, "qeynos", 0, func(QuestEffectIntent) error { t.Fatal("cancelled intent must never apply effects"); return nil })
	require.ErrorIs(t, err, ErrQuestEffectCancelled)
	require.NoError(t, tx.Commit())
	pending, err = LoadPendingQuestEffectIntents(ctx, database, 101, 10)
	require.NoError(t, err)
	require.Empty(t, pending)
	var completed, cancelled bool
	var reason string
	require.NoError(t, raw.QueryRowContext(ctx, "SELECT completed_at IS NOT NULL,cancelled_at IS NOT NULL,cancellation_reason FROM quest_effect_outbox WHERE delivery_id=?", intent.DeliveryID).Scan(&completed, &cancelled, &reason))
	require.False(t, completed)
	require.True(t, cancelled)
	require.Equal(t, "actor-unavailable", reason)
	require.Equal(t, 2, validated, "duplicate cancellation does not rerun the validator")
}

func TestLocalQuestEffectOutboxCommitsWithPaymentAndRetainsScopedReceipt(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "character_currency")
	testutil.TemporaryQuestEffectOutbox(t, ctx, raw)
	_, err := raw.ExecContext(ctx, "INSERT INTO character_currency(id,gold) VALUES (7001,10)")
	require.NoError(t, err)
	database := stmtcache.New(raw).SetCaching(false)
	intent, err := NewQuestEffectIntent(7001, "airplane", 2, 1, json.RawMessage(`{"commands":[]}`))
	require.NoError(t, err)
	settle := func(commit bool) {
		tx, err := database.BeginTx(ctx, nil)
		require.NoError(t, err)
		defer tx.Rollback()
		_, err = tx.ExecContext(ctx, "UPDATE character_currency SET gold=0 WHERE id=7001")
		require.NoError(t, err)
		require.NoError(t, PersistQuestEffectIntentTx(ctx, tx, intent))
		if commit {
			require.NoError(t, tx.Commit())
		} else {
			require.NoError(t, tx.Rollback())
		}
	}
	settle(false)
	var gold int
	require.NoError(t, raw.QueryRowContext(ctx, "SELECT gold FROM character_currency WHERE id=7001").Scan(&gold))
	require.Equal(t, 10, gold)
	pending, err := LoadPendingQuestEffectIntents(ctx, database, 7001, 10)
	require.NoError(t, err)
	require.Empty(t, pending)
	settle(true)
	require.NoError(t, raw.QueryRowContext(ctx, "SELECT gold FROM character_currency WHERE id=7001").Scan(&gold))
	require.Zero(t, gold)
	pending, err = LoadPendingQuestEffectIntents(ctx, database, 7001, 10)
	require.NoError(t, err)
	require.Len(t, pending, 1)
	require.Equal(t, intent.DeliveryID, pending[0].DeliveryID)
	require.JSONEq(t, string(intent.Payload), string(pending[0].Payload))
	other, err := LoadPendingQuestEffectIntents(ctx, database, 7002, 10)
	require.NoError(t, err)
	require.Empty(t, other)
	tx, err := database.BeginTx(ctx, nil)
	require.NoError(t, err)
	require.Error(t, PersistQuestEffectIntentTx(ctx, tx, intent), "duplicate must not overwrite intent")
	require.NoError(t, tx.Rollback())
	tx, err = database.BeginTx(ctx, nil)
	require.NoError(t, err)
	defer tx.Rollback()
	applications := 0
	apply := func(stored QuestEffectIntent) error {
		applications++
		require.JSONEq(t, string(intent.Payload), string(stored.Payload))
		stored.Payload = intent.Payload // MySQL canonicalizes JSON whitespace.
		require.Equal(t, intent, stored)
		return nil
	}
	require.Error(t, CompleteQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 7002, "airplane", 2, apply))
	require.Error(t, CompleteQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 7001, "airplane", 3, apply))
	require.Zero(t, applications)
	require.NoError(t, CompleteQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 7001, "airplane", 2, apply))
	require.NoError(t, CompleteQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 7001, "airplane", 2, apply))
	require.Equal(t, 1, applications)
	require.NoError(t, tx.Commit())
	pending, err = LoadPendingQuestEffectIntents(ctx, database, 7001, 10)
	require.NoError(t, err)
	require.Empty(t, pending)
	var receipts int
	require.NoError(t, raw.QueryRowContext(ctx, "SELECT COUNT(*) FROM quest_effect_outbox WHERE completed_at IS NOT NULL").Scan(&receipts))
	require.Equal(t, 1, receipts, "retain completion evidence for retries")
}

func TestLocalQuestEffectOutboxPreservesEnqueueOrderWithEqualTimestamps(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "character_currency")
	testutil.TemporaryQuestEffectOutbox(t, ctx, raw)
	database := stmtcache.New(raw).SetCaching(false)
	tx, err := database.BeginTx(ctx, nil)
	require.NoError(t, err)
	defer tx.Rollback()
	// Opposite lexical order, identical creation time: UUIDs must not reorder
	// two stateful commands captured by the same parent transaction.
	ids := []string{strings.Repeat("f", 32), strings.Repeat("a", 32)}
	for _, id := range ids {
		intent, err := NewQuestEffectIntent(7001, "airplane", 2, 1, json.RawMessage(`{"commands":[]}`))
		require.NoError(t, err)
		intent.DeliveryID = id
		require.NoError(t, PersistQuestEffectIntentTx(ctx, tx, intent))
	}
	_, err = tx.ExecContext(ctx, "UPDATE quest_effect_outbox SET created_at='2026-01-01 00:00:00.000000'")
	require.NoError(t, err)
	require.NoError(t, tx.Commit())
	pending, err := LoadPendingQuestEffectIntents(ctx, database, 7001, 2)
	require.NoError(t, err)
	require.Len(t, pending, 2)
	require.Equal(t, ids, []string{pending[0].DeliveryID, pending[1].DeliveryID})
	first, err := LoadPendingQuestEffectIntents(ctx, database, 7001, 1)
	require.NoError(t, err)
	require.Len(t, first, 1)
	require.Equal(t, ids[0], first[0].DeliveryID)
}

func TestLocalQuestEffectCompletionRollsBackWithExecutorState(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "character_currency")
	testutil.TemporaryQuestEffectOutbox(t, ctx, raw)
	_, err := raw.ExecContext(ctx, "INSERT INTO character_currency(id,gold) VALUES(7001,10)")
	require.NoError(t, err)
	database := stmtcache.New(raw).SetCaching(false)
	intent, err := NewQuestEffectIntent(7001, "qeynos", 0, 2, json.RawMessage(`{"actor":42}`))
	require.NoError(t, err)
	tx, err := database.BeginTx(ctx, nil)
	require.NoError(t, err)
	require.NoError(t, PersistQuestEffectIntentTx(ctx, tx, intent))
	require.NoError(t, tx.Commit())

	applications := 0
	for _, attempt := range []string{"executor-failure", "commit-aborted", "committed", "receipt-retry"} {
		tx, err := database.BeginTx(ctx, nil)
		require.NoError(t, err)
		err = CompleteQuestEffectIntentTx(ctx, tx, intent.DeliveryID, 7001, "qeynos", 0, func(stored QuestEffectIntent) error {
			applications++
			require.JSONEq(t, string(intent.Payload), string(stored.Payload))
			stored.Payload = intent.Payload // Compare metadata independently of JSON formatting.
			require.Equal(t, intent, stored)
			// Representative transactional world mutation. Never open a second
			// connection inside the receipt transaction.
			_, err := tx.ExecContext(ctx, "UPDATE character_currency SET gold=gold-2 WHERE id=7001")
			if err != nil {
				return err
			}
			if attempt == "executor-failure" {
				return errors.New("actor generation changed")
			}
			return nil
		})
		if attempt == "executor-failure" {
			require.ErrorContains(t, err, "generation changed")
			require.NoError(t, tx.Rollback())
		} else {
			require.NoError(t, err)
			if attempt == "commit-aborted" {
				require.NoError(t, tx.Rollback())
			} else {
				require.NoError(t, tx.Commit())
			}
		}
		var gold, completed int
		require.NoError(t, raw.QueryRowContext(ctx, "SELECT gold FROM character_currency WHERE id=7001").Scan(&gold))
		require.NoError(t, raw.QueryRowContext(ctx, "SELECT COUNT(*) FROM quest_effect_outbox WHERE completed_at IS NOT NULL").Scan(&completed))
		if attempt == "executor-failure" || attempt == "commit-aborted" {
			require.Equal(t, 10, gold)
			require.Zero(t, completed)
		} else {
			require.Equal(t, 8, gold)
			require.Equal(t, 1, completed)
		}
	}
	require.Equal(t, 3, applications, "committed receipt retries must not reapply effects")
}
