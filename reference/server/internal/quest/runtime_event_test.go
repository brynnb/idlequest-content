package quest

import (
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestExecuteEventFromSourceDispatchesRuntimeFields(t *testing.T) {
	source := `
function event_timer(e)
  if e.timer == "summon" then
    e.self:Say("timer fired")
    eq.signal(42, 7)
  end
end

function event_signal(e)
  e.self:Say("signal " .. e.signal)
end`
	event := &LuaEvent{
		NPC:     &NPCProxy{ID: 10, Name: "Test NPC"},
		Player:  &PlayerProxy{ID: 20, Name: "Test Player", Tasks: map[int]bool{}},
		Globals: map[string]string{},
		Fields:  map[string]any{"timer": "summon"},
	}

	capture, err := NewLuaBridge(".").ExecuteEventFromSource(source, "event_timer", event)
	require.NoError(t, err)
	assert.Contains(t, capture.Responses, "timer fired")
	require.Len(t, capture.Signals, 1)
	assert.Equal(t, NPCSignal{NPCID: 42, SignalID: 7}, capture.Signals[0])

	event.Fields = map[string]any{"signal": 99}
	capture, err = NewLuaBridge(".").ExecuteEventFromSource(source, "event_signal", event)
	require.NoError(t, err)
	assert.Contains(t, capture.Responses, "signal 99")
}

func TestExecuteEventFromSourceMissingHandlerIsNoOp(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource("function event_say(e) end", "event_spawn", &LuaEvent{
		NPC: &NPCProxy{}, Player: &PlayerProxy{}, Globals: map[string]string{},
	})
	require.NoError(t, err)
	require.NotNil(t, capture)
	assert.Empty(t, capture.Responses)
}

func TestExecuteEventFromSourceCapturesActorDepop(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(`function event_signal(e) eq.depop() end`, "event_signal", &LuaEvent{
		NPC: &NPCProxy{}, Player: &PlayerProxy{}, Globals: map[string]string{}, SpawnInstanceID: 5001,
	})
	require.NoError(t, err)
	require.Len(t, capture.Depops, 1)
	assert.Equal(t, int64(5001), capture.Depops[0].SpawnInstanceID)
}

func TestRuntimeCompatibilityShimsUsedByClassicKunarkScripts(t *testing.T) {
	source := `
function event_timer(e)
  if not eq.is_paused_timer("patrol") then
    eq.pause("patrol")
    eq.resume("patrol")
  end
  e.self:GMMove(11, 22, 33, 44)
  e.self:MerchantOpenShop()
  e.other:NukeItem(1001)
  local client = eq.get_entity_list():GetClientByCharID(e.other:CharacterID())
  client:Message(15, "compat ok")
end`
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(source, "event_timer", &LuaEvent{
		NPC: &NPCProxy{ID: 99, Name: "Compat NPC"}, Player: &PlayerProxy{ID: 123, Name: "Compat Player", Tasks: map[int]bool{}}, Globals: map[string]string{}, Fields: map[string]any{"timer": "patrol"},
		ReadTimer: func(name string) (bool, bool, error) { require.Equal(t, "patrol", name); return true, false, nil },
	})
	require.NoError(t, err)
	require.Len(t, capture.NPCMoves, 1)
	assert.Equal(t, int32(99), capture.NPCMoves[0].NPCTypeID)
	assert.Equal(t, 11.0, capture.NPCMoves[0].X)
	assert.Equal(t, 22.0, capture.NPCMoves[0].Y)
	assert.Equal(t, 33.0, capture.NPCMoves[0].Z)
	assert.Equal(t, 44.0, capture.NPCMoves[0].Heading)
	assert.Equal(t, []TimerUpdate{{Name: "patrol", Pause: true}, {Name: "patrol", Resume: true}}, capture.Timers)
	assert.Contains(t, capture.Responses, "compat ok")
}

func TestEntityListIsMobSpawnedByNpcTypeIDUsesVisibleContext(t *testing.T) {
	source := `
function event_spawn(e)
  if eq.get_entity_list():IsMobSpawnedByNpcTypeID(96073) then
    eq.depop()
  end
end`
	bridge := NewLuaBridge(".")

	capture, err := bridge.ExecuteEventFromSource(source, "event_spawn", &LuaEvent{
		NPC: &NPCProxy{ID: 96089, Name: "Faydedar"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{},
		SpawnInstanceID:   5001,
		VisibleNPCTypeIDs: []int32{96073},
	})
	require.NoError(t, err)
	require.Len(t, capture.Depops, 1)
	assert.Equal(t, int64(5001), capture.Depops[0].SpawnInstanceID)

	capture, err = bridge.ExecuteEventFromSource(source, "event_spawn", &LuaEvent{
		NPC: &NPCProxy{ID: 96089, Name: "Faydedar"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{},
		SpawnInstanceID: 5001,
	})
	require.NoError(t, err)
	assert.Empty(t, capture.Depops)
}

func TestPlayerQuestFactionLevelIgnoresHydratedFactionValues(t *testing.T) {
	source := `
function event_trade(e)
  if e.other:GetModCharacterFactionLevel(404) >= 1800 then
    e.other:SummonItem(1674)
  else
    e.other:SummonItem(1673)
  end
end`
	bridge := NewLuaBridge(".")

	capture, err := bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC: &NPCProxy{}, Player: &PlayerProxy{Tasks: map[int]bool{}, Factions: map[int]int{404: 1800}}, Globals: map[string]string{},
		Trade: &TradeProxy{Items: []int{1673}},
	})
	require.NoError(t, err)
	assert.Equal(t, []QuestReward{{ItemID: 1674, Count: 1}}, capture.Items)

	capture, err = bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC: &NPCProxy{}, Player: &PlayerProxy{Tasks: map[int]bool{}, Factions: map[int]int{404: 1500}}, Globals: map[string]string{},
		Trade: &TradeProxy{Items: []int{1673}},
	})
	require.NoError(t, err)
	assert.Equal(t, []QuestReward{{ItemID: 1674, Count: 1}}, capture.Items)
}

func TestLordRakAshiirChildsTearSpawnsFinalFightRegardlessOfTrueSpiritFaction(t *testing.T) {
	source := readUpstreamLua(t, "citymist", "#Lord_Rak-Ashiir")
	bridge := NewLuaBridge(filepath.Join("upstream", "projecteq"))

	capture, err := bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC:     &NPCProxy{ID: 90174, Name: "Lord Rak`Ashiir", PrimaryFaction: 404, X: 10, Y: 20, Z: 30, Heading: 40},
		Player:  &PlayerProxy{Name: "Shaman", Tasks: map[int]bool{}, Factions: map[int]int{404: 1800}},
		Globals: map[string]string{},
		Trade:   &TradeProxy{Items: []int{1673}},
	})
	require.NoError(t, err)
	require.Len(t, capture.Spawns, 1)
	assert.Equal(t, QuestSpawnRequest{NPCTypeID: 90183, X: 10, Y: 20, Z: 30, Heading: 40}, capture.Spawns[0])
	require.Len(t, capture.Depops, 1)

	capture, err = bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC:     &NPCProxy{ID: 90174, Name: "Lord Rak`Ashiir", PrimaryFaction: 404},
		Player:  &PlayerProxy{Name: "Shaman", Tasks: map[int]bool{}, Factions: map[int]int{404: -2000}},
		Globals: map[string]string{},
		Trade:   &TradeProxy{Items: []int{1673}},
	})
	require.NoError(t, err)
	assert.Equal(t, []QuestSpawnRequest{{NPCTypeID: 90183}}, capture.Spawns)
	assert.Empty(t, capture.Items, "the accepted tear is not refunded for low faction")

	capture, err = bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC: &NPCProxy{ID: 90174}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{},
		Trade: &TradeProxy{Items: []int{1001}},
	})
	require.NoError(t, err)
	assert.Empty(t, capture.Spawns, "faction bypass does not bypass required items")
}

func TestMonkFireSpriteChallengeSpawnsEejag(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "lavastorm", "a_fire_sprite")
	bridge := NewLuaBridge(".")

	capture, err := bridge.ExecuteEventFromSource(source, "event_say", &LuaEvent{
		NPC: &NPCProxy{ID: 27113, Name: "a fire sprite", X: 1, Y: 2, Z: 3, Heading: 4},
		Player: &PlayerProxy{
			Name:      "Monk",
			CharClass: "Monk",
			ClassID:   7,
			CharLevel: 46,
			Tasks:     map[int]bool{},
		},
		Globals:         map[string]string{},
		Message:         "I challenge Eejag",
		SpawnInstanceID: 5001,
	})
	require.NoError(t, err)
	assert.Equal(t, []QuestSpawnRequest{{NPCTypeID: 27119, X: 298, Y: 1037, Z: -60, Unique: true}}, capture.Spawns)
	assert.Equal(t, []QuestDepopRequest{{SpawnInstanceID: 5001, WithTimer: true}}, capture.Depops)
}

func TestMonkFireSpriteHailOffersEejagChallenge(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "lavastorm", "a_fire_sprite")
	bridge := NewLuaBridge(".")

	capture, err := bridge.ExecuteEventFromSource(source, "event_say", &LuaEvent{
		NPC:     &NPCProxy{ID: 27113, Name: "a fire sprite"},
		Player:  &PlayerProxy{Name: "Monk", CharClass: "Monk", ClassID: 7, CharLevel: 46, Tasks: map[int]bool{}},
		Globals: map[string]string{},
		Message: "hail",
	})
	require.NoError(t, err)
	require.Len(t, capture.Responses, 1)
	assert.Contains(t, capture.Responses[0], "[I challenge Eejag]")

	service := &Service{}
	assert.Equal(t,
		[]DialogueOption{{Text: "I challenge Eejag", Keyword: "I challenge Eejag"}},
		service.extractKeywords(capture.Responses[0]),
	)
}

func TestMonkEpicPresenceCharredScaleSpawnsGwan(t *testing.T) {
	source := readUpstreamLua(t, "airplane", "a_presence")
	bridge := NewLuaBridge(filepath.Join("upstream", "projecteq"))

	capture, err := bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC: &NPCProxy{ID: 71066, Name: "a presence", X: 1043, Y: 286, Z: -8, Heading: 252},
		Player: &PlayerProxy{
			Name: "Monk", CharClass: "Monk", ClassID: 7, CharLevel: 46,
			Tasks: map[int]bool{},
		},
		Globals:         map[string]string{},
		Trade:           &TradeProxy{Items: []int{1684}},
		SpawnInstanceID: 21532,
	})
	require.NoError(t, err)
	assert.Empty(t, capture.Items)
	assert.Equal(t, []QuestSpawnRequest{{NPCTypeID: 71069, X: 1043, Y: 286, Z: -8, Heading: 252}}, capture.Spawns)
	assert.Equal(t, []QuestDepopRequest{{SpawnInstanceID: 21532, WithTimer: true}}, capture.Depops)
}

func TestSsynthiFlowerRewardsScepterOfSorrow(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	source := readOverrideLua(t, "converted-perl", "mistmoore", "Ssynthi")
	bridge := NewLuaBridge(".")

	capture, err := bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC: &NPCProxy{ID: 59154, Name: "Ssynthi", X: 373, Y: -60, Z: -234, Heading: 72},
		Player: &PlayerProxy{
			Name: "Adventurer", CharClass: "Wizard", ClassID: 12, CharLevel: 25,
			Tasks: map[int]bool{},
		},
		Globals: map[string]string{},
		Trade:   &TradeProxy{Items: []int{14362}},
	})
	require.NoError(t, err)
	assert.Equal(t, []QuestReward{{ItemID: 14364, Count: 1}}, capture.Items)
	assert.Equal(t, []FactionReward{{FactionID: 415, Amount: 20}, {FactionID: 416, Amount: -20}}, capture.Factions)
	assert.Equal(t, 1000, capture.Exp)
}

func TestMonkEejagSpawnRegistersProximity(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "lavastorm", "Eejag")
	bridge := NewLuaBridge(".")

	capture, err := bridge.ExecuteEventFromSource(source, "event_spawn", &LuaEvent{
		NPC:     &NPCProxy{ID: 27119, Name: "Eejag", X: 100, Y: 200, Z: -10},
		Player:  &PlayerProxy{Tasks: map[int]bool{}},
		Globals: map[string]string{},
	})
	require.NoError(t, err)
	assert.Equal(t, &ProximityUpdate{MinX: 50, MaxX: 150, MinY: 150, MaxY: 250, MinZ: -1000000, MaxZ: 1000000}, capture.Proximity)
	require.Len(t, capture.Responses, 1)
	assert.Contains(t, capture.Responses[0], "What imbecile dares challenge a Celestial Fist")
}

func TestClericZordakShimmeringPearlSpawnsHostileHuman(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "soldungb", "Zordak_Ragefire")
	bridge := NewLuaBridge(filepath.Join("upstream", "projecteq"))

	capture, err := bridge.ExecuteEventFromSource(source, "event_trade", &LuaEvent{
		NPC: &NPCProxy{ID: 32038, Name: "Zordak Ragefire", X: 10, Y: 20, Z: 30, Heading: 40},
		Player: &PlayerProxy{
			ID:        123,
			Name:      "Cleric",
			CharClass: "Cleric",
			ClassID:   2,
			CharLevel: 46,
			Tasks:     map[int]bool{},
		},
		Globals:         map[string]string{},
		Trade:           &TradeProxy{Items: []int{28054}},
		SpawnInstanceID: 5001,
	})
	require.NoError(t, err)
	assert.Empty(t, capture.Items)
	assert.Equal(t, []QuestSpawnRequest{{NPCTypeID: 91096, X: 10, Y: 20, Z: 30, Heading: 40}}, capture.Spawns)
	assert.Equal(t, []QuestDepopRequest{{SpawnInstanceID: 5001, WithTimer: true}}, capture.Depops)
}

func TestClericHostileZordakDeathSpawnsZordakalicus(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "soldungb", "Zordak_Ragefire")
	bridge := NewLuaBridge(".")

	capture, err := bridge.ExecuteEventFromSource(source, "event_death_complete", &LuaEvent{
		NPC:     &NPCProxy{ID: 91096, Name: "Zordak Ragefire", X: 10, Y: 20, Z: 30, Heading: 40},
		Player:  &PlayerProxy{ID: 123, Name: "Cleric", Tasks: map[int]bool{}},
		Globals: map[string]string{},
	})
	require.NoError(t, err)
	assert.Equal(t, []QuestSpawnRequest{{NPCTypeID: 91090, X: 10, Y: 20, Z: 30, Heading: 40}}, capture.Spawns)

	capture, err = bridge.ExecuteEventFromSource(source, "event_death_complete", &LuaEvent{
		NPC:     &NPCProxy{ID: 32038, Name: "Zordak Ragefire"},
		Player:  &PlayerProxy{Name: "Cleric", Tasks: map[int]bool{}},
		Globals: map[string]string{},
	})
	require.NoError(t, err)
	assert.Empty(t, capture.Spawns)
}

func TestConvertedFaydedarDepopsWhenTriggeredFaydedarVisible(t *testing.T) {
	source := readConvertedPerlLua(t, "timorous", "Faydedar")
	bridge := NewLuaBridge(".")

	capture, err := bridge.ExecuteEventFromSource(source, "event_spawn", &LuaEvent{
		NPC: &NPCProxy{ID: 96089, Name: "Faydedar"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{},
		SpawnInstanceID:   5001,
		VisibleNPCTypeIDs: []int32{96073},
	})
	require.NoError(t, err)
	require.Len(t, capture.Depops, 1)
	assert.Equal(t, int64(5001), capture.Depops[0].SpawnInstanceID)

	capture, err = bridge.ExecuteEventFromSource(source, "event_spawn", &LuaEvent{
		NPC: &NPCProxy{ID: 96089, Name: "Faydedar"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{},
		SpawnInstanceID: 5001,
	})
	require.NoError(t, err)
	assert.Empty(t, capture.Depops)
}

func TestRuntimeActorPositionIsAvailableToLua(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(`
function event_spawn(e)
  eq.spawn2(77, 0, 0, e.self:GetX() + 1, e.self:GetY() + 2, e.self:GetZ() + 3, e.self:GetHeading() + 4)
end`, "event_spawn", &LuaEvent{
		NPC: &NPCProxy{X: 10, Y: 20, Z: 30, Heading: 40}, Player: &PlayerProxy{}, Globals: map[string]string{},
	})
	require.NoError(t, err)
	require.Len(t, capture.Spawns, 1)
	assert.Equal(t, QuestSpawnRequest{NPCTypeID: 77, X: 11, Y: 22, Z: 33, Heading: 44}, capture.Spawns[0])
}

func TestLuaBridgeCapturesRuntimeMovementAndDoorRequests(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(`
function event_spawn(e)
  e.other:MovePC(2, 11, 22, 33, 44)
  e.other:MovePCInstance(3, 7, 55, 66, 77, 88)
  e.self:MoveTo(101, 202, 303, 64, true)
  e.self:SetRunning(true)
  eq.force_door_open(12)
  e.self:RandomRoam()
end`, "event_spawn", &LuaEvent{NPC: &NPCProxy{ID: 9001, Name: "Mover", Heading: 5}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}})
	require.NoError(t, err)
	assert.Equal(t, []QuestPlayerMoveRequest{
		{ZoneID: 2, X: 11, Y: 22, Z: 33, Heading: 44},
		{ZoneID: 3, InstanceID: 7, X: 55, Y: 66, Z: 77, Heading: 88},
	}, capture.PlayerMoves)
	assert.Contains(t, capture.NPCMoves, QuestNPCMoveRequest{Order: 1, Kind: QuestNPCMoveWalk, NPCTypeID: 9001, X: 101, Y: 202, Z: 303, Heading: 64, SaveGuardSpot: true})
	assert.Contains(t, capture.NPCMoves, QuestNPCMoveRequest{Order: 2, Kind: QuestNPCMoveSetRunning, NPCTypeID: 9001, Running: true})
	assert.Contains(t, capture.NPCMoves, QuestNPCMoveRequest{Order: 3, Kind: QuestNPCMoveRoam, NPCTypeID: 9001, Roam: true})
	assert.Equal(t, []QuestDoorRequest{{DoorID: 12, ForceOpen: true}}, capture.Doors)
}

func TestConvertedProximityTravelTriggersCaptureZoneMoves(t *testing.T) {
	cases := []struct {
		name     string
		zone     string
		npc      string
		npcX     float64
		npcY     float64
		wantProx *ProximityUpdate
		wantMove QuestPlayerMoveRequest
	}{
		{
			name:     "erudnext to erudsxing",
			zone:     "erudnext",
			npc:      "24301",
			npcX:     -1645.247559,
			npcY:     64.458321,
			wantProx: &ProximityUpdate{MinX: -1685.247559, MaxX: -1605.247559, MinY: 24.458321, MaxY: 104.458321, MinZ: -1000000, MaxZ: 1000000},
			wantMove: QuestPlayerMoveRequest{ZoneID: 98, X: 716.9, Y: -1771.8, Z: 3.2},
		},
		{
			name:     "firiona to timorous",
			zone:     "firiona",
			npc:      "84400",
			npcX:     1489.770996,
			npcY:     -4464.542969,
			wantProx: &ProximityUpdate{MinX: 1464.770996, MaxX: 1514.770996, MinY: -4489.542969, MaxY: -4439.542969, MinZ: -1000000, MaxZ: 1000000},
			wantMove: QuestPlayerMoveRequest{ZoneID: 96, X: -3260.10, Y: -4544.56, Z: 19.47},
		},
		{
			name:     "oasis to timorous",
			zone:     "oasis",
			npc:      "#_#_2",
			npcX:     -1180.043945,
			npcY:     1557.032959,
			wantProx: &ProximityUpdate{MinX: -1230.043945, MaxX: -1130.043945, MinY: 1507.032959, MaxY: 1607.032959, MinZ: -1000000, MaxZ: 1000000},
			wantMove: QuestPlayerMoveRequest{ZoneID: 96, X: 3335.5, Y: 7121.4, Z: -5.5},
		},
		{
			name:     "overthere to timorous",
			zone:     "overthere",
			npc:      "#_#_6",
			npcX:     2815.439941,
			npcY:     4617.290039,
			wantProx: &ProximityUpdate{MinX: 2740.439941, MaxX: 2890.439941, MinY: 4542.290039, MaxY: 4692.290039, MinZ: -1000000, MaxZ: 1000000},
			wantMove: QuestPlayerMoveRequest{ZoneID: 96, X: 3506.0, Y: 5702.5, Z: 4.6},
		},
		{
			name:     "soldunga safety",
			zone:     "soldunga",
			npc:      "#safetynet",
			npcX:     -64,
			npcY:     262,
			wantProx: &ProximityUpdate{MinX: -69, MaxX: -59, MinY: 257, MaxY: 267, MinZ: -1000000, MaxZ: 1000000},
			wantMove: QuestPlayerMoveRequest{ZoneID: 31, X: -485, Y: -476, Z: 73},
		},
		{
			name:     "timorous to firiona",
			zone:     "timorous",
			npc:      "#_#",
			npcX:     -2410.393066,
			npcY:     -4110.600098,
			wantProx: &ProximityUpdate{MinX: -2445.393066, MaxX: -2375.393066, MinY: -4145.600098, MaxY: -4075.600098, MinZ: -1000000, MaxZ: 1000000},
			wantMove: QuestPlayerMoveRequest{ZoneID: 84, X: 1408.9, Y: -4334.3, Z: -103.6},
		},
		{
			name:     "timorous to oasis",
			zone:     "timorous",
			npc:      "#_#_4",
			npcX:     5259.799805,
			npcY:     7821.700195,
			wantProx: &ProximityUpdate{MinX: 5194.799805, MaxX: 5324.799805, MinY: 7756.700195, MaxY: 7886.700195, MinZ: -1000000, MaxZ: 1000000},
			wantMove: QuestPlayerMoveRequest{ZoneID: 37, X: -847.8, Y: 883.6, Z: -0.5},
		},
		{
			name:     "timorous to overthere",
			zone:     "timorous",
			npc:      "#_8_",
			npcX:     400.671997,
			npcY:     -4867.569824,
			wantProx: &ProximityUpdate{MinX: 335.671997, MaxX: 465.671997, MinY: -4932.569824, MaxY: -4802.569824, MinZ: -1000000, MaxZ: 1000000},
			wantMove: QuestPlayerMoveRequest{ZoneID: 93, X: 2736.0, Y: 3438.8, Z: -158.6},
		},
	}

	bridge := NewLuaBridge(".")
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			source := readConvertedPerlLua(t, tc.zone, tc.npc)
			spawnCapture, err := bridge.ExecuteEventFromSource(source, "event_spawn", &LuaEvent{
				NPC:     &NPCProxy{ID: 1, Name: tc.npc, X: tc.npcX, Y: tc.npcY},
				Player:  &PlayerProxy{Tasks: map[int]bool{}},
				Globals: map[string]string{},
			})
			require.NoError(t, err)
			assertProximityUpdateInDelta(t, tc.wantProx, spawnCapture.Proximity, 0.000001)

			enterCapture, err := bridge.ExecuteEventFromSource(source, "event_enter", &LuaEvent{
				NPC:     &NPCProxy{ID: 1, Name: tc.npc, X: tc.npcX, Y: tc.npcY},
				Player:  &PlayerProxy{Tasks: map[int]bool{}},
				Globals: map[string]string{},
			})
			require.NoError(t, err)
			assert.Equal(t, []QuestPlayerMoveRequest{tc.wantMove}, enterCapture.PlayerMoves)
		})
	}
}

func assertProximityUpdateInDelta(t *testing.T, want, got *ProximityUpdate, delta float64) {
	t.Helper()
	require.NotNil(t, got)
	assert.InDelta(t, want.MinX, got.MinX, delta)
	assert.InDelta(t, want.MaxX, got.MaxX, delta)
	assert.InDelta(t, want.MinY, got.MinY, delta)
	assert.InDelta(t, want.MaxY, got.MaxY, delta)
	assert.InDelta(t, want.MinZ, got.MinZ, delta)
	assert.InDelta(t, want.MaxZ, got.MaxZ, delta)
	assert.Equal(t, want.Clear, got.Clear)
}

func TestConvertedWallEchoSignalsAbandonedHereticPet(t *testing.T) {
	source := readConvertedPerlLua(t, "tox", "#wall_echo")
	bridge := NewLuaBridge(".")

	spawnCapture, err := bridge.ExecuteEventFromSource(source, "event_spawn", &LuaEvent{
		NPC:     &NPCProxy{ID: 38017, Name: "#wall_echo", X: 10, Y: 20},
		Player:  &PlayerProxy{Tasks: map[int]bool{}},
		Globals: map[string]string{},
	})
	require.NoError(t, err)
	assert.Equal(t, &ProximityUpdate{MinX: -15, MaxX: 35, MinY: -5, MaxY: 45, MinZ: -999999, MaxZ: 999999}, spawnCapture.Proximity)

	event := &LuaEvent{
		NPC:         &NPCProxy{ID: 38017, Name: "#wall_echo"},
		Player:      &PlayerProxy{Name: "Druid", Tasks: map[int]bool{}},
		Globals:     map[string]string{},
		ScriptState: spawnCapture.ScriptState,
	}
	event.Message = "yo ho. no sun!!"
	firstCapture, err := bridge.ExecuteEventFromSource(source, "event_proximity_say", event)
	require.NoError(t, err)

	event.ScriptState = firstCapture.ScriptState
	event.Message = "a skeleton's day is never done."
	secondCapture, err := bridge.ExecuteEventFromSource(source, "event_proximity_say", event)
	require.NoError(t, err)
	assert.Contains(t, secondCapture.Responses, "Your voice echoes nicely from the walls.")
	assert.Equal(t, []NPCSignal{{NPCID: 38139, SignalID: 1}}, secondCapture.Signals)
}

func TestConvertedVeeshanRabbitTeleportsOnlyAfterReadyKeyword(t *testing.T) {
	source := readConvertedPerlLua(t, "veeshan", "Vrabbit_Xloren")
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(source, "event_say", &LuaEvent{
		NPC:     &NPCProxy{ID: 108284, Name: "Vrabbit Xloren"},
		Player:  &PlayerProxy{Name: "Raider", Tasks: map[int]bool{}},
		Globals: map[string]string{},
		Message: "ready",
	})
	require.NoError(t, err)
	assert.Contains(t, capture.Responses, "Very well.")
	assert.Equal(t, []QuestPlayerMoveRequest{{ZoneID: 108, X: -1163.2, Y: -1047.9, Z: 283.0, Heading: 127.8}}, capture.PlayerMoves)
}

func TestConvertedVeeshanPlayerDoorSeal(t *testing.T) {
	source := readConvertedPerlLua(t, "veeshan", "player")
	bridge := NewLuaBridge(".")
	event := &LuaEvent{
		Player:       &PlayerProxy{Name: "Raider", Tasks: map[int]bool{}},
		Globals:      map[string]string{},
		SelfIsPlayer: true,
		Fields:       map[string]any{"door_id": 56},
	}

	sealedCapture, err := bridge.ExecuteEventFromSource(source, "event_click_door", &LuaEvent{
		Player:            event.Player,
		Globals:           event.Globals,
		SelfIsPlayer:      true,
		Fields:            event.Fields,
		VisibleNPCTypeIDs: []int32{108053},
	})
	require.NoError(t, err)
	assert.Contains(t, sealedCapture.Responses, "A seal has been placed on this door by Phara Dar. Perhaps there is a way to remove it.")
	assert.Empty(t, sealedCapture.Doors)

	openCapture, err := bridge.ExecuteEventFromSource(source, "event_click_door", event)
	require.NoError(t, err)
	assert.Contains(t, openCapture.Responses, "You got the door open.")
	assert.ElementsMatch(t, []QuestDoorRequest{{DoorID: 56, ForceOpen: true}, {DoorID: 57, ForceOpen: true}}, openCapture.Doors)
}

func TestLuaBridgeExecutesCastOnAndProximitySayRuntimeEvents(t *testing.T) {
	source := `
function event_cast_on(e)
  e.self:Say("spell " .. e.spell_id)
end
function event_proximity_say(e)
  e.self:Say(e.message)
end`
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteEventFromSource(source, "event_cast_on", &LuaEvent{NPC: &NPCProxy{Name: "Listener"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Fields: map[string]any{"spell_id": 200}})
	require.NoError(t, err)
	assert.Contains(t, capture.Responses, "spell 200")

	capture, err = bridge.ExecuteEventFromSource(source, "event_proximity_say", &LuaEvent{NPC: &NPCProxy{Name: "Listener"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Fields: map[string]any{"message": "secret phrase"}})
	require.NoError(t, err)
	assert.Contains(t, capture.Responses, "secret phrase")
}

func TestLuaBridgeCapturesSoulbinderRequests(t *testing.T) {
	source := `
function event_say(e)
  plugin.soulbinder_say(e.message)
end`
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteEventFromSource(source, "event_say", &LuaEvent{NPC: &NPCProxy{Name: "Soulbinder"}, Player: &PlayerProxy{Name: "Tester", Tasks: map[int]bool{}}, Message: "hail"})
	require.NoError(t, err)
	assert.Contains(t, capture.Responses[0], "Greetings, Tester.")
	assert.Contains(t, capture.Responses[0], "[bind your soul]")

	capture, err = bridge.ExecuteEventFromSource(source, "event_say", &LuaEvent{NPC: &NPCProxy{Name: "Soulbinder"}, Player: &PlayerProxy{Name: "Tester", Tasks: map[int]bool{}}, Message: "bind my soul"})
	require.NoError(t, err)
	assert.Empty(t, capture.Spells)
	assert.Equal(t, []QuestBindRequest{{}}, capture.Binds)
	assert.Contains(t, capture.Responses, "You feel yourself bind to the area.")

	capture, err = bridge.ExecuteEventFromSource(`function event_say(e) eq.bind_player() end`, "event_say", &LuaEvent{NPC: &NPCProxy{}, Player: &PlayerProxy{Tasks: map[int]bool{}}})
	require.NoError(t, err)
	assert.Equal(t, []QuestBindRequest{{}}, capture.Binds)
}

func TestDeathEventParticipantsAreMobProxies(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(`
function event_death(e)
  e.self:Say(e.killer:GetName() .. ":" .. e.owner:GetID() .. ":" .. e.target:GetCleanName())
end`, "event_death", &LuaEvent{NPC: &NPCProxy{Name: "Victim"}, Player: &PlayerProxy{ID: 42, Name: "Hero", Tasks: map[int]bool{}}, Globals: map[string]string{}})
	require.NoError(t, err)
	assert.Contains(t, capture.Responses, "Hero:42:Hero")
}

func TestPlayerRuntimeEventUsesClientAsSelf(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(`
function event_enter_zone(e)
  e.self:Message(15, e.self:GetName())
  eq.set_timer("player_tick", 1000)
end`, "event_enter_zone", &LuaEvent{
		Player:       &PlayerProxy{ID: 42, Name: "Tester", CharLevel: 60, Tasks: map[int]bool{}},
		Globals:      map[string]string{},
		SelfIsPlayer: true,
	})
	require.NoError(t, err)
	assert.Equal(t, []string{"Tester"}, capture.Responses)
	assert.NotEmpty(t, capture.Timers)
	assert.Equal(t, "player_tick", capture.Timers[0].Name)
}

func TestLuaBridgeLoadsRequiredModuleFromHook(t *testing.T) {
	bridge := NewLuaBridge(".")
	bridge.ModuleLoader = func(name string) (string, bool, error) {
		if name != "quest_support" {
			return "", false, nil
		}
		return `return { message = function() return "loaded" end }`, true, nil
	}
	capture, err := bridge.ExecuteEventFromSource(`
local support = require("quest_support")
function event_spawn(e)
  e.self:Say(support.message())
end`, "event_spawn", &LuaEvent{NPC: &NPCProxy{Name: "ModuleUser"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}})
	require.NoError(t, err)
	assert.Contains(t, capture.Responses, "loaded")
}

func TestLuaBridgeExecutesRegisteredNPCEventLocalHandler(t *testing.T) {
	const source = `
local count = 0
local function mob_death(e)
  count = count + 1
  e.self:Say("registered " .. count)
end
function event_encounter_load(e)
  eq.register_npc_event(Event.death_complete, 9001, mob_death)
end`
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteRegisteredNPCEventFromSource(source, RuntimeEventDeathComplete, 9001, &LuaEvent{NPC: &NPCProxy{Name: "Registered"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}})
	require.NoError(t, err)
	assert.Contains(t, capture.Responses, "registered 1")
	assert.Equal(t, float64(1), capture.ScriptState["upvalue:count"])
}

func TestRegisteredEncounterSpeechWithoutRewards(t *testing.T) {
	for _, playerEvent := range []bool{false, true} {
		name := "npc"
		source := `function event_encounter_load(e)
  eq.register_npc_event(Event.signal, 9001, function(e) e.self:Say("spoken only") end)
end`
		if playerEvent {
			name = "player"
			source = `function event_encounter_load(e)
  eq.register_player_event(Event.loot, function(e) e.self:Message(15, "spoken only") end)
end`
		}
		t.Run(name, func(t *testing.T) {
			bridge := NewLuaBridge(".")
			event := &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}, SelfIsPlayer: playerEvent}
			var capture *QuestCapture
			var err error
			if playerEvent {
				capture, err = bridge.ExecuteRegisteredPlayerEventFromSource(source, RuntimeEventLoot, event)
			} else {
				capture, err = bridge.ExecuteRegisteredNPCEventFromSource(source, RuntimeEventSignal, 9001, event)
			}
			require.NoError(t, err)
			require.False(t, captureHasEffects(capture), "Speech must not become a hand-in side effect")
			// The bridge currently captures built-in globals even when the script
			// declares no persistent state. This satisfies the service merge gate;
			// speech-only capture must not be mistaken for an empty runtime result.
			require.NotEmpty(t, capture.ScriptState)
			merged := NewQuestCapture()
			mergeQuestCapture(merged, capture)
			require.Equal(t, []string{"spoken only"}, merged.Responses)
		})
	}
}

func TestLuaBridgeExecutesRegisteredNPCTradeWithTradePayload(t *testing.T) {
	setupRealItemsLua(t)
	t.Cleanup(func() { _ = os.RemoveAll("lua_modules") })
	const source = `
local item_lib = require("items")
local function mob_trade(e)
  if item_lib.check_turn_in(e.trade, {item1 = 1001}) then
    e.other:SummonItem(1002)
  end
end
function event_encounter_load(e)
  eq.register_npc_event(Event.trade, 9001, mob_trade)
end`
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteRegisteredNPCEventFromSource(source, RuntimeEventTrade, 9001, &LuaEvent{NPC: &NPCProxy{Name: "Registered"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}, Trade: &TradeProxy{Items: []int{1001}}})
	require.NoError(t, err)
	assert.Equal(t, []QuestReward{{ItemID: 1002, Count: 1}}, capture.Items)
}

func TestLuaBridgeExecutesRegisteredPlayerEventLocalHandler(t *testing.T) {
	const source = `
local seen = false
local function player_loot(e)
  seen = true
  e.self:Message(15, "registered player")
end
function event_encounter_load(e)
  eq.register_player_event(Event.loot, player_loot)
end`
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteRegisteredPlayerEventFromSource(source, RuntimeEventLoot, &LuaEvent{Player: &PlayerProxy{Name: "Player", Tasks: map[int]bool{}}, Globals: map[string]string{}, SelfIsPlayer: true})
	require.NoError(t, err)
	assert.Contains(t, capture.Responses, "registered player")
	assert.Equal(t, true, capture.ScriptState["upvalue:seen"])
}

func TestLuaScriptUpvalueStateRoundTripsAcrossFreshVMs(t *testing.T) {
	const source = `
local count
function event_spawn(e) count = 0 end
function event_signal(e)
  count = count + 1
  e.self:Say("count=" .. count)
end`
	bridge := NewLuaBridge(".")
	event := &LuaEvent{NPC: &NPCProxy{Name: "Counter"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}}
	spawnCapture, err := bridge.ExecuteEventFromSource(source, "event_spawn", event)
	require.NoError(t, err)
	assert.Equal(t, float64(0), spawnCapture.ScriptState["upvalue:count"])

	event.ScriptState = spawnCapture.ScriptState
	signalCapture, err := bridge.ExecuteEventFromSource(source, "event_signal", event)
	require.NoError(t, err)
	assert.Contains(t, signalCapture.Responses, "count=1")
	assert.Equal(t, float64(1), signalCapture.ScriptState["upvalue:count"])
}

func TestLuaTableUpvalueStateRoundTripsAcrossFreshVMs(t *testing.T) {
	const source = `
local ids
function event_spawn(e) ids = {[42] = "ready"} end
function event_signal(e) e.self:Say(ids[42]) end`
	bridge := NewLuaBridge(".")
	event := &LuaEvent{NPC: &NPCProxy{Name: "TableState"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}}
	spawnCapture, err := bridge.ExecuteEventFromSource(source, "event_spawn", event)
	require.NoError(t, err)
	event.ScriptState = spawnCapture.ScriptState
	signalCapture, err := bridge.ExecuteEventFromSource(source, "event_signal", event)
	require.NoError(t, err)
	assert.Contains(t, signalCapture.Responses, "ready")
}

func TestConvertedDrazNurakkDeathCompleteSpawnsRaptorAmbush(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(readConvertedPerlLua(t, "timorous", "Draz_Nurakk"), "event_death_complete", &LuaEvent{
		NPC: &NPCProxy{Name: "Draz Nurakk"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{},
	})
	require.NoError(t, err)
	require.Len(t, capture.Spawns, 6)
	for _, spawn := range capture.Spawns {
		assert.Equal(t, int32(96322), spawn.NPCTypeID)
	}
}

func TestConvertedGrandmasterRinmarkTimerRevertsAndDepops(t *testing.T) {
	source := readConvertedPerlLua(t, "timorous", "Grandmaster_Rinmark")
	bridge := NewLuaBridge(".")
	event := &LuaEvent{
		NPC: &NPCProxy{Name: "Grandmaster Rinmark", X: 10, Y: 20, Z: 30, Heading: 40}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{},
		SpawnInstanceID: 5001,
	}

	capture, err := bridge.ExecuteEventFromSource(source, "event_spawn", event)
	require.NoError(t, err)
	assert.Contains(t, capture.Timers, TimerUpdate{Name: "Depop1", Interval: 90000})

	event.Fields = map[string]any{"timer": "Depop1"}
	capture, err = bridge.ExecuteEventFromSource(source, "event_timer", event)
	require.NoError(t, err)
	require.Len(t, capture.Spawns, 1)
	assert.Equal(t, QuestSpawnRequest{NPCTypeID: 96319, X: 10, Y: 20, Z: 30, Heading: 40}, capture.Spawns[0])
	require.Len(t, capture.Depops, 1)
	assert.Equal(t, int64(5001), capture.Depops[0].SpawnInstanceID)
}

func TestConvertedCargoClockworkWaypointSpawnsBandits(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(readConvertedPerlLua(t, "steamfont", "Cargo_Clockwork"), "event_waypoint_arrive", &LuaEvent{
		NPC: &NPCProxy{Name: "Cargo Clockwork"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{},
		Fields: map[string]any{"wp": 10},
	})
	require.NoError(t, err)
	require.Len(t, capture.Spawns, 3)
	assert.Equal(t, int32(56178), capture.Spawns[0].NPCTypeID)
	assert.Equal(t, int32(56179), capture.Spawns[1].NPCTypeID)
	assert.Equal(t, int32(56180), capture.Spawns[2].NPCTypeID)
}

func TestConvertedUndertowSkeletonDeathCompleteSpawnsFollowup(t *testing.T) {
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(readConvertedPerlLua(t, "cauldron", "#an_undertow_skeleton"), "event_death_complete", &LuaEvent{
		NPC: &NPCProxy{Name: "an undertow skeleton"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{},
	})
	require.NoError(t, err)
	require.Len(t, capture.Spawns, 1)
	assert.Contains(t, []int32{70059, 70060}, capture.Spawns[0].NPCTypeID)
}

func TestConvertedManEatingSharkRuntimeEvents(t *testing.T) {
	source := readConvertedPerlLua(t, "lakerathe", "#Man-eating_Freshwater_Shark")
	bridge := NewLuaBridge(".")
	event := &LuaEvent{
		NPC: &NPCProxy{Name: "Man-eating Freshwater Shark"}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{},
		SpawnInstanceID: 5001,
	}

	capture, err := bridge.ExecuteEventFromSource(source, "event_spawn", event)
	require.NoError(t, err)
	assert.Contains(t, capture.Timers, TimerUpdate{Name: "SharkDepop", Interval: 1800000})
	assert.Equal(t, []HPEventUpdate{{Percent: 75}}, capture.HPEvents)

	event.Fields = map[string]any{"hp_event": 75}
	capture, err = bridge.ExecuteEventFromSource(source, "event_hp", event)
	require.NoError(t, err)
	assert.Equal(t, []HPEventUpdate{{Percent: 50}}, capture.HPEvents)

	event.Fields = map[string]any{"timer": "SharkDepop"}
	capture, err = bridge.ExecuteEventFromSource(source, "event_timer", event)
	require.NoError(t, err)
	require.Len(t, capture.Depops, 1)
	assert.Equal(t, int64(5001), capture.Depops[0].SpawnInstanceID)
}

func TestLuaExecutionTimeoutStopsRunawayQuest(t *testing.T) {
	bridge := NewLuaBridge(".")
	bridge.ExecutionTimeout = 10 * time.Millisecond
	_, err := bridge.ExecuteEventFromSource(`function event_spawn(e) while true do end end`, "event_spawn", &LuaEvent{NPC: &NPCProxy{}, Player: &PlayerProxy{Tasks: map[int]bool{}}, Globals: map[string]string{}})
	require.ErrorContains(t, err, "context deadline exceeded")
}

func TestP99PixieDustRogueRewardsPatchworkTunicAndCoin(t *testing.T) {
	source := readConvertedPerlLua(t, "gfaydark", "Expin")
	capture, err := NewLuaBridge(filepath.Join("upstream", "projecteq")).ExecuteTradeFromSource(source, &LuaEvent{
		NPC:     &NPCProxy{ID: 54068, Name: "Expin"},
		Player:  &PlayerProxy{ID: 101, Name: "Scout", Tasks: map[int]bool{}},
		Globals: map[string]string{},
		Trade:   &TradeProxy{Items: []int{12109}},
	})
	require.NoError(t, err)
	assert.Equal(t, []QuestReward{{ItemID: 2104, Count: 1}}, capture.Items)
	assert.Equal(t, QuestCurrency{Silver: 6, Copper: 3}, capture.Currency)
	assert.Contains(t, capture.Responses[0], "Good work")
}

func TestP99PoisonSalesRewardsGiantWaspVenom(t *testing.T) {
	source := readOverrideLua(t, "modified-upstream", "cauldron", "Conium_Darkblade")
	capture, err := NewLuaBridge(filepath.Join("upstream", "projecteq")).ExecuteTradeFromSource(source, &LuaEvent{
		NPC:     &NPCProxy{ID: 70016, Name: "Conium Darkblade"},
		Player:  &PlayerProxy{ID: 101, Name: "Rogue", Tasks: map[int]bool{}},
		Globals: map[string]string{},
		Trade:   &TradeProxy{Items: []int{13260, 13260, 13260}, Gold: 30},
	})
	require.NoError(t, err)
	assert.Equal(t, []QuestReward{{ItemID: 14024, Count: 1}}, capture.Items)
	assert.Contains(t, capture.Responses[0], "didn't get this from meh")
}

func TestP99PlaguebringerTovaxDeathCreatesSealedLetterGroundObject(t *testing.T) {
	source := readOverrideLua(t, "idlequest-authored", "qeytoqrg", "Tovax_Vmar")
	capture, err := NewLuaBridge(".").ExecuteEventFromSource(source, "event_death_complete", &LuaEvent{
		NPC:             &NPCProxy{ID: 4020, Name: "Tovax Vmar", X: 200, Y: -1000, Z: 12, Heading: 64},
		Player:          &PlayerProxy{ID: 101, Name: "Investigator", Tasks: map[int]bool{}},
		Globals:         map[string]string{},
		SpawnInstanceID: 4345,
	})
	require.NoError(t, err)
	assert.Contains(t, capture.Responses[0], "sealed letter")
	require.Len(t, capture.GroundItems, 1)
	assert.Equal(t, QuestGroundObjectRequest{
		RuntimeID: 1,
		ItemID:    18802,
		X:         200,
		Y:         -1000,
		Z:         12,
		Heading:   64,
		DecayMS:   3600000,
	}, capture.GroundItems[0])
}

func readConvertedPerlLua(t *testing.T, zone, name string) string {
	t.Helper()
	path := filepath.Join("overrides", "lua", "converted-perl", zone, name+".lua")
	data, err := os.ReadFile(path)
	require.NoError(t, err)
	return string(data)
}

func readUpstreamLua(t *testing.T, zone, name string) string {
	t.Helper()
	path := filepath.Join("upstream", "projecteq", zone, name+".lua")
	data, err := os.ReadFile(path)
	require.NoError(t, err)
	return string(data)
}

func readOverrideLua(t *testing.T, origin, zone, name string) string {
	t.Helper()
	path := filepath.Join("overrides", "lua", origin, zone, name+".lua")
	data, err := os.ReadFile(path)
	require.NoError(t, err)
	return string(data)
}
