local blood_lust = SkillModifierManager.register_modifier("blood_lust")
blood_lust:set_add_func(function(data, modifier_index)
    local id_prefix = "blood_lust" .. tostring(data.skill.slot_index) .. tostring(modifier_index)
    if Utils.is_summon_skill(data.skill.skill_id) then
        data:add_pre_activate_callback(function(data)
            Utils.hook_instance_create({gm.constants.oActorTargetEnemy, gm.constants.oActorTargetPlayer})
        end)
        data:add_post_activate_callback(function(data)
            local inst = Instance.wrap(data.skill.parent)
            local list = Utils.get_tracked_instances()
            for i = 1, #list do
                local num = 8
                Instance.wrap(list[i]):add_callback("onKillProc", id_prefix .. "onKillProc", function(actor, victim)
                    inst:heal(num)
                    num = num * 1.5
                end)
            end
            Utils.unhook_instance_create()
        end)
    else
        data:add_pre_activate_callback(function(data)
            local inst = Instance.wrap(data.skill.parent)
            local num = 8
            local id = id_prefix .. "onKillProc"
            if not inst:callback_exists(id) then
                inst:add_callback("onKillProc", id, function(actor, victim)
                    actor:heal(num)
                    num = num * 1.5
                end)
            end
        end)
        data:add_post_activate_callback(function(data)
            Instance_ext.add_on_anim_end(data.skill.parent, id_prefix, function(actor)
                actor:remove_callback(id_prefix .. "onKillProc")
            end)
        end)
    end
end)
blood_lust:set_check_func(function(skill)
    return (Utils.is_non_instant_damage_skill(skill.skill_id) or Utils.is_summon_skill(skill.skill_id)) and
               Utils.is_damage_skill(skill.skill_id)
end)
