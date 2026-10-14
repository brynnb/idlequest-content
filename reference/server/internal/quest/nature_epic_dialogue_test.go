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

func TestVenrilRemainsHandinRestartsRespawnAndTriggeredBossExpires(t *testing.T) {
	bridge := NewLuaBridge("upstream/projecteq")
	event := progressionEvent(PlayerProxy{ID: 123, Name: "Druid", CharLevel: 50})
	event.SpawnInstanceID = 16785
	event.Trade = &TradeProxy{Items: []int{10295}}
	c, err := bridge.ExecuteTradeFromSource(readOverrideLua(t, "converted-perl", "karnor", "Venril_Sathirs_remains"), event)
	require.NoError(t, err)
	require.Len(t, c.Spawns, 1)
	require.EqualValues(t, 102123, c.Spawns[0].NPCTypeID)
	require.Equal(t, []QuestDepopRequest{{SpawnInstanceID: 16785, WithTimer: true}}, c.Depops)
	source := readOverrideLua(t, "idlequest-authored", "karnor", "Venril_Sathir")
	c, err = bridge.ExecuteEventFromSource(source, "event_spawn", event)
	require.NoError(t, err)
	require.Equal(t, []TimerUpdate{{Name: "despawn", Interval: 1200000}}, c.Timers)
	event.Fields = map[string]any{"timer": "despawn"}
	c, err = bridge.ExecuteEventFromSource(source, "event_timer", event)
	require.NoError(t, err)
	require.Equal(t, []QuestDepopRequest{{SpawnInstanceID: 16785}}, c.Depops)
	require.Equal(t, []TimerUpdate{{Name: "despawn", Stop: true}}, c.Timers)
	c, err = bridge.ExecuteEventFromSource(readOverrideLua(t, "modified-upstream", "karnor", "#Venril_Sathir"), "event_spawn", event)
	require.NoError(t, err)
	require.Empty(t, c.Depops, "normal boss must not create per-character remains suppression")
}
