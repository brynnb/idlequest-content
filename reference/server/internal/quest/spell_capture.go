package quest

// Quest actor references retain their namespace. A numeric Lua ID alone is not
// enough: NPC placement IDs and character IDs may have the same value.
type QuestSpellActor struct {
	CharacterID       uint32
	NPCTypeID         int32
	SpawnInstanceID   int64
	PendingSpawnIndex int
}

type QuestSpellCast struct {
	Settled  bool `json:"-"` // Server-only: parent quest transaction already applied this effect.
	SpellID  int32
	Caster   QuestSpellActor
	Target   QuestSpellActor
	TargetID int64
}

func (n *NPCProxy) spellActor() QuestSpellActor {
	return QuestSpellActor{NPCTypeID: n.ID, SpawnInstanceID: n.SpawnInstanceID, PendingSpawnIndex: n.PendingSpawnIndex}
}

func (c *QuestCapture) registerSpellActor(id int64, actor QuestSpellActor) {
	if id <= 0 {
		return
	}
	if c.spellActors == nil {
		c.spellActors = make(map[int64]QuestSpellActor)
	}
	if previous, exists := c.spellActors[id]; exists && previous != actor {
		// Never guess when separate namespaces collide. Resolution must fail,
		// rather than silently healing the player instead of targeting an NPC.
		c.spellActors[id] = QuestSpellActor{}
		return
	}
	c.spellActors[id] = actor
}
