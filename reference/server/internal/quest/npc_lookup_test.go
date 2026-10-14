package quest

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestResolvedNPCLookupPreservesIdentityForSignalAndDepop(t *testing.T) {
	for _, method := range []string{"GetMobByNpcTypeID", "GetNPCByNPCTypeID", "GetNPCBySpawnID"} {
		t.Run(method, func(t *testing.T) {
			other := &NPCProxy{ID: 9002, SpawnInstanceID: 6002, Name: "Other", X: 12}
			event := progressionEvent(PlayerProxy{})
			event.NPC.ID, event.SpawnInstanceID = 9001, 6001
			event.ResolveNPC = func(query QuestNPCQuery) (*NPCProxy, error) {
				if method == "GetNPCBySpawnID" {
					require.Equal(t, QuestNPCQuery{SpawnGroupID: 9002}, query)
				} else {
					require.Equal(t, QuestNPCQuery{NPCTypeID: 9002}, query)
				}
				return other, nil
			}
			bridge := NewLuaBridge(".")
			bridge.RequireImplementedEffects = true
			capture, err := bridge.ExecuteSayFromSource(fmt.Sprintf(`function event_say(e)
  local target = eq.get_entity_list():%s(9002)
  assert(target.valid and not target.null and target:IsNPC() and target:IsMob())
  e.self:Say(target:GetName() .. ":" .. target:GetID() .. ":" .. target:GetX())
  target:Signal(7)
  target:CastToNPC():Depop()
end`, method), event)
			require.NoError(t, err)
			require.Equal(t, []string{"Other:6002:12"}, capture.Responses)
			require.Equal(t, []NPCSignal{{NPCID: 9002, SpawnInstanceID: 6002, SignalID: 7}}, capture.Signals)
			require.Equal(t, []QuestDepopRequest{{NPCTypeID: 9002, SpawnInstanceID: 6002}}, capture.Depops)
			require.Nil(t, other.Capture, "resolver snapshot must not be mutated")
		})
	}
}

func TestResolvedNPCShoutPreservesSpeakerWithoutMutatingResolverSnapshot(t *testing.T) {
	e := progressionEvent(PlayerProxy{})
	other := &NPCProxy{ID: 9002, SpawnInstanceID: 6002, Name: "Commander_Name"}
	e.ResolveNPC = func(QuestNPCQuery) (*NPCProxy, error) { return other, nil }
	b := NewLuaBridge(".")
	b.RequireImplementedEffects = true
	c, err := b.ExecuteSayFromSource(`function event_say(e) eq.get_entity_list():GetNPCByNPCTypeID(9002):Shout("Take your positions!") end`, e)
	require.NoError(t, err)
	require.Equal(t, []string{"[Shout] Commander_Name says, 'Take your positions!'"}, c.Responses)
	require.Empty(t, c.NPCSpeech, "a shout is zone-wide, not a nearby Say")
	require.Nil(t, other.Capture)
}

func TestDialogueCloneRetainsResolverWithoutSerializingAuthority(t *testing.T) {
	event := progressionEvent(PlayerProxy{})
	event.ResolveNPC = func(QuestNPCQuery) (*NPCProxy, error) { return &NPCProxy{ID: 9002, SpawnInstanceID: 6002}, nil }
	event.ListNPCs = func() ([]NPCProxy, error) { return []NPCProxy{{ID: 9002, SpawnInstanceID: 6002}}, nil }
	event.Fields = map[string]any{"__quest_npc_resolver": event.ResolveNPC, "__quest_npc_enumerator": event.ListNPCs, "signal": 1}
	clone, err := cloneDialogueEvent(event)
	require.NoError(t, err)
	require.NotNil(t, clone.ResolveNPC)
	require.NotNil(t, clone.ListNPCs)
	require.NotContains(t, clone.Fields, "__quest_npc_enumerator")
	require.NotContains(t, clone.Fields, "__quest_npc_resolver")
	require.Contains(t, event.Fields, "__quest_npc_resolver")
}

func TestResolvedLookupDoesNotPretendMissingActorOrUnsafeMutationSucceeded(t *testing.T) {
	for _, tc := range []struct {
		name       string
		actor      *NPCProxy
		resolveErr error
		body       string
		errorText  string
	}{
		{"missing", nil, nil, `assert(not target.valid and target.null)
 assert(not target:IsNPC() and not target:IsMob())
 assert(target:GetID() == 0 and target:GetNPCTypeID() == 0)
 target:Signal(7); target:CastToNPC():Depop()`, ""},
		{"wrong type", &NPCProxy{ID: 9999, SpawnInstanceID: 6002}, nil, ``, "mismatched actor"},
		{"storage failure", nil, fmt.Errorf("population unavailable"), ``, "population unavailable"},
		{"foreign removal", &NPCProxy{ID: 9002, SpawnInstanceID: 6002}, nil,
			`pcall(function() target:RemoveItem(18099) end); e.other:SummonItem(14366)`, "cross-NPC method RemoveItem"},
		{"foreign movement", &NPCProxy{ID: 9002, SpawnInstanceID: 6002}, nil,
			`pcall(function() target:MoveTo(1,2,3) end); e.other:SummonItem(14366)`, "cross-NPC method MoveTo"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{})
			event.ResolveNPC = func(QuestNPCQuery) (*NPCProxy, error) { return tc.actor, tc.resolveErr }
			capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
 local target = eq.get_entity_list():GetNPCByNPCTypeID(9002)
 `+tc.body+` end`, event)
			if tc.errorText == "" {
				require.NoError(t, err)
				require.Empty(t, capture.Items)
				require.Empty(t, capture.Signals)
				require.Empty(t, capture.Depops)
			} else {
				require.ErrorContains(t, err, tc.errorText)
				require.Nil(t, capture)
			}
		})
	}
}
