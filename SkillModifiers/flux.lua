local function register_flux(attr, fn)
    local modifier = SkillModifierManager.register_modifier("flux_" .. attr)
    modifier:set_add_func(function(data, modifier_index, value)
        if attr ~= "slot_index" then
            data:add_skill_attr_change(attr, function(origin_value)
                return value + origin_value
            end)
        end
    end)
    modifier:set_check_func(function(skill)
        return SkillModifierManager.count_modifier(skill, modifier.modifier_name) < 1
    end)
    modifier:set_info_func(function(ori_desc, data)
        return Language.translate_token("skill_modifier.flux.name") .. "•" ..
                   Language.translate_token("skill_modifier.flux." .. attr) .. ": " ..
                   Language.translate_token("skill_modifier.flux.description") .. "\n" .. ori_desc
    end)
    modifier:set_default_params_func(function(skill)
        return fn(skill)
    end)
    if attr == "damage" then
        modifier:set_check_func(function(skill)
            return Utils.is_damage_skill(skill.skill_id)
        end)
    end
end
-- It is too hard to balance ;w;
register_flux("max_stock", function(skill)
    return Utils.round(Utils.get_gaussian_random_within(0, skill.max_stock * 3, skill.max_stock + 1,
        0.5 + skill.max_stock * 0.12)) - skill.max_stock
end)
register_flux("damage", function(skill)
    return Utils.get_gaussian_random_within(nil, skill.damage * 10, skill.damage * 1.25, skill.damage * 0.4) -
               skill.damage
end)
register_flux("cooldown", function(skill)
    return Utils.round(Utils.get_gaussian_random_within(0, skill.cooldown * 4, skill.cooldown * 0.8,
        skill.cooldown * 0.2)) - skill.cooldown
end)
register_flux("slot_index", function()
    return Utils.get_random(0, 3)
end)
SkillPickup.add_pre_create_func(function(skill_params)
    if skill_params.ctm_arr_modifiers then
        for i = 1, #skill_params.ctm_arr_modifiers do
            local modifier = skill_params.ctm_arr_modifiers[i]
            if modifier[1] == "flux_slot_index" then
                skill_params.slot_index = modifier[2]
            end
        end
    end
end)
