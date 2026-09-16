package quest

import (
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestSignalCapturesMillisecondDelay(t *testing.T) {
	for _, test := range []struct {
		call  string
		id    int
		delay int64
	}{
		{"eq.signal(9143)", 0, 0}, {"eq.signal(9143,1)", 1, 0},
		{"eq.signal(9143,1,30000)", 1, 30000}, {"eq.signal(71056,2,200000)", 2, 200000},
	} {
		t.Run(test.call, func(t *testing.T) {
			capture, err := NewLuaBridge(".").ExecuteTradeFromSource("function event_trade(e) "+test.call+" end",
				&LuaEvent{NPC: &NPCProxy{ID: 9141}, Player: &PlayerProxy{}, Trade: &TradeProxy{}, SpawnInstanceID: 6001})
			require.NoError(t, err)
			require.Len(t, capture.Signals, 1)
			require.Equal(t, test.id, capture.Signals[0].SignalID)
			require.Equal(t, test.delay, capture.Signals[0].DelayMS)
		})
	}
}

func TestSignalRejectsInvalidDelay(t *testing.T) {
	for _, delay := range []string{"-1", "0.5", "2147483648", "0/0", "math.huge"} {
		_, err := NewLuaBridge(".").ExecuteTradeFromSource(fmt.Sprintf("function event_trade(e) eq.signal(9143,1,%s) end", delay),
			&LuaEvent{NPC: &NPCProxy{ID: 9141}, Player: &PlayerProxy{}, Trade: &TradeProxy{}, SpawnInstanceID: 6001})
		require.Error(t, err, delay)
	}
}
