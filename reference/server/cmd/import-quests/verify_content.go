package main

import (
	"context"
	"database/sql"
	"fmt"
	"idlequest/internal/contentscope"
	"idlequest/internal/quest"
	questoverrides "idlequest/internal/quest/overrides"
	"log"
)

// Compare maintained source, not an import timestamp: targeted imports and local
// edits can otherwise leave a partially updated database looking current.
func verifyMaintainedContent(ctx context.Context, db *sql.DB) error {
	policy, scripts, err := maintainedQuestPolicy()
	if err != nil {
		return err
	}
	modules, err := questoverrides.Modules()
	if err != nil {
		return err
	}
	if err := verifyContentSources(ctx, db, scripts, modules); err != nil {
		return err
	}
	return verifyQuestExclusions(ctx, db, policy)
}

func verifyContentSources(ctx context.Context, db *sql.DB, scripts []questoverrides.Script, modules []questoverrides.Module) error {
	failures := 0
	for _, script := range scripts {
		var source sql.NullString
		var enabled bool
		err := db.QueryRowContext(ctx, "SELECT lua_content,enabled FROM quests WHERE BINARY zone=? AND BINARY name=?", script.Zone, script.Name).Scan(&source, &enabled)
		expectedEnabled := script.Enabled && !contentscope.ExcludesQuest(script.Zone, script.Name)
		if err == sql.ErrNoRows || (err == nil && (!source.Valid || source.String != sanitizeUTF8(script.Lua) || enabled != expectedEnabled)) {
			log.Printf("Maintained quest differs or is missing: %s/%s", script.Zone, script.Name)
			failures++
		} else if err != nil {
			return err
		}
	}
	for _, module := range modules {
		var source string
		var enabled bool
		err := db.QueryRowContext(ctx, "SELECT lua_content,enabled FROM quest_lua_modules WHERE BINARY module_name=?", module.Name).Scan(&source, &enabled)
		if err == sql.ErrNoRows || (err == nil && (source != sanitizeUTF8(module.Lua) || enabled != module.Enabled)) {
			log.Printf("Maintained module differs or is missing: %s", module.Name)
			failures++
		} else if err != nil {
			return err
		}
	}
	if failures > 0 {
		return fmt.Errorf("%d maintained sources differ from the database; run the full quest import", failures)
	}
	log.Printf("Verified %d maintained quest scripts and %d modules against the database", len(scripts), len(modules))
	return nil
}

// Also inspect excluded upstream rows with no maintained source. Source hashes
// alone cannot detect one of these being enabled by an older import or edit.
func verifyQuestExclusions(ctx context.Context, db *sql.DB, policy quest.QuestContentPolicy) error {
	rows, err := db.QueryContext(ctx, "SELECT zone,name FROM quests WHERE enabled=1")
	if err != nil {
		return err
	}
	defer rows.Close()
	var conflicts []string
	for rows.Next() {
		var zone, name string
		if err := rows.Scan(&zone, &name); err != nil {
			return err
		}
		key := zone + "/" + name
		if !isQuestSourceDirectory(zone) {
			conflicts = append(conflicts, key)
			continue
		}
		if rule, excluded := policy.Quests[key]; excluded && rule.ReviewedOverride == "" {
			conflicts = append(conflicts, key)
		}
	}
	if err := rows.Err(); err != nil {
		return err
	}
	if len(conflicts) > 0 {
		return fmt.Errorf("excluded quest rows are enabled: %v", conflicts)
	}
	return nil
}
