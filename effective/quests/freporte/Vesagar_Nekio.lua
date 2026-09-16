-- Source: freporte/Vesagar_Nekio.lua
-- P99 audit: Healing (Dismal Rage)

function event_say(e)
	local fac = e.other:GetFaction(e.self)

	if(e.message:findi("hail")) then
		e.self:Say("Welcome into our church of rage. I am Vesagar Nekio. servant of Innoruuk. If you should need me to [cure poison]. [cure disease]. or if you [require healing]. just let me know.")
	elseif(e.message:findi("cure poison") and fac <= 5) then
		e.self:Say("Ally of the Dismal Rage, Be free of poison!!")
		e.self:CastSpell(203,e.other:GetID()) -- Spell: Cure Poison
	elseif(e.message:findi("cure disease") and fac <= 5) then
		e.self:Say("Ally of the Dismal Rage, Be free of disease!!")
		e.self:CastSpell(213,e.other:GetID()) -- Spell: Cure Disease
	elseif(e.message:findi("require healing") and fac <= 5) then
		e.self:Say("If you wish me to lay my hands upon your wounds, you must first lay 10 gold coins upon my palm.")
	elseif((e.message:findi("cure poison") or e.message:findi("cure disease") or e.message:findi("require healing")) and fac > 5) then
		e.self:Say("Blasphemer!! You are no ally of the Dismal Rage. Run while you still have legs!!")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {gold = 10}) then
		if e.other:GetFaction(e.self) <= 5 then
			e.self:Say("Your gold has proven your faith in our ways as well as having made my pockets a bit heavier. Let the power of the Prince of Hate bind your wounds.")
			e.self:CastSpell(17,e.other:GetID()) -- Spell: Light Healing
		else
			e.self:Say("Blasphemer!! You are no ally of the Dismal Rage. Run while you still have legs!!")
			e.other:GiveCash(0,0,10,0)
		end
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

-- END of FILE Zone:freporte -- Vesagar_Nekio
