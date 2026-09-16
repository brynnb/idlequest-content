-- Converted from ProjectEQ Perl quest script.
-- Dialogue/faction-gated teleport to Phara Dar's lair.

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("It is amazing to find outlanders such as yourself this far into the Peak. What is your business here young one? Are you possibly here to [see Phara Dar]?")
	elseif e.message:findi("see Phara Dar") then
		e.self:Say("Interesting, do you have business with her? This door behind me is sealed with a powerful ward, one which only Phara herself can remove. She has instructed me to assist servants of the Ring of Scale with passage into her lair, if they are loyal to us. At the very least you must be friendly with the inhabitants of this place, for you would not be here speaking to me as safely as you are. Are you a [loyal servant] of the Ring of Scale?")
	elseif e.message:findi("loyal servant") and e.other:GetFaction(e.self) == 1 then
		e.self:Say("I see now, yes, you are a loyal servant. I will translocate you into my master's lair when ready.")
	elseif e.message:findi("ready") then
		if e.other:GetFaction(e.self) == 1 then
			e.self:Say("Very well.")
			eq.move_pc(108, -1163.2, -1047.9, 283.0, 127.8)
		else
			e.self:Say("You still need to prove your loyalty to us. I do not feel we can trust you yet, outlander.")
		end
	end
end
