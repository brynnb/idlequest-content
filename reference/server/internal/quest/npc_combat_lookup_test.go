package quest

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestNPCCombatLookupPreservesConcreteActorAndSelection(t *testing.T) {
	for method, selection := range map[string]QuestNPCCombatSelection{
		"GetTarget": QuestCombatCurrentTarget, "GetHateTop": QuestCombatTopHate, "GetHateRandom": QuestCombatRandomHate,
	} {
		t.Run(method, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{})
			event.NPC = &NPCProxy{ID: 9001}
			event.SpawnInstanceID = 7001
			target := &NPCProxy{ID: 9002, SpawnInstanceID: 7002, Name: "actual target"}
			event.ReadNPCCombat = func(source QuestSpellActor, kind QuestNPCCombatSelection) (QuestNPCCombatResult, error) {
				require.Equal(t, QuestSpellActor{NPCTypeID: 9001, SpawnInstanceID: 7001}, source)
				require.Equal(t, selection, kind)
				return QuestNPCCombatResult{NPC: target}, nil
			}
			capture, err := NewLuaBridge(".").ExecuteSayFromSource(fmt.Sprintf(`function event_say(e)
local target = e.self:%s()
assert(target.valid and target:GetNPCTypeID() == 9002 and target:GetID() == 7002)
target:Signal(8)
end`, method), event)
			require.NoError(t, err)
			require.NotEmpty(t, capture.Signals)
			require.Nil(t, target.Capture, "lookup must not mutate population proxy")
		})
	}
}

func TestNPCCombatLookupObservedEmptyIsNotMissingCapability(t *testing.T) {
	event := progressionEvent(PlayerProxy{})
	event.SpawnInstanceID = 7001
	event.ReadNPCCombat = func(QuestSpellActor, QuestNPCCombatSelection) (QuestNPCCombatResult, error) {
		return QuestNPCCombatResult{}, nil
	}
	_, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
local target = e.self:GetTarget()
assert(target.null and not target.valid)
end`, event)
	require.NoError(t, err)
	for _, reader := range []QuestNPCCombatReader{nil, func(QuestSpellActor, QuestNPCCombatSelection) (QuestNPCCombatResult, error) {
		return QuestNPCCombatResult{}, fmt.Errorf("stale generation")
	}} {
		event.ReadNPCCombat = reader
		_, err = NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
pcall(function() e.self:GetTarget() end)
e.other:SummonItem(1001)
end`, event)
		require.ErrorContains(t, err, "NPC combat lookup", "pcall must not conceal unavailable reads")
	}
}

func TestNPCCombatLookupRejectsAmbiguousAndCrossOwnerActors(t *testing.T) {
	for _, actor := range []QuestNPCCombatResult{
		{NPC: &NPCProxy{ID: 9002}},
		{NPC: &NPCProxy{ID: 9002, SpawnInstanceID: 7002}, Player: &PlayerProxy{ID: 42}},
		{Player: &PlayerProxy{ID: 43}},
	} {
		event := progressionEvent(PlayerProxy{ID: 42})
		event.Player.ID = 42
		event.SpawnInstanceID = 7001
		event.ReadNPCCombat = func(QuestSpellActor, QuestNPCCombatSelection) (QuestNPCCombatResult, error) { return actor, nil }
		_, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e) e.self:GetTarget() end`, event)
		require.Error(t, err)
	}
}

func TestNPCCombatLookupReturnsOwnerWithoutConfusingNPCNamespace(t *testing.T) {
	event := progressionEvent(PlayerProxy{ID: 42})
	event.Player.ID = 42
	event.NPC = &NPCProxy{ID: 9001}
	event.SpawnInstanceID = 42 // Numeric collision is not actor identity.
	owner := &PlayerProxy{ID: 42}
	event.ReadNPCCombat = func(QuestSpellActor, QuestNPCCombatSelection) (QuestNPCCombatResult, error) {
		return QuestNPCCombatResult{Player: owner}, nil
	}
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
local target = e.self:GetTarget()
assert(target:GetID() == 42 and target:IsClient())
target:SummonItem(1001)
end`, event)
	require.NoError(t, err)
	require.NotEmpty(t, capture.Items)
	require.Nil(t, owner.Capture)
}

func TestNPCEngagementUsesScopedReaderForSelfAndResolvedActors(t *testing.T) {
	for _, engaged := range []bool{false, true} {
		event := progressionEvent(PlayerProxy{})
		event.NPC.ID, event.SpawnInstanceID = 9001, 7001
		event.ResolveNPC = func(QuestNPCQuery) (*NPCProxy, error) {
			return &NPCProxy{ID: 9002, SpawnInstanceID: 7002}, nil
		}
		var sources []QuestSpellActor
		event.ReadNPCCombat = func(source QuestSpellActor, selection QuestNPCCombatSelection) (QuestNPCCombatResult, error) {
			require.Equal(t, QuestCombatEngagement, selection)
			sources = append(sources, source)
			return QuestNPCCombatResult{Engaged: &engaged}, nil
		}
		_, err := NewLuaBridge(".").ExecuteSayFromSource(fmt.Sprintf(`function event_say(e)
assert(e.self:IsEngaged() == %t)
assert(eq.get_entity_list():GetNPCByNPCTypeID(9002):IsEngaged() == %t)
end`, engaged, engaged), event)
		require.NoError(t, err)
		require.Equal(t, []QuestSpellActor{{NPCTypeID: 9001, SpawnInstanceID: 7001}, {NPCTypeID: 9002, SpawnInstanceID: 7002}}, sources)
	}
}

func TestNPCEngagementRejectsUnavailableOrAmbiguousStateEvenThroughPcall(t *testing.T) {
	engaged := true
	for _, reader := range []QuestNPCCombatReader{nil,
		func(QuestSpellActor, QuestNPCCombatSelection) (QuestNPCCombatResult, error) {
			return QuestNPCCombatResult{}, nil
		},
		func(QuestSpellActor, QuestNPCCombatSelection) (QuestNPCCombatResult, error) {
			return QuestNPCCombatResult{Engaged: &engaged, Player: &PlayerProxy{ID: 42}}, nil
		},
		func(QuestSpellActor, QuestNPCCombatSelection) (QuestNPCCombatResult, error) {
			return QuestNPCCombatResult{}, fmt.Errorf("stale snapshot")
		},
	} {
		event := progressionEvent(PlayerProxy{})
		event.SpawnInstanceID, event.ReadNPCCombat = 7001, reader
		_, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
pcall(function() e.self:IsEngaged() end)
e.other:SummonItem(1001)
end`, event)
		require.ErrorContains(t, err, "NPC engagement")
	}
}
