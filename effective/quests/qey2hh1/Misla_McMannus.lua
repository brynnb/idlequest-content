-- Modified from ProjectEQ Lua to supply Lion Meat Shipment per P99.
-- Source: qey2hh1/Misla_McMannus.lua
-- P99: https://wiki.project1999.com/Lion_Meat_Shipment_Quest
-- items: 13961

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hello. You look a mite scrawny. You should purchase some fishcakes. They will add muscle to your frame.")
	elseif e.message:findi("pick up the lion meat shipment for Halas") or e.message:findi("deliver the lion meat to Halas") or e.message:findi("lion meat shipment") then
		e.self:Say("Very well, then. Here you go. Be sure to deliver this to Teria O'Danos. She will be one of the first people you meet in Halas.")
		e.other:SummonItem(13961) -- Lion Meat Shipment
	end
end
