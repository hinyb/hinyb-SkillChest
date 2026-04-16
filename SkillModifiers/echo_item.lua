local echo_item = SkillModifierManager.register_modifier("echo_item", 2400)
echo_item.duration_multiplier = 1.0
local item_blacklist = {}
echo_item:set_add_func(function(data, modifier_index, item_id)
    data.skill.is_primary = 0
    local time = (Item.wrap(item_id).tier + 1) * 30 * echo_item.duration_multiplier
    data.skill.cooldown_base = data.skill.cooldown_base + time
    gm._mod_ActorSkill_recalculateStats(data.skill)
    local stack = 0
    local alarm
    data:add_pre_activate_callback(function(data)
        if stack < 5 then
            stack = stack + 1
            gm.item_give(data.skill.parent, item_id, 1, 1)
        end
        Alarm.remove(alarm)
        local player = data.skill.parent
        local player_id = player.id
        alarm = Alarm.add(math.floor(data.skill.cooldown_base + time / 2), function()
            if Instance.exists(player_id) then
                gm.item_take(player, item_id, stack, 1)
            end
            stack = 0
        end)
    end)
end)
echo_item:set_info_func(function(ori_desc, data, item_id)
    local item = Class.ITEM:get(item_id)
    return gm.translate("skill_modifier.echo_item.name") .. ": " ..
               gm.translate("skill_modifier.echo_item.description") .. "\n" .. "<r>" ..
               gm.translate(item:get(2)) .. "</c>" .. ": " .. gm.translate(item:get(3)) .. "\n" ..
               ori_desc
end)

local cache_items
local get_random_item = function(...)
    if cache_items then
        return cache_items[Utils.random_item_id()]
    end
    local items = {}

    for i, _ in ipairs(Class.ITEM) do
        local item = Item.wrap(i - 1)
        if item.identifier ~= "dummyItem" then
            table.insert(items, item.value)
        end
    end

    return items[gm.irandom_range(1, #items)]
end

echo_item:set_default_params_func(function()
    local item_id = get_random_item()
    while item_blacklist[item_id] do
        item_id = get_random_item()
    end
    return item_id
end)
echo_item:register_component(ComponentTemplates.create_modifier_double_component("echo_item_duration_multiplier",
    "duration_multiplier"))

local echo_item_blacklist = Component.new("echo_item_blacklist")
local selectable_list = {}
local selected_list = {76}
local index = 0
local function init()
    for i = 0, Class.Item:size() - 1 do
        selectable_list[#selectable_list + 1] = Item.wrap(i).identifier
    end
end
Initialize.add_hotloadable(init)
if hot_reload then
    init()
end
local function update_blacklist()
    item_blacklist = {}
    for _, v in ipairs(selected_list) do
        item_blacklist[v] = true
    end
end
echo_item_blacklist.prepare = function(self)
    self.active_params = self.parent.active_params
    self.active_modifier = self.parent.active_modifier
end
echo_item_blacklist.on_update = function(self)
    selected_list = {76}
    for namespace, v in pairs(self.active_params) do
        for identifier, t in pairs(v) do
            if t.disable then
                local item = Item.find(namespace, identifier)
                table.insert(selected_list, item.value)
            end
        end
    end
end
echo_item_blacklist.on_draw = function(self)
    local need_to_delete = {}
    for k, v in ipairs(selected_list) do
        ImGui.TextWrapped(Item.wrap(v).identifier)
        if v ~= 76 then
            ImGui.SameLine()
            ImGui.PushID(k)
            if not ImGui.Checkbox("", true) then
                table.insert(need_to_delete, k)
            end
            ImGui.PopID(k)
        end
    end
    if #need_to_delete ~= 0 then
        for _, v in ipairs(need_to_delete) do
            local item = Item.wrap(selected_list[v])
            self.active_params[item.namespace][item.identifier].disable = nil
            table.remove(selected_list, v)
        end
        update_blacklist()
        self.save_change()
    end
    index = ImGui.Combo("", index, selectable_list, #selectable_list, 5)
    ImGui.SameLine()
    if ImGui.Button("Add") then
        if not Util.table_has(selected_list, index) then
            local item = Item.wrap(index)
            ComponentUtils.get_or_create_table(ComponentUtils.get_or_create_table(self.active_params, item.namespace), item.identifier).disable = true
            table.insert(selected_list, index)
            update_blacklist()
            self.save_change()
        end
    end
end
echo_item_blacklist.on_restore = function(self)
    selected_list = {76}
end
echo_item_blacklist.on_cleanup = function(self)
    update_blacklist()
end
echo_item:register_component(echo_item_blacklist)
