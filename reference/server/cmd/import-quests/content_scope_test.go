package main

import (
	"context"
	"github.com/stretchr/testify/require"
	questoverrides "idlequest/internal/quest/overrides"
	"testing"
)

func TestSelectedOverrideRejectsReviewedContentExclusionBeforeDatabaseWrite(t *testing.T) {
	for _, name := range []string{"Igok", "#Igok", "46064"} {
		for _, apply := range []bool{false, true} {
			// A nil DB deliberately proves rejection happens before opening a write
			// transaction, even if an older import left the quest enabled.
			_, err := updateSelectedOverride(context.Background(), nil, questoverrides.Script{Zone: "innothule", Name: name, Lua: "function event_say(e) end"}, apply)
			require.ErrorContains(t, err, "outside the supported content era")
		}
	}
}
