local evolving_hunger_message
Initialize(function ()
    evolving_hunger_message = Utils.create_packet(function (player, id, total_num, inst)
        local actor = Instance.wrap(inst)
        actor:remove_callback(id)
        actor:add_callback("onStatRecalc", id, function (actor)
            actor.maxhp = actor.maxhp - total_num
            if actor.hp < actor.maxhp then
                actor.hp = actor.maxhp
            end
        end)
    end, {Utils.param_type.string, Utils.param_type.int, Utils.param_type.Instance})
end)
local evolving_hunger = SkillModifierManager.register_modifier("evolving_hunger", 3200)
evolving_hunger:set_default_params_func(function ()
    return 1
end)
evolving_hunger:set_add_func(function (data, modifier_index)
    local total_num = 0
    data:add_pre_activate_callback(function(data)
        local modifer = Array.wrap(data.skill.ctm_arr_modifiers):get(modifier_index)
        local times = modifer:get(1)
        local num = 1.24 * times * 1.12 ^ times
        total_num = Utils.round(total_num + num)
        local actor = Instance.wrap(data.skill.parent)
        local skill_address = memory.get_usertype_pointer(data.skill)
        local id = tostring(skill_address)..tostring(modifier_index)
        actor:remove_callback(id)
        actor:add_callback("onStatRecalc", id, function (actor)
            actor.maxhp = actor.maxhp - total_num
            if actor.hp < actor.maxhp then
                actor.hp = actor.maxhp
            end
        end)
        if Utils.get_net_type() == Net.TYPE.host then
            evolving_hunger_message(Utils.packet_type.not_forward, id, total_num, data.skill.parent):send_to_all()
        elseif Utils.get_net_type() == Net.TYPE.client then
            evolving_hunger_message(Utils.packet_type.forward, id, total_num, data.skill.parent):send_to_host()
        end
        data:add_skill_attr_change("damage", function (origin_value)
            return origin_value * 1.5
        end)
        data:add_skill_attr_change("cooldown",function (origin_value)
            return origin_value + Utils.round(num * 0.15 * 60)
        end)
        times = times + 1
        modifer:set(1, times)
    end)
end)
evolving_hunger:set_check_func(function (skill)
    return SkillModifierManager.count_modifier(skill, evolving_hunger.modifier_name) < 2
end)