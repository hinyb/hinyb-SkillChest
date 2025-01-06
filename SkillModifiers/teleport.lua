local skill
local function find_teleport_target(teleport_id)
    local insts = Instance.find_all(SkillPickup.skillPickup_object_index)
    for i = 1, #insts do
        local inst = insts[i].value
        if inst.ctm_arr_modifiers ~= nil then
            local modifiers = Array.wrap(inst.ctm_arr_modifiers)
            for i = 0, modifiers:size() - 1 do
                local modifier = modifiers:get(i)
                if modifier:get(0) == "teleport" then
                    if modifier:get(1) == teleport_id then
                        return inst
                    end
                end
            end
        end
    end
end
local need_process = 120
local teleport_sprite
local teleport_sprite_list = {}
local function calculate_vertex(angle, l)
    local r = l / 2
    local rad = math.rad(angle)
    local result = {{r, r}, {r, 0}}
    if angle > 45 then
        table.insert(result, {l, 0})
    end
    if angle > 135 then
        table.insert(result, {l, l})
    end
    if angle > 225 then
        table.insert(result, {0, l})
    end
    if angle > 315 then
        table.insert(result, {0, 0})
    end
    if angle < 45 then
        table.insert(result, {r + r * math.tan(rad), 0})
    elseif angle < 135 then
        table.insert(result, {l, r - r / math.tan(rad)})
    elseif angle < 225 then
        table.insert(result, {r - r * math.tan(rad), l})
    elseif angle < 315 then
        table.insert(result, {0, r + r / math.tan(rad)})
    else
        table.insert(result, {r + r * math.tan(rad), 0})
    end
    return result
end
local function get_teleport_name(teleport_id)
    return "teleport" .. Utils.to_string_with_floor(teleport_id)
end
local teleport_add_message, teleport_remove_message
Initialize(function()
    teleport_add_message = Utils.create_packet(function(player, actor, slot_index, teleport_id)
        gm.actor_skill_set(actor, slot_index, skill.value)
        local new_skill = gm.array_get(actor.skills, slot_index).active_skill
        new_skill.teleport_id = teleport_id
    end, {Utils.param_type.Instance, Utils.param_type.int, Utils.param_type.int})
    teleport_remove_message = Utils.create_packet(function(player, actor, teleport_id)
        local actor_ = Instance.wrap(actor)
        local id = get_teleport_name(teleport_id)
        actor_:remove_callback(id)
    end, {Utils.param_type.Instance, Utils.param_type.int})
    local sprite = Resources.sprite_load("hinyb", "entropy",
        _ENV["!plugins_mod_folder_path"] .. "/sprites/teleport_skill.png")
    -- I suck at drawing, so I just use AI-generated paintings.
    teleport_sprite = Resources.sprite_load("hinyb", "teleport",
        _ENV["!plugins_mod_folder_path"] .. "/sprites/teleport.png", 0, 65, 67)
    skill = Skill.new("hinyb", "teleport")
    skill:set_skill_icon(sprite, 0)
    skill:set_skill_properties(0, 4 * 60)
    skill:set_skill_stock(1, 1, true, 1)
    skill:set_skill_settings(true, false, 3, false, false, true, true, false)
    skill:onActivate(function(actor, struct, index)
        struct.active = 1.0
        struct.process = 0
        local id = get_teleport_name(struct.teleport_id)
        actor:add_callback("onPreDraw", id, function()
            struct.freeze_cooldown(struct, struct)
            struct.process = struct.process + 1
            local angle = struct.process / need_process * 360
            gm.draw_sprite(teleport_sprite_list[angle], 0, actor.x, actor.y)
            if struct.process == need_process then
                struct.active = 0.0
                local target = find_teleport_target(struct.teleport_id)
                if target then
                    gm.teleport_nearby(actor.value, target.x, target.y)
                end
                actor:remove_callback(id)
            end
        end)
    end)
    skill:onPostStep(function(actor, struct, index)
        if not actor.is_local then
            return
        end
        if struct.active ~= 1.0 then
            return
        end
        if gm.call("gml_Script_control", actor.value, actor.value, "skill" .. Utils.to_string_with_floor(index + 1), false) then
            return
        end
        struct.active = 0.0
        local id = get_teleport_name(struct.teleport_id)
        actor:remove_callback(id)
        if Net.is_host() then
            teleport_remove_message(Utils.packet_type.not_forward, actor, struct.teleport_id):send_to_all()
        elseif Net.is_client() then
            teleport_remove_message(Utils.packet_type.forward, actor, struct.teleport_id):send_to_host()
        end
    end)
    SkillPickup.add_skill_override_check_func(function(actor, skill_)
        return skill_.skill_id == skill.value
    end)
    SkillPickup.add_skill_check_func(function(actor, skill_)
        return skill_.skill_id ~= skill.value
    end)
    local my_surface = gm.surface_create(128, 128)
    gm.surface_set_target(my_surface)
    for process = 1, need_process do
        local angle = process / need_process * 360
        gm.draw_clear_alpha(Color.BLACK, 0)
        gm.draw_set_color(Color.WHITE)
        gm.draw_primitive_begin(6)
        local res = calculate_vertex(angle, 128)
        for i = 1, #res do
            gm.draw_vertex(res[i][1], res[i][2])
        end
        gm.draw_primitive_end();
        local mask_sprite = gm.sprite_create_from_surface(my_surface, 0, 0, 128, 128, false, false, 64, 64)
        local new_sprite = gm.sprite_duplicate(teleport_sprite)
        gm.sprite_set_alpha_from_sprite(new_sprite, mask_sprite)
        teleport_sprite_list[angle] = new_sprite
        gm.sprite_delete(mask_sprite)
    end
    gm.surface_reset_target()
    gm.surface_free(my_surface)
end)

local teleport = SkillModifierManager.register_modifier("teleport", 124)
teleport:set_add_func(function(data, modifier_index, teleport_id)
    data:add_post_local_drop_callback(function(actor, skill_params)
        gm.actor_skill_set(actor, skill_params.slot_index, skill.value)
        local new_skill = gm.array_get(actor.skills, skill_params.slot_index).active_skill
        new_skill.teleport_id = teleport_id
        if Net.is_host() then
            teleport_add_message(Utils.packet_type.not_forward, actor, skill_params.slot_index, teleport_id):send_to_all()
        elseif Net.is_client() then
            teleport_add_message(Utils.packet_type.forward, actor, skill_params.slot_index, teleport_id):send_to_host()
        end
    end)
end)
teleport:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, "teleport") < 1
end)
teleport:set_monster_check_func(function(skill)
    return false
end)
local total_teleport_num = 0.0 -- There must be a double because all numbers in gamemaker are stored as double.
teleport:set_default_params_func(function()
    total_teleport_num = total_teleport_num + 1
    return total_teleport_num
end)
gm.post_script_hook(gm.constants.run_create, function(self, other, result, args)
    total_teleport_num = 0.0
end)
