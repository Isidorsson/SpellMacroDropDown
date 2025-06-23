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

    -- Ensure unique macro name
    while GetMacroInfo(macroName) do
        macroName = baseMacroName .. counter
        counter = counter + 1
    end

    CreateMacro(macroName, icon, macroText, true)
    PickupMacro(macroName)
    print("Created macro: " .. macroName)
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

    -- Create macro button
    local macroButton = CreateFrame("Button", nil, PlayerSpellsFrame.SpellBookFrame, "UIPanelButtonTemplate")
    macroButton:SetSize(100, 22)
    macroButton:SetText("Macros")
    macroButton:SetPoint("TOPRIGHT", PlayerSpellsFrame.SpellBookFrame, "TOPRIGHT", -30, -40)
    macroButton:SetScript("OnClick", function()
        MacroFrame_LoadUI()
        ShowUIPanel(MacroFrame)
    end)
    macroButton:Show()

    -- Hook spell buttons initially and on spellbook updates
    self:hookAllSpellButtons()

    -- Re-hook on spellbook updates
    if PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame and PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame.UpdateSpells then
        hooksecurefunc(PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame, "UpdateSpells", function()
            C_Timer.After(0.1, function() -- Small delay to ensure buttons are created
                self:hookAllSpellButtons()
            end)
        end)
    end
end

-- Hook spell buttons with proper right-click handling
function SpellMacroUI:hookAllSpellButtons()
    local self_ref = self
    local pagedFrame = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame
    if not pagedFrame or not pagedFrame.framePoolCollection then return end

    -- Handle both left and right page templates
    local templates = {
        {template = "SpellBookItemTemplate", kind = "SPELL"},
        {template = "SpellBookItemTemplateRightPage", kind = "SPELL_RIGHT"},
    }

    for _, info in ipairs(templates) do
        local pool = pagedFrame.framePoolCollection:GetPool(info.template, info.kind)
        if pool then
            for elementFrame in pool:EnumerateActive() do
                if elementFrame.Button and not elementFrame.Button.__SMD_Hooked then

                    -- Method 1: Use PreClick to intercept and block right-clicks
                    elementFrame.Button:SetScript("PreClick", function(button_self, button, down)
                        if button == "RightButton" then
                            -- Block the click entirely
                            return
                        end
                    end)

                    -- Method 2: Override the click handler completely
                    elementFrame.Button:SetScript("OnClick", function(button_self, button, down)
                        if button == "RightButton" then
                            local spellID = elementFrame.spellBookItemInfo and elementFrame.spellBookItemInfo.spellID
                            if spellID then
                                local menuItems = self_ref.spellMacroManager:generateMenuItems(spellID)
                                MenuUtil.CreateContextMenu(button_self, function(ownerRegion, rootDescription)
                                    rootDescription:CreateTitle("Create Macro")
                                    for _, menuItem in ipairs(menuItems) do
                                        rootDescription:CreateButton(menuItem.text, function()
                                            menuItem.func()
                                        end)
                                    end
                                end)
                            end
                            return -- Block further processing
                        else
                            -- For left clicks, let the default behavior happen
                            -- We need to manually trigger the spell pickup since we're overriding OnClick
                            if button == "LeftButton" and not down then
                                local spellID = elementFrame.spellBookItemInfo and elementFrame.spellBookItemInfo.spellID
                                if spellID then
                                    C_Spell.PickupSpell(spellID)
                                end
                            end
                        end
                    end)

                    -- Method 3: Disable right-click attribute entirely
                    elementFrame.Button:RegisterForClicks("LeftButtonUp", "LeftButtonDown")

                    -- Method 4: Create invisible overlay to catch right-clicks
                    if not elementFrame.Button.rightClickBlocker then
                        local blocker = CreateFrame("Button", nil, elementFrame.Button)
                        blocker:SetAllPoints(elementFrame.Button)
                        blocker:SetFrameLevel(elementFrame.Button:GetFrameLevel() + 1)
                        blocker:RegisterForClicks("RightButtonUp")
                        blocker:SetScript("OnClick", function(blocker_self, button)
                            if button == "RightButton" then
                                local spellID = elementFrame.spellBookItemInfo and elementFrame.spellBookItemInfo.spellID
                                if spellID then
                                    local menuItems = self_ref.spellMacroManager:generateMenuItems(spellID)
                                    MenuUtil.CreateContextMenu(elementFrame.Button, function(ownerRegion, rootDescription)
                                        rootDescription:CreateTitle("Create Macro")
                                        for _, menuItem in ipairs(menuItems) do
                                            rootDescription:CreateButton(menuItem.text, function()
                                                menuItem.func()
                                            end)
                                        end
                                    end)
                                end
                            end
                        end)
                        elementFrame.Button.rightClickBlocker = blocker
                    end

                    elementFrame.Button.__SMD_Hooked = true
                end
            end
        end
    end
end

-- Initialize the addon
local ui = SpellMacroUI.new()
local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:RegisterEvent("PLAYER_LOGIN")

addonFrame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == "Blizzard_PlayerSpells" then
        -- PlayerSpells addon loaded, hook when frame is shown
        if PlayerSpellsFrame then
            PlayerSpellsFrame:HookScript("OnShow", function()
                ui:initialize()
            end)
        end
    elseif event == "PLAYER_LOGIN" then
        -- Fallback initialization
        C_Timer.After(2, function()
            if PlayerSpellsFrame and PlayerSpellsFrame:IsVisible() then
                ui:initialize()
            end
        end)
    end
end)
