local fire_trail = SkillModifierManager.register_modifier("fire_trail", 250)
fire_trail:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, "fire_trail") < 1
end)
fire_trail:set_add_func(function (data, modifier_index, item_id)
    local alarm
    data:add_pre_activate_callback(function(data)
        local base = math.max(data.skill.cooldown_base, 10)
        Alarm.destroy(alarm)
        local player = data.skill.parent
        player.fire_trail = 1
        alarm = Alarm.create(function()
            if Instance.exists(player) then
                player.fire_trail = 0
            end
        end, math.floor(base))
    end)
end)