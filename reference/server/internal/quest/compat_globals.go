package quest

import (
	"fmt"
	"strings"

	lua "github.com/yuin/gopher-lua"
)

func (b *LuaBridge) registerQuestCompatibilityGlobals(L *lua.LState, capture *QuestCapture, event *LuaEvent) {
	bit := L.NewTable()
	L.SetField(bit, "bor", L.NewFunction(func(L *lua.LState) int {
		value := 0
		for i := 1; i <= L.GetTop(); i++ {
			value |= L.CheckInt(i)
		}
		L.Push(lua.LNumber(value))
		return 1
	}))
	L.SetField(bit, "lshift", L.NewFunction(func(L *lua.LState) int { L.Push(lua.LNumber(L.CheckInt(1) << L.CheckInt(2))); return 1 }))
	L.SetGlobal("bit", bit)
	if loaded, ok := L.GetField(L.Get(lua.RegistryIndex), "_LOADED").(*lua.LTable); ok {
		L.SetField(loaded, "bit", bit)
	}

	special := L.NewTable()
	values := map[string]int{
		"immune_melee": 19, "immune_magic": 20, "immune_fleeing": 21,
		"immune_melee_except_bane": 22, "immune_melee_except_magical": 23,
		"immune_aggro": 24, "immune_aggro_on": 25, "no_harm_from_client": 35,
	}
	for name, value := range values {
		L.SetField(special, name, lua.LNumber(value))
	}
	L.SetGlobal("SpecialAbility", special)

	bodyType := L.NewTable()
	for name, value := range map[string]int{
		"Humanoid": 1, "Lycanthrope": 2, "Undead": 3, "Giant": 4,
		"Construct": 5, "Extraplanar": 6, "Magical": 7, "SummonedUndead": 8,
		"RaidGiant": 9, "NoTarget": 11, "Vampire": 12, "AtenhaRa": 13,
		"GreaterAkheva": 14, "KhatiSha": 15, "Seru": 16, "DrazNurakk": 17,
		"Zek": 18, "Luggald": 19, "Animal": 21, "Insect": 22, "Monster": 23,
		"Summoned": 24, "Plant": 25, "Dragon": 26, "Summoned2": 27, "Summoned3": 28,
	} {
		L.SetField(bodyType, name, lua.LNumber(value))
	}
	L.SetGlobal("BodyType", bodyType)
	L.SetGlobal("BT", bodyType)

	slot := L.NewTable()
	for name, value := range map[string]int{"Charm": 0, "Ear1": 1, "Head": 2, "Face": 3, "Ear2": 4, "Neck": 5, "Shoulders": 6, "Arms": 7, "Back": 8, "Wrist1": 9, "Wrist2": 10, "Range": 11, "Hands": 12, "Primary": 13, "Secondary": 14, "Finger1": 15, "Finger2": 16, "Chest": 17, "Legs": 18, "Feet": 19, "Waist": 20, "Ammo": 21} {
		L.SetField(slot, name, lua.LNumber(value))
	}
	L.SetGlobal("Slot", slot)

	inventoryWhere := L.NewTable()
	for name, value := range map[string]int{
		"Worn": 0x01, "Personal": 0x02, "Bank": 0x04,
		"SharedBank": 0x08, "Trading": 0x10, "Cursor": 0x20,
	} {
		L.SetField(inventoryWhere, name, lua.LNumber(value))
	}
	L.SetGlobal("InventoryWhere", inventoryWhere)

	instance := L.NewTable()
	for name, value := range map[string]int{
		"ikkinz_chambers_of_singular_might": 0, "ikkinz_chambers_of_twin_struggles": 1,
		"ikkinz_chambers_of_the_tri_fates": 2, "ikkinz_chambers_of_righteousness": 3,
		"ikkinz_chambers_of_glorification": 4, "ikkinz_chambers_of_transcendence": 5,
		"ikkinz_chambers_of_destruction": 6,
	} {
		L.SetField(instance, name, lua.LNumber(value))
	}
	L.SetGlobal("Instance", instance)
	L.SetGlobal("instance_version", instance)

	plugin := L.NewTable()
	L.SetField(plugin, "soulbinder_say", L.NewFunction(func(L *lua.LState) int {
		text := ""
		if L.GetTop() >= 1 {
			text = L.CheckString(1)
		}
		lower := strings.ToLower(text)
		playerName := "traveler"
		if event != nil && event.Player != nil && event.Player.Name != "" {
			playerName = event.Player.Name
		}
		if strings.Contains(lower, "hail") {
			capture.Responses = append(capture.Responses, fmt.Sprintf("Greetings, %s. When a hero of our world is slain, their soul returns to the place it was last bound and the body is reincarnated. As a member of the Order of Eternity, it is my duty to [bind your soul] to this location if that is your wish.", playerName))
		} else if strings.Contains(lower, "bind") && strings.Contains(lower, "soul") {
			// Binding is executed by the typed Bind request. Do not also claim
			// an unexecuted legacy spell effect for the same action.
			capture.Binds = append(capture.Binds, QuestBindRequest{})
			capture.Responses = append(capture.Responses, "You feel yourself bind to the area.")
		}
		return 0
	}))
	L.SetGlobal("plugin", plugin)
}
