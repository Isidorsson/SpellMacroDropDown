-- MacroTemplate Class
local MacroTemplate = {}
MacroTemplate.__index = MacroTemplate

function MacroTemplate.new()
    local self = setmetatable({}, MacroTemplate)

    -- Organized macro categories and types
    self.categories = {
        BASIC = {
            name = "Basic Casting",
            macros = {
                NORMAL_CAST = "Normal Cast",
                CAST_PLAYER = "Cast on Self",
                CURSOR_CAST = "Cast at Cursor"
            }
        },
        TARGET = {
            name = "Target-Based",
            macros = {
                CAST_TARGET = "Cast on Target",
                CAST_TARGETTARGET = "Cast on Target's Target",
                CAST_FOCUS = "Cast on Focus",
                CAST_ARENA1 = "Cast on Arena1",
                CAST_ARENA2 = "Cast on Arena2",
                CAST_ARENA3 = "Cast on Arena3"
            }
        },
        MOUSEOVER = {
            name = "Mouseover Casting",
            macros = {
                MOUSEOVER_BASIC = "Mouseover Basic",
                MOUSEOVER_HARM = "Mouseover Harm",
                MOUSEOVER_HELP = "Mouseover Help",
                MOUSEOVER_HARM_OR_HELP = "Mouseover Harm/Help",
                MOUSEOVER_SMART = "Mouseover Smart Priority",
                MOUSEOVER_NODEAD = "Mouseover (No Dead)"
            }
        },
        PET = {
            name = "Pet Targeting",
            macros = {
                CAST_PET = "Cast on Pet",
                CAST_PETTARGET = "Cast on Pet's Target",
                MOUSEOVER_PET = "Mouseover then Pet"
            }
        },
        PARTY = {
            name = "Party/Raid",
            macros = {
                CAST_PARTY1 = "Cast on Party1",
                CAST_PARTY2 = "Cast on Party2",
                CAST_PARTY3 = "Cast on Party3",
                CAST_PARTY4 = "Cast on Party4",
                MOUSEOVER_PARTY = "Mouseover then Party",
                RANDOM_FRIENDLY = "Random Friendly"
            }
        },
        CONDITIONAL = {
            name = "Conditional Casting",
            macros = {
                HARM_HELP_AUTO = "Auto Harm/Help",
                MODIFIER_SHIFT = "Shift Modifier",
                MODIFIER_CTRL = "Ctrl Modifier",
                MODIFIER_ALT = "Alt Modifier",
                COMBAT_CONDITIONAL = "In/Out of Combat"
            }
        },
        UTILITY = {
            name = "Utility Macros",
            macros = {
                STOPCASTING_CAST = "Stop Casting + Cast",
                CANCELAURA_CAST = "Cancel Aura + Cast",
                SEQUENCE_CAST = "Sequence Cast",
                RANDOM_ENEMY = "Random Enemy"
            }
        }
    }

    self.templates = {
        -- Basic Casting
        NORMAL_CAST = "#showtooltip\n/cast %s",
        CAST_PLAYER = "#showtooltip\n/cast [@player] %s",
        CURSOR_CAST = "#showtooltip\n/cast [@cursor] %s",

        -- Target-Based
        CAST_TARGET = "#showtooltip\n/cast [@target,exists,nodead] %s",
        CAST_TARGETTARGET = "#showtooltip\n/cast [@targettarget,exists,nodead] %s",
        CAST_FOCUS = "#showtooltip\n/cast [@focus,exists,nodead][@target,exists,nodead] %s",
        CAST_ARENA1 = "#showtooltip\n/cast [@arena1,exists,nodead] %s",
        CAST_ARENA2 = "#showtooltip\n/cast [@arena2,exists,nodead] %s",
        CAST_ARENA3 = "#showtooltip\n/cast [@arena3,exists,nodead] %s",

        -- Mouseover Casting
        MOUSEOVER_BASIC = "#showtooltip\n/cast [@mouseover,exists] [] %s",
        MOUSEOVER_HARM = "#showtooltip\n/cast [@mouseover,harm,nodead] [] %s",
        MOUSEOVER_HELP = "#showtooltip\n/cast [@mouseover,help,nodead] [] %s",
        MOUSEOVER_HARM_OR_HELP = "#showtooltip\n/cast [@mouseover,harm,nodead][@mouseover,help,nodead] [] %s",
        MOUSEOVER_SMART = "#showtooltip\n/cast [@mouseover,harm,nodead][@mouseover,help,nodead][@target,harm,nodead][@target,help,nodead][@player] %s",
        MOUSEOVER_NODEAD = "#showtooltip\n/cast [@mouseover,exists,nodead] [] %s",

        -- Pet Targeting
        CAST_PET = "#showtooltip\n/cast [@pet,exists,nodead] %s",
        CAST_PETTARGET = "#showtooltip\n/cast [@pettarget,exists,nodead] %s",
        MOUSEOVER_PET = "#showtooltip\n/cast [@mouseover,exists,nodead][@pet,exists,nodead] %s",

        -- Party/Raid
        CAST_PARTY1 = "#showtooltip\n/cast [@party1,exists,nodead] %s",
        CAST_PARTY2 = "#showtooltip\n/cast [@party2,exists,nodead] %s",
        CAST_PARTY3 = "#showtooltip\n/cast [@party3,exists,nodead] %s",
        CAST_PARTY4 = "#showtooltip\n/cast [@party4,exists,nodead] %s",
        MOUSEOVER_PARTY = "#showtooltip\n/cast [@mouseover,help,nodead][@party1,exists,nodead][@party2,exists,nodead][@party3,exists,nodead][@party4,exists,nodead] %s",
        RANDOM_FRIENDLY = "#showtooltip\n/targetfriendplayer\n/cast %s\n/cleartarget",

        -- Conditional Casting
        HARM_HELP_AUTO = "#showtooltip\n/cast [harm,nodead] %s; [help,nodead] %s",
        MODIFIER_SHIFT = "#showtooltip\n/cast [mod:shift] %s; %s",
        MODIFIER_CTRL = "#showtooltip\n/cast [mod:ctrl] %s; [target] %s",
        MODIFIER_ALT = "#showtooltip\n/cast [mod:alt,@player] [target] %s",
        COMBAT_CONDITIONAL = "#showtooltip\n/cast [combat] %s; [nocombat] %s",

        -- Utility Macros
        STOPCASTING_CAST = "#showtooltip\n/stopcasting\n/cast %s",
        CANCELAURA_CAST = "#showtooltip\n/cancelaura %s\n/cast %s",
        SEQUENCE_CAST = "#showtooltip\n/castsequence reset=target %s",
        RANDOM_ENEMY = "#showtooltip\n/targetenemyplayer\n/cast %s\n/cleartarget"
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

    -- Create hierarchical menu structure
    for categoryKey, categoryData in pairs(self.macroTemplate.categories) do
        local categoryItem = {
            text = categoryData.name,
            hasArrow = true,
            menuList = {}
        }

        -- Add macros for this category
        for macroKey, macroName in pairs(categoryData.macros) do
            table.insert(categoryItem.menuList, {
                text = macroName,
                func = function()
                    self:generateSpellMacro(spellId, macroKey)
                end
            })
        end

        table.insert(menuItems, categoryItem)
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

                                    -- Create hierarchical menu
                                    for _, categoryItem in ipairs(menuItems) do
                                        if categoryItem.hasArrow and categoryItem.menuList then
                                            -- Create submenu
                                            local submenu = rootDescription:CreateButton(categoryItem.text)
                                            for _, subItem in ipairs(categoryItem.menuList) do
                                                submenu:CreateButton(subItem.text, subItem.func)
                                            end
                                        else
                                            -- Regular menu item
                                            rootDescription:CreateButton(categoryItem.text, categoryItem.func)
                                        end
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

                                        -- Create hierarchical menu
                                        for _, categoryItem in ipairs(menuItems) do
                                            if categoryItem.hasArrow and categoryItem.menuList then
                                                -- Create submenu
                                                local submenu = rootDescription:CreateButton(categoryItem.text)
                                                for _, subItem in ipairs(categoryItem.menuList) do
                                                    submenu:CreateButton(subItem.text, subItem.func)
                                                end
                                            else
                                                -- Regular menu item
                                                rootDescription:CreateButton(categoryItem.text, categoryItem.func)
                                            end
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
