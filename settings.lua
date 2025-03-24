local config_index = 0
local text = ""
local configs_name_order = {}
local function create_new_config(self)
    self.active_params = self.active_params or {}
    self:restore()
    self.active_params = {}
    config_index = #configs_name_order
    text = "Config_" .. tostring(config_index)
    while params[text] do
        text = text .. "_0"
    end
    configs_name_order[config_index + 1] = text
    params[configs_name_order[config_index + 1]] = self.active_params
    self:update()
    ComponentUtils.save_change()
end
local settings_component = Component.new("settings")
local function init()
    for k, v in pairs(mods) do
        if type(v) == "table" and v.tomlfuncs then
            Toml = v
        end
    end
    params = {}
    settings_component.active_params = {}
    settings_component:restore()
    params = Toml.load_cfg(_ENV["!guid"], params)
    for k,v in pairs(params) do
        table.insert(configs_name_order, k)
    end
    if #configs_name_order == 0 then
        create_new_config(settings_component)
    end
    settings_component.active_params = params[configs_name_order[config_index + 1]]
    settings_component:update()
end
Initialize(init, true)
if hot_reload then
    Alarm.create(init, 1)
end
settings_component.on_update = function(self)
    if not self.active_params then
        create_new_config(self)
    end
    self:restore()
    self.active_params = params[configs_name_order[config_index + 1]]
end
settings_component.on_draw = function(self)
    local need_update
    config_index, need_update = ImGui.Combo("", config_index, configs_name_order, #configs_name_order, 5)
    if need_update then
        self:update()
    end
    ImGui.SameLine()
    if ImGui.Button(" + ") then
        create_new_config(self)
    end
    ImGui.SameLine()
    if ImGui.Button(" - ") then
        self:restore()
        self:cleanup()
        params[configs_name_order[config_index + 1]] = nil
        table.remove(configs_name_order, config_index + 1)
        config_index = config_index - 1
        if config_index < 0 then
            config_index = #configs_name_order
        end
        if #configs_name_order == 0 then
            create_new_config(settings_component)
        end
        settings_component.active_params = params[configs_name_order[config_index + 1]]
        self:update()
        ComponentUtils.save_change()
    end
    ImGui.SameLine()
    text = ImGui.InputText("Label", text, 100)
    ImGui.SameLine()
    if ImGui.Button("Rename") then
        params[configs_name_order[config_index + 1]] = nil
        while params[text] do
            text = text .. "_0"
        end
        configs_name_order[config_index + 1] = text
        params[configs_name_order[config_index + 1]] = self.active_params
        ComponentUtils.save_change()
    end
end
local names = path.get_files(_ENV["!plugins_mod_folder_path"] .. "/configs")
for _, name in ipairs(names) do
    settings_component:add_child(require(name))
end


gui.add_to_menu_bar(function()
    settings_component:draw()
end)
