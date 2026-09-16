package quest

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestQuestExperienceRewardMatchesProjectEQHelper(t *testing.T) {
	assert.Equal(t, int64(719294), questExperienceReward(51, 3, 0))
	assert.Equal(t, int64(0), questExperienceReward(101, 3, 0))
}

func TestParseQuestDurationSeconds(t *testing.T) {
	assert.Equal(t, int64(788645), parseQuestDurationSeconds("1w 2d 3h 4m 5s"))
}

func TestEntityClientIteratorRejectsUnimplementedInventorySearch(t *testing.T) {
	bridge := NewLuaBridge(".")
	_, err := bridge.ExecuteEventFromSource(`
		function event_timer(e)
			for client in eq.get_entity_list():GetClientList().entries do
				local inv = client:GetInventory()
				local slot = inv:HasItem(81890, 1, bit.bor(InventoryWhere.Personal, InventoryWhere.Cursor))
				if slot ~= -1 then error("matrix player unexpectedly owns the item") end
			end
		end
	`, "event_timer", &LuaEvent{NPC: &NPCProxy{ID: 1}, Player: &PlayerProxy{ID: 2}})
	assert.ErrorContains(t, err, "player.GetInventory.HasItem")
}

func TestUnimplementedSlotInventoryReadsCannotCertifyRewards(t *testing.T) {
	for _, expression := range []string{"e.other:GetItemIDAt(13)", "e.other:GetInventory():HasItem(81890, 1, 2)"} {
		for _, strict := range []bool{false, true} {
			bridge := NewLuaBridge(".")
			bridge.RequireImplementedEffects = strict
			capture, err := bridge.ExecuteEventFromSource(`function event_say(e)
 pcall(function() local slot = `+expression+` end)
 e.other:SummonItem(14366)
end`, "event_say", &LuaEvent{NPC: &NPCProxy{ID: 1},
				Player: &PlayerProxy{ID: 2, Inventory: map[int]bool{81890: true}}})
			assert.Error(t, err, expression)
			assert.Nil(t, capture, "caught lookup errors must not allow partial rewards")
		}
	}
}
