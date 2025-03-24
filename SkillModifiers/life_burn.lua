local life_burn = SkillModifierManager.register_modifier("life_burn", 250)
life_burn.hp_multipiler = 1.0
life_burn:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, "life_burn") < 1
end)
life_burn:set_add_func(function(data)
    local actor = data.skill.parent
    if not gm.bool(actor.is_local) then
        return
    end
    local num = Utils.get_handy_drone_type(data.skill.skill_id) ~= nil and 25 or data.skill.cooldown_base / 60 * 5
    num = num * life_burn.hp_multipiler
    local last_frame = 0
    data:add_pre_local_can_activate_callback(function(data)
        local current_frame = gm.variable_global_get("_current_frame")
        if last_frame + 1 ~= current_frame then
            if data.skill.stock == 0 then
                gm.actor_skill_add_stock(actor, data.skill.slot_index)
                Utils.set_and_sync_inst_from_table(actor, {
                    hp = actor.hp - num
                })
                data.skill.use_next_frame = 0
                -- can't use skill's sprite, because it don't use image_index.
                -- can solve this but I think it is not necessary.
                Utils.actor_set_kill_cause_sync(actor, actor.sprite_index, "skill_modifier.life_burn.kill_name")
            end
        end
        last_frame = current_frame
    end)
end)
life_burn:set_monster_check_func(function(skill)
    return false
end)
life_burn:register_component(ComponentTemplates.create_modifier_double_component("life_burn_hp_multipiler", "hp_multipiler"))
