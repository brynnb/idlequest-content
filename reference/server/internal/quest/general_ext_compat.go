package quest

import (
	"idlequest/internal/mechanics"
	"math/rand"
	"regexp"
	"strconv"
)

func questExperienceReward(level, percent, spread int) int64 {
	if level < 1 || level > mechanics.MaxPlayerLevel {
		return 0
	}
	if percent < 0 {
		percent = 0
	}
	if spread < 0 {
		spread = 0
	}
	low, high := percent-spread, percent+spread
	if low < 0 {
		low = 0
	}
	chosen := low
	if high > low {
		chosen += rand.Intn(high - low + 1)
	}
	return int64(mechanics.ExperienceRequiredForLevel(level, 1, 0)) * int64(chosen) / 100
}

var questDurationPartRE = regexp.MustCompile(`(?i)([0-9]+)\s*([wdhms])`)

func parseQuestDurationSeconds(value string) int64 {
	units := map[string]int64{"w": 604800, "d": 86400, "h": 3600, "m": 60, "s": 1}
	var total int64
	for _, match := range questDurationPartRE.FindAllStringSubmatch(value, -1) {
		amount, _ := strconv.ParseInt(match[1], 10, 64)
		total += amount * units[match[2]]
	}
	return total
}
