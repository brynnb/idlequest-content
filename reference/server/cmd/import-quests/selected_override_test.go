package main

import (
	"testing"

	"github.com/stretchr/testify/require"
	questoverrides "idlequest/internal/quest/overrides"
	"idlequest/internal/testutil"
)

func TestSelectBundledOverrideRequiresOneExactCanonicalKey(t *testing.T) {
	scripts, err := questoverrides.Scripts()
	require.NoError(t, err)
	script, err := selectBundledOverride(scripts, "qcat/Teydar")
	require.NoError(t, err)
	require.Equal(t, "converted-perl", script.Origin)
	require.Contains(t, script.Lua, "e.other:GetClass() == 5")
	for _, key := range []string{"qcat/teydar", "qcat/Teydar.lua", "qcat/*", "../qcat/Teydar", "unknown/Missing"} {
		_, err := selectBundledOverride(scripts, key)
		require.Error(t, err)
	}
	_, err = selectBundledOverride([]questoverrides.Script{script, script}, "qcat/Teydar")
	require.ErrorContains(t, err, "found 2")
}

func TestLocalSelectedOverrideDoesNotMutateUnrelatedOrDisabledQuests(t *testing.T) {
	ctx, db := testutil.LocalTemporaryTables(t, "quests")
	_, err := db.ExecContext(ctx, `INSERT INTO quests (zone, name, lua_content, has_say_event, enabled)
 VALUES ('qcat','Teydar','old script',0,1), ('qcat','Other','other script',0,1),
 ('qcat','Disabled','disabled script',0,0)`)
	require.NoError(t, err)
	scripts, err := questoverrides.Scripts()
	require.NoError(t, err)
	script, err := selectBundledOverride(scripts, "qcat/Teydar")
	require.NoError(t, err)
	before, err := updateSelectedOverride(ctx, db, script, false)
	require.NoError(t, err)
	require.Equal(t, "old script", before)
	read := func(name string) (string, bool, bool) {
		var content string
		var say, enabled bool
		require.NoError(t, db.QueryRowContext(ctx, "SELECT lua_content, has_say_event, enabled FROM quests WHERE name = ?", name).Scan(&content, &say, &enabled))
		return content, say, enabled
	}
	content, say, _ := read("Teydar")
	require.Equal(t, "old script", content)
	require.False(t, say)
	_, err = updateSelectedOverride(ctx, db, script, true)
	require.NoError(t, err)
	content, say, enabled := read("Teydar")
	require.Equal(t, script.Lua, content)
	require.True(t, say)
	require.True(t, enabled)
	for _, name := range []string{"Disabled", "Missing", "teydar"} {
		invalid := script
		invalid.Name = name
		_, err := updateSelectedOverride(ctx, db, invalid, true)
		require.Error(t, err)
	}
	content, say, enabled = read("Other")
	require.Equal(t, "other script", content)
	require.False(t, say)
	require.True(t, enabled)
	content, say, enabled = read("Disabled")
	require.Equal(t, "disabled script", content)
	require.False(t, say)
	require.False(t, enabled)
}

func TestLocalSelectedOverrideRepairsEnabledNullLua(t *testing.T) {
	ctx, db := testutil.LocalTemporaryTables(t, "quests")
	_, err := db.ExecContext(ctx, `INSERT INTO quests (zone,name,lua_content,has_say_event,enabled) VALUES ('eastkarana','Tholris',NULL,1,1)`)
	require.NoError(t, err)
	scripts, err := questoverrides.Scripts()
	require.NoError(t, err)
	script, err := selectBundledOverride(scripts, "eastkarana/Tholris")
	require.NoError(t, err)
	_, err = updateSelectedOverride(ctx, db, script, false)
	require.NoError(t, err)
	var missing bool
	require.NoError(t, db.QueryRowContext(ctx, "SELECT lua_content IS NULL FROM quests").Scan(&missing))
	require.True(t, missing, "dry run preserves NULL")
	_, err = updateSelectedOverride(ctx, db, script, true)
	require.NoError(t, err)
	var content string
	var say bool
	require.NoError(t, db.QueryRowContext(ctx, "SELECT lua_content,has_say_event FROM quests").Scan(&content, &say))
	require.Equal(t, script.Lua, content)
	require.False(t, say)
}
