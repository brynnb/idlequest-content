package quest

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"sort"
	"strings"
	"time"

	"idlequest/internal/api/opcodes"
	"idlequest/internal/constants"
	db_character "idlequest/internal/db/character"
	"idlequest/internal/db/items"
	"idlequest/internal/mechanics"
	"idlequest/internal/serialization"
	"idlequest/internal/session"
)

const questUnavailableExpansionItemMessage = "This quest involves items outside the current expansion. Your items have been returned. Please contact support if you think this is in error."

type QuestTurnInContextResolver func(ses *session.Session, zoneShortName string, npcID int32) QuestTurnInContext
type QuestRuntimeCaptureHandler func(ses *session.Session, zoneShortName string, npcID int32, context QuestTurnInContext, capture *QuestCapture)

type QuestRuntimeCaptureValidator func(ses *session.Session, zoneShortName string, npcID int32, context QuestTurnInContext, capture *QuestCapture) error

func resolveAvailableQuestActor(ses *session.Session, zone string, npcID int32, resolve QuestTurnInContextResolver) (QuestTurnInContext, error) {
	// Isolated service tests may omit world resolution. Real network handlers
	// always supply it: an absent/suppressed actor must not become an imaginary
	// NPC at the player's position, accepting payment without lifecycle effects.
	if resolve == nil {
		return QuestTurnInContext{}, nil
	}
	actor := resolve(ses, zone, npcID)
	if actor.SpawnInstanceID <= 0 {
		return actor, fmt.Errorf("That quest NPC is no longer available. Please target it again.")
	}
	return actor, nil
}

func HandleQuestNPCInfoRequest(ses *session.Session, payload []byte, questService *Service, resolveContext QuestTurnInContextResolver, handleCapture QuestRuntimeCaptureHandler) bool {
	var req struct {
		NPCID         int32  `json:"npcId"`
		ZoneShortName string `json:"zoneShortName"`
	}
	if err := json.Unmarshal(payload, &req); err != nil {
		return false
	}
	charID := uint32(0)
	if ses.Client != nil {
		charID = uint32(ses.Client.ID())
	}
	log.Printf("[Quest] HandleQuestNPCInfoRequest: NPCID=%d, Zone=%s, CharID=%d", req.NPCID, req.ZoneShortName, charID)

	actorContext, resolveErr := resolveAvailableQuestActor(ses, req.ZoneShortName, req.NPCID, resolveContext)
	if resolveErr != nil {
		ses.SendStreamJSON(QuestNPCInfo{Success: false, Error: resolveErr.Error()}, opcodes.QuestNPCInfoResponse)
		return false
	}
	actorContext.validateRewards = func(consumedItemIDs []int, rewards RewardSummary) error {
		return preflightQuestRewards(ses.Client.Items(), nil, rewards)
	}
	info, err := questService.GetNPCQuestInfoWithContext(charID, req.NPCID, req.ZoneShortName, actorContext)
	if err != nil {
		log.Printf("[Quest] Error getting NPC info: %v", err)
		ses.SendStreamJSON(QuestNPCInfo{Success: false, Error: err.Error()}, opcodes.QuestNPCInfoResponse)
		return false
	}

	info.Success = info.Error == ""
	if info.Error != "" {
		ses.Client.SendSystemMessage(info.Error)
	}
	log.Printf("[Quest] Sending NPC info for %s (Options: %d)", info.NPCName, len(info.AvailableOptions))
	if info.Rewards != nil {
		grantRewards(ses, *info.Rewards)
	}
	if handleCapture != nil && info.RuntimeCapture != nil {
		handleCapture(ses, req.ZoneShortName, req.NPCID, actorContext, info.RuntimeCapture)
	}

	ses.SendStreamJSON(info, opcodes.QuestNPCInfoResponse)
	return false
}

func HandleQuestDialogueRequest(ses *session.Session, payload []byte, questService *Service, resolveContext QuestTurnInContextResolver, handleCapture QuestRuntimeCaptureHandler) bool {
	var req struct {
		NPCID         int32  `json:"npcId"`
		ZoneShortName string `json:"zoneShortName"`
		Keyword       string `json:"keyword"`
	}
	if err := json.Unmarshal(payload, &req); err != nil {
		return false
	}
	charID := uint32(0)
	if ses.Client != nil {
		charID = uint32(ses.Client.ID())
	}
	log.Printf("[Quest] HandleQuestDialogueRequest: NPCID=%d, Zone=%s, Keyword=%s, CharID=%d", req.NPCID, req.ZoneShortName, req.Keyword, charID)

	actorContext, resolveErr := resolveAvailableQuestActor(ses, req.ZoneShortName, req.NPCID, resolveContext)
	if resolveErr != nil {
		ses.SendStreamJSON(QuestNPCInfo{Success: false, Error: resolveErr.Error()}, opcodes.QuestDialogueResponse)
		return false
	}
	actorContext.validateRewards = func(consumedItemIDs []int, rewards RewardSummary) error {
		return preflightQuestRewards(ses.Client.Items(), nil, rewards)
	}
	info, err := questService.ProcessKeywordWithContext(charID, req.NPCID, req.ZoneShortName, req.Keyword, actorContext)
	if err != nil {
		log.Printf("[Quest] Error processing keyword: %v", err)
		ses.SendStreamJSON(QuestNPCInfo{Success: false, Error: err.Error()}, opcodes.QuestDialogueResponse)
		return false
	}

	info.Success = info.Error == ""
	if info.Error != "" {
		ses.Client.SendSystemMessage(info.Error)
	}
	if info.Rewards != nil {
		grantRewards(ses, *info.Rewards)
	}
	if handleCapture != nil && info.RuntimeCapture != nil {
		handleCapture(ses, req.ZoneShortName, req.NPCID, actorContext, info.RuntimeCapture)
	}

	ses.SendStreamJSON(info, opcodes.QuestDialogueResponse)
	return false
}

func HandleQuestTurnInRequest(
	ses *session.Session,
	payload []byte,
	questService *Service,
	resolveContext QuestTurnInContextResolver,
	handleCapture QuestRuntimeCaptureHandler,
	validateCapture QuestRuntimeCaptureValidator,
) bool {
	var req QuestTurnInRequest
	if err := json.Unmarshal(payload, &req); err != nil {
		return false
	}
	if req.TransactionID == "" || len(req.TransactionID) > 64 {
		sendQuestTurnInResponse(ses, req, &QuestTurnInResponse{Success: false, Error: "The quest turn-in transaction ID is invalid."})
		return false
	}

	turnInContext, resolveErr := resolveAvailableQuestActor(ses, req.ZoneShortName, int32(req.NPCID), resolveContext)
	if resolveErr != nil {
		sendQuestTurnInResponse(ses, req, &QuestTurnInResponse{Success: false, Error: resolveErr.Error()})
		return false
	}
	turnInContext.deferPersistence = true
	if err := validateOfferedItems(ses.Client.Items(), req.OfferedItems, req.ItemIDs); err != nil {
		ses.Client.SendSystemMessage(err.Error() + ". Your items and money have been returned.")
		sendQuestTurnInResponse(ses, req, &QuestTurnInResponse{Success: false, Error: err.Error()})
		return false
	}
	if err := validateQuestTurnInCurrency(ses, req.Currency); err != nil {
		ses.Client.SendSystemMessage(err.Error() + " Your items and money have been returned.")
		sendQuestTurnInResponse(ses, req, &QuestTurnInResponse{Success: false, Error: err.Error()})
		return false
	}
	var consumptionPlan []questItemConsumption
	turnInContext.validateRewards = func(consumedItemIDs []int, rewards RewardSummary) error {
		plan, err := buildQuestConsumptionPlan(ses.Client.Items(), req.OfferedItems, consumedItemIDs)
		if err != nil {
			return err
		}
		if err := preflightQuestRewards(ses.Client.Items(), plan, rewards); err != nil {
			return err
		}
		consumptionPlan = plan
		return nil
	}

	// 1. Process turn-in via service
	res, err := questService.ProcessTurnInWithContext(
		uint32(ses.Client.ID()),
		int32(req.NPCID),
		req.ZoneShortName,
		req.ItemIDs,
		req.Currency,
		turnInContext,
	)
	if err != nil {
		log.Printf("[Quest] Error processing turn-in: %v", err)
		sendQuestTurnInResponse(ses, req, &QuestTurnInResponse{Success: false, Error: "The quest hand-in could not be completed. Your items and money have been returned."})
		return false
	}
	if res.Error != "" {
		ses.Client.SendSystemMessage(res.Error)
	}

	if len(res.UnavailableExpansionItemIDs) > 0 {
		log.Printf("[Quest] Rejecting turn-in for NPC %d in %s because item templates are unavailable: %v", req.NPCID, req.ZoneShortName, res.UnavailableExpansionItemIDs)
		ses.Client.SendSystemMessage(questUnavailableExpansionItemMessage)
		sendQuestTurnInResponse(ses, req, res)
		return false
	}

	if res.Success {
		if validateCapture != nil && res.RuntimeCapture != nil {
			if err := validateCapture(ses, req.ZoneShortName, int32(req.NPCID), turnInContext, res.RuntimeCapture); err != nil {
				log.Printf("[Quest] Runtime effect preflight failed for NPC %d: %v", req.NPCID, err)
				res.Success = false
				res.Error = "This quest's requested effect is not available. Your items and money have been returned."
				ses.Client.SendSystemMessage(res.Error)
				sendQuestTurnInResponse(ses, req, res)
				return false
			}
		}
		charData := ses.Client.CharData()
		settlementCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		finalInventory, revision, settleErr := questService.settleQuestTurnIn(
			settlementCtx,
			req.TransactionID,
			charData.ID,
			int32(req.NPCID),
			req.ZoneShortName,
			turnInContext,
			consumptionPlan,
			res.ConsumedCurrency,
			res.Rewards,
			res.RuntimeCapture,
			ses.Client.Items(),
		)
		cancel()
		if settleErr != nil {
			log.Printf("[Quest] Atomic settlement failed for transaction %s: %v", req.TransactionID, settleErr)
			res.Success = false
			res.Error = "The quest hand-in could not be committed. Your items and money have been returned."
			ses.Client.SendSystemMessage(res.Error)
			sendQuestTurnInResponse(ses, req, res)
			return false
		}
		ses.Client.WithItemsMutate(func(current map[constants.InventoryKey]*constants.ItemWithInstance) {
			for key := range current {
				delete(current, key)
			}
			for key, item := range finalInventory {
				current[key] = item
			}
		})
		res.FinalInventoryRevision = revision
		applySettledQuestRewards(ses, res.Rewards)
		infoContext := turnInContext
		infoContext.validateRewards = nil
		infoContext.deferPersistence = true
		res.NewInfo, _ = questService.GetNPCQuestInfoWithContext(
			charData.ID,
			int32(req.NPCID),
			req.ZoneShortName,
			infoContext,
		)
		if res.NewInfo != nil {
			questService.applyTurnInDialogue(res.NewInfo, res.NPCResponse, res.RuntimeCapture)
			// Match the ordinary info endpoint: a valid refreshed interaction
			// must remain usable for another hand-in without a Reset click.
			res.NewInfo.Success = res.NewInfo.Error == ""
			res.NewInfo.Rewards = nil
			res.NewInfo.RuntimeCapture = nil
		}

		if handleCapture != nil && res.RuntimeCapture != nil {
			handleCapture(ses, req.ZoneShortName, int32(req.NPCID), turnInContext, res.RuntimeCapture)
		}
	}

	sendQuestTurnInResponse(ses, req, res)
	return false
}

func applySettledQuestRewards(ses *session.Session, rewards RewardSummary) {
	charData := ses.Client.CharData()
	for _, reward := range rewards.Items {
		for count := 0; count < reward.Count; count++ {
			ses.Client.SendSystemMessage(fmt.Sprintf("You receive %s.", reward.ItemName))
		}
	}
	if rewards.Experience > 0 {
		oldLevel := charData.Level
		oldExp := charData.Exp
		charData.Exp = mechanics.AddExperience(charData.Exp, rewards.Experience, int(charData.Race), int(charData.Class))
		charData.Level = uint32(mechanics.CalculateLevelAfterExperienceGain(int(oldLevel), charData.Exp, int(charData.Race), int(charData.Class)))
		ses.Client.SendSystemMessage(fmt.Sprintf("You gain experience!! (%d)", charData.Exp-oldExp))
		if charData.Level > oldLevel {
			ses.Client.SendSystemMessage("You have gained a level!")
			ses.Client.HandleLevelChange(oldLevel, charData.Level)
		} else {
			ses.Client.SendStateUpdate()
		}
	}
	if rewards.Currency.Platinum > 0 || rewards.Currency.Gold > 0 || rewards.Currency.Silver > 0 || rewards.Currency.Copper > 0 {
		var parts []string
		if rewards.Currency.Platinum > 0 {
			parts = append(parts, fmt.Sprintf("%d platinum", rewards.Currency.Platinum))
		}
		if rewards.Currency.Gold > 0 {
			parts = append(parts, fmt.Sprintf("%d gold", rewards.Currency.Gold))
		}
		if rewards.Currency.Silver > 0 {
			parts = append(parts, fmt.Sprintf("%d silver", rewards.Currency.Silver))
		}
		if rewards.Currency.Copper > 0 {
			parts = append(parts, fmt.Sprintf("%d copper", rewards.Currency.Copper))
		}
		ses.Client.SendSystemMessage(fmt.Sprintf("You receive %s.", strings.Join(parts, ", ")))
	}
	if len(rewards.SkillUpdates) > 0 {
		ses.Client.WithSkillsMutate(func(skills map[int]int) {
			for _, skill := range rewards.SkillUpdates {
				skills[skill.SkillID] = skill.Value
			}
		})
	}
	for _, message := range rewards.Factions {
		ses.Client.SendSystemMessage(message)
	}
	ses.Client.UpdateStats()
	ses.Client.SendStateUpdate()
}

func unavailableQuestTemplateItemIDs(consumedItemIDs []int, rewards RewardSummary, exists func(int32) bool) []int {
	if exists == nil {
		return nil
	}

	missingSet := make(map[int]struct{})
	addIfMissing := func(itemID int) {
		if itemID <= 0 {
			return
		}
		if !exists(int32(itemID)) {
			missingSet[itemID] = struct{}{}
		}
	}

	for _, itemID := range consumedItemIDs {
		addIfMissing(itemID)
	}
	for _, reward := range rewards.Items {
		addIfMissing(reward.ItemID)
	}

	if len(missingSet) == 0 {
		return nil
	}
	missing := make([]int, 0, len(missingSet))
	for itemID := range missingSet {
		missing = append(missing, itemID)
	}
	sort.Ints(missing)
	return missing
}

func grantRewards(ses *session.Session, rewards RewardSummary) {
	if ses.Client == nil {
		return
	}
	ctx := context.Background()
	charData := ses.Client.CharData()

	// Grant Item Rewards
	if len(rewards.Items) > 0 {
		charSkills, _ := db_character.GetCharacterSkills(ctx, int64(charData.ID))
		for _, reward := range rewards.Items {
			tmpl, err := items.GetAcquirableItemTemplateByID(int32(reward.ItemID))
			if err != nil {
				continue
			}
			for i := 0; i < reward.Count; i++ {
				_, _, err := items.ProcessInventoryReward(
					int32(charData.ID),
					int(charData.Class),
					int(charData.Race),
					ses.Client.Items(),
					tmpl,
					1,
					charSkills,
				)
				if err != nil {
					log.Printf("[Quest] Error adding reward item %d to inventory: %v", reward.ItemID, err)
					ses.Client.SendSystemMessage(fmt.Sprintf("You could not receive %s because your inventory is full.", tmpl.Name))
				} else {
					ses.Client.SendSystemMessage(fmt.Sprintf("You receive %s.", tmpl.Name))
				}
			}
		}

		// Send updated inventory to client so it knows where reward items were placed.
		invMap := make(map[string]interface{})
		for k, item := range ses.Client.Items() {
			if item == nil {
				continue
			}
			invMap[fmt.Sprintf("%d:%d", k.Bag, k.Slot)] = toMap(item)
		}
		ses.SendInventorySnapshot(invMap)
	}

	// Grant EXP
	if rewards.Experience > 0 {
		charData := ses.Client.CharData()
		oldLevel := charData.Level
		oldExp := charData.Exp
		charData.Exp = mechanics.AddExperience(charData.Exp, rewards.Experience, int(charData.Race), int(charData.Class))
		charData.Level = uint32(mechanics.CalculateLevelAfterExperienceGain(int(oldLevel), charData.Exp, int(charData.Race), int(charData.Class)))
		ses.Client.SendSystemMessage(fmt.Sprintf("You gain experience!! (%d)", charData.Exp-oldExp))
		if charData.Level > oldLevel {
			ses.Client.SendSystemMessage("You have gained a level!")
			ses.Client.HandleLevelChange(oldLevel, charData.Level)
		} else {
			ses.Client.SendStateUpdate()
		}
	}

	// Grant Currency Rewards (DB write already done by persistQuestCapture; just refresh client)
	if rewards.Currency.Platinum > 0 || rewards.Currency.Gold > 0 || rewards.Currency.Silver > 0 || rewards.Currency.Copper > 0 {
		currency, err := db_character.GetCharacterCurrency(ctx, uint32(charData.ID))
		if err == nil {
			ses.SendStreamJSON(map[string]interface{}{
				"platinum": currency.Platinum,
				"gold":     currency.Gold,
				"silver":   currency.Silver,
				"copper":   currency.Copper,
			}, opcodes.CharacterCurrency)
		}

		// Build a human-readable currency message
		var parts []string
		if rewards.Currency.Platinum > 0 {
			parts = append(parts, fmt.Sprintf("%d platinum", rewards.Currency.Platinum))
		}
		if rewards.Currency.Gold > 0 {
			parts = append(parts, fmt.Sprintf("%d gold", rewards.Currency.Gold))
		}
		if rewards.Currency.Silver > 0 {
			parts = append(parts, fmt.Sprintf("%d silver", rewards.Currency.Silver))
		}
		if rewards.Currency.Copper > 0 {
			parts = append(parts, fmt.Sprintf("%d copper", rewards.Currency.Copper))
		}
		if len(parts) > 0 {
			ses.Client.SendSystemMessage(fmt.Sprintf("You receive %s.", strings.Join(parts, ", ")))
		}
	}

	if len(rewards.SkillUpdates) > 0 {
		ses.Client.WithSkillsMutate(func(skills map[int]int) {
			for _, skill := range rewards.SkillUpdates {
				skills[skill.SkillID] = skill.Value
			}
		})
	}

	// Send Faction messages to chatbox
	for _, factionMsg := range rewards.Factions {
		ses.Client.SendSystemMessage(factionMsg)
	}

	// Update stats and send update
	ses.Client.UpdateStats()
	ses.Client.SendStateUpdate()
}

func validateQuestTurnInCurrency(ses *session.Session, offered QuestCurrency) error {
	if offered.Platinum < 0 || offered.Gold < 0 || offered.Silver < 0 || offered.Copper < 0 {
		return fmt.Errorf("Invalid quest currency offer.")
	}
	currency, err := db_character.GetCharacterCurrency(context.Background(), uint32(ses.Client.CharData().ID))
	if err != nil {
		return fmt.Errorf("Your currency could not be verified.")
	}
	if offered.Platinum > int(currency.Platinum) || offered.Gold > int(currency.Gold) || offered.Silver > int(currency.Silver) || offered.Copper > int(currency.Copper) {
		return fmt.Errorf("You no longer have all of the offered currency.")
	}
	return nil
}

// DeliverRuntimeRewards applies the session/inventory side of rewards whose
// durable character changes were already persisted by the quest service.
func DeliverRuntimeRewards(ses *session.Session, rewards RewardSummary) {
	// Most patrol/timer events only change NPC or script state. Reusing the
	// hand-in refresh unconditionally republishes the player's inventory,
	// skills and character data for every NPC waypoint. Hand-ins still
	// need that refresh even without rewards because their offered items changed.
	if len(rewards.Items) == 0 && rewards.Experience == 0 && len(rewards.Factions) == 0 &&
		rewards.Currency == (QuestCurrency{}) && len(rewards.SkillUpdates) == 0 &&
		!rewards.LocUpdate && !rewards.Ding {
		return
	}
	grantRewards(ses, rewards)
}

// PreflightRuntimeRewards verifies inventory capacity and lore conflicts before
// a world interaction irreversibly consumes or claims its source object.
func PreflightRuntimeRewards(ses *session.Session, rewards RewardSummary) error {
	if ses == nil || ses.Client == nil {
		return fmt.Errorf("player inventory is unavailable")
	}
	_, err := buildQuestInventoryPlan(ses.Client.Items(), nil, rewards, false)
	return err
}

// toMap converts a struct to map[string]interface{} with camelCase keys.
// Mirrors world.StructToMap to produce JSON the client expects.
func toMap(obj interface{}) interface{} {
	return serialization.StructToMap(obj)
}
