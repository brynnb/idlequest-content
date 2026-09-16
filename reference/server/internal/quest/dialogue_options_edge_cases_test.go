package quest

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestExtractKeywordsDeduplicatesCaseInsensitivelyInFirstSeenOrder(t *testing.T) {
	service := &Service{}
	options := service.extractKeywords("Ask about [Ancient History], [the seal], or [ancient history].")
	assert.Equal(t, []DialogueOption{
		{Text: "Ancient History", Keyword: "Ancient History"},
		{Text: "the seal", Keyword: "the seal"},
	}, options)
}

func TestExtractKeywordsPreservesPunctuationAndNestedDisplayText(t *testing.T) {
	service := &Service{}
	options := service.extractKeywords("Choose [who are you?] and [Seal #4: broken].")
	assert.Equal(t, []DialogueOption{
		{Text: "who are you?", Keyword: "who are you?"},
		{Text: "Seal #4: broken", Keyword: "Seal #4: broken"},
	}, options)
}

func TestExtractKeywordsIgnoresUnclosedAndEmptyBrackets(t *testing.T) {
	service := &Service{}
	assert.Empty(t, service.extractKeywords("No [closed option and [] here."))
}

func TestExtractKeywordsNormalizesAccidentalOuterWhitespace(t *testing.T) {
	service := &Service{}
	assert.Equal(t,
		[]DialogueOption{{Text: "ancient history", Keyword: "ancient history"}},
		service.extractKeywords("Ask about [  ancient history  ]."),
	)
}

func TestExtractScriptBranchesExcludesHailAndDeduplicatesCaseInsensitively(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `
if e.message:findi("hail") then end
if e.message:findi("history") then end
if e.message:findi("HISTORY") then end
if e.message:findi("seal") then end`
	assert.Equal(t, []DialogueOption{
		{Text: "history", Keyword: "history"},
		{Text: "seal", Keyword: "seal"},
	}, discoverOptionsForTest(t, bridge, source))
}

func TestExtractScriptBranchesSupportsLuaQuoteAndSpacingVariants(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `
if e.message:findi('history') then end
if e.message:findi ("seal") then end
if e.message:findi( "final step" ) then end`
	assert.Equal(t, []DialogueOption{
		{Text: "history", Keyword: "history"},
		{Text: "seal", Keyword: "seal"},
		{Text: "final step", Keyword: "final step"},
	}, discoverOptionsForTest(t, bridge, source))
}

func TestExtractScriptBranchesIgnoresCommentsAndNonSayHandlers(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `
function event_say(e)
  -- if e.message:findi("disabled") then end
  if e.message:findi("active") then end
end
function event_timer(e)
  local debug_text = 'findi("not dialogue")'
end`
	assert.Equal(t,
		[]DialogueOption{{Text: "active", Keyword: "active"}},
		discoverOptionsForTest(t, bridge, source),
	)
}

func TestExtractScriptBranchesDoesNotAdvertiseFactionOrLevelGatedOptions(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `
function event_say(e)
  if e.other:GetLevel() >= 50 and e.other:GetModCharacterFactionLevel(404) >= 1800 then
    if e.message:findi("secret trial") then e.self:Say("Accepted") end
  end
end`
	assert.Empty(t, discoverOptionsForTest(t, bridge, source), "static branch discovery must not expose a keyword the current player may be forbidden to use")
}

func TestExtractScriptBranchesIncludesTopLevelElseIfConversationBranches(t *testing.T) {
	bridge := NewLuaBridge(".")
	source := `
function event_say(e)
  if e.message:findi("hail") then
    e.self:Say("Ask about [mail]")
  elseif e.message:findi("i am interested") then
    e.self:Say("Interested response")
  elseif e.message:findi("what mail") then
    e.self:Say("Mail response")
  end
end`
	assert.Equal(t, []DialogueOption{
		{Text: "i am interested", Keyword: "i am interested"},
		{Text: "what mail", Keyword: "what mail"},
	}, discoverOptionsForTest(t, bridge, source))
}

func TestResolveDialogueKeywordUsesOnlyUnambiguousExpandedTrigger(t *testing.T) {
	branches := []DialogueOption{
		{Text: "what mail", Keyword: "what mail"},
		{Text: "i am interested", Keyword: "i am interested"},
		{Text: "no house", Keyword: "no house"},
		{Text: "house of pancakes", Keyword: "house of pancakes"},
	}
	assert.Equal(t, "what mail", resolveDialogueKeyword("mail", branches))
	assert.Equal(t, "i am interested", resolveDialogueKeyword("interested", branches))
	assert.Equal(t, "house", resolveDialogueKeyword("house", branches))
}

func TestDialogueShorthandDoesNotMatchInsideAnotherWord(t *testing.T) {
	for _, pair := range [][2]string{{"us", "an illusion"}, {"war", "reward"}, {"art", "artifact"}} {
		branches := []DialogueOption{{Text: pair[1], Keyword: pair[1]}}
		assert.Equal(t, pair[0], resolveDialogueKeyword(pair[0], branches))
		assert.Contains(t, mergeDialogueOptions([]DialogueOption{{Text: pair[0], Keyword: pair[0]}}, branches), DialogueOption{Text: pair[0], Keyword: pair[0]})
	}
}

func TestMergeDialogueOptionsMapsUniqueShorthandAndReplacesAmbiguousPrompt(t *testing.T) {
	primary := []DialogueOption{
		{Text: "mail", Keyword: "mail"},
		{Text: "house", Keyword: "house"},
	}
	secondary := []DialogueOption{
		{Text: "what mail", Keyword: "what mail"},
		{Text: "no house", Keyword: "no house"},
		{Text: "house of pancakes", Keyword: "house of pancakes"},
	}
	assert.Equal(t, []DialogueOption{
		{Text: "mail", Keyword: "what mail"},
		{Text: "no house", Keyword: "no house"},
		{Text: "house of pancakes", Keyword: "house of pancakes"},
	}, mergeDialogueOptions(primary, secondary))
}

func TestMergeKeywordsPreservesRenderedOptionsBeforeDiscoveredBranches(t *testing.T) {
	primary := []DialogueOption{
		{Text: "The Seal", Keyword: "the seal"},
		{Text: "History", Keyword: "history"},
	}
	secondary := []DialogueOption{
		{Text: "THE SEAL", Keyword: "THE SEAL"},
		{Text: "final", Keyword: "final"},
	}
	assert.Equal(t, []DialogueOption{
		{Text: "The Seal", Keyword: "the seal"},
		{Text: "History", Keyword: "history"},
		{Text: "final", Keyword: "final"},
	}, mergeKeywords(primary, secondary))
}

func TestMergeKeywordsHandlesEmptySidesWithoutInventingOptions(t *testing.T) {
	option := DialogueOption{Text: "history", Keyword: "history"}
	assert.Equal(t, []DialogueOption{option}, mergeKeywords(nil, []DialogueOption{option}))
	assert.Equal(t, []DialogueOption{option}, mergeKeywords([]DialogueOption{option}, nil))
	assert.Empty(t, mergeKeywords(nil, nil))
}

func TestMergeKeywordsDropsDuplicateEntriesWithinEachInput(t *testing.T) {
	duplicate := []DialogueOption{
		{Text: "History", Keyword: "history"},
		{Text: "HISTORY", Keyword: "HISTORY"},
	}
	assert.Equal(t, []DialogueOption{{Text: "History", Keyword: "history"}}, mergeKeywords(duplicate, duplicate))
}
