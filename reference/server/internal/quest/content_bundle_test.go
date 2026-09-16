package quest

import (
	"database/sql"
	"net"
	"os"
	"strings"
	"testing"

	"github.com/go-sql-driver/mysql"
	"github.com/stretchr/testify/require"
)

// This reads a separately restored content database. It never seeds rewards or
// scripts and never writes to the normal development or production database.
func TestContentBundleRestoredRuntime(t *testing.T) {
	database := os.Getenv("IDLEQUEST_CONTENT_TEST_DATABASE")
	if database == "" {
		t.Skip("set IDLEQUEST_CONTENT_TEST_DATABASE to a restored scratch dataset")
	}
	require.True(t, strings.HasPrefix(database, "idlequest_content_"))
	host := os.Getenv("DB_HOST")
	require.Contains(t, []string{"127.0.0.1", "localhost", "::1"}, host)
	config := mysql.NewConfig()
	config.Net, config.Addr = "tcp", net.JoinHostPort(host, os.Getenv("DB_PORT"))
	config.User, config.Passwd, config.DBName = os.Getenv("DB_USER"), os.Getenv("DB_PASS"), database
	db, err := sql.Open("mysql", config.FormatDSN())
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })
	bridge := NewLuaBridge("upstream/projecteq")
	loadedModules := map[string]int{}
	bridge.ModuleLoader = func(name string) (string, bool, error) {
		var source string
		err := db.QueryRow("SELECT lua_content FROM quest_lua_modules WHERE module_name=? AND enabled=1", name).Scan(&source)
		if err == sql.ErrNoRows {
			return "", false, nil
		}
		if err != nil {
			return "", false, err
		}
		loadedModules[name]++
		return source, true, nil
	}
	readSource := func(zone, name string) string {
		var source string
		require.NoError(t, db.QueryRow("SELECT lua_content FROM quests WHERE zone=? AND name=? AND enabled=1", zone, name).Scan(&source))
		return source
	}
	t.Run("restored Freeport mail source accepts both independent deliveries", func(t *testing.T) {
		source := readSource("freportn", "Ton_Twostring")
		for _, item := range []int{18164, 18166} {
			event := progressionEvent(PlayerProxy{ID: 123, CharLevel: 2})
			event.Trade = &TradeProxy{Items: []int{item, 13005}}
			capture, err := bridge.ExecuteTradeFromSource(source, event)
			require.NoError(t, err)
			require.Equal(t, []int{13005}, capture.CurrentTrade.Items)
			require.EqualValues(t, 100, capture.Exp)
			require.GreaterOrEqual(t, capture.Currency.Gold, 8)
		}
		var count int
		require.NoError(t, db.QueryRow(`SELECT COUNT(*) FROM spawn2 s JOIN spawnentry e ON e.spawngroupID=s.spawngroupID
 JOIN npc_types n ON n.id=e.npcID WHERE s.zone='freportn' AND n.name='Ton_Twostring'`).Scan(&count))
		require.Positive(t, count, "restored NPC is linked to the intended zone")
		require.Positive(t, loadedModules["items"], "hand-ins use the restored shared module, not only filesystem source")
	})
	t.Run("restored death script links to NPC loot and authored spawn exclusion", func(t *testing.T) {
		event := progressionEvent(PlayerProxy{ID: 123, Name: "QuestOwner", CharClass: "Shaman", CharLevel: 50})
		capture, err := bridge.ExecuteEventFromSource(readSource("mistmoore", "an_advisor"), "event_death_complete", event)
		require.NoError(t, err)
		require.Len(t, capture.Spawns, 1)
		require.EqualValues(t, 59129, capture.Spawns[0].NPCTypeID)
		var disabled, loot int
		require.NoError(t, db.QueryRow("SELECT disabled FROM spawn2_disabled WHERE spawn2_id=7386 AND instance_id=0").Scan(&disabled))
		require.Equal(t, 1, disabled)
		require.NoError(t, db.QueryRow(`SELECT COUNT(*) FROM npc_types n
 JOIN loottable_entries t ON t.loottable_id=n.loottable_id
 JOIN lootdrop_entries d ON d.lootdrop_id=t.lootdrop_id JOIN items i ON i.id=d.item_id
 WHERE n.id=?`, capture.Spawns[0].NPCTypeID).Scan(&loot))
		require.Positive(t, loot, "script-created NPC retains its loot dependencies")
	})
}
