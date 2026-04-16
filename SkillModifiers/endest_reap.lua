local endest_reap = SkillModifierManager.register_modifier("endest_reap")
endest_reap.damage_multipiler = 0.3
endest_reap:set_add_func(function(data, modifier_index)
    local modifer = Array.wrap(data.skill.ctm_arr_modifiers):get(modifier_index)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value + modifer:get(1) * endest_reap.damage_multipiler
    end)
    InstanceExtManager.add_callback(data.skill.parent, "on_kill_other", data:get_id(modifier_index), function (victim, attacker)
        if victim.boss_drop_item ~= 0.0 then
            modifer:set(1, modifer:get(1) + 1)
            gm._mod_ActorSkill_recalculateStats(data.skill)
        end
    end)
end)
endest_reap:set_remove_func(function(data, modifier_index)
    InstanceExtManager.remove_callback(data.skill.parent, "on_kill_other", data:get_id(modifier_index))
end)
endest_reap:set_default_params_func(function()
    return 0
end)
endest_reap:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)
endest_reap:set_monster_check_func(function(skill)
    return false
end)
endest_reap:set_info_func(function(ori_desc, data, stack)
    return
        gm.translate("skill_modifier.endest_reap.name") .. " • " .. Utils.to_string_with_floor(stack) ..
            ": " .. gm.translate("skill_modifier.endest_reap.description") .. "\n" .. ori_desc
end)
endest_reap:register_component(ComponentTemplates.create_modifier_double_component("endest_reap_damage_multipiler", "damage_multipiler"))
