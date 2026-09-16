package quest

import (
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"strings"
)

type TurnInScenarioManifest struct {
	Version   int                      `json:"version"`
	Overrides []TurnInScenarioOverride `json:"overrides"`
}

type TurnInScenarioOverride struct {
	Zone         string                `json:"zone"`
	NPC          string                `json:"npc"`
	CallIndex    *int                  `json:"callIndex,omitempty"`
	Line         *int                  `json:"line,omitempty"`
	Name         string                `json:"name,omitempty"`
	Requirements *TurnInRequirements   `json:"requirements,omitempty"`
	Player       *TurnInPlayerOverride `json:"player,omitempty"`
	Globals      map[string]string     `json:"globals,omitempty"`
	Expect       *TurnInExpectation    `json:"expect,omitempty"`
}

type TurnInRequirements struct {
	Items    []int         `json:"items,omitempty"`
	Currency QuestCurrency `json:"currency,omitempty"`
}

type TurnInPlayerOverride struct {
	Name                 string               `json:"name,omitempty"`
	Class                string               `json:"class,omitempty"`
	Race                 string               `json:"race,omitempty"`
	Level                int                  `json:"level,omitempty"`
	ActiveTasks          []int                `json:"activeTasks,omitempty"`
	ActiveTaskActivities []TurnInTaskActivity `json:"activeTaskActivities,omitempty"`
	HasItems             []int                `json:"hasItems,omitempty"`
	X                    float64              `json:"x,omitempty"`
	Y                    float64              `json:"y,omitempty"`
	Z                    float64              `json:"z,omitempty"`
	Heading              float64              `json:"heading,omitempty"`
}

type TurnInTaskActivity struct {
	TaskID     int `json:"taskId"`
	ActivityID int `json:"activityId"`
}

type TurnInExpectation struct {
	Activated        *bool           `json:"activated,omitempty"`
	ConsumedItems    []int           `json:"consumedItems,omitempty"`
	RewardItems      []QuestReward   `json:"rewardItems,omitempty"`
	Experience       *int            `json:"experience,omitempty"`
	Factions         []FactionReward `json:"factions,omitempty"`
	Currency         *QuestCurrency  `json:"currency,omitempty"`
	ResponseContains []string        `json:"responseContains,omitempty"`
}

func LoadTurnInScenarioManifest(path string) (TurnInScenarioManifest, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return TurnInScenarioManifest{}, err
	}
	var manifest TurnInScenarioManifest
	if err := json.Unmarshal(data, &manifest); err != nil {
		return TurnInScenarioManifest{}, err
	}
	if manifest.Version != 1 {
		return TurnInScenarioManifest{}, fmt.Errorf("unsupported quest turn-in manifest version %d", manifest.Version)
	}
	for index, override := range manifest.Overrides {
		if override.Zone == "" || override.NPC == "" {
			return TurnInScenarioManifest{}, fmt.Errorf("override %d must specify zone and npc", index)
		}
		if override.CallIndex == nil && override.Line == nil {
			return TurnInScenarioManifest{}, fmt.Errorf("override %d must specify callIndex or line", index)
		}
	}
	return manifest, nil
}

func validateTurnInExpectation(capture *QuestCapture, scenario TurnInScenario, activated bool, expect *TurnInExpectation) []string {
	if expect == nil {
		return nil
	}
	var failures []string
	if expect.Activated != nil && activated != *expect.Activated {
		failures = append(failures, fmt.Sprintf("activated: got %t want %t", activated, *expect.Activated))
	}
	if capture == nil {
		return append(failures, "capture is nil")
	}
	if expect.Experience != nil && capture.Exp != *expect.Experience {
		failures = append(failures, fmt.Sprintf("experience: got %d want %d", capture.Exp, *expect.Experience))
	}
	if expect.Currency != nil && capture.Currency != *expect.Currency {
		failures = append(failures, fmt.Sprintf("reward currency: got %+v want %+v", capture.Currency, *expect.Currency))
	}
	if expect.ConsumedItems != nil {
		got := consumedItems(capture, scenario.Items)
		if !equalInts(got, expect.ConsumedItems) {
			failures = append(failures, fmt.Sprintf("consumed items: got %v want %v", got, expect.ConsumedItems))
		}
	}
	if expect.RewardItems != nil && !equalRewards(capture.Items, expect.RewardItems) {
		failures = append(failures, fmt.Sprintf("reward items: got %+v want %+v", capture.Items, expect.RewardItems))
	}
	if expect.Factions != nil && !equalFactions(capture.Factions, expect.Factions) {
		failures = append(failures, fmt.Sprintf("factions: got %+v want %+v", capture.Factions, expect.Factions))
	}
	responses := strings.Join(capture.Responses, "\n")
	for _, text := range expect.ResponseContains {
		if !strings.Contains(responses, text) {
			failures = append(failures, fmt.Sprintf("response does not contain %q", text))
		}
	}
	return failures
}

func consumedItems(capture *QuestCapture, supplied []int) []int {
	left := map[int]int{}
	if capture.CurrentTrade != nil {
		for _, id := range capture.CurrentTrade.Items {
			left[id]++
		}
	}
	var consumed []int
	for _, id := range supplied {
		if left[id] > 0 {
			left[id]--
		} else {
			consumed = append(consumed, id)
		}
	}
	return consumed
}

func equalInts(a, b []int) bool {
	a = append([]int(nil), a...)
	b = append([]int(nil), b...)
	sort.Ints(a)
	sort.Ints(b)
	return fmt.Sprint(a) == fmt.Sprint(b)
}
func equalRewards(a, b []QuestReward) bool    { return fmt.Sprint(a) == fmt.Sprint(b) }
func equalFactions(a, b []FactionReward) bool { return fmt.Sprint(a) == fmt.Sprint(b) }
