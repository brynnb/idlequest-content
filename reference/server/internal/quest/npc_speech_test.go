package quest

import (
	"encoding/json"
	"math"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestNPCSpeechPreservesSpeakerThroughMergeAndSerialization(t *testing.T) {
	event := &LuaEvent{NPC: &NPCProxy{ID: 9001, Name: "Local", X: 10}, Player: &PlayerProxy{ID: 101}, SpawnInstanceID: 1}
	capture, err := NewLuaBridge(".").ExecuteSayFromSource(`function event_say(e)
 e.self:Say("near")
 e.self:Shout("zone")
 e.self:Say("second")
 e.other:Message(15, "private")
end`, event)
	require.NoError(t, err)
	require.Len(t, capture.NPCSpeech, 2)
	require.Equal(t, "near", capture.Responses[0], "dialogue strings remain unchanged")
	require.Equal(t, NPCSpeech{Name: "Local", X: 10}, capture.NPCSpeech[2])
	dst := NewQuestCapture()
	dst.Responses = []string{"earlier"}
	mergeQuestCapture(dst, capture)
	data, err := json.Marshal(dst)
	require.NoError(t, err)
	var restored QuestCapture
	require.NoError(t, json.Unmarshal(data, &restored))
	require.Equal(t, capture.NPCSpeech[0], restored.NPCSpeech[1])
	require.Equal(t, capture.NPCSpeech[2], restored.NPCSpeech[3])
	require.Len(t, restored.NPCSpeech, 2)
	clearQuestCaptureEffects(&restored)
	require.Empty(t, restored.NPCSpeech, "registered callbacks must not retain stale speech indices")
}

func TestNPCSayDistance(t *testing.T) {
	speech := NPCSpeech{X: 10, Y: 20, Z: 30}
	require.True(t, speech.AudibleAt(210, 20, 30))
	require.False(t, speech.AudibleAt(210.01, 20, 30))
	require.False(t, speech.AudibleAt(10, 20, 231))
	require.False(t, speech.AudibleAt(math.NaN(), 20, 30))
	require.False(t, speech.AudibleAt(10, math.Inf(1), 30))
}
