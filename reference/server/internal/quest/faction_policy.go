package quest

import (
	"idlequest/internal/combat"

	lua "github.com/yuin/gopher-lua"
)

// Quest access deliberately ignores earned faction. AutoLevel can damage
// reputations incidentally, so both EQEmu's ranked and numeric quest APIs must
// see the same friendly policy. Do not alter persisted faction, con messages,
// merchants, or combat hostility to implement this convenience.
//
// Use the existing faction system's maximum, not an epic-specific threshold.
// Class, level, item and explicit quest-state checks remain authoritative.
func (p *PlayerProxy) questFactionStanding(L *lua.LState) int {
	L.Push(lua.LNumber(combat.FactionAlly))
	return 1
}

func (p *PlayerProxy) GetCharacterFactionLevel(L *lua.LState) int {
	L.CheckInt(2) // Preserve the script API's argument validation.
	L.Push(lua.LNumber(combat.FactionMaxValue))
	return 1
}

func (p *PlayerProxy) GetModCharacterFactionLevel(L *lua.LState) int {
	return p.GetCharacterFactionLevel(L)
}
