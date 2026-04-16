local light = SkillModifierManager.register_modifier("light")
light.damage_multipiler = 0.625
light.attack_speed_multipiler = 2
light.gravity_multipiler = 0.8
light:set_add_func(function(data, modifier_index)
    local id = data:get_id(modifier_index)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * light.damage_multipiler
    end)
    data:add_pre_activate_callback(function(data)
        data.skill.parent.attack_speed = data.skill.parent.attack_speed * light.attack_speed_multipiler
        if InstanceExtManager.has_on_anim_end(data.skill.parent, id) then
            data.skill.parent.attack_speed = data.skill.parent.attack_speed / light.attack_speed_multipiler
            InstanceExtManager.remove_on_anim_end(data.skill.parent, id)
        end
        InstanceExtManager.add_on_anim_end(data.skill.parent, id, function(actor)
            actor.attack_speed = actor.attack_speed / light.attack_speed_multipiler
        end)
    end)
    local inst = data.skill.parent
    inst.max_pGravity1 = inst.max_pGravity1 or 30
    inst.max_pGravity1 = inst.max_pGravity1 * light.gravity_multipiler -- see heavy
    InstanceExtManager.add_callback(inst, "post_recalculate_stats", id, function (inst)
        inst.pGravity1 = inst.pGravity1 * light.gravity_multipiler
        inst.pGravity2 = inst.pGravity2 * light.gravity_multipiler
    end)
    gm.actor_queue_dirty(inst)
end)
light:set_remove_func(function(data, modifier_index)
    local inst = data.skill.parent
    InstanceExtManager.remove_callback(inst, "post_recalculate_stats", data:get_id(modifier_index))
    gm.actor_queue_dirty(inst)
    inst.max_pGravity1 = inst.max_pGravity1 / light.gravity_multipiler
end)
light:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)
light:register_component(ComponentTemplates.create_modifier_double_component("light_damage_multipiler",
    "damage_multipiler"))
light:register_component(ComponentTemplates.create_modifier_double_component("light_attack_speed_multipiler",
    "attack_speed_multipiler"))
light:register_component(ComponentTemplates.create_modifier_double_component("light_gravity_multipiler",
    "gravity_multipiler"))
