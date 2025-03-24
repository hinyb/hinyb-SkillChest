local sound
Initialize(function()
    sound = Resources.sfx_load("hinyb", "totem_of_undying",
        _ENV["!plugins_mod_folder_path"] .. "/sounds/glass_shatter.ogg")
end)
local fragile = SkillModifierManager.register_modifier("fragile", 250)
fragile.damage_multipiler = 10
fragile.probability = 0.02
fragile:set_add_func(function(data)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * fragile.damage_multipiler
    end)
    local actor = data.skill.parent
    if not gm.bool(actor.is_local) then
        return
    end
    data:add_pre_activate_callback(function(data)
        if math.random() < fragile.probability then
            SkillModifierManager.clear_and_set_skill_sync(data.skill.parent, data.skill.slot_index, 0)
            gm.sound_play_at(sound, 1.0, 1.0, data.skill.parent.x, data.skill.parent.y, 1.0)
        end
    end)
end)
fragile:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)
fragile:register_component(ComponentTemplates.create_modifier_double_component("fragile_damage_multipiler", "damage_multipiler"))
fragile:register_component(ComponentTemplates.create_modifier_double_component("fragile_proability", "probability"))