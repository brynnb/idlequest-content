-- Converted from ProjectEQ Perl quest script.
-- Source: neriaka/Guard_Lumpin.pl

function event_aggro(e)
	e.self:Say("Die, like the fool you are!")
end

function event_say(e)
	if e.message:findi("hail") then
		e.self:Say("Hullo citizen. Me am here to guard you so puts away any wepuns.")
	elseif e.message:findi("happy love bracers") then
		e.self:Say("Hmm... Me seen green bracers on troll named [Ratraz].")
	elseif e.message:findi("ratraz") then
		e.self:Say("Ratraz is dumb troll who werk in dark elf bar. Him tink he smart because dark elves raise him. Tink he know everyting. Him just as stewpid as all us trolls is!")
	end
end

function event_death_complete(e)
	e.self:Say("My comrades will avenge my death.")
end
