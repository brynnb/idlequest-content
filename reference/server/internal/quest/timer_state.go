package quest

import (
	"database/sql"
	"fmt"
	"strings"

	lua "github.com/yuin/gopher-lua"
)

// Bound by the service to one owner, zone, instance and event actor. The Lua
// API supplies only the timer name, never an alternate ownership scope.
type QuestTimerReader func(name string) (exists, paused bool, err error)

func (s *Service) questTimerReader(owner uint32, npcID int32, zone string, instance int, spawnID int64) QuestTimerReader {
	return s.questTimerReaderInScope(owner, npcID, zone, instance, spawnID, false)
}

func (s *Service) questWorldTimerReader(npcID int32, zone string, instance int, spawnID int64) QuestTimerReader {
	return s.questTimerReaderInScope(0, npcID, zone, instance, spawnID, true)
}

func (s *Service) questTimerReaderInScope(owner uint32, npcID int32, zone string, instance int, spawnID int64, world bool) QuestTimerReader {
	return func(name string) (bool, bool, error) {
		validActor := (spawnID > 0 && npcID > 0) || (spawnID == PlayerRuntimeSpawnInstanceID && npcID == 0)
		if (!world && owner == 0) || (world && (owner != 0 || npcID <= 0 || spawnID <= 0)) || strings.TrimSpace(zone) == "" || instance < 0 || !validActor || strings.TrimSpace(name) == "" {
			return false, false, fmt.Errorf("invalid quest timer read scope")
		}
		var paused bool
		if world {
			var payload sql.NullString
			err := s.db.QueryRow(`SELECT paused_at IS NOT NULL,world_context FROM quest_runtime_timers WHERE owner_character_id=0 AND zone_name=? AND instance_id=? AND spawn_instance_id=? AND npc_type_id=? AND timer_name=?`, zone, instance, spawnID, npcID, name).Scan(&paused, &payload)
			if err == sql.ErrNoRows {
				return false, false, nil
			}
			if err != nil {
				return false, false, err
			}
			if !payload.Valid {
				return false, false, fmt.Errorf("world timer %s has no binding", name)
			}
			if _, err := DecodeWorldTimerBinding(payload.String); err != nil {
				return false, false, err
			}
			return true, paused, nil
		}
		err := s.db.QueryRow(`SELECT paused_at IS NOT NULL FROM quest_runtime_timers WHERE owner_character_id=? AND zone_name=? AND instance_id=? AND spawn_instance_id=? AND npc_type_id=? AND timer_name=?`, owner, zone, instance, spawnID, npcID, name).Scan(&paused)
		if err == sql.ErrNoRows {
			return false, false, nil
		}
		return err == nil, paused, err
	}
}

func readCapturedTimerState(event *LuaEvent, capture *QuestCapture, name string) (bool, bool, error) {
	known, exists, paused := false, false, false
	load := func() error {
		if known {
			return nil
		}
		if event.ReadTimer == nil {
			return fmt.Errorf("quest timer state reader is unavailable")
		}
		var err error
		exists, paused, err = event.ReadTimer(name)
		known = err == nil
		return err
	}
	for _, update := range capture.Timers {
		if update.Stop && update.Name == "*" {
			known, exists, paused = true, false, false
			continue
		}
		if update.Name != name {
			continue
		}
		switch {
		case update.Stop:
			known, exists, paused = true, false, false
		case update.Pause, update.Resume:
			if err := load(); err != nil {
				return false, false, err
			}
			if exists {
				paused = update.Pause
			}
		default:
			known, exists, paused = true, true, false
		}
	}
	if err := load(); err != nil {
		return false, false, err
	}
	return exists, paused, nil
}

func pushTimerPaused(L *lua.LState, event *LuaEvent, capture *QuestCapture) int {
	if L.GetTop() != 1 {
		return capture.rejectActorEffect(L, "is_paused_timer currently requires one timer name for the event actor")
	}
	name := L.CheckString(1)
	exists, paused, err := readCapturedTimerState(event, capture, name)
	if err != nil {
		return capture.rejectActorEffect(L, "is_paused_timer: "+err.Error())
	}
	L.Push(lua.LBool(exists && paused))
	return 1
}
