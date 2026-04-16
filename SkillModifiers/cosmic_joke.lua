Initialize.add_hotloadable(function()
    local cosmic_joke_packet = Packet.new("cosmic_joke_packet")
    cosmic_joke_packet:set_serializers(function(buffer, target)
        buffer:write_instance(target)
    end, function(buffer, player)
        local target = buffer:read_instance().value

        local cache_elite = target.elite_type

        target:instance_change(gm.constants.oLizard, true)

        if cache_elite ~= -1 then
            target:elite_set_internal(target.id, cache_elite)
        end

        if target.hp < target.maxhp then
            target.hp = target.maxhp
        end
    end)
end)
local cosmic_joke = SkillModifierManager.register_modifier("cosmic_joke", 50)
cosmic_joke.probability = 0.05
cosmic_joke:set_add_func(function(data, modifier_index)
    InstanceExtManager.add_skill_bullet_callback(data.skill.parent, data.skill.slot_index, data:get_id(modifier_index),
        "hit", function(hit_info, target)
            if target.object_index == gm.constants.oLizard then
                return
            end
            if target.boss_drop_item ~= 0.0 then
                return
            end
            if math.random() < 0.05 then
                if Net.host then
                    cosmic_joke_packet:send_to_all(target)
                end
                local cache_elite = target.elite_type
                target:instance_change(gm.constants.oLizard, true)
                if cache_elite ~= -1 then
                    target:elite_set_internal(target.id, cache_elite)
                end
                if target.hp < target.maxhp then
                    target.hp = target.maxhp
                end
            end
        end)
end)
cosmic_joke:set_remove_func(function(data, modifier_index)
    InstanceExtManager.remove_skill_bullet_callback(data.skill.parent, data.skill.slot_index,
        data:get_id(modifier_index), "hit")
end)
cosmic_joke:set_check_func(function(skill)
    return Utils.is_can_track_skill(skill.skill_id) and Utils.is_damage_skill(skill.skill_id)
end)
cosmic_joke:set_monster_check_func(function(skill)
    return false
end)
cosmic_joke:register_component(ComponentTemplates.create_modifier_double_component("cosmic_joke_proability",
    "probability"))
