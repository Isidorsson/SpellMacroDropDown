-- SpellMacroDropDown SpellManager
-- Handles spell macro generation and menu creation

local addonName, addonTable = ...
local SpellMacroDropDown = addonTable

-- SpellMacroManager Class
local SpellMacroManager = {}
SpellMacroManager.__index = SpellMacroManager

function SpellMacroManager.new()
    local self = setmetatable({}, SpellMacroManager)
    self.macroTemplate = SpellMacroDropDown.MacroTemplate.new()
    return self
end

function SpellMacroManager:generateMenuItems(spellId)
    local menuItems = {}

    -- Create hierarchical menu structure using ordered iteration
    for _, categoryKey in ipairs(self.macroTemplate.categoryOrder) do
        local categoryData = self.macroTemplate.categories[categoryKey]
        if categoryData then
            local categoryItem = {
                text = categoryData.name,
                hasArrow = true,
                menuList = {}
            }

            -- Add macros for this category in the specified order
            local macroOrderForCategory = self.macroTemplate.macroOrder[categoryKey]
            if macroOrderForCategory then
                for _, macroKey in ipairs(macroOrderForCategory) do
                    local macroName = categoryData.macros[macroKey]
                    if macroName then
                        table.insert(categoryItem.menuList, {
                            text = macroName,
                            func = function()
                                self:generateSpellMacro(spellId, macroKey)
                            end
                        })
                    end
                end
            end

            table.insert(menuItems, categoryItem)
        end
    end

    return menuItems
end

function SpellMacroManager:generateSpellMacro(spellId, macroType)
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    if not spellInfo or not spellInfo.name then
        print("SpellMacroDropDown: Invalid spell ID or spell name not found: " .. tostring(spellId))
        return
    end

    local spellName = spellInfo.name
    local icon = spellInfo.iconID
    local template = self.macroTemplate:getTemplate(macroType)

    -- Handle special cases that need multiple spell names or different formatting
    local macroText
    if macroType == "HARM_HELP_AUTO" then
        macroText = string.format(template, spellName, spellName)
    elseif macroType == "MODIFIER_SHIFT" then
        macroText = string.format(template, spellName, spellName)
    elseif macroType == "COMBAT_CONDITIONAL" then
        macroText = string.format(template, spellName, spellName)
    elseif macroType == "CANCELAURA_CAST" then
        macroText = string.format(template, spellName, spellName)
    else
        macroText = string.format(template, spellName)
    end

    local baseMacroName = spellName
    local macroName = baseMacroName
    local counter = 1

    -- Ensure unique macro name
    while GetMacroInfo(macroName) do
        macroName = baseMacroName .. counter
        counter = counter + 1
    end

    local success = pcall(CreateMacro, macroName, icon, macroText, true)
    if success then
        PickupMacro(macroName)
        print("SpellMacroDropDown: Created macro '" .. macroName .. "'")
    else
        print("SpellMacroDropDown: Failed to create macro '" .. macroName .. "' - you may have reached the macro limit")
    end
end

-- Export SpellMacroManager to addon namespace
SpellMacroDropDown.SpellMacroManager = SpellMacroManager