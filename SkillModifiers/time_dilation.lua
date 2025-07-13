-- This modifier may have many sync issues.
-- I just found this is a time stop item in the game.
local shd_time_dilation = gm.shader_add(path.combine(_ENV["!plugins_mod_folder_path"], "shaders", "time_dilation"), "shd_time_dilation")
local sound
Initialize(function()
    sound = Resources.sfx_load("hinyb", "clockticks", _ENV["!plugins_mod_folder_path"] .. "/sounds/clockticks.ogg")
end)
local time_dilation_flag = false
local alarm
local time_dilation = SkillModifierManager.register_modifier("time_dilation", 50)
time_dilation.duration = 4
time_dilation.cooldown = 15
time_dilation:set_add_func(function(data, modifier_index, item_id)
    local last_frame = 0
    data:add_pre_activate_callback(function(data)
        local current_frame = gm.variable_global_get("_current_frame")
        if current_frame - last_frame >= time_dilation.cooldown * 60 and not time_dilation_flag then
            last_frame = current_frame
            time_dilation_flag = true
            gm.audio_play_sound(sound, 1.0, true)
            gm.game_set_speed(120, false)
            Alarm.destroy(alarm)
            alarm = Alarm.create(function()
                gm.game_set_speed(60, false)
                gm.audio_stop_sound(sound)
                time_dilation_flag = false
            end, time_dilation.duration * 60)
        end
    end)
end)
time_dilation:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, "time_dilation") < 1
end)
time_dilation:set_monster_check_func(function(skill)
    return false
end)
time_dilation:register_component(ComponentTemplates.create_modifier_double_component("time_dilation_duration", "duration"))
time_dilation:register_component(ComponentTemplates.create_modifier_double_component("time_dilation_cooldown", "cooldown"))

local black_list = {
    [gm.constants.oStartObjects] = true,
    [gm.constants.oStartMenu] = true,
    [gm.constants.oPauseMenu] = true,
    [gm.constants.oSelectMenu] = true,
    [gm.constants.oSelectPlayerIcon] = true,
    [gm.constants.oBlack] = true,
    [gm.constants.oBlackOut] = true,
    [gm.constants.oB] = true,
    [gm.constants.oHUD] = true,
    [gm.constants.oBossSpawn] = true,
    [gm.constants.oBossSpawn2] = true,
    [gm.constants.oRope] = true,
    [gm.constants.oBNoSpawn] = true
}
HookSystem.clean_hook()
HookSystem.add_special_hook("pre_Perform_Event_Object", function (ret_val, target, result, object_index, event_type, event_number)
    if not time_dilation_flag then
        return
    end
    if event_type ~= 3 then
        return
    end
    local object_index_ = object_index:get()
    if black_list[object_index_] then
        return
    end
    if gm.object_is_ancestor(object_index_, gm.constants.pEnemy) == 1.0 then
        if gm.variable_global_get("_current_frame") % 4 ~= 0 then
            return false
        end
    end
end)

local my_surface
gm.post_code_execute("gml_Object_oInit_Draw_73", function()
    if not time_dilation_flag then
        return
    end
    local application_surface = gm.variable_global_get("application_surface")
    if (gm.surface_exists(application_surface)) then
        local app_surf_w = gm.surface_get_width(application_surface)
        local app_surf_h = gm.surface_get_height(application_surface)
        if not my_surface or app_surf_w ~= gm.surface_get_width(my_surface) or app_surf_h ~= gm.surface_get_height(my_surface) then
            my_surface = gm.surface_create(app_surf_w, app_surf_h)
        end
        gm.surface_set_target(my_surface)
        gm.shader_set(shd_time_dilation)
        local _uni_tranzitioner       = gm.shader_get_uniform(shd_time_dilation, "Tranzitioner");
        local _uni_shader_strength    = gm.shader_get_uniform(shd_time_dilation, "ShaderStrength");
        local _uni_outline_threshold  = gm.shader_get_uniform(shd_time_dilation, "OutlineThreshold");
        local _uni_outline_smoothness = gm.shader_get_uniform(shd_time_dilation, "OutlineSmoothness");
        local _uni_outline_strength   = gm.shader_get_uniform(shd_time_dilation, "OutlineStrength");
        local _uni_shader_accent      = gm.shader_get_uniform(shd_time_dilation, "ShaderAccent");
        gm.shader_set_uniform_f(_uni_tranzitioner, 0.1);
        gm.shader_set_uniform_f(_uni_shader_strength, 1.0);
        gm.shader_set_uniform_f(_uni_outline_threshold, 0.05);
        gm.shader_set_uniform_f(_uni_outline_smoothness, 0.02);
        gm.shader_set_uniform_f(_uni_outline_strength, 0.8);
        gm.shader_set_uniform_vec3(_uni_shader_accent, 1.0, 0.0, 0.0);
        gm.draw_surface(application_surface, 0, 0)
        gm.shader_reset()
        gm.surface_reset_target()
        gm.surface_copy(application_surface, 0, 0, my_surface)
    end
end)