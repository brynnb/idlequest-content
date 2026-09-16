# Maintained Lua modules

Reviewed module replacements go here using the same relative module name as
upstream `lua_modules/`. The importer applies these after upstream modules.
Original upstream files remain untouched. Optional `-- enabled: false` in the
leading comment header preserves an intentionally disabled module on reimport.
