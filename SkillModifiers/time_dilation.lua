-- This modifier may have many sync issues.
-- I just found this is a time stop item in the game.
local sound
Initialize(function()
    sound = Resources.sfx_load("hinyb", "clockticks", _ENV["!plugins_mod_folder_path"] .. "/sounds/clockticks.ogg")
end)
--[[
-- ev_step 3
-- ev_draw 8
]]
local during = 60 * 4
local cooldown = 60 * 15
local time_dilation_flag = false
local alarm
local time_dilation = SkillModifierManager.register_modifier("time_dilation", 50)
time_dilation:set_add_func(function(data, modifier_index, item_id)
    local last_frame = 0
    data:add_pre_activate_callback(function(data)
        local current_frame = gm.variable_global_get("_current_frame")
        if current_frame - last_frame >= cooldown and not time_dilation_flag then
            last_frame = current_frame
            time_dilation_flag = true
            gm.audio_play_sound(sound, 1.0, true)
            gm.game_set_speed(120, false)
            Alarm.destroy(alarm)
            alarm = Alarm.create(function()
                gm.game_set_speed(60, false)
                gm.audio_stop_sound(sound)
                time_dilation_flag = false
            end, during)
        end
    end)
end)
time_dilation:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, "time_dilation") < 1
end)
time_dilation:set_monster_check_func(function(skill)
    return false
end)
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
memory.dynamic_hook("event_perform_internal", "int64_t", {"CInstance*", "RValue*", "int", "int", "int"},
    Dynamic.event_perform_internal_ptr, function(ret_val, target, result, object_index, event_type, event_number)
        if not time_dilation_flag then
            return
        end
        if event_type:get() ~= 3 then
            return
        end
        local object_index_ = object_index:get()
        if black_list[object_index_] then
            return
        end
        if gm.object_is(object_index_, gm.constants.pEnemy) then
            if gm.variable_global_get("_current_frame") % 4 ~= 0 then
                return false
            end
        end
    end)
