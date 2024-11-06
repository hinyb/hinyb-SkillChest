mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto()
mods["hinyb-Dropability"].auto()

local function add_to_all_stages(self)
    local card_array, id = self:get_card()
    for i = 1, #Class.STAGE do
        local list = List.wrap(Class.STAGE[i]:get(6))
        list:add(id)
    end
end
local function init()
    local spawn_weight = {8, 3}
    local spawn_cost = {40, 60}
    local init_cost = {function(self)
        self.value:interactable_init_cost(self.value, 0, 124)
    end, function(self)
        self.value:interactable_init_cost(self.value, 2, 0.83)
    end}
    local skill_modifier = {function(skill)
        return skill
    end, function(skill)
        skill.slot_index = Utils.get_random(0, 3)
        return skill
    end}
    local sprite_color = {gm.make_color_rgb(240, 240, 120), gm.make_color_rgb(240, 120, 120)}
    for type = 1, 2 do
        obj = Interactable.new("hinyb", "oSkillChest" .. type)
        obj.obj_sprite = gm.constants.sChest4
        obj.spawn_with_sacrifice = true
        obj.obj_depth = 4.0
        add_to_all_stages(obj)

        obj.spawn_cost = spawn_cost[type]
        obj.spawn_weight = spawn_weight[type]
        obj.default_spawn_rarity_override = 2
        obj:onCreate(function(self)
            self.image_blend = sprite_color[type]
            self.skill_sprite = 1628.0
            self.image_index = 0.0
            self.image_speed = 0.2
            self.interval = 60.0
            self.executions = 0.0
            self.sprite_offset_x = 2
            self.sprite_offset_y = 0
            self.text = gm.ds_map_find_value(Utils.get_lang_map(), "interactable.oChest4" .. ".text")
            init_cost[type](self)
        end)

        obj:onActivate(function(self, actor)
            if not self.isopen then
                self.isopen = true -- but actually is 1.0
                self.text = gm.ds_map_find_value(Utils.get_lang_map(), "interactable.oChest4" .. ".pick")
                self.prompt_text = gm.ds_map_find_value(Utils.get_lang_map(), "interactable.oChest4" .. ".active")
                if Utils.get_net_type() ~= Net.TYPE.client then
                    self.random_seed = self.frame - self.interval
                    if Utils.get_net_type() == Net.TYPE.host then
                        Utils.sync_instance_send(self.value, {
                            random_seed = self.random_seed
                        }, 1)
                    end
                end
            elseif self.random_seed then
                self:set_state(1)
            end
            self.cost = 0.0
        end)

        obj:onStateDraw(function(self)
            if self.image_index > 8.0 then
                self.image_index = 0
            end
            if self.isopen and self.random_seed then
                if self.start_frame == nil then
                    self.start_frame = self.random_seed
                end
                self.value:draw_text_w(self.x, self.y + 30, self.prompt_text)
                if self.frame - self.start_frame >= self.interval then
                    self.start_frame = self.start_frame + self.interval
                    self.interval = self.interval - 4
                    self.executions = self.executions + 1
                    local data = self:get_data()
                    if data.get_skill == nil then
                        self.sprite_offset_x = -12
                        self.sprite_offset_y = -8
                        data.get_skill = Utils.random_skill_id(self.random_seed)
                    end
                    self.skill_id = data.get_skill()
                    local skill = Utils.warp_skill(self.skill_id)
                    self.skill_sprite = skill.sprite_index
                    self.skill_subimg = skill.image_index
                    if self.executions >= 15 then
                        self:set_state(1)
                    end
                    self.value:sound_play_at(gm.constants.wClick, 1.0, 0.5, self.x, self.y, nil)
                end
            end
        end, 0)
        obj:onStateStep(function(self)
            if Utils.get_net_type() ~= Net.TYPE.client then
                local skill = Utils.warp_skill(self.skill_id)
                skill_create(self.x + 8, self.y - 10, skill_modifier[type](skill))
            end
            self.value:sound_play_at(gm.constants.wChest2, 1.0, 1.0, self.x, self.y, nil)
            self.value:part_particles_create_color(gm.variable_global_get("below"), self.x, self.y,
                gm.variable_global_get("pHeal"), 65536, 30)
            self.sprite_index = gm.constants.sChest4Open
            self.image_index = 0
            self.image_speed = 0.2
            self:set_state(2)
        end, 1)

        obj:onStateStep(function(self)
            self:set_state(0)
        end, -1) -- I don't know why it triggers after activate on client
        obj:onDraw(function(self)
            self.frame = gm.variable_global_get("_current_frame")
            if self:get_state() ~= 2 then
                gm.draw_sprite_ext(self.skill_sprite, self.skill_subimg or 0.0, self.x + self.sprite_offset_x,
                    self.y + gm.dsin(self.frame * 1.333) * 3 - 34 + self.sprite_offset_y, 1.0, 1.0, 0.0, Color.WHITE,
                    0.64)
            end
        end)
    end
end
Initialize(init)
