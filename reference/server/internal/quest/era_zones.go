package quest

import (
	_ "embed"
	"encoding/json"
	"strings"
)

//go:embed classic_kunark_zones.json
var classicKunarkQuestZonesJSON []byte

// ClassicKunarkQuestZoneNames returns the explicit IdleQuest quest-content
// scope. Do not infer this from zone.expansion alone; the local PEQ-derived
// metadata marks some later zones as expansion 0/1.
func ClassicKunarkQuestZoneNames() []string {
	var zones []string
	if err := json.Unmarshal(classicKunarkQuestZonesJSON, &zones); err != nil {
		panic(err)
	}
	return zones
}

func ClassicKunarkQuestZoneSet() map[string]bool {
	zones := make(map[string]bool)
	for _, zone := range ClassicKunarkQuestZoneNames() {
		zone = strings.ToLower(strings.TrimSpace(zone))
		if zone != "" {
			zones[zone] = true
		}
	}
	return zones
}
