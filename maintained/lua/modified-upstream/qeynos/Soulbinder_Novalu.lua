-- Modified from ProjectEQ Lua quest script.
-- Source: qeynos/Soulbinder_Novalu.lua

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Greetings " .. e.other:GetName() .. ". When a hero of our world is slain their soul returns to the place it was last bound and the body is reincarnated. As a member of the Order of Eternity  it is my duty to [bind your soul] to this location if that is your wish.")
	elseif e.message:findi("bind my soul") then
		e.self:Say("Binding your soul. You will return here when you die.")
		eq.self_cast(2049) -- Bind Affinity visual/effect capture
		eq.bind_player()
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
