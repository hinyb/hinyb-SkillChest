-- WIP: summon will use parent's team.
local chaos_reign = SkillModifierManager.register_modifier("chaos_reign", 0)
chaos_reign:set_add_func(function(data, modifier_index)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * 1.75
    end)
    data:add_pre_activate_callback(function(data)
        local cache_team = data.skill.parent.team
        data.skill.parent.team = 0.0
        Instance_ext.add_on_anim_end(data.skill.parent, data:get_id(), function(actor)
            data.skill.parent.team = cache_team
        end)
    end)
end)
chaos_reign:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)
