// Isolated content tests only: uses the pinned Lua VM and source normalization,
// but mocked quest APIs. This is not the game bridge or inventory settlement.
package main

import (
	"context"
	"encoding/json"
	"fmt"
	lua "github.com/yuin/gopher-lua"
	"idlequest-content-validator/questluasource"
	"os"
	"time"
)

type scenario struct{ Name, Source, Setup, Assertions string }

func main() {
	var cases []scenario
	if err := json.NewDecoder(os.Stdin).Decode(&cases); err != nil {
		panic(err)
	}
	failed := false
	for _, c := range cases {
		L := lua.NewState()
		ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		L.SetContext(ctx)
		err := L.DoString(c.Setup)
		if err == nil {
			err = L.DoString(questluasource.Normalize(c.Source))
		}
		if err == nil {
			err = L.DoString(c.Assertions)
		}
		L.Close()
		cancel()
		if err != nil {
			fmt.Fprintf(os.Stderr, "FAIL %s: %v\n", c.Name, err)
			failed = true
		} else {
			fmt.Printf("PASS %s\n", c.Name)
		}
	}
	if failed {
		os.Exit(1)
	}
}
