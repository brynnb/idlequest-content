-- Converted from ProjectEQ Perl quest script.
-- Source: erudsxing/a_zombie_sailor.pl
-- items: 13423

function event_combat(e)
	-- The Perl source conditionally adds Blurred Map loot on spawn and only
	-- speaks when that random loot was added. The current Lua capture bridge
	-- does not expose dynamic loot mutation, so keep the combat flavor generic.
	if e.joined then
		e.self:Say("Join.. Glug.. Tombor in his.. watery grave!!")
	end
end

function event_death_complete(e)
	e.self:Say("My map!! You have my.. map.")
end

