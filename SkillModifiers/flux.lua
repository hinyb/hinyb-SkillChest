local function register_flux(attr, fn)
    SkillModifier.register_modifier("flux_" .. attr, 125, function(skill)
        return SkillModifier.get_modifier_num("flux_" .. attr) < 1
    end, function(skill, data, modifier_index, value)
        SkillModifier.change_attr_func(skill, attr, data, function (origin_value)
            if attr == "slot_index" then
                return value
            else
                return value + origin_value
            end
        end)
    end, function(skill, data)
        SkillModifier.restore_attr(skill, attr, data)
    end, function(ori_desc, skill)
        return Language.translate_token("skill_modifier.flux.name") .. "•" ..
                   Language.translate_token("skill_modifier.flux." .. attr) .. ": " ..
                   Language.translate_token("skill_modifier.flux.description") .. "\n" .. ori_desc
    end, function(skill)
        return fn(skill)
    end)
end

register_flux("max_stock", function(skill)
    return Utils.round(
    Utils.get_gaussian_random_within(0, skill.max_stock * 3, skill.max_stock, skill.max_stock)) - skill.max_stock
end)
register_flux("damage", function(skill)
    return Utils.round(Utils.get_gaussian_random_within(nil, skill.damage * 10, skill.damage * 1.1, skill.damage)) - skill.damage
end)
register_flux("cooldown", function(skill)
    return Utils.round(Utils.get_gaussian_random_within(0, skill.cooldown * 4, skill.cooldown * 0.9, skill.cooldown)) -skill.cooldown
end)
register_flux("slot_index", function()
    return Utils.get_random(0, 3)
end)
