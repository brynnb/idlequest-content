package quest

import "idlequest/internal/session"

type QuestNPCInfo struct {
	Success           bool                `json:"success"`
	HasDialogue       bool                `json:"hasDialogue"`
	HasTurnIn         bool                `json:"hasTurnIn"`
	Error             string              `json:"error,omitempty"`
	NPCName           string              `json:"npcName"`
	Greeting          string              `json:"greeting"`
	DialogueHistory   []DialogueEntry     `json:"dialogueHistory"`
	AvailableOptions  []DialogueOption    `json:"availableOptions"`
	IncompleteTurnIns []TurnInRequirement `json:"incompleteTurnIns"`
	SystemMessages    []string            `json:"systemMessages,omitempty"`
	Ding              bool                `json:"ding,omitempty"`
	Rewards           *RewardSummary      `json:"rewards,omitempty"`
	RuntimeCapture    *QuestCapture       `json:"-"`
}

type DialogueEntry struct {
	Text      string `json:"text"`
	IsPlayer  bool   `json:"isPlayer"`
	Timestamp int64  `json:"timestamp"`
}

type DialogueOption struct {
	Text    string `json:"text"`
	Keyword string `json:"keyword"`
}

type TurnInRequirement struct {
	Items []TurnInItem `json:"items"`
}

type TurnInItem struct {
	ItemID   int    `json:"itemId"`
	ItemName string `json:"itemName"`
	Quantity int    `json:"quantity"`
	Missing  int    `json:"missing"`
}

type QuestDialogueRequest struct {
	NPCID         int    `json:"npcId"`
	ZoneShortName string `json:"zoneShortName"`
	Keyword       string `json:"keyword"`
}

type QuestTurnInRequest struct {
	TransactionID string             `json:"transactionId"`
	NPCID         int                `json:"npcId"`
	ZoneShortName string             `json:"zoneShortName"`
	ItemIDs       []int              `json:"itemIds"`
	OfferedItems  []QuestOfferedItem `json:"offeredItems,omitempty"`
	Currency      QuestCurrency      `json:"currency"`
}

// QuestOfferedItem identifies the exact inventory instance placed in an NPC
// give slot. ItemIDs remains the script-facing representation; these references
// prevent a duplicate item elsewhere in the inventory from being consumed.
type QuestOfferedItem struct {
	ItemInstanceID int32 `json:"itemInstanceId"`
	ItemID         int   `json:"itemId"`
	Bag            int16 `json:"bag"`
	Slot           int16 `json:"slot"`
	Quantity       int   `json:"quantity"`
}

type QuestTurnInResponse struct {
	TransactionID               string        `json:"transactionId"`
	FinalInventoryRevision      string        `json:"finalInventoryRevision"`
	Success                     bool          `json:"success"`
	Error                       string        `json:"error,omitempty"`
	NPCResponse                 string        `json:"npcResponse"`
	Rewards                     RewardSummary `json:"rewards"`
	NewInfo                     *QuestNPCInfo `json:"newInfo"`
	ConsumedItemIDs             []int         `json:"consumedItemIds,omitempty"`
	ConsumedCurrency            QuestCurrency `json:"consumedCurrency,omitempty"`
	RuntimeCapture              *QuestCapture `json:"-"`
	UnavailableExpansionItemIDs []int         `json:"-"`
}

type CharacterStateRefreshRequest struct {
	TransactionID string `json:"transactionId"`
}

type CharacterStateRefreshResponse struct {
	TransactionID     string                    `json:"transactionId"`
	InventoryRevision string                    `json:"inventoryRevision"`
	Inventory         session.InventorySnapshot `json:"inventory"`
	Currency          map[string]interface{}    `json:"currency"`
}

type RewardSummary struct {
	Items        []QuestReward      `json:"items"`
	Experience   int                `json:"experience"`
	Factions     []string           `json:"factions"`
	Currency     QuestCurrency      `json:"currency"`
	SkillUpdates []QuestSkillUpdate `json:"skillUpdates,omitempty"`
	LocUpdate    bool               `json:"locUpdate"`
	Ding         bool               `json:"ding"`
}

type QuestReward struct {
	ItemID   int    `json:"itemId"`
	ItemName string `json:"itemName,omitempty"`
	Count    int    `json:"count"`
}

type QuestCurrency struct {
	Platinum int `json:"platinum"`
	Gold     int `json:"gold"`
	Silver   int `json:"silver"`
	Copper   int `json:"copper"`
}

type QuestActorPosition struct {
	X          float64
	Y          float64
	Z          float64
	Heading    float64
	InstanceID int
}

type QuestTurnInContext struct {
	ReadSpawnConditions QuestSpawnConditionReader
	ReadNPCCombat       QuestNPCCombatReader
	ReadNPCGrid         QuestNPCGridReader
	NPCVitals           *QuestNPCVitals
	NPCPosition         *QuestActorPosition
	PlayerPosition      *QuestActorPosition
	NPCSelfOverride     *QuestNPCSelfOverride
	SpawnInstanceID     int64
	InstanceID          int
	VisibleNPCTypeIDs   []int32
	ResolveNPC          QuestNPCResolver
	ListNPCs            QuestNPCEnumerator
	validateRewards     func(consumedItemIDs []int, rewards RewardSummary) error
	deferPersistence    bool
}

// World-owned snapshot tied to the exact actor, including a dead actor during
// death callbacks. NPC type defaults cannot describe current health.
type QuestNPCVitals struct {
	NPCTypeID       int32
	SpawnInstanceID int64
	PathEpochMs     int64 // Original public source lifetime, before Lua evaluation.
	HP              int64
	MaxHP           int64
}

type QuestNPCSelfOverride struct {
	NPCTypeID int32
	Race      uint16
	Gender    *uint8
	X         *float64
	Y         *float64
}

type QuestSpawnRequest struct {
	// Set only after the parent transaction commits. Delivery must resolve this
	// exact lifetime instead of creating another NPC on retry.
	SettledSpawnInstanceID int64 `json:"-"`
	SettledCreated         bool  `json:"-"`
	NPCTypeID              int32
	GridID                 int32
	X                      float64
	Y                      float64
	Z                      float64
	Heading                float64
	Unique                 bool
	AddedLoot              []NPCAddedLoot
}

type QuestDepopRequest struct {
	SpawnInstanceID   int64
	PendingSpawnIndex int
	NPCTypeID         int32
	All               bool
	WithTimer         bool
}

type QuestPlayerMoveRequest struct {
	ZoneID     int
	InstanceID int
	X          float64
	Y          float64
	Z          float64
	Heading    float64
	Dynamic    bool
}

type QuestNPCMoveKind string

const (
	QuestNPCMoveWalk       QuestNPCMoveKind = "walk"
	QuestNPCMoveTeleport   QuestNPCMoveKind = "teleport"
	QuestNPCMoveSetRunning QuestNPCMoveKind = "set-running"
	QuestNPCMoveRoam       QuestNPCMoveKind = "roam"
	QuestNPCMoveGridStart  QuestNPCMoveKind = "grid-start"
	QuestNPCMoveGridStop   QuestNPCMoveKind = "grid-stop"
)

type QuestNPCMoveRequest struct {
	Order             int
	Kind              QuestNPCMoveKind
	SpawnInstanceID   int64
	NPCTypeID         int32
	PendingSpawnIndex int
	X                 float64
	Y                 float64
	Z                 float64
	Heading           float64
	SaveGuardSpot     bool
	Running           bool
	Roam              bool
	GridID            int32
}

// Following is a continuing relationship, not a fabricated waypoint/MoveTo.
// The first supported target is the initiating live player; NPC following and
// native patrol interruption stay explicit runtime gaps.
type QuestNPCFollowRequest struct {
	SpawnInstanceID int64
	NPCTypeID       int32
	CharacterID     uint32
	Distance        float64
	Stop            bool
}

type QuestDoorRequest struct {
	ID        int32
	DoorID    int32
	ForceOpen bool
}

type QuestBindRequest struct {
	Settled bool `json:"-"`
}

// QuestGroundObjectRequest describes an item object created by
// eq.create_ground_object. Runtime IDs are local to one captured execution;
// the world layer replaces them with durable database IDs when applying it.
type QuestGroundObjectRequest struct {
	SettledItemID int64 `json:"-"`
	RuntimeID     int64
	ItemID        int32
	X             float64
	Y             float64
	Z             float64
	Heading       float64
	DecayMS       int64
}
