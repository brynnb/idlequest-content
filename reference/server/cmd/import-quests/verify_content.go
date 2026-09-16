package main

import (
	"context"
	"database/sql"
	"fmt"
	"idlequest/internal/contentscope"
	questoverrides "idlequest/internal/quest/overrides"
	"log"
)

// Compare maintained source, not an import timestamp: targeted imports and local
// edits can otherwise leave a partially updated database looking current.
func verifyMaintainedContent(ctx context.Context, db *sql.DB) error {
	scripts, err := questoverrides.Scripts()
	if err != nil {
		return err
	}
	modules, err := questoverrides.Modules()
	if err != nil {
		return err
	}
	return verifyContentSources(ctx, db, scripts, modules)
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
