package quest

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestLoadTurnInScenarioManifest(t *testing.T) {
	path := filepath.Join(t.TempDir(), "manifest.json")
	err := os.WriteFile(path, []byte(`{
  "version": 1,
  "overrides": [{
    "zone": "qeynos",
    "npc": "Guildmaster",
    "callIndex": 0,
    "name": "cleric branch",
    "player": {"class": "Cleric", "level": 10, "activeTasks": [5]},
    "globals": {"badge_stage": "2"},
    "expect": {"activated": true, "consumedItems": [1001], "experience": 50}
  }]
}`), 0o600)
	require.NoError(t, err)

	manifest, err := LoadTurnInScenarioManifest(path)
	require.NoError(t, err)
	require.Len(t, manifest.Overrides, 1)
	assert.Equal(t, "cleric branch", manifest.Overrides[0].Name)
	assert.Equal(t, "Cleric", manifest.Overrides[0].Player.Class)
	assert.Equal(t, "2", manifest.Overrides[0].Globals["badge_stage"])
}

func TestLoadTurnInScenarioManifestRejectsUnaddressableOverride(t *testing.T) {
	path := filepath.Join(t.TempDir(), "manifest.json")
	require.NoError(t, os.WriteFile(path, []byte(`{"version":1,"overrides":[{"zone":"qeynos","npc":"NPC"}]}`), 0o600))
	_, err := LoadTurnInScenarioManifest(path)
	assert.ErrorContains(t, err, "callIndex or line")
}
