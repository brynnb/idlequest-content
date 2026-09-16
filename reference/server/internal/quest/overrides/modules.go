package overrides

import (
	"embed"
	"io/fs"
	"strings"
)

//go:embed modules
var moduleFiles embed.FS

type Module struct {
	Name, Lua string
	Enabled   bool
}

func Modules() ([]Module, error) { return readModules(moduleFiles) }

func readModules(files fs.FS) ([]Module, error) {
	var result []Module
	err := fs.WalkDir(files, "modules", func(file string, entry fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if entry.IsDir() || !strings.HasSuffix(file, ".lua") {
			return nil
		}
		content, err := fs.ReadFile(files, file)
		if err != nil {
			return err
		}
		enabled, err := sourceEnabled(string(content))
		if err != nil {
			return err
		}
		result = append(result, Module{Name: strings.TrimSuffix(strings.TrimPrefix(file, "modules/"), ".lua"), Lua: string(content), Enabled: enabled})
		return nil
	})
	return result, err
}
