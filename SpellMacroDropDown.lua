-- Namespace for spell macros
local SpellMacroManager = {}

-- Constants for spell macro types
SpellMacroManager.MACRO_TYPES = {
    NORMAL_CAST = "normalCast",
    MOUSEOVER_BASIC = "mouseoverBasic",
    MOUSEOVER_HARM = "mouseoverHarm",
    MOUSEOVER_HELP = "mouseoverHelp",
    MOUSEOVER_HARM_OR_HELP = "mouseoverHarmOrHelp",
    MOUSEOVER_HARM_OR_HELP_OR_TARGET = "mouseoverHarmOrHelpOrTarget",
    MOUSEOVER_CAST = "mouseoverCast",
    CURSOR_CAST = "cursorCast",
    CAST_PLAYER = "castPlayer",
    RANDOM_FRIENDLY = "randomFriendly",
    RANDOM_ENEMY = "randomEnemy",
    CAST_FOCUS = "castFocus"
}

-- Templates for macro text
SpellMacroManager.macroTemplates = {
    [SpellMacroManager.MACRO_TYPES.NORMAL_CAST] = "#showtooltip\n/cast %s",
    [SpellMacroManager.MACRO_TYPES.MOUSEOVER_BASIC] = "#showtooltip\n/cast [@mouseover,exists,nodead] [] %s",
    [SpellMacroManager.MACRO_TYPES.MOUSEOVER_HARM] = "#showtooltip\n/cast [@mouseover,harm,nodead] [] %s",
    [SpellMacroManager.MACRO_TYPES.MOUSEOVER_HELP] = "#showtooltip\n/cast [@mouseover,help,nodead] [] %s",
    [SpellMacroManager.MACRO_TYPES.MOUSEOVER_HARM_OR_HELP] = "#showtooltip\n/cast [@mouseover,harm,nodead][@mouseover,help,nodead] [] %s",
    [SpellMacroManager.MACRO_TYPES.MOUSEOVER_HARM_OR_HELP_OR_TARGET] = "#showtooltip\n/cast [@mouseover,harm,nodead][@mouseover,help,nodead][@targettarget,harm,nodead] [] %s",
    [SpellMacroManager.MACRO_TYPES.MOUSEOVER_CAST] = "#showtooltip\n/cast [@mouseover] %s",
    [SpellMacroManager.MACRO_TYPES.CURSOR_CAST] = "#showtooltip\n/cast [@cursor] %s",
    [SpellMacroManager.MACRO_TYPES.CAST_PLAYER] = "#showtooltip\n/stopspelltarget\n/cast [@player] %s",
    [SpellMacroManager.MACRO_TYPES.RANDOM_FRIENDLY] = "#showtooltip\n/targetfriendplayer\n/cast %s\n/cleartarget",
    [SpellMacroManager.MACRO_TYPES.RANDOM_ENEMY] = "#showtooltip\n/targetenemyplayer\n/cast %s\n/cleartarget",
    [SpellMacroManager.MACRO_TYPES.CAST_FOCUS] = "#showtooltip\n/cast [@focus,exists,nodead][@mouseover,exists,nodead][] %s"
}

--- Creates menu items for the custom spell menu.
-- @param spellId The ID of the spell for which to create menu items.
-- @return A table of menu items.
function SpellMacroManager.generateMenuItems(spellId)
    local menuItems = {}

    for macroType, macroTemplate in pairs(SpellMacroManager.macroTemplates) do
        local actionText = macroType:gsub("_", " "):gsub("^%l", string.upper) -- Convert macro type to readable text
        table.insert(menuItems, {
            text = actionText,
            func = function()
                SpellMacroManager.generateSpellMacro(spellId, macroType)
            end
        })
    end

    return menuItems
end

--- Creates a macro for a given spell ID and macro type.
-- @param spellId The ID of the spell.
-- @param macroType The type of macro to create. See MACRO_TYPES for options.
function SpellMacroManager.generateSpellMacro(spellId, macroType)
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    if not spellInfo then
        print("Invalid spell ID: " .. spellId)
        return
    end

    local spellName = spellInfo.name
    local icon = spellInfo.iconID
    local macroText = string.format(SpellMacroManager.macroTemplates[macroType] or
                                  SpellMacroManager.macroTemplates[SpellMacroManager.MACRO_TYPES.NORMAL_CAST],
                                  spellName)

    -- Try to find an available macro name
    local baseMacroName = spellName
    local macroName = baseMacroName
    local counter = 1

    while GetMacroInfo(macroName) do
        macroName = baseMacroName .. counter
        counter = counter + 1
    end

    CreateMacro(macroName, icon, macroText, true)
    PickupMacro(macroName)
end

local isInitialized = false

local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:SetScript("OnEvent", function(_, event, addonName)
    if addonName == "Blizzard_PlayerSpells" then
        PlayerSpellsFrame:HookScript("OnShow", function()
            if isInitialized then return end
            isInitialized = true

            -- Create a button to open the Macro UI
            local macroButton = CreateFrame("Button", nil, PlayerSpellsFrame.SpellBookFrame, "UIPanelButtonTemplate")
            macroButton:SetSize(100, 22)
            macroButton:SetText("Macros")
            macroButton:SetPoint("TOPRIGHT", PlayerSpellsFrame.SpellBookFrame, "TOPRIGHT", -30, -40)
            macroButton:SetScript("OnClick", function()
                MacroFrame_LoadUI()
                ShowUIPanel(MacroFrame)
            end)
            macroButton:Show()

            local pool = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame.framePoolCollection
            for elementFrame in pool:EnumerateActiveByTemplate("SpellBookItemTemplate", "SPELL") do
                elementFrame.Button:HookScript("OnMouseUp", function(self, button)
                    if button == "RightButton" then
                        -- Prevent the default action of picking up the spell
                        self:SetAttribute("type", nil)

                        local menuItems = SpellMacroManager.generateMenuItems(elementFrame.spellBookItemInfo.spellID)
                        MenuUtil.CreateContextMenu(self, function(ownerRegion, rootDescription)
                            rootDescription:CreateTitle("Create Macro")
                            for _, menuItem in ipairs(menuItems) do
                                rootDescription:CreateButton(menuItem.text, function()
                                    menuItem.func()
                                end)
                            end
                        end)
                    end
                end)
            end
        end)
    end
end)
