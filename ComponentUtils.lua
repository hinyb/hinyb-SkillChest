ComponentUtils = {}
local function get_change_table(t)
    local change_table = {}
    for k, v in pairs(t) do
        if type(v) == "table" then
            local t2 = get_change_table(v)
            if next(t2) then
                change_table[k] = t2
            end
        else
            change_table[k] = v
        end
    end
    return change_table
end
function ComponentUtils.create_lazy_fn(fn, time)
    local alarm
    return function(...)
        Alarm.destroy(alarm)
        alarm = Alarm.create(fn, time, ...)
    end
end
ComponentUtils.save_change = function ()
    
end
local function init()
    ComponentUtils.save_change = ComponentUtils.create_lazy_fn(function ()
        Toml.save_cfg(_ENV["!guid"], get_change_table(params))
    end, 1)
end
Initialize(init)
if hot_reload then
    init()
end
function ComponentUtils.get_or_create_table(parent_table, key)
    local child_table = parent_table[key]
    if not child_table then
        child_table = {}
        parent_table[key] = child_table
    end
    return child_table
end
function ComponentUtils.list_set_new_value(list, value, amount)
    local num = 0
    while true do
        local index = list:find(value)
        if not index then
            break
        end
        list:delete(index)
        num = num + 1
    end
    for _ = 1, amount do
        list:add(value)
    end
    return num
end
function ComponentUtils.table_set_empty(t)
    for k, _ in pairs(t) do
        t[k] = nil
    end
end
