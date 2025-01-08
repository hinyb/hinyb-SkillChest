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
            Alarm.destroy(alarm)
            alarm = Alarm.create(function()
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
    [gm.constants.oInit] = true
}
local need_to_step_list = {
    [gm.constants.oInit] = true,
    [gm.constants.oDirectorControl] = true
}
local cache_table = {}
local last_current_frame
memory.dynamic_hook("event_perform_internal", "int64_t", {"CInstance*", "RValue*", "int", "int", "int"},
    Dynamic.event_perform_internal, function(ret_val, target, result, object_index, event_type, event_number)
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
            if gm.variable_global_get("_current_frame") % 2 == 0 then
                return false
            end
        elseif gm.object_is(object_index_, gm.constants.pFriend) or need_to_step_list[object_index] then
            local current_frame = gm.variable_global_get("_current_frame")
            if current_frame % 2 == 0 then
                if current_frame ~= last_current_frame then
                    cache_table = {}
                    last_current_frame = current_frame
                end
                local number = event_number:get()
                local target_cache = cache_table[target.id]
                if target_cache == nil then
                    target_cache = {}
                    cache_table[target.id] = target_cache
                end
                if not target_cache[number] then
                    target_cache[number] = true
                    target:event_perform(3, number)
                    target:event_perform(3, number)
                end
            end
        end
    end)
