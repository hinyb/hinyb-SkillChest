require("SkillModifier")
require("SkillModifierData")

-- maybe I need rewrite the modifier_data
HookSystem.clean_hook()
local modifier_pool = {}
local modifiers_name_order = {}
local default_weight = 500
local skills_data = {}
local total_weight = 0
SkillModifierManager = {}
SkillModifierManager.modifiers_name_order = modifiers_name_order
---@param modifier_name string The name of modifier being registered. This should be a unique identifier for the modifier.
---@param weight number? The weight of the modifier being registered. The default weight is 500.
SkillModifierManager.register_modifier = function(modifier_name, weight)
    weight = weight or default_weight
    total_weight = total_weight + weight
    local modifier = SkillModifier.new(modifier_name, weight)
    if modifier_pool[modifier_name] then
        log.warning("Seems some modifiers have the same name", modifier_name)
    else
        modifiers_name_order[#modifiers_name_order + 1] = modifier_name
    end
    modifier_pool[modifier_name] = modifier
    return modifier
end
SkillModifierManager.get_modifier = function(modifier_name)
    local modifier = modifier_pool[modifier_name]
    if not modifier then
        log.error("Try to get a non-existent modifier", modifier_name)
    end
    return modifier
end
SkillModifierManager.add_modifier_params = function(skill_params, modifier_name, ...)
    local modifier = SkillModifierManager.get_modifier(modifier_name)
    if not modifier.check_func(skill_params) then
        log.error("Can't add the modifier to this skill_params " .. modifier_name, 2)
    end
    local params = { ... }
    params = #params > 0 and params or { modifier.default_params_func(skill_params) }
    skill_params.ctm_arr_modifiers = skill_params.ctm_arr_modifiers or {}
    table.insert(skill_params.ctm_arr_modifiers, { modifier_name, table.unpack(params) })
    return #skill_params.ctm_arr_modifiers - 1, table.unpack(params)
end
-- here may cause memory leak, need to solve.
SkillModifierManager.add_modifier_local = function(skill, modifier_name, ...)
    local modifier = SkillModifierManager.get_modifier(modifier_name)
    if not modifier.check_func(skill) then
        log.error("Can't add the modifier to this skill " .. modifier_name, 2)
    end
    local params = { ... }
    params = #params > 0 and params or { modifier.default_params_func(skill) }
    skill.ctm_arr_modifiers = skill.ctm_arr_modifiers or gm.array_create(0, 0)
    local arr_modifier = gm.array_create(1, modifier_name)
    for i = 1, #params do
        gm.array_push(arr_modifier, params[i])
    end
    gm.array_push(skill.ctm_arr_modifiers, arr_modifier)
    local modifier_index = math.floor(gm.array_length(skill.ctm_arr_modifiers) - 1)
    local data = SkillModifierManager.create_modifier_data(skill, modifier_index, modifier_name)
    modifier.add_func(data, modifier_index, table.unpack(params))
    return modifier_index, table.unpack(params)
end
local add_modifier_packet
SkillModifierManager.add_modifier_sync = function(skill, modifier_name, ...)
    local modifier_details = { SkillModifierManager.add_modifier_local(skill, modifier_name, ...) }
    table.remove(modifier_details, 1)
    if not Net.online then
        return
    end
    if Net.host then
        add_modifier_packet:send_to_all(skill.parent, skill.slot_index, modifier_name, table.unpack(modifier_details))
    elseif Net.client then
        add_modifier_packet:send_to_host(skill.parent, skill.slot_index, modifier_name, table.unpack(modifier_details))
    end
end
-- don't actually remove ctm_arr_modifiers
SkillModifierManager.remove_modifier_local = function(skill, modifier_index)
    local data = SkillModifierManager.get_modifier_data(skill, modifier_index)
    local modifier = SkillModifierManager.get_modifier(data.modifier_name)
    local modifier_data = Array.wrap(skill.ctm_arr_modifiers):get(modifier_index)
    local params = {}
    for i = 1, modifier_data:size() - 1 do
        params[#params + 1] = modifier_data:get(i)
    end
    modifier.remove_func(data, modifier_index, table.unpack(params))
    SkillModifierManager.clear_modifier_data(skill, modifier_index)
end
SkillModifierManager.remove_modifier_sync = function(skill, modifier_index)
    SkillModifierManager.remove_modifier_local(skill, modifier_index)
    if not Net.online then
        return
    end
    if Net.host then
        remove_modifier_packet:send_to_all(skill.parent, skill.slot_index, modifier_index)
    elseif Net.client then
        remove_modifier_packet:send_to_host(skill.parent, skill.slot_index, modifier_index)
    end
end
SkillModifierManager.clear_and_set_skill_sync = function(instance, slot_index, skill_id)
    skill_id = skill_id or 0
    local skill = gm.array_get(instance.skills, slot_index).active_skill
    if skill.ctm_arr_modifiers then
        local ctm_arr_modifiers = Array.wrap(skill.ctm_arr_modifiers)
        for i = 0, ctm_arr_modifiers:size() - 1 do
            SkillModifierManager.remove_modifier_local(skill, i)
        end
    end
    gm.actor_skill_set(skill.parent, skill.slot_index, skill_id)
    if not Net.online then
        return
    end
    if Net.host then
        clear_and_set_skill_packet:send_to_all(skill.parent, skill.slot_index, skill_id)
    elseif Net.client then
        clear_and_set_skill_packet:send_to_host(skill.parent, skill.slot_index, skill_id)
    end
end
SkillModifierManager.create_modifier_data = function(skill, modifier_index, modifier_name)
    local address = memory.get_usertype_pointer(skill)
    skills_data[address] = skills_data[address] or {}
    if skills_data[address][modifier_index] then
        log.error("Modifier has been created.", 2)
    end
    skills_data[address][modifier_index] = SkillModifierData.new(skill, modifier_name)
    return skills_data[address][modifier_index]
end
SkillModifierManager.get_modifier_data = function(skill, modifier_index)
    return skills_data[memory.get_usertype_pointer(skill)][modifier_index]
end
SkillModifierManager.clear_modifier_data = function(skill, modifier_index)
    skills_data[memory.get_usertype_pointer(skill)][modifier_index] = nil
end
SkillModifierManager.get_random_modifier_name = function()
    local rand = math.random(0, total_weight)
    local sum_weight = 0
    for name, modifier in pairs(modifier_pool) do
        sum_weight = sum_weight + modifier.weight
        if rand <= sum_weight and modifier.enable then
            return name
        end
    end
end
SkillModifierManager.count_modifier = function(skill, modifier_name)
    local stack = 0
    if skill.ctm_arr_modifiers ~= nil then
        if lua_type(skill) == "table" then
            for _, modifier_data in ipairs(skill.ctm_arr_modifiers) do
                if modifier_data[1] == modifier_name then
                    stack = stack + 1
                end
            end
        elseif lua_type(skill) == "userdata" then
            for i = 0, gm.array_length(skill.ctm_arr_modifiers) - 1 do
                if gm.array_get(gm.array_get(skill.ctm_arr_modifiers, i), 0) == modifier_name then
                    stack = stack + 1
                end
            end
        else
            log.error("Can't count the skill's modifiers" .. modifier_name, 2)
        end
    end
    return stack
end
SkillModifierManager.get_random_modifier_name_with_check = function(skill)
    local random_modifier_name = SkillModifierManager.get_random_modifier_name()
    if not random_modifier_name then
        return
    end
    local random_modifier = modifier_pool[random_modifier_name]
    return random_modifier.check_func(skill) and random_modifier_name or
        SkillModifierManager.get_random_modifier_name_with_check(skill)
end
SkillModifierManager.get_random_modifier_name_with_monster_check = function(skill)
    local random_modifier_name = SkillModifierManager.get_random_modifier_name_with_check(skill)
    if not random_modifier_name then
        return
    end
    local random_modifier = modifier_pool[random_modifier_name]
    return random_modifier.monster_check_func(skill) and random_modifier_name or
        SkillModifierManager.get_random_modifier_name_with_monster_check(skill)
end
SkillModifierManager.update_weight = function()
    total_weight = 0
    for _, modifier in pairs(modifier_pool) do
        total_weight = total_weight + modifier.weight
    end
end
HookSystem.post_script_hook(gm.constants.run_destroy, function(self, other, result, args)
    skills_data = {}
end)
Initialize.add_hotloadable(function()
    local remove_modifier_packet = Packet.new("remove_modifier_packet")
    remove_modifier_packet:set_serializers(function(buffer, instance, slot_index, modifier_index)
        buffer:write_instance(instance)
        buffer:write_byte(slot_index)
        buffer:write_byte(modifier_index)
    end, function(buffer, player)
        local instance = buffer:read_instance().value
        local slot_index = buffer:read_byte()
        local modifier_index = buffer:read_byte()

        local skill = gm.array_get(instance.skill, slot_index).active_skill
        SkillModifierManager.remove_modifier_local(skill, modifier_index)

        if Net.host then
            remove_modifier_packet:send_exclude(player, instance, slot_index, modifier_index)
        end
    end)
    local clear_and_set_skill_packet = Packet.new("clear_and_set_skill_packet")
    clear_and_set_skill_packet:set_serializers(function(buffer, instance, slot_index, skill_id)
        buffer:write_instance(instance)
        buffer:write_byte(slot_index)
        buffer:write_ushort(skill_id)
    end, function(buffer, player)
        local instance = buffer:read_instance().value
        local slot_index = buffer:read_byte()
        local skill_id = buffer:read_ushort()

        local skill = gm.array_get(instance.skills, slot_index).active_skill
        if skill.ctm_arr_modifiers then
            local ctm_arr_modifiers = Array.wrap(skill.ctm_arr_modifiers)
            for i = 0, ctm_arr_modifiers:size() - 1 do
                SkillModifierManager.remove_modifier_local(skill, i)
            end
        end
        gm.actor_skill_set(skill.parent, skill.slot_index, skill_id)

        if Net.host then
            clear_and_set_skill_packet:send_exclude(player, instance, slot_index, skill_id)
        end
    end)
    add_modifier_packet = Packet.new("add_modifier_packet")
    add_modifier_packet:set_serializers(function(buffer, instance, slot_index, modifier_name, ...)
        buffer:write_instance(instance)
        buffer:write_byte(slot_index)
        buffer:write_string(modifier_name)
        local params = { ... }
        buffer:write_byte(#params)
        for i = 1, #params do
            buffer:write_float(params[i])
        end
    end, function(buffer, player)
        local instance = buffer:read_instance().value
        local slot_index = buffer:read_byte()
        local modifier_name = buffer:read_string()
        local skill = gm.array_get(instance.skills, slot_index).active_skill
        local param_num = buffer:read_byte()
        local params = {}
        for i = 1, param_num do
            params[i] = buffer:read_float()
        end

        SkillModifierManager.add_modifier_local(skill, modifier_name, table.unpack(params))

        if Net.host then
            add_modifier_packet:send_exclude(player, instance, slot_index, modifier_name, table.unpack(params))
        end
    end)
end)

local names = path.get_files(_ENV["!plugins_mod_folder_path"] .. "/SkillModifiers")
for _, name in ipairs(names) do
    require(name)
end
