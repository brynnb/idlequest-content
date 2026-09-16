-- Source: qeynos2/Roesager_Thusten.lua
-- P99 audits: Putrid Skeletons, Plaguebringer Proof
-- items: 18970, 18802, 14007
function event_say(e)
	if(e.message:findi("hail")) then
		e.self:Say("Hail. " .. e.other:GetCleanName() .. "!  My name is Roesager Thusten. Paladin of Life.  I am a loyal servant of the Prime Healer and I seek to destroy all who wish to bring death and disease to the land of Norrath.");
	elseif(e.message:findi("prime healer")) then
		e.self:Say("Rodcet Nife is the Prime Healer.  It is He who gives us the power to resist the decay and death that Bertoxxulous has released upon Norrath.  The Temple of Life is dedicated to His honor.");
	elseif(e.message:findi("bertoxxulous")) then
		e.self:Say("Bertoxxulous is a vile creature who rules the Plane of Disease. His filthy followers are spreading their stain across all of Norrath. We fear they are already here in Qeynos.");
	elseif(e.message:findi("death and disease") or e.message:findi("brings disease") or e.message:findi("plaguebringers")) then
		e.self:Say("The Plaguebringers are followers of the disease lord, Bertoxxulous. We believe a sect of them now operates in Qeynos, but we need proof before we can act.");
	elseif(e.message:findi("proof")) then
		e.self:Say("Someone reported seeing a Plaguebringer roaming about in the hills near Qeynos. We have long suspected that their dark influence was spreading. I am searching for proof that they are now here in Qeynos. If you find anything, please bring it to me at the Temple of Life.");
	elseif(e.message:findi("temple of life")) then
		e.self:Say("The Temple of Life, dedicated to the glory of the Prime Healer, is in the heart of North Qeynos. Enter the glowing disks above the Pool of Jahnda and you will magically appear inside the temple.");
	elseif(e.message:findi("niclaus")) then
		if(e.other:GetFaction(e.self) < 5) then
			e.self:Say("Niclaus Ressinn? Have you seen him? He is one of our paladins who was sent out to investigate the undead sightings in Qeynos Hills. I have a message from Jahnda for him, but I must continue my own search here in Qeynos. Could you take this to Niclaus? Your help would be appreciated.");
			e.other:SummonItem(18970);
		else
			e.self:Say("The Temple of Life smiles upon you, friend... but such a delicate matter can only be entrusted to our most loyal members.");
		end
	end
end

function event_trade(e)
	local item_lib = require("items");
	if(item_lib.check_turn_in(e.trade, {item1 = 18802})) then
		e.self:Say("Rodcet be praised!! This is what we have been searching for! On behalf of the Temple of Life, let me thank you and offer you this small reward for your aid in our war against the Plaguebringer.");
		e.other:Faction(341, 10, 0); -- Priests of Life
		e.other:Faction(280, 10, 0); -- Knights of Thunder
		e.other:Faction(262, 10, 0); -- Guards of Qeynos
		e.other:Faction(221, -10, 0); -- Bloodsabers
		e.other:Faction(219, 10, 0); -- Antonius Bayle
		e.other:GiveCash(0, 3, 0, 0);
		e.other:SummonItem(14007); -- Potion of Light Healing
		e.other:AddEXP(500);
		e.other:Ding();
	end
	item_lib.return_items(e.self, e.other, e.trade);
end
