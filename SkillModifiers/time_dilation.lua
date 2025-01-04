-- This modifier may have many sync issues.
-- Maybe make everything stop is more interesting.
local sound
Initialize(function ()
    sound = Resources.sfx_load("hinyb", "clockticks", _ENV["!plugins_mod_folder_path"] .. "/sounds/clockticks.ogg")
end)
local during = 60
local cooldown = 60 * 8
local time_dilation_flag = false
local alarm
local time_dilation = SkillModifierManager.register_modifier("time_dilation", 50)
time_dilation:set_add_func(function(data, modifier_index, item_id)
    local last_frame = 0
    data:add_pre_activate_callback(function(data)
        local current_frame = gm.variable_global_get("_current_frame")
        if current_frame - last_frame >= cooldown and not time_dilation_flag then
            last_frame = current_frame
            gm.game_set_speed(24, false)
            gm.audio_play_sound(sound, 1.0, true)
            time_dilation_flag = true
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
local flag = true
gm.post_script_hook(gm.constants.step_player, function(self, other, result, args)
    if flag and time_dilation_flag then
        flag = false
        local self_addr = memory.get_usertype_pointer(self)
        local other_addr = memory.get_usertype_pointer(other)
        for _ = 1, 3 do
            _G[Dynamic.oP_Step_1](self_addr, other_addr)
            _G[Dynamic.oP_Step_2](self_addr, other_addr)
        end
        flag = true
    end
end)
gm.post_script_hook(gm.constants.step_actor, function(self, other, result, args)
    if flag and time_dilation_flag and self.object_index == gm.constants.oPDrone then
        flag = false
        local self_addr = memory.get_usertype_pointer(self)
        local other_addr = memory.get_usertype_pointer(other)
        for _ = 1, 3 do
            _G[Dynamic.oPDrone_Step_2](self_addr, other_addr)
        end
        flag = true
    end
end)