// Package questluasource is the shared, side-effect-free source preparation used
// by the live quest bridge and the content repository's syntax checker.
package questluasource

import (
	"regexp"
	"strings"

	lua "github.com/yuin/gopher-lua"
	"github.com/yuin/gopher-lua/parse"
)

var legacyTurnInCurrencyPattern = regexp.MustCompile(`([,{]\s*)(?:e\.)?(platinum|gold|silver|copper)\s*==\s*(\d+)(\s*[,}])`)
var legacyStringClassComparisonPattern = regexp.MustCompile(`(:)Class(\s*\(\s*\)\s*==\s*["'])`)
var legacyStringRaceComparisonPattern = regexp.MustCompile(`(:)Race(\s*\(\s*\)\s*==\s*["'])`)
var legacyLocalClassAssignmentPattern = regexp.MustCompile(`(?m)(local\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*e\.other:)Class(\s*\(\s*\))`)
var legacyLocalRaceAssignmentPattern = regexp.MustCompile(`(?m)(local\s+([A-Za-z_][A-Za-z0-9_]*)\s*=\s*e\.other:)Race(\s*\(\s*\))`)

// Normalize retains the bridge's legacy conversion compatibility. New volunteer
// Lua should use normal syntax, but validation must accept exactly what runs.
func Normalize(source string) string {
	source = legacyTurnInCurrencyPattern.ReplaceAllString(source, `${1}${2} = ${3}${4}`)
	source = legacyStringClassComparisonPattern.ReplaceAllString(source, `${1}GetClassName${2}`)
	source = legacyStringRaceComparisonPattern.ReplaceAllString(source, `${1}GetRaceName${2}`)
	source = normalizeLegacyStringLocalAssignment(source, legacyLocalClassAssignmentPattern, "GetClassName")
	source = normalizeLegacyStringLocalAssignment(source, legacyLocalRaceAssignmentPattern, "GetRaceName")
	source = strings.ReplaceAll(source, "eq.get_entity_list():GetClientList().entries", "eq.get_entity_list():GetClientEntries()")
	source = strings.ReplaceAll(source, "eq.get_entity_list():GetNPCList().entries", "eq.get_entity_list():GetNPCEntries()")
	lines := strings.Split(source, "\n")
	for index, line := range lines {
		trimmed := strings.TrimSpace(line)
		if strings.HasPrefix(trimmed, "#") && !strings.HasPrefix(trimmed, "#!") {
			indent := line[:len(line)-len(strings.TrimLeft(line, " \t"))]
			lines[index] = indent + "--" + strings.TrimPrefix(trimmed, "#")
		}
	}
	return strings.Join(lines, "\n")
}

func normalizeLegacyStringLocalAssignment(source string, pattern *regexp.Regexp, replacementMethod string) string {
	return pattern.ReplaceAllStringFunc(source, func(assignment string) string {
		match := pattern.FindStringSubmatch(assignment)
		if len(match) < 4 {
			return assignment
		}
		localName := match[2]
		stringComparison := regexp.MustCompile(`\b` + regexp.QuoteMeta(localName) + `\s*==\s*["']`)
		if !stringComparison.MatchString(source) {
			return assignment
		}
		return match[1] + replacementMethod + match[3]
	})
}

// Validate compiles but never executes source. Modules are loaded unnormalized
// by the live bridge, whereas NPC event scripts pass through Normalize.
func Validate(name, source string, module bool) error {
	if !module {
		source = Normalize(source)
	}
	chunk, err := parse.Parse(strings.NewReader(source), name)
	if err != nil {
		return err
	}
	_, err = lua.Compile(chunk, name)
	return err
}
