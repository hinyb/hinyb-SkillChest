-- exp is handle by oDirectorControl
local noxp = SkillModifierManager.register_modifier("noxp")
noxp:set_add_func(function(data, modifier_index)
    data:add_skill_attr_change("damage", function(origin_value)
        return origin_value * 4
    end)
    Instance_ext.add_callback(data.skill.parent, "pre_player_level_up", data:get_id(), function (player)
        return false
    end)
end)
noxp:set_remove_func(function (data, modifier_index)
    Instance_ext.remove_callback(data.skill.parent, "pre_player_level_up", data:get_id())
end)
noxp:set_check_func(function(skill)
    return Utils.is_damage_skill(skill.skill_id) and SkillModifierManager.count_modifier(skill, "noxp") < 1
end)
noxp:set_monster_check_func(function(skill)
    return false
end)