-- Source: kaladimb/Kinlo_Strongarm.pl
-- Ranger Epic 1.0: Kinlo handles Enchanted Clay and Refined Mithril Blade steps.
-- Converted from ProjectEQ Perl quest script.
-- items: 5664, 20455, 20478, 20485, 20482, 20483

function event_say(e)
	if e.message:findi("mud") then
		e.self:Say("Eh? Oh, the clay. Arrr. Lots o that mud round 'ere. Mostly, a good dwarf not be needin somethin so soft 'n squishy but the womenfolk, you know, the elves come lookin fer it. If ye be one o' those pansy elves wantin some mud fer workin into fairy statues, flashy trinkets, 'n pig sticker arrers then I can get it for ye. Course I'd be lowerin meself, a good dwarf, ta be diggin that kinda mush outta the ground, but I can do it fer ya.")
	elseif e.message:findi("do it for me") then
		e.self:Say("Arrr. Shaddap. I ain't doin it til ya bring me something. A fee, I guess yed call it, fer lowerin meself ta elf woman work. Go get me a good strong axe and I'll do it fer ye. Mebbe somethin with a good tinted polish on it. I got plenty o' axes but no tinted ones. Har har! Colored axe. Something to go with the color left on the blade after I be crackin open a gobbo head.")
	elseif e.message:findi("ancient") then
		e.self:Say("The ancient smiths, for what I think yer askin about, ain't been around fer a long time, laddy. Last anyone heard o' the ancients was 'fore my time even. There be more than a few tales about 'em.")
	elseif e.message:findi("few tales") then
		e.self:Say("There be some who talk about how the ancient smiths went down to work fer the duke o' below, sayin he be needin some fine dwarven smiths fer makin some castle or some such. There be tales that the ancients were so good at smithin that the duke took 'em down and made 'em head smiths over his minions. There's even tales that some o the smiths' souls were trapped in their hammers, stuck there by some necromancer or somethin, as punishment or retribution.")
	elseif e.message:findi("hammers") then
		e.self:Say("Aye. Some says their souls were bound into their hammers by an Erudite necromancer and enchanter. They say they used the power of the hammers ta profit by makin ships, boats, and houses better than any other merchants. Sad tale, if'n it be true.")
	elseif e.message:findi("erudite necromancer") then
		e.self:Say("I'm not knowin more about the story, lad. Everythin I know is already in what I said. Aye, Erudites. I suppose if yer wantin ta run after shortbeard tales ya can look over on that plague island they call Odus.")
	elseif e.message:findi("erudite enchanter") then
		e.self:Say("I'm not knowing more about the story, lad. Everything I know is already in what I said. Aye, Erudites. I suppose if yer wantin ta run after shortbeard tales you can look over on that plagued island they call Odus.")
	end
end

function event_trade(e)
	local item_lib = require("items")
	if item_lib.check_turn_in(e.trade, {item1 = 5664}) then
		e.self:Say("Arrrrr. Ooooo. Arrrrrr... Yah, now that's what I be callin a good lookin axe. I be crackin a few skulls with this one. Oh, here's yer block o' mud. Our priests o' Brell use the mud pit fer relievin themselves after really hard ale blessin ceremonies, so ya ain't got ta be enchantin it in holy water or anythin cause they already have. Har har!")
		e.other:SummonItem(20455) -- Enchanted Clay
	elseif item_lib.check_turn_in(e.trade, {item1 = 20478}) then
		e.self:Emote("examines the hammer respectfully, admiring its craftsmanship. He strikes it against his anvil and winces as a howl fills the air. 'This is one of the ancients' hammers? I can almost, well, almost hear it callin ta me. It's strong, that's fer sure, lad. I don't know how ye got it, but aye, a dwarf could make a mighty blade with this. It's lookin like this thing still has its owner inside it though. I'm not knowin how, and not wantin to know, but fer yer own good ye better find some way ta get 'im out.'")
		e.other:SummonItem(20478) -- Soulbound Hammer
	elseif item_lib.check_turn_in(e.trade, {item1 = 20485}) then
		e.self:Emote("looks at the hammer and nods once before slamming the head against his anvil, and shattering the head. In a cloud of dust, another dwarf appears from the cloud and tosses you a hunk of metal. Kinlo stares in awe.")
		e.other:SummonItem(20482) -- Small bit of Mithril Ore
		eq.spawn2(67089, 0, 0, -189.5, 346.8, 1.8, 69) -- Usbak_the_Old
	elseif item_lib.check_turn_in(e.trade, {item1 = 20482}) then
		e.self:Say("Erm. Well, I aint never worked with this stuff but here's what I got for ya. It ain't bad, pretty much like the one ye got there. I suppose ye should take the one the ancient made and show it ta yer friend.")
		e.other:SummonItem(20483) -- Refined Mithril Blade
	end
	item_lib.return_items(e.self, e.other, e.trade)
end
