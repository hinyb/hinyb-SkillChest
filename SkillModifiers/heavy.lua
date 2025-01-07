local heavy = SkillModifierManager.register_modifier("heavy")
heavy:set_add_func(function(data, modifier_index)
    local id = data:get_id(modifier_index)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * 4
    end)
    data:add_pre_activate_callback(function(data)
        data.skill.parent.attack_speed = data.skill.parent.attack_speed / 2
        Instance_ext.add_on_anim_end(data.skill.parent, id, function(actor)
            data.skill.parent.attack_speed = data.skill.parent.attack_speed * 2
        end)
    end)
    data:add_pre_local_drop_callback(function(data)
        local modifer = Array.wrap(data.skill.ctm_arr_modifiers):get(modifier_index)
        modifer:set(1, data.skill.parent.damage)
    end)
    local inst = Instance.wrap(data.skill.parent)
    inst.pGravity1 = inst.pGravity1 * 1.25
    inst.pGravity2 = inst.pGravity2 * 1.25
    inst.max_pGravity1 = inst.max_pGravity1 or 30
    inst.max_pGravity1 = inst.max_pGravity1 * 1.25
    inst:add_callback("onPostStatRecalc", id, function(inst)
        inst.pGravity1 = inst.pGravity1 * 1.25
        inst.pGravity2 = inst.pGravity2 * 1.25
    end)
end)
heavy:set_remove_func(function(data, modifier_index)
    local inst = Instance.wrap(data.skill.parent)
    inst:remove_callback(data:get_id(modifier_index))
    GM.actor_queue_dirty(inst)
    -- Loss of precision may cause some issues.
    inst.max_pGravity1 = inst.max_pGravity1 / 1.25
end)
heavy:set_default_params_func(function()
    return 20
end)
heavy:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)
heavy:set_add_inst_func(function(inst, skill_params, x, y, modifier_index, damage, ...)
    if inst.has_heavy then
        return
    end
    inst.has_heavy = true
    inst:init_actor_default()
    inst.pFriction = 1
    inst.pHspeed = 1
    inst.pVspeed = 1
    inst.pFriction = 1
    inst.pAccel = 0.2
    inst.pHmax = 2
    inst.pVmax = 6
    -- pGravity2 only used when jump
    inst.pGravity1 = 6
    inst.max_pGravity1 = 60
    inst.sprite_jump = inst.sprite_index
    inst.sprite_death = inst.sprite_index
    inst.sprite_fall = inst.sprite_index
    inst.sprite_idle = inst.sprite_index
    inst.sprite_jump_peak = inst.sprite_index
    inst.x = x
    inst.y = y
    inst.damage = damage
    inst.team = inst.team or 1
    inst:actor_phy_prevent_overlap()
    local inst_warpped = Instance.wrap(inst)
    inst_warpped:add_callback("onPostStep", "heavy", function(inst)
        if not inst.free then
            return
        end
        local last_pVspeed = inst.pVspeed
        inst:actor_phy_move()
        inst.image_speed = 0
        if not Net.is_client() then
            local collisions_list, collisions_num = inst:get_collisions(gm.constants.pActorCollisionBase)
            for i = 1, collisions_num do
                local collisions_inst_warpped = collisions_list[i]
                if collisions_inst_warpped.object_index ~= gm.constants.oP then
                    gm._mod_attack_fire_explosion_noparent(collisions_inst_warpped.x, collisions_inst_warpped.y, 40, 40,
                        0.0, damage * last_pVspeed / 2, true, gm.constants.sNone, gm.constants.sNone)
                end
            end
        end
        if not inst.free then
            gm.screen_shake(last_pVspeed, x, y)
            inst:sound_play(gm.constants.wGolemAttack1, 0.8, 3.0)
            if not Net.is_client() then
                gm._mod_attack_fire_explosion_noparent(inst.x, inst.y, 120, 120, 0.0, damage * last_pVspeed, true,
                    gm.constants.sNone, gm.constants.sNone)
            end
        end
    end)
end)

memory.dynamic_hook_mid("actor_phy_move_fix_max_gravity1", {"rax", "[rbp+0D20h+10h]"}, {"RValue*", "CInstance*"}, 0,
    gm.get_script_function_address(gm.constants.actor_phy_move):add(18295), function(args)
        if args[2].max_pGravity1 then
            args[1].value = args[2].max_pGravity1
        end
    end)
memory.dynamic_hook_mid("actor_phy_move_fix_max_gravity2", {"rax", "[rbp+0D20h+10h]"}, {"RValue*", "CInstance*"}, 0,
    gm.get_script_function_address(gm.constants.actor_phy_move):add(19515), function(args)
        if args[2].max_pGravity1 then
            args[1].value = args[2].max_pGravity1
        end
    end)
