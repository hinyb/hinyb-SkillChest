local void_power = SkillModifierManager.register_modifier("void_power", 250)
void_power:set_add_func(function(data, modifier_index)
    data:add_skill_attr_change("damage", function(origin_value, data)
        return origin_value * 2 ^ Utils.get_empty_skill_num(data.skill.parent)
    end)
    Instance_ext.add_callback(data.skill.parent, "post_local_drop",
        "void_power_skill_recalculate_stats" .. tostring(data.skill.slot_index), function()
            gm.get_script_ref(102397)(data.skill, data.skill.parent)
        end)
    Instance_ext.add_callback(data.skill.parent, "post_local_pickup",
        "void_power_skill_recalculate_stats" .. tostring(data.skill.slot_index), function()
            gm.get_script_ref(102397)(data.skill, data.skill.parent)
        end)
end)
void_power:set_remove_func(function(data, modifier_index)
    Instance_ext.remove_callback(data.skill.parent, "post_local_drop",
        "void_power_skill_recalculate_stats" .. tostring(data.skill.slot_index))
    Instance_ext.remove_callback(data.skill.parent, "post_local_pickup",
        "void_power_skill_recalculate_stats" .. tostring(data.skill.slot_index))
end)
void_power:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id)
end)
