ComponentTemplates = {}
function ComponentTemplates.create_number_component(name, key, default_value, tooltip, display_text, on_change,
    is_same_line, item_width, fn_name, fn_params)
    display_text = display_text or key
    if is_same_line == nil then
        is_same_line = true
    end
    if item_width == nil then
        item_width = 80
    end
    if fn_params == nil then
        fn_params = {0, 0}
    end
    local component = Component.new(name)
    local number = default_value
    component.prepare = function(self)
        self.active_params = self.parent.active_params
    end
    component.on_update = function(self)
        local number_ = self.active_params[key]
        if number_ ~= nil then
            number = number_
        end
    end
    component.on_draw = function(self)
        local need_update
        if is_same_line then
            ImGui.SameLine()
        end
        if item_width then
            ImGui.SetNextItemWidth(item_width)
        end
        number, need_update = ImGui[fn_name](display_text, number, table.unpack(fn_params))
        if need_update then
            if number ~= default_value then
                self.active_params[key] = number
            else
                self.active_params[key] = nil
            end
            if on_change then
                on_change()
            end
            ComponentUtils.save_change()
        end
        if tooltip and ImGui.IsItemHovered() then
            ImGui.SetTooltip(tooltip)
        end
    end
    component.on_restore = function(self)
        number = default_value
    end
    return component
end
function ComponentTemplates.create_bool_component(name, key, default_value, tooltip, display_text, on_change,
    is_same_line, item_width)
    return ComponentTemplates.create_number_component(name, key, default_value, tooltip, display_text, on_change,
        is_same_line, item_width, "Checkbox", {})
end
function ComponentTemplates.create_int_component(name, key, default_value, tooltip, display_text, on_change,
    is_same_line, item_width, fn_params)
    return ComponentTemplates.create_number_component(name, key, default_value, tooltip, display_text, on_change,
        is_same_line, item_width, "InputInt", fn_params)
end
function ComponentTemplates.create_double_component(name, key, default_value, tooltip, display_text, on_change,
    is_same_line, item_width, fn_params)
    return ComponentTemplates.create_number_component(name, key, default_value, tooltip, display_text, on_change,
        is_same_line, item_width, "InputDouble", fn_params)
end

function ComponentTemplates.create_builtin_number_component(name, key, target_name, tooltip, display_text, on_change,
    is_same_line, item_width, fn_name, fn_params)
    display_text = display_text or key
    if is_same_line == nil then
        is_same_line = true
    end
    if item_width == nil then
        item_width = 80
    end
    if fn_params == nil then
        fn_params = {0, 0}
    end
    local origin_key = "origin_" .. key
    local component = Component.new(name)
    local number
    component.prepare = function(self)
        self.active_params = self.parent.active_params
        self[target_name] = self.parent[target_name]
    end
    component.on_update = function(self)
        number = self.active_params[key] or number
        self[target_name][key] = number
    end
    component.on_draw = function(self)
        local need_update
        if is_same_line then
            ImGui.SameLine()
        end
        if item_width then
            ImGui.SetNextItemWidth(item_width)
        end
        number, need_update = ImGui[fn_name](display_text, number, table.unpack(fn_params))
        if need_update then
            if self.active_params[origin_key] == nil then
                self.active_params[origin_key] = self[target_name][key]
            end
            if number == self.active_params[origin_key] then
                self.active_params[origin_key] = nil
                self.active_params[key] = nil
            else
                self.active_params[key] = number
            end
            self[target_name][key] = number
            if on_change then
                on_change(self)
            end
            ComponentUtils.save_change()
        end
        if tooltip and ImGui.IsItemHovered() then
            ImGui.SetTooltip(tooltip)
        end
    end
    component.on_restore = function(self)
        if self.active_params[origin_key] then
            self[target_name][key] = self.active_params[origin_key]
        end
        number = self[target_name][key]
    end
    return component
end
function ComponentTemplates.create_builtin_int_component(name, key, target_name, tooltip, display_text, on_change,
    is_same_line, item_width, fn_params)
    return ComponentTemplates.create_builtin_number_component(name, key, target_name, tooltip, display_text, on_change,
        is_same_line, item_width, "InputInt", fn_params)
end
function ComponentTemplates.create_builtin_double_component(name, key, target_name, tooltip, display_text, on_change,
    is_same_line, item_width, fn_params)
    return ComponentTemplates.create_builtin_number_component(name, key, target_name, tooltip, display_text, on_change,
        is_same_line, item_width, "InputDouble", fn_params)
end
function ComponentTemplates.create_builtin_bool_component(name, key, target_name, tooltip, display_text, on_change,
    is_same_line, item_width)
    return ComponentTemplates.create_builtin_number_component(name, key, target_name, tooltip, display_text, on_change,
        is_same_line, item_width, "Checkbox", {})
end

function ComponentTemplates.create_modifier_int_component(name, key, tooltip, display_text, on_change, is_same_line,
    item_width, fn_params)
    return ComponentTemplates.create_builtin_int_component(name, key, "active_modifier", tooltip, display_text, on_change,
        is_same_line, item_width, fn_params)
end
function ComponentTemplates.create_modifier_double_component(name, key, tooltip, display_text, on_change, is_same_line,
    item_width, fn_params)
    return ComponentTemplates.create_builtin_double_component(name, key, "active_modifier", tooltip, display_text, on_change,
        is_same_line, item_width, fn_params)
end
function ComponentTemplates.create_modifier_bool_component(name, key, tooltip, display_text, on_change, is_same_line,
    item_width)
    return ComponentTemplates.create_builtin_bool_component(name, key, "active_modifier", tooltip, display_text, on_change,
        is_same_line, item_width)
end
