-- Converted from ProjectEQ Perl quest script.
-- Source: qeynos2/Seta_Bakindo.pl
-- P99 audit: Tomer's Rescue
-- Note: IdleQuest currently persists the rescue state but does not physically escort Tomer; eq.follow is a runtime compatibility no-op.

local function qglobal(e, key)
	local qglobals = eq.get_qglobals(e.other)
	return qglobals[key]
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Ah... Welcome friend. I am Master Seta, of the Silent Fist Clan. We know that true strength lies inside your soul. Once you have found and mastered it, your fists will be deadlier than any blade.")
	elseif e.message:findi("Tomer Instogle") then
		e.self:Say("Oh, Tomer? We haven't heard from him in days, I'm really starting to worry. . . We need to have someone go [find him].")
	elseif e.message:findi("find him") then
		e.self:Say("One of our clan brothers has not reported back in over three days. He was sent to help defend the Qeynos Gates, and we haven't heard from him since. We need you to find him, if he is still alive. Tell him that Seta has sent you to find him, and escort him back to our guild. Good luck.")
		eq.set_global("FindTomer", "1", 1, "M30")
	elseif e.message:findi("I have rescued Tomer Instogle") or e.message:findi("I found Tomer") then
		if qglobal(e, "SetaTomer") == "1" or qglobal(e, "SetaTomer") == 1 then
			e.self:Say("Great work " .. e.other:GetName() .. ", we thought that was the last we'd seen of young Tomer.")
			eq.set_global("FindTomer", "2", 1, "M30")
			eq.delete_global("SetaTomer")
		end
	end
end

function event_trade(e)
	local item_lib = require("items")
	item_lib.return_items(e.self, e.other, e.trade)
end
