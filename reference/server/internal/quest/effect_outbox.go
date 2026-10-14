package quest

import (
	"context"
	"crypto/rand"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/go-jet/jet/v2/stmtcache"
)

const maxQuestEffectPayloadBytes = 256 * 1024

var ErrQuestEffectCancelled = errors.New("quest effect was cancelled")

// Intent survives a crash after quest settlement but before world delivery.
// The versioned payload belongs to the executor; persistence never interprets
// an intent as proof that a spawn, move, or combat action was applied.
type QuestEffectIntent struct {
	DeliveryID     string
	CharacterID    uint32
	ZoneName       string
	InstanceID     int
	PayloadVersion uint16
	Payload        json.RawMessage
}

func NewQuestEffectIntent(owner uint32, zone string, instance int, version uint16, payload json.RawMessage) (QuestEffectIntent, error) {
	var id [16]byte
	if _, err := rand.Read(id[:]); err != nil {
		return QuestEffectIntent{}, err
	}
	intent := QuestEffectIntent{DeliveryID: hex.EncodeToString(id[:]), CharacterID: owner,
		ZoneName: zone, InstanceID: instance, PayloadVersion: version, Payload: append(json.RawMessage(nil), payload...)}
	return intent, intent.validate()
}

func (intent QuestEffectIntent) validate() error {
	id, err := hex.DecodeString(intent.DeliveryID)
	if err != nil || len(id) != 16 || intent.CharacterID == 0 || intent.InstanceID < 0 ||
		intent.ZoneName == "" || strings.TrimSpace(intent.ZoneName) != intent.ZoneName || len(intent.ZoneName) > 64 ||
		intent.PayloadVersion == 0 || len(intent.Payload) > maxQuestEffectPayloadBytes || !json.Valid(intent.Payload) {
		return fmt.Errorf("invalid quest effect delivery intent")
	}
	return nil
}

// No standalone enqueue operation: callers must join the parent quest's
// existing transaction. A duplicate delivery ID is an error, never an upsert
// that could overwrite an already issued command with different contents.
func PersistQuestEffectIntentTx(ctx context.Context, tx *stmtcache.Tx, intent QuestEffectIntent) error {
	if tx == nil {
		return fmt.Errorf("quest effect intent requires the parent transaction")
	}
	if err := intent.validate(); err != nil {
		return err
	}
	_, err := tx.ExecContext(ctx, `INSERT INTO quest_effect_outbox
        (delivery_id,character_id,zone_name,instance_id,payload_version,payload)
        VALUES (?,?,?,?,?,?)`, intent.DeliveryID, intent.CharacterID, intent.ZoneName, intent.InstanceID, intent.PayloadVersion, []byte(intent.Payload))
	return err
}

// Ordered bounded replay leaves receipts intact; reading does not acknowledge
// or delete anything. A dispatcher must also validate actor generations and
// the live session before applying any returned intent.
// Enqueue order, not timestamp/UUID order, preserves same-transaction effects.
// This is not cross-transaction commit ordering: the eventual dispatcher must
// serialize settlement/replay per owner before treating it as a causal stream.
func LoadPendingQuestEffectIntents(ctx context.Context, database *stmtcache.DB, owner uint32, limit int) ([]QuestEffectIntent, error) {
	if owner == 0 || limit < 1 || limit > 128 {
		return nil, fmt.Errorf("invalid quest effect replay scope")
	}
	rows, err := database.QueryContext(ctx, `SELECT delivery_id,character_id,zone_name,instance_id,payload_version,payload
        FROM quest_effect_outbox WHERE character_id=? AND completed_at IS NULL AND cancelled_at IS NULL
        ORDER BY enqueue_sequence LIMIT ?`, owner, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var intents []QuestEffectIntent
	for rows.Next() {
		var intent QuestEffectIntent
		if err := rows.Scan(&intent.DeliveryID, &intent.CharacterID, &intent.ZoneName, &intent.InstanceID, &intent.PayloadVersion, &intent.Payload); err != nil {
			return nil, err
		}
		if err := intent.validate(); err != nil {
			return nil, fmt.Errorf("stored delivery %s: %w", intent.DeliveryID, err)
		}
		intents = append(intents, intent)
	}
	return intents, rows.Err()
}

// Read a bounded, zone-scoped window. The executor preserves ordering for
// overlapping actors while independent actors may proceed concurrently.
func LoadPendingQuestEffectIntentsForZone(ctx context.Context, database *stmtcache.DB, owner uint32, zone string, instance, limit int) ([]QuestEffectIntent, error) {
	if owner == 0 || zone == "" || instance < 0 || limit < 1 || limit > 128 {
		return nil, fmt.Errorf("invalid quest effect replay scope")
	}
	rows, err := database.QueryContext(ctx, `SELECT delivery_id,character_id,zone_name,instance_id,payload_version,payload
 FROM quest_effect_outbox WHERE character_id=? AND zone_name=? AND instance_id=? AND completed_at IS NULL AND cancelled_at IS NULL
 ORDER BY enqueue_sequence LIMIT ?`, owner, zone, instance, limit)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var intents []QuestEffectIntent
	for rows.Next() {
		var intent QuestEffectIntent
		if err := rows.Scan(&intent.DeliveryID, &intent.CharacterID, &intent.ZoneName, &intent.InstanceID, &intent.PayloadVersion, &intent.Payload); err != nil {
			return nil, err
		}
		if err := intent.validate(); err != nil {
			return nil, err
		}
		intents = append(intents, intent)
	}
	return intents, rows.Err()
}

func LoadNextPendingQuestEffectIntent(ctx context.Context, database *stmtcache.DB, owner uint32, zone string, instance int) (*QuestEffectIntent, error) {
	intents, err := LoadPendingQuestEffectIntentsForZone(ctx, database, owner, zone, instance, 1)
	if err != nil || len(intents) == 0 {
		return nil, err
	}
	return &intents[0], nil
}

// Completed authorizations are looked up by exact receipt and authenticated
// scope, never by a client-selected NPC type or newest matching quest. A pending
// or cancelled request is not evidence that its combat operation executed.
func LoadCompletedQuestEffectIntent(ctx context.Context, database *stmtcache.DB, id string, owner uint32, zone string, instance int) (*QuestEffectIntent, error) {
	decoded, err := hex.DecodeString(id)
	if err != nil || len(decoded) != 16 || owner == 0 || zone == "" || instance < 0 {
		return nil, fmt.Errorf("invalid completed quest effect scope")
	}
	var intent QuestEffectIntent
	err = database.QueryRowContext(ctx, `SELECT delivery_id,character_id,zone_name,instance_id,payload_version,payload
		FROM quest_effect_outbox WHERE delivery_id=? AND character_id=? AND zone_name=? AND instance_id=? AND completed_at IS NOT NULL AND cancelled_at IS NULL`, id, owner, zone, instance).
		Scan(&intent.DeliveryID, &intent.CharacterID, &intent.ZoneName, &intent.InstanceID, &intent.PayloadVersion, &intent.Payload)
	if errors.Is(err, sql.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if err := intent.validate(); err != nil {
		return nil, err
	}
	return &intent, nil
}

// Internal settlement primitive, not a client-ack handler. The executor must
// validate the stored payload/lifetimes. Durable world effects persist their
// resulting state in this SAME transaction; ephemeral combat effects require
// an accepted, cached owner snapshot carrying the applied-command receipt.
// Combat still follows its ordinary server-restart reset policy.
// A successful socket send is not an application.
// Completed retries never reapply state or fire another quest callback.
func CompleteQuestEffectIntentTx(ctx context.Context, tx *stmtcache.Tx, id string, owner uint32, zone string, instance int, validateAndApply func(QuestEffectIntent) error) error {
	if tx == nil || owner == 0 || validateAndApply == nil {
		return fmt.Errorf("quest effect completion requires transaction, owner and executor")
	}
	intent := QuestEffectIntent{DeliveryID: id, CharacterID: owner, ZoneName: zone, InstanceID: instance}
	var completed, cancelled bool
	if err := tx.QueryRowContext(ctx, `SELECT payload_version,payload,completed_at IS NOT NULL,cancelled_at IS NOT NULL FROM quest_effect_outbox
		WHERE delivery_id=? AND character_id=? AND zone_name=? AND instance_id=? FOR UPDATE`, id, owner, zone, instance).Scan(&intent.PayloadVersion, &intent.Payload, &completed, &cancelled); err != nil {
		return err
	}
	if err := intent.validate(); err != nil {
		return err
	}
	if cancelled {
		return ErrQuestEffectCancelled
	}
	if completed {
		return nil
	}
	if err := validateAndApply(intent); err != nil {
		return err
	}
	_, err := tx.ExecContext(ctx, `UPDATE quest_effect_outbox SET completed_at=CURRENT_TIMESTAMP(6)
        WHERE delivery_id=? AND character_id=? AND zone_name=? AND instance_id=? AND completed_at IS NULL AND cancelled_at IS NULL`, id, owner, zone, instance)
	return err
}

// Only an authoritative executor may prove an intent obsolete. No client
// cancellation request can call this directly or turn it into a success receipt.
func CancelQuestEffectIntentTx(ctx context.Context, tx *stmtcache.Tx, id string, owner uint32, zone string, instance int, reason string, validateObsolete func(QuestEffectIntent) error) (bool, error) {
	if tx == nil || owner == 0 || validateObsolete == nil || reason == "" || len(reason) > 64 || strings.TrimSpace(reason) != reason {
		return false, fmt.Errorf("quest effect cancellation requires transaction, scope, reason and validator")
	}
	intent := QuestEffectIntent{DeliveryID: id, CharacterID: owner, ZoneName: zone, InstanceID: instance}
	var completed, cancelled bool
	if err := tx.QueryRowContext(ctx, `SELECT payload_version,payload,completed_at IS NOT NULL,cancelled_at IS NOT NULL FROM quest_effect_outbox
		WHERE delivery_id=? AND character_id=? AND zone_name=? AND instance_id=? FOR UPDATE`, id, owner, zone, instance).Scan(&intent.PayloadVersion, &intent.Payload, &completed, &cancelled); err != nil {
		return false, err
	}
	if err := intent.validate(); err != nil {
		return false, err
	}
	if completed || cancelled {
		return false, nil
	}
	if err := validateObsolete(intent); err != nil {
		return false, err
	}
	_, err := tx.ExecContext(ctx, `UPDATE quest_effect_outbox SET cancelled_at=CURRENT_TIMESTAMP(6),cancellation_reason=?
		WHERE delivery_id=? AND character_id=? AND zone_name=? AND instance_id=? AND completed_at IS NULL AND cancelled_at IS NULL`, reason, id, owner, zone, instance)
	return err == nil, err
}
