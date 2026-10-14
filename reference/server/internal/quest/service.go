package quest

import (
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"regexp"
	"strings"
	"sync"
	"time"

	"idlequest/internal/constants"
	"idlequest/internal/contentscope"
	"idlequest/internal/db/jetgen/eqgo/model"
	"idlequest/internal/db/jetgen/eqgo/table"

	. "github.com/go-jet/jet/v2/mysql"
	"github.com/go-jet/jet/v2/qrm"
	"github.com/go-jet/jet/v2/stmtcache"
)

type Service struct {
	// Configure once before serving events. World owns effect availability and
	// actor/session validation; the quest service owns the commit boundary.
	ValidateRuntimeCapture func(characterID uint32, npcID int32, zone string, runtime QuestTurnInContext, capture *QuestCapture) error
	PrepareRuntimeEffects  func(characterID uint32, npcID int32, zone string, runtime QuestTurnInContext, capture *QuestCapture) (*RuntimeEffectSettlement, error)
	db                     *stmtcache.DB
	bridge                 *LuaBridge
	handlerCacheMu         sync.RWMutex
	handlerCache           map[string]bool
}

var luaEventHandlerDefinitionPattern = regexp.MustCompile(`^(function\s+event_[A-Za-z0-9_]+\s*\(|event_[A-Za-z0-9_]+\s*=\s*function\s*\()`)

func NewService(db *stmtcache.DB, dataPath string) *Service {
	service := &Service{
		db:           db,
		bridge:       NewLuaBridge(dataPath),
		handlerCache: make(map[string]bool),
	}
	service.bridge.ModuleLoader = service.loadModuleFromDB
	return service
}

func (s *Service) HasNPCQuest(npcName string, zoneShortName string) bool {
	// Only check DB now, filesystem fallback disabled
	src, _ := s.loadScriptFromDB(zoneShortName, npcName)
	return src != ""
}

// HasNPCQuestInteraction uses the same identity resolution as dialogue and Give.
// Spawn/death/combat scripts belong to runtime actors, not the quest directory.
func (s *Service) HasNPCQuestInteraction(npcName string, npcID int32, zone string) bool {
	source, err := s.loadScriptFromDBForNPC(zone, npcName, npcID)
	return err == nil && scriptHasQuestInteraction(source)
}

func scriptHasQuestInteraction(source string) bool {
	return scriptDefinesLuaHandler(source, "event_say") || scriptDefinesLuaHandler(source, "event_trade")
}

// GetQuestNPCNames includes absent hand-in NPCs, but excludes runtime-only actors.
func (s *Service) GetQuestNPCNames(zoneShortName string) []string {
	rows, err := s.db.Query("SELECT DISTINCT name, lua_content FROM quests WHERE zone = ? AND enabled = 1 AND lua_content IS NOT NULL AND lua_content != ''", zoneShortName)
	if err != nil {
		return nil
	}
	defer rows.Close()
	var names []string
	for rows.Next() {
		var name, source string
		if err := rows.Scan(&name, &source); err == nil && !contentscope.ExcludesQuest(zoneShortName, name) && scriptHasQuestInteraction(source) {
			names = append(names, name)
		}
	}
	return names
}

// loadScriptFromDB retrieves the LUA script text for an NPC from the quests table.
func (s *Service) loadScriptFromDB(zoneShortName, npcName string) (string, error) {
	return s.loadScriptFromDBCandidates(zoneShortName, questScriptNameCandidates(npcName))
}

func (s *Service) loadScriptFromDBForNPC(zoneShortName, npcName string, npcID int32) (string, error) {
	if contentscope.ExcludesNPC(npcID, npcName) {
		return "", nil
	}
	return s.loadScriptFromDBCandidates(zoneShortName, questScriptNameCandidatesForNPC(npcName, npcID))
}

func (s *Service) loadScriptFromDBCandidates(zoneShortName string, candidateNames []string) (string, error) {
	for _, name := range candidateNames {
		if contentscope.ExcludesQuest(zoneShortName, name) {
			return "", nil
		}
	}
	// The schema permits NULL source for catalog rows without an implemented
	// script (including deliberately omitted later-era content). Treat it like
	// an empty source, without swallowing actual SQL/scan or Lua errors.
	var source sql.NullString
	// Using raw SQL because 'enabled' column might not be in the Jet-generated models yet
	var err error
	for _, candidateName := range candidateNames {
		err = s.db.QueryRow("SELECT lua_content FROM quests WHERE name = ? AND zone = ? AND enabled = 1 LIMIT 1", candidateName, zoneShortName).Scan(&source)
		if err == nil {
			break
		}
		if !errors.Is(err, sql.ErrNoRows) {
			return "", fmt.Errorf("load quest script %s/%s: %w", zoneShortName, candidateName, err)
		}
	}

	if err != nil {
		return "", nil // All candidates were genuinely absent.
	}

	content := source.String
	if !source.Valid || content == "" {
		return "", nil
	}

	// If it is an actual Perl script, ignore it so it doesn't fail the Lua
	// parser. Some converted Lua scripts retain Perl text in comments such as
	// "end -- sub EVENT_ITEM"; those must still run.
	if questScriptLooksLikePerl(content) {
		return "", nil
	}
	if IsQuestScriptExcludedFromIdleQuest(candidateNames[0], content) {
		return "", nil
	}

	return content, nil
}

func questScriptNameCandidates(npcName string) []string {
	candidates := []string{npcName}
	legacyFilenameName := strings.ReplaceAll(npcName, "`", "-")
	if legacyFilenameName != npcName {
		candidates = append(candidates, legacyFilenameName)
	}
	if trimmedDuplicate := trimDuplicatedFinalLetter(npcName); trimmedDuplicate != "" && trimmedDuplicate != npcName {
		candidates = append(candidates, trimmedDuplicate)
		legacyTrimmedDuplicate := strings.ReplaceAll(trimmedDuplicate, "`", "-")
		if legacyTrimmedDuplicate != trimmedDuplicate {
			candidates = append(candidates, legacyTrimmedDuplicate)
		}
	}
	return candidates
}

func trimDuplicatedFinalLetter(name string) string {
	runes := []rune(strings.TrimSpace(name))
	if len(runes) < 2 {
		return ""
	}
	last := runes[len(runes)-1]
	previous := runes[len(runes)-2]
	if last != previous || !((last >= 'A' && last <= 'Z') || (last >= 'a' && last <= 'z')) {
		return ""
	}
	return string(runes[:len(runes)-1])
}

func questScriptNameCandidatesForNPC(npcName string, npcID int32) []string {
	candidates := questScriptNameCandidates(npcName)
	if npcID <= 0 {
		return candidates
	}
	idCandidate := fmt.Sprintf("%d", npcID)
	for _, candidate := range candidates {
		if candidate == idCandidate {
			return candidates
		}
	}
	return append(candidates, idCandidate)
}

func questScriptLooksLikePerl(source string) bool {
	if scriptDefinesAnyLuaEventHandler(source) {
		return false
	}
	for _, line := range strings.Split(strings.ReplaceAll(source, "\r\n", "\n"), "\n") {
		trimmed := strings.TrimSpace(line)
		if trimmed == "" || strings.HasPrefix(trimmed, "--") || strings.HasPrefix(trimmed, "#") {
			continue
		}
		if strings.HasPrefix(trimmed, "sub EVENT_") ||
			strings.HasPrefix(trimmed, "quest::") ||
			strings.HasPrefix(trimmed, "my $") ||
			strings.HasPrefix(trimmed, "$") {
			return true
		}
		return false
	}
	return false
}

func scriptDefinesAnyLuaEventHandler(source string) bool {
	normalized := strings.ReplaceAll(source, "\r\n", "\n")
	for _, line := range strings.Split(normalized, "\n") {
		line = strings.TrimSpace(strings.SplitN(line, "--", 2)[0])
		if luaEventHandlerDefinitionPattern.MatchString(line) {
			return true
		}
	}
	return false
}

func (s *Service) loadModuleFromDB(moduleName string) (string, bool, error) {
	if strings.TrimSpace(moduleName) == "" {
		return "", false, nil
	}
	var content string
	err := s.db.QueryRow("SELECT lua_content FROM quest_lua_modules WHERE module_name = ? AND enabled = 1 LIMIT 1", moduleName).Scan(&content)
	if errors.Is(err, sql.ErrNoRows) {
		return "", false, nil
	}
	if err != nil {
		return "", false, fmt.Errorf("load quest module %s: %w", moduleName, err)
	}
	return content, content != "", nil
}

// GetNPCQuestInfo returns the initial dialogue and options for an NPC
func (s *Service) GetNPCQuestInfo(characterID uint32, npcID int32, zoneShortName string) (*QuestNPCInfo, error) {
	return s.GetNPCQuestInfoWithContext(characterID, npcID, zoneShortName, QuestTurnInContext{})
}

func (s *Service) GetNPCQuestInfoWithContext(characterID uint32, npcID int32, zoneShortName string, runtimeContext QuestTurnInContext) (*QuestNPCInfo, error) {
	// 1. Get NPC info from DB
	var npcName string
	var npcRace, npcClass, npcGender, npcFaction, npcHP int32
	err := s.db.QueryRow("SELECT name, race, class, gender, npc_faction_id, hp FROM npc_types WHERE id = ?", npcID).Scan(
		&npcName, &npcRace, &npcClass, &npcGender, &npcFaction, &npcHP,
	)
	if err != nil {
		return nil, err
	}
	cleanName := strings.ReplaceAll(npcName, "_", " ")
	scriptSrc, err := s.loadScriptFromDBForNPC(zoneShortName, npcName, npcID)
	if err != nil {
		return nil, err
	}

	readContext, err := s.loadQuestReadContext(characterID, npcID, zoneShortName, runtimeContext)
	if err != nil {
		return nil, err
	}
	player, zoneID, globals, scriptState := readContext.Player, readContext.ZoneID, readContext.Globals, readContext.ScriptState

	event := &LuaEvent{
		NPC:                 &NPCProxy{ID: npcID, Name: cleanName, Race: uint16(npcRace), Class: uint8(npcClass), Gender: uint8(npcGender), PrimaryFaction: npcFaction, HP: int64(npcHP), MaxHP: int64(npcHP)},
		Player:              player.questPlayerProxy(characterID, nil),
		Message:             "hail",
		NPCVitals:           runtimeContext.NPCVitals,
		Globals:             globals,
		GlobalSnapshot:      readContext.GlobalSnapshot,
		ScriptState:         scriptState,
		SpawnInstanceID:     runtimeContext.SpawnInstanceID,
		InstanceID:          runtimeContext.InstanceID,
		VisibleNPCTypeIDs:   runtimeContext.VisibleNPCTypeIDs,
		ResolveNPC:          runtimeContext.ResolveNPC,
		ReadNPCCombat:       runtimeContext.ReadNPCCombat,
		ReadNPCGrid:         runtimeContext.ReadNPCGrid,
		ReadSpawnConditions: runtimeContext.ReadSpawnConditions,
		ListNPCs:            runtimeContext.ListNPCs,
		ReadTimer:           s.questTimerReader(characterID, npcID, zoneShortName, runtimeContext.InstanceID, runtimeContext.SpawnInstanceID),
	}

	// Use the same source for execution and discovery, loaded before effects.
	applyQuestInteractionPositions(event, runtimeContext)
	capture, err := s.executeLoadedEvent("say", npcName, zoneShortName, scriptSrc, event)
	if err != nil {
		return nil, err
	}
	if capture == nil {
		return &QuestNPCInfo{
			NPCName:     cleanName,
			HasDialogue: false,
			Greeting:    "The NPC has nothing to say.",
		}, nil
	}

	rewardPreview := rewardSummaryFromCapture(capture)
	if runtimeContext.validateRewards != nil {
		if err := runtimeContext.validateRewards(nil, rewardPreview); err != nil {
			return &QuestNPCInfo{NPCName: cleanName, Greeting: strings.Join(formatQuestResponses(capture.Responses, player), "\n"), Error: err.Error()}, nil
		}
	}
	rewards := s.describeQuestCaptureRewards(capture)
	if !runtimeContext.deferPersistence {
		rewards, err = s.persistQuestEventCapture(characterID, npcID, zoneID, zoneShortName, runtimeContext, capture)
		if err != nil {
			return nil, fmt.Errorf("persist quest event: %w", err)
		}
	}

	greeting := strings.Join(formatQuestResponses(capture.Responses, player), "\n")
	responseGreeting := greeting
	if greeting == "" {
		greeting = "The NPC remains silent."
	}

	// 3. Extract keywords (bracketed text) from the response
	options := s.captureDialogueOptions(greeting, capture)

	// 4. Probe reachable branches using the real Lua conditions and isolated state.
	if scriptSrc != "" {
		event.ScriptState = capture.ScriptState
		applyDialogueGlobals(event, capture)
		branchOptions := s.discoverDialogueOptions(scriptSrc, event)
		options = mergeDialogueOptions(options, branchOptions)
	}

	return &QuestNPCInfo{
		NPCName:     cleanName,
		HasDialogue: responseGreeting != "" || len(options) > 0,
		// A trade-only script can accept items without answering a hail.
		// Discover this from the same resolved source used for execution.
		HasTurnIn:        scriptDefinesLuaHandler(scriptSrc, "event_trade"),
		Greeting:         greeting,
		AvailableOptions: options,
		SystemMessages:   rewards.Factions,
		Rewards:          &rewards,
		RuntimeCapture:   capture,
	}, nil
}

// executeEvent tries DB script first. Filesystem fallback has been disabled.
// Returns nil capture if no script found.
func (s *Service) executeEvent(eventType, npcName string, npcID int32, zoneShortName string, event *LuaEvent) (*QuestCapture, error) {
	dbScript, err := s.loadScriptFromDBForNPC(zoneShortName, npcName, npcID)
	if err != nil {
		return nil, err
	}
	return s.executeLoadedEvent(eventType, npcName, zoneShortName, dbScript, event)
}

func (s *Service) executeLoadedEvent(eventType, npcName, zoneShortName, source string, event *LuaEvent) (*QuestCapture, error) {
	if source == "" {
		return nil, nil
	}
	event.ReadWorldTimer = s.questWorldTimerReader(event.NPC.ID, zoneShortName, event.InstanceID, event.SpawnInstanceID)
	handler := "event_" + strings.TrimPrefix(strings.ToLower(eventType), "event_")
	capture, err := s.bridge.ExecuteEventFromSource(source, handler, event)
	if err != nil {
		return nil, fmt.Errorf("execute quest %s/%s %s: %w", zoneShortName, npcName, handler, err)
	}
	return capture, nil
}

// HasRuntimeEvent lets the world avoid creating per-character runtime state for
// the many zone NPCs whose scripts do not define the event being dispatched.
func (s *Service) HasRuntimeEvent(npcID int32, zoneShortName string, eventType RuntimeEventType) (bool, error) {
	cacheKey := fmt.Sprintf("%s:%d:%s", zoneShortName, npcID, eventType)
	s.handlerCacheMu.RLock()
	known, cached := s.handlerCache[cacheKey]
	s.handlerCacheMu.RUnlock()
	if cached {
		return known, nil
	}
	var npcName string
	if err := s.db.QueryRow("SELECT name FROM npc_types WHERE id = ?", npcID).Scan(&npcName); err != nil {
		return false, err
	}
	source, err := s.loadScriptFromDBForNPC(zoneShortName, npcName, npcID)
	if err != nil || source == "" {
		if err != nil {
			return false, err
		}
		result, encounterErr := s.hasEncounterRegisteredNPCEvent(zoneShortName, npcID, eventType)
		if encounterErr != nil {
			return false, encounterErr
		}
		s.handlerCacheMu.Lock()
		s.handlerCache[cacheKey] = result
		s.handlerCacheMu.Unlock()
		return result, encounterErr
	}
	handler := "event_" + strings.TrimPrefix(strings.ToLower(string(eventType)), "event_")
	result := scriptDefinesLuaHandler(source, handler)
	if !result {
		result, err = s.hasEncounterRegisteredNPCEvent(zoneShortName, npcID, eventType)
		if err != nil {
			return false, err
		}
	}
	s.handlerCacheMu.Lock()
	s.handlerCache[cacheKey] = result
	s.handlerCacheMu.Unlock()
	return result, nil
}

// PrimeRuntimeEventCache resolves event metadata for an entire zone population
// in a handful of queries. Zone loading used to call HasRuntimeEvent separately
// for every NPC/event pair, producing hundreds of sequential queries before the
// server could send the spawn response.
func (s *Service) PrimeRuntimeEventCache(zoneShortName string, npcNames map[int32]string, eventTypes []RuntimeEventType) error {
	if len(npcNames) == 0 || len(eventTypes) == 0 {
		return nil
	}

	rows, err := s.db.Query(`SELECT name, lua_content FROM quests WHERE zone = ? AND enabled = 1 AND lua_content IS NOT NULL AND lua_content != ''`, zoneShortName)
	if err != nil {
		return err
	}
	sources := make(map[string]string)
	for rows.Next() {
		var name, source string
		if err := rows.Scan(&name, &source); err != nil {
			rows.Close()
			return err
		}
		sources[strings.ToLower(name)] = source
	}
	if err := rows.Err(); err != nil {
		rows.Close()
		return err
	}
	if err := rows.Close(); err != nil {
		return err
	}

	registered, err := s.registeredEncounterNPCEvents(zoneShortName)
	if err != nil {
		return err
	}

	primed := make(map[string]bool, len(npcNames)*len(eventTypes))
	for npcID, npcName := range npcNames {
		var source string
		for _, candidate := range questScriptNameCandidatesForNPC(npcName, npcID) {
			if candidateSource := sources[strings.ToLower(candidate)]; candidateSource != "" {
				source = candidateSource
				break
			}
		}
		if contentscope.ExcludesNPC(npcID, npcName) || contentscope.ExcludesQuest(zoneShortName, npcName) || questScriptLooksLikePerl(source) || IsQuestScriptExcludedFromIdleQuest(npcName, source) {
			source = ""
		}
		for _, eventType := range eventTypes {
			handler := "event_" + strings.TrimPrefix(strings.ToLower(string(eventType)), "event_")
			hasEvent := source != "" && scriptDefinesLuaHandler(source, handler)
			if !hasEvent {
				hasEvent = registered[npcID][eventType]
			}
			primed[fmt.Sprintf("%s:%d:%s", zoneShortName, npcID, eventType)] = hasEvent
		}
	}

	s.handlerCacheMu.Lock()
	for key, value := range primed {
		s.handlerCache[key] = value
	}
	s.handlerCacheMu.Unlock()
	return nil
}

func (s *Service) registeredEncounterNPCEvents(zoneShortName string) (map[int32]map[RuntimeEventType]bool, error) {
	result := make(map[int32]map[RuntimeEventType]bool)
	encounters, err := s.loadedEncounterNamesForZone(zoneShortName)
	if err != nil || len(encounters) == 0 {
		return result, err
	}
	rows, err := s.db.Query(`SELECT name, lua_content FROM quests WHERE zone='encounters' AND enabled=1 AND lua_content IS NOT NULL AND lua_content != '' AND lua_content LIKE '%register_npc_event%'`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	for rows.Next() {
		var encounterName, source string
		if err := rows.Scan(&encounterName, &source); err != nil {
			return nil, err
		}
		if !encounters[encounterName] {
			continue
		}
		capture, err := s.bridge.ExecuteEventFromSource(source, "event_encounter_load", &LuaEvent{NPC: &NPCProxy{}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}})
		if err != nil {
			return nil, err
		}
		if capture == nil {
			continue
		}
		for _, registration := range capture.Registrations {
			if registration.Scope != "npc" || registration.NPCTypeID <= 0 {
				continue
			}
			if result[registration.NPCTypeID] == nil {
				result[registration.NPCTypeID] = make(map[RuntimeEventType]bool)
			}
			result[registration.NPCTypeID][RuntimeEventType(registration.Event)] = true
		}
	}
	return result, rows.Err()
}

func (s *Service) hasEncounterRegisteredNPCEvent(zoneShortName string, npcID int32, eventType RuntimeEventType) (bool, error) {
	encounters, err := s.loadedEncounterNamesForZone(zoneShortName)
	if err != nil || len(encounters) == 0 {
		return false, err
	}
	rows, err := s.db.Query(`SELECT name, lua_content FROM quests WHERE zone='encounters' AND enabled=1 AND lua_content IS NOT NULL AND lua_content != '' AND lua_content LIKE '%register_npc_event%'`)
	if err != nil {
		return false, err
	}
	defer rows.Close()
	for rows.Next() {
		var encounterName, source string
		if err := rows.Scan(&encounterName, &source); err != nil {
			return false, err
		}
		if !encounters[encounterName] {
			continue
		}
		capture, err := s.bridge.ExecuteEventFromSource(source, "event_encounter_load", &LuaEvent{NPC: &NPCProxy{ID: npcID}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}})
		if err != nil {
			return false, err
		}
		for _, registration := range capture.Registrations {
			if registration.Scope == "npc" && registration.NPCTypeID == npcID && registration.Event == string(eventType) {
				return true, nil
			}
		}
	}
	return false, rows.Err()
}

func (s *Service) HasPlayerRuntimeEvent(zoneShortName string, eventType RuntimeEventType) (bool, error) {
	cacheKey := fmt.Sprintf("%s:player:%s", zoneShortName, eventType)
	s.handlerCacheMu.RLock()
	known, cached := s.handlerCache[cacheKey]
	s.handlerCacheMu.RUnlock()
	if cached {
		return known, nil
	}
	source, err := s.loadScriptFromDB(zoneShortName, "player")
	if err != nil || source == "" {
		return false, err
	}
	handler := "event_" + strings.TrimPrefix(strings.ToLower(string(eventType)), "event_")
	result := scriptDefinesLuaHandler(source, handler)
	s.handlerCacheMu.Lock()
	s.handlerCache[cacheKey] = result
	s.handlerCacheMu.Unlock()
	return result, nil
}

func scriptDefinesLuaHandler(source, handler string) bool {
	normalized := strings.ReplaceAll(source, "\r\n", "\n")
	for _, line := range strings.Split(normalized, "\n") {
		line = strings.TrimSpace(strings.SplitN(line, "--", 2)[0])
		if strings.HasPrefix(line, "function "+handler+"(") ||
			strings.HasPrefix(line, "function "+handler+" (") ||
			strings.HasPrefix(line, handler+" = function(") ||
			strings.HasPrefix(line, handler+"=function(") {
			return true
		}
	}
	return false
}

// ProcessKeyword handles a player clicking a keyword response
func (s *Service) ProcessKeyword(characterID uint32, npcID int32, zoneShortName string, keyword string) (*QuestNPCInfo, error) {
	return s.ProcessKeywordWithContext(characterID, npcID, zoneShortName, keyword, QuestTurnInContext{})
}

func (s *Service) ProcessKeywordWithContext(characterID uint32, npcID int32, zoneShortName string, keyword string, runtimeContext QuestTurnInContext) (*QuestNPCInfo, error) {
	// 1. Get NPC info from DB
	var npcName string
	var npcRace, npcClass, npcGender, npcFaction, npcHP int32
	err := s.db.QueryRow("SELECT name, race, class, gender, npc_faction_id, hp FROM npc_types WHERE id = ?", npcID).Scan(
		&npcName, &npcRace, &npcClass, &npcGender, &npcFaction, &npcHP,
	)
	if err != nil {
		return nil, err
	}
	cleanName := strings.ReplaceAll(npcName, "_", " ")
	scriptSrc, err := s.loadScriptFromDBForNPC(zoneShortName, npcName, npcID)
	if err != nil {
		return nil, err
	}

	readContext, err := s.loadQuestReadContext(characterID, npcID, zoneShortName, runtimeContext)
	if err != nil {
		return nil, err
	}
	player, zoneID, globals, scriptState := readContext.Player, readContext.ZoneID, readContext.Globals, readContext.ScriptState

	event := &LuaEvent{
		NPC:                 &NPCProxy{ID: npcID, Name: cleanName, Race: uint16(npcRace), Class: uint8(npcClass), Gender: uint8(npcGender), PrimaryFaction: npcFaction, HP: int64(npcHP), MaxHP: int64(npcHP)},
		Player:              player.questPlayerProxy(characterID, nil),
		Message:             keyword,
		NPCVitals:           runtimeContext.NPCVitals,
		Globals:             globals,
		GlobalSnapshot:      readContext.GlobalSnapshot,
		ScriptState:         scriptState,
		SpawnInstanceID:     runtimeContext.SpawnInstanceID,
		InstanceID:          runtimeContext.InstanceID,
		VisibleNPCTypeIDs:   runtimeContext.VisibleNPCTypeIDs,
		ResolveNPC:          runtimeContext.ResolveNPC,
		ReadNPCCombat:       runtimeContext.ReadNPCCombat,
		ReadNPCGrid:         runtimeContext.ReadNPCGrid,
		ReadSpawnConditions: runtimeContext.ReadSpawnConditions,
		ListNPCs:            runtimeContext.ListNPCs,
		ReadTimer:           s.questTimerReader(characterID, npcID, zoneShortName, runtimeContext.InstanceID, runtimeContext.SpawnInstanceID),
	}

	applyQuestInteractionPositions(event, runtimeContext)
	branchOptions := s.discoverDialogueOptions(scriptSrc, event)
	event.Message = resolveDialogueKeyword(keyword, branchOptions)
	capture, err := s.executeLoadedEvent("say", npcName, zoneShortName, scriptSrc, event)
	if err != nil {
		return nil, err
	}
	if capture == nil {
		return unansweredQuestDialogue(cleanName, branchOptions, scriptDefinesLuaHandler(scriptSrc, "event_trade")), nil
	}

	rewardPreview := rewardSummaryFromCapture(capture)
	if runtimeContext.validateRewards != nil {
		if err := runtimeContext.validateRewards(nil, rewardPreview); err != nil {
			return &QuestNPCInfo{NPCName: cleanName, Greeting: strings.Join(formatQuestResponses(capture.Responses, player), "\n"), Error: err.Error()}, nil
		}
	}
	rewards, err := s.persistQuestEventCapture(characterID, npcID, zoneID, zoneShortName, runtimeContext, capture)
	if err != nil {
		return nil, fmt.Errorf("persist quest event: %w", err)
	}

	greeting := strings.Join(formatQuestResponses(capture.Responses, player), "\n")
	hasSideEffects := captureHasEffects(capture)

	if greeting == "" && !hasSideEffects {
		return unansweredQuestDialogue(cleanName, branchOptions, scriptDefinesLuaHandler(scriptSrc, "event_trade")), nil
	}

	options := s.captureDialogueOptions(greeting, capture)

	if scriptSrc != "" {
		event.ScriptState = capture.ScriptState
		applyDialogueGlobals(event, capture)
		branchOptions = s.discoverDialogueOptions(scriptSrc, event)
		options = mergeDialogueOptions(options, branchOptions)
	}

	return &QuestNPCInfo{
		NPCName:          cleanName,
		HasDialogue:      greeting != "" || len(options) > 0,
		HasTurnIn:        scriptDefinesLuaHandler(scriptSrc, "event_trade"),
		Greeting:         greeting,
		AvailableOptions: options,
		SystemMessages:   rewards.Factions,
		Rewards:          &rewards,
		RuntimeCapture:   capture,
	}, nil
}

func unansweredQuestDialogue(npcName string, options []DialogueOption, hasTurnIn bool) *QuestNPCInfo {
	return &QuestNPCInfo{
		NPCName:          npcName,
		HasDialogue:      len(options) > 0,
		HasTurnIn:        hasTurnIn,
		Greeting:         npcName + " does not respond to that.",
		AvailableOptions: options,
	}
}

// resolveDialogueKeyword maps shorthand shown inside brackets to the one
// unambiguous message branch that actually exists in the script. For example,
// a displayed "mail" option can safely invoke a "what mail" branch. Ambiguous
// prompts such as "house" remain unchanged and the UI offers the real branches.
func resolveDialogueKeyword(keyword string, branches []DialogueOption) string {
	trimmed := strings.TrimSpace(keyword)
	lower := strings.ToLower(trimmed)
	if lower == "" {
		return trimmed
	}
	for _, branch := range branches {
		if strings.EqualFold(strings.TrimSpace(branch.Keyword), trimmed) {
			return branch.Keyword
		}
	}
	var candidate string
	for _, branch := range branches {
		branchLower := strings.ToLower(strings.TrimSpace(branch.Keyword))
		if !dialogueContainsPhrase(branchLower, lower) {
			continue
		}
		if candidate != "" {
			return trimmed
		}
		candidate = branch.Keyword
	}
	if candidate != "" {
		return candidate
	}
	return trimmed
}

func (s *Service) extractKeywords(text string) []DialogueOption {
	var options []DialogueOption
	re := regexp.MustCompile(`\[([^\]]+)\]`)
	matches := re.FindAllStringSubmatch(text, -1)
	seen := make(map[string]bool)

	for _, m := range matches {
		keyword := strings.TrimSpace(m[1])
		if keyword == "" || strings.ContainsAny(keyword, "[]") {
			continue
		}
		if !seen[strings.ToLower(keyword)] {
			options = append(options, DialogueOption{
				Text:    keyword,
				Keyword: keyword,
			})
			seen[strings.ToLower(keyword)] = true
		}
	}
	return options
}

func (s *Service) discoverDialogueOptions(source string, event *LuaEvent) []DialogueOption {
	options, err := s.bridge.DiscoverDialogueOptions(source, event)
	if err != nil {
		log.Printf("[Quest] dialogue discovery for NPC %d: %v", event.NPC.ID, err)
	}
	return options
}

// mergeDialogueOptions maps bracket text to an unambiguous real script trigger. Ambiguous shorthand is omitted and
// replaced by the actual branches so every rendered button is actionable.
func mergeDialogueOptions(primary, secondary []DialogueOption) []DialogueOption {
	seen := make(map[string]bool)
	var merged []DialogueOption
	for _, option := range primary {
		resolved := resolveDialogueKeyword(option.Keyword, secondary)
		if strings.EqualFold(strings.TrimSpace(resolved), strings.TrimSpace(option.Keyword)) {
			matches := 0
			for _, branch := range secondary {
				if dialogueContainsPhrase(branch.Keyword, option.Keyword) {
					matches++
				}
			}
			if matches > 1 {
				continue
			}
		}
		lower := strings.ToLower(strings.TrimSpace(resolved))
		if lower == "" || seen[lower] {
			continue
		}
		seen[lower] = true
		merged = append(merged, DialogueOption{Text: option.Text, Keyword: resolved})
	}
	for _, option := range secondary {
		lower := strings.ToLower(strings.TrimSpace(option.Keyword))
		if lower == "" || seen[lower] {
			continue
		}
		seen[lower] = true
		merged = append(merged, option)
	}
	return merged
}

// mergeKeywords combines bracket-extracted keywords with script-branch keywords,
// deduplicating by lowercase keyword.
func mergeKeywords(primary, secondary []DialogueOption) []DialogueOption {
	seen := make(map[string]bool)
	var merged []DialogueOption
	for _, opt := range primary {
		lower := strings.ToLower(opt.Keyword)
		if !seen[lower] {
			seen[lower] = true
			merged = append(merged, opt)
		}
	}
	for _, opt := range secondary {
		lower := strings.ToLower(opt.Keyword)
		if !seen[lower] {
			seen[lower] = true
			merged = append(merged, opt)
		}
	}
	return merged
}

type PlayerInfo struct {
	Name       string
	LastName   string
	Class      uint8
	ClassName  string
	Race       uint16
	RaceName   string
	Level      uint32
	Gender     uint8
	GenderName string
	Deity      uint32
	DeityName  string
	Tasks      map[int]bool
	Activities map[string]bool
	Inventory  map[int]int
	Factions   map[int]int
}

func formatQuestResponses(responses []string, player PlayerInfo) []string {
	if len(responses) == 0 {
		return responses
	}

	formatted := make([]string, len(responses))
	for i, response := range responses {
		formatted[i] = formatQuestText(response, player)
	}
	return formatted
}

func formatQuestText(text string, player PlayerInfo) string {
	replacements := []struct {
		keys  []string
		value string
	}{
		{[]string{"$name", "${name}"}, player.Name},
		{[]string{"$surname", "${surname}", "$lastname", "${lastname}"}, player.LastName},
		{[]string{"$class", "${class}"}, player.ClassName},
		{[]string{"$race", "${race}"}, player.RaceName},
		{[]string{"$level", "${level}"}, fmt.Sprintf("%d", player.Level)},
		{[]string{"$gender", "${gender}"}, player.GenderName},
		{[]string{"$deity", "${deity}"}, player.DeityName},
	}

	for _, replacement := range replacements {
		if replacement.value == "" {
			continue
		}
		for _, key := range replacement.keys {
			text = strings.ReplaceAll(text, key, replacement.value)
		}
	}

	return text
}

func (s *Service) getPlayerInfo(characterID uint32) (PlayerInfo, error) {
	var row model.CharacterData
	err := SELECT(
		table.CharacterData.Name,
		table.CharacterData.LastName,
		table.CharacterData.Class,
		table.CharacterData.Race,
		table.CharacterData.Level,
		table.CharacterData.Gender,
		table.CharacterData.Deity,
	).
		FROM(table.CharacterData).
		WHERE(table.CharacterData.ID.EQ(Int32(int32(characterID)))).
		Query(s.db, &row)

	if err != nil {
		return PlayerInfo{}, err
	}

	// Query tasks
	tasks := make(map[int]bool)
	var taskRows []model.CharacterTasks
	err = SELECT(table.CharacterTasks.Taskid).
		FROM(table.CharacterTasks).
		WHERE(table.CharacterTasks.Charid.EQ(Int32(int32(characterID)))).
		Query(s.db, &taskRows)
	if err != nil && !errors.Is(err, qrm.ErrNoRows) {
		return PlayerInfo{}, fmt.Errorf("load quest tasks: %w", err)
	}

	for _, t := range taskRows {
		tasks[int(t.Taskid)] = true
	}

	activities := make(map[string]bool)
	rows, err := s.db.Query(`
SELECT ca.taskid, ca.activityid
FROM character_activities ca
INNER JOIN character_tasks ct
  ON ct.charid = ca.charid AND ct.taskid = ca.taskid
WHERE ca.charid = ?
  AND COALESCE(ca.completed, 0) = 0`, characterID)
	if err != nil {
		return PlayerInfo{}, fmt.Errorf("load quest activities: %w", err)
	}
	defer rows.Close()
	for rows.Next() {
		var taskID, activityID int
		if err := rows.Scan(&taskID, &activityID); err != nil {
			return PlayerInfo{}, fmt.Errorf("read quest activity: %w", err)
		}
		activities[taskActivityKey(taskID, activityID)] = true
	}
	if err := rows.Err(); err != nil {
		return PlayerInfo{}, fmt.Errorf("read quest activities: %w", err)
	}

	inventory := make(map[int]int)
	itemRows, err := s.db.Query(`
SELECT ii.item_id, ii.quantity
FROM character_inventory ci
INNER JOIN item_instances ii ON ii.id = ci.item_instance_id
WHERE ci.character_id = ?`, characterID)
	if err != nil {
		return PlayerInfo{}, fmt.Errorf("load quest inventory: %w", err)
	}
	defer itemRows.Close()
	for itemRows.Next() {
		var itemID, quantity int
		if err := itemRows.Scan(&itemID, &quantity); err != nil {
			return PlayerInfo{}, fmt.Errorf("read quest inventory item: %w", err)
		}
		// Trade offers are expanded into individual items. Counting rows would
		// hide a remaining stack after just one of its items was offered.
		inventory[itemID] += quantity
	}
	if err := itemRows.Err(); err != nil {
		return PlayerInfo{}, fmt.Errorf("read quest inventory: %w", err)
	}

	factions := make(map[int]int)
	factionRows, err := s.db.Query(`
SELECT fl.id, fl.base + COALESCE(fv.current_value, 0) AS value
FROM faction_list fl
LEFT JOIN faction_values fv
  ON fv.faction_id = fl.id AND fv.char_id = ?`, characterID)
	if err != nil {
		return PlayerInfo{}, fmt.Errorf("load quest factions: %w", err)
	}
	defer factionRows.Close()
	for factionRows.Next() {
		var factionID, value int
		if err := factionRows.Scan(&factionID, &value); err != nil {
			return PlayerInfo{}, fmt.Errorf("read quest faction: %w", err)
		}
		factions[factionID] = value
	}
	if err := factionRows.Err(); err != nil {
		return PlayerInfo{}, fmt.Errorf("read quest factions: %w", err)
	}

	// We'll use a simple map for now, or query constants if available
	return PlayerInfo{
		Name:       row.Name,
		LastName:   row.LastName,
		Class:      uint8(row.Class),
		ClassName:  s.getClassName(uint8(row.Class)),
		Race:       row.Race,
		RaceName:   s.getRaceName(row.Race),
		Level:      row.Level,
		Gender:     uint8(row.Gender),
		GenderName: s.getGenderName(uint8(row.Gender)),
		Deity:      row.Deity,
		DeityName:  s.getDeityName(row.Deity),
		Tasks:      tasks,
		Activities: activities,
		Inventory:  inventory,
		Factions:   factions,
	}, nil
}

func (s *Service) getClassName(classID uint8) string {
	classes := map[uint8]string{
		1: "Warrior", 2: "Cleric", 3: "Paladin", 4: "Ranger", 5: "Shadow Knight",
		6: "Druid", 7: "Monk", 8: "Bard", 9: "Rogue", 10: "Shaman",
		11: "Necromancer", 12: "Wizard", 13: "Magician", 14: "Enchanter",
		15: "Beastlord", 16: "Berserker",
	}
	return classes[classID]
}

func (s *Service) getRaceName(raceID uint16) string {
	races := map[uint16]string{
		1: "Human", 2: "Barbarian", 3: "Erudite", 4: "Wood Elf", 5: "High Elf",
		6: "Dark Elf", 7: "Half Elf", 8: "Dwarf", 9: "Troll", 10: "Ogre",
		11: "Halfling", 12: "Gnome", 13: "Iksar", 14: "Vah Shir", 15: "Froglok",
		128: "Iksar",
	}
	return races[raceID]
}

func (s *Service) getGenderName(genderID uint8) string {
	genders := map[uint8]string{
		0: "Male",
		1: "Female",
		2: "Neuter",
	}
	return genders[genderID]
}

func (s *Service) getDeityName(deityID uint32) string {
	deities := map[uint32]string{
		201: "Bertoxxulous",
		202: "Brell Serilis",
		203: "Cazic Thule",
		204: "Erollisi Marr",
		205: "Bristlebane",
		206: "Innoruuk",
		207: "Karana",
		208: "Mithaniel Marr",
		209: "Prexus",
		210: "Quellious",
		211: "Rallos Zek",
		212: "Rodcet Nife",
		213: "Solusek Ro",
		214: "The Tribunal",
		215: "Tunare",
		216: "Veeshan",
	}
	return deities[deityID]
}

func inventoryAfterTrade(inventoryCounts map[int]int, itemIDs []int) map[int]bool {
	remainingCounts := make(map[int]int, len(inventoryCounts))
	for itemID, count := range inventoryCounts {
		remainingCounts[itemID] = count
	}
	for _, itemID := range itemIDs {
		if remainingCounts[itemID] > 0 {
			remainingCounts[itemID]--
		}
	}
	remaining := make(map[int]bool, len(remainingCounts))
	for itemID, count := range remainingCounts {
		if count > 0 {
			remaining[itemID] = true
		}
	}
	return remaining
}

// ProcessTurnIn handles a player giving items to an NPC
func (s *Service) ProcessTurnIn(
	characterID uint32,
	npcID int32,
	zoneShortName string,
	itemIDs []int,
	currency QuestCurrency,
	npcPosition *QuestActorPosition,
	playerPosition *QuestActorPosition,
) (*QuestTurnInResponse, error) {
	return s.ProcessTurnInWithContext(characterID, npcID, zoneShortName, itemIDs, currency, QuestTurnInContext{NPCPosition: npcPosition, PlayerPosition: playerPosition})
}

func (s *Service) ProcessTurnInWithContext(
	characterID uint32,
	npcID int32,
	zoneShortName string,
	itemIDs []int,
	currency QuestCurrency,
	runtimeContext QuestTurnInContext,
) (*QuestTurnInResponse, error) {
	log.Printf("[Quest-TurnIn] charID=%d npcID=%d zone=%s items=%v currency=%+v", characterID, npcID, zoneShortName, itemIDs, currency)
	// 1. Get NPC info
	var npcName string
	var npcRace, npcClass, npcGender, npcFaction, npcHP int32
	err := s.db.QueryRow("SELECT name, race, class, gender, npc_faction_id, hp FROM npc_types WHERE id = ?", npcID).Scan(
		&npcName, &npcRace, &npcClass, &npcGender, &npcFaction, &npcHP,
	)
	if err != nil {
		log.Printf("[Quest-TurnIn] NPC lookup failed for id=%d: %v", npcID, err)
		return nil, err
	}
	log.Printf("[Quest-TurnIn] NPC name: %s", npcName)
	cleanName := strings.ReplaceAll(npcName, "_", " ")

	readContext, err := s.loadQuestReadContext(characterID, npcID, zoneShortName, runtimeContext)
	if err != nil {
		return nil, err
	}
	player, zoneID, globals, scriptState := readContext.Player, readContext.ZoneID, readContext.Globals, readContext.ScriptState

	npcProxy := &NPCProxy{ID: npcID, Name: cleanName, Race: uint16(npcRace), Class: uint8(npcClass), Gender: uint8(npcGender), PrimaryFaction: npcFaction, HP: int64(npcHP), MaxHP: int64(npcHP)}
	playerProxy := player.questPlayerProxy(characterID, itemIDs)

	event := &LuaEvent{
		NPC:       npcProxy,
		NPCVitals: runtimeContext.NPCVitals,
		Player:    playerProxy,
		Trade: &TradeProxy{
			Items:    itemIDs,
			Platinum: currency.Platinum,
			Gold:     currency.Gold,
			Silver:   currency.Silver,
			Copper:   currency.Copper,
		},
		Globals:             globals,
		GlobalSnapshot:      readContext.GlobalSnapshot,
		ScriptState:         scriptState,
		SpawnInstanceID:     runtimeContext.SpawnInstanceID,
		InstanceID:          runtimeContext.InstanceID,
		VisibleNPCTypeIDs:   runtimeContext.VisibleNPCTypeIDs,
		ResolveNPC:          runtimeContext.ResolveNPC,
		ReadNPCCombat:       runtimeContext.ReadNPCCombat,
		ReadNPCGrid:         runtimeContext.ReadNPCGrid,
		ReadSpawnConditions: runtimeContext.ReadSpawnConditions,
		ListNPCs:            runtimeContext.ListNPCs,
		ReadTimer:           s.questTimerReader(characterID, npcID, zoneShortName, runtimeContext.InstanceID, runtimeContext.SpawnInstanceID),
	}

	// 2. Try DB script first, then filesystem
	applyQuestInteractionPositions(event, runtimeContext)
	capture, err := s.executeEvent("trade", npcName, npcID, zoneShortName, event)
	if err != nil {
		log.Printf("[Quest-TurnIn] executeEvent error: %v", err)
		return nil, err
	}
	if capture == nil {
		log.Printf("[Quest-TurnIn] capture is nil — no script found for %s/%s", zoneShortName, npcName)
		return &QuestTurnInResponse{Success: false}, nil
	}
	log.Printf("[Quest-TurnIn] capture responses=%v items=%v exp=%d", capture.Responses, capture.Items, capture.Exp)

	consumedItemIDs := []int{}
	leftovers := make(map[int]int)
	if capture.CurrentTrade != nil {
		for _, id := range capture.CurrentTrade.Items {
			leftovers[id]++
		}
	}
	for _, id := range itemIDs {
		if leftovers[id] > 0 {
			leftovers[id]--
		} else {
			consumedItemIDs = append(consumedItemIDs, id)
		}
	}

	consumedCurrency := QuestCurrency{
		Platinum: currency.Platinum,
		Gold:     currency.Gold,
		Silver:   currency.Silver,
		Copper:   currency.Copper,
	}

	if capture.CurrentTrade != nil {
		consumedCurrency.Platinum -= capture.CurrentTrade.Platinum
		consumedCurrency.Gold -= capture.CurrentTrade.Gold
		consumedCurrency.Silver -= capture.CurrentTrade.Silver
		consumedCurrency.Copper -= capture.CurrentTrade.Copper
	}

	rewardPreview := rewardSummaryFromCapture(capture)
	if unavailableResponse := rejectUnavailableExpansionQuestItems(consumedItemIDs, rewardPreview, s.questItemTemplateExists); unavailableResponse != nil {
		log.Printf("[Quest-TurnIn] unavailable expansion item templates for %s/%s: %v", zoneShortName, npcName, unavailableResponse.UnavailableExpansionItemIDs)
		return unavailableResponse, nil
	}
	if runtimeContext.validateRewards != nil {
		if err := runtimeContext.validateRewards(consumedItemIDs, rewardPreview); err != nil {
			return &QuestTurnInResponse{Success: false, Error: err.Error()}, nil
		}
	}

	rewards := s.describeQuestCaptureRewards(capture)
	if !runtimeContext.deferPersistence {
		rewards, err = s.persistQuestEventCapture(characterID, npcID, zoneID, zoneShortName, runtimeContext, capture)
		if err != nil {
			return nil, fmt.Errorf("persist quest event: %w", err)
		}
	}

	hasCurrencyReward := rewards.Currency.Platinum > 0 ||
		rewards.Currency.Gold > 0 ||
		rewards.Currency.Silver > 0 ||
		rewards.Currency.Copper > 0
	hasSideEffects := len(capture.Responses) > 0 ||
		len(capture.Spells) > 0 ||
		len(rewards.Items) > 0 ||
		rewards.Experience > 0 ||
		hasCurrencyReward ||
		len(rewards.Factions) > 0 ||
		rewards.Ding ||
		len(capture.Globals) > 0 ||
		captureHasRuntimeEffects(capture)
	if !hasSideEffects {
		log.Printf("[Quest-TurnIn] No side effects — returning Success=false")
		return &QuestTurnInResponse{Success: false}, nil
	}

	// 3. Get updated NPC info
	var newInfo *QuestNPCInfo
	if !runtimeContext.deferPersistence {
		newInfo, _ = s.GetNPCQuestInfoWithContext(characterID, npcID, zoneShortName, runtimeContext)
		s.applyTurnInDialogue(newInfo, strings.Join(formatQuestResponses(capture.Responses, player), "\n"), capture)
	}

	return &QuestTurnInResponse{
		Success:          true,
		NPCResponse:      strings.Join(formatQuestResponses(capture.Responses, player), "\n"),
		NewInfo:          newInfo,
		Rewards:          rewards,
		ConsumedItemIDs:  consumedItemIDs,
		ConsumedCurrency: consumedCurrency,
		RuntimeCapture:   capture,
	}, nil
}

func (s *Service) describeQuestCaptureRewards(capture *QuestCapture) RewardSummary {
	rewards := rewardSummaryFromCapture(capture)
	for i, item := range rewards.Items {
		_ = s.db.QueryRow("SELECT name FROM items WHERE id = ?", item.ItemID).Scan(&rewards.Items[i].ItemName)
	}
	for _, faction := range capture.Factions {
		var name string
		_ = s.db.QueryRow("SELECT name FROM faction_list WHERE id = ?", faction.FactionID).Scan(&name)
		if name == "" {
			continue
		}
		direction := "better"
		if faction.Amount < 0 {
			direction = "worse"
		}
		rewards.Factions = append(rewards.Factions, fmt.Sprintf("Your faction standing with %s has gotten %s.", name, direction))
	}
	for _, skill := range capture.SkillUpdates {
		name := constants.GetSkillName(skill.SkillID)
		if name == "" {
			name = fmt.Sprintf("skill %d", skill.SkillID)
		}
		rewards.Factions = append(rewards.Factions, fmt.Sprintf("Your %s skill is now %d.", name, skill.Value))
	}
	for _, task := range capture.Tasks {
		if task.Action != "assign" {
			continue
		}
		var name string
		_ = s.db.QueryRow("SELECT title FROM tasks WHERE id = ?", task.TaskID).Scan(&name)
		if name != "" {
			rewards.Factions = append(rewards.Factions, fmt.Sprintf("You have been assigned the task: %s", name))
		}
	}
	return rewards
}

func captureHasEffects(capture *QuestCapture) bool {
	if capture == nil {
		return false
	}
	return len(capture.Factions) > 0 || len(capture.Items) > 0 || len(capture.Spells) > 0 ||
		capture.Exp > 0 || capture.Ding || len(capture.Tasks) > 0 || capture.Currency.Platinum > 0 ||
		capture.Currency.Gold > 0 || capture.Currency.Silver > 0 || capture.Currency.Copper > 0 ||
		len(capture.SkillUpdates) > 0 ||
		len(capture.Globals) > 0 ||
		captureHasRuntimeEffects(capture)
}

func captureHasRuntimeEffects(capture *QuestCapture) bool {
	return capture != nil && (len(capture.SpawnConditions) > 0 || len(capture.DeferredAPIs) > 0 || len(capture.HateChanges) > 0 || len(capture.ExternalNPCAddedLoot) > 0 || len(capture.Attacks) > 0 || len(capture.Spawns) > 0 || len(capture.Signals) > 0 || len(capture.Timers) > 0 ||
		len(capture.Depops) > 0 || len(capture.PlayerMoves) > 0 || len(capture.NPCMoves) > 0 || len(capture.NPCFollows) > 0 || len(capture.Doors) > 0 ||
		len(capture.Binds) > 0 || len(capture.HPEvents) > 0 || len(capture.GroundItems) > 0 || capture.Proximity != nil || capture.ProximitySayEnabled != nil)
}

func (s *Service) loadRuntimeScriptState(characterID uint32, npcID int32, zoneName string, instanceID int, spawnInstanceID int64) (map[string]any, error) {
	stateKey := questRuntimeScriptStateKey(npcID, spawnInstanceID)
	if stateKey == 0 {
		return map[string]any{}, nil
	}
	state, found, err := s.loadRuntimeScriptStateByKey(characterID, npcID, zoneName, instanceID, stateKey)
	if err != nil || found || spawnInstanceID <= 0 || npcID <= 0 {
		return state, err
	}
	fallbackKey := questRuntimeScriptStateKey(npcID, 0)
	if fallbackKey == 0 || fallbackKey == stateKey {
		return map[string]any{}, nil
	}
	state, _, err = s.loadRuntimeScriptStateByKey(characterID, npcID, zoneName, instanceID, fallbackKey)
	// Type-scoped legacy progress may be inherited, but an NPC's physical
	// inventory must never be cloned into every incarnation of that NPC type.
	delete(state, NPCAddedLootScriptStateKey)
	return state, err
}

func (s *Service) loadRuntimeScriptStateByKey(characterID uint32, npcID int32, zoneName string, instanceID int, stateKey int64) (map[string]any, bool, error) {
	var encoded []byte
	var storedNPCID int32
	err := s.db.QueryRow(`SELECT npc_type_id, state_json FROM quest_runtime_script_state WHERE owner_character_id=? AND zone_name=? AND instance_id=? AND spawn_instance_id=?`, characterID, zoneName, instanceID, stateKey).Scan(&storedNPCID, &encoded)
	if err == sql.ErrNoRows {
		return map[string]any{}, false, nil
	}
	if err != nil {
		return nil, false, err
	}
	if storedNPCID != npcID {
		return nil, false, fmt.Errorf("quest state spawn %d belongs to NPC %d, not %d", stateKey, storedNPCID, npcID)
	}
	state := map[string]any{}
	if err := json.Unmarshal(encoded, &state); err != nil {
		return nil, false, err
	}
	return state, true, nil
}

func (s *Service) RuntimeNPCAddedLoot(characterID uint32, npcID int32, zoneName string, instanceID int, spawnInstanceID int64) ([]NPCAddedLoot, error) {
	if characterID == 0 || npcID <= 0 || zoneName == "" || spawnInstanceID <= 0 {
		return nil, fmt.Errorf("quest NPC inventory requires an exact owner, zone and spawn")
	}
	state, _, err := s.loadRuntimeScriptStateByKey(characterID, npcID, zoneName, instanceID, spawnInstanceID)
	if err != nil {
		return nil, err
	}
	return npcAddedLootForActor(state, npcID, spawnInstanceID)
}

func npcAddedLootForActor(state map[string]any, npcID int32, spawnInstanceID int64) ([]NPCAddedLoot, error) {
	items, err := NPCAddedLootFromScriptState(state)
	if err != nil {
		return nil, err
	}
	var result []NPCAddedLoot
	for _, item := range items {
		if item.SpawnInstanceID != 0 && item.SpawnInstanceID != spawnInstanceID {
			return nil, fmt.Errorf("quest NPC inventory item %d belongs to spawn %d, not %d", item.ItemID, item.SpawnInstanceID, spawnInstanceID)
		}
		if item.NPCID != 0 && item.NPCID != npcID {
			continue
		}
		if item.ItemID <= 0 || item.Count < -1 {
			return nil, fmt.Errorf("invalid quest NPC inventory item %d with charges %d for spawn %d", item.ItemID, item.Count, spawnInstanceID)
		}
		result = append(result, item)
	}
	return result, nil
}

func questRuntimeScriptStateKey(npcID int32, spawnInstanceID int64) int64 {
	if spawnInstanceID != 0 {
		return spawnInstanceID
	}
	if npcID <= 0 {
		return 0
	}
	return -int64(npcID)
}

func (s *Service) DeleteRuntimeScriptState(characterID uint32, zoneName string, instanceID int, spawnInstanceID int64) error {
	_, err := s.db.Exec(`DELETE FROM quest_runtime_script_state WHERE owner_character_id=? AND zone_name=? AND instance_id=? AND spawn_instance_id=?`, characterID, zoneName, instanceID, spawnInstanceID)
	return err
}

func (s *Service) questItemTemplateExists(itemID int32) bool {
	if itemID <= 0 {
		return true
	}
	var exists int
	err := s.db.QueryRow("SELECT 1 FROM items WHERE id = ? LIMIT 1", itemID).Scan(&exists)
	return err == nil
}

func (s *Service) getZoneID(shortName string) (int32, error) {
	// Jet qualifies result columns with the model name. An anonymous struct
	// silently leaves this field zero despite a successful zone lookup.
	var row model.Zone
	err := SELECT(table.Zone.Zoneidnumber).
		FROM(table.Zone).
		WHERE(table.Zone.ShortName.EQ(String(shortName))).
		LIMIT(1).
		Query(s.db, &row)
	if err != nil {
		return 0, err
	}
	return row.Zoneidnumber, nil
}

func (s *Service) getGlobals(charID uint32, npcID int32, zoneID int32) (map[string]string, error) {
	values, _, err := s.getGlobalsWithSnapshot(charID, npcID, zoneID)
	return values, err
}

func (s *Service) getGlobalsWithSnapshot(charID uint32, npcID int32, zoneID int32) (map[string]string, *QuestGlobalSnapshot, error) {
	var rows []model.QuestGlobals
	err := SELECT(table.QuestGlobals.AllColumns).
		FROM(table.QuestGlobals).
		WHERE(
			AND(
				OR(table.QuestGlobals.Charid.EQ(Int32(int32(charID))), table.QuestGlobals.Charid.EQ(Int32(0))),
				OR(table.QuestGlobals.Npcid.EQ(Int32(npcID)), table.QuestGlobals.Npcid.EQ(Int32(0))),
				OR(table.QuestGlobals.Zoneid.EQ(Int32(zoneID)), table.QuestGlobals.Zoneid.EQ(Int32(0))),
			),
		).
		ORDER_BY(table.QuestGlobals.Charid.ASC(), table.QuestGlobals.Npcid.ASC(), table.QuestGlobals.Zoneid.ASC()).
		Query(s.db, &rows)

	if err != nil && err != qrm.ErrNoRows {
		return nil, nil, err
	}

	snapshot := &QuestGlobalSnapshot{}
	globals := make(map[string]string)
	now := time.Now().Unix()
	for _, r := range rows {
		if r.Expdate != nil && int64(*r.Expdate) <= now {
			continue
		}
		globals[r.Name] = r.Value
		snapshot.Rows = append(snapshot.Rows, r)
	}
	return globals, snapshot, nil
}

func questGlobalScopeIDs(charID uint32, npcID int32, zoneID int32, options int) (int32, int32, int32) {
	qgCharID := int32(charID)
	qgNPCID := npcID
	qgZoneID := zoneID
	if options < 0 || options > 7 {
		options = 0
	}
	// EQEmu qglobal option bits:
	//   1 => all NPCs, 2 => all players, 4 => all zones.
	// Example: option 5 means all NPCs, this player, all zones.
	if options&1 != 0 {
		qgNPCID = 0
	}
	if options&2 != 0 {
		qgCharID = 0
	}
	if options&4 != 0 {
		qgZoneID = 0
	}
	return qgCharID, qgNPCID, qgZoneID
}

// Hail, keyword discovery/execution and Give must expose the same live actor
// coordinates. Applying only Give positions silently routed dialogue moves to
// zero; explicit test-only self overrides still take precedence afterward.
func applyQuestInteractionPositions(event *LuaEvent, runtime QuestTurnInContext) {
	if p := runtime.NPCPosition; p != nil && event.NPC != nil {
		event.NPC.X, event.NPC.Y, event.NPC.Z, event.NPC.Heading = p.X, p.Y, p.Z, p.Heading
	}
	if p := runtime.PlayerPosition; p != nil && event.Player != nil {
		event.Player.X, event.Player.Y, event.Player.Z, event.Player.Heading = p.X, p.Y, p.Z, p.Heading
	}
	event.NPC = applyQuestNPCSelfOverride(event.NPC, runtime.NPCSelfOverride)
}

func applyQuestNPCSelfOverride(npc *NPCProxy, override *QuestNPCSelfOverride) *NPCProxy {
	if npc == nil || override == nil {
		return npc
	}
	if override.NPCTypeID > 0 {
		npc.ID = override.NPCTypeID
	}
	if override.Race > 0 {
		npc.Race = override.Race
	}
	if override.Gender != nil {
		npc.Gender = *override.Gender
	}
	if override.X != nil {
		npc.X = *override.X
	}
	if override.Y != nil {
		npc.Y = *override.Y
	}
	return npc
}

func rewardSummaryFromCapture(cap *QuestCapture) RewardSummary {
	if cap == nil {
		return RewardSummary{}
	}
	return RewardSummary{
		Experience:   cap.Exp,
		Ding:         cap.Ding,
		Currency:     cap.Currency,
		Items:        cap.Items,
		SkillUpdates: cap.SkillUpdates,
	}
}

func rejectUnavailableExpansionQuestItems(consumedItemIDs []int, rewards RewardSummary, exists func(int32) bool) *QuestTurnInResponse {
	missingItemIDs := unavailableQuestTemplateItemIDs(consumedItemIDs, rewards, exists)
	if len(missingItemIDs) == 0 {
		return nil
	}
	return &QuestTurnInResponse{
		Success:                     false,
		UnavailableExpansionItemIDs: missingItemIDs,
	}
}
