local sound
Initialize(function()
    sound = Resources.sfx_load("hinyb", "totem_of_undying",
        _ENV["!plugins_mod_folder_path"] .. "/sounds/glass_shatter.ogg")
end)
local fragile = SkillModifierManager.register_modifier("fragile", 250)
fragile:set_add_func(function(data)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * 10
    end)
    local actor = data.skill.parent
    if not actor.is_local then
        return
    end
    data:add_pre_activate_callback(function(data)
        if Utils.get_random() < 0.02 then
            SkillModifierManager.clear_and_set_skill_sync(data.skill.parent, data.skill.slot_index, 0)
            gm.sound_play_at(sound, 1.0, 1.0, data.skill.parent.x, data.skill.parent.y, 1.0)
        end
    end)
end)
fragile:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)

