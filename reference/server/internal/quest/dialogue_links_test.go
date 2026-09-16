package quest

import (
	"os"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestTurnInRetainsAuthoredResponseLink(t *testing.T) {
	source, err := os.ReadFile("upstream/projecteq/emeraldjungle/Spirit_Sentinel.lua")
	require.NoError(t, err)
	bridge := NewLuaBridge("upstream/projecteq")
	e := progressionEvent(PlayerProxy{ID: 123, Name: "QuestTester", CharClass: "Shaman", CharLevel: 50})
	e.Trade = &TradeProxy{Items: []int{1668}}
	capture, err := bridge.ExecuteTradeFromSource(string(source), e)
	require.NoError(t, err)
	branches, err := bridge.DiscoverDialogueOptions(string(source), e)
	require.NoError(t, err)
	info := &QuestNPCInfo{Greeting: "The NPC remains silent.", AvailableOptions: branches}
	response := strings.Join(capture.Responses, "\n")
	(&Service{}).applyTurnInDialogue(info, response, capture)
	require.Equal(t, response, info.Greeting)
	link := DialogueOption{Text: "continue what you have started", Keyword: "continue what I have started"}
	require.Contains(t, info.AvailableOptions, link)
	e.Message = link.Keyword
	reply, err := bridge.ExecuteSayFromSource(string(source), e)
	require.NoError(t, err)
	require.Contains(t, strings.Join(reply.Responses, "\n"), "walk one more path")
}

func TestShamanSrafenUsLinkSurvivesDiscoveryAndRouting(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "erudsxing", "Srafen_the_Soaked")
	bridge := NewLuaBridge("upstream/projecteq")
	event := progressionEvent(PlayerProxy{ID: 123, Name: "Shaman", CharClass: "Shaman"})
	event.Message = "hail"
	capture, err := bridge.ExecuteSayFromSource(source, event)
	require.NoError(t, err)
	branches, err := bridge.DiscoverDialogueOptions(source, event)
	require.NoError(t, err)
	options := mergeDialogueOptions((&Service{}).captureDialogueOptions(strings.Join(capture.Responses, "\n"), capture), branches)
	require.Contains(t, options, DialogueOption{Text: "us", Keyword: "us"})
	event.Message = resolveDialogueKeyword("us", branches)
	reply, err := bridge.ExecuteSayFromSource(source, event)
	require.NoError(t, err)
	require.Contains(t, strings.Join(reply.Responses, "\n"), "there's me, Srafen")
}

func TestShamanLesserSpiritsExplainWhereToTakeGem(t *testing.T) {
	for _, zone := range []string{"rathemtn", "fieldofbone", "oot", "oceanoftears", "butcher"} {
		e := progressionEvent(PlayerProxy{ID: 123, Name: "QuestTester", CharClass: "Shaman", CharLevel: 50})
		e.Message = "know more"
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(readOverrideLua(t, "modified-upstream", zone, "a_lesser_spirit"), e)
		require.NoError(t, err, zone)
		require.Contains(t, strings.Join(capture.Responses, "\n"), "Some call it a port", zone)
		require.Equal(t, []QuestReward{{ItemID: 1665, Count: 1}}, capture.Items, zone)
	}
}

func TestAuthoredSayLinkPreservesResponseThroughDiscovery(t *testing.T) {
	bridge := NewLuaBridge("upstream/projecteq")
	service := &Service{}
	source := readOverrideLua(t, "modified-upstream", "highpass", "Stanos_Herkanor")
	for _, tc := range []struct{ request, label, keyword, response string }{
		{"hanns", "my head", "your head", "Hanns has wanted me dead for years"},
		{"tools", "clear my name", "clear your name", "Steal them both"},
	} {
		event := progressionEvent(PlayerProxy{ID: 123, Name: "Rogue", CharClass: "Rogue"})
		event.Message = tc.request
		capture, err := bridge.ExecuteSayFromSource(source, event)
		require.NoError(t, err)
		branches, err := bridge.DiscoverDialogueOptions(source, event)
		require.NoError(t, err)
		options := mergeDialogueOptions(service.captureDialogueOptions(strings.Join(capture.Responses, "\n"), capture), branches)
		require.Contains(t, options, DialogueOption{Text: tc.label, Keyword: tc.keyword})
		event.Message = tc.keyword
		response, err := bridge.ExecuteSayFromSource(source, event)
		require.NoError(t, err)
		require.Contains(t, strings.Join(response.Responses, "\n"), tc.response)
	}
}

func TestAuthoredSayLinksAreCaptureLocalAndMergeWithEffects(t *testing.T) {
	s := &Service{}
	capture := NewQuestCapture()
	mergeQuestCapture(capture, &QuestCapture{SayLinks: []DialogueOption{{Text: "my head", Keyword: "your head"}}})
	require.Equal(t, []DialogueOption{{Text: "my head", Keyword: "your head"}}, s.captureDialogueOptions("[my head]", capture))
	require.Equal(t, []DialogueOption{{Text: "my head", Keyword: "my head"}}, s.captureDialogueOptions("[my head]", NewQuestCapture()))
	require.Empty(t, s.captureDialogueOptions("No option emitted", capture))
}

func TestConflictingSayLinkLabelsOfferExactResponses(t *testing.T) {
	s := &Service{}
	capture := &QuestCapture{SayLinks: []DialogueOption{
		{Text: "choice", Keyword: "first response"},
		{Text: "choice", Keyword: "second response"},
		{Text: "choice", Keyword: "first response"},
	}}
	require.Equal(t, []DialogueOption{
		{Text: "first response", Keyword: "first response"},
		{Text: "second response", Keyword: "second response"},
	}, s.captureDialogueOptions("[choice]", capture))
}
