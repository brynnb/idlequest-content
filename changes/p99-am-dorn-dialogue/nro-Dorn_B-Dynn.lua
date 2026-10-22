-- Authored from cached P99 Marda's Secret Mission; no retained upstream source exists.
-- Existing Dorn NPC/spawn records only; no new NPC or exclusion removal.
-- Public password dialogue only. Missing Marda note odds/XP/faction magnitudes are not invented.
function event_say(e)
  if e.message:findi("hail") then
    e.self:Say("Just who are you? Do you expect some sort of courteous greeting? I have no time for idle chitchat!! Either you are here to attend to [business] or you seek shelter, which is it?")
  elseif e.message:findi("business") then
    e.self:Say("So, business is your mission! I have never met you. Who sent you?")
  elseif e.message:findi("zimbittle sent me") then
    e.self:Say("I do not know if I could trust you. You certainly do not look as though you are from Grobb, although your stench does hint of that place. If you are truly sent by Zimbittle, what is the passwrod?")
  elseif e.message:findi("mukk") then
    e.self:Say("So you were sent by Zimbittle. Take this note Kraagia of Da Bashers in Grobb. Do not lose the note. If it were to fall into the wrong hands of [Goonda], this whole plan could be disrupted. Now, leave, I can no longer tolerate you foul stench!")
    e.other:SummonItem(18886) -- Sealed Letter; Marda does not accept this note on P99.
  elseif e.message:findi("goonda") then
    e.self:Say("In the western planes of Karana, you will find Goonda. He seems to be the Ogre shaman in charge out there.")
  end
end

function event_trade(e)
  local item_lib = require("items")
  item_lib.return_items(e.self, e.other, e.trade)
end
