local perpetual_strike = SkillModifierManager.register_modifier("perpetual_strike")
local max_stack = 5
perpetual_strike:set_add_func(function(data, modifier_index)
    local target_id, stacks
    local id_prefix = "perpetual_strike" .. tostring(data.skill.slot_index) .. tostring(modifier_index)
    Instance_ext.add_skill_bullet_hit(data.skill.parent, data.skill.slot_index, id_prefix,
        function(bullet, hit_info, target)
            if target_id ~= target.id then
                target_id = target.id
                stacks = 0
            else
                stacks = math.min(max_stack, stacks + 1)
                hit_info.damage = hit_info.damage * (1 + stacks * 1)
            end
        end)
end)
perpetual_strike:set_remove_func(function(data, modifier_index)
    local id_prefix = "perpetual_strike" .. tostring(data.skill.slot_index) .. tostring(modifier_index)
    Instance_ext.remove_skill_captrue(data.skill.parent, data.skill.slot_index, id_prefix)
end)
perpetual_strike:set_check_func(function(skill)
    return (Utils.is_non_instant_damage_skill(skill.skill_id) or Utils.is_summon_skill(skill.skill_id)) and
               Utils.is_damage_skill(skill.skill_id)
end)

