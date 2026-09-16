package main

import (
	"github.com/stretchr/testify/require"
	questoverrides "idlequest/internal/quest/overrides"
	"idlequest/internal/testutil"
	"os"
	"path/filepath"
	"testing"
)

func TestLocalMaintainedContentSurvivesRepeatedImport(t *testing.T) {
	ctx, db := testutil.LocalTemporaryTables(t, "quests", "quest_lua_modules")
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(dir, "items.lua"), []byte("return {version='upstream'}"), 0600))
	module := questoverrides.Module{Name: "items", Lua: "-- enabled: false\nreturn {version='reviewed'}", Enabled: false}
	script := questoverrides.Script{Zone: "freportn", Name: "Test_Reviewed", Lua: "-- enabled: false\nfunction event_say(e) end", HasSayEvent: true, Enabled: false}
	for i := 0; i < 2; i++ {
		_, err := importLuaModules(ctx, db, dir)
		require.NoError(t, err)
		_, err = writeMaintainedLuaModules(ctx, db, []questoverrides.Module{module})
		require.NoError(t, err)
		_, err = writeBundledLuaOverrides(ctx, db, []questoverrides.Script{script})
		require.NoError(t, err)
		require.NoError(t, verifyContentSources(ctx, db, []questoverrides.Script{script}, []questoverrides.Module{module}))
		var content string
		var enabled bool
		require.NoError(t, db.QueryRowContext(ctx, "SELECT lua_content,enabled FROM quest_lua_modules WHERE module_name='items'").Scan(&content, &enabled))
		require.Equal(t, module.Lua, content)
		require.False(t, enabled)
		require.NoError(t, db.QueryRowContext(ctx, "SELECT lua_content,enabled FROM quests WHERE zone='freportn' AND name='Test_Reviewed'").Scan(&content, &enabled))
		require.Equal(t, script.Lua, content)
		require.False(t, enabled)
	}
	_, err := db.ExecContext(ctx, "UPDATE quests SET lua_content='stale' WHERE name='Test_Reviewed'")
	require.NoError(t, err)
	require.ErrorContains(t, verifyContentSources(ctx, db, []questoverrides.Script{script}, nil), "1 maintained sources differ")
	_, err = db.ExecContext(ctx, "DELETE FROM quests WHERE name='Test_Reviewed'")
	require.NoError(t, err)
	require.ErrorContains(t, verifyContentSources(ctx, db, []questoverrides.Script{script}, nil), "1 maintained sources differ")
}
