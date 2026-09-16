package quest

import (
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"testing"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/stretchr/testify/require"
)

func TestAllDatabaseQuestRuntimeHandlers(t *testing.T) {
	dsn := questRuntimeMatrixDSN(t)
	if dsn == "" {
		t.Skip("set IDLEQUEST_QUEST_TEST_DSN or DB_* env/.env to run the real runtime handler matrix")
	}
	database, err := sql.Open("mysql", dsn)
	require.NoError(t, err)
	defer database.Close()
	if err := database.Ping(); err != nil {
		t.Skipf("quest runtime matrix database is unavailable: %v", err)
	}
	classicKunarkOnly := os.Getenv("IDLEQUEST_QUEST_TEST_CLASSIC_KUNARK_ONLY") != "false"
	classicKunarkZones := map[string]bool(nil)
	if classicKunarkOnly {
		classicKunarkZones = ClassicKunarkQuestZoneSet()
	}
	query := `SELECT zone, name, lua_content FROM quests WHERE enabled=1 AND lua_content IS NOT NULL AND lua_content != '' ORDER BY zone, name`
	rows, err := database.Query(query)
	require.NoError(t, err)
	defer rows.Close()
	dataPath := os.Getenv("IDLEQUEST_QUEST_DATA_PATH")
	bridge := NewLuaBridge(dataPath)
	bridge.ModuleLoader = databaseQuestModuleLoader(database)
	bridge.ExecutionTimeout = 100 * time.Millisecond
	// This source-execution matrix has no live world population. Supply an
	// explicitly empty snapshot, not an absent capability or a fabricated NPC.
	// Positive cross-NPC behavior is tested in npc_lookup_content_test.go and
	// the world resolver tests; this matrix does not certify quest playability.
	emptyPopulation := QuestNPCResolver(func(QuestNPCQuery) (*NPCProxy, error) { return nil, nil })
	emptyNPCList := QuestNPCEnumerator(func() ([]NPCProxy, error) { return nil, nil })
	deferredHandlers := 0
	types := []RuntimeEventType{
		RuntimeEventSpawn, RuntimeEventSay, RuntimeEventTimer, RuntimeEventSignal,
		RuntimeEventDeath, RuntimeEventDeathComplete, RuntimeEventCombat, RuntimeEventAggro,
		RuntimeEventAttack, RuntimeEventSlay, RuntimeEventKilledMerit, RuntimeEventHP,
		RuntimeEventEnter, RuntimeEventExit, RuntimeEventWaypointArrive, RuntimeEventWaypointDepart,
		RuntimeEventEnterZone, RuntimeEventCastOn, RuntimeEventProximitySay, RuntimeEventFishSuccess, RuntimeEventForageSuccess,
		RuntimeEventTaskAccepted,
	}
	executed := 0
	scriptInits := 0
	loadedEncounters := 0
	encounterLoads := 0
	encounterRegistrations := 0
	expectedPrerequisites := map[string]string{
		"dranik/#Filligno_the_Slayer/event_signal":         "between nil and number",
		"gunthak/a_shadowed_assassin/event_death_complete": "compare string with nil",
	}
	for rows.Next() {
		var zone, npc, source string
		require.NoError(t, rows.Scan(&zone, &npc, &source))
		if classicKunarkOnly && !classicKunarkZones[strings.ToLower(strings.TrimSpace(zone))] {
			continue
		}
		state := map[string]any{}
		if npc == "script_init" {
			scriptInits++
			capture, executeErr := bridge.ExecuteEventFromSource(source, "__script_init__", &LuaEvent{ResolveNPC: emptyPopulation, ListNPCs: emptyNPCList, NPC: &NPCProxy{ID: 1, Name: npc}, Player: &PlayerProxy{ID: 1, Name: "QuestMatrix", CharClass: "Warrior", CharRace: "Human", CharLevel: 60, ClassID: 1, RaceID: 1, Tasks: map[int]bool{}}, Globals: map[string]string{}, Fields: map[string]any{}, SpawnInstanceID: 5000000000001})
			if executeErr != nil {
				t.Errorf("%s/%s script_init: %v", zone, npc, executeErr)
			}
			if capture != nil {
				loadedEncounters += len(capture.EncounterLoads)
			}
		}
		if scriptDefinesLuaHandler(source, "event_encounter_load") {
			encounterLoads++
			capture, executeErr := bridge.ExecuteEventFromSource(source, "event_encounter_load", &LuaEvent{ResolveNPC: emptyPopulation, ListNPCs: emptyNPCList, NPC: &NPCProxy{ID: 1, Name: npc, X: 10, Y: 20, Z: 30, HP: 100, MaxHP: 100}, Player: &PlayerProxy{ID: 1, Name: "QuestMatrix", CharClass: "Warrior", CharRace: "Human", CharLevel: 60, ClassID: 1, RaceID: 1, Tasks: map[int]bool{}}, Globals: map[string]string{}, Fields: map[string]any{}, SpawnInstanceID: 5000000000001})
			if executeErr != nil {
				t.Errorf("%s/%s event_encounter_load: %v", zone, npc, executeErr)
			}
			if capture != nil {
				encounterRegistrations += len(capture.Registrations)
			}
		}
		for _, eventType := range types {
			handler := "event_" + string(eventType)
			if !scriptDefinesLuaHandler(source, handler) {
				continue
			}
			executed++
			fields := map[string]any{"timer": "matrix", "signal": 1, "joined": true, "hp_event": 50, "inc_hp_event": 50, "wp": 1, "task_id": 1, "activity_id": 1, "item_id": 13019}
			selfIsPlayer := npc == "player" || npc == "global_player"
			event := &LuaEvent{ResolveNPC: emptyPopulation, ListNPCs: emptyNPCList, NPC: &NPCProxy{ID: 1, Name: npc, X: 10, Y: 20, Z: 30, HP: 100, MaxHP: 100}, Player: &PlayerProxy{ID: 1, Name: "QuestMatrix", CharClass: "Warrior", CharRace: "Human", CharLevel: 60, ClassID: 1, RaceID: 1, Tasks: map[int]bool{}}, Globals: map[string]string{}, Fields: fields, SpawnInstanceID: 5000000000001, ScriptState: state, SelfIsPlayer: selfIsPlayer}
			// Explicit source-only fixture: joined combat has one player target;
			// no persisted timers exist. Runtime capture still overlays operations
			// emitted in this event. This is not a live combat/persistence test.
			event.ReadTimer = func(string) (bool, bool, error) { return false, false, nil }
			event.ReadNPCCombat = func(QuestSpellActor, QuestNPCCombatSelection) (QuestCombatActor, error) {
				return QuestCombatActor{Player: event.Player}, nil
			}
			capture, executeErr := bridge.ExecuteEventFromSource(source, handler, event)
			if executeErr == nil && capture != nil {
				state = capture.ScriptState
				if len(capture.DeferredAPIs) > 0 {
					deferredHandlers++
					t.Logf("%s/%s %s incomplete effects: %v", zone, npc, handler, capture.DeferredAPIs)
				}
			}
			if executeErr != nil {
				key := zone + "/" + npc + "/" + handler
				if expected, ok := expectedPrerequisites[key]; ok && strings.Contains(executeErr.Error(), expected) {
					continue
				}
				lineText := ""
				if match := regexp.MustCompile(`<string>:(\d+)`).FindStringSubmatch(executeErr.Error()); len(match) == 2 {
					line, _ := strconv.Atoi(match[1])
					lineText = sourceLine(source, line)
				}
				t.Errorf("%s/%s %s [%s]: %v", zone, npc, handler, lineText, executeErr)
			}
		}
	}
	require.NoError(t, rows.Err())
	require.Positive(t, executed)
	if !classicKunarkOnly {
		require.Positive(t, scriptInits)
		require.Positive(t, loadedEncounters)
		require.Positive(t, encounterLoads)
		require.Positive(t, encounterRegistrations)
	}
	t.Logf("Source-only matrix uses an empty NPC population; %d handlers reached unsupported effects. This is not quest completion coverage.", deferredHandlers)
	t.Logf("executed %d real NPC/player/encounter runtime quest handlers, %d script_init rows loading %d encounters, and %d encounter loads with %d registrations", executed, scriptInits, loadedEncounters, encounterLoads, encounterRegistrations)
}

func questRuntimeMatrixDSN(t *testing.T) string {
	if dsn := strings.TrimSpace(os.Getenv("IDLEQUEST_QUEST_TEST_DSN")); dsn != "" {
		return dsn
	}
	env := map[string]string{}
	for _, candidate := range []string{".env", "../.env", "../../.env", "../../../.env"} {
		for key, value := range readDotEnvForTest(t, candidate) {
			env[key] = value
		}
	}
	for _, key := range []string{"DB_HOST", "DB_PORT", "DB_USER", "DB_PASS", "DB_NAME"} {
		if value := os.Getenv(key); value != "" {
			env[key] = value
		}
	}
	user := env["DB_USER"]
	name := env["DB_NAME"]
	if user == "" || name == "" {
		return ""
	}
	host := env["DB_HOST"]
	if host == "" {
		host = "127.0.0.1"
	}
	port := env["DB_PORT"]
	if port == "" {
		port = "3306"
	}
	return fmt.Sprintf("%s:%s@tcp(%s:%s)/%s", user, env["DB_PASS"], host, port, name)
}

func readDotEnvForTest(t *testing.T, file string) map[string]string {
	t.Helper()
	out := map[string]string{}
	content, err := os.ReadFile(filepath.Clean(file))
	if err != nil {
		return out
	}
	for _, line := range strings.Split(string(content), "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		key, value, ok := strings.Cut(line, "=")
		if !ok {
			continue
		}
		out[strings.TrimSpace(key)] = strings.Trim(strings.TrimSpace(value), `"'`)
	}
	return out
}

func databaseQuestModuleLoader(database *sql.DB) func(string) (string, bool, error) {
	return func(name string) (string, bool, error) {
		var content string
		err := database.QueryRow(`SELECT lua_content FROM quest_lua_modules WHERE module_name=? AND enabled=1 LIMIT 1`, name).Scan(&content)
		if err == sql.ErrNoRows {
			return "", false, nil
		}
		if err != nil {
			if strings.Contains(err.Error(), "quest_lua_modules") {
				return "", false, nil
			}
			return "", false, err
		}
		return content, content != "", nil
	}
}
