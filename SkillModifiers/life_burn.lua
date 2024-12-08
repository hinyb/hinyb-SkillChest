SkillModifier.register_modifier("life_burn", 250, function(skill)
    return SkillModifier.get_modifier_num("life_burn") < 1
end, function(skill, data)
    local num = Utils.get_handy_drone_type(skill.skill_id) ~= nil and 25 or skill.cooldown_base / 60 * 5
    SkillModifier.add_on_can_activate_callback(data, function(skill_, result)
        if not result.value then
            local current_frame = gm.variable_global_get("_current_frame")
            if skill_.use_next_frame <= current_frame then
                if skill_.stock == 0 then
                    log.info(skill_.stock)
                    gm.actor_skill_add_stock(skill_.parent, skill_.slot_index)
                    Utils.set_and_sync_inst_from_table(skill_.parent, {
                        hp = skill_.parent.hp - num
                    })
                end
            end
        end
    end)
end)
