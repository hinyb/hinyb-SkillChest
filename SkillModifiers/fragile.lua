SkillModifier.register_modifier("fragile", 250, nil, function(skill, data)
    SkillModifier.change_attr_func(skill, "damage", data, function(origin_value)
        return origin_value * 10
    end)
    SkillModifier.add_on_activate_callback(data, function(skill_)
        if skill_.parent.is_local then
            if Utils.get_random() < 0.05 then
                gm.actor_skill_set(skill_.parent, skill_.slot_index, 0)
            end
        end
    end)
end, function(skill, data)
    SkillModifier.remove_on_activate_callback(data)
    SkillModifier.restore_attr(skill, "damage", data)
end)
