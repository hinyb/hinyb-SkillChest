local evolving_hunger = SkillModifierManager.register_modifier("evolving_hunger", 100)
evolving_hunger:set_default_params_func(function()
    return 1, 0
end)
evolving_hunger:set_add_func(function(data, modifier_index, times)
    local modifer = Array.wrap(data.skill.ctm_arr_modifiers):get(modifier_index)
    data:add_pre_activate_callback(function(data)
        local times = modifer:get(1)
        local actor = Instance.wrap(data.skill.parent)
        local skill_address = memory.get_usertype_pointer(data.skill)
        local id = tostring(skill_address) .. tostring(modifier_index) .. tostring(times)
        local num = Utils.round(0.64 * times * 1.08 ^ times)
        if num >= actor.maxhp then
            data:add_skill_attr_change("cooldown", function(origin_value)
                local num_cooldown = (num - actor.maxhp + 1) * 10
                modifer:set(2, modifer:get(2) + num_cooldown)
                return origin_value + num_cooldown
            end)
            num = actor.maxhp - 1
        end
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
            return origin_value * 1.4
        end)
    end
    local cooldown_adjust = modifer:get(2)
    data:add_skill_attr_change("cooldown", function(origin_value)
        return origin_value + cooldown_adjust
    end)
end)
evolving_hunger:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, evolving_hunger.modifier_name) < 1 and
    Utils.is_damage_skill(skill.skill_id)
end)
evolving_hunger:set_monster_check_func(function(skill)
    return false
end)