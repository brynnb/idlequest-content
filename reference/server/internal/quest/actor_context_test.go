package quest

import (
	"strconv"
	"testing"

	"github.com/stretchr/testify/require"
	"idlequest/internal/session"
)

func TestResolvedQuestActorMustStillExist(t *testing.T) {
	for _, id := range []int64{0, -1, 16785, 5000000000648} {
		t.Run(strconv.FormatInt(id, 10), func(t *testing.T) {
			context, err := resolveAvailableQuestActor(nil, "karnor", 102099,
				func(_ *session.Session, zone string, npcID int32) QuestTurnInContext {
					require.Equal(t, "karnor", zone)
					require.Equal(t, int32(102099), npcID)
					return QuestTurnInContext{SpawnInstanceID: id}
				})
			if id <= 0 {
				require.ErrorContains(t, err, "no longer available")
			} else {
				require.NoError(t, err)
				require.Equal(t, id, context.SpawnInstanceID)
			}
		})
	}
}
