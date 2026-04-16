-- still terrible
local teleport_skill
local function find_teleport_target(teleport_id)
    local insts = Instance.find_all(gm.constants.oSkillPickup)
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
local teleport_add_sync
local teleport_remove_sync
Initialize.add_hotloadable(function()
    local sprite = Sprite.new("entropy",
        _ENV["!plugins_mod_folder_path"] .. "/sprites/teleport_skill.png")
    -- I suck at drawing, so I just use AI-generated paintings.
    local teleport_sprite = Sprite.new("teleport",
        _ENV["!plugins_mod_folder_path"] .. "/sprites/teleport.png", 0, 65, 67).value
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
        teleport_sprite_list[process] = new_sprite
        gm.sprite_delete(mask_sprite)
    end
    gm.surface_reset_target()
    gm.surface_free(my_surface)

    teleport_skill = Skill.new("teleport")
    teleport_add_sync = Utils.create_sync_func([[
    gm.actor_skill_set(a1, a2, teleport_skill_id)
    local new_skill = gm.array_get(a1.skills, a2).active_skill
    new_skill.teleport_id = a3
]], {Utils.param_type.instance, Utils.param_type.ushort, Utils.param_type.double}, {
        teleport_skill_id = teleport_skill.value
    })
    teleport_remove_sync = Utils.create_sync_func([[
        local id = get_teleport_name(a2)
        gm.event_hook_pre_remove(a1, gm.constants.ev_draw, 0, id)
    ]], {Utils.param_type.instance, Utils.param_type.double}, {
        get_teleport_name = get_teleport_name
    })
    teleport_skill.sprite = sprite
    teleport_skill.damage = 0
    teleport_skill.cooldown = 4 * 60
    teleport_skill.required_interrupt_priority = 3
    teleport_skill.override_strafe_direction = false
    teleport_skill.ignore_aim_direction = true
    teleport_skill.disable_aim_stall = true

    Callback.add(teleport_skill.on_activate, function(actor, struct, slot)
        struct.active = 1.0
        struct.process = 0
        local id = get_teleport_name(struct.teleport_id)
        gm.event_hook_pre_add(actor.value, gm.constants.ev_draw, 0, id, function (actor)
            struct.freeze_cooldown(struct, struct)
            struct.process = struct.process + 1
            if teleport_sprite_list[struct.process] then
                gm.draw_sprite(teleport_sprite_list[struct.process], 0, actor.x, actor.y)
            else
                log.warning("can't find teleport sprite")
            end
            if struct.process == need_process then
                struct.active = 0.0
                local target = find_teleport_target(struct.teleport_id)
                if target then
                    gm.teleport_nearby(actor, target.x, target.y)
                end
                gm.event_hook_pre_remove(actor, gm.constants.ev_draw, 0, id)
            end
        end)
    end)
    Callback.add(teleport_skill.on_step, function(actor, struct, slot)
        if not gm.bool(actor.is_local) then
            return
        end
        if struct.active ~= 1.0 then
            return
        end
        if actor.value:control("skill" .. Utils.to_string_with_floor(slot + 1), false) then
            return
        end
        struct.active = 0.0
        teleport_remove_sync(actor.value, struct.teleport_id)
    end)
    Utils.add_random_skill_blacklist(teleport_skill.value)
end)

local teleport = SkillModifierManager.register_modifier("teleport", 124)
teleport:set_add_func(function(data, modifier_index, teleport_id)
    data:add_post_local_drop_callback(function(actor, skill_params)
        teleport_add_sync(actor, skill_params.slot_index, teleport_id)
    end)
end)
teleport:set_check_func(function(teleport_skill)
    return SkillModifierManager.count_modifier(teleport_skill, "teleport") < 1
end)
teleport:set_monster_check_func(function(teleport_skill)
    return false
end)
local total_teleport_num = 0.0 -- There must be a double because all numbers in gamemaker are stored as double.
teleport:set_default_params_func(function()
    if Net.client then
        log.warning("Teleport modifier should be initialized only on the host")
    end
    total_teleport_num = total_teleport_num + 1
    return total_teleport_num
end)
HookSystem.clean_hook()
HookSystem.post_script_hook(gm.constants.run_create, function(self, other, result, args)
    total_teleport_num = 0.0
end)
