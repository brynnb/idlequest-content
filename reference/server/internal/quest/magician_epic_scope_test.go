package quest

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestMagicianEpicDoesNotExposeLaterBantilRoute(t *testing.T) {
	for _, npc := range []struct{ zone, name string }{{"butcher", "Walnan"}, {"najena", "Akksstaff"}} {
		source := readOverrideLua(t, "modified-upstream", npc.zone, npc.name)
		for _, message := range []string{"hail", "bantil sent me", "demise"} {
			event := progressionEvent(PlayerProxy{ID: 123, Name: "Magician", CharClass: "Magician", CharLevel: 60})
			event.Globals = map[string]string{"mage_epic": "5", "mage_epic_jah": "1", "ask_minion_dead": "1"}
			event.Message = message
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(source, event)
			require.NoError(t, err, npc.name)
			require.Empty(t, capture.Items, npc.name)
			require.Empty(t, capture.Spawns, npc.name)
			require.Empty(t, capture.Globals, npc.name)
			require.NotContains(t, strings.Join(capture.Responses, "\n"), "Bantil", npc.name)
		}
	}
}

func TestMagicianPageDirectionsRetainAllThreeSources(t *testing.T) {
	for _, zone := range []string{"commons", "commonlands"} {
		event := progressionEvent(PlayerProxy{ID: 123, Name: "Mage", CharClass: "Magician", CharLevel: 50})
		event.Message = "what task"
		capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(
			readOverrideLua(t, "modified-upstream", zone, "Jahsohn_Aksot"), event)
		require.NoError(t, err)
		for _, clue := range []string{"tainted forest", "haunted estate", "amphibian"} {
			require.Contains(t, strings.Join(capture.Responses, "\n"), clue, zone)
		}
	}
}
