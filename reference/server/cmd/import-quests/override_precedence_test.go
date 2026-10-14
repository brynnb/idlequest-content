package main

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
	"idlequest/internal/contentscope"
	"idlequest/internal/quest"
	questoverrides "idlequest/internal/quest/overrides"
	"idlequest/internal/testutil"
)

func TestLocalFullFixupsPreserveReviewedOverridesAfterEraFilters(t *testing.T) {
	ctx, db := testutil.LocalTemporaryTables(t, "quests")
	scripts, err := questoverrides.Scripts()
	require.NoError(t, err)
	require.NotEmpty(t, scripts)
	policy, err := quest.LoadQuestContentPolicy()
	require.NoError(t, err)
	// Exercise real exclusion-only rows too. Previously the relative manifest
	// path was absent from this test's cwd, silently skipping this whole stage.
	for key := range policy.Quests {
		zone, name, _ := strings.Cut(key, "/")
		_, err = db.ExecContext(ctx, `INSERT INTO quests (zone,name,lua_content,enabled) VALUES (?,?, 'function event_say(e) end',1)`, zone, name)
		require.NoError(t, err)
	}
	_, err = db.ExecContext(ctx, `INSERT INTO quests (zone,name,lua_content,enabled)
VALUES ('testzone','LaterEra','-- epic 1.5',1),
('erudnext','Tomekeeper_Danl','-- epic 1.5',0),
('butcher','Walnan','-- epic 1.5',0),
('najena','Akksstaff','-- epic 1.5',0)`)
	require.NoError(t, err)
	for i := 0; i < 2; i++ {
		require.NoError(t, applyIdleQuestQuestFixups(ctx, db))
		// Test the producing pipeline for every bundled override, not a hand-picked
		// subset of epics. Preserve source even when a reviewed NPC exclusion
		// supersedes an older override's admission to the game.
		for _, script := range scripts {
			var enabled, hasSay bool
			var source string
			require.NoError(t, db.QueryRowContext(ctx,
				"SELECT enabled,has_say_event,lua_content FROM quests WHERE zone=? AND name=?",
				script.Zone, script.Name).Scan(&enabled, &hasSay, &source))
			require.Equal(t, script.Enabled && !contentscope.ExcludesQuest(script.Zone, script.Name), enabled, script.Zone+"/"+script.Name)
			require.Equal(t, script.HasSayEvent, hasSay, script.Zone+"/"+script.Name)
			require.Equal(t, sanitizeUTF8(script.Lua), source, script.Zone+"/"+script.Name)
		}
		for _, name := range []string{"Tomekeeper_Danl", "Walnan", "Akksstaff"} {
			var enabled bool
			var source string
			require.NoError(t, db.QueryRowContext(ctx,
				"SELECT enabled,lua_content FROM quests WHERE name=?", name).Scan(&enabled, &source))
			require.True(t, enabled, name)
			require.Contains(t, source, "function event_trade", name)
			require.Contains(t, source, "epic 1.5", "keep provenance comments")
		}
		var enabled bool
		require.NoError(t, db.QueryRowContext(ctx,
			"SELECT enabled FROM quests WHERE name='LaterEra'").Scan(&enabled))
		require.False(t, enabled, "unreviewed later content stays disabled")
		for key, rule := range policy.Quests {
			zone, name, _ := strings.Cut(key, "/")
			require.NoError(t, db.QueryRowContext(ctx, "SELECT enabled FROM quests WHERE zone=? AND name=?", zone, name).Scan(&enabled))
			require.Equal(t, rule.ReviewedOverride != "", enabled, key)
		}
		require.NoError(t, verifyQuestExclusions(ctx, db, policy))
		// A matching maintained corpus alone must not bless a resurrected
		// excluded upstream-only row. The next pass repairs it again.
		_, err = db.ExecContext(ctx, "UPDATE quests SET enabled=1 WHERE zone='akanon' AND name='Jarah_Reskan'")
		require.NoError(t, err)
		require.ErrorContains(t, verifyQuestExclusions(ctx, db, policy), "akanon/Jarah_Reskan")
	}
	t.Logf("verified %d bundled overrides through two full fixup passes", len(scripts))
}
