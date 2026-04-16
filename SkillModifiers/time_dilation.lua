-- This modifier may have many sync issues.
-- I just found this is a time stop item in the game.
local shd_time_dilation       = gm.shader_add(path.combine(_ENV["!plugins_mod_folder_path"], "shaders", "time_dilation"),
    "shd_time_dilation")
local _uni_tranzitioner       = gm.shader_get_uniform(shd_time_dilation, "Tranzitioner")
local _uni_shader_strength    = gm.shader_get_uniform(shd_time_dilation, "ShaderStrength")
local _uni_outline_threshold  = gm.shader_get_uniform(shd_time_dilation, "OutlineThreshold")
local _uni_outline_smoothness = gm.shader_get_uniform(shd_time_dilation, "OutlineSmoothness")
local _uni_outline_strength   = gm.shader_get_uniform(shd_time_dilation, "OutlineStrength")
local _uni_shader_accent      = gm.shader_get_uniform(shd_time_dilation, "ShaderAccent")

local sound
Initialize.add_hotloadable(function()
    sound = Sound.new("clockticks", _ENV["!plugins_mod_folder_path"] .. "/sounds/clockticks.ogg").value
end)
local time_dilation_flag = false
local alarm
local time_dilation = SkillModifierManager.register_modifier("time_dilation", 50)
time_dilation.duration = 4
time_dilation.cooldown = 15
local ev_cache = {}
local my_surface = gm.surface_create(1920, 1080)

time_dilation:set_add_func(function(data, modifier_index, item_id)
    local last_frame = 0
    data:add_pre_activate_callback(function(data)
        local current_frame = gm.variable_global_get("_current_frame")
        if current_frame - last_frame >= time_dilation.cooldown * 60 and not time_dilation_flag then
            if not time_dilation_flag then
                for _, inst in ipairs(Instance.find_all(gm.constants.pEnemy)) do
                    if not ev_cache[inst.object_index] then
                        local cache = {}
                        ev_cache[inst.object_index] = cache
                        local events = gm.event_hook_get_all(inst.object_index)
                        for _, event in ipairs(events) do
                            if event.event_type == gm.constants.ev_step then
                                table.insert(cache, event.event_number)
                            end
                        end
                    end
                    local events = ev_cache[inst.object_index]
                    for i = 1, #events do
                        gm.event_hook_pre_add(inst.value, gm.constants.ev_step, events[i], "time_dilation", function(inst)
                            if not time_dilation_flag then
                                gm.event_hook_pre_remove(inst, gm.constants.ev_step, events[i], "time_dilation")
                            end
                            if gm.variable_global_get("_current_frame") % 4 ~= 0 then
                                return false
                            end
                        end)
                    end
                end
                local inst = Instance.find(gm.constants.oInit).value
                gm.event_hook_pre_add(inst, gm.constants.ev_draw, 73, "time_dilation", function()
                    if not time_dilation_flag then
                        gm.event_hook_pre_remove(inst, gm.constants.ev_draw, 73, "time_dilation")
                        return
                    end
                    local application_surface = gm.variable_global_get("application_surface")
                    if gm.surface_exists(application_surface) then
                        local app_surf_w = gm.surface_get_width(application_surface)
                        local app_surf_h = gm.surface_get_height(application_surface)
                        if not gm.surface_exists(my_surface) then
                            my_surface = gm.surface_create(app_surf_w, app_surf_h)
                        elseif app_surf_w ~= gm.surface_get_width(my_surface) or app_surf_h ~= gm.surface_get_height(my_surface) then
                            gm.surface_free(my_surface)
                            my_surface = gm.surface_create(app_surf_w, app_surf_h)
                        end
                        gm.surface_set_target(my_surface)
                        gm.shader_set(shd_time_dilation)
                        gm.shader_set_uniform_f(_uni_tranzitioner, 0.1)
                        gm.shader_set_uniform_f(_uni_shader_strength, 1.0)
                        gm.shader_set_uniform_f(_uni_outline_threshold, 0.05)
                        gm.shader_set_uniform_f(_uni_outline_smoothness, 0.02)
                        gm.shader_set_uniform_f(_uni_outline_strength, 0.8)
                        gm.shader_set_uniform_i(_uni_shader_accent, 1.0, 0.0, 0.0)
                        gm.draw_surface(application_surface, 0, 0)
                        gm.shader_reset()
                        gm.surface_reset_target()
                        gm.surface_copy(application_surface, 0, 0, my_surface)
                    end
                end)
            end
            last_frame = current_frame
            time_dilation_flag = true
            gm.audio_play_sound(sound, 1.0, true)
            gm.game_set_speed(120, false)
            Alarm.remove(alarm)
            alarm = Alarm.add(time_dilation.duration * 60, function()
                gm.game_set_speed(60, false)
                gm.audio_stop_sound(sound)
                time_dilation_flag = false
            end)
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