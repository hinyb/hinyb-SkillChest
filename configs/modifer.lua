local modifier_enable_component = ComponentTemplates.create_builtin_bool_component("modifier_enable_component",
    "enable", "active_modifier", "Enable/Disable the modifier", "")
local modifier_weight_component = ComponentTemplates.create_modifier_int_component("modifier_weight_component",
    "weight", "The modifier's probability of selection.", nil, function()
        SkillModifierManager.update_weight()
    end)
local modifier_component = Component.new("skill_modifiers")
local modifiers_name_order = SkillModifierManager.modifiers_name_order
local current_modifier_index = 0
modifier_component.prepare = function(self)
    local modifier_name = modifiers_name_order[current_modifier_index + 1]
    self.active_params = ComponentUtils.get_or_create_table(ComponentUtils.get_or_create_table(
        self.parent.active_params, self.name), modifier_name)
    self.active_modifier = SkillModifierManager.get_modifier(modifier_name)
    self.childs = {}
    self.draw_order = {{
        component = self,
        priority = 0
    }}
    modifier_component:add_child(modifier_enable_component)
    modifier_component:add_child(modifier_weight_component)
    local modifier_childs = self.active_modifier.component_childs
    for i = 1, #modifier_childs do
        modifier_component:add_child(modifier_childs[i])
    end
end
modifier_component.on_draw = function(self)
    ImGui.TextColored(1, 0.5, 1, 1, "-- Modifier Settings --")
    local need_update
    current_modifier_index, need_update = ImGui.Combo("", current_modifier_index, modifiers_name_order,
        #modifiers_name_order, 5)
    if need_update then
        self:restore(true)
        self:update()
    end
    if ImGui.IsItemHovered() then
        local modifier_name = modifiers_name_order[current_modifier_index + 1]
        local tooltip = Language.translate_token("skill_modifier." .. modifier_name .. ".name") .. ": " ..
                            Language.translate_token("skill_modifier." .. modifier_name .. ".description")
        ImGui.SetTooltip(ComponentUtils.tooltip_cleanup(tooltip) .. "\nIt is designed to be applied to a skill, so the tooltip may have some issues.")
    end
    ImGui.SameLine()
    if ImGui.Button("Reset") then
        self:restore()
        self:cleanup()
        self:restore()
        self:update()
    end
    ImGui.NewLine()
end
modifier_component.on_restore = function(self)
    local cache_index = current_modifier_index
    for i = 1, #modifiers_name_order do
        current_modifier_index = i - 1
        modifier_component:restore(true)
    end
    current_modifier_index = cache_index
    modifier_component:restore(true)
    return false
end
modifier_component.on_cleanup = function(self)
    ComponentUtils.table_set_empty(self.active_params)
    ComponentUtils.save_change()
end
return modifier_component
