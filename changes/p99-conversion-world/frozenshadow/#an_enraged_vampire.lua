-- name: #an_enraged_vampire
-- Source: sources/projecteq/frozenshadow/#an_enraged_vampire.pl
-- Source SHA256: 6e2b554ab7a9d0d72de10a73fdbcfc7db35776126fad4784b992a940f5ae1881
-- P99 conversion review: changes/p99-conversion-world/closure-review.json
-- Preserve the random cosmetic gender intent with the established Lua illusion API.
-- Current IdleQuest SendIllusionPacket is a no-op: translated, NOT visually delivered.
-- The hash and plain actor variants remain separate runtime keys.
function event_spawn(e)
  e.self:SendIllusionPacket({gender = eq.ChooseRandom(0, 1)})
end
