package quest

import (
	"idlequest/internal/contentscope"
	"strings"
)

// P99QuestZoneNames returns the Classic-through-Velious audit scope, including
// Warrens and Stonebrunt. Inclusion does not enable a zone, quest or NPC: those
// decisions still require their ordinary availability and content checks.
// Do not infer scope from zone.expansion: PEQ marks some later zones as 0/1.
func P99QuestZoneNames() []string {
	return contentscope.P99ZoneNames()
}

func P99QuestZoneSet() map[string]bool {
	zones := make(map[string]bool)
	for _, zone := range P99QuestZoneNames() {
		zone = strings.ToLower(strings.TrimSpace(zone))
		if zone != "" {
			zones[zone] = true
		}
	}
	return zones
}
