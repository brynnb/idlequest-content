-- Converted from ProjectEQ Perl quest script.
-- Source: firiona/Hero_Goxnok.pl

function event_say(e)
	if e.message:findi("news of the charasis tome") then
		e.self:Say("The Charasis Tome has been scribed and now another copy exists. The traitor obviously wants to keep a copy for himself. I am told you will deliver both copies to Lord Qyzar along with your zealot khukri and you shall be awarded that of a crusader. Let us rest for a minute and then I shall show you the meeting place.")
		eq.start(215)
		e.self:SetAppearance(1)
		e.self:Say("Come along. If we get separated, look for the humanoid wolf camp and beyond the tunnel, you shall find the meeting place of the spider riders and the traitor.")
		eq.set_timer("Talk1", 180000)
	end
end

function event_signal(e)
	if e.signal == 0 then
		eq.spawn2(84401, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading()) -- #Hero_Goxnok
		eq.depop()
	end
end

function event_timer(e)
	if e.timer == "Talk1" then
		e.self:Emote("stops abruptly and shudders with fear. 'Look!! There, past the wolf people. Near an ancient tunnel can be found the meeting place. I fear we may be too late. I thought I saw a shadow dash from the tunnels, but I did not see any spider riders. We'll see when we reach it.'")
		eq.stop_timer("Talk1")
		eq.set_timer("Talk2", 30000)
	elseif e.timer == "Talk2" then
		e.self:Emote("looks over at you and sizes you up before continuing on. He says, 'We should continue, follow me.'")
		eq.stop_timer("Talk2")
	end
end
