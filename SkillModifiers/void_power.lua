local void_power = SkillModifierManager.register_modifier("void_power", 250)
void_power:set_add_func(function (data)
    data:add_skill_attr_change("damage", function(origin_value, data)
        return origin_value * 2 ^ Utils.get_empty_skill_num(data.skill.parent)
    end)
    SkillPickup.add_local_drop_callback(data.skill.parent, function()
        gm.get_script_ref(102397)(data.skill, data.skill.parent)
    end)
    SkillPickup.add_local_pick_callback(data.skill.parent, function()
        gm.get_script_ref(102397)(data.skill, data.skill.parent)
    end)
end)
void_power:set_remove_func(function (data)
    SkillPickup.remove_local_drop_callback(data.skill.parent)
    SkillPickup.remove_local_pick_callback(data.skill.parent)
end)