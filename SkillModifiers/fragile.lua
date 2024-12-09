local fragile = SkillModifierManager.register_modifier("fragile", 250)
fragile:set_add_func(function (data)
    data:add_skill_attr_change("damage", function (origin_value)
        return origin_value * 10
    end)
    data:add_pre_activate_callback(function (data)
        if data.skill.parent.is_local then
            if Utils.get_random() < 0.05 then
                if data.skill.ctm_arr_modifiers then
                    local ctm_arr_modifiers = Array.wrap(data.skill.ctm_arr_modifiers)
                    for i = 0, ctm_arr_modifiers:size() - 1 do
                        SkillModifierManager.remove_modifier(data.skill, ctm_arr_modifiers:get(i):get(0), i)
                    end
                end
                gm.actor_skill_set(data.skill.parent, data.skill.slot_index, 0)
            end
        end
    end)
end)