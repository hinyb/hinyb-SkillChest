local teleport = SkillModifierManager.register_modifier("teleport", 250)
teleport:set_add_func(function(data, modifier_index, m_id)
    data:add_post_drop_callback(function(data)
    end)
end)
teleport:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, "teleport") < 1
end)
teleport:set_default_params_func(function()
    return 0
end)
SkillPickup.add_post_create_func(function(inst)
    if inst.ctm_arr_modifiers ~= nil then
        local modifiers = Array.wrap(inst.ctm_arr_modifiers)
        for j = 0, modifiers:size() - 1 do
            local modifier = modifiers:get(j)
            if modifier:get(0) == "teleport" then
                inst.m_id = gm.call("gml_Script_set_m_id", inst, inst, inst)
                modifier:set(1, inst.m_id)
            end
        end
    end
end)

local sprite = Resources.sprite_load("hinyb", "teleport", _ENV["!plugins_mod_folder_path"] .. "/sprites/teleport.png")

local skill = Skill.new("hinyb", "teleport")
skill:set_skill_icon(sprite, 0)
skill:set_skill_properties(0, 0)
skill:set_skill_stock(1, 1, false, 0)
skill:set_skill_settings(true, false, 3, false, false, true, true, false)
skill.require_key_press = true

skill:onActivate(function(actor, struct, index)

    gm.actor_skill_set(actor.value, index, 0)
end)

SkillPickup.add_skill_override_check_func(function(actor, skill)
    return skill.id == 0
end)
