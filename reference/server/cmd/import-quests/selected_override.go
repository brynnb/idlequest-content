package main

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"fmt"
	"log"
	"strings"
	"time"

	"idlequest/internal/contentscope"
	questoverrides "idlequest/internal/quest/overrides"
)

// Targeted repair uses the same embedded source and sanitization as the full
// importer. It intentionally cannot add rows, enable content, import modules,
// or apply global fixups: those require the full reviewed content workflow.
func selectBundledOverride(scripts []questoverrides.Script, key string) (questoverrides.Script, error) {
	var selected questoverrides.Script
	count := 0
	for _, script := range scripts {
		if script.Zone+"/"+script.Name == key {
			selected = script
			count++
		}
	}
	if count != 1 {
		return selected, fmt.Errorf("expected one exact bundled override for %q, found %d", key, count)
	}
	if !isQuestSourceDirectory(selected.Zone) || strings.TrimSpace(selected.Lua) == "" {
		return selected, fmt.Errorf("invalid quest override %q", key)
	}
	selected.Lua = sanitizeUTF8(selected.Lua)
	return selected, nil
}

func runSelectedOverride(ctx context.Context, db *sql.DB, key string, apply bool) error {
	scripts, err := questoverrides.Scripts()
	if err != nil {
		return err
	}
	script, err := selectBundledOverride(scripts, key)
	if err != nil {
		return err
	}
	before, err := updateSelectedOverride(ctx, db, script, apply)
	if err != nil {
		return err
	}
	log.Printf("Selected override %s origin=%s apply=%t changed=%t before_sha256=%x after_sha256=%x",
		key, script.Origin, apply, before != script.Lua, sha256.Sum256([]byte(before)), sha256.Sum256([]byte(script.Lua)))
	return nil
}

func updateSelectedOverride(ctx context.Context, db *sql.DB, script questoverrides.Script, apply bool) (string, error) {
	if contentscope.ExcludesQuest(script.Zone, script.Name) {
		return "", fmt.Errorf("quest %s/%s is outside the supported content era", script.Zone, script.Name)
	}
	if !script.Enabled {
		return "", fmt.Errorf("disabled maintained sources require a reviewed content migration/full import")
	}
	ctx, cancel := context.WithTimeout(ctx, 10*time.Second)
	defer cancel()
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return "", err
	}
	defer tx.Rollback()
	var zone, name string
	var before sql.NullString
	var enabled bool
	err = tx.QueryRowContext(ctx, `SELECT zone, name, lua_content, enabled FROM quests
 WHERE zone = ? AND name = ? FOR UPDATE`, script.Zone, script.Name).Scan(&zone, &name, &before, &enabled)
	if err != nil {
		return "", fmt.Errorf("read existing quest %s/%s: %w", script.Zone, script.Name, err)
	}
	// MySQL's normal collation is case-insensitive; don't silently select a
	// differently spelled record or undo an explicit content exclusion.
	if zone != script.Zone || name != script.Name || !enabled {
		return "", fmt.Errorf("target must be an exact existing enabled quest: %s/%s", script.Zone, script.Name)
	}
	if !apply {
		if !before.Valid {
			log.Printf("Selected override %s/%s has NULL existing Lua; before hash represents empty content", zone, name)
		}
		return before.String, nil
	}
	_, err = tx.ExecContext(ctx, `UPDATE quests SET lua_content = ?, has_say_event = ?
 WHERE zone = ? AND name = ? AND enabled = 1`, script.Lua, script.HasSayEvent, script.Zone, script.Name)
	if err != nil {
		return "", err
	}
	return before.String, tx.Commit()
}
