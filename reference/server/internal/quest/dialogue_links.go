package quest

import (
	"regexp"
	"strings"
)

// Shorthand must be a complete phrase, not letters inside an unrelated word:
// mapping "us" to "an illusion" changes the player's chosen response.
func dialogueContainsPhrase(branch, phrase string) bool {
	phrase = strings.TrimSpace(phrase)
	if phrase == "" {
		return false
	}
	return regexp.MustCompile(`(?i)(^|[^\p{L}\p{N}_])` + regexp.QuoteMeta(phrase) + `($|[^\p{L}\p{N}_])`).MatchString(branch)
}

// Hand-ins have their own response links. Refreshing reachable branches after
// settlement must not replace those links with the NPC's unrelated hail text.
func (s *Service) applyTurnInDialogue(info *QuestNPCInfo, response string, capture *QuestCapture) {
	if info == nil || capture == nil {
		return
	}
	info.Greeting = response
	info.AvailableOptions = mergeDialogueOptions(s.captureDialogueOptions(response, capture), info.AvailableOptions)
	info.HasDialogue = strings.TrimSpace(response) != "" || len(info.AvailableOptions) > 0
}

// Explicit eq.say_link labels carry an authored response, unlike ordinary
// bracket text. Preserve that response before applying inferred shorthand.
// Captures are event-local: never reuse another NPC's or prior reply's aliases.
func (s *Service) captureDialogueOptions(greeting string, capture *QuestCapture) []DialogueOption {
	options := s.extractKeywords(greeting)
	if capture == nil {
		return options
	}
	for i := range options {
		var matches []DialogueOption
		for _, link := range capture.SayLinks {
			if strings.EqualFold(strings.TrimSpace(link.Text), options[i].Text) && strings.TrimSpace(link.Keyword) != "" {
				matches = mergeKeywords(matches, []DialogueOption{link})
			}
		}
		if len(matches) == 1 {
			options[i].Keyword = matches[0].Keyword
		} else if len(matches) > 1 {
			// Conflicting authored labels must not silently choose one action.
			// Offer the exact response phrases as separate choices instead.
			options[i].Keyword = ""
			for _, match := range matches {
				options = append(options, DialogueOption{Text: match.Keyword, Keyword: match.Keyword})
			}
		}
	}
	var result []DialogueOption
	for _, option := range options {
		if option.Keyword != "" {
			result = append(result, option)
		}
	}
	return mergeKeywords(nil, result)
}
