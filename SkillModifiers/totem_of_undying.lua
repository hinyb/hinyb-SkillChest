-- Stealing from Minecraft, I'm not sure if it's safe to use.
local sound
Initialize(function ()
    sound = Resources.sfx_load("hinyb", "totem_of_undying", _ENV["!plugins_mod_folder_path"] .. "/sounds/use_totem.ogg")
end)
local totem_of_undying = SkillModifierManager.register_modifier("totem_of_undying", 24)
totem_of_undying:set_add_func(function(data)
    data:add_pre_actor_death_after_hippo_callback(function(data)
        if data.skill.parent.hp <= 0 then
            data.skill.parent.hp = data.skill.parent.maxhp / 2
            local ctm_arr_modifiers = Array.wrap(data.skill.ctm_arr_modifiers)
            for i = ctm_arr_modifiers:size() - 1, 0 do
                SkillModifierManager.remove_modifier(data.skill, ctm_arr_modifiers:get(i):get(0), i)
            end
            gm.actor_skill_set(data.skill.parent, data.skill.slot_index, 0)
            data.skill.parent.invincible = 60
            gm.apply_buff(data.skill.parent, 11, 30)
            gm.sound_play_at(sound, 1.0, 1.0, data.skill.parent.x, data.skill.parent.y, 1.0)
        end
    end)
end)
totem_of_undying:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, "totem_of_undying") < 1
end)
