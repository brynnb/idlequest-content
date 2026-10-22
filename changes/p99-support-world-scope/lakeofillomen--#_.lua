-- enabled: false
-- P99 scope: exclusive later epic hook. Historical callbacks retained below; see p99-support-source-review/world-scope-dispositions.json.
-- Source: lakeofillomen/#_.pl
-- Converted from ProjectEQ Perl quest script.
-- items: 16675

local character_active = false

function event_spawn(e)
	eq.set_timer("laydown", 1)
end

function event_timer(e)
	if e.timer == "laydown" then
		eq.stop_timer("laydown")
		e.self:SetAppearance(3)
	end
end

function event_combat(e)
	character_active = e.joined == true
end

function event_death_complete(e)
	if character_active and e.other:GetGlobal("wiz_epic_pre") == "2" then
		local scorpions = {
			eq.spawn2(85240, 0, 0, 4949.8014, -2423.8932, 225, 321.5),
			eq.spawn2(85240, 0, 0, 4905.3961, -2404.0442, 225, 259),
			eq.spawn2(85240, 0, 0, 4859.6490, -2420.5676, 225, 196.5),
			eq.spawn2(85240, 0, 0, 4838.1767, -2464.2111, 225, 134),
			eq.spawn2(85240, 0, 0, 4853.0025, -2510.5362, 225, 71.5),
			eq.spawn2(85240, 0, 0, 4895.8248, -2533.6028, 225, 9),
			eq.spawn2(85240, 0, 0, 4942.6649, -2520.4946, 225, 458.5),
			eq.spawn2(85240, 0, 0, 4967.2944, -2478.5517, 225, 396),
			eq.spawn2(85240, 0, 0, 4955.9218, -2431.2603, 225, 333.5),
			eq.spawn2(85240, 0, 0, 4914.9153, -2405.1014, 225, 271),
			eq.spawn2(85240, 0, 0, 4867.2368, -2414.7230, 225, 208.5),
			eq.spawn2(85240, 0, 0, 4839.5841, -2454.7374, 225, 146),
			eq.spawn2(85240, 0, 0, 4847.4416, -2502.7382, 225, 83.5),
			eq.spawn2(85240, 0, 0, 4886.4094, -2531.8470, 225, 21),
			eq.spawn2(85240, 0, 0, 4934.6672, -2525.7643, 225, 470.5),
			eq.spawn2(85240, 0, 0, 4965.1928, -2487.8960, 225, 408),
			eq.spawn2(85240, 0, 0, 4960.8931, -2439.4468, 225, 345.5),
			eq.spawn2(85240, 0, 0, 4924.1758, -2407.5461, 225, 283),
			eq.spawn2(85240, 0, 0, 4875.6010, -2410.0569, 225, 220.5),
			eq.spawn2(85240, 0, 0, 4842.3684, -2445.5733, 225, 158),
			eq.spawn2(85240, 0, 0, 4843.0869, -2494.2076, 225, 95.5),
			eq.spawn2(85240, 0, 0, 4877.3541, -2528.7268, 225, 33),
			eq.spawn2(85240, 0, 0, 4925.9819, -2529.8016, 225, 482.5),
			eq.spawn2(85240, 0, 0, 4961.7408, -2496.8301, 225, 420),
			eq.spawn2(85240, 0, 0, 4964.6074, -2448.2750, 225, 357.5),
			eq.spawn2(85240, 0, 0, 4932.9765, -2411.3250, 225, 295),
			eq.spawn2(85240, 0, 0, 4884.5601, -2406.6705, 225, 232.5),
		}
		local random = math.random(#scorpions)
		for index, scorpion in ipairs(scorpions) do
			scorpion:AddToHateList(e.other, 1)
			if index == random then
				scorpion:AddItem(16675, 1) -- Cursed Talisman
			end
		end
	end
end
