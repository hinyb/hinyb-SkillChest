local blood_lust = SkillModifierManager.register_modifier("blood_lust")
blood_lust:set_add_func(function(data, modifier_index)
    local id_prefix = "blood_lust" .. tostring(data.skill.slot_index) .. tostring(modifier_index)
    local num = 8
    local inst = Instance.wrap(data.skill.parent)
    Instance_ext.add_skill_bullet_kill(data.skill.parent, data.skill.slot_index, id_prefix, function()
        inst:heal(num)
        num = num * 1.5
    end, function ()
        num = 8
    end)
end)
blood_lust:set_remove_func(function (data, modifier_index)
    local id_prefix = "blood_lust" .. tostring(data.skill.slot_index) .. tostring(modifier_index)
    Instance_ext.remove_skill_captrue(data.skill.parent, data.skill.slot_index, id_prefix)
end)
blood_lust:set_check_func(function(skill)
    return (Utils.is_non_instant_damage_skill(skill.skill_id) or Utils.is_summon_skill(skill.skill_id)) and
               Utils.is_damage_skill(skill.skill_id)
end)
blood_lust:set_monster_check_func(function(skill)
    return false
end)