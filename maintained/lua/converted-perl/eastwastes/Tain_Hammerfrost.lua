-- P99 Coldain Ring Quests, fourth ring. Original ProjectEQ Perl is preserved.
-- P99 specifies Ghrek plus THREE giants, not the upstream four. Coordinates,
-- timers and reward amounts retain the upstream source where P99 is silent.
-- Wounded/standing poses are deferred (SetAppearance has no delivered effect).
-- Each attacker's guard spot is its nearby approach endpoint, rather than the
-- Perl's separate SaveGuardSpot at Tain. No silent no-op is used for either.
local item_lib = require("items")
local helping = false
local rewarded = false

function event_spawn(e)
  helping = false
  rewarded = false
  eq.set_timer("moan", 60000)
end

function event_say(e)
  if e.message:findi("hail") then
    e.self:Say("The bloody Kromrif ambushed me! I escaped, but I am near death. They'll be tracking me down to finish me off at any moment. Without [help], I'm as good as dead.")
  elseif e.message:findi("help") and not helping and not rewarded then
    helping = true
    eq.set_timer("help", 600000)
    e.self:Say("Thank Brell! I hear them approaching from just over that hill! Slay the leader, Ghrek, and give me his elixir.")
    local attackers = {
      {116560, -4837, -2681, -4944},
      {116030, -4815, -2703, -4920},
      {116030, -4793, -2697, -4890},
      {116030, -4859, -2707, -4950},
    }
    for _, entry in ipairs(attackers) do
      local attacker = eq.spawn2(entry[1], 0, 0, -2991, entry[2], 229, 130)
      -- Ordinary NPC hostility observes Tain during this walk. An unconditional
      -- AddToHateList would aggro him remotely before the attackers arrive.
      attacker:MoveTo(entry[3], entry[4], 150, 130, true)
    end
  end
end

function event_trade(e)
  if not rewarded and helping and item_lib.check_turn_in(e.trade, {item1 = 30138}) then
    rewarded = true
    helping = false
    eq.stop_timer("moan")
    eq.stop_timer("help")
    e.self:Say("I will report your selfless actions when I return to Thurgadin. Take this for your troubles, friend. I hope you find it useful. Fare thee well.")
    e.other:SummonItem(30140)
    e.other:Faction(406, 30)
    e.other:Faction(405, 30)
    e.other:Faction(419, -30)
    e.other:Faction(448, -30)
    e.other:AddEXP(80000)
    eq.set_timer("leave", 15000)
  elseif item_lib.check_turn_in(e.trade, {item1 = 30139}) then
    -- P99: the note is optional and does not start the encounter.
  end
  item_lib.return_items(e.self, e.other, e.trade)
end

function event_timer(e)
  if e.timer == "moan" then
    e.self:Say("Ohhhh, someone... help, please...")
  elseif e.timer == "help" then
    eq.stop_timer("help")
    helping = false
  elseif e.timer == "leave" then
    eq.stop_timer("leave")
    eq.depop_with_timer()
  end
end

function event_death_complete(e)
  eq.stop_timer("moan")
  eq.stop_timer("help")
  eq.stop_timer("leave")
end
