package quest

import (
	"context"
	"fmt"
	"sort"
	"time"

	"github.com/go-jet/jet/v2/stmtcache"
)

// Runtime callbacks may share an event but own distinct persistent state
// records. Stage copies before merging captures, which merges Lua variables.
type questRuntimeStateWrite struct {
	npcID int32
	key   int64
	state map[string]any
	added []NPCAddedLoot
}

type questEncounterScript struct{ name, source string }

// Release the result set before loading callback state. Otherwise a one-
// connection pool deadlocks and ordinary pools retain connections during Lua.
func (s *Service) loadRegisteredEncounterScripts(loaded map[string]bool, registration string) ([]questEncounterScript, error) {
	rows, err := s.db.Query(`SELECT name, lua_content FROM quests WHERE zone='encounters' AND enabled=1 AND lua_content IS NOT NULL AND lua_content != '' AND lua_content LIKE ? ORDER BY name`, "%"+registration+"%")
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var scripts []questEncounterScript
	for rows.Next() {
		var script questEncounterScript
		if err := rows.Scan(&script.name, &script.source); err != nil {
			return nil, err
		}
		if loaded[script.name] {
			scripts = append(scripts, script)
		}
	}
	return scripts, rows.Err()
}

func stageQuestRuntimeState(capture *QuestCapture, npcID int32, spawnID int64) {
	capture.runtimeStateWrites = append(capture.runtimeStateWrites, questRuntimeStateWrite{
		npcID: npcID, key: questRuntimeScriptStateKey(npcID, spawnID),
		state: cloneScriptState(capture.ScriptState), added: append([]NPCAddedLoot(nil), capture.NPCAddedLoot...),
	})
}

func persistQuestEventStatesTx(ctx context.Context, tx *stmtcache.Tx, characterID uint32,
	npcID int32, zone string, runtime QuestTurnInContext, capture *QuestCapture) error {
	if len(capture.runtimeStateWrites) == 0 {
		return PersistRuntimeScriptStateTx(ctx, tx, characterID, npcID, zone, runtime.InstanceID,
			questRuntimeScriptStateKey(npcID, runtime.SpawnInstanceID), capture.ScriptState, capture.NPCAddedLoot)
	}
	writes := append([]questRuntimeStateWrite(nil), capture.runtimeStateWrites...)
	sort.SliceStable(writes, func(i, j int) bool { return writes[i].key < writes[j].key })
	for _, write := range writes {
		if err := PersistRuntimeScriptStateTx(ctx, tx, characterID, write.npcID, zone, runtime.InstanceID, write.key, write.state, write.added); err != nil {
			return err
		}
	}
	return nil
}

// Reuse turn-in persistence for ordinary dialogue/runtime character changes
// and all staged actor states. Prepared server effects join this transaction;
// other items/world effects still use post-commit delivery, not a durable outbox.
func (s *Service) persistQuestEventCapture(characterID uint32, npcID, zoneID int32,
	zone string, runtime QuestTurnInContext, capture *QuestCapture) (RewardSummary, error) {
	effects, err := s.prepareRuntimeEffects(characterID, npcID, zone, runtime, capture)
	if err != nil {
		return RewardSummary{}, err
	}
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return RewardSummary{}, fmt.Errorf("begin quest event settlement: %w", err)
	}
	defer tx.Rollback()
	if err := s.persistQuestCaptureTx(ctx, tx, characterID, npcID, zoneID, zone, runtime, capture); err != nil {
		return RewardSummary{}, err
	}
	if capture.Currency != (QuestCurrency{}) {
		if err := settleQuestCurrency(ctx, tx, characterID, QuestCurrency{}, capture.Currency); err != nil {
			return RewardSummary{}, err
		}
	}
	if err := effects.persist(ctx, tx); err != nil {
		return RewardSummary{}, err
	}
	if err := tx.Commit(); err != nil {
		return RewardSummary{}, fmt.Errorf("commit quest event settlement: %w", err)
	}
	effects.publish()
	return s.describeQuestCaptureRewards(capture), nil
}
