package quest

import (
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

type QuestScript struct {
	Zone   string
	NPC    string
	Source string
}

type turnInNPCOverride struct {
	NPCTypeID int32
	Race      uint16
	Gender    *uint8
	X         *float64
	Y         *float64
}

type TurnInCaseResult struct {
	Zone             string
	NPC              string
	CaseName         string
	Status           TurnInCaseStatus
	MissingAPI       string
	Scenario         TurnInScenario
	Capture          *QuestCapture
	Player           *TurnInPlayerOverride
	Globals          map[string]string
	NPCPrerequisites *TurnInNPCPrerequisites
	Activated        bool
	Err              error
	ValidationErrors []string
	DeferredAPIs     []string
}

type TurnInMatrixReport struct {
	Scripts            int
	ScriptsWithTurnIns int
	DiscoveredCases    int
	ExecutedCases      int
	ActivatedCases     int
	Unsupported        []QuestScriptUnsupportedTurnIn
	Results            []TurnInCaseResult
	UnmatchedOverrides []TurnInScenarioOverride
}

type QuestScriptUnsupportedTurnIn struct {
	Zone string
	NPC  string
	UnsupportedTurnIn
}

type TurnInNPCPrerequisites struct {
	NPCTypeID int32    `json:"npcTypeId,omitempty"`
	Race      uint16   `json:"race,omitempty"`
	Gender    *uint8   `json:"gender,omitempty"`
	X         *float64 `json:"x,omitempty"`
	Y         *float64 `json:"y,omitempty"`
}

type TurnInCaseStatus string

const (
	TurnInCaseActivated  TurnInCaseStatus = "activated"
	TurnInCaseInactive   TurnInCaseStatus = "inactive"
	TurnInCaseFailed     TurnInCaseStatus = "failed"
	TurnInCaseMissingAPI TurnInCaseStatus = "missing_api"
	TurnInCaseMismatch   TurnInCaseStatus = "mismatch"
)

// RunTurnInMatrix discovers and executes every literal turn-in in the supplied
// scripts. The caller owns loading scripts (database, fixture, or file) so this
// runner remains deterministic and fast in normal unit tests.
func RunTurnInMatrix(bridge *LuaBridge, scripts []QuestScript) TurnInMatrixReport {
	return RunTurnInMatrixWithOverrides(bridge, scripts, nil)
}

func RunTurnInMatrixWithOverrides(bridge *LuaBridge, scripts []QuestScript, overrides []TurnInScenarioOverride) TurnInMatrixReport {
	report := TurnInMatrixReport{Scripts: len(scripts)}
	matchedOverrides := make([]bool, len(overrides))
	for _, script := range scripts {
		discovery := DiscoverTurnInScenarios(script.Source)
		if len(discovery.Scenarios) > 0 || len(discovery.Unsupported) > 0 {
			report.ScriptsWithTurnIns++
		}
		for _, unsupported := range discovery.Unsupported {
			matching := matchingOverrideSelector(script, unsupported.CallIndex, unsupported.Line, overrides, matchedOverrides)
			run := false
			for _, override := range matching {
				if override.Requirements == nil {
					continue
				}
				run = true
				scenario := TurnInScenario{Line: unsupported.Line, CallIndex: unsupported.CallIndex, Source: unsupported.Source}
				report.runCase(bridge, script, scenario, override)
			}
			if run {
				continue
			}
			report.Unsupported = append(report.Unsupported, QuestScriptUnsupportedTurnIn{
				Zone: script.Zone, NPC: script.NPC, UnsupportedTurnIn: unsupported,
			})
		}
		for _, scenario := range discovery.Scenarios {
			report.DiscoveredCases++
			matching := matchingOverrides(script, scenario, overrides, matchedOverrides)
			if len(matching) == 0 {
				report.runCase(bridge, script, scenario, TurnInScenarioOverride{})
				continue
			}
			for _, override := range matching {
				report.runCase(bridge, script, scenario, override)
			}
		}
	}
	for index, override := range overrides {
		if !matchedOverrides[index] {
			report.UnmatchedOverrides = append(report.UnmatchedOverrides, override)
		}
	}
	return report
}

func (r *TurnInMatrixReport) runCase(bridge *LuaBridge, script QuestScript, discovered TurnInScenario, override TurnInScenarioOverride) {
	scenario := discovered
	if override.Requirements != nil {
		scenario.Items = append([]int(nil), override.Requirements.Items...)
		scenario.Currency = override.Requirements.Currency
	}
	playerOverride := override.Player
	globals := override.Globals
	var npcOverride *turnInNPCOverride
	inferredPlayerApplied := false
	if playerOverride == nil || len(globals) == 0 {
		inferredPlayer, inferredGlobals, inferredNPC := inferTurnInPrerequisites(script.Source, scenario.Line)
		if playerOverride == nil {
			playerOverride = inferredPlayer
			inferredPlayerApplied = inferredPlayer != nil
		}
		if len(globals) == 0 {
			globals = inferredGlobals
		}
		npcOverride = inferredNPC
	}
	handler := turnInHandlerForLine(script.Source, scenario.Line)
	capture, err := bridge.ExecuteEventFromSource(script.Source, handler, scenarioEvent(script, scenario, playerOverride, globals, npcOverride))
	result := TurnInCaseResult{
		Zone:             script.Zone,
		NPC:              script.NPC,
		CaseName:         override.Name,
		Scenario:         scenario,
		Capture:          capture,
		Player:           cloneTurnInPlayerOverride(playerOverride),
		Globals:          cloneStringMap(globals),
		NPCPrerequisites: turnInNPCPrerequisites(npcOverride),
		Err:              err,
	}
	if err == nil {
		r.ExecutedCases++
		result.Activated = turnInCaptureActivated(capture, scenario)
		if result.Activated {
			r.ActivatedCases++
			result.Status = TurnInCaseActivated
		} else {
			result.Status = TurnInCaseInactive
		}
		result.ValidationErrors = validateTurnInExpectation(capture, scenario, result.Activated, override.Expect)
		if len(result.ValidationErrors) > 0 {
			result.Status = TurnInCaseMismatch
		}
		if result.Status == TurnInCaseInactive && inferredPlayerApplied && playerOverride.Class != "" && override.Expect == nil {
			alternatePlayer := *playerOverride
			alternatePlayer.Class = ""
			retryCapture, retryErr := bridge.ExecuteEventFromSource(script.Source, handler, scenarioEvent(script, scenario, &alternatePlayer, globals, npcOverride))
			if retryErr == nil && turnInCaptureActivated(retryCapture, scenario) {
				result.Capture = retryCapture
				result.Activated = true
				result.Status = TurnInCaseActivated
				r.ActivatedCases++
			}
		}
		if result.Status == TurnInCaseInactive && override.Expect == nil {
			if npcTypeID := registeredNPCTypeForHandler(script.Source, handler, RuntimeEventTrade); npcTypeID > 0 {
				retryCapture, retryErr := bridge.ExecuteRegisteredNPCEventFromSource(script.Source, RuntimeEventTrade, npcTypeID, scenarioEvent(script, scenario, playerOverride, globals, npcOverride))
				if retryErr == nil && turnInCaptureActivated(retryCapture, scenario) {
					result.Capture = retryCapture
					result.Activated = true
					result.Status = TurnInCaseActivated
					r.ActivatedCases++
				}
			}
		}
		if result.Status == TurnInCaseInactive && override.Expect == nil {
			if _, fullGlobals, _ := inferTurnInPrerequisitesFullContext(script.Source, scenario.Line); len(fullGlobals) > 0 {
				retryCapture, retryErr := bridge.ExecuteEventFromSource(script.Source, handler, scenarioEvent(script, scenario, playerOverride, fullGlobals, npcOverride))
				if retryErr == nil && turnInCaptureActivated(retryCapture, scenario) {
					result.Capture = retryCapture
					result.Globals = cloneStringMap(fullGlobals)
					result.Activated = true
					result.Status = TurnInCaseActivated
					r.ActivatedCases++
				}
			}
		}
	} else if missing := classifyMissingLuaAPI(err, script.Source); missing != "" {
		result.Status = TurnInCaseMissingAPI
		result.MissingAPI = missing
	} else {
		result.Status = TurnInCaseFailed
	}
	if result.Capture != nil {
		result.DeferredAPIs = append([]string(nil), result.Capture.DeferredAPIs...)
	}
	r.Results = append(r.Results, result)
}

var (
	tradeFunctionRE             = regexp.MustCompile(`(?i)function\s+event_trade\s*\(`)
	classEnumConditionRE        = regexp.MustCompile(`(?i)e\.other:(?:GetClass|Class)\s*\(\s*\)\s*==\s*Class\.([A-Z_]+|[A-Za-z]+)`)
	classNameConditionRE        = regexp.MustCompile(`(?i)e\.other:GetClassName\s*\(\s*\)\s*==\s*["']([^"']+)["']`)
	legacyClassNameConditionRE  = regexp.MustCompile(`(?i)e\.other:Class\s*\(\s*\)\s*==\s*["']([^"']+)["']`)
	localClassAssignmentRE      = regexp.MustCompile(`(?i)local\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*e\.other:GetClass\s*\(\s*\)`)
	raceEnumConditionRE         = regexp.MustCompile(`(?i)e\.other:(?:GetRace|Race|GetBaseRace)\s*\(\s*\)\s*==\s*Race\.([A-Z_]+|[A-Za-z]+)`)
	raceNameConditionRE         = regexp.MustCompile(`(?i)e\.other:GetRaceName\s*\(\s*\)\s*==\s*["']([^"']+)["']`)
	legacyRaceNameConditionRE   = regexp.MustCompile(`(?i)e\.other:Race\s*\(\s*\)\s*==\s*["']([^"']+)["']`)
	localRaceAssignmentRE       = regexp.MustCompile(`(?i)local\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*e\.other:GetRaceName\s*\(\s*\)`)
	localLevelAssignmentRE      = regexp.MustCompile(`(?i)local\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*e\.other:(?:GetLevel|Level)\s*\(\s*\)`)
	levelMinConditionRE         = regexp.MustCompile(`(?i)e\.other:(?:GetLevel|Level)\s*\(\s*\)\s*>=\s*([0-9]+)`)
	levelEqualConditionRE       = regexp.MustCompile(`(?i)e\.other:(?:GetLevel|Level)\s*\(\s*\)\s*==\s*([0-9]+)`)
	levelGreaterConditionRE     = regexp.MustCompile(`(?i)e\.other:(?:GetLevel|Level)\s*\(\s*\)\s*>\s*([0-9]+)`)
	levelLessEqualConditionRE   = regexp.MustCompile(`(?i)e\.other:(?:GetLevel|Level)\s*\(\s*\)\s*<=\s*([0-9]+)`)
	levelLessConditionRE        = regexp.MustCompile(`(?i)e\.other:(?:GetLevel|Level)\s*\(\s*\)\s*<\s*([0-9]+)`)
	taskActiveConditionRE       = regexp.MustCompile(`(?i)e\.other:IsTaskActive\s*\(\s*([0-9]+)\s*\)`)
	taskActivityConditionRE     = regexp.MustCompile(`(?i)e\.other:IsTaskActivityActive\s*\(\s*([0-9]+)\s*,\s*([0-9]+)\s*\)`)
	hasItemConditionRE          = regexp.MustCompile(`(?i)e\.other:HasItem\s*\(\s*([0-9]+)\s*\)`)
	qglobalEqualConditionRE     = regexp.MustCompile(`(?i)qglobals\s*\[\s*["']([^"']+)["']\s*\]\s*==\s*["']([^"']+)["']`)
	qglobalMinConditionRE       = regexp.MustCompile(`(?i)qglobals\s*\[\s*["']([^"']+)["']\s*\]\s*>=\s*["']?([0-9]+)["']?`)
	qglobalExistsConditionRE    = regexp.MustCompile(`(?i)qglobals\s*\[\s*["']([^"']+)["']\s*\]\s*~=\s*nil`)
	qglobalDotEqualConditionRE  = regexp.MustCompile(`(?i)qglobals\.([A-Za-z_][A-Za-z0-9_]*)\s*==\s*["']([^"']+)["']`)
	qglobalDotMinConditionRE    = regexp.MustCompile(`(?i)qglobals\.([A-Za-z_][A-Za-z0-9_]*)\s*>=\s*["']?([0-9]+)["']?`)
	qglobalDotExistsConditionRE = regexp.MustCompile(`(?i)qglobals\.([A-Za-z_][A-Za-z0-9_]*)\s*~=\s*nil`)
	sameBaseRaceConditionRE     = regexp.MustCompile(`(?i)e\.other:GetBaseRace\s*\(\s*\)\s*==\s*e\.self:GetBaseRace\s*\(\s*\)`)
	npcRaceConditionRE          = regexp.MustCompile(`(?i)e\.self:GetRace\s*\(\s*\)\s*==\s*([0-9]+)`)
	npcBaseRaceConditionRE      = regexp.MustCompile(`(?i)e\.self:GetBaseRace\s*\(\s*\)\s*==\s*([0-9]+)`)
	npcGenderConditionRE        = regexp.MustCompile(`(?i)e\.self:GetGender\s*\(\s*\)\s*==\s*([0-9]+)`)
	npcTypeConditionRE          = regexp.MustCompile(`(?i)e\.self:GetNPCTypeID\s*\(\s*\)\s*==\s*([0-9]+)`)
	npcXGreaterConditionRE      = regexp.MustCompile(`(?i)e\.self:GetX\s*\(\s*\)\s*>\s*(-?[0-9]+(?:\.[0-9]+)?)`)
	npcYLessConditionRE         = regexp.MustCompile(`(?i)e\.self:GetY\s*\(\s*\)\s*<\s*(-?[0-9]+(?:\.[0-9]+)?)`)
)

func inferTurnInPrerequisites(source string, line int) (*TurnInPlayerOverride, map[string]string, *turnInNPCOverride) {
	context := eventTradeContextBeforeLine(source, line)
	if context == "" {
		return nil, nil, nil
	}
	classRaceContext := context
	branchContext := turnInBranchContext(context)
	player := &TurnInPlayerOverride{}
	hasPlayer := false
	if match := classEnumConditionRE.FindStringSubmatch(classRaceContext); len(match) == 2 {
		player.Class = enumNameToDisplayName(match[1])
		hasPlayer = true
	} else if match := classNameConditionRE.FindStringSubmatch(classRaceContext); len(match) == 2 {
		player.Class = match[1]
		hasPlayer = true
	} else if match := legacyClassNameConditionRE.FindStringSubmatch(classRaceContext); len(match) == 2 {
		player.Class = match[1]
		hasPlayer = true
	} else if className := inferLocalClassAlias(classRaceContext); className != "" {
		player.Class = className
		hasPlayer = true
	}
	if match := raceEnumConditionRE.FindStringSubmatch(classRaceContext); len(match) == 2 {
		player.Race = enumNameToDisplayName(match[1])
		hasPlayer = true
	} else if match := raceNameConditionRE.FindStringSubmatch(classRaceContext); len(match) == 2 {
		player.Race = match[1]
		hasPlayer = true
	} else if match := legacyRaceNameConditionRE.FindStringSubmatch(classRaceContext); len(match) == 2 {
		player.Race = match[1]
		hasPlayer = true
	} else if raceName := inferLocalRaceAlias(classRaceContext); raceName != "" {
		player.Race = raceName
		hasPlayer = true
	}
	if level, ok := inferLevelPrerequisite(source, line, context, branchContext); ok {
		player.Level = level
		hasPlayer = true
	}
	for _, match := range taskActiveConditionRE.FindAllStringSubmatch(context, -1) {
		taskID, _ := strconv.Atoi(match[1])
		player.ActiveTasks = append(player.ActiveTasks, taskID)
		hasPlayer = true
	}
	for _, match := range taskActivityConditionRE.FindAllStringSubmatch(context, -1) {
		taskID, _ := strconv.Atoi(match[1])
		activityID, _ := strconv.Atoi(match[2])
		player.ActiveTaskActivities = append(player.ActiveTaskActivities, TurnInTaskActivity{TaskID: taskID, ActivityID: activityID})
		hasPlayer = true
	}
	for _, match := range hasItemConditionRE.FindAllStringSubmatch(branchContext, -1) {
		itemID, _ := strconv.Atoi(match[1])
		player.HasItems = append(player.HasItems, itemID)
		hasPlayer = true
	}
	globals := inferQGlobals(branchContext)
	npc := &turnInNPCOverride{}
	hasNPC := false
	if matches := npcRaceConditionRE.FindAllStringSubmatch(context, -1); len(matches) > 0 {
		race, _ := strconv.Atoi(matches[len(matches)-1][1])
		npc.Race = uint16(race)
		hasNPC = true
	}
	if matches := npcBaseRaceConditionRE.FindAllStringSubmatch(context, -1); len(matches) > 0 {
		race, _ := strconv.Atoi(matches[len(matches)-1][1])
		npc.Race = uint16(race)
		hasNPC = true
	}
	if matches := npcGenderConditionRE.FindAllStringSubmatch(context, -1); len(matches) > 0 {
		gender, _ := strconv.Atoi(matches[len(matches)-1][1])
		value := uint8(gender)
		npc.Gender = &value
		hasNPC = true
	}
	if matches := npcTypeConditionRE.FindAllStringSubmatch(context, -1); len(matches) > 0 {
		npcTypeID, _ := strconv.Atoi(matches[len(matches)-1][1])
		npc.NPCTypeID = int32(npcTypeID)
		hasNPC = true
	}
	if matches := npcXGreaterConditionRE.FindAllStringSubmatch(branchContext, -1); len(matches) > 0 {
		threshold, _ := strconv.ParseFloat(matches[len(matches)-1][1], 64)
		value := threshold + 1
		npc.X = &value
		hasNPC = true
	}
	if matches := npcYLessConditionRE.FindAllStringSubmatch(branchContext, -1); len(matches) > 0 {
		threshold, _ := strconv.ParseFloat(matches[len(matches)-1][1], 64)
		value := threshold - 1
		npc.Y = &value
		hasNPC = true
	}
	if sameBaseRaceConditionRE.MatchString(context) {
		if player.Race == "" {
			player.Race = "Human"
			hasPlayer = true
		}
		if npc.Race == 0 {
			npc.Race = raceIDByName(player.Race)
			hasNPC = true
		}
	}
	if !hasPlayer {
		player = nil
	}
	if len(globals) == 0 {
		globals = nil
	}
	if !hasNPC {
		npc = nil
	}
	return player, globals, npc
}

func inferTurnInPrerequisitesFullContext(source string, line int) (*TurnInPlayerOverride, map[string]string, *turnInNPCOverride) {
	context := eventTradeContextBeforeLine(source, line)
	if context == "" {
		return nil, nil, nil
	}
	return nil, inferQGlobals(context), nil
}

func inferQGlobals(context string) map[string]string {
	globals := map[string]string{}
	for _, match := range qglobalEqualConditionRE.FindAllStringSubmatch(context, -1) {
		setInferredQGlobal(globals, match[1], match[2])
	}
	for _, match := range qglobalMinConditionRE.FindAllStringSubmatch(context, -1) {
		setInferredQGlobal(globals, match[1], match[2])
	}
	for _, match := range qglobalExistsConditionRE.FindAllStringSubmatch(context, -1) {
		if _, exists := globals[match[1]]; !exists {
			globals[match[1]] = "1"
		}
	}
	for _, match := range qglobalDotEqualConditionRE.FindAllStringSubmatch(context, -1) {
		setInferredQGlobal(globals, match[1], match[2])
	}
	for _, match := range qglobalDotMinConditionRE.FindAllStringSubmatch(context, -1) {
		setInferredQGlobal(globals, match[1], match[2])
	}
	for _, match := range qglobalDotExistsConditionRE.FindAllStringSubmatch(context, -1) {
		if _, exists := globals[match[1]]; !exists {
			globals[match[1]] = "1"
		}
	}
	return globals
}

func setInferredQGlobal(globals map[string]string, name, value string) {
	next, nextErr := strconv.Atoi(value)
	current, currentErr := strconv.Atoi(globals[name])
	if nextErr != nil || currentErr != nil {
		if _, exists := globals[name]; !exists || value != "" {
			globals[name] = value
		}
		return
	}
	if next > current {
		globals[name] = value
	}
}

func turnInBranchContext(context string) string {
	lower := strings.ToLower(context)
	branchStart := strings.LastIndex(lower, "elseif")
	if branchStart < 0 {
		branchStart = strings.LastIndex(lower, "\nif")
		if branchStart >= 0 {
			branchStart++
		}
	}
	if branchStart < 0 {
		return context
	}
	return context[branchStart:]
}

func inferLocalClassAlias(context string) string {
	matches := localClassAssignmentRE.FindAllStringSubmatch(context, -1)
	for index := len(matches) - 1; index >= 0; index-- {
		variable := regexp.QuoteMeta(matches[index][1])
		pattern := regexp.MustCompile(`(?i)\b` + variable + `\s*==\s*Class\.([A-Z_]+|[A-Za-z]+)`)
		if condition := pattern.FindStringSubmatch(context); len(condition) == 2 {
			return enumNameToDisplayName(condition[1])
		}
	}
	return ""
}

func inferLocalRaceAlias(context string) string {
	matches := localRaceAssignmentRE.FindAllStringSubmatch(context, -1)
	for index := len(matches) - 1; index >= 0; index-- {
		variable := regexp.QuoteMeta(matches[index][1])
		pattern := regexp.MustCompile(`(?i)\b` + variable + `\s*==\s*["']([^"']+)["']`)
		if condition := pattern.FindStringSubmatch(context); len(condition) == 2 {
			return condition[1]
		}
	}
	return ""
}

func inferLevelPrerequisite(source string, line int, context, branchContext string) (int, bool) {
	levelAliases := inferLocalLevelAliases(context)
	for _, condition := range activeLuaConditionsBeforeLine(source, line) {
		if level, ok := levelFromCondition(condition, levelAliases); ok {
			return level, true
		}
	}
	if level, ok := levelFromCondition(branchContext, levelAliases); ok {
		return level, true
	}
	if level, ok := levelFromCondition(context, levelAliases); ok {
		return level, true
	}
	return 0, false
}

func inferLocalLevelAliases(context string) map[string]bool {
	aliases := map[string]bool{}
	for _, match := range localLevelAssignmentRE.FindAllStringSubmatch(context, -1) {
		aliases[match[1]] = true
	}
	return aliases
}

func activeLuaConditionsBeforeLine(source string, line int) []string {
	context := eventTradeContextStrictBeforeLine(source, line)
	if context == "" {
		return nil
	}
	var stack []string
	for _, rawLine := range strings.Split(context, "\n") {
		line := strings.TrimSpace(stripLuaLineComment(rawLine))
		if line == "" {
			continue
		}
		lower := strings.ToLower(line)
		for strings.HasPrefix(lower, "end") && len(stack) > 0 {
			stack = stack[:len(stack)-1]
			line = strings.TrimSpace(line[len("end"):])
			lower = strings.ToLower(line)
			if line == "" {
				break
			}
		}
		if line == "" {
			continue
		}
		if strings.HasPrefix(lower, "elseif ") {
			if condition := luaConditionFromLine(line, "elseif"); condition != "" {
				if len(stack) > 0 {
					stack[len(stack)-1] = condition
				} else {
					stack = append(stack, condition)
				}
			}
			continue
		}
		if lower == "else" || strings.HasPrefix(lower, "else ") {
			if len(stack) > 0 {
				stack[len(stack)-1] = "not (" + stack[len(stack)-1] + ")"
			}
			continue
		}
		if strings.HasPrefix(lower, "if ") {
			if condition := luaConditionFromLine(line, "if"); condition != "" {
				stack = append(stack, condition)
			}
		}
	}
	return stack
}

func eventTradeContextStrictBeforeLine(source string, line int) string {
	if line <= 0 {
		return ""
	}
	lineStart := byteOffsetForLine(source, line)
	if lineStart < 0 {
		return ""
	}
	prefix := source[:lineStart]
	matches := tradeFunctionRE.FindAllStringIndex(prefix, -1)
	if len(matches) == 0 {
		return ""
	}
	return source[matches[len(matches)-1][0]:lineStart]
}

func stripLuaLineComment(line string) string {
	if index := strings.Index(line, "--"); index >= 0 {
		return line[:index]
	}
	return line
}

func luaConditionFromLine(line, keyword string) string {
	lower := strings.ToLower(line)
	start := strings.Index(lower, keyword)
	if start < 0 {
		return ""
	}
	condition := strings.TrimSpace(line[start+len(keyword):])
	lowerCondition := strings.ToLower(condition)
	if thenIndex := strings.LastIndex(lowerCondition, " then"); thenIndex >= 0 {
		condition = strings.TrimSpace(condition[:thenIndex])
	}
	return condition
}

func levelFromCondition(condition string, aliases map[string]bool) (int, bool) {
	trimmed := strings.TrimSpace(condition)
	negated := false
	lower := strings.ToLower(trimmed)
	if strings.HasPrefix(lower, "not (") && strings.HasSuffix(trimmed, ")") {
		negated = true
		trimmed = strings.TrimSpace(trimmed[len("not (") : len(trimmed)-1])
	}
	if level, ok := directLevelFromCondition(trimmed, negated); ok {
		return level, true
	}
	for alias := range aliases {
		if level, ok := aliasLevelFromCondition(trimmed, alias, negated); ok {
			return level, true
		}
	}
	return 0, false
}

func directLevelFromCondition(condition string, negated bool) (int, bool) {
	return levelFromComparisonRegexps(condition, negated,
		levelEqualConditionRE,
		levelMinConditionRE,
		levelGreaterConditionRE,
		levelLessEqualConditionRE,
		levelLessConditionRE,
	)
}

func aliasLevelFromCondition(condition, alias string, negated bool) (int, bool) {
	variable := regexp.QuoteMeta(alias)
	return levelFromComparisonRegexps(condition, negated,
		regexp.MustCompile(`(?i)\b`+variable+`\s*==\s*([0-9]+)`),
		regexp.MustCompile(`(?i)\b`+variable+`\s*>=\s*([0-9]+)`),
		regexp.MustCompile(`(?i)\b`+variable+`\s*>\s*([0-9]+)`),
		regexp.MustCompile(`(?i)\b`+variable+`\s*<=\s*([0-9]+)`),
		regexp.MustCompile(`(?i)\b`+variable+`\s*<\s*([0-9]+)`),
	)
}

func levelFromComparisonRegexps(condition string, negated bool, equal, min, greater, lessEqual, less *regexp.Regexp) (int, bool) {
	if match := equal.FindStringSubmatch(condition); len(match) == 2 {
		value, _ := strconv.Atoi(match[1])
		if negated {
			if value > 1 {
				return value - 1, true
			}
			return value + 1, true
		}
		return value, true
	}
	if match := min.FindStringSubmatch(condition); len(match) == 2 {
		value, _ := strconv.Atoi(match[1])
		if negated {
			if value > 1 {
				return value - 1, true
			}
			return 1, true
		}
		return value, true
	}
	if match := greater.FindStringSubmatch(condition); len(match) == 2 {
		value, _ := strconv.Atoi(match[1])
		if negated {
			return value, true
		}
		return value + 1, true
	}
	if match := lessEqual.FindStringSubmatch(condition); len(match) == 2 {
		value, _ := strconv.Atoi(match[1])
		if negated {
			return value + 1, true
		}
		return value, true
	}
	if match := less.FindStringSubmatch(condition); len(match) == 2 {
		value, _ := strconv.Atoi(match[1])
		if negated {
			return value, true
		}
		if value > 1 {
			return value - 1, true
		}
		return 1, true
	}
	return 0, false
}

func latestRegexpMatchStart(source string, patterns ...*regexp.Regexp) int {
	latest := -1
	for _, pattern := range patterns {
		for _, match := range pattern.FindAllStringIndex(source, -1) {
			if match[0] > latest {
				latest = match[0]
			}
		}
	}
	return latest
}

func eventTradeContextBeforeLine(source string, line int) string {
	if line <= 0 {
		return ""
	}
	lineStart := byteOffsetForLine(source, line)
	lineEnd := byteOffsetForLine(source, line+1)
	if lineStart < 0 {
		return ""
	}
	if lineEnd < 0 {
		lineEnd = len(source)
	}
	prefix := source[:lineStart]
	matches := tradeFunctionRE.FindAllStringIndex(prefix, -1)
	if len(matches) == 0 {
		return ""
	}
	return source[matches[len(matches)-1][0]:lineEnd]
}

func turnInHandlerForLine(source string, line int) string {
	if line <= 0 {
		return "event_trade"
	}
	lineStart := byteOffsetForLine(source, line)
	if lineStart < 0 {
		return "event_trade"
	}
	prefix := source[:lineStart]
	matches := regexp.MustCompile(`(?m)\b(?:local\s+)?function\s+([A-Za-z_][A-Za-z0-9_]*)\s*\(`).FindAllStringSubmatch(prefix, -1)
	if len(matches) == 0 {
		return "event_trade"
	}
	return matches[len(matches)-1][1]
}

func registeredNPCTypeForHandler(source, handler string, eventType RuntimeEventType) int32 {
	if strings.TrimSpace(handler) == "" {
		return 0
	}
	pattern := regexp.MustCompile(fmt.Sprintf(`(?s)eq\.register_npc_event\s*\(\s*(?:["'][^"']+["']\s*,\s*)?(?:Event\.%s|["']%s["'])\s*,\s*([0-9]+)\s*,\s*%s\s*\)`,
		regexp.QuoteMeta(string(eventType)),
		regexp.QuoteMeta(string(eventType)),
		regexp.QuoteMeta(handler),
	))
	match := pattern.FindStringSubmatch(source)
	if len(match) != 2 {
		return 0
	}
	npcTypeID, _ := strconv.Atoi(match[1])
	return int32(npcTypeID)
}

func byteOffsetForLine(source string, line int) int {
	if line <= 1 {
		return 0
	}
	currentLine := 1
	for index, char := range source {
		if char == '\n' {
			currentLine++
			if currentLine == line {
				return index + 1
			}
		}
	}
	if currentLine == line {
		return len(source)
	}
	return -1
}

func enumNameToDisplayName(name string) string {
	normalized := strings.ReplaceAll(strings.TrimSpace(name), "_", "")
	for _, candidate := range []string{"Warrior", "Cleric", "Paladin", "Ranger", "Shadow Knight", "Druid", "Monk", "Bard", "Rogue", "Shaman", "Necromancer", "Wizard", "Magician", "Enchanter", "Beastlord", "Berserker", "Human", "Barbarian", "Erudite", "Wood Elf", "High Elf", "Dark Elf", "Half Elf", "Dwarf", "Troll", "Ogre", "Halfling", "Gnome", "Iksar", "Vah Shir", "Froglok", "Drakkin"} {
		if strings.EqualFold(strings.ReplaceAll(candidate, " ", ""), normalized) {
			return candidate
		}
	}
	return name
}

func (r TurnInMatrixReport) Failures() []TurnInCaseResult {
	result := make([]TurnInCaseResult, 0)
	for _, candidate := range r.Results {
		if candidate.Err != nil || len(candidate.ValidationErrors) > 0 {
			result = append(result, candidate)
		}
	}
	return result
}

func (r TurnInMatrixReport) Summary() string {
	activated, inactive, missingAPI, failed, mismatched := r.StatusCounts()
	return fmt.Sprintf(
		"scripts=%d turn-in-scripts=%d discovered=%d cases=%d executed=%d activated=%d inactive=%d unsupported=%d missing-api=%d failed=%d mismatched=%d unmatched-overrides=%d",
		r.Scripts, r.ScriptsWithTurnIns, r.DiscoveredCases, len(r.Results), r.ExecutedCases, activated, inactive, len(r.Unsupported), missingAPI, failed, mismatched, len(r.UnmatchedOverrides),
	)
}

func (r TurnInMatrixReport) StatusCounts() (activated, inactive, missingAPI, failed, mismatched int) {
	for _, result := range r.Results {
		switch result.Status {
		case TurnInCaseActivated:
			activated++
		case TurnInCaseInactive:
			inactive++
		case TurnInCaseMissingAPI:
			missingAPI++
		case TurnInCaseMismatch:
			mismatched++
		default:
			if result.Err != nil {
				failed++
			}
		}
	}
	return activated, inactive, missingAPI, failed, mismatched
}

var missingLuaAPIRegexps = []*regexp.Regexp{
	regexp.MustCompile(`attempt to call method '([^']+)' \(a nil value\)`),
	regexp.MustCompile(`attempt to call field '([^']+)' \(a nil value\)`),
	regexp.MustCompile(`attempt to index global '([^']+)' \(a nil value\)`),
	regexp.MustCompile(`module ([^ ]+) not found`),
}

var luaErrorLineRE = regexp.MustCompile(`<string>:(\d+):`)
var luaCallOnLineRE = regexp.MustCompile(`([A-Za-z_][A-Za-z0-9_]*(?:(?:\.|:)[A-Za-z_][A-Za-z0-9_]*)*)\s*\(`)

func classifyMissingLuaAPI(err error, source string) string {
	if err == nil {
		return ""
	}
	message := err.Error()
	for _, pattern := range missingLuaAPIRegexps {
		if match := pattern.FindStringSubmatch(message); len(match) == 2 {
			return match[1]
		}
	}
	if strings.Contains(message, "attempt to call a non-function object") {
		if match := luaErrorLineRE.FindStringSubmatch(message); len(match) == 2 {
			line, _ := strconv.Atoi(match[1])
			calls := luaCallOnLineRE.FindAllStringSubmatch(sourceLine(source, line), -1)
			if len(calls) > 0 {
				return calls[len(calls)-1][1]
			}
		}
		return "unknown non-function call"
	}
	return ""
}

func scenarioEvent(script QuestScript, scenario TurnInScenario, playerOverride *TurnInPlayerOverride, globals map[string]string, npcOverride ...*turnInNPCOverride) *LuaEvent {
	player := &PlayerProxy{ID: 1, Name: "QuestMatrix", CharClass: "Warrior", CharRace: "Human", CharLevel: 60, ClassID: 1, RaceID: 1, Tasks: map[int]bool{}, Activities: map[string]bool{}, Inventory: map[int]bool{}}
	if playerOverride != nil {
		if playerOverride.Name != "" {
			player.Name = playerOverride.Name
		}
		if playerOverride.Class != "" {
			player.CharClass = playerOverride.Class
			player.ClassID = classIDByName(playerOverride.Class)
		}
		if playerOverride.Race != "" {
			player.CharRace = playerOverride.Race
			player.RaceID = raceIDByName(playerOverride.Race)
		}
		if playerOverride.Level != 0 {
			player.CharLevel = playerOverride.Level
		}
		player.X, player.Y, player.Z, player.Heading = playerOverride.X, playerOverride.Y, playerOverride.Z, playerOverride.Heading
		for _, taskID := range playerOverride.ActiveTasks {
			player.Tasks[taskID] = true
		}
		for _, activity := range playerOverride.ActiveTaskActivities {
			player.Activities[taskActivityKey(activity.TaskID, activity.ActivityID)] = true
			player.Tasks[activity.TaskID] = true
		}
		for _, itemID := range playerOverride.HasItems {
			player.Inventory[itemID] = true
		}
	}
	if globals == nil {
		globals = map[string]string{}
	}
	npc := &NPCProxy{ID: 1, Name: script.NPC, Race: player.RaceID}
	if len(npcOverride) > 0 && npcOverride[0] != nil {
		if npcOverride[0].NPCTypeID != 0 {
			npc.ID = npcOverride[0].NPCTypeID
		}
		if npcOverride[0].Race != 0 {
			npc.Race = npcOverride[0].Race
		}
		if npcOverride[0].Gender != nil {
			npc.Gender = *npcOverride[0].Gender
		}
		if npcOverride[0].X != nil {
			npc.X = *npcOverride[0].X
		}
		if npcOverride[0].Y != nil {
			npc.Y = *npcOverride[0].Y
		}
	}
	return &LuaEvent{
		NPC:    npc,
		Player: player,
		Trade: &TradeProxy{
			Items: append([]int(nil), scenario.Items...), Platinum: scenario.Currency.Platinum,
			Gold: scenario.Currency.Gold, Silver: scenario.Currency.Silver, Copper: scenario.Currency.Copper,
		},
		Globals: globals,
	}
}

func cloneTurnInPlayerOverride(player *TurnInPlayerOverride) *TurnInPlayerOverride {
	if player == nil {
		return nil
	}
	clone := *player
	clone.ActiveTasks = append([]int(nil), player.ActiveTasks...)
	clone.ActiveTaskActivities = append([]TurnInTaskActivity(nil), player.ActiveTaskActivities...)
	clone.HasItems = append([]int(nil), player.HasItems...)
	return &clone
}

func cloneStringMap(values map[string]string) map[string]string {
	if len(values) == 0 {
		return nil
	}
	clone := make(map[string]string, len(values))
	for key, value := range values {
		clone[key] = value
	}
	return clone
}

func turnInNPCPrerequisites(npc *turnInNPCOverride) *TurnInNPCPrerequisites {
	if npc == nil {
		return nil
	}
	return &TurnInNPCPrerequisites{
		NPCTypeID: npc.NPCTypeID,
		Race:      npc.Race,
		Gender:    cloneUint8Pointer(npc.Gender),
		X:         cloneFloat64Pointer(npc.X),
		Y:         cloneFloat64Pointer(npc.Y),
	}
}

func cloneUint8Pointer(value *uint8) *uint8 {
	if value == nil {
		return nil
	}
	clone := *value
	return &clone
}

func cloneFloat64Pointer(value *float64) *float64 {
	if value == nil {
		return nil
	}
	clone := *value
	return &clone
}

func taskActivityKey(taskID, activityID int) string {
	return fmt.Sprintf("%d:%d", taskID, activityID)
}

func classIDByName(name string) uint8 {
	for id, candidate := range []string{"", "Warrior", "Cleric", "Paladin", "Ranger", "Shadow Knight", "Druid", "Monk", "Bard", "Rogue", "Shaman", "Necromancer", "Wizard", "Magician", "Enchanter", "Beastlord", "Berserker"} {
		if strings.EqualFold(strings.ReplaceAll(candidate, " ", ""), strings.ReplaceAll(name, " ", "")) {
			return uint8(id)
		}
	}
	return 0
}

func raceIDByName(name string) uint16 {
	for id, candidate := range []string{"", "Human", "Barbarian", "Erudite", "Wood Elf", "High Elf", "Dark Elf", "Half Elf", "Dwarf", "Troll", "Ogre", "Halfling", "Gnome", "Iksar", "Vah Shir", "Froglok", "Drakkin"} {
		if strings.EqualFold(strings.ReplaceAll(candidate, " ", ""), strings.ReplaceAll(name, " ", "")) {
			return uint16(id)
		}
	}
	return 0
}

func matchingOverrides(script QuestScript, scenario TurnInScenario, overrides []TurnInScenarioOverride, matched []bool) []TurnInScenarioOverride {
	return matchingOverrideSelector(script, scenario.CallIndex, scenario.Line, overrides, matched)
}

func matchingOverrideSelector(script QuestScript, callIndex, line int, overrides []TurnInScenarioOverride, matched []bool) []TurnInScenarioOverride {
	var result []TurnInScenarioOverride
	for index, override := range overrides {
		if !strings.EqualFold(override.Zone, script.Zone) || !strings.EqualFold(override.NPC, script.NPC) {
			continue
		}
		if override.CallIndex != nil && *override.CallIndex != callIndex {
			continue
		}
		if override.Line != nil && *override.Line != line {
			continue
		}
		matched[index] = true
		result = append(result, override)
	}
	return result
}

func turnInCaptureActivated(capture *QuestCapture, scenario TurnInScenario) bool {
	if capture == nil {
		return false
	}
	if len(capture.Responses) > 0 || capture.Exp != 0 || len(capture.Factions) > 0 ||
		len(capture.Items) > 0 || capture.Currency != (QuestCurrency{}) || capture.Ding ||
		len(capture.Signals) > 0 || len(capture.Globals) > 0 || len(capture.Timers) > 0 ||
		len(capture.Tasks) > 0 || len(capture.Popups) > 0 || len(capture.Spells) > 0 || len(capture.Spawns) > 0 {
		return true
	}
	if capture.CurrentTrade == nil {
		return false
	}
	return len(capture.CurrentTrade.Items) < len(scenario.Items) ||
		capture.CurrentTrade.Platinum < scenario.Currency.Platinum ||
		capture.CurrentTrade.Gold < scenario.Currency.Gold ||
		capture.CurrentTrade.Silver < scenario.Currency.Silver ||
		capture.CurrentTrade.Copper < scenario.Currency.Copper
}
