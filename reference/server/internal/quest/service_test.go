package quest

import (
	"database/sql"
	"os"
	"testing"

	"github.com/go-jet/jet/v2/stmtcache"
	_ "github.com/go-sql-driver/mysql"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestFormatQuestTextPlayerTokens(t *testing.T) {
	player := PlayerInfo{
		Name:       "Vayoen",
		LastName:   "Nightbloom",
		ClassName:  "Shadow Knight",
		RaceName:   "Iksar",
		Level:      60,
		GenderName: "Male",
		DeityName:  "Innoruuk",
	}

	text := "Greetings $name ${name}, $race ${class} level $level. Surname: ${surname}. Gender: $gender. Deity: ${deity}."

	assert.Equal(
		t,
		"Greetings Vayoen Vayoen, Iksar Shadow Knight level 60. Surname: Nightbloom. Gender: Male. Deity: Innoruuk.",
		formatQuestText(text, player),
	)
}

func TestFormatQuestTextSkipsUnknownTokensWhenValueMissing(t *testing.T) {
	text := "Greetings $name of $deity."

	assert.Equal(t, "Greetings Vayoen of $deity.", formatQuestText(text, PlayerInfo{Name: "Vayoen"}))
}

func TestGetRaceNameSupportsClassicAndEQEmuIksarIDs(t *testing.T) {
	service := &Service{}

	assert.Equal(t, "Iksar", service.getRaceName(13))
	assert.Equal(t, "Iksar", service.getRaceName(128))
}

func TestQuestScriptNameCandidatesIncludeLegacyBacktickFilename(t *testing.T) {
	assert.Equal(t, []string{"#Tasi_V`ghera", "#Tasi_V-ghera"}, questScriptNameCandidates("#Tasi_V`ghera"))
	assert.Equal(t, []string{"Stanos_Herkanor"}, questScriptNameCandidates("Stanos_Herkanor"))
}

func TestQuestScriptNameCandidatesIncludeTrimmedDuplicatedFinalLetterFallback(t *testing.T) {
	assert.Equal(t, []string{"Forager_Grikk", "Forager_Grik"}, questScriptNameCandidates("Forager_Grikk"))
	assert.Equal(t, []string{"Forager_Grik"}, questScriptNameCandidates("Forager_Grik"))
}

func TestQuestScriptNameCandidatesForNPCIncludesNumericIDFallback(t *testing.T) {
	assert.Equal(t, []string{"Orc_Centurion", "10000"}, questScriptNameCandidatesForNPC("Orc_Centurion", 10000))
	assert.Equal(t, []string{"10000"}, questScriptNameCandidatesForNPC("10000", 10000))
}

func TestQuestScriptLooksLikePerlRejectsActualPerl(t *testing.T) {
	assert.True(t, questScriptLooksLikePerl(`
sub EVENT_SAY {
  quest::say("hello");
}
`))
	assert.True(t, questScriptLooksLikePerl(`
my $item = 1;
`))
}

func TestQuestScriptLooksLikePerlAllowsConvertedLuaWithLegacyComment(t *testing.T) {
	assert.False(t, questScriptLooksLikePerl(`
function event_trade(e)
  item_lib.return_items(e.self, e.other, e.trade);
end -- sub EVENT_ITEM
`))
}

func TestIsQuestScriptExcludedFromIdleQuestExcludesNewerArtisanCulturalQuests(t *testing.T) {
	assert.True(t, IsQuestScriptExcludedFromIdleQuest(
		"Artisan_Vidi_Cogsworthy",
		"-- Newer Cultural Tradeskill Armor Quest -- Gnome\nfunction event_trade(e) end",
	))
	assert.True(t, IsQuestScriptExcludedFromIdleQuest(
		"Horgram",
		"--Frostfell A Gift for Tinam (#4) -- TODO Update Task ID's\nfunction event_trade(e) end",
	))
	assert.False(t, IsQuestScriptExcludedFromIdleQuest(
		"Artisan_Vidi_Cogsworthy",
		"-- Some other artisan quest\nfunction event_trade(e) end",
	))
	assert.False(t, IsQuestScriptExcludedFromIdleQuest(
		"Not_An_Artisan",
		"-- Newer Cultural Tradeskill Armor Quest -- Gnome\nfunction event_trade(e) end",
	))
}

func TestIsQuestScriptExcludedFromIdleQuestTestsExcludesNonClassicNumericScripts(t *testing.T) {
	assert.True(t, IsQuestScriptExcludedFromIdleQuestTests("cazicthule", "48255", "function event_trade(e) end"))
	assert.True(t, IsQuestScriptExcludedFromIdleQuestTests("freporte", "10000", "function event_trade(e) end"))
	assert.False(t, IsQuestScriptExcludedFromIdleQuestTests("airplane", "Dugaas_Helpyre", "function event_trade(e) end"))
}

func TestCaptureHasEffectsAcceptsGlobalOnlyTurnIn(t *testing.T) {
	assert.True(t, captureHasEffects(&QuestCapture{
		Globals: map[string]GlobalUpdate{"wizepicA": {Name: "wizepicA", Value: "1"}},
	}))
}

func TestCaptureHasEffectsAcceptsSkillUpdateOnlyTurnIn(t *testing.T) {
	assert.True(t, captureHasEffects(&QuestCapture{
		SkillUpdates: []QuestSkillUpdate{{SkillID: 43, Value: 49}},
	}))
}

func TestQuestGlobalScopeIDsMatchEQEmuOptionBits(t *testing.T) {
	tests := []struct {
		name    string
		options int
		charID  int32
		npcID   int32
		zoneID  int32
	}{
		{name: "zero is current npc current player current zone", options: 0, charID: 100, npcID: 200, zoneID: 300},
		{name: "one is all npcs current player current zone", options: 1, charID: 100, npcID: 0, zoneID: 300},
		{name: "two is current npc all players current zone", options: 2, charID: 0, npcID: 200, zoneID: 300},
		{name: "three is all npcs all players current zone", options: 3, charID: 0, npcID: 0, zoneID: 300},
		{name: "four is current npc current player all zones", options: 4, charID: 100, npcID: 200, zoneID: 0},
		{name: "five is all npcs current player all zones", options: 5, charID: 100, npcID: 0, zoneID: 0},
		{name: "six is current npc all players all zones", options: 6, charID: 0, npcID: 200, zoneID: 0},
		{name: "seven is all npcs all players all zones", options: 7, charID: 0, npcID: 0, zoneID: 0},
		{name: "invalid falls back to zero", options: 99, charID: 100, npcID: 200, zoneID: 300},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			charID, npcID, zoneID := questGlobalScopeIDs(100, 200, 300, tt.options)
			assert.Equal(t, tt.charID, charID)
			assert.Equal(t, tt.npcID, npcID)
			assert.Equal(t, tt.zoneID, zoneID)
		})
	}
}

func TestQuestRuntimeScriptStateKeyUsesStaticNPCFallback(t *testing.T) {
	assert.Equal(t, int64(5001), questRuntimeScriptStateKey(2029, 5001))
	assert.Equal(t, int64(-2029), questRuntimeScriptStateKey(2029, 0))
	assert.Equal(t, int64(0), questRuntimeScriptStateKey(0, 0))
}

func TestLiveServiceExecuteEventLoadsNumericNPCScript(t *testing.T) {
	if os.Getenv("IDLEQUEST_LIVE_DB_TESTS") != "true" {
		t.Skip("set IDLEQUEST_LIVE_DB_TESTS=true to run against local MySQL")
	}
	dsn := os.Getenv("IDLEQUEST_TEST_DSN")
	if dsn == "" {
		dsn = "idlequest:idlequest@tcp(127.0.0.1:3306)/eqgo?parseTime=true"
	}
	rawDB, err := sql.Open("mysql", dsn)
	require.NoError(t, err)
	defer rawDB.Close()

	service := NewService(stmtcache.New(rawDB), ".")
	seenSpawn := false
	for i := 0; i < 100; i++ {
		capture, err := service.executeEvent("death_complete", "a_black_reaver", 90192, "citymist", &LuaEvent{
			NPC:             &NPCProxy{ID: 90192, Name: "a black reaver", X: 1, Y: 2, Z: 3, Heading: 4},
			Player:          &PlayerProxy{ID: 1, Name: "Tester", Tasks: map[int]bool{}},
			Globals:         map[string]string{},
			Fields:          map[string]any{},
			SpawnInstanceID: int64(i + 1),
		})
		require.NoError(t, err)
		if capture != nil && len(capture.Spawns) > 0 {
			seenSpawn = true
			break
		}
	}
	assert.True(t, seenSpawn, "numeric 90192 citymist script should capture a spawn from event_death_complete")
}

func TestLivePrimeRuntimeEventCacheIncludesZoneAndEncounterHandlers(t *testing.T) {
	if os.Getenv("IDLEQUEST_LIVE_DB_TESTS") != "true" {
		t.Skip("set IDLEQUEST_LIVE_DB_TESTS=true to run against local MySQL")
	}
	dsn := os.Getenv("IDLEQUEST_TEST_DSN")
	if dsn == "" {
		dsn = "idlequest:idlequest@tcp(127.0.0.1:3306)/eqgo?parseTime=true"
	}
	rawDB, err := sql.Open("mysql", dsn)
	require.NoError(t, err)
	defer rawDB.Close()

	service := NewService(stmtcache.New(rawDB), ".")
	require.NoError(t, service.PrimeRuntimeEventCache("qeynos", map[int32]string{
		1042: "Trumpy_Irontoe",
		1074: "Sunsa",
	}, []RuntimeEventType{
		RuntimeEventSpawn,
		RuntimeEventWaypointArrive,
		RuntimeEventHP,
	}))

	hasWaypoint, err := service.HasRuntimeEvent(1042, "qeynos", RuntimeEventWaypointArrive)
	require.NoError(t, err)
	assert.True(t, hasWaypoint, "Trumpy's encounter-registered waypoint handler must be retained")
	hasSpawn, err := service.HasRuntimeEvent(1042, "qeynos", RuntimeEventSpawn)
	require.NoError(t, err)
	assert.True(t, hasSpawn, "Trumpy's encounter-registered spawn handler must be retained")
	hasHP, err := service.HasRuntimeEvent(1074, "qeynos", RuntimeEventHP)
	require.NoError(t, err)
	assert.False(t, hasHP)
}
