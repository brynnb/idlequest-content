package quest

// The source actor is supplied by the authoritative world event context, not
// a type lookup or coordinates supplied by Lua. Quest attacks stay owner-scoped.
type QuestAttackRequest struct {
	PlayerName string
}
