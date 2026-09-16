package quest

import (
	"github.com/stretchr/testify/require"
	"strings"
	"testing"
)

func TestWendenSpecificHiltNamesAreNotShadowedByGenericKeyword(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "freporte", "Wenden_Blackhammer")
	for _, tc := range []struct{ phrase, response string }{
		{"hilt", "made or [repaired]"},
		{"unjeweled dragon head hilt", "missing some gems"},
		{"severely damaged dragon head hilt", "proper components"},
	} {
		t.Run(tc.phrase, func(t *testing.T) {
			e := progressionEvent(PlayerProxy{ID: 123, CharClass: "Warrior", ClassID: 1})
			e.Message = tc.phrase
			capture, err := NewLuaBridge("upstream/projecteq").ExecuteSayFromSource(source, e)
			require.NoError(t, err)
			require.Contains(t, strings.Join(capture.Responses, " "), tc.response)
		})
	}
}
