local sound
local fragile_message
Initialize(function()
    sound = Resources.sfx_load("hinyb", "totem_of_undying", _ENV["!plugins_mod_folder_path"].."/sounds/glass_shatter.ogg")
    fragile_message = Utils.create_packet(function(player, inst, slot_index)
        local skill = gm.array_get(inst.skills, slot_index)
        local ctm_arr_modifiers = Array.wrap(skill.ctm_arr_modifiers)
        for i = ctm_arr_modifiers:size() - 1, 0 do
            SkillModifierManager.remove_modifier(skill, ctm_arr_modifiers:get(i):get(0), i)
        end
        gm.actor_skill_set(inst, slot_index, 0)
        gm.sound_play_at(sound, 1.0, 1.0, inst.x, inst.y, 1.0)
    end, {Utils.param_type.Instance, Utils.param_type.int})
end)
local fragile = SkillModifierManager.register_modifier("fragile", 250)
fragile:set_add_func(function(data)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * 10
    end)
    if data.skill.parent.is_local then
        data:add_pre_activate_callback(function(data)
            if Utils.get_random() < 0.02 then
                local ctm_arr_modifiers = Array.wrap(data.skill.ctm_arr_modifiers)
                for i = 0, ctm_arr_modifiers:size() - 1 do
                    SkillModifierManager.remove_modifier(data.skill, ctm_arr_modifiers:get(i):get(0), i)
                end
                gm.actor_skill_set(data.skill.parent, data.skill.slot_index, 0)
                if Net.is_host() then
                    fragile_message(Utils.packet_type.not_forward, data.skill.parent, data.skill.slot_index):send_to_all()
                elseif Net.is_client() then
                    fragile_message(Utils.packet_type.forward, data.skill.parent, data.skill.slot_index):send_to_host()
                end
                gm.sound_play_at(sound, 1.0, 1.0, data.skill.parent.x, data.skill.parent.y, 1.0)
            end
        end)
    end
end)
fragile:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)

