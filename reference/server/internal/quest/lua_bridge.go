package quest

import (
	"context"
	"encoding/json"
	"fmt"
	"idlequest/internal/mechanics"
	"idlequest/internal/questluasource"
	"math"
	"math/rand"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	lua "github.com/yuin/gopher-lua"
)

const NPCAddedLootScriptStateKey = "__idlequest_npc_added_loot"

// FactionReward represents a reputation change
type FactionReward struct {
	FactionID int
	Amount    int
}

// NPCSignal represents a signal sent to an NPC
type NPCSignal struct {
	NPCID             int
	SignalID          int
	DelayMS           int64
	Settled           bool `json:"-"`
	SpawnInstanceID   int64
	PendingSpawnIndex int
}

type NPCAddedLoot struct {
	NPCID  int32 `json:"npcId"`
	ItemID int32 `json:"itemId"`
	// Keep physical inventory attached to the exact actor. Old records without
	// this field remain scoped by their owner/zone/instance/spawn state row.
	SpawnInstanceID int64 `json:"spawnInstanceId,omitempty"`
	// Historical persisted name: this is NPC:AddItem's charges argument.
	// Each entry represents one item, not Count copies of that item.
	Count int `json:"count"`
}

// GlobalUpdate represents a change to quest_globals
type GlobalUpdate struct {
	Name     string
	Value    string
	Options  int
	Duration string
	Delete   bool
}

// TaskAction represents a task-related side-effect
type TaskAction struct {
	TaskID int
	Action string // "assign", "fail", "complete", "step"
	StepID int
}

// PopupInfo represents a popup dialog sent to the player
type PopupInfo struct {
	ID       int
	Title    string
	Text     string
	Buttons  int
	Duration int
}

// TimerUpdate represents a timer start/stop
type TimerUpdate struct {
	Name     string
	Interval int // ms
	Stop     bool
	Pause    bool
	Resume   bool
}

type HPEventUpdate struct {
	Percent    int
	Increasing bool
}

type ProximityUpdate struct {
	MinX, MaxX float64
	MinY, MaxY float64
	MinZ, MaxZ float64
	Clear      bool
}

type QuestSkillUpdate struct {
	SkillID int
	Value   int
}

// QuestCapture tracks all side-effects from a Lua script execution
// Server event metadata, never populated by Lua or accepted from client JSON.
type QuestWaypointProgress struct {
	Waypoint int
	Depart   bool
}

type QuestCapture struct {
	WaypointProgress *QuestWaypointProgress `json:"-"`
	// A durable intent ID is not an execution receipt. Set only after commit.
	RuntimeActorEffectDeliveryID string `json:"-"`
	RuntimeTriggersSettled       bool   `json:"-"`
	RuntimeTimersSettled         bool   `json:"-"`
	// Diagnostics only: these are requests the runtime did not execute. They
	// must never be counted as applied effects or written as quest progress.
	DeferredAPIs              []string
	requireImplementedEffects bool
	actorEffectError          error
	Responses                 []string
	// Indexed metadata preserves dialogue-window strings while runtime chat
	// retains the actual speaker and local Say scope.
	NPCSpeech map[int]NPCSpeech
	SayLinks  []DialogueOption
	Exp       int
	Factions  []FactionReward
	Items     []QuestReward
	Currency  QuestCurrency
	Ding      bool
	Signals   []NPCSignal
	Globals   map[string]GlobalUpdate
	// Preserve script order: set/pause/resume and stop-all are operations,
	// not a last-value map of independent timer names.
	Timers               []TimerUpdate
	Tasks                []TaskAction
	Popups               []PopupInfo
	Spells               []int
	SpellCasts           []QuestSpellCast
	spellActors          map[int64]QuestSpellActor
	Spawns               []QuestSpawnRequest
	Attacks              []QuestAttackRequest
	HateChanges          []QuestHateChange
	Depops               []QuestDepopRequest
	PlayerMoves          []QuestPlayerMoveRequest
	NPCMoves             []QuestNPCMoveRequest
	Doors                []QuestDoorRequest
	Binds                []QuestBindRequest
	GroundItems          []QuestGroundObjectRequest
	NPCAddedLoot         []NPCAddedLoot
	ExternalNPCAddedLoot []NPCAddedLoot
	ZoneFlags            []int
	SkillUpdates         []QuestSkillUpdate
	HPEvents             []HPEventUpdate
	Proximity            *ProximityUpdate
	ProximitySayEnabled  *bool
	ScriptState          map[string]any
	runtimeStateWrites   []questRuntimeStateWrite
	EncounterLoads       []string
	// Registrations holds EQEmu event callbacks registered by encounter scripts.
	Registrations []QuestEventRegistration
	// CurrentTrade stores a pointer to the original Trade so CheckHandin can deduct items.
	CurrentTrade *TradeProxy
}

type QuestEventRegistration struct {
	Scope     string
	Event     string
	NPCTypeID int32
	Handler   lua.LValue `json:"-"`
}

func NewQuestCapture() *QuestCapture {
	return &QuestCapture{
		Globals:     make(map[string]GlobalUpdate),
		ScriptState: make(map[string]any),
	}
}

func cloneScriptState(state map[string]any) map[string]any {
	clone := make(map[string]any)
	for key, value := range state {
		clone[key] = value
	}
	return clone
}

func recordNPCAddedLootInState(state map[string]any, added NPCAddedLoot) error {
	if state == nil {
		return fmt.Errorf("quest NPC inventory state is unavailable")
	}
	existing, err := npcAddedLootFromState(state)
	if err != nil {
		return err
	}
	existing = append(existing, added)
	state[NPCAddedLootScriptStateKey] = existing
	return nil
}

func NPCAddedLootFromScriptState(state map[string]any) ([]NPCAddedLoot, error) {
	return npcAddedLootFromState(state)
}

func npcAddedLootFromState(state map[string]any) ([]NPCAddedLoot, error) {
	if state == nil {
		return nil, nil
	}
	raw, ok := state[NPCAddedLootScriptStateKey]
	if !ok || raw == nil {
		return nil, nil
	}
	encoded, err := json.Marshal(raw)
	if err != nil {
		return nil, fmt.Errorf("encode quest NPC inventory: %w", err)
	}
	var items []NPCAddedLoot
	if err := json.Unmarshal(encoded, &items); err != nil {
		return nil, fmt.Errorf("decode quest NPC inventory: %w", err)
	}
	return items, nil
}

// LuaEvent represents the 'e' table passed to Lua events
type LuaEvent struct {
	ReadNPCCombat QuestNPCCombatReader `json:"-"`
	ReadTimer     QuestTimerReader     `json:"-"`
	NPCVitals     *QuestNPCVitals
	NPC           *NPCProxy
	Player        *PlayerProxy
	SelfIsPlayer  bool
	Message       string
	Trade         *TradeProxy
	Item          *ItemInstProxy
	Corpse        *CorpseProxy
	Door          *DoorProxy
	Globals       map[string]string // Current values of quest_globals for this char/npc
	Language      int
	// Fields supplies event-specific values such as timer, signal, hp_event,
	// waypoint, and combat state. Core self/other/message/trade/qglobals fields
	// remain strongly typed above.
	Fields          map[string]any
	SpawnInstanceID int64
	ScriptState     map[string]any
	// VisibleNPCTypeIDs supplies the NPC types currently visible to this
	// character/instance for entity-list queries such as
	// IsMobSpawnedByNpcTypeID.
	VisibleNPCTypeIDs []int32
	ResolveNPC        QuestNPCResolver   `json:"-"`
	ListNPCs          QuestNPCEnumerator `json:"-"`
}

// NPCProxy wraps a Go NPC for Lua
type NPCProxy struct {
	ID              int32
	SpawnInstanceID int64
	Name            string
	NPCFactionID    int32
	X               float64
	Y               float64
	Z               float64
	Heading         float64
	Race            uint16
	Class           uint8
	Gender          uint8
	PrimaryFaction  int32
	HP              int64
	MaxHP           int64
	Capture         *QuestCapture
	// One-based request index, not a pointer into the appendable spawn slice.
	PendingSpawnIndex      int
	externalActor          bool
	missingActor           bool
	readCombatActor        QuestNPCCombatReader
	combatOwnerCharacterID int64
	combatOwner            *PlayerProxy
}

func (n *NPCProxy) Say(L *lua.LState) int {
	msg := L.CheckString(2)
	if n.Capture.NPCSpeech == nil {
		n.Capture.NPCSpeech = make(map[int]NPCSpeech)
	}
	n.Capture.NPCSpeech[len(n.Capture.Responses)] = NPCSpeech{Name: n.Name, X: n.X, Y: n.Y, Z: n.Z}
	n.Capture.Responses = append(n.Capture.Responses, msg)
	return 0
}

func (n *NPCProxy) GetName(L *lua.LState) int {
	L.Push(lua.LString(n.Name))
	return 1
}

func (n *NPCProxy) IsPet(L *lua.LState) int {
	L.Push(lua.LBool(false))
	return 1
}

func (n *NPCProxy) Signal(L *lua.LState) int {
	if n.missingActor {
		return 0
	}
	signalID := L.CheckInt(2)
	n.Capture.Signals = append(n.Capture.Signals, NPCSignal{
		NPCID:             int(n.ID),
		SignalID:          signalID,
		SpawnInstanceID:   n.SpawnInstanceID,
		PendingSpawnIndex: n.PendingSpawnIndex,
	})
	return 0
}

func (n *NPCProxy) Depop(L *lua.LState) int {
	if n.missingActor {
		return 0
	}
	n.Capture.Depops = append(n.Capture.Depops, QuestDepopRequest{NPCTypeID: n.ID, SpawnInstanceID: n.SpawnInstanceID, PendingSpawnIndex: n.PendingSpawnIndex})
	return 0
}

func (n *NPCProxy) AddItem(L *lua.LState) int {
	if n.missingActor {
		return 0
	}
	itemID := L.CheckInt(2)
	count := 1
	if L.GetTop() >= 3 {
		count = L.CheckInt(3)
	}
	if itemID <= 0 || count < -1 || n.Capture == nil {
		return 0
	}
	added := NPCAddedLoot{NPCID: n.ID, ItemID: int32(itemID), Count: count, SpawnInstanceID: n.SpawnInstanceID}
	if n.externalActor {
		// Delivered to this actor by the world, never into the caller's state.
		n.Capture.ExternalNPCAddedLoot = append(n.Capture.ExternalNPCAddedLoot, added)
		return 0
	}
	if n.PendingSpawnIndex > 0 {
		index := n.PendingSpawnIndex - 1
		if index >= len(n.Capture.Spawns) || n.Capture.Spawns[index].NPCTypeID != n.ID {
			L.RaiseError("quest inventory has an invalid pending spawn")
			return 0
		}
		n.Capture.Spawns[index].AddedLoot = append(n.Capture.Spawns[index].AddedLoot, added)
		return 0
	}
	if err := recordNPCAddedLootInState(n.Capture.ScriptState, added); err != nil {
		L.RaiseError("%s", err)
		return 0
	}
	n.Capture.NPCAddedLoot = append(n.Capture.NPCAddedLoot, added)
	return 0
}

func (n *NPCProxy) CheckHandin(L *lua.LState) int {
	if L.GetTop() < 4 {
		L.Push(lua.LBool(false))
		return 1
	}

	handinTable := L.ToTable(3)
	requiredTable := L.ToTable(4)

	if handinTable == nil || requiredTable == nil {
		L.Push(lua.LBool(false))
		return 1
	}

	// items.lua passes handin_data as {[item_id] = count, platinum = N, ...}
	// Keys are numeric (item IDs) with numeric values (counts), or string currency keys.
	availItems := make(map[int]int)
	var availPlat, availGold, availSilver, availCopper int

	handinTable.ForEach(func(k, v lua.LValue) {
		switch key := k.(type) {
		case lua.LNumber:
			// Numeric key = item ID, value = count
			if count, ok := v.(lua.LNumber); ok {
				availItems[int(key)] += int(count)
			}
		case lua.LString:
			keyStr := strings.ToLower(string(key))
			switch keyStr {
			case "platinum":
				if num, ok := v.(lua.LNumber); ok {
					availPlat = int(num)
				}
			case "gold":
				if num, ok := v.(lua.LNumber); ok {
					availGold = int(num)
				}
			case "silver":
				if num, ok := v.(lua.LNumber); ok {
					availSilver = int(num)
				}
			case "copper":
				if num, ok := v.(lua.LNumber); ok {
					availCopper = int(num)
				}
			}
		}
	})

	reqPlat, reqGold, reqSilver, reqCopper := 0, 0, 0, 0
	reqItems := make(map[int]int)

	requiredTable.ForEach(func(k, v lua.LValue) {
		switch key := k.(type) {
		case lua.LNumber:
			// Numeric key = item ID, value = count
			if count, ok := v.(lua.LNumber); ok {
				reqItems[int(key)] += int(count)
			}
		case lua.LString:
			keyStr := strings.ToLower(string(key))
			switch keyStr {
			case "platinum":
				if num, ok := v.(lua.LNumber); ok {
					reqPlat = int(num)
				}
			case "gold":
				if num, ok := v.(lua.LNumber); ok {
					reqGold = int(num)
				}
			case "silver":
				if num, ok := v.(lua.LNumber); ok {
					reqSilver = int(num)
				}
			case "copper":
				if num, ok := v.(lua.LNumber); ok {
					reqCopper = int(num)
				}
			}
		}
	})

	success := true
	if availPlat < reqPlat {
		success = false
	}
	if availGold < reqGold {
		success = false
	}
	if availSilver < reqSilver {
		success = false
	}
	if availCopper < reqCopper {
		success = false
	}

	for itemID, reqQty := range reqItems {
		if availItems[itemID] < reqQty {
			success = false
			break
		}
	}

	if success {
		if n.Capture == nil || n.Capture.CurrentTrade == nil {
			L.Push(lua.LBool(false))
			return 1
		}
		success = consumeTradeRequirements(n.Capture.CurrentTrade, reqItems, reqPlat, reqGold, reqSilver, reqCopper)
	}

	L.Push(lua.LBool(success))
	return 1
}

func handinRequirementsFromLuaTable(table *lua.LTable) (map[int]int, int, int, int, int) {
	reqItems := make(map[int]int)
	reqPlat, reqGold, reqSilver, reqCopper := 0, 0, 0, 0

	if table == nil {
		return reqItems, reqPlat, reqGold, reqSilver, reqCopper
	}

	table.ForEach(func(k, v lua.LValue) {
		count := int(lua.LVAsNumber(v))
		if count <= 0 {
			return
		}
		switch key := k.(type) {
		case lua.LNumber:
			reqItems[int(key)] += count
		case lua.LString:
			switch strings.ToLower(string(key)) {
			case "platinum":
				reqPlat += count
			case "gold":
				reqGold += count
			case "silver":
				reqSilver += count
			case "copper":
				reqCopper += count
			}
		}
	})

	return reqItems, reqPlat, reqGold, reqSilver, reqCopper
}

func consumeTradeRequirements(trade *TradeProxy, reqItems map[int]int, reqPlat, reqGold, reqSilver, reqCopper int) bool {
	if trade == nil {
		return false
	}
	if trade.Platinum < reqPlat || trade.Gold < reqGold || trade.Silver < reqSilver || trade.Copper < reqCopper {
		return false
	}

	available := make(map[int]int)
	for _, itemID := range trade.Items {
		available[itemID]++
	}
	for itemID, reqQty := range reqItems {
		if reqQty <= 0 {
			continue
		}
		if available[itemID] < reqQty {
			return false
		}
	}

	trade.Platinum -= reqPlat
	trade.Gold -= reqGold
	trade.Silver -= reqSilver
	trade.Copper -= reqCopper

	for itemID, reqQty := range reqItems {
		if reqQty <= 0 {
			continue
		}
		removed := 0
		newItems := make([]int, 0, len(trade.Items)-reqQty)
		for _, handedItemID := range trade.Items {
			if handedItemID == itemID && removed < reqQty {
				removed++
				continue
			}
			newItems = append(newItems, handedItemID)
		}
		trade.Items = newItems
	}

	return true
}

func (n *NPCProxy) ReturnHandinItems(L *lua.LState) int {
	// Mock
	return 0
}

func (n *NPCProxy) CastSpell(L *lua.LState) int {
	n.Capture.recordDeferredAPI(L, "e.self:CastSpell")
	spellID := L.CheckInt(2)
	n.Capture.Spells = append(n.Capture.Spells, spellID)
	targetID := int64(L.CheckNumber(3))
	n.Capture.SpellCasts = append(n.Capture.SpellCasts, QuestSpellCast{SpellID: int32(spellID), Caster: n.spellActor(), Target: n.Capture.spellActors[targetID], TargetID: targetID})
	return 0
}

func (n *NPCProxy) GetID(L *lua.LState) int {
	L.Push(lua.LNumber(n.SpawnInstanceID))
	return 1
}

func (n *NPCProxy) Emote(L *lua.LState) int {
	msg := L.CheckString(2)
	n.Capture.Responses = append(n.Capture.Responses, fmt.Sprintf("%s %s", n.Name, msg))
	return 0
}

func (n *NPCProxy) GetX(L *lua.LState) int {
	L.Push(lua.LNumber(n.X))
	return 1
}

func (n *NPCProxy) GetY(L *lua.LState) int {
	L.Push(lua.LNumber(n.Y))
	return 1
}

func (n *NPCProxy) GetZ(L *lua.LState) int {
	L.Push(lua.LNumber(n.Z))
	return 1
}

func (n *NPCProxy) GetHeading(L *lua.LState) int {
	L.Push(lua.LNumber(n.Heading))
	return 1
}

func (n *NPCProxy) GetNPCTypeID(L *lua.LState) int {
	L.Push(lua.LNumber(n.ID))
	return 1
}

func (n *NPCProxy) GetRace(L *lua.LState) int {
	L.Push(lua.LNumber(n.Race))
	return 1
}

func (n *NPCProxy) GetGender(L *lua.LState) int {
	L.Push(lua.LNumber(n.Gender))
	return 1
}

func (n *NPCProxy) GetClass(L *lua.LState) int    { L.Push(lua.LNumber(n.Class)); return 1 }
func (n *NPCProxy) GetBaseRace(L *lua.LState) int { L.Push(lua.LNumber(n.Race)); return 1 }
func (n *NPCProxy) GetPrimaryFaction(L *lua.LState) int {
	L.Push(lua.LNumber(n.PrimaryFaction))
	return 1
}
func (n *NPCProxy) GetHP(L *lua.LState) int    { L.Push(lua.LNumber(n.HP)); return 1 }
func (n *NPCProxy) TempName(L *lua.LState) int { n.Name = L.CheckString(2); return 0 }

func (n *NPCProxy) Message(L *lua.LState) int {
	// Message(type, text)
	msg := L.CheckString(3)
	n.Capture.Responses = append(n.Capture.Responses, msg)
	return 0
}

func (n *NPCProxy) Shout(L *lua.LState) int {
	msg := L.CheckString(2)
	n.Capture.Responses = append(n.Capture.Responses, fmt.Sprintf("[Shout] %s says, '%s'", n.Name, msg))
	return 0
}

func (n *NPCProxy) QuestSay(L *lua.LState) int {
	// QuestSay(client, msg) — arg1=self, arg2=client, arg3=msg
	if L.GetTop() >= 3 {
		msg := L.CheckString(3)
		n.Capture.Responses = append(n.Capture.Responses, msg)
	}
	return 0
}

func (n *NPCProxy) CastToNPC(L *lua.LState) int {
	L.Push(L.CheckUserData(1)) // Return self
	return 1
}

func (n *NPCProxy) HasItem(L *lua.LState) int {
	L.Push(lua.LBool(false))
	return 1
}

func (n *NPCProxy) SetSpecialAbility(L *lua.LState) int {
	return n.Capture.recordDeferredAPI(L, "e.self:SetSpecialAbility")
}

func (n *NPCProxy) SetSpecialAbilityParam(L *lua.LState) int {
	return n.Capture.recordDeferredAPI(L, "e.self:SetSpecialAbilityParam")
}

func (n *NPCProxy) ModSkillDmgTaken(L *lua.LState) int {
	return 0
}

func (n *NPCProxy) ModifyNPCStat(L *lua.LState) int {
	return n.Capture.recordDeferredAPI(L, "e.self:ModifyNPCStat")
}

func (n *NPCProxy) WipeHateList(L *lua.LState) int {
	return n.Capture.recordDeferredAPI(L, "e.self:WipeHateList")
}

func (n *NPCProxy) AddToHateList(L *lua.LState) int {
	return n.captureHateAddition(L)
}

func (n *NPCProxy) SetHP(L *lua.LState) int {
	hp := int64(L.CheckNumber(2))
	n.HP = hp
	return 0
}

func (n *NPCProxy) GetMaxHP(L *lua.LState) int {
	L.Push(lua.LNumber(n.MaxHP))
	return 1
}

func (n *NPCProxy) GetHPRatio(L *lua.LState) int {
	if n.MaxHP <= 0 {
		return n.Capture.rejectActorEffect(L, "NPC health ratio requires a positive maximum HP snapshot")
	}
	L.Push(lua.LNumber(float64(n.HP) / float64(n.MaxHP) * 100))
	return 1
}

func (n *NPCProxy) GetGrid(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (n *NPCProxy) GetSp(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (n *NPCProxy) GotoBind(L *lua.LState) int {
	return 0
}

func (n *NPCProxy) SetScale(L *lua.LState) int {
	return 0
}

func (n *NPCProxy) SetAppearance(L *lua.LState) int {
	return 0
}

func (n *NPCProxy) ChangeSize(L *lua.LState) int {
	return 0
}

func (n *NPCProxy) GetSpawnPointX(L *lua.LState) int {
	L.Push(lua.LNumber(n.X))
	return 1
}

func (n *NPCProxy) GetSpawnPointY(L *lua.LState) int {
	L.Push(lua.LNumber(n.Y))
	return 1
}

func (n *NPCProxy) GetSpawnPointZ(L *lua.LState) int {
	L.Push(lua.LNumber(n.Z))
	return 1
}

func (n *NPCProxy) GetSpawnPointH(L *lua.LState) int { L.Push(lua.LNumber(n.Heading)); return 1 }
func (n *NPCProxy) CalculateDistance(L *lua.LState) int {
	dx, dy, dz := n.X-float64(L.CheckNumber(2)), n.Y-float64(L.CheckNumber(3)), n.Z-float64(L.CheckNumber(4))
	L.Push(lua.LNumber(math.Sqrt(dx*dx + dy*dy + dz*dz)))
	return 1
}
func (n *NPCProxy) SetRace(L *lua.LState) int { n.Race = uint16(L.CheckInt(2)); return 0 }

func (n *NPCProxy) CastedSpellFinished(L *lua.LState) int {
	return 0
}

// PlayerProxy wraps a Go Character for Lua
type PlayerProxy struct {
	ID         uint32
	Name       string
	CharClass  string
	CharRace   string
	CharLevel  int
	ClassID    uint8
	RaceID     uint16
	Tasks      map[int]bool // Active tasks
	Activities map[string]bool
	Inventory  map[int]bool
	Factions   map[int]int
	Globals    map[string]string
	X          float64
	Y          float64
	Z          float64
	Heading    float64
	Capture    *QuestCapture
}

func (p *PlayerProxy) GetName(L *lua.LState) int {
	L.Push(lua.LString(p.Name))
	return 1
}

func (p *PlayerProxy) GetCleanName(L *lua.LState) int {
	L.Push(lua.LString(p.Name)) // Just use name for now
	return 1
}

func (p *PlayerProxy) CharacterID(L *lua.LState) int {
	L.Push(lua.LNumber(p.ID))
	return 1
}

func (p *PlayerProxy) CreateExpedition(L *lua.LState) int {
	expedition := L.NewTable()
	L.SetField(expedition, "valid", lua.LBool(true))
	L.Push(expedition)
	return 1
}

func (p *PlayerProxy) Class(L *lua.LState) int {
	L.Push(lua.LNumber(p.ClassID))
	return 1
}

func (p *PlayerProxy) Race(L *lua.LState) int {
	L.Push(lua.LNumber(p.RaceID))
	return 1
}

func (p *PlayerProxy) Level(L *lua.LState) int {
	L.Push(lua.LNumber(p.CharLevel))
	return 1
}

func (p *PlayerProxy) SummonItem(L *lua.LState) int {
	id := int(lua.LVAsNumber(L.Get(2)))
	qty := 1
	if L.GetTop() >= 3 {
		qty = L.CheckInt(3)
	}
	p.Capture.Items = append(p.Capture.Items, QuestReward{ItemID: id, Count: qty})
	return 0
}

func (p *PlayerProxy) AddEXP(L *lua.LState) int {
	exp := L.CheckInt(2)
	p.Capture.Exp += exp
	return 0
}

func (p *PlayerProxy) Ding(L *lua.LState) int {
	p.Capture.Ding = true
	return 0
}

func (p *PlayerProxy) Faction(L *lua.LState) int {
	factionID := L.CheckInt(2)
	value := L.CheckInt(3)
	p.Capture.Factions = append(p.Capture.Factions, FactionReward{FactionID: factionID, Amount: value})
	return 0
}

func (p *PlayerProxy) RewardFaction(L *lua.LState) int {
	return p.Faction(L)
}

func (p *PlayerProxy) GiveCash(L *lua.LState) int {
	p.Capture.Currency.Copper += L.CheckInt(2)
	p.Capture.Currency.Silver += L.CheckInt(3)
	p.Capture.Currency.Gold += L.CheckInt(4)
	p.Capture.Currency.Platinum += L.CheckInt(5)
	return 0
}

func (p *PlayerProxy) Message(L *lua.LState) int {
	// type := L.CheckInt(2)
	msg := L.CheckString(3)
	p.Capture.Responses = append(p.Capture.Responses, msg)
	return 0
}

func (p *PlayerProxy) CastToClient(L *lua.LState) int {
	L.Push(L.CheckUserData(1)) // Just return self
	return 1
}

func (p *PlayerProxy) AssignTask(L *lua.LState) int {
	taskID := L.CheckInt(2)
	p.Capture.Tasks = append(p.Capture.Tasks, TaskAction{TaskID: taskID, Action: "assign"})
	return 0
}

func (p *PlayerProxy) IsTaskActive(L *lua.LState) int {
	taskID := L.CheckInt(2)
	L.Push(lua.LBool(p.Tasks[taskID]))
	return 1
}

func (p *PlayerProxy) TaskSelector(L *lua.LState) int {
	// Not implemented yet, but common in scripts
	return 0
}

func (p *PlayerProxy) GetID(L *lua.LState) int {
	L.Push(lua.LNumber(p.ID))
	return 1
}

func (p *PlayerProxy) HasItem(L *lua.LState) int {
	itemID := L.CheckInt(2)
	L.Push(lua.LBool(p.Inventory[itemID]))
	return 1
}

func (p *PlayerProxy) KeyRingCheck(L *lua.LState) int {
	// Mock
	L.Push(lua.LBool(false))
	return 1
}

func (p *PlayerProxy) MovePC(L *lua.LState) int {
	move := QuestPlayerMoveRequest{ZoneID: L.CheckInt(2)}
	if L.GetTop() >= 3 {
		move.X = float64(lua.LVAsNumber(L.Get(3)))
	}
	if L.GetTop() >= 4 {
		move.Y = float64(lua.LVAsNumber(L.Get(4)))
	}
	if L.GetTop() >= 5 {
		move.Z = float64(lua.LVAsNumber(L.Get(5)))
	}
	if L.GetTop() >= 6 {
		move.Heading = float64(lua.LVAsNumber(L.Get(6)))
	}
	p.Capture.PlayerMoves = append(p.Capture.PlayerMoves, move)
	return 0
}

func (p *PlayerProxy) ClearCompassMark(L *lua.LState) int {
	return 0
}

func (p *PlayerProxy) GetBindZoneID(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) IsInAGuild(L *lua.LState) int {
	L.Push(lua.LBool(true))
	return 1
}

func (p *PlayerProxy) SendToGuildHall(L *lua.LState) int {
	return 0
}

func (p *PlayerProxy) RemoveItem(L *lua.LState) int {
	return 0
}

func (p *PlayerProxy) NukeItem(L *lua.LState) int {
	return p.RemoveItem(L)
}

func (p *PlayerProxy) Popup(L *lua.LState) int {
	title := L.CheckString(2)
	text := L.CheckString(3)
	id := 0
	if L.GetTop() >= 4 {
		id = L.CheckInt(4)
	}
	p.Capture.Popups = append(p.Capture.Popups, PopupInfo{Title: title, Text: text, ID: id})
	return 0
}

func (p *PlayerProxy) BuffFadeAll(L *lua.LState) int {
	return 0
}

func (p *PlayerProxy) GetStartZone(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) SetPVP(L *lua.LState) int {
	// Mock: SetPVP(bool)
	return 0
}

func (p *PlayerProxy) QuestReward(L *lua.LState) int {
	// QuestReward(npc, {itemid=N, exp=N, copper=N, silver=N, gold=N, platinum=N})
	// or QuestReward(npc, copper, silver, gold, platinum, itemid, exp)
	// arg1=self(player), arg2=npc, arg3+=reward spec
	if L.GetTop() >= 3 {
		arg3 := L.Get(3)
		if tbl, ok := arg3.(*lua.LTable); ok {
			// Table form: {itemid=N, exp=N, copper=N, ...}
			if itemid := tbl.RawGetString("itemid"); itemid != lua.LNil {
				if num, ok := itemid.(lua.LNumber); ok {
					p.Capture.Items = append(p.Capture.Items, QuestReward{ItemID: int(num), Count: 1})
				}
			}
			if exp := tbl.RawGetString("exp"); exp != lua.LNil {
				if num, ok := exp.(lua.LNumber); ok {
					p.Capture.Exp += int(num)
				}
			}
			if cp := tbl.RawGetString("copper"); cp != lua.LNil {
				if num, ok := cp.(lua.LNumber); ok {
					p.Capture.Currency.Copper += int(num)
				}
			}
			if sv := tbl.RawGetString("silver"); sv != lua.LNil {
				if num, ok := sv.(lua.LNumber); ok {
					p.Capture.Currency.Silver += int(num)
				}
			}
			if gd := tbl.RawGetString("gold"); gd != lua.LNil {
				if num, ok := gd.(lua.LNumber); ok {
					p.Capture.Currency.Gold += int(num)
				}
			}
			if pt := tbl.RawGetString("platinum"); pt != lua.LNil {
				if num, ok := pt.(lua.LNumber); ok {
					p.Capture.Currency.Platinum += int(num)
				}
			}
		} else {
			// Positional form: QuestReward(npc, copper, silver, gold, platinum, itemid, exp)
			if L.GetTop() >= 3 {
				p.Capture.Currency.Copper += int(lua.LVAsNumber(L.Get(3)))
			}
			if L.GetTop() >= 4 {
				p.Capture.Currency.Silver += int(lua.LVAsNumber(L.Get(4)))
			}
			if L.GetTop() >= 5 {
				p.Capture.Currency.Gold += int(lua.LVAsNumber(L.Get(5)))
			}
			if L.GetTop() >= 6 {
				p.Capture.Currency.Platinum += int(lua.LVAsNumber(L.Get(6)))
			}
			if L.GetTop() >= 7 {
				itemID := int(lua.LVAsNumber(L.Get(7)))
				if itemID > 0 {
					p.Capture.Items = append(p.Capture.Items, QuestReward{ItemID: itemID, Count: 1})
				}
			}
			if L.GetTop() >= 8 {
				p.Capture.Exp += int(lua.LVAsNumber(L.Get(8)))
			}
		}
	}
	return 0
}

func (p *PlayerProxy) HasSpellScribed(L *lua.LState) int {
	// Mock: always false
	L.Push(lua.LBool(false))
	return 1
}

func (p *PlayerProxy) GetRaceName(L *lua.LState) int {
	L.Push(lua.LString(p.CharRace))
	return 1
}

func (p *PlayerProxy) GetGM(L *lua.LState) int {
	// God mode: return true so GM-gated branches are accessible
	L.Push(lua.LBool(true))
	return 1
}

func (p *PlayerProxy) UpdateTaskActivity(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) IsTaskActivityActive(L *lua.LState) int {
	taskID := L.CheckInt(2)
	activityID := L.CheckInt(3)
	L.Push(lua.LBool(p.Activities[taskActivityKey(taskID, activityID)]))
	return 1
}

func (p *PlayerProxy) IsTaskCompleted(L *lua.LState) int {
	// Mock: always false
	L.Push(lua.LBool(false))
	return 1
}

func (p *PlayerProxy) IsPet(L *lua.LState) int {
	L.Push(lua.LBool(false))
	return 1
}

func (p *PlayerProxy) IsClient(L *lua.LState) int {
	L.Push(lua.LBool(true))
	return 1
}

func (p *PlayerProxy) GetGlobal(L *lua.LState) int {
	value, ok := p.Globals[L.CheckString(2)]
	if !ok {
		value = "Undefined"
	}
	L.Push(lua.LString(value))
	return 1
}

func (p *PlayerProxy) SetGlobal(L *lua.LState) int {
	// Delegate to capture globals
	name := L.CheckString(2)
	val := L.CheckString(3)
	options := 0
	duration := "F"
	if L.GetTop() >= 4 {
		options = L.CheckInt(4)
	}
	if L.GetTop() >= 5 {
		duration = L.CheckString(5)
	}
	p.Capture.Globals[name] = GlobalUpdate{
		Name:     name,
		Value:    val,
		Options:  options,
		Duration: duration,
	}
	return 0
}

func (p *PlayerProxy) GetX(L *lua.LState) int {
	L.Push(lua.LNumber(p.X))
	return 1
}

func (p *PlayerProxy) GetY(L *lua.LState) int {
	L.Push(lua.LNumber(p.Y))
	return 1
}

func (p *PlayerProxy) GetZ(L *lua.LState) int {
	L.Push(lua.LNumber(p.Z))
	return 1
}

func (p *PlayerProxy) GetHeading(L *lua.LState) int {
	L.Push(lua.LNumber(p.Heading))
	return 1
}

func (p *PlayerProxy) GetBaseRace(L *lua.LState) int {
	L.Push(lua.LNumber(p.RaceID))
	return 1
}

func (p *PlayerProxy) GetClassName(L *lua.LState) int {
	L.Push(lua.LString(p.CharClass))
	return 1
}

func (p *PlayerProxy) GetDeity(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) GetGender(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) HasDisciplineLearned(L *lua.LState) int {
	L.Push(lua.LBool(false))
	return 1
}

func (p *PlayerProxy) AddAAPoints(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) Admin(L *lua.LState) int {
	// Return high admin level for god mode
	L.Push(lua.LNumber(250))
	return 1
}

func (p *PlayerProxy) AddItem(L *lua.LState) int {
	id := L.CheckInt(2)
	qty := 1
	if L.GetTop() >= 3 {
		qty = L.CheckInt(3)
	}
	p.Capture.Items = append(p.Capture.Items, QuestReward{ItemID: id, Count: qty})
	return 0
}

func (p *PlayerProxy) SendSound(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) Say(L *lua.LState) int {
	msg := L.CheckString(2)
	p.Capture.Responses = append(p.Capture.Responses, msg)
	return 0
}

func (p *PlayerProxy) Emote(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) Signal(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) MovePCDynamicZone(L *lua.LState) int {
	move := QuestPlayerMoveRequest{ZoneID: L.CheckInt(2), Dynamic: true}
	if L.GetTop() >= 3 {
		move.X = float64(lua.LVAsNumber(L.Get(3)))
	}
	if L.GetTop() >= 4 {
		move.Y = float64(lua.LVAsNumber(L.Get(4)))
	}
	if L.GetTop() >= 5 {
		move.Z = float64(lua.LVAsNumber(L.Get(5)))
	}
	if L.GetTop() >= 6 {
		move.Heading = float64(lua.LVAsNumber(L.Get(6)))
	}
	p.Capture.PlayerMoves = append(p.Capture.PlayerMoves, move)
	return 0
}

func (p *PlayerProxy) MovePCInstance(L *lua.LState) int {
	move := QuestPlayerMoveRequest{ZoneID: L.CheckInt(2)}
	if L.GetTop() >= 3 {
		move.InstanceID = L.CheckInt(3)
	}
	if L.GetTop() >= 4 {
		move.X = float64(lua.LVAsNumber(L.Get(4)))
	}
	if L.GetTop() >= 5 {
		move.Y = float64(lua.LVAsNumber(L.Get(5)))
	}
	if L.GetTop() >= 6 {
		move.Z = float64(lua.LVAsNumber(L.Get(6)))
	}
	if L.GetTop() >= 7 {
		move.Heading = float64(lua.LVAsNumber(L.Get(7)))
	}
	p.Capture.PlayerMoves = append(p.Capture.PlayerMoves, move)
	return 0
}

func (p *PlayerProxy) HasZoneFlag(L *lua.LState) int {
	L.Push(lua.LBool(true))
	return 1
}

func (p *PlayerProxy) GuildID(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) GetSkill(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) GetRawSkill(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) MaxSkill(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) CanHaveSkill(L *lua.LState) int {
	L.Push(lua.LBool(true))
	return 1
}

func (p *PlayerProxy) GetBucket(L *lua.LState) int {
	L.Push(lua.LString(""))
	return 1
}

func (p *PlayerProxy) SetBucket(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) GetExpedition(L *lua.LState) int {
	expedition := L.NewTable()
	L.SetField(expedition, "valid", lua.LBool(false))
	L.SetField(expedition, "GetZoneID", L.NewFunction(func(L *lua.LState) int { L.Push(lua.LNumber(0)); return 1 }))
	L.SetField(expedition, "HasLockout", L.NewFunction(func(L *lua.LState) int { L.Push(lua.LBool(false)); return 1 }))
	L.Push(expedition)
	return 1
}

func (p *PlayerProxy) FindBuff(L *lua.LState) int {
	L.Push(lua.LBool(false))
	return 1
}

func (p *PlayerProxy) SpellFinished(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) SelfCast(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) BuffFadeBySpellID(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) AddMoneyToPP(L *lua.LState) int {
	// AddMoneyToPP(copper, silver, gold, platinum, update_client)
	if L.GetTop() >= 2 {
		p.Capture.Currency.Copper += int(lua.LVAsNumber(L.Get(2)))
	}
	if L.GetTop() >= 3 {
		p.Capture.Currency.Silver += int(lua.LVAsNumber(L.Get(3)))
	}
	if L.GetTop() >= 4 {
		p.Capture.Currency.Gold += int(lua.LVAsNumber(L.Get(4)))
	}
	if L.GetTop() >= 5 {
		p.Capture.Currency.Platinum += int(lua.LVAsNumber(L.Get(5)))
	}
	return 0
}

func (p *PlayerProxy) GetLanguageSkill(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) SetSkill(L *lua.LState) int {
	skillID := L.CheckInt(2)
	value := L.CheckInt(3)
	if p.Capture != nil {
		p.Capture.SkillUpdates = append(p.Capture.SkillUpdates, QuestSkillUpdate{
			SkillID: skillID,
			Value:   value,
		})
	}
	return 0
}

func (p *PlayerProxy) SetAATitle(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) SendColoredText(L *lua.LState) int {
	// Mock
	return 0
}

func (p *PlayerProxy) GetCorpseCount(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) GetGroup(L *lua.LState) int {
	L.Push(lua.LNil)
	return 1
}

func (p *PlayerProxy) GetGroupMemberCount(L *lua.LState) int {
	L.Push(lua.LNumber(1))
	return 1
}

func (p *PlayerProxy) GetRaidMemberCountInZone(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) DoesAnyPartyMemberHaveLockout(L *lua.LState) int {
	L.Push(lua.LBool(false))
	return 1
}

func (p *PlayerProxy) GetOwner(L *lua.LState) int {
	L.Push(lua.LNil)
	return 1
}

func (p *PlayerProxy) GetMobByNpcTypeID(L *lua.LState) int {
	L.Push(lua.LNil)
	return 1
}

func (p *PlayerProxy) GetNPCTypeID(L *lua.LState) int {
	L.Push(lua.LNumber(0))
	return 1
}

func (p *PlayerProxy) AddLevelBasedExp(L *lua.LState) int {
	percent := float64(L.CheckNumber(2))
	spread := 0.0
	if L.GetTop() >= 3 {
		spread = float64(L.CheckNumber(3))
	}
	if percent < 0 {
		percent = 0
	}
	if spread < 0 {
		spread = 0
	}
	low, high := percent-spread, percent+spread
	chosen := low
	if high > low {
		chosen += rand.Float64() * (high - low)
	}
	required := mechanics.ExperienceRequiredForLevel(p.CharLevel, int(p.RaceID), int(p.ClassID))
	p.Capture.Exp += int(math.Round(float64(required) * chosen / 100))
	return 0
}

func (p *PlayerProxy) AddNimbusEffect(L *lua.LState) int {
	return 0
}

func (p *PlayerProxy) RemoveNimbusEffect(L *lua.LState) int {
	return 0
}

func (p *PlayerProxy) DisableAreaRegens(L *lua.LState) int {
	return 0
}

func (p *PlayerProxy) EnableAreaRegens(L *lua.LState) int {
	return 0
}

func (p *PlayerProxy) PushItemOnCursor(L *lua.LState) int {
	// Mock: used by item_lib.return_bot_items
	return 0
}

// TradeProxy (Phase 2)
type TradeProxy struct {
	Items    []int
	Platinum int
	Gold     int
	Silver   int
	Copper   int
}

// ItemInstProxy wraps an item instance for Lua
type ItemInstProxy struct {
	ID    int
	Valid bool
}

type CorpseProxy struct {
	NPCTypeID int32
	NPC       bool
}

type DoorProxy struct {
	ID     int32
	DoorID int32
}

func (d *DoorProxy) GetDoorID(L *lua.LState) int {
	if d == nil {
		L.Push(lua.LNumber(0))
		return 1
	}
	if d.DoorID != 0 {
		L.Push(lua.LNumber(d.DoorID))
		return 1
	}
	L.Push(lua.LNumber(d.ID))
	return 1
}

func (d *DoorProxy) GetID(L *lua.LState) int {
	if d == nil {
		L.Push(lua.LNumber(0))
		return 1
	}
	L.Push(lua.LNumber(d.ID))
	return 1
}

func (d *DoorProxy) SetLockPick(L *lua.LState) int {
	return 0
}

func (d *DoorProxy) ForceOpen(L *lua.LState) int {
	return 0
}

func (c *CorpseProxy) IsNPCCorpse(L *lua.LState) int {
	L.Push(lua.LBool(c == nil || c.NPC))
	return 1
}

func (c *CorpseProxy) GetNPCTypeID(L *lua.LState) int {
	if c == nil {
		L.Push(lua.LNumber(0))
		return 1
	}
	L.Push(lua.LNumber(c.NPCTypeID))
	return 1
}

func (c *CorpseProxy) AddItem(L *lua.LState) int {
	return 0
}

func (c *CorpseProxy) ResetDecayTimer(L *lua.LState) int {
	return 0
}

func (i *ItemInstProxy) GetID(L *lua.LState) int {
	L.Push(lua.LNumber(i.ID))
	return 1
}

func (i *ItemInstProxy) IsValid(L *lua.LState) int {
	L.Push(lua.LBool(i.Valid))
	return 1
}

// Bridge manages script execution
type LuaBridge struct {
	DataPath         string
	ExecutionTimeout time.Duration
	ModuleLoader     func(name string) (string, bool, error)
	// Behavior tests opt in to fail at the first reached compatibility stub.
	// Production keeps historical behavior until each world effect is wired.
	RequireImplementedEffects bool
}

func NewLuaBridge(dataPath string) *LuaBridge {
	return &LuaBridge{DataPath: dataPath, ExecutionTimeout: 2 * time.Second}
}

func (b *LuaBridge) ResolveScriptPath(zone, npcName string, npcID int32) string {
	// Try name variations
	variations := []string{
		strings.ReplaceAll(npcName, " ", "_"),
		npcName,
		fmt.Sprintf("%d", npcID),
	}

	zoneDir := filepath.Join(b.DataPath, zone)
	for _, v := range variations {
		path := filepath.Join(zoneDir, v+".lua")
		if _, err := os.Stat(path); err == nil {
			return path
		}
	}

	// Try default.lua
	defaultPath := filepath.Join(zoneDir, "default.lua")
	if _, err := os.Stat(defaultPath); err == nil {
		return defaultPath
	}

	return ""
}

func (b *LuaBridge) ExecuteSay(scriptPath string, event *LuaEvent) (*QuestCapture, error) {
	L, eTable, cap, err := b.prepareState(scriptPath, event)
	if err != nil {
		return nil, err
	}
	defer L.Close()

	fn := L.GetGlobal("event_say")
	if fn.Type() != lua.LTFunction {
		return cap.checkedResult()
	}

	if err := L.CallByParam(lua.P{
		Fn:      fn,
		NRet:    0,
		Protect: true,
	}, eTable); err != nil {
		return nil, err
	}

	return cap.checkedResult()
}

// ExecuteSayFromSource executes event_say from a LUA source string (e.g. from DB).
func (b *LuaBridge) ExecuteSayFromSource(source string, event *LuaEvent) (*QuestCapture, error) {
	return b.ExecuteEventFromSource(source, "event_say", event)
}

func (b *LuaBridge) ExecuteTrade(scriptPath string, event *LuaEvent) (*QuestCapture, error) {
	L, eTable, cap, err := b.prepareState(scriptPath, event)
	if err != nil {
		return nil, err
	}
	defer L.Close()

	b.setupTradeTable(L, eTable, event)

	fn := L.GetGlobal("event_trade")
	if fn.Type() != lua.LTFunction {
		return cap.checkedResult()
	}

	if err := L.CallByParam(lua.P{
		Fn:      fn,
		NRet:    0,
		Protect: true,
	}, eTable); err != nil {
		return nil, err
	}

	return cap.checkedResult()
}

// ExecuteTradeFromSource executes event_trade from a LUA source string (e.g. from DB).
func (b *LuaBridge) ExecuteTradeFromSource(source string, event *LuaEvent) (*QuestCapture, error) {
	return b.ExecuteEventFromSource(source, "event_trade", event)
}

// ExecuteEventFromSource executes one named EQEmu-style event handler from a
// fresh Lua state. Persistent quest state is supplied through LuaEvent and
// captured as explicit effects rather than retained inside the Lua VM.
func (b *LuaBridge) ExecuteEventFromSource(source, handler string, event *LuaEvent) (*QuestCapture, error) {
	L, eTable, cap, err := b.prepareStateFromSource(source, event)
	if err != nil {
		return nil, err
	}
	defer L.Close()

	if event != nil && event.Trade != nil {
		b.setupTradeTable(L, eTable, event)
	}

	fn := L.GetGlobal(handler)
	if fn.Type() != lua.LTFunction {
		return cap.checkedResult()
	}
	if err := applyLuaScriptState(L, fn.(*lua.LFunction), event.ScriptState); err != nil {
		return nil, err
	}
	// Remember initialized globals too, including ones cleared by this first event.
	captureLuaScriptState(L, fn.(*lua.LFunction), cap)

	if err := L.CallByParam(lua.P{
		Fn:      fn,
		NRet:    0,
		Protect: true,
	}, eTable); err != nil {
		return nil, err
	}
	captureLuaScriptState(L, fn.(*lua.LFunction), cap)

	return cap.checkedResult()
}

func (b *LuaBridge) ExecuteRegisteredNPCEventFromSource(source string, eventType RuntimeEventType, npcTypeID int32, event *LuaEvent) (*QuestCapture, error) {
	L, eTable, cap, err := b.prepareStateFromSource(source, event)
	if err != nil {
		return nil, err
	}
	defer L.Close()

	if event != nil && event.Trade != nil {
		b.setupTradeTable(L, eTable, event)
	}

	loadFn := L.GetGlobal("event_encounter_load")
	if loadFn.Type() != lua.LTFunction {
		return cap.checkedResult()
	}
	if err := L.CallByParam(lua.P{Fn: loadFn, NRet: 0, Protect: true}, eTable); err != nil {
		return nil, err
	}
	var handler *lua.LFunction
	for _, registration := range cap.Registrations {
		if registration.Scope != "npc" || registration.NPCTypeID != npcTypeID || registration.Event != string(eventType) {
			continue
		}
		if fn, ok := registration.Handler.(*lua.LFunction); ok {
			handler = fn
			break
		}
	}
	clearQuestCaptureEffects(cap)
	if handler == nil {
		return cap.checkedResult()
	}
	if err := applyLuaScriptState(L, handler, event.ScriptState); err != nil {
		return nil, err
	}
	cap.ScriptState = cloneScriptState(event.ScriptState)
	captureLuaScriptState(L, handler, cap)
	if err := L.CallByParam(lua.P{Fn: handler, NRet: 0, Protect: true}, eTable); err != nil {
		return nil, err
	}
	captureLuaScriptState(L, handler, cap)
	return cap.checkedResult()
}

func (b *LuaBridge) ExecuteRegisteredPlayerEventFromSource(source string, eventType RuntimeEventType, event *LuaEvent) (*QuestCapture, error) {
	L, eTable, cap, err := b.prepareStateFromSource(source, event)
	if err != nil {
		return nil, err
	}
	defer L.Close()

	if event != nil && event.Trade != nil {
		b.setupTradeTable(L, eTable, event)
	}

	loadFn := L.GetGlobal("event_encounter_load")
	if loadFn.Type() != lua.LTFunction {
		return cap.checkedResult()
	}
	if err := L.CallByParam(lua.P{Fn: loadFn, NRet: 0, Protect: true}, eTable); err != nil {
		return nil, err
	}
	var handler *lua.LFunction
	for _, registration := range cap.Registrations {
		if registration.Scope != "player" || registration.Event != string(eventType) {
			continue
		}
		if fn, ok := registration.Handler.(*lua.LFunction); ok {
			handler = fn
			break
		}
	}
	clearQuestCaptureEffects(cap)
	if handler == nil {
		return cap.checkedResult()
	}
	if err := applyLuaScriptState(L, handler, event.ScriptState); err != nil {
		return nil, err
	}
	cap.ScriptState = cloneScriptState(event.ScriptState)
	captureLuaScriptState(L, handler, cap)
	if err := L.CallByParam(lua.P{Fn: handler, NRet: 0, Protect: true}, eTable); err != nil {
		return nil, err
	}
	captureLuaScriptState(L, handler, cap)
	return cap.checkedResult()
}

func clearQuestCaptureEffects(capture *QuestCapture) {
	if capture == nil {
		return
	}
	// Registration re-executes encounter_load to recover Lua callbacks, not
	// to replay its world effects. Reset by retaining only execution context
	// so newly added effect fields cannot silently leak into the callback.
	// Keep diagnostics/errors: resetting effects must not conceal a failed or
	// unsupported load operation. Userdata still points at this same capture.
	*capture = QuestCapture{
		CurrentTrade:              capture.CurrentTrade,
		spellActors:               capture.spellActors,
		requireImplementedEffects: capture.requireImplementedEffects,
		actorEffectError:          capture.actorEffectError,
		DeferredAPIs:              capture.DeferredAPIs,
		Globals:                   make(map[string]GlobalUpdate),
		ScriptState:               make(map[string]any),
	}
}

func applyLuaScriptState(L *lua.LState, fn *lua.LFunction, state map[string]any) error {
	if fn == nil || state == nil {
		return nil
	}
	for key, upvalue := range scriptStateUpvalues(L, fn) {
		if value, ok := state[key]; ok {
			upvalue.SetValue(luaEventValue(L, value))
		}
	}
	for key, value := range state {
		if strings.HasPrefix(key, "global:") {
			L.SetGlobal(strings.TrimPrefix(key, "global:"), luaEventValue(L, value))
		}
	}
	return restoreLuaTableAliases(L, fn, state)
}

func captureLuaScriptState(L *lua.LState, fn *lua.LFunction, capture *QuestCapture) {
	if fn == nil || capture == nil {
		return
	}
	for key, upvalue := range scriptStateUpvalues(L, fn) {
		if value, ok := serializableLuaPrimitive(upvalue.Value()); ok {
			capture.ScriptState[key] = value
		}
	}
	// Lua removes nil globals from its table. Retain an explicit JSON null for
	// previously saved globals so fresh source initialization cannot revive a
	// cleared quest flag. Unrelated NPC inventory/state keys stay untouched.
	for key := range capture.ScriptState {
		if strings.HasPrefix(key, "global:") && L.GetGlobal(strings.TrimPrefix(key, "global:")) == lua.LNil {
			capture.ScriptState[key] = nil
		}
	}
	L.G.Global.ForEach(func(key, value lua.LValue) {
		name, ok := key.(lua.LString)
		if !ok || name == "_VERSION" {
			return
		}
		if primitive, ok := serializableLuaPrimitive(value); ok {
			capture.ScriptState["global:"+string(name)] = primitive
		}
	})
	captureLuaTableAliases(L, fn, capture)
}

func serializableLuaPrimitive(value lua.LValue) (any, bool) {
	return serializableLuaValue(value, 0, map[*lua.LTable]bool{})
}

func serializableLuaValue(value lua.LValue, depth int, seen map[*lua.LTable]bool) (any, bool) {
	switch typed := value.(type) {
	case *lua.LNilType:
		return nil, true
	case lua.LNumber:
		return float64(typed), true
	case lua.LString:
		return string(typed), true
	case lua.LBool:
		return bool(typed), true
	case *lua.LTable:
		if depth >= 6 || seen[typed] {
			return nil, false
		}
		seen[typed] = true
		defer delete(seen, typed)
		result := map[string]any{}
		valid := true
		typed.ForEach(func(key, entry lua.LValue) {
			if !valid {
				return
			}
			serialized, ok := serializableLuaValue(entry, depth+1, seen)
			if !ok {
				valid = false
				return
			}
			encodedKey, ok := encodeScriptStateKey(key)
			if !ok {
				valid = false
				return
			}
			result[encodedKey] = serialized
		})
		return result, valid
	default:
		return nil, false
	}
}

func (b *LuaBridge) setupTradeTable(L *lua.LState, eTable *lua.LTable, event *LuaEvent) {
	npcUD := L.GetField(eTable, "self")
	otherUD := L.GetField(eTable, "other")
	tradeTable := L.NewTable()
	itemMT := b.createItemMetatable(L)
	if event.Trade != nil {
		for i := 0; i < 4; i++ {
			key := fmt.Sprintf("item%d", i+1)
			itemUD := L.NewUserData()
			if i < len(event.Trade.Items) {
				itemUD.Value = &ItemInstProxy{ID: event.Trade.Items[i], Valid: true}
			} else {
				itemUD.Value = &ItemInstProxy{ID: 0, Valid: false}
			}
			L.SetMetatable(itemUD, itemMT)
			L.SetField(tradeTable, key, itemUD)
		}
		L.SetField(tradeTable, "platinum", lua.LNumber(event.Trade.Platinum))
		L.SetField(tradeTable, "gold", lua.LNumber(event.Trade.Gold))
		L.SetField(tradeTable, "silver", lua.LNumber(event.Trade.Silver))
		L.SetField(tradeTable, "copper", lua.LNumber(event.Trade.Copper))
		L.SetField(tradeTable, "self", npcUD)
		L.SetField(tradeTable, "other", otherUD)
	}
	L.SetField(eTable, "trade", tradeTable)
}

func (b *LuaBridge) createItemMetatable(L *lua.LState) *lua.LTable {
	mt := L.NewTable()
	L.SetField(mt, "__index", L.NewFunction(func(L *lua.LState) int {
		item := L.CheckUserData(1).Value.(*ItemInstProxy)
		key := L.CheckString(2)
		switch key {
		case "GetID":
			L.Push(L.NewFunction(item.GetID))
			return 1
		case "IsValid":
			L.Push(L.NewFunction(item.IsValid))
			return 1
		case "valid":
			L.Push(lua.LBool(item.Valid))
			return 1
		}
		return 0
	}))
	return mt
}

func (b *LuaBridge) createCorpseMetatable(L *lua.LState) *lua.LTable {
	mt := L.NewTable()
	L.SetField(mt, "__index", L.NewFunction(func(L *lua.LState) int {
		corpse := L.CheckUserData(1).Value.(*CorpseProxy)
		key := L.CheckString(2)
		switch key {
		case "IsNPCCorpse":
			L.Push(L.NewFunction(corpse.IsNPCCorpse))
			return 1
		case "GetNPCTypeID":
			L.Push(L.NewFunction(corpse.GetNPCTypeID))
			return 1
		case "AddItem":
			L.Push(L.NewFunction(corpse.AddItem))
			return 1
		case "ResetDecayTimer":
			L.Push(L.NewFunction(corpse.ResetDecayTimer))
			return 1
		}
		return 0
	}))
	return mt
}

func (b *LuaBridge) createDoorMetatable(L *lua.LState) *lua.LTable {
	mt := L.NewTable()
	L.SetField(mt, "__index", L.NewFunction(func(L *lua.LState) int {
		door := L.CheckUserData(1).Value.(*DoorProxy)
		key := L.CheckString(2)
		switch key {
		case "GetDoorID":
			L.Push(L.NewFunction(door.GetDoorID))
			return 1
		case "GetID":
			L.Push(L.NewFunction(door.GetID))
			return 1
		case "SetLockPick":
			L.Push(L.NewFunction(door.SetLockPick))
			return 1
		case "ForceOpen":
			L.Push(L.NewFunction(door.ForceOpen))
			return 1
		}
		return 0
	}))
	return mt
}

func (b *LuaBridge) prepareState(scriptPath string, event *LuaEvent) (*lua.LState, *lua.LTable, *QuestCapture, error) {
	data, err := os.ReadFile(scriptPath)
	if err != nil {
		return nil, nil, nil, fmt.Errorf("failed to read script file: %w", err)
	}
	return b.prepareStateFromSource(string(data), event)
}

func (b *LuaBridge) prepareStateFromSource(source string, event *LuaEvent) (*lua.LState, *lua.LTable, *QuestCapture, error) {
	return b.prepareStateWithLoader(event, func(L *lua.LState) error {
		return L.DoString(normalizeLegacyTurnInCurrencySyntax(source))
	})
}

func (b *LuaBridge) prepareStateWithLoader(event *LuaEvent, load func(*lua.LState) error) (*lua.LState, *lua.LTable, *QuestCapture, error) {
	if err := applyQuestEventVitals(event); err != nil {
		return nil, nil, nil, err
	}
	L := lua.NewState()
	if b.ExecutionTimeout > 0 {
		ctx, _ := context.WithTimeout(context.Background(), b.ExecutionTimeout)
		L.SetContext(ctx)
	}
	registerLuaMathRandom(L, event)
	capture := NewQuestCapture()
	capture.requireImplementedEffects = b.RequireImplementedEffects
	capture.CurrentTrade = event.Trade
	capture.ScriptState = cloneScriptState(event.ScriptState)

	b.registerStringExtensions(L)
	b.registerEqGlobal(L, capture, event)
	b.registerEqConstants(L)
	b.registerQuestCompatibilityGlobals(L, capture, event)
	b.registerMT(L)

	b.registerModuleLoader(L)
	if b.DataPath != "" {
		modulesPath := filepath.Join(b.DataPath, "lua_modules", "?.lua")
		L.DoString(fmt.Sprintf("package.path = package.path .. ';%s'", modulesPath))
	}

	if err := load(L); err != nil {
		L.Close()
		return nil, nil, nil, fmt.Errorf("failed to load script: %w", err)
	}

	eTable := L.NewTable()

	if event.NPC == nil {
		event.NPC = &NPCProxy{}
	}
	if event.Player == nil {
		event.Player = &PlayerProxy{Tasks: map[int]bool{}}
	}
	if event.Globals == nil {
		event.Globals = map[string]string{}
	}
	if event.Fields == nil {
		event.Fields = map[string]any{}
	}
	if event.Message == "" {
		if message, ok := event.Fields["message"].(string); ok {
			event.Message = message
		}
	}

	// Event-only read capabilities must not leak into a population-owned proxy.
	npcView := *event.NPC
	event.NPC = &npcView
	event.NPC.Capture = capture
	event.NPC.readCombatActor = event.ReadNPCCombat
	event.NPC.combatOwnerCharacterID = int64(event.Player.ID)
	event.NPC.combatOwner = event.Player
	// An NPC method addresses this concrete actor; eq.signal/type selectors
	// intentionally retain their separate type-wide semantics.
	event.NPC.SpawnInstanceID = event.SpawnInstanceID
	capture.registerSpellActor(event.NPC.SpawnInstanceID, event.NPC.spellActor())
	capture.registerSpellActor(int64(event.Player.ID), QuestSpellActor{CharacterID: uint32(event.Player.ID)})
	npcUD := L.NewUserData()
	npcUD.Value = event.NPC
	L.SetMetatable(npcUD, b.createNPCMetatable(L))

	event.Player.Capture = capture
	event.Player.Globals = event.Globals
	playerUD := L.NewUserData()
	playerUD.Value = event.Player
	L.SetMetatable(playerUD, b.createPlayerMetatable(L))
	if event.SelfIsPlayer {
		L.SetField(eTable, "self", playerUD)
		L.SetField(eTable, "other", playerUD)
	} else {
		L.SetField(eTable, "self", npcUD)
		L.SetField(eTable, "other", playerUD)
	}
	L.SetField(eTable, "killer", playerUD)
	L.SetField(eTable, "owner", playerUD)
	L.SetField(eTable, "target", playerUD)

	L.SetField(eTable, "message", lua.LString(event.Message))
	if event.Item == nil {
		if itemID, ok := integerEventField(event.Fields["item_id"]); ok {
			event.Item = &ItemInstProxy{ID: itemID, Valid: itemID > 0}
		}
	}
	if event.Item != nil {
		itemUD := L.NewUserData()
		itemUD.Value = event.Item
		L.SetMetatable(itemUD, b.createItemMetatable(L))
		L.SetField(eTable, "item", itemUD)
	}
	if event.Corpse == nil {
		if npcTypeID, ok := integerEventField(event.Fields["corpse_npc_type_id"]); ok {
			event.Corpse = &CorpseProxy{NPCTypeID: int32(npcTypeID), NPC: true}
		}
	}
	if event.Corpse != nil {
		corpseUD := L.NewUserData()
		corpseUD.Value = event.Corpse
		L.SetMetatable(corpseUD, b.createCorpseMetatable(L))
		L.SetField(eTable, "corpse", corpseUD)
	}
	if event.Door == nil {
		doorID, hasDoorID := integerEventField(event.Fields["door_id"])
		dbID, _ := integerEventField(event.Fields["door_db_id"])
		if hasDoorID || dbID > 0 {
			event.Door = &DoorProxy{ID: int32(dbID), DoorID: int32(doorID)}
		}
	}
	if event.Door != nil {
		doorUD := L.NewUserData()
		doorUD.Value = event.Door
		L.SetMetatable(doorUD, b.createDoorMetatable(L))
		L.SetField(eTable, "door", doorUD)
	}
	for name, value := range event.Fields {
		if name == "self" || name == "other" || name == "killer" || name == "owner" || name == "target" || name == "message" || name == "trade" || name == "qglobals" || name == "item" || name == "corpse" || name == "door" {
			continue
		}
		L.SetField(eTable, name, luaEventValue(L, value))
	}

	// Globals
	globalsTable := L.NewTable()
	for k, v := range event.Globals {
		L.SetField(globalsTable, k, lua.LString(v))
	}
	L.SetField(eTable, "qglobals", globalsTable)
	L.SetGlobal("qglobals", globalsTable)

	return L, eTable, capture, nil
}

func registerLuaMathRandom(L *lua.LState, event *LuaEvent) {
	mathValue := L.GetGlobal("math")
	mathTable, ok := mathValue.(*lua.LTable)
	if !ok {
		return
	}

	seed := time.Now().UnixNano() ^ rand.Int63()
	if event != nil {
		seed ^= event.SpawnInstanceID
		if event.NPC != nil {
			seed ^= int64(event.NPC.ID) << 16
		}
		if event.Player != nil {
			seed ^= int64(event.Player.ID) << 32
		}
	}
	rng := rand.New(rand.NewSource(seed))

	L.SetField(mathTable, "randomseed", L.NewFunction(func(L *lua.LState) int {
		rng.Seed(L.OptInt64(1, time.Now().UnixNano()))
		return 0
	}))

	L.SetField(mathTable, "random", L.NewFunction(func(L *lua.LState) int {
		switch L.GetTop() {
		case 0:
			L.Push(lua.LNumber(rng.Float64()))
		case 1:
			upper := L.CheckInt(1)
			if upper < 1 {
				L.ArgError(1, "interval is empty")
				return 0
			}
			L.Push(lua.LNumber(rng.Intn(upper) + 1))
		default:
			lower := L.CheckInt(1)
			upper := L.CheckInt(2)
			if upper < lower {
				L.ArgError(2, "interval is empty")
				return 0
			}
			L.Push(lua.LNumber(lower + rng.Intn(upper-lower+1)))
		}
		return 1
	}))
}

func integerEventField(value any) (int, bool) {
	switch typed := value.(type) {
	case int:
		return typed, true
	case int32:
		return int(typed), true
	case int64:
		return int(typed), true
	case float64:
		integer := int(typed)
		return integer, typed == float64(integer)
	default:
		return 0, false
	}
}

func (b *LuaBridge) registerModuleLoader(L *lua.LState) {
	if b.ModuleLoader == nil {
		return
	}
	loaders, ok := L.GetField(L.Get(lua.RegistryIndex), "_LOADERS").(*lua.LTable)
	if !ok {
		return
	}
	dbLoader := L.NewFunction(func(L *lua.LState) int {
		name := L.CheckString(1)
		source, ok, err := b.ModuleLoader(name)
		if err != nil {
			L.Push(lua.LString(fmt.Sprintf("error loading quest module %s: %v", name, err)))
			return 1
		}
		if !ok {
			L.Push(lua.LString(fmt.Sprintf("no field quest_lua_modules['%s']", name)))
			return 1
		}
		fn, err := L.LoadString(source)
		if err != nil {
			L.RaiseError("failed to compile quest module %s: %v", name, err)
			return 0
		}
		L.Push(fn)
		return 1
	})
	length := loaders.Len()
	for i := length + 1; i >= 3; i-- {
		loaders.RawSetInt(i, loaders.RawGetInt(i-1))
	}
	loaders.RawSetInt(2, dbLoader)
}

// Shared with the standalone content validator; keep runtime compatibility in one place.
func normalizeLegacyTurnInCurrencySyntax(source string) string {
	return questluasource.Normalize(source)
}

func luaEventValue(L *lua.LState, value any) lua.LValue {
	switch typed := value.(type) {
	case nil:
		return lua.LNil
	case string:
		return lua.LString(typed)
	case bool:
		return lua.LBool(typed)
	case int:
		return lua.LNumber(typed)
	case int32:
		return lua.LNumber(typed)
	case int64:
		return lua.LNumber(typed)
	case uint32:
		return lua.LNumber(typed)
	case uint64:
		return lua.LNumber(typed)
	case float32:
		return lua.LNumber(typed)
	case float64:
		return lua.LNumber(typed)
	case map[string]any:
		table := L.NewTable()
		for key, entry := range typed {
			table.RawSet(decodeScriptStateKey(key), luaEventValue(L, entry))
		}
		return table
	case []any:
		table := L.NewTable()
		for index, entry := range typed {
			table.RawSetInt(index+1, luaEventValue(L, entry))
		}
		return table
	default:
		return lua.LString(fmt.Sprint(value))
	}
}

func luaEventHasVisibleNPCTypeID(event *LuaEvent, npcTypeID int32) bool {
	if event == nil || npcTypeID <= 0 {
		return false
	}
	for _, visibleID := range event.VisibleNPCTypeIDs {
		if visibleID == npcTypeID {
			return true
		}
	}
	if event.Fields == nil {
		return false
	}
	for _, key := range []string{"__visible_npc_type_ids", "visible_npc_type_ids"} {
		if hasNPCTypeIDInLuaEventField(event.Fields[key], npcTypeID) {
			return true
		}
	}
	return false
}

func hasNPCTypeIDInLuaEventField(value any, npcTypeID int32) bool {
	switch typed := value.(type) {
	case nil:
		return false
	case []int32:
		for _, id := range typed {
			if id == npcTypeID {
				return true
			}
		}
	case []int:
		for _, id := range typed {
			if int32(id) == npcTypeID {
				return true
			}
		}
	case []any:
		for _, entry := range typed {
			if hasNPCTypeIDInLuaEventField(entry, npcTypeID) {
				return true
			}
		}
	case map[int32]bool:
		return typed[npcTypeID]
	case map[int]bool:
		return typed[int(npcTypeID)]
	case map[string]any:
		return hasNPCTypeIDInLuaEventField(typed[strconv.Itoa(int(npcTypeID))], npcTypeID)
	case float64:
		return int32(typed) == npcTypeID && typed == float64(int32(typed))
	case int:
		return int32(typed) == npcTypeID
	case int32:
		return typed == npcTypeID
	}
	return false
}

func (b *LuaBridge) registerEqConstants(L *lua.LState) {
	eq := L.GetGlobal("eq").(*lua.LTable)
	// We'll place constants in sub-tables of eq as per EQEMU

	// Classes
	classTbl := L.NewTable()
	classes := map[string]int{
		"Warrior": 1, "Cleric": 2, "Paladin": 3, "Ranger": 4, "ShadowKnight": 5,
		"Druid": 6, "Monk": 7, "Bard": 8, "Rogue": 9, "Shaman": 10,
		"Necromancer": 11, "Wizard": 12, "Magician": 13, "Enchanter": 14,
		"Beastlord": 15, "Berserker": 16,
	}
	for name, id := range classes {
		L.SetField(classTbl, name, lua.LNumber(id))
	}
	L.SetField(eq, "Class", classTbl)
	legacyClassTbl := L.NewTable()
	for name, id := range classes {
		legacyName := strings.ToUpper(name)
		if name == "ShadowKnight" {
			legacyName = "SHADOWKNIGHT"
		}
		L.SetField(legacyClassTbl, legacyName, lua.LNumber(id))
	}
	L.SetGlobal("Class", legacyClassTbl)

	// Races
	raceTbl := L.NewTable()
	races := map[string]int{
		"Human": 1, "Barbarian": 2, "Erudite": 3, "WoodElf": 4, "HighElf": 5,
		"DarkElf": 6, "HalfElf": 7, "Dwarf": 8, "Troll": 9, "Ogre": 10,
		"Halfling": 11, "Gnome": 12, "Iksar": 13, "VahShir": 14, "Froglok": 15,
	}
	for name, id := range races {
		L.SetField(raceTbl, name, lua.LNumber(id))
	}
	L.SetField(eq, "Race", raceTbl)
	legacyRaceTbl := L.NewTable()
	for name, id := range races {
		L.SetField(legacyRaceTbl, strings.ToUpper(name), lua.LNumber(id))
	}
	L.SetGlobal("Race", legacyRaceTbl)
}

func (b *LuaBridge) createNPCMetatable(L *lua.LState) *lua.LTable {
	mt := L.NewTable()
	L.SetField(mt, "__index", L.NewFunction(func(L *lua.LState) int {
		npc := L.CheckUserData(1).Value.(*NPCProxy)
		key := L.CheckString(2)
		if key == "valid" || key == "null" {
			L.Push(lua.LBool((key == "valid") != npc.missingActor))
			return 1
		}
		if npc.externalActor && !supportsExternalNPCMethod(key) {
			return npc.Capture.rejectActorEffect(L, "cross-NPC method "+key)
		}
		switch key {
		case "Say":
			L.Push(L.NewFunction(npc.Say))
			return 1
		case "GetName":
			L.Push(L.NewFunction(npc.GetName))
			return 1
		case "GetCleanName":
			L.Push(L.NewFunction(npc.GetName))
			return 1
		case "IsPet":
			L.Push(L.NewFunction(npc.IsPet))
			return 1
		case "IsNPC", "IsMob":
			L.Push(L.NewFunction(func(L *lua.LState) int { L.Push(lua.LBool(!npc.missingActor)); return 1 }))
			return 1
		case "GetID":
			L.Push(L.NewFunction(npc.GetID))
			return 1
		case "Signal":
			L.Push(L.NewFunction(npc.Signal))
			return 1
		case "Depop":
			L.Push(L.NewFunction(npc.Depop))
			return 1
		case "CastSpell":
			L.Push(L.NewFunction(npc.CastSpell))
			return 1
		case "CheckHandin":
			L.Push(L.NewFunction(npc.CheckHandin))
			return 1
		case "ReturnHandinItems":
			L.Push(L.NewFunction(npc.ReturnHandinItems))
			return 1
		case "Emote":
			L.Push(L.NewFunction(npc.Emote))
			return 1
		case "GetX":
			L.Push(L.NewFunction(npc.GetX))
			return 1
		case "GetY":
			L.Push(L.NewFunction(npc.GetY))
			return 1
		case "GetZ":
			L.Push(L.NewFunction(npc.GetZ))
			return 1
		case "GetHeading":
			L.Push(L.NewFunction(npc.GetHeading))
			return 1
		case "GetNPCTypeID":
			L.Push(L.NewFunction(npc.GetNPCTypeID))
			return 1
		case "GetRace":
			L.Push(L.NewFunction(npc.GetRace))
			return 1
		case "GetBaseRace":
			L.Push(L.NewFunction(npc.GetBaseRace))
			return 1
		case "GetClass":
			L.Push(L.NewFunction(npc.GetClass))
			return 1
		case "GetPrimaryFaction":
			L.Push(L.NewFunction(npc.GetPrimaryFaction))
			return 1
		case "GetHP":
			L.Push(L.NewFunction(npc.GetHP))
			return 1
		case "TempName":
			L.Push(L.NewFunction(npc.TempName))
			return 1
		case "GetGender":
			L.Push(L.NewFunction(npc.GetGender))
			return 1
		case "Message":
			L.Push(L.NewFunction(npc.Message))
			return 1
		case "Shout":
			L.Push(L.NewFunction(npc.Shout))
			return 1
		case "QuestSay":
			L.Push(L.NewFunction(npc.QuestSay))
			return 1
		case "CastToNPC":
			L.Push(L.NewFunction(npc.CastToNPC))
			return 1
		case "HasItem":
			L.Push(L.NewFunction(npc.HasItem))
			return 1
		case "SetSpecialAbility":
			L.Push(L.NewFunction(npc.SetSpecialAbility))
			return 1
		case "SetSpecialAbilityParam":
			L.Push(L.NewFunction(npc.SetSpecialAbilityParam))
			return 1
		case "ModSkillDmgTaken":
			L.Push(L.NewFunction(npc.ModSkillDmgTaken))
			return 1
		case "ModifyNPCStat":
			L.Push(L.NewFunction(npc.ModifyNPCStat))
			return 1
		case "WipeHateList":
			L.Push(L.NewFunction(npc.WipeHateList))
			return 1
		case "GetHateRandom":
			L.Push(L.NewFunction(func(L *lua.LState) int { return b.pushNPCCombatActor(L, npc, QuestCombatRandomHate) }))
			return 1
		case "GetHateTop":
			L.Push(L.NewFunction(func(L *lua.LState) int { return b.pushNPCCombatActor(L, npc, QuestCombatTopHate) }))
			return 1
		case "AddToHateList":
			L.Push(L.NewFunction(npc.AddToHateList))
			return 1
		case "GetTarget":
			L.Push(L.NewFunction(func(L *lua.LState) int { return b.pushNPCCombatActor(L, npc, QuestCombatCurrentTarget) }))
			return 1
		case "MoveTo":
			L.Push(L.NewFunction(npc.MoveTo))
			return 1
		case "GMMove":
			L.Push(L.NewFunction(npc.GMMove))
			return 1
		case "SetRunning":
			L.Push(L.NewFunction(npc.SetRunning))
			return 1
		case "SetHP":
			L.Push(L.NewFunction(npc.SetHP))
			return 1
		case "GetMaxHP":
			L.Push(L.NewFunction(npc.GetMaxHP))
			return 1
		case "GetHPRatio":
			L.Push(L.NewFunction(npc.GetHPRatio))
			return 1
		case "GetGrid":
			L.Push(L.NewFunction(npc.GetGrid))
			return 1
		case "GetSp":
			L.Push(L.NewFunction(npc.GetSp))
			return 1
		case "GotoBind":
			L.Push(L.NewFunction(npc.GotoBind))
			return 1
		case "AddItem":
			L.Push(L.NewFunction(npc.AddItem))
			return 1
		case "SetScale":
			L.Push(L.NewFunction(npc.SetScale))
			return 1
		case "SetAppearance":
			L.Push(L.NewFunction(npc.SetAppearance))
			return 1
		case "ChangeSize":
			L.Push(L.NewFunction(npc.ChangeSize))
			return 1
		case "GetSpawnPointX":
			L.Push(L.NewFunction(npc.GetSpawnPointX))
			return 1
		case "GetSpawnPointY":
			L.Push(L.NewFunction(npc.GetSpawnPointY))
			return 1
		case "GetSpawnPointZ":
			L.Push(L.NewFunction(npc.GetSpawnPointZ))
			return 1
		case "GetSpawnPointH":
			L.Push(L.NewFunction(npc.GetSpawnPointH))
			return 1
		case "GetGuardPointX":
			L.Push(L.NewFunction(npc.GetSpawnPointX))
			return 1
		case "GetGuardPointY":
			L.Push(L.NewFunction(npc.GetSpawnPointY))
			return 1
		case "GetGuardPointZ":
			L.Push(L.NewFunction(npc.GetSpawnPointZ))
			return 1
		case "CalculateDistance":
			L.Push(L.NewFunction(npc.CalculateDistance))
			return 1
		case "SetRace":
			L.Push(L.NewFunction(npc.SetRace))
			return 1
		case "GetSp2", "GetSpawnPointID":
			L.Push(L.NewFunction(func(L *lua.LState) int { L.Push(lua.LNumber(0)); return 1 }))
			return 1
		case "RandomRoam":
			L.Push(L.NewFunction(func(L *lua.LState) int {
				npc.Capture.recordDeferredAPI(L, "e.self:RandomRoam")
				npc.Capture.NPCMoves = append(npc.Capture.NPCMoves, QuestNPCMoveRequest{Order: npc.Capture.nextActorEffectOrder(), Kind: QuestNPCMoveRoam, NPCTypeID: npc.ID, SpawnInstanceID: npc.SpawnInstanceID, PendingSpawnIndex: npc.PendingSpawnIndex, Roam: true})
				return 0
			}))
			return 1
		case "SaveGuardSpot", "AI_SetRoambox", "ResumeWandering", "SetPseudoRoot", "PauseWandering", "MerchantCloseShop", "MerchantOpenShop", "SetOOCRegen", "SetDisableMelee", "DoAnim", "ChangeTexture", "SetTexture", "SpellFinished", "SetEntityVariable", "SetTarget", "RemoveItem", "ClearSpecialAbilities", "SetBodyType", "AssignWaypoints", "SetFlyMode", "SetNPCFactionID", "SetTargetable", "SetInvisible", "SetLevel", "SendIllusionPacket", "RemoveAISpell", "CameraEffect", "FaceTarget", "ForeachHateList", "CombatRange", "DoMeleeSkillAttackDmg":
			L.Push(L.NewFunction(func(L *lua.LState) int { return 0 }))
			return 1
		case "GetOwner":
			L.Push(L.NewFunction(func(L *lua.LState) int { L.Push(L.CheckUserData(1)); return 1 }))
			return 1
		case "GuildID":
			L.Push(L.NewFunction(func(L *lua.LState) int { L.Push(lua.LNumber(0)); return 1 }))
			return 1
		case "IsEngaged":
			L.Push(L.NewFunction(func(L *lua.LState) int { L.Push(lua.LBool(false)); return 1 }))
			return 1
		case "SetGlobal":
			L.Push(L.NewFunction(func(L *lua.LState) int {
				name, value := L.CheckString(2), L.CheckString(3)
				npc.Capture.Globals[name] = GlobalUpdate{Name: name, Value: value}
				return 0
			}))
			return 1
		case "CastedSpellFinished":
			L.Push(L.NewFunction(npc.CastedSpellFinished))
			return 1
		}
		return 0
	}))
	return mt
}

func (b *LuaBridge) createPlayerMetatable(L *lua.LState) *lua.LTable {
	mt := L.NewTable()
	L.SetField(mt, "__index", L.NewFunction(func(L *lua.LState) int {
		player := L.CheckUserData(1).Value.(*PlayerProxy)
		key := L.CheckString(2)
		switch key {
		case "GetName":
			L.Push(L.NewFunction(player.GetName))
			return 1
		case "GetCleanName":
			L.Push(L.NewFunction(player.GetCleanName))
			return 1
		case "CharacterID":
			L.Push(L.NewFunction(player.CharacterID))
			return 1
		case "GetID":
			L.Push(L.NewFunction(player.GetID))
			return 1
		case "GetLevel":
			L.Push(L.NewFunction(player.Level))
			return 1
		case "GetClass":
			L.Push(L.NewFunction(player.Class))
			return 1
		case "GetRace":
			L.Push(L.NewFunction(player.Race))
			return 1
		case "HasItem":
			L.Push(L.NewFunction(player.HasItem))
			return 1
		case "KeyRingCheck":
			L.Push(L.NewFunction(player.KeyRingCheck))
			return 1
		case "CreateExpedition":
			L.Push(L.NewFunction(player.CreateExpedition))
			return 1
		case "Class":
			L.Push(L.NewFunction(player.Class))
			return 1
		case "Race":
			L.Push(L.NewFunction(player.Race))
			return 1
		case "Level":
			L.Push(L.NewFunction(player.Level))
			return 1
		case "SummonItem":
			L.Push(L.NewFunction(player.SummonItem))
			return 1
		case "AddEXP":
			L.Push(L.NewFunction(player.AddEXP))
			return 1
		case "Ding":
			L.Push(L.NewFunction(player.Ding))
			return 1
		case "Faction":
			L.Push(L.NewFunction(player.Faction))
			return 1
		case "GetFaction":
			L.Push(L.NewFunction(player.questFactionStanding))
			return 1
		case "RewardFaction":
			L.Push(L.NewFunction(player.RewardFaction))
			return 1
		case "GiveCash":
			L.Push(L.NewFunction(player.GiveCash))
			return 1
		case "Message":
			L.Push(L.NewFunction(player.Message))
			return 1
		case "CastToClient":
			L.Push(L.NewFunction(player.CastToClient))
			return 1
		case "AssignTask":
			L.Push(L.NewFunction(player.AssignTask))
			return 1
		case "IsTaskActive":
			L.Push(L.NewFunction(player.IsTaskActive))
			return 1
		case "TaskSelector":
			L.Push(L.NewFunction(player.TaskSelector))
			return 1
		case "MovePC":
			L.Push(L.NewFunction(player.MovePC))
			return 1
		case "ClearCompassMark":
			L.Push(L.NewFunction(player.ClearCompassMark))
			return 1
		case "GetBindZoneID":
			L.Push(L.NewFunction(player.GetBindZoneID))
			return 1
		case "IsInAGuild":
			L.Push(L.NewFunction(player.IsInAGuild))
			return 1
		case "SendToGuildHall":
			L.Push(L.NewFunction(player.SendToGuildHall))
			return 1
		case "RemoveItem":
			L.Push(L.NewFunction(player.RemoveItem))
			return 1
		case "NukeItem":
			L.Push(L.NewFunction(player.NukeItem))
			return 1
		case "Popup":
			L.Push(L.NewFunction(player.Popup))
			return 1
		case "BuffFadeAll":
			L.Push(L.NewFunction(player.BuffFadeAll))
			return 1
		case "GetStartZone":
			L.Push(L.NewFunction(player.GetStartZone))
			return 1
		case "SetPVP":
			L.Push(L.NewFunction(player.SetPVP))
			return 1
		case "QuestReward":
			L.Push(L.NewFunction(player.QuestReward))
			return 1
		case "HasSpellScribed":
			L.Push(L.NewFunction(player.HasSpellScribed))
			return 1
		case "GetRaceName":
			L.Push(L.NewFunction(player.GetRaceName))
			return 1
		case "GetGM":
			L.Push(L.NewFunction(player.GetGM))
			return 1
		case "UpdateTaskActivity":
			L.Push(L.NewFunction(player.UpdateTaskActivity))
			return 1
		case "IsTaskActivityActive":
			L.Push(L.NewFunction(player.IsTaskActivityActive))
			return 1
		case "IsTaskCompleted":
			L.Push(L.NewFunction(player.IsTaskCompleted))
			return 1
		case "IsPet":
			L.Push(L.NewFunction(player.IsPet))
			return 1
		case "IsClient":
			L.Push(L.NewFunction(player.IsClient))
			return 1
		case "GetGlobal":
			L.Push(L.NewFunction(player.GetGlobal))
			return 1
		case "SetGlobal":
			L.Push(L.NewFunction(player.SetGlobal))
			return 1
		case "GetX":
			L.Push(L.NewFunction(player.GetX))
			return 1
		case "GetY":
			L.Push(L.NewFunction(player.GetY))
			return 1
		case "GetZ":
			L.Push(L.NewFunction(player.GetZ))
			return 1
		case "GetHeading":
			L.Push(L.NewFunction(player.GetHeading))
			return 1
		case "GetBaseRace":
			L.Push(L.NewFunction(player.GetBaseRace))
			return 1
		case "GetClassName":
			L.Push(L.NewFunction(player.GetClassName))
			return 1
		case "GetDeity":
			L.Push(L.NewFunction(player.GetDeity))
			return 1
		case "GetGender":
			L.Push(L.NewFunction(player.GetGender))
			return 1
		case "HasDisciplineLearned":
			L.Push(L.NewFunction(player.HasDisciplineLearned))
			return 1
		case "AddAAPoints":
			L.Push(L.NewFunction(player.AddAAPoints))
			return 1
		case "Admin":
			L.Push(L.NewFunction(player.Admin))
			return 1
		case "AddItem":
			L.Push(L.NewFunction(player.AddItem))
			return 1
		case "GetCharacterFactionLevel":
			L.Push(L.NewFunction(player.GetCharacterFactionLevel))
			return 1
		case "GetModCharacterFactionLevel":
			L.Push(L.NewFunction(player.GetModCharacterFactionLevel))
			return 1
		case "SendSound":
			L.Push(L.NewFunction(player.SendSound))
			return 1
		case "Say":
			L.Push(L.NewFunction(player.Say))
			return 1
		case "Emote":
			L.Push(L.NewFunction(player.Emote))
			return 1
		case "Signal":
			L.Push(L.NewFunction(player.Signal))
			return 1
		case "MovePCDynamicZone":
			L.Push(L.NewFunction(player.MovePCDynamicZone))
			return 1
		case "MovePCInstance":
			L.Push(L.NewFunction(player.MovePCInstance))
			return 1
		case "HasZoneFlag":
			L.Push(L.NewFunction(player.HasZoneFlag))
			return 1
		case "GuildID":
			L.Push(L.NewFunction(player.GuildID))
			return 1
		case "GetSkill":
			L.Push(L.NewFunction(player.GetSkill))
			return 1
		case "GetRawSkill":
			L.Push(L.NewFunction(player.GetRawSkill))
			return 1
		case "MaxSkill":
			L.Push(L.NewFunction(player.MaxSkill))
			return 1
		case "CanHaveSkill":
			L.Push(L.NewFunction(player.CanHaveSkill))
			return 1
		case "GetBucket":
			L.Push(L.NewFunction(player.GetBucket))
			return 1
		case "SetBucket":
			L.Push(L.NewFunction(player.SetBucket))
			return 1
		case "GetExpedition":
			L.Push(L.NewFunction(player.GetExpedition))
			return 1
		case "FindBuff":
			L.Push(L.NewFunction(player.FindBuff))
			return 1
		case "SpellFinished":
			L.Push(L.NewFunction(player.SpellFinished))
			return 1
		case "SelfCast":
			L.Push(L.NewFunction(player.SelfCast))
			return 1
		case "BuffFadeBySpellID":
			L.Push(L.NewFunction(player.BuffFadeBySpellID))
			return 1
		case "AddMoneyToPP":
			L.Push(L.NewFunction(player.AddMoneyToPP))
			return 1
		case "GetLanguageSkill":
			L.Push(L.NewFunction(player.GetLanguageSkill))
			return 1
		case "SetSkill":
			L.Push(L.NewFunction(player.SetSkill))
			return 1
		case "SetAATitle":
			L.Push(L.NewFunction(player.SetAATitle))
			return 1
		case "SendColoredText":
			L.Push(L.NewFunction(player.SendColoredText))
			return 1
		case "GetCorpseCount":
			L.Push(L.NewFunction(player.GetCorpseCount))
			return 1
		case "GetGroup":
			L.Push(L.NewFunction(player.GetGroup))
			return 1
		case "GetGroupMemberCount":
			L.Push(L.NewFunction(player.GetGroupMemberCount))
			return 1
		case "GetRaidMemberCountInZone":
			L.Push(L.NewFunction(player.GetRaidMemberCountInZone))
			return 1
		case "DoesAnyPartyMemberHaveLockout":
			L.Push(L.NewFunction(player.DoesAnyPartyMemberHaveLockout))
			return 1
		case "GetOwner":
			L.Push(L.NewFunction(player.GetOwner))
			return 1
		case "GetMobByNpcTypeID":
			L.Push(L.NewFunction(player.GetMobByNpcTypeID))
			return 1
		case "GetNPCTypeID":
			L.Push(L.NewFunction(player.GetNPCTypeID))
			return 1
		case "AddLevelBasedExp":
			L.Push(L.NewFunction(player.AddLevelBasedExp))
			return 1
		case "AddNimbusEffect":
			L.Push(L.NewFunction(player.AddNimbusEffect))
			return 1
		case "RemoveNimbusEffect":
			L.Push(L.NewFunction(player.RemoveNimbusEffect))
			return 1
		case "DisableAreaRegens":
			L.Push(L.NewFunction(player.DisableAreaRegens))
			return 1
		case "EnableAreaRegens":
			L.Push(L.NewFunction(player.EnableAreaRegens))
			return 1
		case "PushItemOnCursor":
			L.Push(L.NewFunction(player.PushItemOnCursor))
			return 1
		case "GetItemIDAt":
			L.Push(L.NewFunction(func(L *lua.LState) int {
				return player.Capture.recordDeferredAPI(L, "player.GetItemIDAt")
			}))
			return 1
		case "GetInventory":
			L.Push(L.NewFunction(func(L *lua.LState) int {
				inventory := L.NewTable()
				L.SetField(inventory, "HasItem", L.NewFunction(func(L *lua.LState) int {
					return player.Capture.recordDeferredAPI(L, "player.GetInventory.HasItem")
				}))
				L.Push(inventory)
				return 1
			}))
			return 1
		}
		return 0
	}))
	return mt
}

func (b *LuaBridge) registerStringExtensions(L *lua.LState) {
	mt := L.GetMetatable(lua.LString(""))
	if mt == lua.LNil {
		mt = L.NewTable()
		L.SetMetatable(lua.LString(""), mt)
	}
	index := L.GetField(mt, "__index")
	if tbl, ok := index.(*lua.LTable); ok {
		L.SetField(tbl, "findi", L.NewFunction(func(L *lua.LState) int {
			str := strings.ToLower(L.CheckString(1))
			pattern := strings.ToLower(L.CheckString(2))
			if strings.Contains(str, pattern) {
				L.Push(lua.LNumber(strings.Index(str, pattern) + 1))
				return 1
			}
			L.Push(lua.LNil)
			return 1
		}))
	}
}

func (b *LuaBridge) registerEventConstants(L *lua.LState) {
	eventTable := L.NewTable()
	events := map[string]string{
		"spawn":               string(RuntimeEventSpawn),
		"trade":               string(RuntimeEventTrade),
		"timer":               string(RuntimeEventTimer),
		"signal":              string(RuntimeEventSignal),
		"death":               string(RuntimeEventDeath),
		"death_complete":      string(RuntimeEventDeathComplete),
		"combat":              string(RuntimeEventCombat),
		"hp":                  string(RuntimeEventHP),
		"enter":               string(RuntimeEventEnter),
		"exit":                string(RuntimeEventExit),
		"waypoint_arrive":     string(RuntimeEventWaypointArrive),
		"waypoint_depart":     string(RuntimeEventWaypointDepart),
		"enter_zone":          string(RuntimeEventEnterZone),
		"click_door":          string(RuntimeEventClickDoor),
		"cast_on":             string(RuntimeEventCastOn),
		"proximity_say":       string(RuntimeEventProximitySay),
		"loot":                string(RuntimeEventLoot),
		"fish_success":        string(RuntimeEventFishSuccess),
		"forage_success":      string(RuntimeEventForageSuccess),
		"inspect":             string(RuntimeEventInspect),
		"popup_response":      string(RuntimeEventPopupResponse),
		"task_stage_complete": string(RuntimeEventTaskStageComplete),
		"say":                 "say",
		"tick":                "timer",
		"death_zone":          "death_zone",
	}
	for name, value := range events {
		L.SetField(eventTable, name, lua.LString(value))
	}
	L.SetGlobal("Event", eventTable)
}

func eventNameFromLuaValue(value lua.LValue) string {
	switch typed := value.(type) {
	case lua.LString:
		return string(typed)
	case lua.LNumber:
		return strconv.Itoa(int(typed))
	default:
		return ""
	}
}

func (b *LuaBridge) registerEqGlobal(L *lua.LState, capture *QuestCapture, event *LuaEvent) {
	eq := L.NewTable()
	L.SetGlobal("eq", eq)
	initialGlobals := map[string]string{}
	if event != nil && event.Globals != nil {
		initialGlobals = event.Globals
	}

	L.SetField(eq, "say_link", L.NewFunction(func(L *lua.LState) int {
		keyword := L.CheckString(1)
		display := keyword
		// eq.say_link(keyword, silent, display)
		if L.GetTop() >= 3 {
			display = L.CheckString(3)
		}
		capture.SayLinks = append(capture.SayLinks, DialogueOption{Text: display, Keyword: keyword})
		L.Push(lua.LString(display))
		return 1
	}))
	L.SetField(eq, "handin", L.NewFunction(func(L *lua.LState) int {
		requiredTable := L.ToTable(1)
		if requiredTable == nil || capture == nil || capture.CurrentTrade == nil {
			L.Push(lua.LBool(false))
			return 1
		}
		reqItems, reqPlat, reqGold, reqSilver, reqCopper := handinRequirementsFromLuaTable(requiredTable)
		L.Push(lua.LBool(consumeTradeRequirements(capture.CurrentTrade, reqItems, reqPlat, reqGold, reqSilver, reqCopper)))
		return 1
	}))
	b.registerEventConstants(L)
	L.SetField(eq, "register_npc_event", L.NewFunction(func(L *lua.LState) int {
		eventValueIndex := 1
		if L.GetTop() >= 4 && L.Get(1).Type() == lua.LTString {
			eventValueIndex = 2
		}
		eventName := eventNameFromLuaValue(L.Get(eventValueIndex))
		npcID := int32(lua.LVAsNumber(L.Get(eventValueIndex + 1)))
		handler := L.Get(eventValueIndex + 2)
		if eventName != "" && npcID > 0 && handler.Type() == lua.LTFunction {
			capture.Registrations = append(capture.Registrations, QuestEventRegistration{Scope: "npc", Event: eventName, NPCTypeID: npcID, Handler: handler})
		}
		return 0
	}))
	L.SetField(eq, "register_player_event", L.NewFunction(func(L *lua.LState) int {
		eventValueIndex := 1
		if L.GetTop() >= 3 && L.Get(1).Type() == lua.LTString {
			eventValueIndex = 2
		}
		eventName := eventNameFromLuaValue(L.Get(eventValueIndex))
		handler := L.Get(eventValueIndex + 1)
		if eventName != "" && handler.Type() == lua.LTFunction {
			capture.Registrations = append(capture.Registrations, QuestEventRegistration{Scope: "player", Event: eventName, Handler: handler})
		}
		return 0
	}))
	L.SetField(eq, "register_encounter_event", L.NewFunction(func(L *lua.LState) int {
		eventValueIndex := 1
		if L.GetTop() >= 3 && L.Get(1).Type() == lua.LTString {
			eventValueIndex = 2
		}
		eventName := eventNameFromLuaValue(L.Get(eventValueIndex))
		handler := L.Get(eventValueIndex + 1)
		if eventName != "" && handler.Type() == lua.LTFunction {
			capture.Registrations = append(capture.Registrations, QuestEventRegistration{Scope: "encounter", Event: eventName, Handler: handler})
		}
		return 0
	}))

	L.SetField(eq, "seconds", L.NewFunction(func(L *lua.LState) int {
		L.Push(lua.LNumber(parseQuestDurationSeconds(L.CheckString(1))))
		return 1
	}))
	for _, name := range []string{"get_zone_instance_id", "get_zone_instance_version", "get_zone_id", "get_spawn_condition", "get_dz_task_id"} {
		L.SetField(eq, name, L.NewFunction(func(L *lua.LState) int { L.Push(lua.LNumber(0)); return 1 }))
	}
	L.SetField(eq, "get_player_buried_corpse_count", L.NewFunction(func(L *lua.LState) int { L.Push(lua.LNumber(0)); return 1 }))
	L.SetField(eq, "set_zone_flag", L.NewFunction(func(L *lua.LState) int {
		capture.ZoneFlags = append(capture.ZoneFlags, L.CheckInt(1))
		return 0
	}))
	L.SetField(eq, "get_zone_short_name", L.NewFunction(func(L *lua.LState) int { L.Push(lua.LString("")); return 1 }))
	for _, name := range []string{"toggle_spawn_event", "set_anim", "add_area", "end_dz_task", "reject_say", "task_selector"} {
		L.SetField(eq, name, L.NewFunction(func(L *lua.LState) int { return 0 }))
	}
	L.SetField(eq, "load_encounter", L.NewFunction(func(L *lua.LState) int {
		capture.EncounterLoads = append(capture.EncounterLoads, L.CheckString(1))
		return 0
	}))
	for _, name := range []string{"debug"} {
		L.SetField(eq, name, L.NewFunction(func(L *lua.LState) int { return 0 }))
	}
	getExpedition := func(L *lua.LState) int {
		expedition := L.NewTable()
		L.SetField(expedition, "valid", lua.LBool(false))
		for _, name := range []string{"AddReplayLockout", "AddLockout", "SetLocked", "Save", "MovePCs", "Message"} {
			L.SetField(expedition, name, L.NewFunction(func(L *lua.LState) int { return 0 }))
		}
		for _, name := range []string{"GetZoneID", "GetInstanceID", "GetMemberCount"} {
			L.SetField(expedition, name, L.NewFunction(func(L *lua.LState) int { L.Push(lua.LNumber(0)); return 1 }))
		}
		L.SetField(expedition, "HasLockout", L.NewFunction(func(L *lua.LState) int { L.Push(lua.LBool(false)); return 1 }))
		L.Push(expedition)
		return 1
	}
	L.SetField(eq, "get_expedition", L.NewFunction(getExpedition))
	L.SetField(eq, "get_expedition_by_zone_instance", L.NewFunction(getExpedition))
	L.SetField(eq, "get_characters_in_instance", L.NewFunction(func(L *lua.LState) int { L.Push(L.NewTable()); return 1 }))
	L.SetField(eq, "GM_Message", L.NewFunction(func(L *lua.LState) int { return 0 }))
	pushClient := func(L *lua.LState) int {
		ud := L.NewUserData()
		ud.Value = event.Player
		L.SetMetatable(ud, b.createPlayerMetatable(L))
		L.Push(ud)
		return 1
	}
	clientTable := L.NewTable()
	clientMT := L.NewTable()
	L.SetField(clientMT, "__call", L.NewFunction(pushClient))
	L.SetMetatable(clientTable, clientMT)
	L.SetGlobal("Client", clientTable)
	for _, name := range []string{"Mob", "NPC", "EntityList"} {
		L.SetGlobal(name, L.NewTable())
	}
	zoneTable := L.NewTable()
	for index, name := range []string{
		"qeynos", "qeynos2", "qrg", "freportn", "freportw", "freporte", "rivervale", "ecommons",
		"erudnint", "erudnext", "halas", "everfrost", "nro", "sro", "neriaka", "neriakb", "neriakc",
		"qcat", "oggok", "grobb", "gfaydark", "akanon", "kaladima", "felwithea", "felwitheb",
		"kaladimb", "butcher", "paineel", "cabwest", "cabeast", "sharvahl", "poknowledge",
		"freeporteast", "freeportwest", "northro", "southro", "commonlands",
	} {
		L.SetField(zoneTable, name, lua.LNumber(index+1))
	}
	L.SetGlobal("Zone", zoneTable)
	L.SetField(eq, "is_content_flag_enabled", L.NewFunction(func(L *lua.LState) int { L.Push(lua.LBool(false)); return 1 }))

	L.SetField(eq, "ExpHelper", L.NewFunction(func(L *lua.LState) int {
		level := L.CheckInt(1)
		percent, spread := 3, 1
		if L.GetTop() >= 2 {
			percent = L.CheckInt(2)
		}
		if L.GetTop() >= 3 {
			spread = L.CheckInt(3)
		}
		L.Push(lua.LNumber(questExperienceReward(level, percent, spread)))
		return 1
	}))

	defaultX, defaultY, defaultZ, defaultHeading := 0.0, 0.0, 0.0, 0.0
	if event != nil && event.NPC != nil {
		defaultX = event.NPC.X
		defaultY = event.NPC.Y
		defaultZ = event.NPC.Z
		defaultHeading = event.NPC.Heading
	}
	numberArg := func(L *lua.LState, index int, fallback float64) float64 {
		if L.GetTop() < index {
			return fallback
		}
		value := L.Get(index)
		if value == lua.LNil {
			return fallback
		}
		return float64(lua.LVAsNumber(value))
	}
	pushSpawnProxy := func(L *lua.LState, spawn QuestSpawnRequest) {
		ud := L.NewUserData()
		ud.Value = &NPCProxy{
			ID:                spawn.NPCTypeID,
			Name:              fmt.Sprintf("%d", spawn.NPCTypeID),
			X:                 spawn.X,
			Y:                 spawn.Y,
			Z:                 spawn.Z,
			Heading:           spawn.Heading,
			Capture:           capture,
			PendingSpawnIndex: len(capture.Spawns),
		}
		L.SetMetatable(ud, b.createNPCMetatable(L))
		L.Push(ud)
	}
	captureSpawn := func(unique bool) lua.LGFunction {
		return func(L *lua.LState) int {
			value := float64(L.CheckNumber(1))
			if math.IsNaN(value) || math.IsInf(value, 0) || value < 0 || value > math.MaxInt32 || math.Trunc(value) != value {
				return capture.rejectActorEffect(L, "invalid quest spawn NPC type identity")
			}
			npcTypeID := int32(value)
			// ProjectEQ uses ChooseRandom(..., 0) for an intentional no-spawn
			// outcome (e.g. Fear golem broodlings). EQEmu spawn2 returns a null
			// mob when no type loads; do not enqueue an invalid world mutation
			// for this explicit sentinel. Other missing IDs still fail validation.
			if npcTypeID == 0 {
				ud := L.NewUserData()
				ud.Value = &NPCProxy{Capture: capture, missingActor: true, externalActor: true}
				L.SetMetatable(ud, b.createNPCMetatable(L))
				L.Push(ud)
				return 1
			}
			spawn := QuestSpawnRequest{
				NPCTypeID: npcTypeID,
				GridID:    int32(numberArg(L, 2, 0)),
				X:         numberArg(L, 4, defaultX),
				Y:         numberArg(L, 5, defaultY),
				Z:         numberArg(L, 6, defaultZ),
				Heading:   numberArg(L, 7, defaultHeading),
				Unique:    unique,
			}
			capture.Spawns = append(capture.Spawns, spawn)
			pushSpawnProxy(L, spawn)
			return 1
		}
	}

	L.SetField(eq, "get_entity_list", L.NewFunction(func(L *lua.LState) int {
		// Return a mock entity list table
		entityList := L.NewTable()
		L.SetField(entityList, "MessageClose", L.NewFunction(func(L *lua.LState) int {
			// Mock MessageClose by appending to Responses
			// Arguments: self, self_npc, is_echo, dist, color, text
			if L.GetTop() >= 6 {
				msg := L.CheckString(6)
				capture.Responses = append(capture.Responses, msg)
			} else if L.GetTop() >= 5 {
				msg := L.CheckString(5)
				capture.Responses = append(capture.Responses, msg)
			}
			return 0
		}))
		L.SetField(entityList, "IsMobSpawnedByNpcTypeID", L.NewFunction(func(L *lua.LState) int {
			npcTypeID := int32(L.CheckInt(2))
			L.Push(lua.LBool(luaEventHasVisibleNPCTypeID(event, npcTypeID)))
			return 1
		}))
		L.SetField(entityList, "GetMobByNpcTypeID", L.NewFunction(func(L *lua.LState) int {
			return b.npcLookup(L, event, capture, "entity_list.GetMobByNpcTypeID", false)
		}))
		L.SetField(entityList, "GetNPCByNPCTypeID", L.NewFunction(func(L *lua.LState) int {
			return b.npcLookup(L, event, capture, "entity_list.GetNPCByNPCTypeID", false)
		}))
		L.SetField(entityList, "GetNPCBySpawnID", L.NewFunction(func(L *lua.LState) int {
			return b.npcLookup(L, event, capture, "entity_list.GetNPCBySpawnID", true)
		}))
		L.SetField(entityList, "GetClientList", L.NewFunction(func(L *lua.LState) int {
			list := L.NewTable()
			yielded := false
			L.SetField(list, "entries", L.NewFunction(func(L *lua.LState) int {
				if yielded {
					L.Push(lua.LNil)
					return 1
				}
				yielded = true
				ud := L.NewUserData()
				ud.Value = event.Player
				L.SetMetatable(ud, b.createPlayerMetatable(L))
				L.Push(ud)
				return 1
			}))
			L.Push(list)
			return 1
		}))
		L.SetField(entityList, "GetClientEntries", L.NewFunction(func(L *lua.LState) int {
			yielded := false
			L.Push(L.NewFunction(func(L *lua.LState) int {
				if yielded {
					L.Push(lua.LNil)
					return 1
				}
				yielded = true
				ud := L.NewUserData()
				ud.Value = event.Player
				L.SetMetatable(ud, b.createPlayerMetatable(L))
				L.Push(ud)
				return 1
			}))
			return 1
		}))
		L.SetField(entityList, "GetNPCList", L.NewFunction(func(L *lua.LState) int {
			return b.npcEntries(L, event, capture, "entity_list.GetNPCList", true)
		}))
		L.SetField(entityList, "GetNPCEntries", L.NewFunction(func(L *lua.LState) int {
			return b.npcEntries(L, event, capture, "entity_list.GetNPCEntries", false)
		}))
		L.SetField(entityList, "GetRandomClient", L.NewFunction(func(L *lua.LState) int {
			ud := L.NewUserData()
			ud.Value = event.Player
			L.SetMetatable(ud, b.createPlayerMetatable(L))
			L.Push(ud)
			return 1
		}))
		L.SetField(entityList, "GetClientByID", L.NewFunction(func(L *lua.LState) int {
			ud := L.NewUserData()
			ud.Value = event.Player
			L.SetMetatable(ud, b.createPlayerMetatable(L))
			L.Push(ud)
			return 1
		}))
		L.SetField(entityList, "GetClientByCharID", L.NewFunction(func(L *lua.LState) int {
			ud := L.NewUserData()
			ud.Value = event.Player
			L.SetMetatable(ud, b.createPlayerMetatable(L))
			L.Push(ud)
			return 1
		}))
		L.SetField(entityList, "FindDoor", L.NewFunction(func(L *lua.LState) int {
			door := L.NewTable()
			L.SetField(door, "SetLockPick", L.NewFunction(func(L *lua.LState) int { return 0 }))
			L.SetField(door, "ForceOpen", L.NewFunction(func(L *lua.LState) int { return 0 }))
			L.Push(door)
			return 1
		}))
		L.Push(entityList)
		return 1
	}))

	L.SetField(eq, "get_qglobals", L.NewFunction(func(L *lua.LState) int {
		globalsTable := L.NewTable()
		// First set initial globals
		for k, v := range initialGlobals {
			L.SetField(globalsTable, k, lua.LString(v))
		}
		// Then overlay any updates from the current capture
		for k, v := range capture.Globals {
			if v.Delete {
				L.SetField(globalsTable, k, lua.LNil)
			} else {
				L.SetField(globalsTable, k, lua.LString(v.Value))
			}
		}
		L.Push(globalsTable)
		return 1
	}))

	L.SetField(eq, "target_global", L.NewFunction(func(L *lua.LState) int {
		// mock
		return 0
	}))

	L.SetField(eq, "set_global", L.NewFunction(func(L *lua.LState) int {
		name := L.CheckString(1)
		val := L.CheckString(2)
		options := L.CheckInt(3)
		duration := L.CheckString(4)
		capture.Globals[name] = GlobalUpdate{
			Name:     name,
			Value:    val,
			Options:  options,
			Duration: duration,
		}
		return 0
	}))

	deleteGlobal := func(L *lua.LState) int {
		name := L.CheckString(1)
		capture.Globals[name] = GlobalUpdate{
			Name:   name,
			Delete: true,
		}
		return 0
	}
	L.SetField(eq, "delete_global", L.NewFunction(deleteGlobal))
	L.SetField(eq, "del_global", L.NewFunction(deleteGlobal))

	L.SetField(eq, "set_timer", L.NewFunction(func(L *lua.LState) int {
		name := L.CheckString(1)
		ms := L.CheckInt(2)
		capture.Timers = append(capture.Timers, TimerUpdate{Name: name, Interval: ms})
		return 0
	}))

	L.SetField(eq, "stop_timer", L.NewFunction(func(L *lua.LState) int {
		name := L.CheckString(1)
		capture.Timers = append(capture.Timers, TimerUpdate{Name: name, Stop: true})
		return 0
	}))
	L.SetField(eq, "pause_timer", L.NewFunction(func(L *lua.LState) int {
		name := L.CheckString(1)
		capture.Timers = append(capture.Timers, TimerUpdate{Name: name, Pause: true})
		return 0
	}))
	L.SetField(eq, "pause", L.GetField(eq, "pause_timer"))
	L.SetField(eq, "resume_timer", L.NewFunction(func(L *lua.LState) int {
		name := L.CheckString(1)
		capture.Timers = append(capture.Timers, TimerUpdate{Name: name, Resume: true})
		return 0
	}))
	L.SetField(eq, "resume", L.GetField(eq, "resume_timer"))
	L.SetField(eq, "is_paused_timer", L.NewFunction(func(L *lua.LState) int {
		return pushTimerPaused(L, event, capture)
	}))
	L.SetField(eq, "stop_all_timers", L.NewFunction(func(L *lua.LState) int {
		capture.Timers = append(capture.Timers, TimerUpdate{Name: "*", Stop: true})
		return 0
	}))

	L.SetField(eq, "set_next_hp_event", L.NewFunction(func(L *lua.LState) int {
		capture.HPEvents = append(capture.HPEvents, HPEventUpdate{Percent: L.CheckInt(1)})
		return 0
	}))
	L.SetField(eq, "set_next_inc_hp_event", L.NewFunction(func(L *lua.LState) int {
		capture.HPEvents = append(capture.HPEvents, HPEventUpdate{Percent: L.CheckInt(1), Increasing: true})
		return 0
	}))
	L.SetField(eq, "set_proximity", L.NewFunction(func(L *lua.LState) int {
		update := &ProximityUpdate{
			MinX: float64(L.CheckNumber(1)), MaxX: float64(L.CheckNumber(2)),
			MinY: float64(L.CheckNumber(3)), MaxY: float64(L.CheckNumber(4)),
			MinZ: -1000000, MaxZ: 1000000,
		}
		if L.GetTop() >= 6 {
			update.MinZ, update.MaxZ = float64(L.CheckNumber(5)), float64(L.CheckNumber(6))
		}
		capture.Proximity = update
		return 0
	}))
	L.SetField(eq, "clear_proximity", L.NewFunction(func(L *lua.LState) int {
		capture.Proximity = &ProximityUpdate{Clear: true}
		return 0
	}))
	proximitySpeechSwitch := func(enabled bool) lua.LGFunction {
		return func(L *lua.LState) int {
			capture.ProximitySayEnabled = &enabled
			return 0
		}
	}
	L.SetField(eq, "enable_proximity_say", L.NewFunction(proximitySpeechSwitch(true)))
	L.SetField(eq, "disable_proximity_say", L.NewFunction(proximitySpeechSwitch(false)))
	capturePlayerMove := func(zoneArg, coordOffset int, dynamic bool) lua.LGFunction {
		return func(L *lua.LState) int {
			move := QuestPlayerMoveRequest{ZoneID: L.CheckInt(zoneArg), Dynamic: dynamic}
			if L.GetTop() >= coordOffset {
				move.X = float64(lua.LVAsNumber(L.Get(coordOffset)))
			}
			if L.GetTop() >= coordOffset+1 {
				move.Y = float64(lua.LVAsNumber(L.Get(coordOffset + 1)))
			}
			if L.GetTop() >= coordOffset+2 {
				move.Z = float64(lua.LVAsNumber(L.Get(coordOffset + 2)))
			}
			if L.GetTop() >= coordOffset+3 {
				move.Heading = float64(lua.LVAsNumber(L.Get(coordOffset + 3)))
			}
			capture.PlayerMoves = append(capture.PlayerMoves, move)
			return 0
		}
	}
	L.SetField(eq, "move_pc", L.NewFunction(capturePlayerMove(1, 2, false)))
	L.SetField(eq, "movepc", L.NewFunction(capturePlayerMove(1, 2, false)))
	L.SetField(eq, "move_pc_dynamic_zone", L.NewFunction(capturePlayerMove(1, 2, true)))
	L.SetField(eq, "move_pc_instance", L.NewFunction(func(L *lua.LState) int {
		move := QuestPlayerMoveRequest{ZoneID: L.CheckInt(1)}
		if L.GetTop() >= 2 {
			move.InstanceID = L.CheckInt(2)
		}
		if L.GetTop() >= 3 {
			move.X = float64(lua.LVAsNumber(L.Get(3)))
		}
		if L.GetTop() >= 4 {
			move.Y = float64(lua.LVAsNumber(L.Get(4)))
		}
		if L.GetTop() >= 5 {
			move.Z = float64(lua.LVAsNumber(L.Get(5)))
		}
		if L.GetTop() >= 6 {
			move.Heading = float64(lua.LVAsNumber(L.Get(6)))
		}
		capture.PlayerMoves = append(capture.PlayerMoves, move)
		return 0
	}))
	L.SetField(eq, "force_door_open", L.NewFunction(func(L *lua.LState) int {
		doorID := int32(L.CheckInt(1))
		capture.Doors = append(capture.Doors, QuestDoorRequest{DoorID: doorID, ForceOpen: true})
		return 0
	}))
	L.SetField(eq, "forcedooropen", L.GetField(eq, "force_door_open"))
	L.SetField(eq, "bind_player", L.NewFunction(func(L *lua.LState) int {
		capture.Binds = append(capture.Binds, QuestBindRequest{})
		return 0
	}))
	L.SetField(eq, "self_cast", L.NewFunction(func(L *lua.LState) int {
		capture.Spells = append(capture.Spells, L.CheckInt(1))
		return 0
	}))
	L.SetField(eq, "selfcast", L.GetField(eq, "self_cast"))

	L.SetField(eq, "signal", L.NewFunction(func(L *lua.LState) int {
		npcID := L.CheckInt(1)
		signalID := 0
		if L.GetTop() >= 2 {
			signalID = L.CheckInt(2)
		}
		var delayMS int64
		if L.GetTop() >= 3 {
			value := float64(L.CheckNumber(3))
			// EQEmu's wait_ms is an integer millisecond argument. Reject malformed
			// data rather than firing a delayed ceremony immediately.
			if math.IsNaN(value) || math.IsInf(value, 0) || value < 0 || math.Trunc(value) != value || value > math.MaxInt32 {
				L.ArgError(3, "signal delay must be a non-negative int32 number of milliseconds")
				return 0
			}
			delayMS = int64(value)
		}
		capture.Signals = append(capture.Signals, NPCSignal{
			NPCID:    npcID,
			SignalID: signalID,
			DelayMS:  delayMS,
		})
		return 0
	}))

	L.SetField(eq, "assign_task", L.NewFunction(func(L *lua.LState) int {
		capture.Tasks = append(capture.Tasks, TaskAction{TaskID: L.CheckInt(1), Action: "assign"})
		return 0
	}))

	L.SetField(eq, "fail_task", L.NewFunction(func(L *lua.LState) int {
		capture.Tasks = append(capture.Tasks, TaskAction{TaskID: L.CheckInt(1), Action: "fail"})
		return 0
	}))

	L.SetField(eq, "is_task_active", L.NewFunction(func(L *lua.LState) int {
		// This needs access to the player. Since it's a global function, it's tricky.
		// Usually these are only called within an event where 'e.other' exists.
		// But some scripts use eq.is_task_active.
		// For now return false or implement a way to get the current player's tasks.
		L.Push(lua.LBool(false)) // Default to false for now
		return 1
	}))

	L.SetField(eq, "is_task_completed", L.NewFunction(func(L *lua.LState) int {
		// Similar to is_task_active, needs player context.
		L.Push(lua.LBool(false)) // Default to false for now
		return 1
	}))
	L.SetField(eq, "is_task_activity_active", L.NewFunction(func(L *lua.LState) int {
		L.Push(lua.LBool(false))
		return 1
	}))

	L.SetField(eq, "zone_emote", L.NewFunction(func(L *lua.LState) int {
		// color := L.CheckInt(1)
		msg := L.CheckString(2)
		capture.Responses = append(capture.Responses, "[Zone Emote] "+msg)
		return 0
	}))

	L.SetField(eq, "world_emote", L.NewFunction(func(L *lua.LState) int {
		// color := L.CheckInt(1)
		msg := L.CheckString(2)
		capture.Responses = append(capture.Responses, "[World Emote] "+msg)
		return 0
	}))

	L.SetField(eq, "popup", L.NewFunction(func(L *lua.LState) int {
		title := L.CheckString(1)
		text := L.CheckString(2)
		id := 0
		if L.GetTop() >= 3 {
			id = L.CheckInt(3)
		}
		capture.Popups = append(capture.Popups, PopupInfo{Title: title, Text: text, ID: id})
		return 0
	}))

	L.SetField(eq, "message", L.NewFunction(func(L *lua.LState) int {
		// color := L.CheckInt(1)
		msg := L.CheckString(2)
		capture.Responses = append(capture.Responses, msg)
		return 0
	}))

	L.SetField(eq, "ChooseRandom", L.NewFunction(func(L *lua.LState) int {
		n := L.GetTop()
		if n == 0 {
			L.Push(lua.LNil)
			return 1
		}
		pick := rand.Intn(n) + 1
		L.Push(L.Get(pick))
		return 1
	}))
	L.SetField(eq, "RandomNumber", L.NewFunction(func(L *lua.LState) int {
		if table, ok := L.Get(1).(*lua.LTable); ok {
			if table.Len() == 0 {
				L.Push(lua.LNil)
			} else {
				L.Push(table.RawGetInt(rand.Intn(table.Len()) + 1))
			}
			return 1
		}
		low, high := L.CheckInt(1), L.CheckInt(2)
		if high < low {
			low, high = high, low
		}
		L.Push(lua.LNumber(low + rand.Intn(high-low+1)))
		return 1
	}))
	for _, name := range []string{"is_current_expansion_veil_of_alaris", "is_current_expansion_secrets_of_faydwer", "is_current_expansion_depths_of_darkhollow", "is_current_expansion_the_serpents_spine", "is_current_expansion_underfoot", "is_current_expansion_house_of_thule", "is_current_expansion_dragons_of_norrath", "is_dragons_of_norrath_enabled", "is_lost_dungeons_of_norrath_enabled"} {
		L.SetField(eq, name, L.NewFunction(func(L *lua.LState) int { L.Push(lua.LBool(true)); return 1 }))
	}
	L.SetField(eq, "is_the_ruins_of_kunark_enabled", L.NewFunction(func(L *lua.LState) int { L.Push(lua.LBool(true)); return 1 }))
	b.registerDeferredQuestAPIs(L, eq, capture)
	b.registerQuestGridAPIs(L, eq, capture, event)
	b.registerQuestNPCAttackAPI(L, eq, capture, event)
	L.SetField(eq, "attack", L.NewFunction(func(L *lua.LState) int {
		name := strings.TrimSpace(L.CheckString(1))
		if name == "" {
			L.RaiseError("eq.attack requires a player name")
			return 0
		}
		for _, request := range capture.Attacks {
			if strings.EqualFold(request.PlayerName, name) {
				return 0
			}
		}
		capture.Attacks = append(capture.Attacks, QuestAttackRequest{PlayerName: name})
		return 0
	}))
	L.SetField(eq, "SelfCast", L.NewFunction(func(L *lua.LState) int { capture.Spells = append(capture.Spells, L.CheckInt(1)); return 0 }))
	L.SetField(eq, "local_emote", L.NewFunction(func(L *lua.LState) int {
		if L.GetTop() >= 4 {
			capture.Responses = append(capture.Responses, L.CheckString(4))
		}
		return 0
	}))
	L.SetField(eq, "ZoneMarquee", L.NewFunction(func(L *lua.LState) int {
		if L.GetTop() >= 6 {
			capture.Popups = append(capture.Popups, PopupInfo{Text: L.CheckString(6)})
		}
		return 0
	}))
	L.SetField(eq, "update_task_activity", L.NewFunction(func(L *lua.LState) int {
		capture.Tasks = append(capture.Tasks, TaskAction{TaskID: L.CheckInt(1), Action: "step", StepID: L.CheckInt(2)})
		return 0
	}))
	L.SetField(eq, "set_data", L.NewFunction(func(L *lua.LState) int { return 0 }))
	L.SetField(eq, "get_data", L.NewFunction(func(L *lua.LState) int { L.Push(lua.LString("")); return 1 }))
	L.SetField(eq, "get_zone_time", L.NewFunction(func(L *lua.LState) int {
		table := L.NewTable()
		L.SetField(table, "zone_hour", lua.LNumber(12))
		L.SetField(table, "zone_minute", lua.LNumber(0))
		L.Push(table)
		return 1
	}))

	L.SetField(eq, "spawn2", L.NewFunction(captureSpawn(false)))
	L.SetField(eq, "unique_spawn", L.NewFunction(captureSpawn(true)))
	L.SetField(eq, "create_ground_object", L.NewFunction(func(L *lua.LState) int {
		decayMS := int64(300000)
		if L.GetTop() >= 6 {
			decayMS = int64(L.CheckNumber(6))
		}
		runtimeID := int64(len(capture.GroundItems) + 1)
		capture.GroundItems = append(capture.GroundItems, QuestGroundObjectRequest{
			RuntimeID: runtimeID,
			ItemID:    int32(L.CheckInt(1)),
			X:         float64(L.CheckNumber(2)),
			Y:         float64(L.CheckNumber(3)),
			Z:         float64(L.CheckNumber(4)),
			Heading:   float64(L.CheckNumber(5)),
			DecayMS:   decayMS,
		})
		L.Push(lua.LNumber(runtimeID))
		return 1
	}))

	L.SetField(eq, "depop", L.NewFunction(func(L *lua.LState) int {
		request := QuestDepopRequest{SpawnInstanceID: event.SpawnInstanceID}
		if L.GetTop() >= 1 {
			request.SpawnInstanceID = 0
			request.NPCTypeID = int32(L.CheckInt(1))
		}
		capture.Depops = append(capture.Depops, request)
		return 0
	}))

	L.SetField(eq, "depop_with_timer", L.NewFunction(func(L *lua.LState) int {
		request := QuestDepopRequest{SpawnInstanceID: event.SpawnInstanceID, WithTimer: true}
		if L.GetTop() >= 1 {
			request.SpawnInstanceID = 0
			request.NPCTypeID = int32(L.CheckInt(1))
		}
		capture.Depops = append(capture.Depops, request)
		return 0
	}))

	L.SetField(eq, "depop_all", L.NewFunction(func(L *lua.LState) int {
		request := QuestDepopRequest{All: true}
		if L.GetTop() >= 1 {
			request.NPCTypeID = int32(L.CheckInt(1))
		}
		capture.Depops = append(capture.Depops, request)
		return 0
	}))

	// Register Constants
	classTable := L.NewTable()
	L.SetField(eq, "Class", classTable)
	classes := map[string]int{
		"Warrior": 1, "Cleric": 2, "Paladin": 3, "Ranger": 4, "ShadowKnight": 5,
		"Druid": 6, "Monk": 7, "Bard": 8, "Rogue": 9, "Shaman": 10,
		"Necromancer": 11, "Wizard": 12, "Magician": 13, "Enchanter": 14,
		"Beastlord": 15, "Berserker": 16,
	}
	for name, id := range classes {
		L.SetField(classTable, name, lua.LNumber(id))
	}

	raceTable := L.NewTable()
	L.SetField(eq, "Race", raceTable)
	races := map[string]int{
		"Human": 1, "Barbarian": 2, "Erudite": 3, "WoodElf": 4, "HighElf": 5,
		"DarkElf": 6, "HalfElf": 7, "Dwarf": 8, "Troll": 9, "Ogre": 10,
		"Halfling": 11, "Gnome": 12, "Iksar": 13, "VahShir": 14, "Froglok": 15,
		"Drakkin": 16,
	}
	for name, id := range races {
		L.SetField(raceTable, name, lua.LNumber(id))
	}

	L.SetGlobal("ItemInst", L.NewFunction(func(L *lua.LState) int {
		ud := L.NewUserData()
		ud.Value = &ItemInstProxy{ID: 0, Valid: false}
		L.SetMetatable(ud, b.createItemMetatable(L))
		L.Push(ud)
		return 1
	}))
}

func (b *LuaBridge) registerMT(L *lua.LState) {
	mt := L.NewTable()
	L.SetGlobal("MT", mt)
	// Common Message Types from EQEMU
	constants := map[string]int{
		"White":     0,
		"SayEcho":   1,
		"Say":       2,
		"Tell":      3,
		"Group":     4,
		"Guild":     5,
		"Shout":     6,
		"Auction":   7,
		"OOC":       8,
		"Broadcast": 9,
		"Emote":     10,
		"Yellow":    258,
		"Red":       259,
		"Green":     260,
		"Cyan":      261,
		"Blue":      262,
	}
	for name, id := range constants {
		L.SetField(mt, name, lua.LNumber(id))
	}

	speakMode := L.NewTable()
	for name, id := range map[string]int{
		"Say": 1, "Emote": 2, "Shout": 3,
	} {
		L.SetField(speakMode, name, lua.LNumber(id))
	}
	L.SetGlobal("SpeakMode", speakMode)
}
