package quest

import (
	"github.com/go-jet/jet/v2/stmtcache"
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
	"testing"
)

func TestLocalQuestContentScopeRejectsEnabledRowsAndAliases(t *testing.T) {
	ctx, raw := testutil.LocalTemporaryTables(t, "quests")
	s := NewService(stmtcache.New(raw).SetCaching(false), ".")
	for _, name := range []string{"Igok", "#Igok", "46064"} {
		_, err := raw.ExecContext(ctx, "INSERT INTO quests(zone,name,lua_content,enabled) VALUES('innothule',?,'function event_say(e) end\nfunction event_trade(e) end',1)", name)
		require.NoError(t, err)
		require.False(t, s.HasNPCQuest(name, "innothule"))
		require.False(t, s.HasNPCQuestInteraction(name, 46064, "innothule"))
	}
	require.Empty(t, s.GetQuestNPCNames("innothule"))
	_, err := raw.ExecContext(ctx, "INSERT INTO quests(zone,name,lua_content,enabled) VALUES('grobb','a_prisoner','function event_trade(e) end',1),('grobb','Igok','function event_say(e) end',1)")
	require.NoError(t, err)
	require.True(t, s.HasNPCQuestInteraction("a_prisoner", 52047, "grobb"))
	require.True(t, s.HasNPCQuest("Igok", "grobb"))
	require.ElementsMatch(t, []string{"a_prisoner", "Igok"}, s.GetQuestNPCNames("grobb"))
}

func TestInactiveUnplacedNPCQuestLookupDoesNotInferAZone(t *testing.T) {
	s := NewService(nil, ".")
	// Neither name-only nor numeric fallback may run for the actual excluded actor.
	source, err := s.loadScriptFromDBForNPC("qeynos", "Uglib_Gaibido", 20293)
	require.NoError(t, err)
	require.Empty(t, source)
}
