mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)
mods["hinyb-Dropability"].auto()

require("Utils.lua")

local names = path.get_files(_ENV["!plugins_mod_folder_path"] .. "/SkillModifiers")
for _, name in ipairs(names) do
    require(name)
end
local function init()
    local spawn_weight = {8, 6}
    local spawn_cost = {24, 24} -- It seems they are not worth the high price for most skills, so I lowered their prices.
    local init_cost = {function(self)
        self.value:interactable_init_cost(self.value, 0, 46)
    end, function(self)
        self.value:interactable_init_cost(self.value, 2, 0.24)
    end}
    local skill_modifier = {function(skill)
        local num = 0
        while true do
            if num == 1 then
                if Utils.get_random() > 0.6 then
                    break
                end
            end
            if num == 2 then
                if Utils.get_random() > 0.4 then
                    break
                end
            end
            if num > 2 then
                if Utils.get_random() > 0.3 then
                    break
                end
            end
            SkillModifierManager.add_modifier_params(skill,
                SkillModifierManager.get_random_modifier_name_with_check(skill))
            num = num + 1
        end
        return skill
    end, function(skill)
        local num = 0
        while true do
            if num > 1 then
                if Utils.get_random() > 0.1 then
                    break
                end
            end
            SkillModifierManager.add_modifier_params(skill,
                SkillModifierManager.get_random_modifier_name_with_check(skill))
            num = num + 1
        end
        return skill
    end} -- May need more modifiers
    local sprite_color = {gm.make_color_rgb(240, 240, 120), gm.make_color_rgb(240, 120, 120)}
    for chest_type = 1, 2 do
        obj = Object.new("hinyb", "oSkillChest" .. chest_type, Object.PARENT.interactable)
        obj.obj_sprite = gm.constants.sChest4
        obj.obj_depth = 10.0

        -- Create Interactable Card
        local card = Interactable_Card.new("hinyb", "oSkillChest" .. chest_type)
        card.object_id = obj
        card.spawn_with_sacrifice = true
        card.spawn_cost = spawn_cost[chest_type]
        card.spawn_weight = spawn_weight[chest_type]
        card.default_spawn_rarity_override = 2

        -- Add Interactable Card to stages
        local stages = Stage.find_all()
        for _, stage in ipairs(stages) do
            stage:add_interactable(card)
        end
        obj:onCreate(function(self)
            self.image_blend = sprite_color[chest_type]
            self.image_index = 0.0
            self.image_speed = 0.2
            self.text = Language.translate_token("interactable.oChest4" .. ".text")
            local data = self:get_data()
            data.skill_sprite = 1628.0
            data.interval = 60.0
            data.executions = 0.0
            data.sprite_offset_x = 2
            data.sprite_offset_y = 0
            init_cost[chest_type](self)
        end)
        obj:onStep(function(self)
            if not self.has_init then
                self.has_init = true
                if not Net.is_client() then
                    Utils.set_and_sync_inst_from_table(self.value, {
                        random_seed = Utils.get_random_seed()
                    })
                end
            end
            local data = self:get_data()
            data.frame = gm.variable_global_get("_current_frame")
            if self.active == 1 then
                if not data.isopen then
                    data.isopen = true -- but actually is 1.0
                    self.text = Language.translate_token("interactable.oChest4" .. ".pick")
                    self.prompt_text = Language.translate_token("interactable.oChest4" .. ".active")
                    self.cost = 0.0
                    self.active = 0
                elseif self.random_seed then
                    self.active = 3
                else
                    log.error("random_seed hasn't been initialized")
                end
            elseif self.active == 0 then
                if self.image_index > 8.0 then
                    self.image_index = 0
                end
                if data.isopen then
                    if data.start_frame == nil then
                        data.start_frame = data.frame - data.interval
                    end
                    self.value:draw_text_w(self.x, self.y + 30, self.prompt_text)
                    if data.frame - data.start_frame >= data.interval then
                        data.start_frame = data.start_frame + data.interval
                        data.interval = data.interval - 4
                        data.executions = data.executions + 1
                        if data.get_skill == nil then
                            data.sprite_offset_x = -12
                            data.sprite_offset_y = -8
                            data.get_skill = Utils.random_skill_id(self.random_seed)
                        end
                        data.skill_id = data.get_skill()
                        local default_skill = Class.SKILL:get(data.skill_id)
                        data.skill_sprite = default_skill:get(4)
                        data.skill_subimg = default_skill:get(5)
                        self.prompt_text = Language.translate_token(default_skill:get(2)) -- It seems it is hard to distinguish which is which,and some skills don't have a icon.
                        if data.executions >= 15 then
                            self.active = 3
                        end
                        self.value:sound_play_at(gm.constants.wClick, 1.0, 0.5, self.x, self.y, nil)
                    end
                end
            elseif self.active == 3 then
                if self.activator then
                    if self.activator.is_local then
                        local skill = Utils.wrap_skill(data.skill_id)
                        SkillPickup.skill_create(self.x + 8, self.y - 10, skill_modifier[chest_type](skill))
                    end
                    self:sound_play_at(gm.constants.wChest2, 1.0, 1.0, self.x, self.y, nil)
                    local Heal = Particle.find("ror", "Heal")
                    Heal:create_color(self.x, self.y, 65536, 30)
                    self.sprite_index = gm.constants.sChest4Open
                    self.image_index = 0
                    self.image_speed = 0.2
                    self.active = 4
                end
            end
        end)
        obj:onDraw(function(self)
            if self.active == 0 then
                local data = self:get_data()
                gm.draw_sprite_ext(data.skill_sprite, data.skill_subimg or 0.0, self.x + data.sprite_offset_x,
                    self.y + gm.dsin(data.frame * 1.333) * 3 - 34 + data.sprite_offset_y, 1.0, 1.0, 0.0, Color.WHITE,
                    0.64)
            end
        end)
    end
end
Initialize(init)
