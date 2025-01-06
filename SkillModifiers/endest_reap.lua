local endest_reap = SkillModifierManager.register_modifier("endest_reap")
endest_reap:set_add_func(function(data, modifier_index)
    local modifer = Array.wrap(data.skill.ctm_arr_modifiers):get(modifier_index)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value + modifer:get(1) * 0.3
    end)
    local actor = Instance.wrap(data.skill.parent)
    actor:add_callback("onKillProc", data:get_id(modifier_index), function(actor, victim)
        if victim.boss_drop_item ~= 0.0 then
            modifer:set(1, modifer:get(1) + 1)
            gm._mod_ActorSkill_recalculateStats(data.skill)
        end
    end)
end)
endest_reap:set_remove_func(function(data, modifier_index)
    local actor = Instance.wrap(data.skill.parent)
    actor:remove_callback(data:get_id(modifier_index))
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
        Language.translate_token("skill_modifier.endest_reap.name") .. " • " .. Utils.to_string_with_floor(stack) ..
            ": " .. Language.translate_token("skill_modifier.endest_reap.description") .. "\n" .. ori_desc
end)
