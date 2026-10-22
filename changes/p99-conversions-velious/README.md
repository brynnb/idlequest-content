# Focused Velious conversions

Seven Lua sources are proposed: six missing conversions plus P99-authored Adia.
Kardakor is intentionally not converted; four connected ambient sources remain runtime-blocked.
See `review.json` for every reviewed candidate, exact baseline NPC IDs, item IDs,
evidence hashes, open questions and separate verification levels.

- Souvenir Mugs: Tobart Dirkins and Loremaster Fronden accept one platinum for
  item 30146; Doogle McBanick accepts three gold for item 30147. P99 explicitly
  documents Fronden giving the apparently wrong tavern mug; retain that result.
- Learn the Ways of Skinning and Tailoring: Errgriz accepts one item 30023 for
  30037; the discovery chain is reachable through bracketed dialogue phrases.
- Tiny Savages: Kaavin and Darral receive flavor hails and return-all handlers.
  They remain kill targets, not invented hand-in quest givers. Yetarr unchanged.
- Ralgyn's Promise: do not convert Kardakor. The cached checklist explicitly
  calls this branch post-Velious. Ralgyn and Rolandal unchanged.

All existing upstream ambient Fronden/Doogle signal branches remain in the
conversions. The event target IDs exist and signal delays preserve milliseconds.
Their broader Horasug/Rumagur waypoint story remains incomplete: recipient Lua
is absent. That is an open lifecycle boundary, not a justification to discard
supported source behavior.

No XP, faction amounts, reward probabilities, new level gates, or unknown item
IDs are invented. The existing item helper controls consumption/return. No
atomicity, live server, rendered UI, or whole-chain claim follows from an isolated
Lua mock or compiler pass. Baseline remains unchanged, proposals not applied.

Adia Coldbeard NPC115140 now has proposed quest row503524 and an idlequest-authored
source: five gold returns item30145. This fills the fourth documented mug exchange;
the unknown Velium Keg acquisition path remains explicitly unresolved.
