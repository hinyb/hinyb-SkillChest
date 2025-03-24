-- the system is still terrible
-- when I finished improving it, I will release it
Component = {}
Component.__index = Component

function Component.new(name)
    local self = setmetatable({}, Component)
    self.name = name
    self.childs = {}
    self.draw_order = {{
        component = self,
        priority = 0
    }}
    return self
end
local compare_func = function(a, b)
    return a.priority < b.priority
end
function Component:add_child(component, priority)
    table.insert(self.childs, component)
    component.parent = self

    table.insert(self.draw_order, {
        component = component,
        priority = priority or #self.draw_order
    })
    table.sort(self.draw_order, compare_func)
end

local function traverse_childs(childs, method_name)
    for _, member in ipairs(childs) do
        local method = member[method_name]
        if method then
            method(member)
        end
    end
end
function Component:draw()
    local draw_order = {}
    for i = 1, #self.draw_order do
        draw_order[i] = self.draw_order[i]
    end
    for i = 1, #draw_order do
        local component = draw_order[i].component
        ImGui.PushID(component.name)
        if component == self then
            local on_draw = component.on_draw
            if on_draw then
                on_draw(self)
            end
        else
            component:draw()
        end
        ImGui.PopID()
    end
end
-- update draw from params
-- apply change to cards
function Component:update(skip_self)
    local prepare = self.prepare
    if prepare then
        prepare(self)
    end
    if not skip_self then
        local on_update = self.on_update
        if on_update and on_update(self) == false then
            return
        end
    end
    traverse_childs(self.childs, "update")
end
-- restore change to card
function Component:restore(skip_self)
    local prepare = self.prepare
    if prepare then
        prepare(self)
    end
    if not skip_self then
        local on_restore = self.on_restore
        if on_restore and on_restore(self) == false then
            return
        end
    end
    traverse_childs(self.childs, "restore")
end
-- cleanup params
function Component:cleanup(skip_self)
    if not skip_self then
        local on_cleanup = self.on_cleanup
        if on_cleanup and on_cleanup(self) == false then
            return
        end
    end
    traverse_childs(self.childs, "cleanup")
end

require("ComponentUtils")
require("ComponentTemplates")