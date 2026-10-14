package quest

import (
	"errors"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestCaptureResetDiscardsEffectsButPreservesExecutionContext(t *testing.T) {
	capture := NewQuestCapture()
	capture.CurrentTrade = &TradeProxy{Items: []int{1001}}
	capture.requireImplementedEffects = true
	capture.actorEffectError = errors.New("invalid actor")
	capture.DeferredAPIs = []string{"e.self:MoveTo"}
	capture.registerSpellActor(101, QuestSpellActor{CharacterID: 101})
	expected := *capture
	capture.RuntimeActorEffectDeliveryID = "committed-old-event"
	capture.SignalProgress = &QuestSignalProgress{DeliveryID: "old-signal"}
	capture.RuntimeTriggersSettled, capture.RuntimeTimersSettled = true, true
	capture.PlayerMoves = []QuestPlayerMoveRequest{{}}
	capture.NPCMoves = []QuestNPCMoveRequest{{Order: 1, Kind: QuestNPCMoveWalk}}
	capture.Doors = []QuestDoorRequest{{}}
	capture.Binds = []QuestBindRequest{{}}
	capture.SayLinks = []DialogueOption{{}}
	capture.runtimeStateWrites = []questRuntimeStateWrite{{npcID: 9001}}
	clearQuestCaptureEffects(capture)
	require.Equal(t, expected, *capture, "reset must retain trade/identity/policy and fail-closed diagnostics, not old effects")
	require.Equal(t, 1, capture.nextActorEffectOrder())
}

func TestRegisteredCallbackDoesNotInheritEncounterLoadMovement(t *testing.T) {
	const source = `
function event_encounter_load(e)
  e.self:MoveTo(1, 2, 3)
  eq.register_npc_event(Event.signal, 9001, function(e)
    e.self:MoveTo(4, 5, 6)
  end)
end`
	for _, npcID := range []int32{9001, 9002} {
		capture, err := NewLuaBridge(".").ExecuteRegisteredNPCEventFromSource(source, RuntimeEventSignal, npcID,
			&LuaEvent{NPC: &NPCProxy{ID: npcID}, SpawnInstanceID: 77, Player: &PlayerProxy{ID: 101}})
		require.NoError(t, err)
		if npcID == 9002 {
			require.Empty(t, capture.NPCMoves, "no matching callback cannot produce encounter-load movement")
			continue
		}
		require.Len(t, capture.NPCMoves, 1)
		require.Equal(t, 1, capture.NPCMoves[0].Order)
		require.Equal(t, float64(4), capture.NPCMoves[0].X)
		require.Equal(t, int64(77), capture.NPCMoves[0].SpawnInstanceID)
	}
}

func TestRegisteredPlayerCallbackDoesNotReplayLoadDoorAndBind(t *testing.T) {
	const source = `
function event_encounter_load(e)
  eq.force_door_open(10)
  eq.bind_player()
  eq.register_player_event(Event.loot, function(e)
    eq.force_door_open(20)
    e.self:Message(15, "callback only")
  end)
end`
	for _, eventType := range []RuntimeEventType{RuntimeEventLoot, RuntimeEventEnterZone} {
		capture, err := NewLuaBridge(".").ExecuteRegisteredPlayerEventFromSource(source, eventType,
			&LuaEvent{Player: &PlayerProxy{ID: 101}, SelfIsPlayer: true})
		require.NoError(t, err)
		require.Empty(t, capture.Binds)
		if eventType == RuntimeEventEnterZone {
			require.Empty(t, capture.Doors)
			require.Empty(t, capture.Responses)
			continue
		}
		require.Equal(t, []QuestDoorRequest{{DoorID: 20, ForceOpen: true}}, capture.Doors)
		require.Equal(t, []string{"callback only"}, capture.Responses)
	}
}
