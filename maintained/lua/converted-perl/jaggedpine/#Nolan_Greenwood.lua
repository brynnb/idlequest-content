-- Converted from ProjectEQ Perl quest script.
-- Source: jaggedpine/#Nolan_Greenwood.pl
-- items: 8761, 8760, 8400

function event_say(e)
	if e.message:findi("hail") then
		e.self:Emote("gives a gentle nod to " .. e.other:GetName())
		e.self:Say("Greetings. I am Nolan Greenwood, warder of the Jaggedpine and retainer of our [ancient ways].")
	elseif e.message:findi("ancient ways") then
		e.self:Say("You must experience and [accept them as your own] to fully understand.")
	elseif e.message:findi("accept them") then
		e.self:Say("I will give you what words I can to guide you through these [trials].")
	elseif e.message:findi("trials") then
		e.self:Say("The natural world will provide the [tools] that aid you.")
	elseif e.message:findi("tools") then
		e.self:Say("If you invest time and prayer to [ask of her], nature shall provide.")
	elseif e.message:findi("ask of her") then
		e.self:Say("My beloved daughter, Cheyloh, and I shall [guide you] through this quest.")
	elseif e.message:findi("guide me") then
		e.self:Say("Acquire and return to me [Silver Griffon Feathers] and a [Jade Studded Rawhide Tunic].")
	elseif e.message:findi("silver griffon") then
		e.self:Say("Put the Silver Griffon to rest and bring me its silver feathers.")
	elseif e.message:findi("jade studded") then
		e.self:Say("Speak to Jhaya Wyndrunner about the Jade Studded Rawhide Tunic.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 8761, item2 = 8760}) then
		e.self:Say("You have done well, " .. e.other:GetName() .. ". I am impressed and most pleased to know that you are adapting and accepting our ways so easily. Take this and may it protect you in these troubling times.")
		e.other:SummonItem(8400)
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
