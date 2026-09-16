-- Source: halas/Kevan_McPherson.lua
-- items:
function event_say(e)
	if (e.message:findi("hail")) then
		e.self:Say("Well met, " .. e.other:GetName() .. "! I'm Kevan McPherson, the best darn smith in the north. Have ye come to purchase my finely crafted weapons or are ye wanting me ta teach ya the secrets of Northman smithing?");
	elseif (e.message:findi("northman kite shield")) then
		e.self:Say("To smith a Northman kite shield ye'll need a kite shield mold, a smithy hammer, a flask of water and a medium quality folded sheet metal. Remember ye'll have ta smith the metal sheet in a regular forge and finish the shield in our special Northman forge.");
	end
end
