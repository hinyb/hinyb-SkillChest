local evolving_hunger = SkillModifierManager.register_modifier("evolving_hunger", 100)
evolving_hunger:set_default_params_func(function()
    return 1
end)
evolving_hunger:set_add_func(function(data, modifier_index, times)
    data:add_pre_activate_callback(function(data)
        local modifer = Array.wrap(data.skill.ctm_arr_modifiers):get(modifier_index)
        local times = modifer:get(1)
        local actor = Instance.wrap(data.skill.parent)
        local skill_address = memory.get_usertype_pointer(data.skill)
        local id = tostring(skill_address) .. tostring(modifier_index) .. tostring(times)
        local num = Utils.round(1.24 * times * 1.12 ^ times)
        actor:add_callback("onStatRecalc", id, function(actor)
            actor.maxhp = actor.maxhp - num
        end)
        actor.maxhp = actor.maxhp - num
        data:add_skill_attr_change("damage", function(origin_value)
            return origin_value * 1.5
        end)
        times = times + 1
        modifer:set(1, times)
    end)
    for _ = 2, times do
        data:add_skill_attr_change("damage", function(origin_value)
            return origin_value * 1.5
        end)
    end
end)
evolving_hunger:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, evolving_hunger.modifier_name) < 2
end)
