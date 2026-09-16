package overrides

import (
	"embed"
	"fmt"
	"io/fs"
	"path"
	"strings"
)

// luaFiles contains IdleQuest-maintained Lua conversions and overrides.
//
// These files are the source of truth for converted ProjectEQ Perl quest
// scripts that should be upserted into the runtime quests table after the
// upstream ProjectEQ Lua import has completed.
//
//go:embed lua/converted-perl/*/*.lua lua/modified-upstream/*/*.lua lua/idlequest-authored/*/*.lua
var luaFiles embed.FS

type Script struct {
	Zone        string
	Name        string
	Origin      string
	Lua         string
	HasSayEvent bool
	Enabled     bool
}

// Enabled is authored with the source so a later full import cannot accidentally
// reactivate a reviewed disabled script. Existing scripts default to enabled.
func sourceEnabled(source string) (bool, error) {
	enabled := true
	for _, line := range strings.Split(source, "\n") {
		text := strings.TrimSpace(line)
		if strings.HasPrefix(text, "-- enabled:") {
			switch strings.TrimSpace(strings.TrimPrefix(text, "-- enabled:")) {
			case "true":
				enabled = true
			case "false":
				enabled = false
			default:
				return false, fmt.Errorf("invalid enabled header: %s", text)
			}
		}
		if text != "" && !strings.HasPrefix(text, "--") {
			break
		}
	}
	return enabled, nil
}

func Scripts() ([]Script, error) {
	var scripts []Script
	if err := fs.WalkDir(luaFiles, "lua", func(filePath string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() || path.Ext(filePath) != ".lua" {
			return nil
		}
		parts := strings.Split(filePath, "/")
		if len(parts) != 4 {
			return nil
		}
		content, err := luaFiles.ReadFile(filePath)
		if err != nil {
			return err
		}
		lua := string(content)
		enabled, err := sourceEnabled(lua)
		if err != nil {
			return fmt.Errorf("%s: %w", filePath, err)
		}
		name := strings.TrimSuffix(parts[3], ".lua")
		for _, line := range strings.Split(lua, "\n") {
			trimmed := strings.TrimSpace(line)
			if strings.HasPrefix(trimmed, "-- name:") {
				if explicitName := strings.TrimSpace(strings.TrimPrefix(trimmed, "-- name:")); explicitName != "" {
					name = explicitName
				}
				break
			}
			if trimmed != "" && !strings.HasPrefix(trimmed, "--") {
				break
			}
		}
		lowerLua := strings.ToLower(lua)
		scripts = append(scripts, Script{
			Origin:      parts[1],
			Zone:        parts[2],
			Name:        name,
			Lua:         lua,
			HasSayEvent: strings.Contains(lowerLua, "event_say"),
			Enabled:     enabled,
		})
		return nil
	}); err != nil {
		return nil, err
	}
	return scripts, nil
}
