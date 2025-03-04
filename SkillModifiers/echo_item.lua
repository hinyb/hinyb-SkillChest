local echo_item = SkillModifierManager.register_modifier("echo_item", 2400)
echo_item:set_add_func(function(data, modifier_index, item_id)
    data.skill.is_primary = 0
    local time = (Item.wrap(item_id).tier + 1) * 30
    data.skill.cooldown_base = data.skill.cooldown_base + time
    gm._mod_ActorSkill_recalculateStats(data.skill)
    local stack = 0
    local alarm
    data:add_pre_activate_callback(function(data)
        if stack < 5 then
            stack = stack + 1
            gm.item_give(data.skill.parent, item_id, 1, 1)
        end
        Alarm.destroy(alarm)
        local player = data.skill.parent
        local player_id = player.id
        alarm = Alarm.create(function()
            if Instance.exists(player_id) then
                gm.item_take(player, item_id, stack, 1)
            end
            stack = 0
        end, math.floor(data.skill.cooldown_base + time / 2))
    end)
end)
echo_item:set_info_func(function(ori_desc, data, item_id)
    local item = Class.ITEM:get(item_id)
    return Language.translate_token("skill_modifier.echo_item.name") .. ": " ..
               Language.translate_token("skill_modifier.echo_item.description") .. "\n" .. "<r>" ..
               Language.translate_token(item:get(2)) .. "</c>" .. ": " .. Language.translate_token(item:get(3)) .. "\n" ..
               ori_desc
end)
echo_item:set_default_params_func(function()
    local item_id = Item.get_random().value
    while item_id == 76 do
        item_id = Item.get_random().value
    end
    return item_id
end)
