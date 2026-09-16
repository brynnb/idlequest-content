package quest

import (
	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
	"testing"
)

func TestLocalQuestDirectoryUsesInteractionAndExactIdentity(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "quests")
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	for _, row := range []struct{ name, source string }{
		{"#Neh-Ashiir", "function event_trade(e) end"},
		{"#Neh-Ashiir_", "function event_spawn(e) eq.attack(e.other:GetName()) end"},
		{"#Lord_Rak-Ashiir", "function event_trade(e) end"},
		{"#Lord_Rak-Ashiir_", "function event_death_complete(e) end"},
		{"90000", "function event_death_complete(e) end"},
		{"42", "function event_say(e) end"},
		{"comment", "-- function event_trade(e)\nfunction event_spawn(e) end"},
	} {
		_, err := raw.ExecContext(ctx, "INSERT INTO quests(zone,name,lua_content,enabled) VALUES('citymist',?,?,1)", row.name, row.source)
		require.NoError(t, err)
	}
	require.ElementsMatch(t, []string{"#Neh-Ashiir", "#Lord_Rak-Ashiir", "42"}, s.GetQuestNPCNames("citymist"))
	require.True(t, s.HasNPCQuestInteraction("#Neh`Ashiir", 90184, "citymist"))
	require.False(t, s.HasNPCQuestInteraction("#Neh`Ashiir_", 90181, "citymist"))
	require.True(t, s.HasNPCQuestInteraction("numeric_npc", 42, "citymist"))
	require.False(t, s.HasNPCQuestInteraction("numeric_npc", 43, "citymist"))
}
