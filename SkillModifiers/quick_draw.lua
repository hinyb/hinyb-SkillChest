local quick_draw = SkillModifierManager.register_modifier("quick_draw")
quick_draw:set_add_func(function(data, modifier_index)
    local id_prefix = "quick_draw" .. tostring(data.skill.slot_index) .. tostring(modifier_index)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * 0.625
    end)
    data:add_post_activate_callback(function(data)
        local cache_attack_speed = data.skill.parent.attack_speed
        data.skill.parent.attack_speed = cache_attack_speed * 2
        Instance_ext.add_on_anim_end(data.skill.parent, id_prefix, function(actor)
            actor.attack_speed = cache_attack_speed
        end)
    end)
end)
