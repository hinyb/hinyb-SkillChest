SkillModifier.register_modifier("evolving_hunger", 50, nil, function(skill, data, modifier_index)
    SkillModifier.add_on_activate_callback(data, function(skill_)
        local modifer = Array.wrap(skill_.ctm_arr_modifiers):get(modifier_index)
        local times = modifer:get(1)
        local num = 1.24 * times * 1.12 ^ times
        Utils.change_actor_attr(skill_.parent, "maxhp", skill_.parent.maxhp - num)
        if skill_.parent.maxhp > skill_.parent.hp then
            skill_.parent.hp = skill_.parent.maxhp
        end
        SkillModifier.change_attr_func(skill_, "damage", data, function (origin_value)
            return origin_value * 1.5
        end)
        SkillModifier.change_attr_func(skill_, "cooldown", data,function (origin_value)
            return origin_value + Utils.round(num * 0.15 * 60)
        end)
        times = times + 1
        modifer:set(1, times)
    end)
end,nil,nil,function ()
    return 1
end)
