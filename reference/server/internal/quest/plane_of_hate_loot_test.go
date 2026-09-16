package quest

import (
	"database/sql"
	"testing"

	_ "github.com/go-sql-driver/mysql"
	"github.com/stretchr/testify/require"
)

func TestPlaneOfHateP99QuestAndNotableDropsAreAvailable(t *testing.T) {
	dsn := questRuntimeMatrixDSN(t)
	if dsn == "" {
		t.Skip("set IDLEQUEST_QUEST_TEST_DSN or DB_* env/.env to audit Plane of Hate loot")
	}
	database, err := sql.Open("mysql", dsn)
	require.NoError(t, err)
	defer database.Close()
	if err := database.Ping(); err != nil {
		t.Skipf("Plane of Hate loot database is unavailable: %v", err)
	}

	// Each source below is either directly documented by P99 or deliberately
	// retained as an availability fallback where Hate's pre/post-revamp spawn
	// behavior differs. Every source must be spawned in the playable hateplane.
	requiredSources := map[string]struct {
		itemID int
		npcIDs []int
	}{
		"Ranger epic emerald":            {20484, []int{76007, 76017, 76044, 76047}},
		"Necromancer epic eye":           {20656, []int{76007, 76016, 76019, 76045}},
		"Magician epic earth staff":      {11567, []int{76007, 76019}},
		"Warrior epic hand":              {20676, []int{76011, 76015}},
		"Enchanter epic vampire essence": {10624, []int{76004, 76047}},
		"Paladin epic breastplate":       {29001, []int{76013, 186150}},
		"Shadow Knight epic hide":        {14371, []int{76002}},
		"Nature's Defender skull":        {31427, []int{76018}},
		"Nature's Defender wand":         {12504, []int{76018}},
		"Revultant Whip":                 {5522, []int{76012}},
		"Darkwar Mask":                   {2190, []int{76012}},
		"Master of Spite breastplate":    {5187, []int{76044}},
		"Master of Spite helm":           {5188, []int{76044}},
		"Maestro Mempo":                  {11560, []int{76011}},
		"Innoruuk Dawnchaser":            {11555, []int{76007}},
		"Innoruuk Encyclopedia":          {11571, []int{76007}},
		"Innoruuk Shield":                {11551, []int{76007}},
		"Innoruuk Vexthorne":             {11557, []int{76007}},
		"Innoruuk unbound rod":           {11572, []int{76007}},
	}

	for name, requirement := range requiredSources {
		requirement := requirement
		t.Run(name, func(t *testing.T) {
			for _, npcID := range requirement.npcIDs {
				var count int
				err := database.QueryRow(`
SELECT COUNT(*)
FROM spawn2 s2
JOIN spawnentry se ON se.spawngroupID = s2.spawngroupID
JOIN npc_types nt ON nt.id = se.npcID
JOIN loottable_entries lte ON lte.loottable_id = nt.loottable_id
JOIN lootdrop_entries lde ON lde.lootdrop_id = lte.lootdrop_id
WHERE s2.zone = 'hateplane'
  AND nt.id = ?
  AND lde.item_id = ?
  AND lte.probability > 0
  AND lde.chance > 0`, npcID, requirement.itemID).Scan(&count)
				require.NoError(t, err)
				require.Positivef(t, count, "item %d must drop from hateplane NPC %d", requirement.itemID, npcID)
			}
		})
	}

	var enabledBookCount int
	err = database.QueryRow(`
SELECT COUNT(*)
FROM ground_spawns g
JOIN zone z ON z.zoneidnumber = g.zoneid AND z.version = g.version
JOIN idlequest_enabled_ground_spawns enabled ON enabled.ground_spawn_id = g.id
WHERE z.short_name = 'hateplane'
  AND g.item = 28016`).Scan(&enabledBookCount)
	require.NoError(t, err)
	require.Equal(t, 1, enabledBookCount, "exactly one playable Book of Souls spawn must be enabled")
}

func TestPlaneOfHateGenerousLootPoolsRemainSane(t *testing.T) {
	dsn := questRuntimeMatrixDSN(t)
	if dsn == "" {
		t.Skip("set IDLEQUEST_QUEST_TEST_DSN or DB_* env/.env to audit Plane of Hate loot")
	}
	database, err := sql.Open("mysql", dsn)
	require.NoError(t, err)
	defer database.Close()
	if err := database.Ping(); err != nil {
		t.Skipf("Plane of Hate loot database is unavailable: %v", err)
	}

	expectedPools := map[string]float64{
		"P99 Hate revultant rat notable drops":         50,
		"P99 Hate Maestro restored notable drops":      50,
		"P99 Hate Master of Spite restored armor":      30,
		"P99 Hate Innoruuk restored pre-revamp drops":  75,
		"P99 Hate scorn banshee Paladin epic fallback": 25,
	}
	for name, expectedProbability := range expectedPools {
		var probability float64
		var dropLimit int
		err := database.QueryRow(`
SELECT lte.probability, lte.droplimit
FROM lootdrop ld
JOIN loottable_entries lte ON lte.lootdrop_id = ld.id
WHERE ld.name = ?
LIMIT 1`, name).Scan(&probability, &dropLimit)
		require.NoError(t, err)
		require.Equal(t, expectedProbability, probability)
		require.Equal(t, 1, dropLimit, "%s should award at most one item from its weighted pool", name)
	}
}
