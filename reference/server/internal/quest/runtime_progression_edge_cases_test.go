package quest

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func progressionEvent(player PlayerProxy) *LuaEvent {
	if player.Tasks == nil {
		player.Tasks = map[int]bool{}
	}
	return &LuaEvent{
		NPC:     &NPCProxy{ID: 9001, Name: "Quest Keeper", PrimaryFaction: 404},
		Player:  &player,
		Globals: map[string]string{},
		Fields:  map[string]any{},
	}
}

func TestExecuteRuntimeEventRejectsInvalidContextBeforeQuestLookup(t *testing.T) {
	service := &Service{}
	for _, tt := range []struct {
		name   string
		zone   string
		script string
		event  RuntimeEventType
	}{
		{name: "missing zone", script: "npc", event: RuntimeEventSay},
		{name: "whitespace zone", zone: "  ", script: "npc", event: RuntimeEventSay},
		{name: "missing script", zone: "qeynos", event: RuntimeEventSay},
		{name: "whitespace script", zone: "qeynos", script: "  ", event: RuntimeEventSay},
		{name: "unsupported event", zone: "qeynos", script: "npc", event: RuntimeEventType("forged")},
	} {
		t.Run(tt.name, func(t *testing.T) {
			capture, err := service.ExecuteRuntimeEvent(tt.zone, tt.script, RuntimeEvent{Type: tt.event})
			assert.Nil(t, capture)
			assert.Error(t, err)
		})
	}
}

func TestProcessPlayerRuntimeEventRejectsNPCAuthoritativeEventsBeforeDatabaseAccess(t *testing.T) {
	service := &Service{}
	for _, eventType := range []RuntimeEventType{
		RuntimeEventSpawn, RuntimeEventSay, RuntimeEventTrade, RuntimeEventDeath,
		RuntimeEventCombat, RuntimeEventHP, RuntimeEventWaypointArrive,
	} {
		t.Run(string(eventType), func(t *testing.T) {
			capture, rewards, err := service.ProcessPlayerRuntimeEvent(10, "qeynos", 0, eventType, nil, nil)
			assert.Nil(t, capture)
			assert.Equal(t, RewardSummary{}, rewards)
			assert.ErrorContains(t, err, "unsupported player quest event")
		})
	}
}

func TestVisibleNPCTypeIDsFromRuntimeFieldsAcceptsOnlyPositiveIntegralIDs(t *testing.T) {
	fields := map[string]any{
		"__visible_npc_type_ids": []any{float64(9001), float64(9001.5), 9002, int32(9003), 0, -1, "9004", nil},
	}
	assert.Equal(t, []int32{9001, 9002, 9003}, visibleNPCTypeIDsFromRuntimeFields(fields))
}

func TestVisibleNPCTypeIDsPreferPrivateAuthoritativeField(t *testing.T) {
	fields := map[string]any{
		"__visible_npc_type_ids": []int32{9001},
		"visible_npc_type_ids":   []int32{9999},
	}
	assert.Equal(t, []int32{9001}, visibleNPCTypeIDsFromRuntimeFields(fields))
	fields["__visible_npc_type_ids"] = []int32{}
	assert.Empty(t, visibleNPCTypeIDsFromRuntimeFields(fields), "authoritative empty population must not use public fallback")
	fields["__visible_npc_type_ids"] = nil
	assert.Empty(t, visibleNPCTypeIDsFromRuntimeFields(fields), "present private key remains authoritative even when nil")
}

func TestRuntimeDialogueGatesUseAuthoritativePlayerContext(t *testing.T) {
	const source = `
function event_say(e)
  if not e.message:findi("begin trial") then return end
  if e.other:GetLevel() < 46 then e.self:Say("level") return end
  if e.other:GetClass() ~= Class.MONK then e.self:Say("class") return end
  if e.other:GetRace() ~= Race.IKSAR then e.self:Say("race") return end
  if e.other:GetModCharacterFactionLevel(404) < 1800 then e.self:Say("faction") return end
  if qglobals.epic_stage ~= "2" then e.self:Say("stage") return end
  e.self:Say("accepted")
end`

	tests := []struct {
		name       string
		player     PlayerProxy
		globals    map[string]string
		message    string
		want       string
		wantSilent bool
	}{
		{name: "all gates pass", player: PlayerProxy{CharLevel: 46, ClassID: 7, RaceID: 13, Factions: map[int]int{404: 1800}}, globals: map[string]string{"epic_stage": "2"}, message: "Begin Trial", want: "accepted"},
		{name: "level below boundary", player: PlayerProxy{CharLevel: 45, ClassID: 7, RaceID: 13, Factions: map[int]int{404: 1800}}, globals: map[string]string{"epic_stage": "2"}, message: "begin trial", want: "level"},
		{name: "wrong class", player: PlayerProxy{CharLevel: 60, ClassID: 2, RaceID: 13, Factions: map[int]int{404: 1800}}, globals: map[string]string{"epic_stage": "2"}, message: "begin trial", want: "class"},
		{name: "wrong race", player: PlayerProxy{CharLevel: 60, ClassID: 7, RaceID: 1, Factions: map[int]int{404: 1800}}, globals: map[string]string{"epic_stage": "2"}, message: "begin trial", want: "race"},
		{name: "negative faction deliberately does not gate quests", player: PlayerProxy{CharLevel: 60, ClassID: 7, RaceID: 13, Factions: map[int]int{404: -2000}}, globals: map[string]string{"epic_stage": "2"}, message: "begin trial", want: "accepted"},
		{name: "missing faction deliberately does not gate quests", player: PlayerProxy{CharLevel: 60, ClassID: 7, RaceID: 13, Factions: map[int]int{}}, globals: map[string]string{"epic_stage": "2"}, message: "begin trial", want: "accepted"},
		{name: "wrong durable stage", player: PlayerProxy{CharLevel: 60, ClassID: 7, RaceID: 13, Factions: map[int]int{404: 1800}}, globals: map[string]string{"epic_stage": "1"}, message: "begin trial", want: "stage"},
		{name: "unrecognized dialogue has no effect", player: PlayerProxy{CharLevel: 60, ClassID: 7, RaceID: 13, Factions: map[int]int{404: 1800}}, globals: map[string]string{"epic_stage": "2"}, message: "unrelated", wantSilent: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			event := progressionEvent(tt.player)
			event.Globals = tt.globals
			event.Message = tt.message
			capture, err := NewLuaBridge(".").ExecuteSayFromSource(source, event)
			require.NoError(t, err)
			if tt.wantSilent {
				assert.Empty(t, capture.Responses)
				assert.False(t, captureHasEffects(capture))
				return
			}
			assert.Equal(t, []string{tt.want}, capture.Responses)
		})
	}
}

func TestRuntimeDialogueSupportsNameAndNumericClassRaceChecks(t *testing.T) {
	const source = `
function event_say(e)
  if e.other:GetClassName() == "Shadow Knight" and e.other:GetRaceName() == "Iksar"
      and e.other:GetClass() == 5 and e.other:GetBaseRace() == 128 then
    e.self:Say("matched")
  end
end`
	event := progressionEvent(PlayerProxy{CharClass: "Shadow Knight", CharRace: "Iksar", ClassID: 5, RaceID: 128})

	capture, err := NewLuaBridge(".").ExecuteSayFromSource(source, event)
	require.NoError(t, err)
	assert.Equal(t, []string{"matched"}, capture.Responses)
}

func TestRuntimeDeityGateDoesNotGrantNonAgnosticBranchWithoutHydratedDeity(t *testing.T) {
	const source = `
function event_say(e)
  if e.other:GetDeity() == 201 then
    e.other:SummonItem(1001)
  elseif e.other:GetDeity() == 0 then
    e.self:Say("agnostic")
  end
end`

	capture, err := NewLuaBridge(".").ExecuteSayFromSource(source, progressionEvent(PlayerProxy{}))
	require.NoError(t, err)
	assert.Empty(t, capture.Items, "a non-agnostic reward must not be granted without authoritative deity context")
	assert.Equal(t, []string{"agnostic"}, capture.Responses)
}

func TestQuestGlobalScopeSeparatesPerPlayerAndSharedProgress(t *testing.T) {
	const source = `
function event_say(e)
  if e.message:findi("personal") then
    eq.set_global("personal_step", "1", 0, "F")
  elseif e.message:findi("shared") then
    eq.set_global("shared_step", "1", 2, "F")
  end
end`
	tests := []struct {
		keyword string
		name    string
		want    GlobalUpdate
	}{
		{keyword: "personal", name: "personal_step", want: GlobalUpdate{Name: "personal_step", Value: "1", Options: 0, Duration: "F"}},
		{keyword: "shared", name: "shared_step", want: GlobalUpdate{Name: "shared_step", Value: "1", Options: 2, Duration: "F"}},
	}
	for _, tt := range tests {
		t.Run(tt.keyword, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 10})
			event.Message = tt.keyword
			capture, err := NewLuaBridge(".").ExecuteSayFromSource(source, event)
			require.NoError(t, err)
			assert.Equal(t, tt.want, capture.Globals[tt.name])
		})
	}
}

func TestPerPlayerQuestStateDoesNotLeakAcrossFreshRuntimeContexts(t *testing.T) {
	const source = `
local visits = 0
function event_say(e)
  visits = visits + 1
  e.self:Say(tostring(visits))
end`
	bridge := NewLuaBridge(".")

	firstA, err := bridge.ExecuteSayFromSource(source, progressionEvent(PlayerProxy{ID: 10}))
	require.NoError(t, err)
	firstB, err := bridge.ExecuteSayFromSource(source, progressionEvent(PlayerProxy{ID: 20}))
	require.NoError(t, err)
	secondAEvent := progressionEvent(PlayerProxy{ID: 10})
	secondAEvent.ScriptState = firstA.ScriptState
	secondA, err := bridge.ExecuteSayFromSource(source, secondAEvent)
	require.NoError(t, err)

	assert.Equal(t, []string{"1"}, firstA.Responses)
	assert.Equal(t, []string{"1"}, firstB.Responses, "another player starts from independent runtime state")
	assert.Equal(t, []string{"2"}, secondA.Responses)
}

func TestNonRepeatableQuestRewardRequiresDurableCompletionState(t *testing.T) {
	const source = `
function event_say(e)
  if not e.message:findi("claim") then return end
  if qglobals.claimed == "1" then
    e.self:Say("already claimed")
    return
  end
  e.other:SummonItem(1001)
  eq.set_global("claimed", "1", 0, "F")
end`
	bridge := NewLuaBridge(".")
	first := progressionEvent(PlayerProxy{ID: 10})
	first.Message = "claim"
	firstCapture, err := bridge.ExecuteSayFromSource(source, first)
	require.NoError(t, err)
	assert.Equal(t, []QuestReward{{ItemID: 1001, Count: 1}}, firstCapture.Items)
	assert.Equal(t, "1", firstCapture.Globals["claimed"].Value)

	second := progressionEvent(PlayerProxy{ID: 10})
	second.Message = "claim"
	second.Globals = map[string]string{"claimed": "1"}
	secondCapture, err := bridge.ExecuteSayFromSource(source, second)
	require.NoError(t, err)
	assert.Empty(t, secondCapture.Items)
	assert.Equal(t, []string{"already claimed"}, secondCapture.Responses)
}

func TestExplicitlyRepeatableQuestCanRewardEachAcceptedEvent(t *testing.T) {
	const source = `
function event_forage_success(e)
  if e.item:GetID() == 13019 then e.other:SummonItem(1002) end
end`
	bridge := NewLuaBridge(".")
	for attempt := 0; attempt < 2; attempt++ {
		event := progressionEvent(PlayerProxy{ID: 10})
		event.Fields = map[string]any{"item_id": 13019}
		capture, err := bridge.ExecuteEventFromSource(source, "event_forage_success", event)
		require.NoError(t, err)
		assert.Equal(t, []QuestReward{{ItemID: 1002, Count: 1}}, capture.Items)
		assert.Empty(t, capture.Globals)
	}
}

func TestEpicDialogueStepOrderingRejectsSkippedAndRepeatedSteps(t *testing.T) {
	const source = `
function event_say(e)
  if e.message:findi("first") then
    if qglobals.epic == nil then eq.set_global("epic", "1", 0, "F") else e.self:Say("out of order") end
  elseif e.message:findi("second") then
    if qglobals.epic == "1" then eq.set_global("epic", "2", 0, "F") else e.self:Say("out of order") end
  elseif e.message:findi("final") then
    if qglobals.epic == "2" then e.other:SummonItem(9999) else e.self:Say("out of order") end
  end
end`
	tests := []struct {
		name      string
		stage     string
		message   string
		wantStage string
		wantItem  bool
		wantDeny  bool
	}{
		{name: "start", message: "first", wantStage: "1"},
		{name: "advance", stage: "1", message: "second", wantStage: "2"},
		{name: "finish", stage: "2", message: "final", wantItem: true},
		{name: "skip middle", stage: "1", message: "final", wantDeny: true},
		{name: "repeat first", stage: "1", message: "first", wantDeny: true},
		{name: "repeat middle", stage: "2", message: "second", wantDeny: true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 10})
			event.Message = tt.message
			if tt.stage != "" {
				event.Globals["epic"] = tt.stage
			}
			capture, err := NewLuaBridge(".").ExecuteSayFromSource(source, event)
			require.NoError(t, err)
			if tt.wantStage != "" {
				assert.Equal(t, tt.wantStage, capture.Globals["epic"].Value)
			}
			if tt.wantItem {
				assert.Equal(t, []QuestReward{{ItemID: 9999, Count: 1}}, capture.Items)
			}
			if tt.wantDeny {
				assert.Equal(t, []string{"out of order"}, capture.Responses)
				assert.Empty(t, capture.Items)
				assert.Empty(t, capture.Globals)
			}
		})
	}
}

func TestSpawnTimerLifecycleOnlyAdvancesOnNamedTimer(t *testing.T) {
	const source = `
function event_spawn(e)
  eq.set_timer("ambush", 5000)
end
function event_timer(e)
  if e.timer ~= "ambush" then return end
  eq.stop_timer("ambush")
  eq.unique_spawn(9002, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
  eq.depop()
end`
	bridge := NewLuaBridge(".")
	spawnEvent := progressionEvent(PlayerProxy{ID: 10})
	spawnEvent.NPC.X, spawnEvent.NPC.Y, spawnEvent.NPC.Z, spawnEvent.NPC.Heading = 1, 2, 3, 4
	spawnEvent.SpawnInstanceID = 5001
	spawnCapture, err := bridge.ExecuteEventFromSource(source, "event_spawn", spawnEvent)
	require.NoError(t, err)
	assert.Equal(t, []TimerUpdate{{Name: "ambush", Interval: 5000}}, spawnCapture.Timers)
	assert.Empty(t, spawnCapture.Spawns)

	wrongTimer := progressionEvent(PlayerProxy{ID: 10})
	wrongTimer.Fields = map[string]any{"timer": "other"}
	wrongCapture, err := bridge.ExecuteEventFromSource(source, "event_timer", wrongTimer)
	require.NoError(t, err)
	assert.False(t, captureHasEffects(wrongCapture))

	timerEvent := progressionEvent(PlayerProxy{ID: 10})
	timerEvent.NPC.X, timerEvent.NPC.Y, timerEvent.NPC.Z, timerEvent.NPC.Heading = 1, 2, 3, 4
	timerEvent.SpawnInstanceID = 5001
	timerEvent.Fields = map[string]any{"timer": "ambush"}
	timerCapture, err := bridge.ExecuteEventFromSource(source, "event_timer", timerEvent)
	require.NoError(t, err)
	assert.Equal(t, []TimerUpdate{{Name: "ambush", Stop: true}}, timerCapture.Timers)
	assert.Equal(t, []QuestSpawnRequest{{NPCTypeID: 9002, X: 1, Y: 2, Z: 3, Heading: 4, Unique: true}}, timerCapture.Spawns)
	assert.Equal(t, []QuestDepopRequest{{SpawnInstanceID: 5001}}, timerCapture.Depops)
}

func TestTriggeredGroundObjectRequiresExpectedSignalAndPreservesDecay(t *testing.T) {
	const source = `
function event_signal(e)
  if e.signal == 7 then
    eq.create_ground_object(12147, 10, 20, 30, 40, 60000)
  end
end`
	bridge := NewLuaBridge(".")
	for _, tt := range []struct {
		signal int
		want   bool
	}{{signal: 6}, {signal: 7, want: true}, {signal: 8}} {
		t.Run(string(rune('0'+tt.signal)), func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 10})
			event.Fields = map[string]any{"signal": tt.signal}
			capture, err := bridge.ExecuteEventFromSource(source, "event_signal", event)
			require.NoError(t, err)
			if !tt.want {
				assert.Empty(t, capture.GroundItems)
				return
			}
			require.Len(t, capture.GroundItems, 1)
			assert.Equal(t, int32(12147), capture.GroundItems[0].ItemID)
			assert.Equal(t, 10.0, capture.GroundItems[0].X)
			assert.Equal(t, 20.0, capture.GroundItems[0].Y)
			assert.Equal(t, 30.0, capture.GroundItems[0].Z)
			assert.Equal(t, 40.0, capture.GroundItems[0].Heading)
			assert.Equal(t, int64(60000), capture.GroundItems[0].DecayMS)
		})
	}
}

func TestFishingAndForageEventsHydrateCaughtItemAndEventFields(t *testing.T) {
	const source = `
function event_fish_success(e)
  if e.item:IsValid() and e.item:GetID() == e.item_id then
    e.self:Say("fish " .. e.item:GetID())
  end
end
function event_forage_success(e)
  if e.item:IsValid() and e.item:GetID() == e.item_id then
    e.self:Say("forage " .. e.item:GetID())
  end
end`
	tests := []struct {
		handler string
		itemID  int
		want    string
	}{
		{handler: "event_fish_success", itemID: 13019, want: "fish 13019"},
		{handler: "event_forage_success", itemID: 14905, want: "forage 14905"},
	}
	for _, tt := range tests {
		t.Run(tt.handler, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 10})
			event.Fields = map[string]any{"item_id": tt.itemID}
			capture, err := NewLuaBridge(".").ExecuteEventFromSource(source, tt.handler, event)
			require.NoError(t, err)
			assert.Equal(t, []string{tt.want}, capture.Responses)
		})
	}
}

func TestInvalidFishingAndForageItemsDoNotAdvanceQuest(t *testing.T) {
	const source = `
function event_fish_success(e)
  if e.item:IsValid() then eq.set_global("fish_step", "1", 0, "F") end
end
function event_forage_success(e)
  if e.item:IsValid() then eq.set_global("forage_step", "1", 0, "F") end
end`
	for _, handler := range []string{"event_fish_success", "event_forage_success"} {
		t.Run(handler, func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 10})
			event.Fields = map[string]any{"item_id": 0}
			capture, err := NewLuaBridge(".").ExecuteEventFromSource(source, handler, event)
			require.NoError(t, err)
			assert.Empty(t, capture.Globals)
		})
	}
}

func TestEncounterCanRegisterFishingAndForagePlayerEvents(t *testing.T) {
	const source = `
local function caught(e)
  e.other:SummonItem(e.item_id)
end
function event_encounter_load(e)
  eq.register_player_event(Event.fish_success, caught)
  eq.register_player_event(Event.forage_success, caught)
end`
	bridge := NewLuaBridge(".")
	for _, eventType := range []RuntimeEventType{RuntimeEventFishSuccess, RuntimeEventForageSuccess} {
		t.Run(string(eventType), func(t *testing.T) {
			event := progressionEvent(PlayerProxy{ID: 10})
			event.Fields = map[string]any{"item_id": 13019}
			capture, err := bridge.ExecuteRegisteredPlayerEventFromSource(source, eventType, event)
			require.NoError(t, err)
			assert.Equal(t, []QuestReward{{ItemID: 13019, Count: 1}}, capture.Items)
		})
	}
}
