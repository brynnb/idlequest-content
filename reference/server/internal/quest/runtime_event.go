package quest

import (
	"fmt"
	"hash/fnv"
	"math"
	"strings"
)

type RuntimeEventType string

const PlayerRuntimeSpawnInstanceID int64 = -1

const (
	RuntimeEventSpawn             RuntimeEventType = "spawn"
	RuntimeEventSay               RuntimeEventType = "say"
	RuntimeEventTrade             RuntimeEventType = "trade"
	RuntimeEventTimer             RuntimeEventType = "timer"
	RuntimeEventSignal            RuntimeEventType = "signal"
	RuntimeEventDeath             RuntimeEventType = "death"
	RuntimeEventDeathComplete     RuntimeEventType = "death_complete"
	RuntimeEventCombat            RuntimeEventType = "combat"
	RuntimeEventAggro             RuntimeEventType = "aggro"
	RuntimeEventAttack            RuntimeEventType = "attack"
	RuntimeEventSlay              RuntimeEventType = "slay"
	RuntimeEventKilledMerit       RuntimeEventType = "killed_merit"
	RuntimeEventHP                RuntimeEventType = "hp"
	RuntimeEventEnter             RuntimeEventType = "enter"
	RuntimeEventExit              RuntimeEventType = "exit"
	RuntimeEventWaypointArrive    RuntimeEventType = "waypoint_arrive"
	RuntimeEventWaypointDepart    RuntimeEventType = "waypoint_depart"
	RuntimeEventEnterZone         RuntimeEventType = "enter_zone"
	RuntimeEventClickDoor         RuntimeEventType = "click_door"
	RuntimeEventCastOn            RuntimeEventType = "cast_on"
	RuntimeEventProximitySay      RuntimeEventType = "proximity_say"
	RuntimeEventLoot              RuntimeEventType = "loot"
	RuntimeEventFishSuccess       RuntimeEventType = "fish_success"
	RuntimeEventForageSuccess     RuntimeEventType = "forage_success"
	RuntimeEventInspect           RuntimeEventType = "inspect"
	RuntimeEventPopupResponse     RuntimeEventType = "popup_response"
	RuntimeEventTaskStageComplete RuntimeEventType = "task_stage_complete"
	RuntimeEventTaskAccepted      RuntimeEventType = "task_accepted"
)

type RuntimeEvent struct {
	Type    RuntimeEventType
	NPC     NPCProxy
	Player  PlayerProxy
	Globals map[string]string
	Fields  map[string]any
}

func (s *Service) ExecuteRuntimeEvent(zoneShortName, npcScriptName string, event RuntimeEvent) (*QuestCapture, error) {
	if strings.TrimSpace(zoneShortName) == "" || strings.TrimSpace(npcScriptName) == "" {
		return nil, fmt.Errorf("runtime quest event requires zone and NPC script name")
	}
	switch event.Type {
	case RuntimeEventSpawn, RuntimeEventSay, RuntimeEventTrade, RuntimeEventTimer, RuntimeEventSignal, RuntimeEventDeath,
		RuntimeEventDeathComplete, RuntimeEventCombat, RuntimeEventAggro, RuntimeEventAttack, RuntimeEventSlay,
		RuntimeEventKilledMerit, RuntimeEventHP, RuntimeEventEnter,
		RuntimeEventExit, RuntimeEventWaypointArrive, RuntimeEventWaypointDepart, RuntimeEventEnterZone,
		RuntimeEventClickDoor, RuntimeEventCastOn, RuntimeEventProximitySay, RuntimeEventLoot, RuntimeEventFishSuccess, RuntimeEventForageSuccess,
		RuntimeEventInspect, RuntimeEventPopupResponse, RuntimeEventTaskStageComplete, RuntimeEventTaskAccepted:
	default:
		return nil, fmt.Errorf("unsupported runtime quest event %q", event.Type)
	}
	return s.executeEvent(string(event.Type), npcScriptName, event.NPC.ID, zoneShortName, &LuaEvent{
		NPC: &event.NPC, Player: &event.Player, Globals: event.Globals, Fields: event.Fields,
		ReadNPCCombat:       npcCombatReaderFromFields(event.Fields),
		ReadNPCGrid:         npcGridReaderFromFields(event.Fields),
		ReadSpawnConditions: spawnConditionReaderFromFields(event.Fields),
		VisibleNPCTypeIDs:   visibleNPCTypeIDsFromRuntimeFields(event.Fields),
		ResolveNPC:          npcResolverFromFields(event.Fields),
		ListNPCs:            npcEnumeratorFromFields(event.Fields),
	})
}

// ProcessRuntimeEvent builds production player/NPC/global context, executes the
// handler, and persists its durable effects. Session-specific delivery of item
// rewards and state refreshes remains the world handler's responsibility.
func (s *Service) ProcessRuntimeEvent(characterID uint32, npcID int32, spawnInstanceID int64, zoneShortName string, eventType RuntimeEventType, fields map[string]any) (*QuestCapture, RewardSummary, error) {
	return s.ProcessRuntimeEventWithContext(characterID, npcID, spawnInstanceID, zoneShortName, eventType, fields, nil, nil)
}

func (s *Service) ProcessRuntimeEventWithContext(characterID uint32, npcID int32, spawnInstanceID int64, zoneShortName string, eventType RuntimeEventType, fields map[string]any, npcPosition, playerPosition *QuestActorPosition) (*QuestCapture, RewardSummary, error) {
	return s.processNPCEventWithContext(characterID, npcID, spawnInstanceID, zoneShortName, eventType, fields, npcPosition, playerPosition, nil)
}

func (s *Service) ProcessWorldNPCTimer(characterID uint32, npcID int32, spawnID int64, zone string, fields map[string]any, position *QuestActorPosition, clock *QuestWorldTimerEvent) (*QuestCapture, RewardSummary, error) {
	if clock == nil || clock.PathEpochMs <= 0 || clock.TimerID <= 0 || clock.ExpectedFireAt.IsZero() || clock.PendingFireAt.IsZero() {
		return nil, RewardSummary{}, fmt.Errorf("invalid world timer firing context")
	}
	return s.processNPCEventWithContext(characterID, npcID, spawnID, zone, RuntimeEventTimer, fields, position, nil, clock)
}

func (s *Service) processNPCEventWithContext(characterID uint32, npcID int32, spawnInstanceID int64, zoneShortName string, eventType RuntimeEventType, fields map[string]any, npcPosition, playerPosition *QuestActorPosition, worldTimer *QuestWorldTimerEvent) (*QuestCapture, RewardSummary, error) {
	instanceID := 0
	if npcPosition != nil {
		instanceID = npcPosition.InstanceID
	}
	var npcName string
	var npcRace uint16
	var npcClass, npcGender uint8
	var npcFaction int32
	var npcHP int64
	if err := s.db.QueryRow("SELECT name, race, class, gender, npc_faction_id, hp FROM npc_types WHERE id = ?", npcID).Scan(
		&npcName, &npcRace, &npcClass, &npcGender, &npcFaction, &npcHP,
	); err != nil {
		return nil, RewardSummary{}, err
	}
	readContext, err := s.loadQuestReadContext(characterID, npcID, zoneShortName, QuestTurnInContext{
		InstanceID: instanceID, SpawnInstanceID: spawnInstanceID,
	})
	if err != nil {
		return nil, RewardSummary{}, err
	}
	player, zoneID, globals, scriptState := readContext.Player, readContext.ZoneID, readContext.Globals, readContext.ScriptState
	event := RuntimeEvent{
		Type:    eventType,
		NPC:     NPCProxy{ID: npcID, Name: strings.ReplaceAll(npcName, "_", " "), Race: npcRace, Class: npcClass, Gender: npcGender, PrimaryFaction: npcFaction, HP: npcHP, MaxHP: npcHP},
		Player:  *player.questPlayerProxy(characterID, nil),
		Globals: globals, Fields: fields,
	}
	if npcPosition != nil {
		event.NPC.X, event.NPC.Y, event.NPC.Z, event.NPC.Heading = npcPosition.X, npcPosition.Y, npcPosition.Z, npcPosition.Heading
	}
	if playerPosition != nil {
		event.Player.X, event.Player.Y, event.Player.Z, event.Player.Heading = playerPosition.X, playerPosition.Y, playerPosition.Z, playerPosition.Heading
	}
	capture, err := s.executeEvent(string(event.Type), npcName, npcID, zoneShortName, &LuaEvent{
		ReadTimer: s.questTimerReader(characterID, npcID, zoneShortName, instanceID, spawnInstanceID),
		NPC:       &event.NPC, Player: &event.Player, Globals: event.Globals, Fields: event.Fields, SpawnInstanceID: spawnInstanceID, ScriptState: scriptState,
		GlobalSnapshot:  readContext.GlobalSnapshot,
		WorldTimerEvent: worldTimer, InstanceID: instanceID,
		NPCVitals:           npcVitalsFromFields(event.Fields),
		ReadNPCCombat:       npcCombatReaderFromFields(event.Fields),
		ReadNPCGrid:         npcGridReaderFromFields(event.Fields),
		ReadSpawnConditions: spawnConditionReaderFromFields(event.Fields),
		VisibleNPCTypeIDs:   visibleNPCTypeIDsFromRuntimeFields(event.Fields),
		ResolveNPC:          npcResolverFromFields(event.Fields),
		ListNPCs:            npcEnumeratorFromFields(event.Fields),
	})
	if err != nil {
		return nil, RewardSummary{}, err
	}
	if capture == nil {
		if worldTimer != nil {
			return nil, RewardSummary{}, ErrWorldTimerScopeChanged
		}
		capture = NewQuestCapture()
	}
	stageQuestRuntimeState(capture, npcID, spawnInstanceID)
	encounterCapture, err := s.executeRegisteredEncounterNPCEvents(characterID, npcID, spawnInstanceID, zoneShortName, instanceID, eventType, &event)
	if err != nil {
		return nil, RewardSummary{}, err
	}
	mergeQuestCapture(capture, encounterCapture)
	if progress, ok := fields["__quest_waypoint_progress"].(*QuestWaypointProgress); ok && progress != nil &&
		(eventType == RuntimeEventWaypointArrive || eventType == RuntimeEventWaypointDepart) {
		copy := *progress
		capture.WaypointProgress = &copy
	}
	if progress, ok := fields["__quest_signal_progress"].(*QuestSignalProgress); ok && progress != nil && eventType == RuntimeEventSignal {
		copy := *progress
		capture.SignalProgress = &copy
	}
	capture.GlobalSnapshot = readContext.GlobalSnapshot
	capture.Responses = formatQuestResponses(capture.Responses, player)
	rewards, err := s.persistQuestEventCapture(characterID, npcID, zoneID, zoneShortName,
		QuestTurnInContext{InstanceID: instanceID, SpawnInstanceID: spawnInstanceID, NPCVitals: npcVitalsFromFields(fields)}, capture)
	if err != nil {
		return nil, RewardSummary{}, err
	}
	return capture, rewards, nil
}

func (s *Service) ProcessPlayerRuntimeEvent(characterID uint32, zoneShortName string, instanceID int, eventType RuntimeEventType, fields map[string]any, playerPosition *QuestActorPosition) (*QuestCapture, RewardSummary, error) {
	switch eventType {
	case RuntimeEventEnterZone, RuntimeEventTimer, RuntimeEventClickDoor, RuntimeEventCastOn, RuntimeEventProximitySay, RuntimeEventLoot, RuntimeEventFishSuccess, RuntimeEventForageSuccess, RuntimeEventInspect, RuntimeEventPopupResponse, RuntimeEventTaskStageComplete, RuntimeEventTaskAccepted:
	default:
		return nil, RewardSummary{}, fmt.Errorf("unsupported player quest event %q", eventType)
	}
	readContext, err := s.loadQuestReadContext(characterID, 0, zoneShortName, QuestTurnInContext{
		InstanceID: instanceID, SpawnInstanceID: PlayerRuntimeSpawnInstanceID,
	})
	if err != nil {
		return nil, RewardSummary{}, err
	}
	player, zoneID, globals, scriptState := readContext.Player, readContext.ZoneID, readContext.Globals, readContext.ScriptState
	playerProxy := *player.questPlayerProxy(characterID, nil)
	if playerPosition != nil {
		playerProxy.X, playerProxy.Y, playerProxy.Z, playerProxy.Heading = playerPosition.X, playerPosition.Y, playerPosition.Z, playerPosition.Heading
	}
	capture, err := s.executeEvent(string(eventType), "player", 0, zoneShortName, &LuaEvent{
		ReadTimer: s.questTimerReader(characterID, 0, zoneShortName, instanceID, PlayerRuntimeSpawnInstanceID),
		NPC:       &NPCProxy{}, Player: &playerProxy, Globals: globals, Fields: fields,
		GlobalSnapshot:  readContext.GlobalSnapshot,
		SpawnInstanceID: PlayerRuntimeSpawnInstanceID, ScriptState: scriptState, SelfIsPlayer: true,
		VisibleNPCTypeIDs:   visibleNPCTypeIDsFromRuntimeFields(fields),
		ResolveNPC:          npcResolverFromFields(fields),
		ReadNPCCombat:       npcCombatReaderFromFields(fields),
		ReadNPCGrid:         npcGridReaderFromFields(fields),
		ReadSpawnConditions: spawnConditionReaderFromFields(fields),
		ListNPCs:            npcEnumeratorFromFields(fields),
	})
	if err != nil {
		return nil, RewardSummary{}, err
	}
	if capture == nil {
		capture = NewQuestCapture()
	}
	stageQuestRuntimeState(capture, 0, PlayerRuntimeSpawnInstanceID)
	encounterCapture, err := s.executeRegisteredEncounterPlayerEvents(characterID, zoneShortName, instanceID, eventType, &playerProxy, globals, fields)
	if err != nil {
		return nil, RewardSummary{}, err
	}
	mergeQuestCapture(capture, encounterCapture)
	capture.GlobalSnapshot = readContext.GlobalSnapshot
	capture.Responses = formatQuestResponses(capture.Responses, player)
	rewards, err := s.persistQuestEventCapture(characterID, 0, zoneID, zoneShortName,
		QuestTurnInContext{InstanceID: instanceID, SpawnInstanceID: PlayerRuntimeSpawnInstanceID}, capture)
	if err != nil {
		return nil, RewardSummary{}, err
	}
	return capture, rewards, nil
}

func (s *Service) executeRegisteredEncounterNPCEvents(characterID uint32, npcID int32, spawnInstanceID int64, zoneShortName string, instanceID int, eventType RuntimeEventType, event *RuntimeEvent) (*QuestCapture, error) {
	encounters, err := s.loadedEncounterNamesForZone(zoneShortName)
	if err != nil || len(encounters) == 0 {
		return nil, err
	}
	scripts, err := s.loadRegisteredEncounterScripts(encounters, "register_npc_event")
	if err != nil {
		return nil, err
	}
	merged := NewQuestCapture()
	for _, script := range scripts {
		encounterName, source := script.name, script.source
		stateKey := encounterRuntimeStateKey(encounterName)
		state, err := s.loadRuntimeScriptState(characterID, 0, zoneShortName, instanceID, stateKey)
		if err != nil {
			return nil, err
		}
		luaEvent := &LuaEvent{
			NPC: &event.NPC, Player: &event.Player, Globals: event.Globals, Fields: event.Fields,
			ReadTimer:       s.questTimerReader(characterID, npcID, zoneShortName, instanceID, spawnInstanceID),
			SpawnInstanceID: spawnInstanceID, ScriptState: state,
			VisibleNPCTypeIDs:   visibleNPCTypeIDsFromRuntimeFields(event.Fields),
			ResolveNPC:          npcResolverFromFields(event.Fields),
			ReadNPCCombat:       npcCombatReaderFromFields(event.Fields),
			ReadNPCGrid:         npcGridReaderFromFields(event.Fields),
			ReadSpawnConditions: spawnConditionReaderFromFields(event.Fields),
			ListNPCs:            npcEnumeratorFromFields(event.Fields),
		}
		capture, err := s.bridge.ExecuteRegisteredNPCEventFromSource(source, eventType, npcID, luaEvent)
		if err != nil {
			return nil, fmt.Errorf("encounter %s registered %s handler failed: %w", encounterName, eventType, err)
		}
		if capture == nil || !captureHasEffects(capture) && len(capture.ScriptState) == 0 {
			continue
		}
		stageQuestRuntimeState(capture, 0, stateKey)
		mergeQuestCapture(merged, capture)
	}
	return merged, nil
}

func (s *Service) loadedEncounterNamesForZone(zoneShortName string) (map[string]bool, error) {
	source, err := s.loadScriptFromDB(zoneShortName, "script_init")
	if err != nil || strings.TrimSpace(source) == "" {
		return nil, err
	}
	capture, err := s.bridge.ExecuteEventFromSource(source, "__script_init__", &LuaEvent{NPC: &NPCProxy{}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}})
	if err != nil {
		return nil, err
	}
	loaded := map[string]bool{}
	for _, name := range capture.EncounterLoads {
		if strings.TrimSpace(name) != "" {
			loaded[name] = true
		}
	}
	return loaded, nil
}

func encounterRuntimeStateKey(encounterName string) int64 {
	hash := fnv.New32a()
	_, _ = hash.Write([]byte(encounterName))
	return -1000000 - int64(hash.Sum32())
}

func visibleNPCTypeIDsFromRuntimeFields(fields map[string]any) []int32 {
	if fields == nil {
		return nil
	}
	value, ok := fields["__visible_npc_type_ids"]
	if !ok {
		value = fields["visible_npc_type_ids"]
	}
	switch typed := value.(type) {
	case []int32:
		result := make([]int32, 0, len(typed))
		for _, id := range typed {
			if id > 0 {
				result = append(result, id)
			}
		}
		return result
	case []int:
		result := make([]int32, 0, len(typed))
		for _, id := range typed {
			if id > 0 && int64(id) <= math.MaxInt32 {
				result = append(result, int32(id))
			}
		}
		return result
	case []any:
		result := make([]int32, 0, len(typed))
		for _, entry := range typed {
			switch id := entry.(type) {
			case int:
				if id > 0 && int64(id) <= math.MaxInt32 {
					result = append(result, int32(id))
				}
			case int32:
				if id > 0 {
					result = append(result, id)
				}
			case float64:
				if id > 0 && id <= math.MaxInt32 && id == math.Trunc(id) {
					result = append(result, int32(id))
				}
			}
		}
		return result
	default:
		return nil
	}
}

func (s *Service) executeRegisteredEncounterPlayerEvents(characterID uint32, zoneShortName string, instanceID int, eventType RuntimeEventType, player *PlayerProxy, globals map[string]string, fields map[string]any) (*QuestCapture, error) {
	encounters, err := s.loadedEncounterNamesForZone(zoneShortName)
	if err != nil || len(encounters) == 0 {
		return nil, err
	}
	scripts, err := s.loadRegisteredEncounterScripts(encounters, "register_player_event")
	if err != nil {
		return nil, err
	}
	merged := NewQuestCapture()
	for _, script := range scripts {
		encounterName, source := script.name, script.source
		stateKey := encounterRuntimeStateKey("player:" + encounterName)
		state, err := s.loadRuntimeScriptState(characterID, 0, zoneShortName, instanceID, stateKey)
		if err != nil {
			return nil, err
		}
		luaEvent := &LuaEvent{
			NPC: &NPCProxy{}, Player: player, Globals: globals, Fields: fields,
			ReadTimer:       s.questTimerReader(characterID, 0, zoneShortName, instanceID, PlayerRuntimeSpawnInstanceID),
			SpawnInstanceID: PlayerRuntimeSpawnInstanceID, ScriptState: state, SelfIsPlayer: true,
			VisibleNPCTypeIDs:   visibleNPCTypeIDsFromRuntimeFields(fields),
			ResolveNPC:          npcResolverFromFields(fields),
			ReadNPCCombat:       npcCombatReaderFromFields(fields),
			ReadNPCGrid:         npcGridReaderFromFields(fields),
			ReadSpawnConditions: spawnConditionReaderFromFields(fields),
			ListNPCs:            npcEnumeratorFromFields(fields),
		}
		capture, err := s.bridge.ExecuteRegisteredPlayerEventFromSource(source, eventType, luaEvent)
		if err != nil {
			return nil, fmt.Errorf("encounter %s registered player %s handler failed: %w", encounterName, eventType, err)
		}
		if capture == nil || !captureHasEffects(capture) && len(capture.ScriptState) == 0 {
			continue
		}
		stageQuestRuntimeState(capture, 0, stateKey)
		mergeQuestCapture(merged, capture)
	}
	return merged, nil
}

func mergeQuestCapture(dst, src *QuestCapture) {
	if dst == nil || src == nil {
		return
	}
	if len(src.NPCSpeech) > 0 {
		if dst.NPCSpeech == nil {
			dst.NPCSpeech = make(map[int]NPCSpeech)
		}
		for index, speech := range src.NPCSpeech {
			dst.NPCSpeech[len(dst.Responses)+index] = speech
		}
	}
	dst.Responses = append(dst.Responses, src.Responses...)
	dst.SayLinks = append(dst.SayLinks, src.SayLinks...)
	dst.runtimeStateWrites = append(dst.runtimeStateWrites, src.runtimeStateWrites...)
	dst.Attacks = append(dst.Attacks, src.Attacks...)
	dst.SpawnConditions = append(dst.SpawnConditions, src.SpawnConditions...)
	for _, api := range src.DeferredAPIs {
		seen := false
		for _, existing := range dst.DeferredAPIs {
			if existing == api {
				seen = true
				break
			}
		}
		if !seen {
			dst.DeferredAPIs = append(dst.DeferredAPIs, api)
		}
	}
	dst.Exp += src.Exp
	dst.Factions = append(dst.Factions, src.Factions...)
	dst.Items = append(dst.Items, src.Items...)
	dst.Currency.Platinum += src.Currency.Platinum
	dst.Currency.Gold += src.Currency.Gold
	dst.Currency.Silver += src.Currency.Silver
	dst.Currency.Copper += src.Currency.Copper
	dst.Ding = dst.Ding || src.Ding
	spawnOffset := len(dst.Spawns)
	actorEffectOffset := len(dst.HateChanges) + len(dst.NPCMoves)
	for _, change := range src.HateChanges {
		change.Order += actorEffectOffset
		if change.Source.PendingSpawnIndex > 0 {
			change.Source.PendingSpawnIndex += spawnOffset
		}
		if change.Target.PendingSpawnIndex > 0 {
			change.Target.PendingSpawnIndex += spawnOffset
		}
		dst.HateChanges = append(dst.HateChanges, change)
	}
	for _, signal := range src.Signals {
		if signal.PendingSpawnIndex > 0 {
			signal.PendingSpawnIndex += spawnOffset
		}
		dst.Signals = append(dst.Signals, signal)
	}
	for key, value := range src.Globals {
		dst.Globals[key] = value
	}
	dst.Timers = append(dst.Timers, src.Timers...)
	dst.Tasks = append(dst.Tasks, src.Tasks...)
	dst.Popups = append(dst.Popups, src.Popups...)
	dst.Spells = append(dst.Spells, src.Spells...)
	for _, cast := range src.SpellCasts {
		if cast.Caster.PendingSpawnIndex > 0 {
			cast.Caster.PendingSpawnIndex += len(dst.Spawns)
		}
		if cast.Target.PendingSpawnIndex > 0 {
			cast.Target.PendingSpawnIndex += len(dst.Spawns)
		}
		dst.SpellCasts = append(dst.SpellCasts, cast)
	}
	dst.Spawns = append(dst.Spawns, src.Spawns...)
	for _, depop := range src.Depops {
		if depop.PendingSpawnIndex > 0 {
			depop.PendingSpawnIndex += spawnOffset
		}
		dst.Depops = append(dst.Depops, depop)
	}
	dst.PlayerMoves = append(dst.PlayerMoves, src.PlayerMoves...)
	for _, move := range src.NPCMoves {
		move.Order += actorEffectOffset
		if move.PendingSpawnIndex > 0 {
			move.PendingSpawnIndex += spawnOffset
		}
		dst.NPCMoves = append(dst.NPCMoves, move)
	}
	dst.Doors = append(dst.Doors, src.Doors...)
	dst.Binds = append(dst.Binds, src.Binds...)
	dst.GroundItems = append(dst.GroundItems, src.GroundItems...)
	dst.NPCAddedLoot = append(dst.NPCAddedLoot, src.NPCAddedLoot...)
	dst.ExternalNPCAddedLoot = append(dst.ExternalNPCAddedLoot, src.ExternalNPCAddedLoot...)
	dst.SkillUpdates = append(dst.SkillUpdates, src.SkillUpdates...)
	dst.HPEvents = append(dst.HPEvents, src.HPEvents...)
	if src.Proximity != nil {
		dst.Proximity = src.Proximity
	}
	if src.ProximitySayEnabled != nil {
		dst.ProximitySayEnabled = src.ProximitySayEnabled
	}
	for key, value := range src.ScriptState {
		dst.ScriptState[key] = value
	}
	dst.EncounterLoads = append(dst.EncounterLoads, src.EncounterLoads...)
}
