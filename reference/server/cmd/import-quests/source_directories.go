package main

import (
	"context"
	"database/sql"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
)

// These repository directories contain tools/modules, not zone NPC handlers.
// Keep the import filter and legacy-row cleanup derived from the same list.
// Do not include encounters: encounter modules require a separate scope audit.
var nonQuestSourceDirectories = []string{".git", "lua_modules", "plugins", "utility"}

func isQuestSourceDirectory(name string) bool {
	if isVersionDirectory(name) {
		return false
	}
	for _, excluded := range nonQuestSourceDirectories {
		if name == excluded {
			return false
		}
	}
	return true
}

func isVersionDirectory(name string) bool {
	if len(name) < 2 || name[0] != 'v' {
		return false
	}
	for _, c := range name[1:] {
		if c < '0' || c > '9' {
			return false
		}
	}
	return true
}

type questSource struct {
	Zone, Name, Path string
}

// ProjectEQ's v0 is a zone version, not a zone name. IdleQuest uses the
// original zone population; later v1 revamps must not replace classic handlers.
// Reject ambiguous root/v0 duplicates rather than silently picking one. Bundled
// reviewed overrides are still applied after this upstream import.
func collectQuestSources(root string) ([]questSource, error) {
	zones, err := os.ReadDir(root)
	if err != nil {
		return nil, err
	}
	var sources []questSource
	for _, zone := range zones {
		if !zone.IsDir() || !isQuestSourceDirectory(zone.Name()) {
			continue
		}
		seen := map[string]string{}
		for _, directory := range []string{filepath.Join(root, zone.Name()), filepath.Join(root, zone.Name(), "v0")} {
			files, err := os.ReadDir(directory)
			if os.IsNotExist(err) && filepath.Base(directory) == "v0" {
				continue
			}
			if err != nil {
				return nil, err
			}
			for _, file := range files {
				if file.IsDir() || filepath.Ext(file.Name()) != ".lua" || file.Name() == "default.lua" {
					continue
				}
				name := strings.TrimSuffix(file.Name(), ".lua")
				path := filepath.Join(directory, file.Name())
				if previous, exists := seen[name]; exists {
					return nil, fmt.Errorf("ambiguous quest source %s/%s: %s and %s", zone.Name(), name, previous, path)
				}
				seen[name] = path
				sources = append(sources, questSource{Zone: zone.Name(), Name: name, Path: path})
			}
		}
	}
	sort.Slice(sources, func(i, j int) bool { return sources[i].Zone+"/"+sources[i].Name < sources[j].Zone+"/"+sources[j].Name })
	return sources, nil
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
	_, err := db.ExecContext(ctx, "UPDATE quests SET enabled = 0 WHERE enabled <> 0 AND (zone IN ("+strings.Join(placeholders, ",")+") OR zone REGEXP '^v[0-9]+$')", args...)
	if err != nil {
		return fmt.Errorf("disable non-quest source directories: %w", err)
	}
	return nil
}

func importQuestSources(ctx context.Context, db *sql.DB, sources []questSource) (int, int, error) {
	imported, dialogue := 0, 0
	for _, source := range sources {
		content, err := os.ReadFile(source.Path)
		if err != nil {
			return imported, dialogue, err
		}
		lua := sanitizeUTF8(string(content))
		hasSay := strings.Contains(strings.ToLower(lua), "event_say")
		_, err = db.ExecContext(ctx, `INSERT INTO quests (zone,name,lua_content,has_say_event,enabled)
   VALUES (?,?,?,?,1) ON DUPLICATE KEY UPDATE lua_content=VALUES(lua_content),has_say_event=VALUES(has_say_event),enabled=1`,
			source.Zone, source.Name, lua, hasSay)
		if err != nil {
			return imported, dialogue, fmt.Errorf("import %s/%s: %w", source.Zone, source.Name, err)
		}
		imported++
		if hasSay {
			dialogue++
		}
	}
	return imported, dialogue, nil
}
