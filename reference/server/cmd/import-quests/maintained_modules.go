package main

import (
	"context"
	"database/sql"
	questoverrides "idlequest/internal/quest/overrides"
)

func importMaintainedLuaModules(ctx context.Context, db *sql.DB) (int, error) {
	modules, err := questoverrides.Modules()
	if err != nil {
		return 0, err
	}
	return writeMaintainedLuaModules(ctx, db, modules)
}

func writeMaintainedLuaModules(ctx context.Context, db *sql.DB, modules []questoverrides.Module) (int, error) {
	for _, module := range modules {
		_, err := db.ExecContext(ctx, `INSERT INTO quest_lua_modules(module_name,lua_content,enabled) VALUES(?,?,?)
 ON DUPLICATE KEY UPDATE lua_content=VALUES(lua_content),enabled=VALUES(enabled)`, module.Name, sanitizeUTF8(module.Lua), module.Enabled)
		if err != nil {
			return 0, err
		}
	}
	return len(modules), nil
}
