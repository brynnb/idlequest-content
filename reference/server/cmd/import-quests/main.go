package main

import (
	"context"
	"database/sql"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
	"unicode/utf8"

	_ "github.com/go-sql-driver/mysql"

	"idlequest/internal/config"
	"idlequest/internal/contentscope"
	"idlequest/internal/quest"
	questoverrides "idlequest/internal/quest/overrides"
)

func main() {
	verify := flag.Bool("verify", false, "Read-only check that maintained Lua scripts and modules match the database")
	overrideKey := flag.String("override", "", "Review one existing enabled quest from its bundled override (zone/exact name); does not import modules or run global fixups")
	applyOverride := flag.Bool("apply", false, "Apply the selected --override; without this flag it is read-only")
	flag.Parse()
	if flag.NArg() != 0 || (*applyOverride && *overrideKey == "") || (*verify && (*applyOverride || *overrideKey != "")) {
		log.Fatal("expected --override zone/name [--apply], or no flags for the full import")
	}
	if *overrideKey != "" && os.Getenv("IMPORT_ONLY_MODULES") == "1" {
		log.Fatal("--override cannot be combined with IMPORT_ONLY_MODULES")
	}
	cfg, err := config.Get()
	if err != nil {
		log.Fatalf("failed to read config: %v", err)
	}

	dsn := fmt.Sprintf("%s:%s@tcp(%s:%d)/%s?parseTime=true",
		cfg.DBUser, cfg.DBPass, cfg.DBHost, cfg.DBPort, "eqgo")

	db, err := sql.Open("mysql", dsn)
	if err != nil {
		log.Fatalf("failed to connect to db: %v", err)
	}
	defer db.Close()
	if *verify {
		if err := verifyMaintainedContent(context.Background(), db); err != nil {
			log.Fatal(err)
		}
		return
	}
	if *overrideKey != "" {
		if err := runSelectedOverride(context.Background(), db, *overrideKey, *applyOverride); err != nil {
			log.Fatal(err)
		}
		return
	}

	if _, _, err := maintainedQuestPolicy(); err != nil {
		log.Fatal(err)
	}

	questDir := "internal/quest/upstream/projecteq"
	absQuestDir, err := filepath.Abs(questDir)
	if err != nil {
		log.Fatalf("failed to get absolute path for %s: %v", questDir, err)
	}

	log.Printf("Importing quests from: %s", absQuestDir)

	sources, err := collectQuestSources(absQuestDir)
	if err != nil {
		log.Fatalf("failed to discover quest sources: %v", err)
	}

	ctx := context.Background()
	totalImported := 0
	dialogueScripts := 0
	moduleScripts := 0
	if imported, err := importLuaModules(ctx, db, filepath.Join(absQuestDir, "lua_modules")); err != nil {
		log.Fatalf("failed to import lua modules: %v", err)
	} else {
		moduleScripts = imported
	}
	if imported, err := importMaintainedLuaModules(ctx, db); err != nil {
		log.Fatalf("failed to import maintained modules: %v", err)
	} else {
		moduleScripts += imported
	}
	if os.Getenv("IMPORT_ONLY_MODULES") == "1" {
		log.Printf("✅ Finished! Lua modules: %d", moduleScripts)
		return
	}

	totalImported, dialogueScripts, err = importQuestSources(ctx, db, sources)
	if err != nil {
		log.Fatal(err)
	}

	if err := applyIdleQuestQuestFixups(ctx, db); err != nil {
		log.Fatalf("failed to apply IdleQuest quest fixups: %v", err)
	}

	log.Printf("✅ Finished! Total LUA scripts: %d, Dialogue scripts: %d, Lua modules: %d", totalImported, dialogueScripts, moduleScripts)
}

func applyIdleQuestQuestFixups(ctx context.Context, db *sql.DB) error {
	policy, scripts, err := maintainedQuestPolicy()
	if err != nil {
		return err
	}
	if err := disableNonQuestDirectoryRows(ctx, db); err != nil {
		return err
	}
	// Disable out-of-scope upstream scripts before applying IdleQuest's curated
	// replacements. A maintained Classic/Kunark-only override must take
	// precedence over a mixed-era upstream script at the same zone/name.
	if _, err := applyQuestContentExclusions(ctx, db, policy); err != nil {
		return err
	}
	if _, err := db.ExecContext(ctx, `
UPDATE quests
SET enabled = 0
WHERE lua_content LIKE '%Come to find out about the Wayfarers Brotherhood%'
   OR lua_content LIKE '%qglobals.Wayfarer%'
   OR lua_content LIKE '%Mistmoore''s Catacombs%'
   OR lua_content LIKE '%Miragul''s Menagerie%'
   OR lua_content LIKE '%Deepest Guk%'
   OR lua_content LIKE '%expedition =%'
   OR lua_content LIKE '%Lost Dungeons of Norrath%'
   OR lua_content LIKE '%Wayfarer camp%'
   OR lua_content LIKE '%Wayfarers Brotherhood welcomes%'
   OR lua_content LIKE '%portal to Luclin%'
   OR lua_content LIKE '%Journey: Luclin%'
   OR lua_content LIKE '%MovePC(152%'
   OR lua_content REGEXP 'nexus_[[:alnum:]_]'
   OR lua_content REGEXP 'spire_[[:alnum:]_]'
   OR lua_content LIKE '%Newbie Armor%'
   OR lua_content LIKE '%Epic 1.5%'
   OR lua_content LIKE '%epic 1.5%'
   OR lua_content LIKE '%epic15%'
   OR lua_content LIKE '%ranger_epic15_pre%'
   OR lua_content LIKE '%Cleric 1.5%'
   OR lua_content LIKE '%cleric 1.5%'
   OR lua_content LIKE '%berserk_epic%'
   OR lua_content LIKE '%Fatestealer%'
   OR lua_content LIKE '%Guktan%'
   OR lua_content LIKE '%dismal influences of Discord%'`); err != nil {
		return err
	}
	if _, err := db.ExecContext(ctx, `
UPDATE quests
SET enabled = 0
WHERE name LIKE 'Artisan\_%'
  AND lua_content LIKE '%Newer Cultural Tradeskill Armor Quest%'`); err != nil {
		return err
	}
	if _, err := db.ExecContext(ctx, `
UPDATE quests
SET enabled = 0
WHERE lua_content LIKE '%Newer Cultural Tradeskill Armor Quest%'`); err != nil {
		return err
	}
	if _, err := db.ExecContext(ctx, `
UPDATE quests
SET enabled = 0
WHERE lua_content LIKE '%Frostfell A Gift for Tinam%'`); err != nil {
		return err
	}
	if _, err := db.ExecContext(ctx, `
DELETE FROM quests
WHERE zone = 'airplane'
  AND name = 'Duggas_Helpyre'`); err != nil {
		return err
	}
	// Text heuristics above classify imported upstream content, including its
	// comments. Reviewed overrides must run last: a comment explaining removal
	// of epic 1.5 content must not disable an otherwise valid epic 1.0 quest.
	if _, err := writeBundledLuaOverrides(ctx, db, scripts); err != nil {
		return err
	}
	return contentscope.ApplyQuestExclusions(ctx, db)
}

// Source and policy are validated together before any importer writes.
func maintainedQuestPolicy() (quest.QuestContentPolicy, []questoverrides.Script, error) {
	policy, err := quest.LoadQuestContentPolicy()
	if err != nil {
		return policy, nil, err
	}
	scripts, err := questoverrides.Scripts()
	if err != nil {
		return policy, nil, err
	}
	return policy, scripts, policy.ValidateOverrides(scripts)
}

func applyQuestContentExclusions(ctx context.Context, db *sql.DB, policy quest.QuestContentPolicy) (int, error) {
	applied := 0
	for key := range policy.Quests {
		zone, name, ok := strings.Cut(key, "/")
		if !ok || zone == "" || name == "" {
			return applied, fmt.Errorf("invalid quest content exclusion key %q; expected zone/name", key)
		}
		result, err := db.ExecContext(ctx, `
UPDATE quests
SET enabled = 0
WHERE zone = ? AND name = ?`, zone, name)
		if err != nil {
			return applied, err
		}
		if affected, err := result.RowsAffected(); err == nil && affected > 0 {
			applied++
		}
	}
	if applied > 0 {
		log.Printf("Applied %d quest content exclusions from the embedded ledger", applied)
	}
	return applied, nil
}

func importBundledLuaOverrides(ctx context.Context, db *sql.DB) (int, error) {
	_, scripts, err := maintainedQuestPolicy()
	if err != nil {
		return 0, err
	}
	return writeBundledLuaOverrides(ctx, db, scripts)
}

func writeBundledLuaOverrides(ctx context.Context, db *sql.DB, scripts []questoverrides.Script) (int, error) {
	for _, script := range scripts {
		if _, err := db.ExecContext(ctx, `
			INSERT INTO quests (zone, name, lua_content, has_say_event, enabled)
			VALUES (?, ?, ?, ?, ?)
			ON DUPLICATE KEY UPDATE
				lua_content = VALUES(lua_content),
				has_say_event = VALUES(has_say_event),
				enabled = VALUES(enabled)`,
			script.Zone, script.Name, sanitizeUTF8(script.Lua), script.HasSayEvent, script.Enabled); err != nil {
			return 0, err
		}
	}
	return len(scripts), nil
}

func importLuaModules(ctx context.Context, db *sql.DB, modulesDir string) (int, error) {
	imported := 0
	err := filepath.Walk(modulesDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() || filepath.Ext(info.Name()) != ".lua" {
			return nil
		}
		relative, err := filepath.Rel(modulesDir, path)
		if err != nil {
			return err
		}
		moduleName := strings.TrimSuffix(filepath.ToSlash(relative), ".lua")
		content, err := ioutil.ReadFile(path)
		if err != nil {
			log.Printf("Warning: failed to read module %s: %v", moduleName, err)
			return nil
		}
		_, err = db.ExecContext(ctx, `
			INSERT INTO quest_lua_modules (module_name, lua_content, enabled)
			VALUES (?, ?, 1)
			ON DUPLICATE KEY UPDATE lua_content=VALUES(lua_content), enabled=1`,
			moduleName, sanitizeUTF8(string(content)))
		if err != nil {
			log.Printf("Error inserting lua module %s: %v", moduleName, err)
			return nil
		}
		imported++
		return nil
	})
	return imported, err
}

func sanitizeUTF8(s string) string {
	if utf8.ValidString(s) {
		return s
	}
	v := make([]rune, 0, len(s))
	for i, r := range s {
		if r == utf8.RuneError {
			_, size := utf8.DecodeRuneInString(s[i:])
			if size == 1 {
				continue
			}
		}
		v = append(v, r)
	}
	return string(v)
}
