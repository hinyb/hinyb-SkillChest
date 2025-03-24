local perpetual_strike = SkillModifierManager.register_modifier("perpetual_strike")
perpetual_strike.damage_multipiler_per_stack = 0.2
perpetual_strike.max_stack = 5
perpetual_strike:set_add_func(function(data, modifier_index)
    local actor = data.skill.parent
    local target_id, stacks
    InstanceExtManager.add_skill_bullet_fake_hit_actually_attack(actor, data.skill.slot_index, data:get_id(modifier_index),
        function(attack_info, target)
            if target_id ~= target.id then
                target_id = target.id
                stacks = 0
            else
                stacks = math.min(perpetual_strike.max_stack, stacks + 1)
                attack_info.damage = attack_info.damage * (1 + stacks * perpetual_strike.damage_multipiler_per_stack)
            end
        end)
end)
perpetual_strike:set_remove_func(function(data, modifier_index)
    local actor = data.skill.parent
    InstanceExtManager.remove_skill_bullet_callback(actor, data.skill.slot_index, data:get_id(modifier_index), "attack")
end)
perpetual_strike:set_check_func(function(skill)
    return Utils.is_can_track_skill(skill.skill_id) and Utils.is_damage_skill(skill.skill_id)
end)
perpetual_strike:register_component(ComponentTemplates.create_modifier_int_component("perpetual_strike_max_stack", "max_stack"))
perpetual_strike:register_component(ComponentTemplates.create_modifier_double_component("perpetual_strike_damage_multipiler_per_stack",
    "damage_multipiler_per_stack"))
