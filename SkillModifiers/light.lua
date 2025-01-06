local light = SkillModifierManager.register_modifier("light")
light:set_add_func(function(data, modifier_index)
    local id = data:get_id(modifier_index)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * 0.625
    end)
    data:add_post_activate_callback(function(data)
        local cache_attack_speed = data.skill.parent.attack_speed
        data.skill.parent.attack_speed = cache_attack_speed * 2
        Instance_ext.add_on_anim_end(data.skill.parent, id, function(actor)
            actor.attack_speed = cache_attack_speed
        end)
    end)
    local inst = Instance.wrap(data.skill.parent)
    inst.pGravity1 = inst.pGravity1 * 0.8
    inst.pGravity2 = inst.pGravity2 * 0.8
    inst.max_pGravity1 = inst.max_pGravity1 or 30
    inst.max_pGravity1 = inst.max_pGravity1 * 0.8 -- see heavy
    inst:add_callback("onPostStatRecalc", id, function(inst)
        inst.pGravity1 = inst.pGravity1 * 0.8
        inst.pGravity2 = inst.pGravity2 * 0.8
    end)
end)
light:set_remove_func(function (data, modifier_index)
    local inst = Instance.wrap(data.skill.parent)
    inst:remove_callback(data:get_id(modifier_index))
    GM.actor_queue_dirty(inst)
    inst.max_pGravity1 = inst.max_pGravity1 / 0.8
end)
light:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)
