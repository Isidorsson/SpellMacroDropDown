-- MacroTemplate Class
local MacroTemplate = {}
MacroTemplate.__index = MacroTemplate

function MacroTemplate.new()
    local self = setmetatable({}, MacroTemplate)
    self.types = {
        NORMAL_CAST = "Cast Normal",
        MOUSEOVER_BASIC = "Cast @Mouseover",
        MOUSEOVER_HARM = "Cast @Mouseover Harm",
        MOUSEOVER_HELP = "Cast @Mouseover Help",
        MOUSEOVER_HARM_OR_HELP = "Cast @Mouseover Harm/Help",
        MOUSEOVER_HARM_OR_HELP_OR_TARGET = "Cast @Mouseover Harm/Help/Target",
        MOUSEOVER_CAST = "Cast @Mouseover Any",
        CURSOR_CAST = "Cast @Cursor",
        CAST_PLAYER = "Cast @Self",
        RANDOM_FRIENDLY = "Cast Random Friend",
        RANDOM_ENEMY = "Cast Random Enemy",
        CAST_FOCUS = "Cast @Focus"
    }

    self.templates = {
        [self.types.NORMAL_CAST] = "#showtooltip\n/cast %s",
        [self.types.MOUSEOVER_BASIC] = "#showtooltip\n/cast [@mouseover,exists,nodead] [] %s",
        [self.types.MOUSEOVER_HARM] = "#showtooltip\n/cast [@mouseover,harm,nodead] [] %s",
        [self.types.MOUSEOVER_HELP] = "#showtooltip\n/cast [@mouseover,help,nodead] [] %s",
        [self.types.MOUSEOVER_HARM_OR_HELP] = "#showtooltip\n/cast [@mouseover,harm,nodead][@mouseover,help,nodead] [] %s",
        [self.types.MOUSEOVER_HARM_OR_HELP_OR_TARGET] = "#showtooltip\n/cast [@mouseover,harm,nodead][@mouseover,help,nodead][@targettarget,harm,nodead] [] %s",
        [self.types.MOUSEOVER_CAST] = "#showtooltip\n/cast [@mouseover] %s",
        [self.types.CURSOR_CAST] = "#showtooltip\n/cast [@cursor] %s",
        [self.types.CAST_PLAYER] = "#showtooltip\n/stopspelltarget\n/cast [@player] %s",
        [self.types.RANDOM_FRIENDLY] = "#showtooltip\n/targetfriendplayer\n/cast %s\n/cleartarget",
        [self.types.RANDOM_ENEMY] = "#showtooltip\n/targetenemyplayer\n/cast %s\n/cleartarget",
        [self.types.CAST_FOCUS] = "#showtooltip\n/cast [@focus,exists,nodead][@mouseover,exists,nodead][] %s"
    }
    return self
end

function MacroTemplate:getTemplate(macroType)
    return self.templates[macroType] or self.templates[self.types.NORMAL_CAST]
end

-- SpellMacroManager Class
local SpellMacroManager = {}
SpellMacroManager.__index = SpellMacroManager

function SpellMacroManager.new()
    local self = setmetatable({}, SpellMacroManager)
    self.macroTemplate = MacroTemplate.new()
    return self
end

function SpellMacroManager:generateMenuItems(spellId)
    local menuItems = {}
    for macroType, _ in pairs(self.macroTemplate.templates) do
        local actionText = macroType:gsub("_", " "):gsub("^%l", string.upper)
        table.insert(menuItems, {
            text = actionText,
            func = function()
                self:generateSpellMacro(spellId, macroType)
            end
        })
    end
    return menuItems
end

function SpellMacroManager:generateSpellMacro(spellId, macroType)
    local spellInfo = C_Spell.GetSpellInfo(spellId)
    if not spellInfo then
        print("Invalid spell ID: " .. spellId)
        return
    end

    local spellName = spellInfo.name
    local icon = spellInfo.iconID
    local macroText = string.format(self.macroTemplate:getTemplate(macroType), spellName)

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

-- SpellMacroUI Class
local SpellMacroUI = {}
SpellMacroUI.__index = SpellMacroUI

function SpellMacroUI.new()
    local self = setmetatable({}, SpellMacroUI)
    self.isInitialized = false
    self.spellMacroManager = SpellMacroManager.new()
    return self
end

function SpellMacroUI:initialize()
    if self.isInitialized then return end
    self.isInitialized = true

    local macroButton = CreateFrame("Button", nil, PlayerSpellsFrame.SpellBookFrame, "UIPanelButtonTemplate")
    macroButton:SetSize(100, 22)
    macroButton:SetText("Macros")
    macroButton:SetPoint("TOPRIGHT", PlayerSpellsFrame.SpellBookFrame, "TOPRIGHT", -30, -40)
    macroButton:SetScript("OnClick", function()
        MacroFrame_LoadUI()
        ShowUIPanel(MacroFrame)
    end)
    macroButton:Show()

    self:hookSpellButtons()
end

function SpellMacroUI:hookSpellButtons()
    local pool = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame.framePoolCollection
    local self_ref = self -- Store reference to SpellMacroUI instance

    for elementFrame in pool:EnumerateActiveByTemplate("SpellBookItemTemplate", "SPELL") do
        elementFrame.Button:HookScript("OnMouseUp", function(button_self, button)
            if button == "RightButton" and not IsAltKeyDown() or (button == "RightButton" and IsAltKeyDown()) then
                button_self:SetAttribute("type", nil)
                -- Use self_ref instead of SpellMacroUI
                local menuItems = self_ref.spellMacroManager:generateMenuItems(elementFrame.spellBookItemInfo.spellID)
                MenuUtil.CreateContextMenu(button_self, function(ownerRegion, rootDescription)
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
end

-- Initialize the addon
local ui = SpellMacroUI.new()
local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:SetScript("OnEvent", function(_, event, addonName)
    if addonName == "Blizzard_PlayerSpells" then
        PlayerSpellsFrame:HookScript("OnShow", function()
            ui:initialize()
        end)
    end
end)
