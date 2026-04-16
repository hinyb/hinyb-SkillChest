local skill_component = Component.new("skill")
local current_skill_index = 0
skill_component.prepare = function(self)
    local skill = Skill.wrap(SkillDisplayMap[current_skill_index])
    self.active_params = ComponentUtils.get_or_create_table(ComponentUtils.get_or_create_table(
        ComponentUtils.get_or_create_table(self.parent.active_params, self.name), skill.namespace), skill.identifier)
    self.active_skill = skill
end
skill_component.on_draw = function(self)
    local need_update
    ImGui.TextColored(1, 0.5, 1, 1, "-- Skill Settings --")
    current_skill_index, need_update = ImGui.Combo("", current_skill_index, SkillDisplayNames, #SkillDisplayNames, 5)
    if need_update then
        self:restore(true)
        self:update()
    end
    if ImGui.IsItemHovered() then
        local skill_name = SkillDisplayNames[SkillDisplayMap[current_skill_index]]
        local tooltip = gm.translate("skill." .. skill_name .. ".name") .. ": " ..
                            gm.translate("skill." .. skill_name .. ".description")
        ImGui.SetTooltip(ComponentUtils.tooltip_cleanup(tooltip))
    end
end
skill_component.on_restore = function(self)
    local cache_index = current_skill_index
    for i = 1, #SkillDisplayNames do
        current_skill_index = i - 1
        skill_component:restore(true)
    end
    current_skill_index = cache_index
    skill_component:restore(true)
    return false
end
skill_component.on_cleanup = function(self)
    ComponentUtils.table_set_empty(self.active_params)
    self.save_change()
end
skill_component:add_child(ComponentTemplates.create_bool_component("skill_is_blacklist", "is_blacklist", false))
function _CheckSKill(skill_id)
    local skill = Skill.wrap(skill_id)
    local params = ComponentUtils.get_or_create_table(ComponentUtils.get_or_create_table(ComponentUtils.get_or_create_table(skill_component.parent.active_params, skill_component.name), skill.namespace), skill.identifier)
    return not params.is_blacklist
end
return skill_component
