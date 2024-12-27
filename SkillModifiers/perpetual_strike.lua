local perpetual_strike = SkillModifierManager.register_modifier("perpetual_strike")
local max_stack = 5
perpetual_strike:set_add_func(function(data, modifier_index)
    local target_id, stacks
    local id_prefix = "perpetual_strike" .. tostring(data.skill.slot_index) .. tostring(modifier_index)
    data:add_pre_activate_callback(function(data)
        Instance_ext.add_callback(data.skill.parent, "pre_damager_attack_process", id_prefix,
            function(attack_info, hit_list)
                if gm.ds_list_size(hit_list) == 3.0 then
                    local hit_first = gm.ds_list_find_value(hit_list, 0)
                    if target_id ~= hit_first.id then
                        target_id = hit_first.id
                        stacks = 0
                    else
                        stacks = math.min(max_stack, stacks + 1)
                        attack_info.damage = attack_info.damage * (1 + stacks * 0.1)
                    end
                end
            end)
    end)
    data:add_post_activate_callback(function(data)
        Instance_ext.add_on_anim_end(data.skill.parent, id_prefix, function (actor)
            Instance_ext.remove_callback(actor.value, "pre_damager_attack_process", id_prefix)
        end)
    end)
end)
perpetual_strike:set_check_func(function(skill)
    return Utils.is_instant_skill(skill.skill_id) and Utils.is_damage_skill(skill.skill_id)
end)

