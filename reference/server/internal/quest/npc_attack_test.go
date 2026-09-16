package quest

import (
	"fmt"
	"os"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestKrazenAndLithnonAttackExactAlayleNotQuestPlayer(t *testing.T) {
	for _, sourceNPC := range []struct {
		name string
		id   int32
	}{{"Krazen_Loosh", 9143}, {"Guard_Lithnon", 9106}} {
		t.Run(sourceNPC.name, func(t *testing.T) {
			source, err := os.ReadFile("upstream/projecteq/freportw/" + sourceNPC.name + ".lua")
			require.NoError(t, err)
			event := progressionEvent(PlayerProxy{ID: 123})
			event.NPC.ID, event.SpawnInstanceID = sourceNPC.id, 6001
			event.ResolveNPC = func(q QuestNPCQuery) (*NPCProxy, error) {
				require.Equal(t, QuestNPCQuery{NPCTypeID: 9141}, q)
				return &NPCProxy{ID: 9141, SpawnInstanceID: 6002}, nil
			}
			capture, err := NewLuaBridge(".").ExecuteEventFromSource(string(source), "event_signal", event)
			require.NoError(t, err)
			require.Equal(t, []QuestHateChange{{Order: 1, Source: QuestSpellActor{NPCTypeID: sourceNPC.id, SpawnInstanceID: 6001}, Target: QuestSpellActor{NPCTypeID: 9141, SpawnInstanceID: 6002}, Hate: 1, YellForHelp: true}}, capture.HateChanges)
			require.Contains(t, capture.DeferredAPIs, "eq.attack_npc_type", "capture does not prove execution")
		})
	}
}

func TestNPCAttackRejectsMalformedOrUnresolvedIdentity(t *testing.T) {
	for _, argument := range []string{"0", "-1", "1.5", "0/0", "1/0", "2147483648", "'9141'", "9141, 2"} {
		t.Run(argument, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 123})
			capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e) pcall(function() eq.attack_npc_type(`+argument+`) end); e.other:SummonItem(1001) end`, event)
			require.Error(t, err)
			require.Nil(t, capture)
		})
	}
	for _, mode := range []string{"absent", "read-error", "wrong-type", "self", "no-resolver"} {
		t.Run(mode, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 123})
			event.NPC.ID, event.SpawnInstanceID = 9143, 6001
			event.ResolveNPC = func(QuestNPCQuery) (*NPCProxy, error) {
				switch mode {
				case "absent":
					return nil, nil
				case "read-error":
					return nil, fmt.Errorf("population read failed")
				case "wrong-type":
					return &NPCProxy{ID: 9999, SpawnInstanceID: 6002}, nil
				default:
					return &NPCProxy{ID: 9141, SpawnInstanceID: 6001}, nil
				}
			}
			if mode == "no-resolver" {
				event.ResolveNPC = nil
			}
			capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e) pcall(function() eq.attack_npc_type(9141) end) end`, event)
			if mode == "absent" {
				require.NoError(t, err)
				require.Empty(t, capture.HateChanges)
				require.Equal(t, []string{"I am unable to locate NPC type 9141"}, capture.Responses)
			} else {
				require.Error(t, err)
				require.Nil(t, capture)
			}
		})
	}
}
