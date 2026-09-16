package main

import (
	"context"
	"database/sql"
	"fmt"
	"strings"
)

// These repository directories contain tools/modules, not zone NPC handlers.
// Keep the import filter and legacy-row cleanup derived from the same list.
// Do not include encounters: encounter modules require a separate scope audit.
var nonQuestSourceDirectories = []string{".git", "lua_modules", "plugins", "utility"}

func isQuestSourceDirectory(name string) bool {
	for _, excluded := range nonQuestSourceDirectories {
		if name == excluded {
			return false
		}
	}
	return true
}

type questSourceExecutor interface {
	ExecContext(context.Context, string, ...any) (sql.Result, error)
}

func disableNonQuestDirectoryRows(ctx context.Context, db questSourceExecutor) error {
	placeholders := make([]string, len(nonQuestSourceDirectories))
	args := make([]any, len(nonQuestSourceDirectories))
	for i, name := range nonQuestSourceDirectories {
		placeholders[i], args[i] = "?", name
	}
	// Preserve historical source text for provenance; only remove runtime eligibility.
	_, err := db.ExecContext(ctx, "UPDATE quests SET enabled = 0 WHERE enabled <> 0 AND zone IN ("+strings.Join(placeholders, ",")+")", args...)
	if err != nil {
		return fmt.Errorf("disable non-quest source directories: %w", err)
	}
	return nil
}
