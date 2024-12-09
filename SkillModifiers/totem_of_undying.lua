--[[
local totem_of_undying = SkillModifierManager.register_modifier("totem_of_undying", 50)
totem_of_undying:set_add_func(function (data)
    local actor = Instance.wrap(data.skill.parent)
    actor:add_callback()
end)
--]]