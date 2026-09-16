package quest

import (
	"os"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestSkyDeathHateKeepsBothPendingActorIdentities(t *testing.T) {
	source, err := os.ReadFile("upstream/projecteq/airplane/a_soul_carrier.lua")
	require.NoError(t, err)
	event := progressionEvent(PlayerProxy{ID: 123})
	event.SpawnInstanceID = 6001
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(string(source), "event_death_complete", event)
	require.NoError(t, err)
	require.Len(t, capture.HateChanges, 2)
	for i, change := range capture.HateChanges {
		require.Equal(t, QuestSpellActor{NPCTypeID: 71070, PendingSpawnIndex: i + 1}, change.Source)
		require.Equal(t, QuestSpellActor{CharacterID: 123}, change.Target)
		require.Equal(t, int64(1), change.Hate)
		require.Zero(t, change.Damage)
		require.True(t, change.YellForHelp)
		require.False(t, change.Frenzy)
		require.False(t, change.BuffTick)
	}
	require.Contains(t, capture.DeferredAPIs, "e.self:AddToHateList", "capture is not combat delivery")
}

func TestConvertedEpicHandinsRetainSpawnedAttackerHate(t *testing.T) {
	for _, tc := range []struct {
		path      string
		item, npc int32
	}{
		{"kithicor/Giz_X-Tin", 20446, 20190},
		{"kaesora/spectral_librarian", 10631, 88087},
		{"karnor/Spirit_of_Venril_Sathir", 15392, 102126},
		{"hole/Jaeil_the_Wretched", 17860, 39154},
	} {
		t.Run(tc.path, func(t *testing.T) {
			source, err := os.ReadFile("overrides/lua/converted-perl/" + tc.path + ".lua")
			require.NoError(t, err)
			event := progressionEvent(PlayerProxy{ID: 123})
			event.Trade = &TradeProxy{Items: []int{int(tc.item)}}
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(string(source), event)
			require.NoError(t, err)
			require.Len(t, capture.HateChanges, 1)
			require.Equal(t, QuestSpellActor{NPCTypeID: tc.npc, PendingSpawnIndex: 1}, capture.HateChanges[0].Source)
			require.Equal(t, QuestSpellActor{CharacterID: 123}, capture.HateChanges[0].Target)
			require.Equal(t, int64(1), capture.HateChanges[0].Hate)
		})
	}
}

func TestHateCaptureRejectsMalformedActorsAndAmountsEvenThroughPcall(t *testing.T) {
	for _, args := range []string{"123,1", "e.other,0/0", "e.other,1/0", "e.other,1.5", "e.other,9007199254740992", "e.other,1,0,1"} {
		t.Run(args, func(t *testing.T) {
			capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
pcall(function() e.self:AddToHateList(`+args+`) end)
e.other:SummonItem(1001)
end`, progressionEvent(PlayerProxy{ID: 123}))
			require.Error(t, err)
			require.Nil(t, capture)
		})
	}
}
