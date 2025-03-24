local blood_lust = SkillModifierManager.register_modifier("blood_lust")
blood_lust.base_heal = 8
blood_lust.heal_increase_multiplier = 1.5
blood_lust:set_add_func(function(data, modifier_index)
    local inst = Instance.wrap(data.skill.parent)
    local num = blood_lust.base_heal
    InstanceExtManager.add_skill_bullet_callback(data.skill.parent, data.skill.slot_index, data:get_id(modifier_index),
        "kill", function()
            inst:heal(num)
            num = num * blood_lust.heal_increase_multiplier
        end)
    data:add_pre_activate_callback(function(data)
        num = blood_lust.base_heal
    end)
end)
blood_lust:set_remove_func(function(data, modifier_index)
    InstanceExtManager.remove_skill_bullet_callback(data.skill.parent, data.skill.slot_index,
        data:get_id(modifier_index), "kill")
end)
blood_lust:set_check_func(function(skill)
    return Utils.is_can_track_skill(skill.skill_id) and Utils.is_damage_skill(skill.skill_id)
end)
blood_lust:set_monster_check_func(function(skill)
    return false
end)
blood_lust:register_component(ComponentTemplates.create_modifier_double_component("blood_lust_base_heal", "base_heal"))
blood_lust:register_component(ComponentTemplates.create_modifier_double_component("blood_lust_heal_increase_multiplier", "heal_increase_multiplier"))
