package overrides

import (
	"github.com/stretchr/testify/require"
	"testing"
	"testing/fstest"
)

func TestMaintainedModulesAndEnabledHeaders(t *testing.T) {
	modules, err := readModules(fstest.MapFS{
		"modules/README.md":      {Data: []byte("reference")},
		"modules/items.lua":      {Data: []byte("return {}")},
		"modules/sub/helper.lua": {Data: []byte("-- enabled: false\nreturn {}")},
	})
	require.NoError(t, err)
	require.Equal(t, []Module{{Name: "items", Lua: "return {}", Enabled: true}, {Name: "sub/helper", Lua: "-- enabled: false\nreturn {}", Enabled: false}}, modules)
	_, err = sourceEnabled("-- enabled: maybe\nreturn {}")
	require.Error(t, err)
	enabled, err := sourceEnabled("-- name: Alias\n-- enabled: false\nfunction event_say(e) end")
	require.NoError(t, err)
	require.False(t, enabled)
}
