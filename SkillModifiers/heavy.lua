local heavy = SkillModifierManager.register_modifier("heavy")
heavy:set_add_func(function(data, modifier_index)
    local id_prefix = "heavy" .. tostring(data.skill.slot_index) .. tostring(modifier_index)
    data:add_pre_activate_callback(function(data)
        Utils.hook_instance_create({gm.constants.oActorTargetEnemy, gm.constants.oActorTargetPlayer})
    end)
    data:add_post_activate_callback(function(data)
        local inst = Instance.wrap(data.skill.parent)
        local list = Utils.get_tracked_instances()
        if #list > 0 then
            log.info(data.skill.skill_id)
            for i = 1,#list do
                log.info(list[i].object_name)
            end
        end
        Utils.unhook_instance_create()
    end)
end)
