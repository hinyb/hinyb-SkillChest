local function register(name)
    local modifier = SkillModifierManager.register_modifier(name, 250)
    modifier:set_check_func(function(skill)
        return SkillModifierManager.count_modifier(skill, name) < 1
    end)
    modifier:set_add_func(function(data, modifier_index)
        local alarm
        local id = name .. tostring(data.skill.slot_index)
        data:add_pre_activate_callback(function(data)
            local base = math.max(data.skill.cooldown_base, 10)
            Alarm.destroy(alarm)
            local actor = Instance.wrap(data.skill.parent)
            actor:add_callback("onStatRecalc", id, function(actor)
                actor[name] = 1
            end)
            actor[name] = 1
            alarm = Alarm.create(function()
                if actor:exists() then
                    actor:remove_callback(id)
                    actor:recalculate_stats()
                end
            end, math.floor(base))
        end)
    end)
end
register("explosive_shot")
register("lightning")
register("fire_trail")