local blood_lust = SkillModifierManager.register_modifier("blood_lust")
blood_lust:set_add_func(function(data, modifier_index)
    local inst = Instance.wrap(data.skill.parent)
    local num = 8
    InstanceExtManager.add_skill_bullet_callback(data.skill.parent, data.skill.slot_index, data:get_id(modifier_index), "kill",
        function()
            inst:heal(num)
            num = num * 1.5
        end, function()
            num = 8
        end)
end)
blood_lust:set_remove_func(function(data, modifier_index)
    InstanceExtManager.remove_skill_bullet_callback(data.skill.parent, data.skill.slot_index, data:get_id(modifier_index), "kill")
end)
blood_lust:set_check_func(function(skill)
    return Utils.is_can_track_skill(skill.skill_id) and Utils.is_damage_skill(skill.skill_id)
end)
blood_lust:set_monster_check_func(function(skill)
    return false
end)
