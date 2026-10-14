package main

import (
	"context"
	"database/sql"
	"errors"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
	"idlequest/internal/quest"
	"idlequest/internal/testutil"
)

type directoryCleanupRecorder struct {
	query string
	args  []any
	err   error
}

func (r *directoryCleanupRecorder) ExecContext(_ context.Context, query string, args ...any) (sql.Result, error) {
	r.query, r.args = query, args
	return nil, r.err
}

func TestSourceDirectoryImportAndCleanupAgree(t *testing.T) {
	for _, name := range nonQuestSourceDirectories {
		require.False(t, isQuestSourceDirectory(name))
	}
	for _, name := range []string{"v0", "v1", "v123"} {
		require.False(t, isQuestSourceDirectory(name))
	}
	for _, name := range []string{"hole", "tox", "encounters", "necropolis", "veeshan"} {
		require.True(t, isQuestSourceDirectory(name))
	}
	r := &directoryCleanupRecorder{}
	require.NoError(t, disableNonQuestDirectoryRows(context.Background(), r))
	require.Equal(t, "UPDATE quests SET enabled = 0 WHERE enabled <> 0 AND (zone IN (?,?,?,?) OR zone REGEXP '^v[0-9]+$')", r.query)
	require.Equal(t, []any{".git", "lua_modules", "plugins", "utility"}, r.args)
	r.err = errors.New("write failed")
	require.ErrorContains(t, disableNonQuestDirectoryRows(context.Background(), r), "write failed")
}

func TestCollectQuestSourcesPreservesZoneForClassicVersion(t *testing.T) {
	root := t.TempDir()
	for _, name := range []string{"droga/v0/traitor.lua", "droga/v1/traitor.lua", "droga/root.lua", "droga/default.lua", "droga/v0/old.pl", "lua_modules/items.lua", "v0/legacy.lua"} {
		file := filepath.Join(root, name)
		require.NoError(t, os.MkdirAll(filepath.Dir(file), 0755))
		require.NoError(t, os.WriteFile(file, []byte(name), 0644))
	}
	sources, err := collectQuestSources(root)
	require.NoError(t, err)
	require.Equal(t, []questSource{
		{Zone: "droga", Name: "root", Path: filepath.Join(root, "droga/root.lua")},
		{Zone: "droga", Name: "traitor", Path: filepath.Join(root, "droga/v0/traitor.lua")},
	}, sources)
	require.NoError(t, os.WriteFile(filepath.Join(root, "droga/traitor.lua"), []byte("conflict"), 0644))
	_, err = collectQuestSources(root)
	require.ErrorContains(t, err, "ambiguous quest source droga/traitor")
}

func TestVendoredVersionZeroSourcesHaveCanonicalZoneKeys(t *testing.T) {
	root := "../../internal/quest/upstream/projecteq"
	sources, err := collectQuestSources(root)
	require.NoError(t, err)
	counts := map[string]int{}
	for _, source := range sources {
		if filepath.Base(filepath.Dir(source.Path)) == "v0" {
			counts[source.Zone]++
		}
	}
	require.Equal(t, map[string]int{"droga": 6, "citymist": 4, "lavastorm": 5, "paw": 1}, counts)
}

func TestLocalVersionedImportRepairsBindingsAndRejectsLegacyRegistration(t *testing.T) {
	ctx, db := testutil.LocalTemporaryTables(t, "quests")
	sources, err := collectQuestSources("../../internal/quest/upstream/projecteq")
	require.NoError(t, err)
	var droga []questSource
	for _, source := range sources {
		if source.Zone == "droga" && filepath.Base(filepath.Dir(source.Path)) == "v0" {
			droga = append(droga, source)
		}
	}
	require.Len(t, droga, 6)
	_, err = db.ExecContext(ctx, `INSERT INTO quests(zone,name,lua_content,enabled)
 VALUES('v0','a_goblin_traitor','old source',1),('v1','LaterEra','old source',1)`)
	require.NoError(t, err)
	policy, err := quest.LoadQuestContentPolicy()
	require.NoError(t, err)
	require.ErrorContains(t, verifyQuestExclusions(ctx, db, policy), "v0/a_goblin_traitor")
	for i := 0; i < 2; i++ {
		imported, _, err := importQuestSources(ctx, db, droga)
		require.NoError(t, err)
		require.Equal(t, 6, imported)
		require.NoError(t, applyIdleQuestQuestFixups(ctx, db))
		for _, name := range []string{"a_goblin_traitor", "an_angry_goblin"} {
			var enabled, hasSay bool
			var source string
			require.NoError(t, db.QueryRowContext(ctx, "SELECT enabled,has_say_event,lua_content FROM quests WHERE zone='droga' AND name=?", name).Scan(&enabled, &hasSay, &source))
			require.True(t, enabled)
			require.True(t, hasSay)
			require.Contains(t, source, "RegalBandBathezid")
		}
		var count int
		require.NoError(t, db.QueryRowContext(ctx, "SELECT COUNT(*) FROM quests WHERE zone IN('v0','v1') AND enabled=1").Scan(&count))
		require.Zero(t, count)
		require.NoError(t, verifyQuestExclusions(ctx, db, policy))
	}
}
