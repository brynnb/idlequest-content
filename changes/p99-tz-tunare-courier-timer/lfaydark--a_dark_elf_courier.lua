-- Converted from ProjectEQ Perl quest script.
-- Source: lfaydark/a_dark_elf_courier.pl

function event_spawn(e)
	eq.set_timer("CourierDepop", 10000)
	e.self:SetRunning(true)
end

function event_timer(e)
	if e.timer ~= "CourierDepop" then return end
	if e.self:GetX() == 1150 and e.self:GetY() == -885 then
		eq.stop_timer("CourierDepop")
		eq.depop()
	end
	e.self:SetRunning(true)
end

function event_trade(e)
	e.self:ReturnHandinItems(e.other)
end
