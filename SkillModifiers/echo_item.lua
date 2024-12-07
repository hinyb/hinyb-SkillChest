SkillModifier.register_modifier("echo_item", 3200, nil, function(skill, data, item_id)
    local last_frame = 0
    local stack = 0
    local alarm_stop = function()
    end
    SkillModifier.add_on_activate_callback(data, function(skill_)
        local current_frame = gm.variable_global_get("_current_frame")
        local base = math.max(skill_.cooldown_base, 10)
        if current_frame - last_frame >= base and stack < 4 then
            stack = stack + 1
            gm.item_give(skill_.parent, item_id, 1, 0)
            last_frame = current_frame
        end
        alarm_stop()
        alarm_stop = Utils.add_alarm(function()
            if Instance.exists(skill_.parent) then
                gm.item_take(skill_.parent, item_id, stack, 0)
            end
            stack = 0
            skill_.use_next_frame = current_frame + (base + 60) * 3
        end, math.floor(base + 30))
    end)
end, function(skill, data)
    SkillModifier.remove_on_activate_callback(data)
end, function(ori_desc, skill, item_id)
    local item = Class.ITEM:get(item_id)
    return "<y>" .. Language.translate_token("skill_modifier.echo_item.name") .. ": " ..
               Language.translate_token("skill_modifier.echo_item.description") .. "\n" ..
               Language.translate_token(item:get(2)) .. ": " .. Language.translate_token(item:get(3)) .. "\n" ..
               ori_desc
end, function(skill)
    return Item.get_random().value
end)