package quest

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestRogueEpicRestoredDialogueAndSignal(t *testing.T) {
	bridge := NewLuaBridge("upstream/projecteq")
	e := progressionEvent(PlayerProxy{ID: 123, CharClass: "Rogue", CharLevel: 50})
	e.Message = "Eldreth sent me"
	capture, err := bridge.ExecuteSayFromSource(readOverrideLua(t, "converted-perl", "steamfont", "Yendar_Starpyre"), e)
	require.NoError(t, err)
	require.Contains(t, strings.Join(capture.Responses, " "), "rather shabby Erudite")
	e.Message = "hail"
	capture, err = bridge.ExecuteSayFromSource(readOverrideLua(t, "modified-upstream", "highpass", "Stanos_Herkanor"), e)
	require.NoError(t, err)
	require.Len(t, capture.Signals, 1)
	require.Equal(t, 5037, capture.Signals[0].NPCID)
}

func TestRogueQeynosStoryResponsesPreserveSeparatePackageQuest(t *testing.T) {
	for _, tc := range []struct{ npc, phrase, response string }{
		{"Hanns_Krieghor", "stanos", "Do not speak to him, do not attack him"},
		{"Renux_Herkanor", "stanos", "time to make my choices"},
		{"Renux_Herkanor", "hail", "just browsing"},
		{"Renux_Herkanor", "lomarc", "small time smuggler"},
		{"Zannsin_Resdinet", "renux", "second in command"},
		{"Zannsin_Resdinet", "hanns", "Circle quickly took any market opposition"},
	} {
		event := progressionEvent(PlayerProxy{ID: 123, CharClass: "Rogue", CharLevel: 50})
		event.Message = tc.phrase
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(readOverrideLua(t, "modified-upstream", "qeynos2", tc.npc), event)
		require.NoError(t, err)
		require.Contains(t, strings.Join(capture.Responses, " "), tc.response)
		require.Empty(t, capture.Items)
	}
}

func TestZannsinStoryAdditionPreservesPrakLetter(t *testing.T) {
	event := progressionEvent(PlayerProxy{ID: 123, CharClass: "Rogue", CharLevel: 50})
	event.Message = "send men to Prak in Highpass"
	capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(readOverrideLua(t, "modified-upstream", "qeynos2", "Zannsin_Resdinet"), event)
	require.NoError(t, err)
	require.Equal(t, []QuestReward{{ItemID: 18795, Count: 1}}, capture.Items)
	require.Contains(t, strings.Join(capture.Responses, " "), "Golden Rooster")
}

func TestVilniusSpecificDelayedPhrasePrecedesMalka(t *testing.T) {
	event := progressionEvent(PlayerProxy{ID: 123, CharClass: "Rogue", CharLevel: 50})
	for phrase, response := range map[string]string{"Malka will be delayed": "several days overdue", "malka": "One of the best thieves"} {
		event.Message = phrase
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(readOverrideLua(t, "modified-upstream", "qey2hh1", "Vilnius_the_Small"), event)
		require.NoError(t, err)
		require.Contains(t, strings.Join(capture.Responses, " "), response)
	}
}

func TestCyanelleDirectionsOnlyWhenEldrethAbsent(t *testing.T) {
	for _, present := range []bool{false, true} {
		event := progressionEvent(PlayerProxy{ID: 123, CharClass: "Rogue", CharLevel: 50})
		event.Message = "Where is Eldreth?"
		if present {
			event.VisibleNPCTypeIDs = []int32{51025}
		}
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(readOverrideLua(t, "converted-perl", "lakerathe", "Cyanelle"), event)
		require.NoError(t, err)
		if present {
			require.Empty(t, capture.Responses)
		} else {
			require.Contains(t, strings.Join(capture.Responses, " "), "Eldreth is not here right now")
		}
		require.Empty(t, capture.Items)
	}
}

func TestEldrethDepartsOnlyAfterCompleteTranslationPayment(t *testing.T) {
	for _, milk := range []int{1, 2} {
		e := progressionEvent(PlayerProxy{ID: 123, CharClass: "Rogue", CharLevel: 50})
		e.Trade = &TradeProxy{Items: []int{28012, 1001}, Platinum: 100}
		for i := 0; i < milk; i++ {
			e.Trade.Items = append(e.Trade.Items, 13087)
		}
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(readOverrideLua(t, "converted-perl", "lakerathe", "Eldreth"), e)
		require.NoError(t, err)
		if milk == 2 {
			require.Equal(t, []QuestReward{{ItemID: 28053, Count: 1}}, capture.Items)
			require.Len(t, capture.Depops, 1)
			require.Equal(t, []int{1001}, capture.CurrentTrade.Items)
			require.Zero(t, capture.CurrentTrade.Platinum)
		} else {
			require.Empty(t, capture.Items)
			require.Empty(t, capture.Depops)
			require.Equal(t, []int{28012, 1001, 13087}, capture.CurrentTrade.Items)
			require.Equal(t, 100, capture.CurrentTrade.Platinum)
		}
	}
}

func TestAnsonEligibilityPreservesRejectedPouch(t *testing.T) {
	for _, tc := range []struct {
		class  string
		level  int
		accept bool
	}{{"Rogue", 1, true}, {"Rogue", 9, true}, {"Rogue", 49, true}, {"Warrior", 1, false}, {"Warrior", 50, false}, {"Rogue", 50, true}} {
		e := progressionEvent(PlayerProxy{ID: 123, CharClass: tc.class, CharLevel: tc.level})
		e.Trade = &TradeProxy{Items: []int{28014}}
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(readOverrideLua(t, "modified-upstream", "highpass", "Anson_McBale"), e)
		require.NoError(t, err)
		if tc.accept {
			require.Len(t, capture.Spawns, 1)
			require.Empty(t, capture.CurrentTrade.Items)
		} else {
			require.Empty(t, capture.Spawns)
			require.Equal(t, []int{28014}, capture.CurrentTrade.Items, "%s level%d must keep pouch", tc.class, tc.level)
		}
	}
}

func TestRogueEpicAllKithicorAidesAcceptOnlySealedBox(t *testing.T) {
	// P99 explicitly permits any dark elf in the cabin (not their pets).
	// Exercise the actual seven bundled scripts; the UI suite covers two aides.
	for _, name := range []string{"#Adjutant_D-kan", "#Advisor_C-zatl", "#Brigadier_G-tav", "#Coercer_Q-ioul", "#Ioltos_V-ghera", "#Tasi_V-ghera", "#War_Priestess_T-zan"} {
		t.Run(name, func(t *testing.T) {
			source := readOverrideLua(t, "converted-perl", "kithicor", name)
			for _, sealedBox := range []bool{false, true} {
				e := progressionEvent(PlayerProxy{ID: 123, CharClass: "Rogue", CharLevel: 50})
				e.Trade = &TradeProxy{Items: []int{1001}}
				if sealedBox {
					e.Trade.Items = append(e.Trade.Items, 28057)
				}
				capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(source, e)
				require.NoError(t, err)
				require.Equal(t, []int{1001}, capture.CurrentTrade.Items)
				require.Empty(t, capture.Items)
				if sealedBox {
					require.Len(t, capture.Spawns, 1)
					require.EqualValues(t, 20205, capture.Spawns[0].NPCTypeID)
					require.Contains(t, strings.Join(capture.Responses, " "), "General will take care of you")
				} else {
					require.Empty(t, capture.Spawns)
				}
			}
		})
	}
}
