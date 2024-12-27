-- Some skills may be missing
local non_instant_skills = {
    [39] = true, -- handX
    [43] = true, -- handX2
    [44] = true, -- handX3
    [45] = true, -- handX4
    [51] = true, -- engineerV
    [52] = true, -- engineerVBoosted
    [55] = true, -- engineerV2
    [56] = true, -- engineerV2Boosted
    [77] = true, -- acridC -- need to fix
    [95] = true, -- loaderV
    [96] = true, -- loaderVBoosted
    [99] = true, -- loaderV2
    [100] = true, -- loaderV2Boosted
    [147] = true -- monsterLemurianRiderLemC -- need to fix
}
Utils.is_instant_skill = function (skill_id)
    return not non_instant_skills[skill_id]
end
local no_damage_skills = {
    [3] = true, -- commandoC
    [7] = true, -- commandoC2
    [12] = true, -- enforcerC
    [27] = true, -- banditC2
    [32] = true, -- huntressC
    [40] = true, -- handC
    [68] = true, -- sniperV
    [69] = true, -- sniperVBoosted
    [90] = true, -- mercenaryV2
    [91] = true, -- mercenaryV2Boosted
    [93] = true, -- loaderX
    [103] = true, -- chefC
    [104] = true, -- chefV
    [105] = true, -- chefVBoosted
    [107] = true, -- chefC2
    [112] = true, -- pilotC
    [116] = true, -- pilotC2
    [131] = true, -- drifterV
    [132] = true, -- drifterVBoosted
    [135] = true, -- drifterV2
    [136] = true, -- drifterV2Boosted
    [140] = true, -- robomandoC
    [141] = true, -- robomandoV
    [142] = true -- robomandoVBoosted
}
Utils.is_damage_skill = function (skill_id)
    return not no_damage_skills[skill_id]
end