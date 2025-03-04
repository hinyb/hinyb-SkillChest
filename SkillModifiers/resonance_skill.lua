local table = {"image_xscale", "team", "hp", "shield", "damage", "critical_chance", "totem_spawn_id", "elite_type"}
local resonance_skill = SkillModifierManager.register_modifier("resonance_skill")
resonance_skill:set_add_func(function(data, modifier_index, skill_id)
    data.skill.is_primary = 0
    local default_skill = Skill.wrap(skill_id)
    data.skill.cooldown_base = (data.skill.cooldown_base + default_skill.cooldown) * 0.75
    local required_stock = default_skill.required_stock
    gm._mod_ActorSkill_recalculateStats(data.skill)
    local target = data.skill.parent
    local target_id = target.id
    data:add_pre_activate_callback(function(data)
        local inst = gm.instance_create(target.x, target.y, gm.constants.oFakeActor)
        
        local p_object_index = target.object_index
        -- fix custom_object's callback_execute
        local is_custom = target.__object_index and true or false
        if is_custom then
            inst.__custom_id = target.__custom_id
        end
        inst:event_perform_object(p_object_index, 0, 0)
        if is_custom then
            inst:event_perform_object(p_object_index, 7, 25)
        end
        if p_object_index == gm.constants.oP then
            local class = target.class
            inst:init_class(class, true)
            inst:init_player_late()
            inst.input_player_index = 0
        else
            CompatibilityPatch.set_compat(inst)
        end
        for i = 1, #table do
            local name = table[i]
            inst[name] = target[name]
        end

        inst.is_targettable = false
        gm.call("gml_Script___actor_update_target_marker", inst, inst)

        gm.actor_skill_set(inst, 0, skill_id)
        local i_skill = inst:actor_get_skill_active(0)
        local flag = 0
        i_skill.stock = required_stock
        InstanceExtManager.add_callback(inst, "post_instance_destroy", "resonance_skill", function(actor)
            if not Instance.exists(target_id) then
                return
            end
            local stock_diff = i_skill.stock - required_stock
            if stock_diff > 0 then
                local t_skill = target:actor_get_skill_active(data.skill.slot_index)
                t_skill.stock = t_skill.stock + stock_diff
            end
        end)
        local start_frame = gm.variable_global_get("_current_frame")
        InstanceExtManager.add_callback(inst, "pre_step", "resonance_skill", function(actor, event_number)
            if flag > 1 or not Instance.exists(target_id) then
                gm.instance_destroy(actor)
                return HookFlags.fSkipQueue | HookFlags.fSkipOriginal
            end
            if event_number:get() ~= 2 then
                return HookFlags.fSkipOriginal
            end
            if gm.variable_global_get("_current_frame") - start_frame >= 600 then
                gm.instance_destroy(actor)
                return HookFlags.fSkipQueue | HookFlags.fSkipOriginal
            end
            i_skill:freeze_cooldown(i_skill, i_skill)
            actor.z_skill = 1
            actor:skill_system_update()
            actor:step_actor()
            actor:step_default()
            return HookFlags.fSkipOriginal
        end)
        InstanceExtManager.add_callback(inst, "pre_skill_activate", "resonance_skill", function(actor)
            flag = flag + 1
            if flag > 1 then
                return false
            end
            InstanceExtManager.add_on_anim_end(inst, "resonance_skill", function(actor)
                gm.instance_destroy(actor)
                return HookFlags.fSkipQueue | HookFlags.fSkipOriginal
            end)
        end)
        InstanceExtManager.add_skill_instance_captrue(inst, 0, "resonance_skill", function(inst_)
            if inst_.parent then
                inst_.parent = target
            else
                local attack_info = inst_.attack_info
                if inst_.attack_info then
                    attack_info.parent = target
                end
            end
        end)
        if not Net.is_client() then
            InstanceExtManager.add_callback(inst, "pre_apply_buff", "resonance_skill",
                function(actor, buff_id, time, stack_kind)
                    target:apply_buff(target, buff_id, time, stack_kind)
                    return false
                end)
        end
    end)
end)
local get_random = Utils.random_skill_id()
resonance_skill:set_default_params_func(function()
    while true do
        local skill = Skill.wrap(get_random())
        if skill.auto_restock and not Utils.is_skill_need_scrap_bar(skill.value) then
            return skill.value
        end
    end
end)
resonance_skill:set_info_func(function(ori_desc, data, skill_id)
    local skill = Class.SKILL:get(skill_id)
    return Language.translate_token("skill_modifier.resonance_skill.name") .. ": " ..
               Language.translate_token("skill_modifier.resonance_skill.description") .. "\n" .. "<r>" ..
               Language.translate_token(skill:get(2)) .. "</c>" .. ": " .. Language.translate_token(skill:get(3)) ..
               "\n" .. ori_desc
end)

Initialize(function()
    local oFakeActor = Object.new("hinyb", "oFakeActor", Object.PARENT.actor)
    gm.constants.oFakeActor = oFakeActor.value
    oFakeActor.obj_sprite = 24
    oFakeActor:add_callback("onCreate", function(inst)
        inst.m_id = inst:set_m_id(inst.id)
    end)
end)
