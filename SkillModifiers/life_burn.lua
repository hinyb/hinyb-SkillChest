local life_burn = SkillModifierManager.register_modifier("life_burn", 250)
life_burn:set_check_func(function (skill)
    return SkillModifierManager.count_modifier(skill, "life_burn") < 1
end)
life_burn:set_add_func(function (data)
    local num = Utils.get_handy_drone_type(data.skill.skill_id) ~= nil and 25 or data.skill.cooldown_base / 60 * 5
    data:add_post_can_activate_callback(function(data, result)
        if not result.value then
            local current_frame = gm.variable_global_get("_current_frame")
            if data.skill.use_next_frame <= current_frame then
                if data.skill.stock == 0 then
                    gm.actor_skill_add_stock(data.skill.parent, data.skill.slot_index)
                    Utils.set_and_sync_inst_from_table(data.skill.parent, {
                        hp = data.skill.parent.hp - num
                    })
                end
            end
        end
    end)
end)