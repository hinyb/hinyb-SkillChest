SkillModifier.register_modifier("life_burn", 250, function(skill)
    return SkillModifier.get_modifier_num("life_burn") < 1
end, function(skill, data)
    SkillModifier.add_on_can_activate_callback(data, function(skill_, result)
        if not result.value then
            local current_frame = gm.variable_global_get("_current_frame")
            if skill_.use_next_frame <= current_frame then
                if skill_.stock == 0 then
                    Utils.sync_call("gml_Script_actor_skill_add_stock", "client_and_host", skill_.parent,
                        skill_.slot_index)
                    local num = Utils.get_handy_drone_type(skill_.skill_id) ~= nil and 25 or skill_.cooldown_base / 60 *
                                    5
                    Utils.set_and_sync_inst_from_table(skill_.parent, {
                        hp = skill_.parent.hp - num
                    })
                end
            end
        end
    end)
end, function(skill, data)
    SkillModifier.remove_on_can_activate_callback(data)
end)