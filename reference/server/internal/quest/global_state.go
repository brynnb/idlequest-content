package quest

import (
	"context"
	"fmt"
	"reflect"
	"sort"
	"strconv"
	"strings"
	"time"

	"github.com/go-jet/jet/v2/stmtcache"
	"idlequest/internal/db/jetgen/eqgo/model"
)

// The exact visible, unexpired rows that backed a production Lua invocation.
// This is a read preimage, not a second quest-state store. Retaining scope and
// expiry distinguishes an inherited flag from a same-named personal one.
type QuestGlobalSnapshot struct{ Rows []model.QuestGlobals }

func validateQuestGlobalPreimagesTx(ctx context.Context, tx *stmtcache.Tx, characterID uint32, npcID, zoneID int32, capture *QuestCapture) error {
	if capture.GlobalSnapshot == nil || len(capture.Globals) == 0 {
		return nil
	}
	names := make([]string, 0, len(capture.Globals))
	for name := range capture.Globals {
		names = append(names, name)
	}
	sort.Strings(names)
	// Lock every written name before changing any of them. Two players claiming
	// a shared invitation cannot both delete it and receive its reward. Missing
	// rows retain InnoDB's normal range-lock/duplicate-key behavior; a deadlock is
	// an aborted quest transaction, never permission to grant without the flag.
	for _, name := range names {
		rows, err := tx.QueryContext(ctx, `SELECT charid,npcid,zoneid,name,value,expdate FROM quest_globals
WHERE name=? AND charid IN(0,?) AND npcid IN(0,?) AND zoneid IN(0,?)
ORDER BY charid,npcid,zoneid FOR UPDATE`, name, characterID, npcID, zoneID)
		if err != nil {
			return fmt.Errorf("lock quest global %s: %w", name, err)
		}
		var current []model.QuestGlobals
		for rows.Next() {
			var r model.QuestGlobals
			if err := rows.Scan(&r.Charid, &r.Npcid, &r.Zoneid, &r.Name, &r.Value, &r.Expdate); err != nil {
				rows.Close()
				return err
			}
			if r.Expdate == nil || int64(*r.Expdate) > time.Now().Unix() {
				current = append(current, r)
			}
		}
		err = rows.Err()
		rows.Close()
		if err != nil {
			return err
		}
		var expected []model.QuestGlobals
		for _, r := range capture.GlobalSnapshot.Rows {
			if r.Name == name {
				expected = append(expected, r)
			}
		}
		if !reflect.DeepEqual(expected, current) {
			return fmt.Errorf("quest global %s changed or expired before settlement", name)
		}
	}
	return nil
}

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
