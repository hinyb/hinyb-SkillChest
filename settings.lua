ComponentTemplates.create_modifier_int_component = function(name, key, tooltip, display_text, on_change, is_same_line,
                                                            item_width, fn_params)
    return ComponentTemplates.create_builtin_int_component(name, key, "active_modifier", tooltip, display_text, on_change,
        is_same_line, item_width, fn_params)
end
ComponentTemplates.create_modifier_double_component = function(name, key, tooltip, display_text, on_change, is_same_line,
                                                               item_width, fn_params)
    return ComponentTemplates.create_builtin_double_component(name, key, "active_modifier", tooltip, display_text,
        on_change,
        is_same_line, item_width, fn_params)
end

ComponentTemplates.create_modifier_bool_component = function(name, key, tooltip, display_text, on_change, is_same_line,
                                                             item_width)
    return ComponentTemplates.create_builtin_bool_component(name, key, "active_modifier", tooltip, display_text,
        on_change,
        is_same_line, item_width)
end

local settings = ComponentTemplates.create_default_setting_component()
return settings