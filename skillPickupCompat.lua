SkillPickup.add_pre_local_drop_after_diff_func(function(player, skill)
    if skill.ctm_arr_modifiers then
        local ctm_arr_modifiers = Array.wrap(skill.ctm_arr_modifiers)
        for i = 0, ctm_arr_modifiers:size() - 1 do
            SkillModifierManager.remove_modifier_local(skill, i)
        end
    end
end)

SkillPickup.add_post_create_func(function(target, skill_params, x, y)
    for k, v in pairs(skill_params) do
        if k == "ctm_arr_modifiers" then
            for modifier_index, modifier_table in pairs(v) do
                local modifier = SkillModifierManager.get_modifier(modifier_table[1])
                if modifier.add_inst_func then
                    local params = {}
                    for i = 2, #modifier_table do
                        params[#params + 1] = modifier_table[i]
                    end
                    modifier.add_inst_func(target, skill_params, x, y, modifier_index, table.unpack(params))
                end
            end
        end
    end
end)

SkillPickup.add_skill_diff("ctm_sprite", function(result, skill)
    result.ctm_sprite = skill.ctm_sprite
end)
SkillPickup.add_skill_diff("ctm_arr_modifiers", function(result, skill)
    result.ctm_arr_modifiers = Utils.create_table_from_array(skill.ctm_arr_modifiers)
end)

SkillPickup.add_post_pickup_func(function(actor, target, skill)
    if target.ctm_sprite ~= nil then
        skill.ctm_sprite = target.ctm_sprite
    end
    local ctm_arr_modifiers = target.ctm_arr_modifiers
    if ctm_arr_modifiers ~= nil then
        if type(ctm_arr_modifiers) == "table" then
            for i = 1, #ctm_arr_modifiers do
                local modifier = ctm_arr_modifiers[i]
                local modifier_args = {}
                for j = 2, #modifier do
                    modifier_args[#modifier_args + 1] = modifier[j]
                end
                SkillModifierManager.add_modifier_local(skill, modifier[1], table.unpack(modifier_args))
            end
        else
            local modifiers = Array.wrap(ctm_arr_modifiers)
            for i = 0, modifiers:size() - 1 do
                local modifier = modifiers:get(i)
                local modifier_args = {}
                for j = 1, modifier:size() - 1 do
                    modifier_args[#modifier_args + 1] = modifier:get(j)
                end
                SkillModifierManager.add_modifier_local(skill, modifier:get(0), table.unpack(modifier_args))
            end
        end
    end
end)
