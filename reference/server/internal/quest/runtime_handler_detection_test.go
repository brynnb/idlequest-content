package quest

import "testing"

func TestScriptDefinesLuaHandler(t *testing.T) {
	for _, source := range []string{
		"function event_spawn(e)\nend",
		"function event_spawn (e) end",
		"event_spawn = function(e) end",
		"event_spawn=function(e) end",
	} {
		if !scriptDefinesLuaHandler(source, "event_spawn") {
			t.Fatalf("handler not detected in %q", source)
		}
	}
	if scriptDefinesLuaHandler("-- function event_spawn(e)\nfunction event_say(e) end", "event_spawn") {
		t.Fatal("commented handler must not be detected")
	}
}
