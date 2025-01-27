local perpetual_strike = SkillModifierManager.register_modifier("perpetual_strike")
local max_stack = 5
perpetual_strike:set_add_func(function(data, modifier_index)
    local actor = data.skill.parent
    if actor.is_local == 0 then
        return
    end
    local target_id, stacks
    Instance_ext.add_skill_bullet_fake_hit_actually_attack(actor, data.skill.slot_index, data:get_id(modifier_index),
        function(attack_info, target)
            if target_id ~= target.id then
                target_id = target.id
                stacks = 0
            else
                stacks = math.min(max_stack, stacks + 1)
                attack_info.damage = attack_info.damage * (1 + stacks * 0.2)
            end
        end)
end)
perpetual_strike:set_remove_func(function(data, modifier_index)
    local actor = data.skill.parent
    if actor.is_local == 0 then
        return
    end
    Instance_ext.remove_skill_bullet_callback(actor, data.skill.slot_index, data:get_id(modifier_index), "hit")
end)
perpetual_strike:set_check_func(function(skill)
    return (Utils.is_non_instant_damage_skill(skill.skill_id) or Utils.is_summon_skill(skill.skill_id)) and
               Utils.is_damage_skill(skill.skill_id)
end)

