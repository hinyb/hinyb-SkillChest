local function register(name)
    local modifier = SkillModifierManager.register_modifier(name, 250)
    modifier:set_check_func(function(skill)
        return SkillModifierManager.count_modifier(skill, name) < 1
    end)
    modifier:set_add_func(function(data, modifier_index)
        local alarm
        local id = data:get_id()
        data:add_pre_activate_callback(function(data)
            local base = math.max(data.skill.cooldown_base, 10)
            Alarm.remove(alarm)
            local actor = data.skill.parent
            if not InstanceExtManager.callback_exists(actor, "post_recalculate_stats", id) then
                InstanceExtManager.add_callback(actor, "post_recalculate_stats", id, function (actor)
                    actor[name] = 1
                end)
                actor[name] = 1
            end
            local actor_id = actor.id
            alarm = Alarm.add(math.floor(base), function()
                if Instance.exists(actor_id) then
                    InstanceExtManager.remove_callback(actor, "post_recalculate_stats", id)
                    gm.actor_queue_dirty(actor)
                end
            end)
        end)
    end)
    modifier:set_check_func(function(skill)
        return Utils.is_damage_skill(skill.skill_id)
    end)
end
register("explosive_shot")
register("lightning")
register("fire_trail")
