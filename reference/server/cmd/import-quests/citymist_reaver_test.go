package main

import (
	"github.com/stretchr/testify/require"
	"idlequest/internal/testutil"
	"testing"
)

func TestLocalCitymistActiveReaversHaveImportedDeathHandlers(t *testing.T) {
	ctx, db := testutil.LocalTemporaryTables(t, "quests")
	// Import through the production override pipeline twice: this also proves new
	// rows are created and not merely updates to the old version-1 test fixture.
	for i := 0; i < 2; i++ {
		_, err := importBundledLuaOverrides(ctx, db)
		require.NoError(t, err)
	}
	rows, err := db.QueryContext(ctx, `SELECT DISTINCT n.id, q.enabled, q.lua_content
 FROM spawn2 s JOIN spawnentry e ON e.spawngroupID=s.spawngroupID
 JOIN npc_types n ON n.id=e.npcID
 LEFT JOIN quests q ON q.zone='citymist' AND BINARY q.name=BINARY CAST(n.id AS CHAR)
 WHERE s.zone='citymist' AND s.version=0 AND e.chance>0 AND n.name='a_black_reaver'`)
	require.NoError(t, err)
	defer rows.Close()
	var ids []int
	for rows.Next() {
		var id int
		var enabled bool
		var source string
		require.NoError(t, rows.Scan(&id, &enabled, &source), "an active Reaver has no imported handler")
		require.True(t, enabled)
		require.Contains(t, source, "function event_death_complete")
		ids = append(ids, id)
	}
	require.NoError(t, rows.Err())
	require.ElementsMatch(t, []int{90000, 90010, 90012, 90199}, ids)
}
