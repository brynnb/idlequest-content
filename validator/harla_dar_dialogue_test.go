package main

import (
	"os"
	"testing"

	lua "github.com/yuin/gopher-lua"
)

func TestHarlaDarSeenWhoDialogue(t *testing.T) {
	script := os.Getenv("HARLA_SCRIPT")
	if script == "" {
		script = "../changes/westwastes-harla-dar-dialogue/Harla_Dar.lua"
	}
	source, err := os.ReadFile(script)
	if err != nil {
		t.Fatal(err)
	}
	state := lua.NewState()
	defer state.Close()
	if err := state.DoString(`function string.findi(s, pattern) return string.find(string.lower(s), string.lower(pattern), 1, true) end`); err != nil {
		t.Fatal(err)
	}
	state.PreloadModule("items", func(l *lua.LState) int {
	l.Push(l.NewTable())
	return 1
	})
	if err := state.DoString(string(source)); err != nil {
		t.Fatal(err)
	}
	if err := state.DoString(`
local function say(message)
 local result = { lines = {} }
 local npc = {}
 local player = {}
 function npc:Say(text) table.insert(result.lines, text) end
 function player:GetCleanName() return "Tester" end
 event_say({message = message, self = npc, other = player})
 return result.lines
end
local seen = "My whelp, Frakadar. I was sunning myself and he wandered off. At first I did not worry, for he never went far before. But it has been hours and hours, and no other dragon has seen him. I have flown calling his name, but he does not answer. Klandicar was the last to see him, near the entrance of the Necropolis. I am forbidden to enter the Necropolis as long as this body draws breath, for good reason. But I must know if my son is in there!"
for _, phrase in ipairs({"Seen who?", "sEeN WhO", "Have you seen who?"}) do
 local lines = say(phrase)
 assert(#lines == 1 and lines[1] == seen, "P99 Seen who? response must match exactly for " .. phrase)
end
local son = say("son")
assert(#son == 1 and son[1]:find("Have you seen him?", 1, true), "existing son response must remain")
local hail = say("hail")
assert(#hail == 1 and hail[1]:find("My son is lost", 1, true), "existing hail response must remain")
assert(#say("unrelated phrase") == 0, "unrelated speech must remain silent")
`); err != nil {
		t.Fatal(err)
	}
}
