local echo_item = SkillModifierManager.register_modifier("echo_item", 3200)
echo_item:set_add_func(function (data, modifier_index, item_id)
    local last_frame = 0
    local stack = 0
    local alarm
    data:add_pre_activate_callback(function(data)
        local current_frame = gm.variable_global_get("_current_frame")
        local base = math.max(data.skill.cooldown_base, 10)
        if current_frame - last_frame >= base and stack < 4 then
            stack = stack + 1
            gm.item_give(data.skill.parent, item_id, 1, 0)
            last_frame = current_frame
        end
        Alarm.destroy(alarm)
        local player = data.skill.parent
        alarm = Alarm.create(function()
            if Instance.exists(player) then
                gm.item_take(player, item_id, stack, 0)
            end
            stack = 0
            if data.skill then
                data.skill.use_next_frame = current_frame + math.max(4*60 - base, 60) * 3
            end
        end, math.floor(base + 40))
    end)
end)
echo_item:set_info_func(function(ori_desc, data, item_id)
    local item = Class.ITEM:get(item_id)
    return "<y>" .. Language.translate_token("skill_modifier.echo_item.name") .. ": " ..
               Language.translate_token("skill_modifier.echo_item.description") .. "\n" ..
               Language.translate_token(item:get(2)) .. ": " .. Language.translate_token(item:get(3)) .. "\n" ..
               ori_desc
end)
echo_item:set_default_params_func(function ()
    return Item.get_random().value
end)