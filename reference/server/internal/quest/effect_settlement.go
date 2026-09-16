package quest

import (
	"context"
	"fmt"

	"github.com/go-jet/jet/v2/stmtcache"
)

// RuntimeEffectSettlement joins server-owned effects to the existing quest
// transaction. Publish is called only after that transaction commits.
type RuntimeEffectSettlement struct {
	Persist func(context.Context, *stmtcache.Tx) error
	Publish func()
}

func (s *Service) prepareRuntimeEffects(characterID uint32, npcID int32, zone string, runtime QuestTurnInContext, capture *QuestCapture) (*RuntimeEffectSettlement, error) {
	if s.ValidateRuntimeCapture != nil {
		if err := s.ValidateRuntimeCapture(characterID, npcID, zone, runtime, capture); err != nil {
			return nil, fmt.Errorf("quest event effect preflight: %w", err)
		}
	}
	if s.PrepareRuntimeEffects == nil {
		return nil, nil
	}
	return s.PrepareRuntimeEffects(characterID, npcID, zone, runtime, capture)
}

func (s *RuntimeEffectSettlement) persist(ctx context.Context, tx *stmtcache.Tx) error {
	if s == nil || s.Persist == nil {
		return nil
	}
	return s.Persist(ctx, tx)
}

func (s *RuntimeEffectSettlement) publish() {
	if s != nil && s.Publish != nil {
		s.Publish()
	}
}
