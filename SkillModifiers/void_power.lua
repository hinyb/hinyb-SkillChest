local void_power = SkillModifierManager.register_modifier("void_power", 250)
void_power:set_add_func(function(data, modifier_index)
    data:add_skill_attr_change("damage", function(origin_value, data)
        return origin_value * 2 ^ Utils.get_empty_skill_num(data.skill.parent)
    end)
    local actor = data.skill.parent
    if not gm.bool(actor.is_local) then
        return
    end
    Instance_ext.add_callback(data.skill.parent, "post_local_drop", data:get_id(), function()
        gm._mod_ActorSkill_recalculateStats(data.skill)
    end)
    Instance_ext.add_callback(data.skill.parent, "post_pickup", data:get_id(), function()
        gm._mod_ActorSkill_recalculateStats(data.skill)
    end)
end)
void_power:set_remove_func(function(data, modifier_index)
    local actor = data.skill.parent
    if not gm.bool(actor.is_local) then
        return
    end
    Instance_ext.remove_callback(data.skill.parent, "post_local_drop", data:get_id())
    Instance_ext.remove_callback(data.skill.parent, "post_pickup", data:get_id())
end)
void_power:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)
