-- enabled: false
-- name: Lieutenant_Krofer
-- Source: sources/projecteq/wakening/Lieutenant_Krofer.pl
-- Source SHA256: 1a9060e3ca8990dd0d804c3590f59472a54f494fb86bfe5fddf1e4265845339a
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Authorized caller extension: preserve signed requisition, four distinct actors,
-- mission report and signal-driven replacement. P99 says the meat/messenger parts
-- are optional; prepared does not require the artificial tunarean_regiment global.
-- Keep meat-assignment state, check it BEFORE consuming inputs, and return extras.
-- P99 meat payment is10pp2gp1cp; other XP/cash/deltas remain explicitly upstream.
-- Faction locks omitted per repository policy. The staged replacement preserves
-- the walkthrough warning against an immediate mission-report turn-in.
local item_lib = require("items")
local function faction_reward(e)
  e.other:Faction(448, 10); e.other:Faction(419, 10)
  e.other:Faction(429, 10); e.other:Faction(430, -30)
end
function event_say(e)
  if e.message:findi("hail") then e.self:Say("Unless you're the new mercenary reinforcements I suggest you remove yourself from my presence before I decorate the bottom of my boot with your intestines.")
  elseif e.message:findi("next assignment") then e.self:Say("Well, ready or not, this must be done now. Out there in the forest are our enemies. For us to be successful, we must know what they are doing and how they are going about it. Our probing attacks have revealed little so we've decided to send you out to gather any info you can. There must be some sort of messenger out there, bring any info you might find.")
  elseif e.message:findi("prepared") then
    e.self:Say("Very well. We've decided to attack the small Sifaye village northeast of here and I want you to coordinate the attack. I will send you into Kael Drakkel with a request for troop assistance. After the squad is assembled you will lead them to the staging point where you will oversee the battle. Here is the request. Take it to Drioc in the city and return here with the troops.")
    e.other:SummonItem(1706)
  end
end
function event_trade(e)
  local qglobals = e.qglobals or {}
  if item_lib.check_turn_in(e.trade, {item1 = 1702}) then
    e.self:Say("Drioc sent you? I suppose one can't expect much from a mercenary. Well then, " .. e.other:GetCleanName() .. ", your first assignment will be to clear out some of this forest's annoying populace. Bring me the meat of one of the raptors, the meat of two panthers, and the remains of one of those living puddles of black sludge found in the caves. You will then have your payment.")
    e.other:AddEXP(1000); e.other:Ding()
    eq.set_global("krofer_assignment", "1", 0, "F")
  elseif qglobals.krofer_assignment and item_lib.check_turn_in(e.trade, {item1 = 22851, item2 = 22851, item3 = 22852, item4 = 1703}) then
    e.self:Say("Well, I suppose you may be worth something more than fodder after all. Here is your payment. Speak to me again when you are ready for your next assignment. For now, get some rest, you will need it.")
    e.other:Ding(); faction_reward(e); e.other:AddEXP(1000)
    e.other:GiveCash(1, 0, 2, 10)
    eq.delete_global("krofer_assignment")
    eq.set_global("tunarean_regiment", "1", 0, "F")
  elseif item_lib.check_turn_in(e.trade, {item1 = 1704}) then
    e.self:Say("Excellent, " .. e.other:GetCleanName() .. ". With this we can plan an attack that might actually accomplish something. Here is your payment. You have also earned this cloak, it should help protect you from the clawing undergrowth of this savage land. Your next mission will be more complex and dangerous, however we may be able to spare a laborer or two to assist you. Rest now, and tell me when you are prepared.")
    e.other:Ding(); faction_reward(e); e.other:AddEXP(1000)
    e.other:GiveCash(0, 5, 4, 11)
    e.other:SummonItem(1705)
  elseif item_lib.check_turn_in(e.trade, {item1 = 1707}) then
    e.self:Emote("takes the note and looks it over, then sighs and says, 'This will have to be enough. The squad should be here shortly. When they arrive you will march with them to the staging area near the village of those insect Sifaye. When you are satisfied with the formation, give the corporal the order to attack and observe the battle. After the village is destroyed return this report to me and we'll plan our next move.'")
    e.other:AddEXP(1000); e.other:Ding(); e.other:SummonItem(1708)
    eq.spawn2(119168, 0, 0, -4975, -699, -182, 126)
    eq.spawn2(119166, 0, 0, -4954, -697, -182, 126)
    eq.spawn2(119167, 0, 0, -4954, -671, -182, 126)
    eq.spawn2(119169, 0, 0, -4976, -672, -182, 126)
  end
  item_lib.return_items(e.self, e.other, e.trade)
end
function event_signal(e)
  eq.spawn2(119173, 0, 0, e.self:GetX(), e.self:GetY(), e.self:GetZ(), e.self:GetHeading())
  eq.depop_with_timer()
end
