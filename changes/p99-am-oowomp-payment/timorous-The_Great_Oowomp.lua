-- Converted from ProjectEQ Perl quest script.
-- Source: timorous/The_Great_Oowomp.pl
-- items: 12942, 12945, 12944, 12943, 12941

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("gestures as if casting a powerful spell...")
		e.self:Say("Come forward, adventurer! Come and [see the dancing skeleton]. I shall cast a powerfull spell and bring forth this operatic, clattering jumble of bones and he shall do a fine dance for you. From the nether regions and planes beyond, I call forth this bardic, magical, rhyming, tap-dancing hunk of undead!! I am Oowomp the Great!!")
	elseif e.message:findi("see the dancing skeleton") then
		e.self:Say("Oh!!  You wish to see the great Oowomp perform his magic!! I have studied with the grand mages and wise [McMerin clan] of Norrath. as my speech implies. I can call forth the skeleton with but a twinkling of my power and five of your gold.")
	elseif e.message:findi("McMerin clan") then
		e.self:Say("Clan McMerin were wise shamans from the North. They allowed me to study with them. I learned many spells while I communed with them.  From them, I sto.., I mean, I learned the secret of McMerin's Feast. If you want to know the secret, you could [help gather components] for future rituals.")
	elseif e.message:findi("help gather components") then
		e.self:Say("Actually... Not so much help as do - ALL - of the gathering. In the lands of Kunark are clay of Ghiosk, crushed dread diamond and powder of Yun. A rare find would be the bones of one who touched the Bath of Obulus. Find and return these to me and the shaman secret of McMerin's Feast is yours.")
	end
end

-- P99 permits five gold or equivalent. Consume offered money through the
-- authoritative matcher, then return exact change; never mutate trade fields.
local function pay_for_skeleton(e, item_lib)
    local p, g = e.trade.platinum or 0, e.trade.gold or 0
    local s, c = e.trade.silver or 0, e.trade.copper or 0
    local total = p * 1000 + g * 100 + s * 10 + c
    if total < 500 then return false end
    if not item_lib.check_turn_in(e.trade, {platinum=p, gold=g, silver=s, copper=c}) then
        return false
    end
    local change = total - 500
    if change > 0 then
        local cp = change % 10
        local sp = math.floor(change / 10) % 10
        local gp = math.floor(change / 100) % 10
        local pp = math.floor(change / 1000)
        e.other:GiveCash(cp, sp, gp, pp)
    end
    return true
end

function event_trade(e)
	local item_lib = require("items")
	if pay_for_skeleton(e, item_lib) then
		e.self:Emote("flings the coins into the air and they all fall neatly into his oversized coin pouch. <Tink, tink, tink, tink, TINK!!>")
		e.self:Say("Gaze upon my awsome powers of the arcane!! You shall see my power. Allakabam!!")
		eq.spawn2(96088, 0, 0, 3122.8, 5725.2, 7.9, 13.0)
		eq.set_timer("1", 3000)
	elseif item_lib.check_turn_in(e.trade, {item1 = 12942, item2 = 12945, item3 = 12944, item4 = 12943}) then
		e.self:Say("Ahh, you've gathered all the ritual components. Very good, as promised, a cop...I mean, priceless scroll of McMerin's Feast for you!")
		e.other:SummonItem(12941)
		e.other:AddEXP(45000)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
	if e.timer == "1" then
		eq.signal(96088, 5)
		eq.stop_timer("1")
	end
end
