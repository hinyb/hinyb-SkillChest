-- Some skills may be missing
local instant_damage_skills = {
    [23] = true, -- banditC -- need to fix
    [39] = true, -- handX
    [43] = true, -- handX2
    [44] = true, -- handX3
    [45] = true, -- handX4
    [49] = true, -- engineerX
    [51] = true, -- engineerV
    [52] = true, -- engineerVBoosted
    [54] = true, -- engineerX2
    [55] = true, -- engineerV2
    [56] = true, -- engineerV2Boosted
    [77] = true, -- acridC -- hard to fix, this skill don't use damager_attack_process. -- apply_buff on_activate
    [95] = true, -- loaderV
    [96] = true, -- loaderVBoosted
    [99] = true, -- loaderV2
    [100] = true, -- loaderV2Boosted
    [147] = true -- monsterLemurianRiderLemC -- need to fix
}
Utils.is_non_instant_damage_skill = function(skill_id)
    return not instant_damage_skills[skill_id]
end
local summon_skills = {
    [39] = true, -- handX
    [43] = true, -- handX2
    [44] = true, -- handX3
    [45] = true, -- handX4
    [49] = true, -- engineerX
    [51] = true, -- engineerV
    [52] = true, -- engineerVBoosted
    [54] = true, -- engineerX2
    [55] = true, -- engineerV2
    [56] = true, -- engineerV2Boosted
    [95] = true, -- loaderV
    [96] = true, -- loaderVBoosted
    [99] = true, -- loaderV2
    [100] = true, -- loaderV2Boosted
    [129] = true, -- drifterX
    [133] = true -- drifterX2
}
Utils.is_summon_skill = function(skill_id)
    return summon_skills[skill_id]
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
Utils.is_damage_skill = function(skill_id)
    return not no_damage_skills[skill_id]
end
local instance_list = {}
local instance_create_flag = false
local instance_filter = {}
Utils.hook_instance_create = function(filter)
    instance_filter = filter or {}
    instance_create_flag = true
end
Utils.get_tracked_instances = function()
    return instance_list
end
Utils.unhook_instance_create = function()
    instance_create_flag = false
    instance_list = {}
end
gm.post_script_hook(gm.constants.instance_create, function(self, other, result, args)
    if instance_create_flag and not Helper.table_has(instance_filter, result.value.object_index) then
        table.insert(instance_list, result.value)
    end
end)
