local heavy_strike = SkillModifierManager.register_modifier("heavy_strike")
heavy_strike:set_add_func(function(data, modifier_index)
    local id_prefix = "heavy_strike" .. tostring(data.skill.slot_index) .. tostring(modifier_index)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * 4
    end)
    data:add_post_activate_callback(function(data)
        local cache_attack_speed = data.skill.parent.attack_speed
        data.skill.parent.attack_speed = cache_attack_speed / 2
        Instance_ext.add_on_anim_end(data.skill.parent, id_prefix, function(actor)
            data.skill.parent.attack_speed = cache_attack_speed
        end)
    end)
end)
heavy_strike:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)