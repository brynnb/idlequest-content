package quest

import (
	"fmt"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestDeferredQuestAPIsAreObservableAndStrictlyRejectable(t *testing.T) {
	for api, reason := range deferredRuntimeAPIs {
		t.Run(api, func(t *testing.T) {
			require.NotEmpty(t, reason)
			call := api
			if strings.HasPrefix(api, "entity_list.") {
				call = "eq.get_entity_list():" + strings.TrimPrefix(api, "entity_list.")
			}
			arguments := ""
			event := progressionEvent(PlayerProxy{ID: 123})
			if api == "eq.attack_npc_type" {
				arguments = "9141"
				event.SpawnInstanceID = 6001
				event.ResolveNPC = func(QuestNPCQuery) (*NPCProxy, error) {
					return &NPCProxy{ID: 9141, SpawnInstanceID: 6002}, nil
				}
			}
			if api == "eq.start" {
				arguments = "14"
			}
			if api == "player.GetItemIDAt" {
				call, arguments = "e.other:GetItemIDAt", "13"
			}
			if api == "player.GetInventory.HasItem" {
				call, arguments = "e.other:GetInventory():HasItem", "81890, 1, 2"
			}
			if api == "e.self:CastSpell" {
				arguments = "17, e.other:GetID()"
			}
			if api == "e.self:AddToHateList" {
				arguments = "e.other, 1"
			}
			if api == "e.self:MoveTo" || api == "e.self:GMMove" {
				arguments = "1, 2, 3"
			}
			source := fmt.Sprintf(`function event_say(e)
  for i = 1, 100 do %s(%s) end
  e.self:Say("after deferred effect")
end`, call, arguments)
			bridge := NewLuaBridge(".")
			capture, err := bridge.ExecuteSayFromSource(source, event)
			if requiresAuthoritativeQuestRead(api) {
				require.ErrorContains(t, err, "quest runtime capability not implemented: "+api)
				require.Nil(t, capture, "ordinary execution must not substitute the event NPC")
				return
			}
			require.NoError(t, err)
			require.Equal(t, []string{api}, capture.DeferredAPIs, "diagnostics must be deduplicated")
			require.Equal(t, []string{"after deferred effect"}, capture.Responses, "normal compatibility mode preserves existing behavior")
			require.Empty(t, capture.Items)
			require.Empty(t, capture.Spawns)

			bridge.RequireImplementedEffects = true
			_, err = bridge.ExecuteSayFromSource(source, progressionEvent(PlayerProxy{}))
			require.ErrorContains(t, err, "quest runtime capability not implemented: "+api)
		})
	}
}

func TestUnresolvedActorLookupsCannotRedirectEffectsOrHideBehindPcall(t *testing.T) {
	for _, method := range []string{"GetMobByNpcTypeID", "GetNPCByNPCTypeID", "GetNPCBySpawnID"} {
		t.Run(method, func(t *testing.T) {
			for _, strict := range []bool{false, true} {
				bridge := NewLuaBridge(".")
				bridge.RequireImplementedEffects = strict
				capture, err := bridge.ExecuteSayFromSource(fmt.Sprintf(`function event_say(e)
  pcall(function()
    local target = eq.get_entity_list():%s(9002)
    target:AddItem(18099, 1)
    target:Signal(7)
    target:Depop()
  end)
  e.other:SummonItem(14366)
end`, method), &LuaEvent{NPC: &NPCProxy{ID: 9001}, Player: &PlayerProxy{}, SpawnInstanceID: 5002})
				require.ErrorContains(t, err, "quest runtime capability not implemented: entity_list."+method)
				require.Nil(t, capture, "no reward or wrong-actor effects may escape the failed lookup")
			}
		})
	}
}

func TestDeferredQuestAPIsOnlyReportReachedBranches(t *testing.T) {
	bridge := NewLuaBridge(".")
	bridge.RequireImplementedEffects = true
	capture, err := bridge.ExecuteSayFromSource(`function event_say(e)
  if e.message == "follow" then eq.follow(123) end
  e.self:Say("peaceful dialogue")
end`, progressionEvent(PlayerProxy{}))
	require.NoError(t, err)
	require.Empty(t, capture.DeferredAPIs)
	require.Equal(t, []string{"peaceful dialogue"}, capture.Responses)
}

func TestUnexecutedMovementDoesNotChangePositionOrEscapeStrictPcall(t *testing.T) {
	for _, method := range []string{"MoveTo", "GMMove"} {
		t.Run(method, func(t *testing.T) {
			source := fmt.Sprintf(`function event_say(e)
  pcall(function() e.self:%s(100, 200, 300, 64) end)
  e.self:Say(e.self:GetX() .. ":" .. e.self:GetY() .. ":" .. e.self:GetZ())
  e.other:SummonItem(14366)
end`, method)
			bridge := NewLuaBridge(".")
			event := &LuaEvent{NPC: &NPCProxy{ID: 9001, X: 1, Y: 2, Z: 3}, Player: &PlayerProxy{}}
			capture, err := bridge.ExecuteSayFromSource(source, event)
			require.NoError(t, err)
			require.Equal(t, []string{"1:2:3"}, capture.Responses)
			require.Equal(t, []string{"e.self:" + method}, capture.DeferredAPIs)
			bridge.RequireImplementedEffects = true
			capture, err = bridge.ExecuteSayFromSource(source, event)
			require.ErrorContains(t, err, "not implemented")
			require.Nil(t, capture, "pcall must not turn an unexecuted move into a certified reward")
		})
	}
}

func TestDivineDutyDonationsCannotCertifyUnexecutedHealingOrCures(t *testing.T) {
	source := readOverrideLua(t, "idlequest-authored", "neriakc", "Ulazia_W-slug-Selo")
	for _, tc := range []struct{ gold, spell int }{{10, 17}, {8, 203}, {6, 213}} {
		t.Run(fmt.Sprintf("spell_%d", tc.spell), func(t *testing.T) {
			newEvent := func() *LuaEvent {
				return &LuaEvent{NPC: &NPCProxy{ID: 42000}, Player: &PlayerProxy{ID: 101}, Trade: &TradeProxy{Gold: tc.gold}}
			}
			bridge := NewLuaBridge("upstream/projecteq")
			capture, err := bridge.ExecuteTradeFromSource(source, newEvent())
			require.NoError(t, err)
			require.Equal(t, []int{tc.spell}, capture.Spells, "legacy capture is not proof the effect was applied")
			require.Equal(t, []string{"e.self:CastSpell"}, capture.DeferredAPIs)
			bridge.RequireImplementedEffects = true
			_, err = bridge.ExecuteTradeFromSource(source, newEvent())
			require.ErrorContains(t, err, "quest runtime capability not implemented: e.self:CastSpell")
		})
	}
	bridge := NewLuaBridge("upstream/projecteq")
	bridge.RequireImplementedEffects = true
	capture, err := bridge.ExecuteSayFromSource(source, &LuaEvent{NPC: &NPCProxy{}, Player: &PlayerProxy{}, Message: "hail"})
	require.NoError(t, err)
	require.NotEmpty(t, capture.Responses, "unrelated dialogue remains testable")
	require.Empty(t, capture.DeferredAPIs)
}

func TestNPCEnumerationCannotCertifyPopulationDependentRewards(t *testing.T) {
	for _, expression := range []string{
		`eq.get_entity_list():GetNPCList().entries`,
		`eq.get_entity_list():GetNPCEntries()`,
	} {
		t.Run(expression, func(t *testing.T) {
			bridge := NewLuaBridge(".")
			bridge.RequireImplementedEffects = true
			// An empty or singleton stand-in can falsely satisfy an encounter's
			// "all other actors are gone" condition. Strict verification must
			// reject the enumeration, including its normalized iterator form.
			capture, err := bridge.ExecuteSayFromSource(fmt.Sprintf(`function event_say(e)
  local count = 0
  for npc in %s do count = count + 1 end
  if count <= 1 then e.other:SummonItem(1001) end
end`, expression), progressionEvent(PlayerProxy{}))
			require.ErrorContains(t, err, "quest runtime capability not implemented: entity_list.GetNPC")
			require.Nil(t, capture)
		})
	}
}

func TestSpawnProxyHateCannotMasqueradeAsExecutedCombat(t *testing.T) {
	const source = `function event_say(e)
  local attacker = eq.spawn2(39155, 0, 0, 1, 2, 3, 4)
  attacker:AddToHateList(e.other, 1)
  e.other:SummonItem(14381)
end`
	bridge := NewLuaBridge(".")
	capture, err := bridge.ExecuteSayFromSource(source, progressionEvent(PlayerProxy{ID: 123, Name: "Knight"}))
	require.NoError(t, err)
	require.Equal(t, []string{"e.self:AddToHateList"}, capture.DeferredAPIs)
	require.Len(t, capture.Spawns, 1)
	require.Empty(t, capture.Attacks)
	bridge.RequireImplementedEffects = true
	capture, err = bridge.ExecuteSayFromSource(source, progressionEvent(PlayerProxy{Name: "Knight"}))
	require.ErrorContains(t, err, "e.self:AddToHateList")
	require.Nil(t, capture, "unexecuted hate must not certify a reward-bearing branch")
}

func TestStrictDeferredQuestAPIsCannotBeHiddenByLuaPcall(t *testing.T) {
	bridge := NewLuaBridge(".")
	bridge.RequireImplementedEffects = true
	capture, err := bridge.ExecuteSayFromSource(`function event_say(e)
  pcall(function() eq.follow(123) end)
  pcall(function() eq.follow(123) end)
  e.other:SummonItem(1001)
end`, progressionEvent(PlayerProxy{}))
	require.ErrorContains(t, err, "quest runtime capabilities not implemented: eq.follow")
	require.Nil(t, capture, "strict mode must not expose a successful reward capture")
}

func TestMergeQuestCapturePreservesDeferredAPIsWithoutDuplicates(t *testing.T) {
	dst := &QuestCapture{DeferredAPIs: []string{"eq.attack"}}
	src := &QuestCapture{DeferredAPIs: []string{"eq.attack", "eq.follow"}}
	mergeQuestCapture(dst, src)
	require.Equal(t, []string{"eq.attack", "eq.follow"}, dst.DeferredAPIs)
	require.Equal(t, []string{"eq.attack", "eq.follow"}, src.DeferredAPIs)
}

func TestDeferredQuestAPIRegistryOnlyContainsBoundNamespaces(t *testing.T) {
	for api := range deferredRuntimeAPIs {
		require.True(t, strings.HasPrefix(api, "eq.") || strings.HasPrefix(api, "e.self:") || strings.HasPrefix(api, "entity_list.") || api == "player.GetItemIDAt" || api == "player.GetInventory.HasItem", api)
	}
}
