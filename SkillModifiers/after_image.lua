SkillModifier.register_modifier("after_image", 250, function(skill)
    return SkillModifier.get_modifier_num("after_image") < 2
end, function(skill, data)
    SkillModifier.add_on_activate_callback(data, function(skill_)
        gm.apply_buff(skill_.parent, 44.0, skill_.cooldown_base)
    end)
end)