package quest

import (
	"github.com/stretchr/testify/require"
	"testing"
)

func TestQuestAttackCapturesTargetOnceAndIsARuntimeEffect(t *testing.T) {
	event := progressionEvent(PlayerProxy{Name: "Knight"})
	bridge := NewLuaBridge(".")
	bridge.RequireImplementedEffects = true
	capture, err := bridge.ExecuteSayFromSource(`function event_say(e)
  eq.attack(e.other:GetName())
  eq.attack("knight")
end`, event)
	require.NoError(t, err)
	require.Equal(t, []QuestAttackRequest{{PlayerName: "Knight"}}, capture.Attacks)
	require.Empty(t, capture.DeferredAPIs)
	require.True(t, captureHasRuntimeEffects(capture))
}

func TestKurronRequiresAndConsumesCashWhilePreservingExtraHandins(t *testing.T) {
	source := readOverrideLua(t, "converted-perl", "overthere", "Kurron_Ni")
	for _, cash := range []int{899, 900, 901} {
		event := progressionEvent(PlayerProxy{Name: "Knight"})
		event.Trade = &TradeProxy{Items: []int{3141, 3145, 3140, 1001}, Platinum: cash}
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteTradeFromSource(source, event)
		require.NoError(t, err)
		if cash < 900 {
			require.Equal(t, cash, capture.CurrentTrade.Platinum)
			require.Equal(t, []int{3141, 3145, 3140, 1001}, capture.CurrentTrade.Items)
			require.Empty(t, capture.NPCAddedLoot)
		} else {
			require.Equal(t, cash-900, capture.CurrentTrade.Platinum)
			require.Equal(t, []int{1001}, capture.CurrentTrade.Items)
			require.Equal(t, []NPCAddedLoot{{NPCID: 9001, ItemID: 18099, Count: 1}}, capture.NPCAddedLoot)
		}
	}
}

func TestActualSKQuestScriptsRequestOwnerCombat(t *testing.T) {
	bridge := NewLuaBridge("upstream/projecteq")
	bridge.RequireImplementedEffects = true
	event := progressionEvent(PlayerProxy{Name: "Knight", Factions: map[int]int{404: -2000}})
	event.Message = "mission"
	capture, err := bridge.ExecuteSayFromSource(readOverrideLua(t, "converted-perl", "overthere", "Kurron_Ni"), event)
	require.NoError(t, err)
	require.Equal(t, []QuestAttackRequest{{PlayerName: "Knight"}}, capture.Attacks)
	event.Trade = &TradeProxy{Items: []int{14373}}
	capture, err = bridge.ExecuteTradeFromSource(readOverrideLua(t, "converted-perl", "hole", "Caradon"), event)
	require.NoError(t, err)
	require.Equal(t, []QuestAttackRequest{{PlayerName: "Knight"}}, capture.Attacks)
	require.Len(t, capture.Spawns, 1)
	require.Equal(t, int32(39155), capture.Spawns[0].NPCTypeID)
}

func TestNPCAddedInventoryRequiresConcreteActorIdentity(t *testing.T) {
	service := &Service{}
	for _, tc := range []struct {
		owner uint32
		npc   int32
		zone  string
		spawn int64
	}{
		{0, 93083, "overthere", 123}, {7, 0, "overthere", 123}, {7, 93083, "", 123}, {7, 93083, "overthere", 0}, {7, 93083, "overthere", -93083},
	} {
		_, err := service.RuntimeNPCAddedLoot(tc.owner, tc.npc, tc.zone, 0, tc.spawn)
		require.ErrorContains(t, err, "exact owner")
	}
}

func TestKyrennaSpawnRequestsCombatAgainstHerQuestOwner(t *testing.T) {
	bridge := NewLuaBridge(".")
	bridge.RequireImplementedEffects = true
	source := readOverrideLua(t, "idlequest-authored", "hole", "Kyrenna")
	event := progressionEvent(PlayerProxy{Name: "Knight"})
	event.NPC.ID = 39155
	capture, err := bridge.ExecuteEventFromSource(source, "event_spawn", event)
	require.NoError(t, err)
	require.Equal(t, []QuestAttackRequest{{PlayerName: "Knight"}}, capture.Attacks)
	require.Empty(t, capture.Spawns)
	require.Empty(t, capture.Items)
	require.Empty(t, capture.DeferredAPIs)
}
