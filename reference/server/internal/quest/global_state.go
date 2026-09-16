package quest

import (
	"strconv"
	"strings"
)

// Match the same local-or-global scope visible to this quest invocation.
// EQEmu QuestManager::delglobal applies all three scope dimensions. Omitting
// NPC/zone can erase unrelated progress; omitting zero excludes shared flags.
const deleteQuestGlobalSQL = `DELETE FROM quest_globals
WHERE name=? AND (npcid=0 OR npcid=?) AND (charid=0 OR charid=?) AND (zoneid=0 OR zoneid=?)`

// EQEmu QuestManager::QGVarDuration uses seconds/minutes/hours/days/years
// (31556926 seconds per year), with F meaning SQL NULL. Empty durations are
// retained as permanent for existing internal captures that omit the field.
// Source: https://github.com/EQEmu/EQEmu/blob/master/zone/questmgr.cpp
func questGlobalExpiration(duration string, now int64) *int64 {
	if duration == "" || strings.EqualFold(duration, "F") {
		return nil
	}
	seconds := int64(0)
	value, err := strconv.ParseInt(duration[1:], 10, 32)
	if err == nil {
		switch duration[0] {
		case 'S', 's':
			seconds = value
		case 'M', 'm':
			seconds = value * 60
		case 'H', 'h':
			seconds = value * 3600
		case 'D', 'd':
			seconds = value * 86400
		case 'Y', 'y':
			seconds = value * 31556926
		}
	}
	// Unknown/invalid formats have zero duration in EQEmu, not forever.
	expires := now + seconds
	return &expires
}
