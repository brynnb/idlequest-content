package quest

import (
	"database/sql"
	"fmt"
	"os"
	"testing"

	_ "github.com/go-sql-driver/mysql"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestRunTurnInMatrix(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	scripts := []QuestScript{{
		Zone: "freportw", NPC: "Captain_Hazran",
		Source: `function event_trade(e)
local item_lib = require("items")
if item_lib.check_turn_in(e.trade, {item1 = 13916}) then
  e.self:Say("Good work!")
  e.other:Faction(265, 10)
end
end`,
	}}

	report := RunTurnInMatrix(NewLuaBridge("."), scripts)
	assert.Equal(t, 1, report.DiscoveredCases)
	assert.Equal(t, 1, report.ExecutedCases)
	assert.Equal(t, 1, report.ActivatedCases)
	assert.Empty(t, report.Failures())
	assert.Contains(t, report.Summary(), "unsupported=0")
	assert.Contains(t, report.Summary(), "failed=0")
}

func TestRunTurnInMatrixAppliesConditionalOverrideAndExpectations(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "qeynos", NPC: "Guildmaster", Source: `function event_trade(e)
local item_lib = require("items")
if e.other:GetClassName() == "Cleric" and item_lib.check_turn_in(e.trade, {item1 = 1001}) then
  e.self:Say("Welcome, cleric")
  e.other:SummonItem(2002)
  e.other:AddEXP(50)
end
end`}
	callIndex := 0
	activated := true
	experience := 50
	report := RunTurnInMatrixWithOverrides(NewLuaBridge("."), []QuestScript{script}, []TurnInScenarioOverride{{
		Zone: "qeynos", NPC: "Guildmaster", CallIndex: &callIndex, Name: "cleric branch",
		Player: &TurnInPlayerOverride{Class: "Cleric", Level: 10},
		Expect: &TurnInExpectation{
			Activated: &activated, ConsumedItems: []int{1001},
			RewardItems: []QuestReward{{ItemID: 2002, Count: 1}}, Experience: &experience,
			ResponseContains: []string{"Welcome, cleric"},
		},
	}})

	require.Len(t, report.Results, 1)
	assert.Equal(t, "cleric branch", report.Results[0].CaseName)
	assert.Empty(t, report.Results[0].ValidationErrors)
	assert.Empty(t, report.UnmatchedOverrides)
	assert.Empty(t, report.Failures())
}

func TestRunTurnInMatrixReportsUnmatchedAndFailedExpectations(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "qeynos", NPC: "NPC", Source: `function event_trade(e)
local item_lib = require("items")
if item_lib.check_turn_in(e.trade, {item1 = 1}) then e.other:AddEXP(5) end
end`}
	callIndex, missingIndex, wrongExperience := 0, 9, 999
	report := RunTurnInMatrixWithOverrides(NewLuaBridge("."), []QuestScript{script}, []TurnInScenarioOverride{
		{Zone: "qeynos", NPC: "NPC", CallIndex: &callIndex, Expect: &TurnInExpectation{Experience: &wrongExperience}},
		{Zone: "qeynos", NPC: "NPC", CallIndex: &missingIndex},
	})
	require.Len(t, report.Failures(), 1)
	assert.Equal(t, TurnInCaseMismatch, report.Failures()[0].Status)
	assert.Contains(t, report.Failures()[0].ValidationErrors[0], "experience")
	require.Len(t, report.UnmatchedOverrides, 1)
}

func TestRunTurnInMatrixClassifiesMissingLuaAPI(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "qeynos", NPC: "NPC", Source: `function event_trade(e)
local item_lib = require("items")
if item_lib.check_turn_in(e.trade, {item1 = 1}) then eq.missing_api() end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Failures(), 1)
	assert.Equal(t, TurnInCaseMissingAPI, report.Failures()[0].Status)
	assert.Equal(t, "eq.missing_api", report.Failures()[0].MissingAPI)
	assert.Contains(t, report.Summary(), "missing-api=1")
}

func TestRunTurnInMatrixExecutesDynamicRequirementsFromOverride(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "qeynos", NPC: "DynamicNPC", Source: `function event_trade(e)
local item_lib = require("items")
local requirements = {item1 = 77, gold = 3}
if item_lib.check_turn_in(e.trade, requirements) then e.other:AddEXP(25) end
end`}
	callIndex, experience := 0, 25
	report := RunTurnInMatrixWithOverrides(NewLuaBridge("."), []QuestScript{script}, []TurnInScenarioOverride{{
		Zone: "qeynos", NPC: "DynamicNPC", CallIndex: &callIndex, Name: "dynamic requirements",
		Requirements: &TurnInRequirements{Items: []int{77}, Currency: QuestCurrency{Gold: 3}},
		Expect:       &TurnInExpectation{ConsumedItems: []int{77}, Experience: &experience},
	}})

	assert.Empty(t, report.Unsupported)
	require.Len(t, report.Results, 1)
	assert.True(t, report.Results[0].Activated)
	assert.Empty(t, report.Failures())
}

func TestRunTurnInMatrixInfersSimplePlayerPrerequisites(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "cauldron", NPC: "Treanik_Ireblade", Source: `function event_trade(e)
local item_lib = require("items")
if e.other:GetClass() == Class.BERSERKER and e.other:GetLevel() >= 45 and item_lib.check_turn_in(e.trade, {item1 = 555}) then
  e.other:SummonItem(777)
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 1)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	assert.True(t, report.Results[0].Activated)
	require.NotNil(t, report.Results[0].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 777, Count: 1}}, report.Results[0].Capture.Items)
}

func TestRunTurnInMatrixInfersLocalLevelAliasBranches(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "butcher", NPC: "Dapper_Blackhammer", Source: `function event_trade(e)
local item_lib = require("items")
local level = e.other:GetLevel()
if level >= 40 then
  if item_lib.check_turn_in(e.trade, {item1 = 12880, item2 = 6552, platinum = 500}) then
    e.other:QuestReward(e.self,0,0,0,0,6551,25000)
  end
else
  if item_lib.check_turn_in(e.trade, {item1 = 12880, item2 = 6552, platinum = 500}) then
    e.other:QuestReward(e.self,0,0,0,500,6551,25000)
    e.other:SummonItem(6552)
  end
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 2)
	require.NotNil(t, report.Results[0].Player)
	assert.Equal(t, 40, report.Results[0].Player.Level)
	assert.Equal(t, []QuestReward{{ItemID: 6551, Count: 1}}, report.Results[0].Capture.Items)
	assert.Equal(t, 0, report.Results[0].Capture.Currency.Platinum)
	require.NotNil(t, report.Results[1].Player)
	assert.Equal(t, 39, report.Results[1].Player.Level)
	assert.Equal(t, []QuestReward{{ItemID: 6551, Count: 1}, {ItemID: 6552, Count: 1}}, report.Results[1].Capture.Items)
	assert.Equal(t, 500, report.Results[1].Capture.Currency.Platinum)
}

func TestRunTurnInMatrixInfersQGlobalMinimumPrerequisite(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "bazaar", NPC: "Eryke_Stremstin", Source: `function event_trade(e)
local item_lib = require("items")
local qglobals = eq.get_qglobals(e.other)
if qglobals["monk_epic"] ~= nil and qglobals["monk_epic"] >= "6" and item_lib.check_turn_in(e.trade, {platinum = 1000}) then
  e.other:SummonItem(48123)
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 1)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	require.NotNil(t, report.Results[0].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 48123, Count: 1}}, report.Results[0].Capture.Items)
}

func TestRunTurnInMatrixInfersHighestQGlobalMinimumBeforeScenario(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "draniksscar", NPC: "Korbuk_Brimblade", Source: `function event_trade(e)
local item_lib = require("items")
local qglobals = eq.get_qglobals(e.other)
if qglobals["warrior_epic"] ~= nil then
  if qglobals["warrior_epic"] >= "1" and item_lib.check_turn_in(e.trade, {item1 = 1}) then
    e.other:SummonItem(10)
  end
  if qglobals["warrior_epic"] >= "5" and item_lib.check_turn_in(e.trade, {item1 = 2}) then
    e.other:SummonItem(20)
  end
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 2)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	assert.Equal(t, TurnInCaseActivated, report.Results[1].Status)
	require.NotNil(t, report.Results[1].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 20, Count: 1}}, report.Results[1].Capture.Items)
}

func TestRunTurnInMatrixExportsFullContextQGlobalRetryPrerequisite(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "butcher", NPC: "Kandin_Firepot", Source: `function event_trade(e)
local item_lib = require("items")
if item_lib.check_turn_in(e.trade, {item1 = 18169}) then
  eq.set_global("wizepicK","1",0,"F")
elseif qglobals["wizepicK"] ~= nil then
  if item_lib.check_turn_in(e.trade, {item1 = 14349}) then
    e.other:SummonItem(14337)
  elseif item_lib.check_turn_in(e.trade, {item1 = 14333, item2 = 14332}) then
    e.other:SummonItem(14339)
    e.other:SummonItem(14336)
  end
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 3)
	assert.Equal(t, TurnInCaseActivated, report.Results[2].Status)
	assert.Equal(t, map[string]string{"wizepicK": "1"}, report.Results[2].Globals)
}

func TestRunTurnInMatrixInfersHigherQGlobalMinimumAfterExactStage(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "draniksscar", NPC: "Korbuk_Brimblade", Source: `function event_trade(e)
local item_lib = require("items")
local qglobals = eq.get_qglobals(e.other)
if qglobals["warrior_epic"] == "10" and item_lib.check_turn_in(e.trade, {item1 = 1}) then
  e.other:SummonItem(10)
end
if qglobals["warrior_epic"] >= "13" and item_lib.check_turn_in(e.trade, {item1 = 2}) then
  e.other:SummonItem(20)
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 2)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	assert.Equal(t, TurnInCaseActivated, report.Results[1].Status)
	require.NotNil(t, report.Results[1].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 20, Count: 1}}, report.Results[1].Capture.Items)
}

func TestRunTurnInMatrixInfersNPCSelfPrerequisites(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "crushbone", NPC: "a_dwarven_slave", Source: `function event_trade(e)
local item_lib = require("items")
if e.self:GetRace() == 8 and e.self:GetGender() == 0 then
  if item_lib.check_turn_in(e.trade, {item1 = 20016}) then
    e.other:SummonItem(18905)
  end
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 1)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	require.NotNil(t, report.Results[0].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 18905, Count: 1}}, report.Results[0].Capture.Items)
}

func TestRunTurnInMatrixInfersTaskActivityPrerequisite(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "akanon", NPC: "Artisan_Vidi_Cogsworthy", Source: `function event_trade(e)
local item_lib = require("items")
if e.other:GetBaseRace() == e.self:GetBaseRace() then
  if e.other:IsTaskActivityActive(5784,4) and item_lib.check_turn_in(e.trade, {item1 = 34997}) then
    e.other:QuestReward(e.self,{itemid = 38453})
  end
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 1)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	require.NotNil(t, report.Results[0].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 38453, Count: 1}}, report.Results[0].Capture.Items)
}

func TestRunTurnInMatrixInfersHeldItemPrerequisite(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "airplane", NPC: "Inte_Akera", Source: `function event_trade(e)
local item_lib = require("items")
if e.other:HasItem(69953) and e.other:HasItem(69954) and item_lib.check_turn_in(e.trade, {item1 = 47100}) then
  e.other:SummonItem(69957)
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 1)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	require.NotNil(t, report.Results[0].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 69957, Count: 1}}, report.Results[0].Capture.Items)
}

func TestRunTurnInMatrixInfersLegacyStringClassPrerequisite(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "freeporteast", NPC: "Guard_Alayle", Source: `function event_trade(e)
local item_lib = require("items")
if e.other:Class() == "Paladin" and item_lib.check_turn_in(e.trade, {item1 = 18817}) then
  e.other:SummonItem(18818)
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 1)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	require.NotNil(t, report.Results[0].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 18818, Count: 1}}, report.Results[0].Capture.Items)
}

func TestRunTurnInMatrixDoesNotApplyEarlierClassGateToLaterElseIf(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "freeportwest", NPC: "Shana_Liskia", Source: `function event_trade(e)
local item_lib = require("items")
if e.other:Class() == "Enchanter" then
  if item_lib.check_turn_in(e.trade, {item1 = 9917}) then
    e.other:SummonItem(9938)
  end
elseif item_lib.check_turn_in(e.trade, {item1 = 62617}) then
  e.other:SummonItem(62654)
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 2)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	assert.Equal(t, TurnInCaseActivated, report.Results[1].Status)
	require.NotNil(t, report.Results[1].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 62654, Count: 1}}, report.Results[1].Capture.Items)
}

func TestRunTurnInMatrixInfersNPCTypePrerequisite(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "grobb", NPC: "a_skeleton", Source: `function event_trade(e)
local item_lib = require("items")
if e.self:GetNPCTypeID() == 52056 and item_lib.check_turn_in(e.trade, {item1 = 12211}) then
  e.other:SummonItem(12213)
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 1)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	require.NotNil(t, report.Results[0].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 12213, Count: 1}}, report.Results[0].Capture.Items)
}

func TestRunTurnInMatrixInfersBranchScopedPrerequisites(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "cabeast", NPC: "Hierophant_Granix", Source: `function event_trade(e)
local item_lib = require("items")
if e.other:HasItem(5146) then
  if item_lib.check_turn_in(e.trade, {item1 = 30984}) then
    e.other:SummonItem(1)
  end
elseif item_lib.check_turn_in(e.trade, {item1 = 30988, item2 = 5146}) then
  e.other:SummonItem(5148)
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 2)
	assert.Equal(t, TurnInCaseActivated, report.Results[1].Status)
	assert.Equal(t, []QuestReward{{ItemID: 5148, Count: 1}}, report.Results[1].Capture.Items)
}

func TestInventoryAfterTradeRemovesOnlyHandedInItems(t *testing.T) {
	remaining := inventoryAfterTrade(map[int]int{5146: 2, 30988: 1, 5145: 1}, []int{5146, 30988})

	assert.True(t, remaining[5146])
	assert.True(t, remaining[5145])
	assert.False(t, remaining[30988])
}

func TestRunTurnInMatrixInfersLocalClassAndRaceAliases(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "rivervale", NPC: "alias_user", Source: `function event_trade(e)
local item_lib = require("items")
local class = e.other:GetClass()
local race = e.other:GetRaceName()
if race == "Halfling" and item_lib.check_turn_in(e.trade, {item1 = 12372}) then
  e.other:SummonItem(38447)
elseif (class == Class.BARD or class == Class.ROGUE) and item_lib.check_turn_in(e.trade, {item1 = 11139}) then
  e.other:SummonItem(52355)
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 2)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	assert.Equal(t, TurnInCaseActivated, report.Results[1].Status)
}

func TestRunTurnInMatrixInfersDotQGlobalsAndNPCPosition(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "thurgadina", NPC: "Dardek_Bladewright", Source: `function event_trade(e)
local qglobals = eq.get_qglobals(e.other)
local item_lib = require("items")
if qglobals.wiz_epic_pre == "2" and item_lib.check_turn_in(e.trade, {item1 = 16675}) then
  e.other:SummonItem(16675)
end
if e.self:GetX() > -142 and e.self:GetY() < -402 then
  if qglobals["warrior_pre"] == "4" and item_lib.check_turn_in(e.trade, {item1 = 60285}) then
    e.other:SummonItem(60292)
  end
end
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 2)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	assert.Equal(t, TurnInCaseActivated, report.Results[1].Status)
}

func TestRunTurnInMatrixExecutesContainingTradeHandler(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "encounters", NPC: "ring_war", Source: `function Churn_Trade(e)
local item_lib = require("items")
if item_lib.check_turn_in(e.trade, {item1 = 1741}) then
  e.other:SummonItem(1746)
  e.self:Depop()
end
end

function event_encounter_load(e)
  eq.register_npc_event('ring_war', Event.trade, 118169, Churn_Trade)
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 1)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	require.NotNil(t, report.Results[0].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 1746, Count: 1}}, report.Results[0].Capture.Items)
	require.Len(t, report.Results[0].Capture.Depops, 1)
}

func TestRunTurnInMatrixExecutesRegisteredLocalTradeHandler(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	script := QuestScript{Zone: "encounters", NPC: "local_trade", Source: `local item_lib = require("items")
local function contact_trade(e)
if item_lib.check_turn_in(e.trade, {item1 = 36214}) then
  e.other:SummonItem(36215)
end
end

function event_encounter_load(e)
  eq.register_npc_event(Event.trade, 338422, contact_trade)
end`}

	report := RunTurnInMatrix(NewLuaBridge("."), []QuestScript{script})

	require.Len(t, report.Results, 1)
	assert.Equal(t, TurnInCaseActivated, report.Results[0].Status)
	require.NotNil(t, report.Results[0].Capture)
	assert.Equal(t, []QuestReward{{ItemID: 36215, Count: 1}}, report.Results[0].Capture.Items)
}

// TestAllDatabaseQuestTurnIns executes real enabled quest scripts when a DSN is
// explicitly supplied. It is opt-in because normal unit tests do not require a
// running MySQL database.
//
//	IDLEQUEST_QUEST_TEST_DSN='user:pass@tcp(localhost:3306)/eqgo?parseTime=true' \
//	  go test ./internal/quest -run TestAllDatabaseQuestTurnIns -v
func TestAllDatabaseQuestTurnIns(t *testing.T) {
	dsn := os.Getenv("IDLEQUEST_QUEST_TEST_DSN")
	if dsn == "" {
		t.Skip("set IDLEQUEST_QUEST_TEST_DSN to run the real quest matrix")
	}

	db, err := sql.Open("mysql", dsn)
	require.NoError(t, err)
	defer db.Close()
	require.NoError(t, db.Ping())

	rows, err := db.Query(`
SELECT zone, name, lua_content
FROM quests
WHERE enabled = 1
  AND lua_content IS NOT NULL
  AND lua_content != ''
  AND LOWER(lua_content) LIKE '%event_trade%'
ORDER BY zone, name`)
	require.NoError(t, err)
	defer rows.Close()

	var scripts []QuestScript
	for rows.Next() {
		var script QuestScript
		require.NoError(t, rows.Scan(&script.Zone, &script.NPC, &script.Source))
		if IsQuestScriptExcludedFromIdleQuestTests(script.Zone, script.NPC, script.Source) {
			continue
		}
		scripts = append(scripts, script)
	}
	require.NoError(t, rows.Err())
	require.NotEmpty(t, scripts, "database contains no enabled event_trade scripts")

	dataPath := os.Getenv("IDLEQUEST_QUEST_DATA_PATH")
	if dataPath == "" {
		dataPath = "."
		setupRealItemsLua(t)
		t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	}
	var overrides []TurnInScenarioOverride
	manifestPath := os.Getenv("IDLEQUEST_QUEST_TEST_MANIFEST")
	if manifestPath == "" {
		manifestPath = "testdata/turnin_overrides.json"
	}
	if manifestPath != "" {
		manifest, manifestErr := LoadTurnInScenarioManifest(manifestPath)
		require.NoError(t, manifestErr)
		overrides = manifest.Overrides
	}
	bridge := NewLuaBridge(dataPath)
	bridge.ModuleLoader = databaseQuestModuleLoader(db)
	report := RunTurnInMatrixWithOverrides(bridge, scripts, overrides)
	t.Log(report.Summary())
	for _, unsupported := range report.Unsupported {
		t.Logf("UNSUPPORTED %s/%s line %d: %s (%s)", unsupported.Zone, unsupported.NPC, unsupported.Line, unsupported.Reason, unsupported.Source)
	}
	verboseInactive := os.Getenv("IDLEQUEST_QUEST_TEST_VERBOSE") == "1"
	for _, result := range report.Results {
		if result.Err != nil {
			if result.Status == TurnInCaseMissingAPI {
				t.Errorf("MISSING API %s/%s turn-in line %d %s: %s: %v", result.Zone, result.NPC, result.Scenario.Line, result.Scenario.Source, result.MissingAPI, result.Err)
			} else {
				t.Errorf("FAILED %s/%s turn-in line %d %s: %v", result.Zone, result.NPC, result.Scenario.Line, result.Scenario.Source, result.Err)
			}
		} else if !result.Activated {
			if verboseInactive {
				t.Logf("NOT ACTIVATED %s/%s line %d (likely conditional): %s", result.Zone, result.NPC, result.Scenario.Line, result.Scenario.Source)
			}
		}
		for _, validationErr := range result.ValidationErrors {
			t.Errorf("MISMATCH %s/%s case %q line %d: %s", result.Zone, result.NPC, result.CaseName, result.Scenario.Line, validationErr)
		}
	}
	for _, override := range report.UnmatchedOverrides {
		t.Errorf("UNMATCHED OVERRIDE %s/%s case %q", override.Zone, override.NPC, override.Name)
	}

	assert.Equal(t, report.DiscoveredCases, report.ExecutedCases,
		fmt.Sprintf("not every discovered case executed; %s", report.Summary()))
}

func TestDatabaseClockworkScrubberStatefulTurnIn(t *testing.T) {
	dsn := os.Getenv("IDLEQUEST_QUEST_TEST_DSN")
	if dsn == "" {
		t.Skip("set IDLEQUEST_QUEST_TEST_DSN to run the real quest stateful turn-in test")
	}

	db, err := sql.Open("mysql", dsn)
	require.NoError(t, err)
	defer db.Close()
	require.NoError(t, db.Ping())

	var source string
	require.NoError(t, db.QueryRow(`
SELECT lua_content
FROM quests
WHERE enabled = 1
  AND zone = 'akanon'
  AND name = 'clockwork_scrubber'
LIMIT 1`).Scan(&source))

	dataPath := os.Getenv("IDLEQUEST_QUEST_DATA_PATH")
	if dataPath == "" {
		dataPath = "."
		setupRealItemsLua(t)
		t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	}
	bridge := NewLuaBridge(dataPath)
	bridge.ModuleLoader = databaseQuestModuleLoader(db)

	inactiveCapture, err := bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC:     &NPCProxy{ID: 628, Name: "clockwork_scrubber"},
		Player:  &PlayerProxy{ID: 101, Name: "QuestMatrix", Tasks: map[int]bool{}},
		Trade:   &TradeProxy{Items: []int{12164}},
		Globals: map[string]string{},
	})
	require.NoError(t, err)
	assert.False(t, turnInCaptureActivated(inactiveCapture, TurnInScenario{Items: []int{12164}}), "fresh script state should not activate the miner628-gated turn-in")

	activeCapture, err := bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC:             &NPCProxy{ID: 628, Name: "clockwork_scrubber"},
		Player:          &PlayerProxy{ID: 101, Name: "QuestMatrix", Tasks: map[int]bool{}},
		Trade:           &TradeProxy{Items: []int{12164}},
		Globals:         map[string]string{},
		ScriptState:     map[string]any{"upvalue:miner628": float64(1)},
		SpawnInstanceID: 5000000000628,
	})
	require.NoError(t, err)
	assert.True(t, turnInCaptureActivated(activeCapture, TurnInScenario{Items: []int{12164}}), "persisted spawn-local miner628 state should activate the turn-in")
	assert.NotEmpty(t, activeCapture.Items, "activated scrubber turn-in should reward one of the configured result items")
}

func TestDatabaseTralynMarsingerAcceptsAllMailTurnInItems(t *testing.T) {
	dsn := os.Getenv("IDLEQUEST_QUEST_TEST_DSN")
	if dsn == "" {
		t.Skip("set IDLEQUEST_QUEST_TEST_DSN to run the real quest Tralyn turn-in test")
	}

	db, err := sql.Open("mysql", dsn)
	require.NoError(t, err)
	defer db.Close()
	require.NoError(t, db.Ping())

	var source string
	require.NoError(t, db.QueryRow(`
SELECT lua_content
FROM quests
WHERE enabled = 1
  AND zone = 'qeynos'
  AND name = 'Tralyn_Marsinger'
LIMIT 1`).Scan(&source))
	require.NotContains(t, source, "(18150 or 18151)")
	require.NotContains(t, source, "(18153 or 18154)")

	dataPath := os.Getenv("IDLEQUEST_QUEST_DATA_PATH")
	if dataPath == "" {
		dataPath = "."
		setupRealItemsLua(t)
		t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	}
	bridge := NewLuaBridge(dataPath)
	bridge.ModuleLoader = databaseQuestModuleLoader(db)
	execute := func(itemID int) *QuestCapture {
		t.Helper()
		capture, executeErr := bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
			NPC:     &NPCProxy{ID: 100, Name: "Tralyn_Marsinger"},
			Player:  &PlayerProxy{ID: 101, Name: "QuestMatrix", Tasks: map[int]bool{}},
			Trade:   &TradeProxy{Items: []int{itemID}},
			Globals: map[string]string{},
		})
		require.NoError(t, executeErr)
		return capture
	}

	for _, itemID := range []int{18150, 18151, 18153, 18154} {
		assert.True(t, turnInCaptureActivated(execute(itemID), TurnInScenario{Items: []int{itemID}}), "mail item %d should activate", itemID)
	}
}
