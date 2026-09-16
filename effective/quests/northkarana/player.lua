-- Source: northkarana/player.lua

function event_enter_zone(e)
	eq.set_timer("spires",10 * 1000);
end

function event_timer(e)
    local qglobals = eq.get_qglobals(e.self);

	if qglobals.nexus_nk ~= nil and qglobals.spire_nk ~= nil and qglobals.spire_nk == "1" and e.self:HasItem(19720) then
		eq.SelfCast(2433); -- self only to avoid AE
		eq.set_global("spire_nk","0",1,"F");
		eq.del_global("message_nk");
		e.self:NukeItem(19720) -- removes stone from inventory.
	elseif qglobals.nexus_nk ~= nil and qglobals.spire_nk ~= nil and qglobals.spire_nk == "1" and qglobals.message_nk == nil and not e.self:HasItem(19720) then
		e.self:Message(MT.Yellow, "You don't have the correct component to travel to Luclin.");
		eq.set_global("message_nk","1",1,"M20"); -- prevent component mssage from being spammed.
	end
end

function event_loot(e)
    if e.item:GetID() == 14344 and e.corpse:GetNPCTypeID() == 13125 and e.self:HasItem(26896) and e.self:HasItem(11430) and e.self:HasItem(22892) then -- All 4 Heads
        e.self:Message(MT.Yellow, "With his last breath, the paladin says, 'You are too late. The last paladin has fled to Natimbi with the staff and is on his way to destroy it!'");
    end
end
