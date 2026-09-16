package quest

import (
	"fmt"
	"regexp"
	"sort"
	"strconv"
	"strings"
)

// TurnInScenario is an exact, statically discoverable item_lib.check_turn_in
// invocation. It is intentionally limited to literal numeric requirements. Lua
// branches that calculate requirements at runtime are reported separately rather
// than guessed at by the test harness.
type TurnInScenario struct {
	Line      int
	Items     []int
	Currency  QuestCurrency
	Source    string
	CallIndex int
}

// TurnInDiscovery describes both the cases the harness can execute and calls it
// found but could not safely turn into deterministic input.
type TurnInDiscovery struct {
	Scenarios   []TurnInScenario
	Unsupported []UnsupportedTurnIn
}

type UnsupportedTurnIn struct {
	Line      int
	CallIndex int
	Source    string
	Reason    string
}

var (
	checkTurnInCallRE = regexp.MustCompile(`(?i)(?:item_lib\s*\.\s*)?check_turn_in\s*\(`)
	literalFieldRE    = regexp.MustCompile(`(?i)([a-z_][a-z0-9_]*)\s*=\s*(-?[0-9]+)\b`)
	localNumberRE     = regexp.MustCompile(`(?mi)^\s*local\s+([a-z_][a-z0-9_]*)\s*=\s*([0-9]+)\s*;?`)
	identifierValueRE = regexp.MustCompile(`(?i)([a-z_][a-z0-9_]*\s*=\s*)([a-z_][a-z0-9_]*)\b`)
	numericOrRE       = regexp.MustCompile(`\(\s*([0-9]+)\s+or\s+([0-9]+)\s*\)`)
)

// DiscoverTurnInScenarios extracts literal requirements from the common EQEmu
// item_lib.check_turn_in(e.trade, {...}) form. It uses balanced-delimiter
// scanning so multiline tables and nested expressions do not confuse later
// calls in the same script.
func DiscoverTurnInScenarios(source string) TurnInDiscovery {
	source = normalizeLegacyTurnInCurrencySyntax(source)
	var result TurnInDiscovery
	matches := checkTurnInCallRE.FindAllStringIndex(source, -1)
	constants := literalLuaNumberConstants(source)
	for callIndex, match := range matches {
		if luaSourcePositionIsCommented(source, match[0]) {
			continue
		}
		line := 1 + strings.Count(source[:match[0]], "\n")
		openBrace := findRequirementTableStart(source, match[1])
		if openBrace < 0 {
			result.Unsupported = append(result.Unsupported, UnsupportedTurnIn{
				Line: line, CallIndex: callIndex, Source: sourceLine(source, line), Reason: "requirement table is not a literal table",
			})
			continue
		}

		closeBrace := findBalancedClose(source, openBrace, '{', '}')
		if closeBrace < 0 {
			result.Unsupported = append(result.Unsupported, UnsupportedTurnIn{
				Line: line, CallIndex: callIndex, Source: sourceLine(source, line), Reason: "requirement table is not balanced",
			})
			continue
		}

		tableSource := source[openBrace : closeBrace+1]
		expanded := expandTurnInRequirementTable(tableSource, source, constants)
		parsed := false
		var lastReason string
		for _, candidate := range expanded {
			scenario, reason := parseLiteralTurnInTable(candidate)
			if reason != "" {
				lastReason = reason
				continue
			}
			scenario.Line = line
			scenario.Source = compactLua(candidate)
			scenario.CallIndex = callIndex
			result.Scenarios = append(result.Scenarios, scenario)
			parsed = true
		}
		if !parsed {
			result.Unsupported = append(result.Unsupported, UnsupportedTurnIn{
				Line: line, CallIndex: callIndex, Source: compactLua(tableSource), Reason: lastReason,
			})
		}
	}
	return result
}

func literalLuaNumberConstants(source string) map[string]string {
	result := map[string]string{}
	for _, match := range localNumberRE.FindAllStringSubmatch(source, -1) {
		result[strings.ToLower(match[1])] = match[2]
	}
	return result
}

func expandTurnInRequirementTable(tableSource, fullSource string, constants map[string]string) []string {
	resolved := identifierValueRE.ReplaceAllStringFunc(tableSource, func(field string) string {
		parts := identifierValueRE.FindStringSubmatch(field)
		if value, ok := constants[strings.ToLower(parts[2])]; ok {
			return parts[1] + value
		}
		return field
	})
	if match := numericOrRE.FindStringSubmatchIndex(resolved); match != nil {
		return []string{resolved[:match[0]] + resolved[match[2]:match[3]] + resolved[match[1]:], resolved[:match[0]] + resolved[match[4]:match[5]] + resolved[match[1]:]}
	}
	if strings.Contains(strings.ToLower(resolved), "riddle.item") {
		itemRE := regexp.MustCompile(`(?i)\bitem\s*=\s*([0-9]+)`)
		seen := map[string]bool{}
		var result []string
		for _, match := range itemRE.FindAllStringSubmatch(fullSource, -1) {
			if !seen[match[1]] {
				seen[match[1]] = true
				result = append(result, strings.ReplaceAll(resolved, "riddle.item", match[1]))
			}
		}
		if len(result) > 0 {
			return result
		}
	}
	return []string{resolved}
}

func luaSourcePositionIsCommented(source string, position int) bool {
	lineStart := strings.LastIndex(source[:position], "\n") + 1
	prefix := strings.TrimSpace(source[lineStart:position])
	return strings.HasPrefix(prefix, "--")
}

func parseLiteralTurnInTable(tableSource string) (TurnInScenario, string) {
	fields := literalFieldRE.FindAllStringSubmatch(tableSource, -1)
	if len(fields) == 0 {
		return TurnInScenario{}, "requirement table has no literal numeric fields"
	}

	// Remove fields, punctuation, whitespace, and comments. Anything left means
	// the table contains an expression the harness must not pretend to understand.
	remainder := literalFieldRE.ReplaceAllString(tableSource, "")
	remainder = regexp.MustCompile(`--[^\n]*`).ReplaceAllString(remainder, "")
	remainder = strings.Map(func(r rune) rune {
		if strings.ContainsRune("{},; \t\r\n", r) {
			return -1
		}
		return r
	}, remainder)
	if remainder != "" {
		return TurnInScenario{}, fmt.Sprintf("requirement table contains a dynamic expression (%s)", remainder)
	}

	var scenario TurnInScenario
	itemSlots := make(map[int]int)
	for _, field := range fields {
		name := strings.ToLower(field[1])
		value, _ := strconv.Atoi(field[2])
		if value < 0 {
			return TurnInScenario{}, fmt.Sprintf("requirement %s is negative", name)
		}
		switch name {
		case "platinum":
			scenario.Currency.Platinum = value
		case "gold":
			scenario.Currency.Gold = value
		case "silver":
			scenario.Currency.Silver = value
		case "copper":
			scenario.Currency.Copper = value
		default:
			if !strings.HasPrefix(name, "item") {
				return TurnInScenario{}, fmt.Sprintf("unknown requirement field %s", name)
			}
			slot, err := strconv.Atoi(strings.TrimPrefix(name, "item"))
			if err != nil || slot < 1 {
				return TurnInScenario{}, fmt.Sprintf("invalid item field %s", name)
			}
			itemSlots[slot] = value
		}
	}

	keys := make([]int, 0, len(itemSlots))
	for slot := range itemSlots {
		keys = append(keys, slot)
	}
	sort.Ints(keys)
	for _, slot := range keys {
		scenario.Items = append(scenario.Items, itemSlots[slot])
	}
	if len(scenario.Items) == 0 && scenario.Currency == (QuestCurrency{}) {
		return TurnInScenario{}, "requirement table is empty"
	}
	return scenario, ""
}

func findRequirementTableStart(source string, start int) int {
	comma := findTopLevelDelimiter(source, start, ',')
	if comma < 0 {
		return -1
	}
	for i := comma + 1; i < len(source); i++ {
		switch source[i] {
		case ' ', '\t', '\r', '\n':
			continue
		case '{':
			return i
		default:
			return -1
		}
	}
	return -1
}

func findTopLevelDelimiter(source string, start int, wanted byte) int {
	depth := 0
	quote := byte(0)
	for i := start; i < len(source); i++ {
		c := source[i]
		if quote != 0 {
			if c == '\\' {
				i++
				continue
			}
			if c == quote {
				quote = 0
			}
			continue
		}
		if c == '\'' || c == '"' {
			quote = c
			continue
		}
		if c == '(' {
			depth++
			continue
		}
		if c == ')' {
			if depth == 0 {
				return -1
			}
			depth--
			continue
		}
		if c == wanted && depth == 0 {
			return i
		}
	}
	return -1
}

func findBalancedClose(source string, open int, opening, closing byte) int {
	depth := 0
	quote := byte(0)
	for i := open; i < len(source); i++ {
		c := source[i]
		if quote != 0 {
			if c == '\\' {
				i++
				continue
			}
			if c == quote {
				quote = 0
			}
			continue
		}
		if c == '\'' || c == '"' {
			quote = c
			continue
		}
		if c == opening {
			depth++
		}
		if c == closing {
			depth--
			if depth == 0 {
				return i
			}
		}
	}
	return -1
}

func compactLua(source string) string { return strings.Join(strings.Fields(source), " ") }

func sourceLine(source string, line int) string {
	lines := strings.Split(source, "\n")
	if line < 1 || line > len(lines) {
		return ""
	}
	return strings.TrimSpace(lines[line-1])
}
