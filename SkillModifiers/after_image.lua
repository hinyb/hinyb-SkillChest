local after_image = SkillModifierManager.register_modifier("after_image", 250)
after_image.max_stack = 2
after_image.duration_multiplier = 1.0
after_image:set_add_func(function (data, modifier_index)
    data:add_pre_activate_callback(function (data)
        gm.apply_buff(data.skill.parent, 44.0, data.skill.cooldown_base * after_image.duration_multiplier)
    end)
end)
after_image:set_check_func(function (skill)
    return SkillModifierManager.count_modifier(skill, "after_image") < after_image.max_stack
end)
after_image:register_component(ComponentTemplates.create_modifier_int_component("after_image_max_stack", "max_stack", "This modifier can be applied to a skill's max stack."))
after_image:register_component(ComponentTemplates.create_modifier_double_component("after_image_duration_multiplier", "duration_multiplier"))