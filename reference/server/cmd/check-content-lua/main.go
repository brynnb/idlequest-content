package main

import (
	"encoding/json"
	"fmt"
	"idlequest/internal/questluasource"
	"os"
)

func main() {
	var scripts []struct {
		Name   string `json:"name"`
		Source string `json:"source"`
		Module bool   `json:"module"`
	}
	if err := json.NewDecoder(os.Stdin).Decode(&scripts); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
	var failures []map[string]string
	for _, script := range scripts {
		if err := questluasource.Validate(script.Name, script.Source, script.Module); err != nil {
			failures = append(failures, map[string]string{"name": script.Name, "error": err.Error()})
		}
	}
	_ = json.NewEncoder(os.Stdout).Encode(map[string]any{"checked": len(scripts), "failures": failures})
	if len(failures) > 0 {
		os.Exit(1)
	}
}
