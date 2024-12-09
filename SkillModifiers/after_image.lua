local after_image = SkillModifierManager.register_modifier("after_image", 250)
after_image:set_add_func(function (data, modifier_index)
    data:add_pre_activate_callback(function (data)
        gm.apply_buff(data.skill.parent, 44.0, data.skill.cooldown_base)
    end)
end)
after_image:set_check_func(function (skill)
    return SkillModifierManager.count_modifier(skill, "after_image") < 2
end)