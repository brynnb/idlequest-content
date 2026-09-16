package quest

import "strings"

// IsQuestScriptExcludedFromIdleQuest returns true for enabled ProjectEQ quest
// scripts that are deliberately outside IdleQuest's current content scope.
//
// The Artisan cultural scripts are Dragons of Norrath-era "new cultural"
// tradeskill armor/book quests that live in many classic city zone folders in
// modern quest packs. IdleQuest is currently scoped to classic/Kunark content,
// so these should not appear in game quest loading or automated coverage.
//
// The Butcherblock Frostfell "A Gift for Tinam" scripts are also later live
// event/task content rooted in the Plane of Knowledge Frostfell flow, despite
// being located in a classic zone folder.
func IsQuestScriptExcludedFromIdleQuest(npcName, source string) bool {
	if strings.HasPrefix(npcName, "Artisan_") &&
		strings.Contains(source, "Newer Cultural Tradeskill Armor Quest") {
		return true
	}
	return strings.Contains(source, "Frostfell A Gift for Tinam")
}

// IsQuestScriptExcludedFromIdleQuestTests returns true for quest scripts that
// should not participate in automated turn-in coverage. This includes runtime
// content exclusions plus known non-classic/incomplete numeric scripts that can
// remain harmlessly present in the DB because players cannot reach them through
// current spawned NPCs.
func IsQuestScriptExcludedFromIdleQuestTests(zoneName, npcName, source string) bool {
	if IsQuestScriptExcludedFromIdleQuest(npcName, source) {
		return true
	}
	zoneName = strings.ToLower(strings.TrimSpace(zoneName))
	npcName = strings.TrimSpace(npcName)
	return (zoneName == "cazicthule" && npcName == "48255") ||
		(zoneName == "freporte" && npcName == "10000")
}
