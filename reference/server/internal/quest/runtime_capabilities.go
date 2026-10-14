package quest

import (
	_ "embed"
	"encoding/json"
	"fmt"
	"strings"

	lua "github.com/yuin/gopher-lua"
)

// This is a deliberately explicit backlog, not a claim that every other bridge
// API is fully implemented. The same registry drives stub bindings and audit
// classification, so a reached stub cannot be mistaken for working behavior.
//
//go:embed deferred_runtime_apis.json
var deferredRuntimeAPISource []byte

var deferredRuntimeAPIs = func() map[string]string {
	var apis map[string]string
	if err := json.Unmarshal(deferredRuntimeAPISource, &apis); err != nil {
		panic(fmt.Sprintf("invalid deferred quest API registry: %v", err))
	}
	return apis
}()

func (b *LuaBridge) registerDeferredQuestAPIs(L *lua.LState, eq *lua.LTable, capture *QuestCapture) {
	for api := range deferredRuntimeAPIs {
		if strings.HasPrefix(api, "eq.") {
			L.SetField(eq, strings.TrimPrefix(api, "eq."), L.NewFunction(func(L *lua.LState) int {
				return capture.recordDeferredAPI(L, api)
			}))
		}
	}
}

func (capture *QuestCapture) recordDeferredAPI(L *lua.LState, api string) int {
	reason, known := deferredRuntimeAPIs[api]
	if !known {
		L.RaiseError("unregistered deferred quest API: %s", api)
		return 0
	}
	for _, existing := range capture.DeferredAPIs {
		if existing == api {
			return 0
		}
	}
	// Bounded by the registry, even if a script calls the same stub in a loop.
	capture.DeferredAPIs = append(capture.DeferredAPIs, api)
	if capture.requireImplementedEffects || requiresAuthoritativeQuestRead(api) {
		L.RaiseError("quest runtime capability not implemented: %s: %s", api, reason)
	}
	return 0
}

// An unresolved read is not an empty population, slot or inventory. Unlike
// cosmetic stubs, fake read results can select the wrong reward/state branch
// or redirect effects to another actor during ordinary play.
func requiresAuthoritativeQuestRead(api string) bool {
	switch api {
	case "entity_list.GetMobByNpcTypeID", "entity_list.GetNPCByNPCTypeID", "entity_list.GetNPCBySpawnID":
		return true
	case "entity_list.GetNPCList", "entity_list.GetNPCEntries":
		return true
	case "player.GetItemIDAt", "player.GetInventory.HasItem":
		return true
	case "eq.get_data", "eq.get_spawn_condition":
		return true
	}
	return false
}

func (capture *QuestCapture) checkedResult() (*QuestCapture, error) {
	if capture.actorEffectError != nil {
		return nil, capture.actorEffectError
	}
	for _, api := range capture.DeferredAPIs {
		if requiresAuthoritativeQuestRead(api) {
			return nil, fmt.Errorf("quest runtime capability not implemented: %s", api)
		}
	}
	// Lua pcall may catch RaiseError. A strict behavior test must still reject
	// the invocation rather than accept rewards after an unexecuted effect.
	if capture.requireImplementedEffects && len(capture.DeferredAPIs) > 0 {
		return nil, fmt.Errorf("quest runtime capabilities not implemented: %s", strings.Join(capture.DeferredAPIs, ", "))
	}
	return capture, nil
}
