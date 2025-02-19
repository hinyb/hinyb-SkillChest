-- Stealing from Minecraft, I'm not sure if it's safe to use.
local sound
Initialize(function()
    sound = Resources.sfx_load("hinyb", "totem_of_undying", _ENV["!plugins_mod_folder_path"] .. "/sounds/use_totem.ogg")
end)
local totem_of_undying = SkillModifierManager.register_modifier("totem_of_undying", 50)
totem_of_undying:set_add_func(function(data, modifier_index)
    InstanceExtManager.add_callback(data.skill.parent, "pre_actor_death_after_hippo", data:get_id(), function(inst)
        if inst.hp <= 0 then
            inst.hp = inst.maxhp / 2
            SkillModifierManager.clear_and_set_skill_sync(inst, data.skill.slot_index, 0)
            inst.invincible = 60
            gm.apply_buff(inst, 11, 30)
            gm.sound_play_at(sound, 1.0, 1.0, inst.x, inst.y, 1.0)
        end
    end)
end)
totem_of_undying:set_remove_func(function(data, modifier_index)
    InstanceExtManager.remove_callback(data.skill.parent, "pre_actor_death_after_hippo", data:get_id())
end)
totem_of_undying:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, "totem_of_undying") < 1
end)
