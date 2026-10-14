package quest

// NPCSpeech describes local speech captured by NPC:Say/Emote. Shouts, explicit
// player messages and zone emotes deliberately do not have this restriction.
type NPCSpeech struct {
	Name    string
	Emote   bool `json:",omitempty"`
	X, Y, Z float64
}

// EQEmu zone/mob.cpp Mob::Say uses a 200-unit distance. This is execution
// compatibility for imported scripts, not a claim of exact historical EQ range.
const NPCSayDistance = 200.0

func (s NPCSpeech) AudibleAt(x, y, z float64) bool {
	dx, dy, dz := s.X-x, s.Y-y, s.Z-z
	// NaN and infinite positions fail this comparison rather than broadcasting.
	return dx*dx+dy*dy+dz*dz <= NPCSayDistance*NPCSayDistance
}
