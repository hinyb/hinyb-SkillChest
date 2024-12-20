local function get_random_skill_id_with_check(random_fn, actor)
    local random_skill_id = random_fn()
    if not CompatibilityPatch.has_scrap_bar(actor) then
        while Utils.is_skill_need_scrap_bar(random_skill_id) do
            random_skill_id = random_fn()
        end
    end
    return random_skill_id
end
local entropy = SkillModifierManager.register_modifier("entropy", 24)
entropy:set_add_func(function(data, modifier_index, random_seed)
    -- I'm not sure if I need to periodically synchronize the random seed.
    -- So I decided not to add until it has sync issues.
    local get_random_skill_id = Utils.random_skill_id(random_seed)
    local get_random = Utils.LCG_random(random_seed)
    data:add_post_add_stock_callback(function(data)
        local random_skill_id = get_random_skill_id_with_check(get_random_skill_id, data.skill.parent)
        local fake_skill = Utils.wrap_skill(random_skill_id)
        data.skill.sprite = fake_skill.sprite_index
        data.skill.subimage = fake_skill.image_index
        data.skill.name = fake_skill.name
        data.skill.description = fake_skill.description
        data.skill.skill_id = fake_skill.skill_id
        data.skill.cooldown_base = get_random(0, fake_skill.cooldown * 1.5)
        data.skill.damage_base = get_random(fake_skill.cooldown * 0.5, fake_skill.damage * 2)
        gm.get_script_ref(102397)(data.skill, data.skill.parent)
    end)
end)
entropy:set_check_func(function(skill)
    return SkillModifierManager.count_modifier(skill, "entropy") < 1
end)
entropy:set_default_params_func(function()
    return os.time()
end)
