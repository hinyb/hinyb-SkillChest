local chaos_faction = SkillModifierManager.register_modifier("chaos_faction")
chaos_faction:set_add_func(function(data, modifier_index)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * 1.75
    end)
    local actor = data.skill.parent
    if not actor.is_local then
        return
    end
    Instance_ext.add_skill_instance_captrue_local_with_filter(actor, data.skill.slot_index, data:get_id(modifier_index),
        function(inst)
            if inst.parent then
                inst.team = 0
            else
                inst.attack_info.team = 0
                Instance_ext.add_callback(inst, "pre_attack_collision_resolve", data:get_id(modifier_index), function (bullet, target)
                    if target == actor then
                        return false, -4
                    end
                end)
            end
        end)
end)
chaos_faction:set_remove_func(function(data, modifier_index)
    local actor = data.skill.parent
    if not actor.is_local then
        return
    end
    Instance_ext.remove_skill_instance_captrue(actor, data.skill.slot_index, data:get_id(modifier_index))
end)
chaos_faction:set_check_func(function(skill)
    return (Utils.is_non_instant_damage_skill(skill.skill_id) or Utils.is_summon_skill(skill.skill_id)) and
               Utils.is_damage_skill(skill.skill_id)
end)
