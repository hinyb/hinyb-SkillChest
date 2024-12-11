local life_burn = SkillModifierManager.register_modifier("life_burn", 250)
life_burn:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, "life_burn") < 1
end)
life_burn:set_add_func(function(data)
    local num = Utils.get_handy_drone_type(data.skill.skill_id) ~= nil and 25 or data.skill.cooldown_base / 60 * 5
    local last_frame = 0
    data:add_pre_can_activate_callback(function(data)
        local current_frame = gm.variable_global_get("_current_frame")
        if last_frame + 1 ~= current_frame then
            if data.skill.stock == 0 then
                gm.actor_skill_add_stock(data.skill.parent, data.skill.slot_index)
                Utils.set_and_sync_inst_from_table(data.skill.parent, {
                    hp = data.skill.parent.hp - num
                })
                data.skill.use_next_frame = 0
            end
        end
        last_frame = current_frame
    end)
end)
