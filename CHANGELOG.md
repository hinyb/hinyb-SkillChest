v2.1.8
* Fix sync bugs in the new track API.
* Add cosmic_joke modifier.
* Improve the implementation of time dilation, so it won't decrease the FPS.
* Add phantom_impact modifier.

v2.1.7
* Fix fragile can't be synced correctly in multiplayer.
* Change to new track api. Now blood_lust and perpetual_stike should trigger correctly.
* Make heavy_strike and quick_draw more fun.
* Fix a lot of sync bug.
* Add noxp modifier.

v2.1.6 **Final version of 2024**
* Add blood lust, endest reap and perpetual strike modifiers.
* Balace echo_item, evolving_hunber, flux and fragile.
* Add a check to avoid adding damage modifiers to skills that have no damage.
* Fix void_power can't work porperly.
* Sync random seed when creating.
* Fix echo_item can duplicate items and infinite revive.
* Add heavy_strike and quick_draw modifier.
* Fix totem_of_undying will crash game when the skill have the other modifiers.

v2.1.5
* Add entropy modifier.
* Add lightning fire_trail and explosive_shot.
* Add teleport modifier.

v2.1.4
* Update to RMT 1.2.0.
* Fix evolving_hunger's growth will be reset after being dropped.

v2.1.3
* Fix time_dilation modifier not multiplying correctly.
* Fix some modifiers can't be removed correctly.

v2.1.2
* Fix incorrect proability of flux.
* Improved life_burn, now it only triggers when the stock is 0 and the button is pressed.
* Add totem_of_undying modifier.
* Add time_dilation modifier.
* Fix fragile's sync bug.
* Add some sounds.

v2.1.1
* Fix incorrect proability of evolving_hunger.

v2.1.0
* Refactor SkillModifier.
* Fix incorrect usage of log.error.
* Fix the skill with flux_slot_index can't drop.

v2.0.3
* Delete unnessary sync function.
* Add evolving_hunger modifier.
* Fix flux may crash game and balance flux.

v2.0.2
* Move SkillModifier_Regs from Dropability.

v2.0.1
* Fix sync bug.

v2.0.0
* Add skill modifiers.
* I'm not good at balancing, so It may have many issues.

v1.0.1
* Lowered prices for balance.
* Add the display for the skill's name.

v1.0.0
* First upload.