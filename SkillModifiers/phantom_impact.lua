local scale = 1.25
local phantom_impact = SkillModifierManager.register_modifier("phantom_impact")
phantom_impact:set_add_func(function(data, modifier_index)
    local actor = data.skill.parent
    if not gm.bool(actor.is_local) then
        return
    end
    InstanceExtManager.add_skill_bullet_captrue_local(actor, data.skill.slot_index, data:get_id(modifier_index),
        function(inst)
            inst.image_xscale = inst.image_xscale * scale
            inst.image_yscale = inst.image_yscale * scale
        end)
end)
phantom_impact:set_remove_func(function(data, modifier_index)
    local actor = data.skill.parent
    if not gm.bool(actor.is_local) then
        return
    end
    InstanceExtManager.remove_skill_instance_captrue(actor, data.skill.slot_index, data:get_id(modifier_index))
end)
phantom_impact:set_check_func(function(skill)
    return Utils.is_can_track_skill(skill.skill_id) and Utils.is_damage_skill(skill.skill_id)
end)

