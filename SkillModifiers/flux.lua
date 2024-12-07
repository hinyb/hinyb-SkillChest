local function register_flux(attr, fn)
    SkillModifier.register_modifier("flux_" .. attr, 125, function(skill)
        return SkillModifier.get_modifier_num("flux_" .. attr) < 1
    end, function(skill, data, value)
        SkillModifier.change_attr(skill, attr, data, value)
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
    return Utils.round(Utils.get_gaussian_random(1.36, 1))
end)
register_flux("damage", function(skill)
    return Utils.round(Utils.get_gaussian_random(skill.damage * 1.36, skill.damage * 1.36))
end)
register_flux("cooldown", function(skill)
    return Utils.round(Utils.get_gaussian_random(skill.cooldown / 1.36, skill.cooldown / 1.36))
end)
register_flux("slot_index", function(skill)
    return Utils.get_random(0, 3)
end)
