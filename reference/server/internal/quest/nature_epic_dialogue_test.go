package quest

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestVenrilResurrectionUsesCurrentPlayerName(t *testing.T) {
	source := readOverrideLua(t, "converted-perl", "karnor", "Spirit_of_Venril_Sathir")
	bridge := NewLuaBridge("upstream/projecteq")
	for _, name := range []string{"RangerOne", "DruidTwo"} {
		event := progressionEvent(PlayerProxy{ID: 123, Name: name, CharLevel: 50})
		event.Trade = &TradeProxy{Items: []int{15392}}
		capture, err := bridge.ExecuteTradeFromSource(source, event)
		require.NoError(t, err)
		response := strings.Join(capture.Responses, " ")
		require.Contains(t, response, "My thanks to you, "+name+".")
		require.NotContains(t, response, "$name")
		require.Contains(t, response, "Your carcass will help nurture")
		require.Len(t, capture.Spawns, 1)
		require.EqualValues(t, 102126, capture.Spawns[0].NPCTypeID)
	}
}
