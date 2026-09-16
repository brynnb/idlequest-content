package quest

import (
	"os"
	"testing"

	"idlequest/internal/combat"

	"github.com/stretchr/testify/require"
)

func TestQuestFactionPolicyDoesNotChangeRealFactionOrRewards(t *testing.T) {
	event := progressionEvent(PlayerProxy{Factions: map[int]int{404: -2000}})
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(`
function event_say(e)
  e.self:Say(tostring(e.other:GetFaction(e.self)))
  e.self:Say(tostring(e.other:GetCharacterFactionLevel(404)))
  e.self:Say(tostring(e.other:GetModCharacterFactionLevel(404)))
  e.other:Faction(404, -53)
end`, event)
	require.NoError(t, err)
	require.Equal(t, []string{"1", "2000", "2000"}, capture.Responses)
	require.Equal(t, map[int]int{404: -2000}, event.Player.Factions)
	require.Equal(t, []FactionReward{{FactionID: 404, Amount: -53}}, capture.Factions)
	require.Equal(t, combat.FactionScowls, combat.CalculateFactionLevel(-2000), "world faction is not bypassed")
}

func TestActualShadowKnightDialogueIgnoresQuestFaction(t *testing.T) {
	for _, tt := range []struct{ path, keyword, response string }{
		{"upstream/projecteq/citymist/Lhranc.lua", "cure", "I require only four things"},
		{"overrides/lua/converted-perl/hole/Caradon.lua", "Who is Kyrenna", "I was with Kyrenna"},
		{"overrides/lua/converted-perl/paineel/Duriek_Bloodpool.lua", "items", "I will need the Ghoulbane"},
	} {
		t.Run(tt.path, func(t *testing.T) {
			source, err := os.ReadFile(tt.path)
			require.NoError(t, err)
			event := progressionEvent(PlayerProxy{ClassID: 5, CharClass: "Shadow Knight", Factions: map[int]int{404: -2000}})
			event.Message = tt.keyword
			capture, err := NewLuaBridge(".").ExecuteSayFromSource(string(source), event)
			require.NoError(t, err)
			require.Len(t, capture.Responses, 1)
			require.Contains(t, capture.Responses[0], tt.response)
		})
	}
}

func TestTeydarGreetingUsesActualClassAndRetainsIngredientDirections(t *testing.T) {
	source, err := os.ReadFile("overrides/lua/converted-perl/qcat/Teydar.lua")
	require.NoError(t, err)
	for _, classID := range []uint8{5, 14} {
		event := progressionEvent(PlayerProxy{ClassID: classID, CharClass: (&Service{}).getClassName(uint8(classID)),
			Factions: map[int]int{404: -2000}})
		event.Message = "hail"
		bridge := NewLuaBridge(".")
		capture, err := bridge.ExecuteSayFromSource(string(source), event)
		require.NoError(t, err)
		if classID == 5 {
			require.Len(t, capture.Responses, 1)
			require.Contains(t, capture.Responses[0], "suitable scabbards and sheaths")
		} else {
			require.Empty(t, capture.Responses)
		}
		event.Message = "decrepit sheath"
		capture, err = bridge.ExecuteSayFromSource(string(source), event)
		require.NoError(t, err)
		require.Len(t, capture.Responses, 1)
		require.Contains(t, capture.Responses[0], "decrepit hide and a drake spine")
		require.Contains(t, capture.Responses[0], "enchanted platinum")
	}
}
