package quest

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestNPCEnumerationUsesScopedSnapshotAndExactIdentity(t *testing.T) {
	for _, expression := range []string{"eq.get_entity_list():GetNPCList().entries", "eq.get_entity_list():GetNPCEntries()"} {
		t.Run(expression, func(t *testing.T) {
			actors := []NPCProxy{{ID: 9002, SpawnInstanceID: 6002, Name: "First"}, {ID: 9002, SpawnInstanceID: 6003, Name: "Second"}}
			event := progressionEvent(PlayerProxy{})
			calls := 0
			event.ListNPCs = func() ([]NPCProxy, error) { calls++; return actors, nil }
			bridge := NewLuaBridge(".")
			bridge.RequireImplementedEffects = true
			capture, err := bridge.ExecuteSayFromSource(fmt.Sprintf(`function event_say(e)
local count = 0
for npc in %s do
  count = count + 1
  npc:Signal(count)
  e.self:Say(npc:GetName())
end
assert(count == 2)
end`, expression), event)
			require.NoError(t, err)
			require.Equal(t, 1, calls)
			require.Equal(t, []string{"First", "Second"}, capture.Responses)
			require.Equal(t, []NPCSignal{{NPCID: 9002, SpawnInstanceID: 6002, SignalID: 1}, {NPCID: 9002, SpawnInstanceID: 6003, SignalID: 2}}, capture.Signals)
			require.Empty(t, capture.DeferredAPIs)
			require.Nil(t, actors[0].Capture)
		})
	}
}

func TestNPCEnumerationRejectsUnavailableMalformedAndUnsafeResults(t *testing.T) {
	for _, tc := range []struct {
		name            string
		list            QuestNPCEnumerator
		body, wantError string
	}{
		{"empty", func() ([]NPCProxy, error) { return nil, nil }, `assert(count == 0)`, ""},
		{"missing capability", nil, "", "capability not implemented"},
		{"population failure", func() ([]NPCProxy, error) { return nil, fmt.Errorf("offline") }, "", "offline"},
		{"invalid identity", func() ([]NPCProxy, error) { return []NPCProxy{{ID: 1}}, nil }, "", "invalid or duplicate"},
		{"duplicate", func() ([]NPCProxy, error) {
			return []NPCProxy{{ID: 1, SpawnInstanceID: 5}, {ID: 1, SpawnInstanceID: 5}}, nil
		}, "", "invalid or duplicate"},
		{"unsafe foreign write", func() ([]NPCProxy, error) { return []NPCProxy{{ID: 9002, SpawnInstanceID: 6002}}, nil }, "", "cross-NPC method MoveTo"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{})
			event.ListNPCs = tc.list
			loopBody := "count = count + 1"
			if tc.name == "unsafe foreign write" {
				loopBody += "; npc:MoveTo(1,2,3)"
			}
			capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
local count=0
pcall(function() for npc in eq.get_entity_list():GetNPCEntries() do `+loopBody+` end end)
`+tc.body+`
e.other:SummonItem(1001)
end`, event)
			if tc.wantError != "" {
				require.ErrorContains(t, err, tc.wantError)
				require.Nil(t, capture)
			} else {
				require.NoError(t, err)
				require.NotEmpty(t, capture.Items)
			}
		})
	}
}
