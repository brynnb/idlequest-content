package quest

import "testing"

func TestCaptureHasRuntimeEffects(t *testing.T) {
	cases := []QuestCapture{
		{Spawns: []QuestSpawnRequest{{NPCTypeID: 1}}},
		{Signals: []NPCSignal{{NPCID: 1}}},
		{Timers: []TimerUpdate{{Name: "tick", Interval: 1000}}},
		{Depops: []QuestDepopRequest{{NPCTypeID: 1}}},
		{HPEvents: []HPEventUpdate{{Percent: 50}}},
		{Proximity: &ProximityUpdate{MinX: -1, MaxX: 1}},
	}
	for index := range cases {
		if !captureHasRuntimeEffects(&cases[index]) {
			t.Fatalf("runtime effect case %d was treated as empty", index)
		}
	}
	if captureHasRuntimeEffects(&QuestCapture{}) {
		t.Fatal("empty capture must not count as a runtime effect")
	}
}
