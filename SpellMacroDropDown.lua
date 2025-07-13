-- MacroTemplate Class
local MacroTemplate = {}
MacroTemplate.__index = MacroTemplate

function MacroTemplate.new()
    local self = setmetatable({}, MacroTemplate)

    -- Define the order of categories
    self.categoryOrder = {
        "BASIC",
        "TARGET",
        "MOUSEOVER",
        "PET",
        "PARTY",
        "CONDITIONAL",
        "UTILITY"
    }

    -- Define the order of macros within each category
    self.macroOrder = {
        BASIC = {
            "NORMAL_CAST",
            "CAST_PLAYER",
            "CURSOR_CAST"
        },
        TARGET = {
            "CAST_TARGET",
            "CAST_TARGETTARGET",
            "CAST_FOCUS",
            "CAST_ARENA1",
            "CAST_ARENA2",
            "CAST_ARENA3"
        },
        MOUSEOVER = {
            "MOUSEOVER_BASIC",
            "MOUSEOVER_HARM",
            "MOUSEOVER_HELP",
            "MOUSEOVER_HARM_OR_HELP",
            "MOUSEOVER_SMART",
            "MOUSEOVER_NODEAD"
        },
        PET = {
            "CAST_PET",
            "CAST_PETTARGET",
            "MOUSEOVER_PET"
        },
        PARTY = {
            "CAST_PARTY1",
            "CAST_PARTY2",
            "CAST_PARTY3",
            "CAST_PARTY4",
            "MOUSEOVER_PARTY",
            "RANDOM_FRIENDLY"
        },
        CONDITIONAL = {
            "HARM_HELP_AUTO",
            "MODIFIER_SHIFT",
            "MODIFIER_CTRL",
            "MODIFIER_ALT",
            "COMBAT_CONDITIONAL"
        },
        UTILITY = {
            "STOPCASTING_CAST",
            "CANCELAURA_CAST",
            "SEQUENCE_CAST",
            "RANDOM_ENEMY"
        }
    }

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
    return self.templates[macroType] or self.templates.NORMAL_CAST
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
    if not spellInfo then
        print("Invalid spell ID: " .. spellId)
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

    CreateMacro(macroName, icon, macroText, true)
    PickupMacro(macroName)
    print("Created macro: " .. macroName)
end

-- Improved SpellMacroUI Class with better hooking
local SpellMacroUI = {}
SpellMacroUI.__index = SpellMacroUI

function SpellMacroUI.new()
    local self = setmetatable({}, SpellMacroUI)
    self.isInitialized = false
    self.spellMacroManager = SpellMacroManager.new()
    self.hookedButtons = {} -- Track hooked buttons
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

    -- Hook spellbook events more reliably
    self:setupSpellbookHooks()

    -- Initial hook attempt
    self:hookAllSpellButtons()
end

function SpellMacroUI:setupSpellbookHooks()
    local self_ref = self

    -- Hook the spellbook frame show event
    if PlayerSpellsFrame.SpellBookFrame then
        PlayerSpellsFrame.SpellBookFrame:HookScript("OnShow", function()
            C_Timer.After(0.2, function()
                self_ref:hookAllSpellButtons()
            end)
        end)
    end

    -- Hook page changes
    local pagedFrame = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame
    if pagedFrame then
        -- Hook UpdateSpells with longer delay
        if pagedFrame.UpdateSpells then
            hooksecurefunc(pagedFrame, "UpdateSpells", function()
                C_Timer.After(0.3, function()
                    self_ref:hookAllSpellButtons()
                end)
            end)
        end

        -- Hook page navigation
        if pagedFrame.SetPage then
            hooksecurefunc(pagedFrame, "SetPage", function()
                C_Timer.After(0.2, function()
                    self_ref:hookAllSpellButtons()
                end)
            end)
        end
    end

    -- Hook spellbook category changes
    if PlayerSpellsFrame.SpellBookFrame.CategoryDropdown then
        local dropdown = PlayerSpellsFrame.SpellBookFrame.CategoryDropdown
        if dropdown.SetSelectionID then
            hooksecurefunc(dropdown, "SetSelectionID", function()
                C_Timer.After(0.3, function()
                    self_ref:hookAllSpellButtons()
                end)
            end)
        end
    end
end

-- Simplified, more reliable hook method
function SpellMacroUI:hookAllSpellButtons()
    local self_ref = self
    local pagedFrame = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame
    if not pagedFrame or not pagedFrame.framePoolCollection then return end

    -- Clear old hooks to prevent conflicts
    self.hookedButtons = {}

    local templates = {
        {template = "SpellBookItemTemplate", kind = "SPELL"},
        {template = "SpellBookItemTemplateRightPage", kind = "SPELL_RIGHT"},
    }

    for _, info in ipairs(templates) do
        local pool = pagedFrame.framePoolCollection:GetPool(info.template, info.kind)
        if pool then
            for elementFrame in pool:EnumerateActive() do
                if elementFrame.Button and elementFrame.spellBookItemInfo and elementFrame.spellBookItemInfo.spellID then
                    local buttonKey = tostring(elementFrame.Button)

                    -- Only hook if not already hooked
                    if not self.hookedButtons[buttonKey] then
                        self:hookSpellButton(elementFrame.Button, elementFrame.spellBookItemInfo.spellID)
                        self.hookedButtons[buttonKey] = true
                    end
                end
            end
        end
    end
end

function SpellMacroUI:hookSpellButton(button, spellID)
    local self_ref = self

    -- Store original click handler
    local originalOnClick = button:GetScript("OnClick")

    -- Set new click handler
    button:SetScript("OnClick", function(button_self, mouseButton, down)
        if mouseButton == "RightButton" and not down then
            -- Handle right-click for macro creation
            local menuItems = self_ref.spellMacroManager:generateMenuItems(spellID)
            MenuUtil.CreateContextMenu(button_self, function(ownerRegion, rootDescription)
                rootDescription:CreateTitle("Create Macro")

                for _, categoryItem in ipairs(menuItems) do
                    if categoryItem.hasArrow and categoryItem.menuList then
                        local submenu = rootDescription:CreateButton(categoryItem.text)
                        for _, subItem in ipairs(categoryItem.menuList) do
                            submenu:CreateButton(subItem.text, subItem.func)
                        end
                    else
                        rootDescription:CreateButton(categoryItem.text, categoryItem.func)
                    end
                end
            end)
        elseif mouseButton == "LeftButton" then
            -- Don't override the default spellbook behavior
            -- Let the default handler run by not preventing propagation
            return
        end
    end)

    -- Ensure button registers right-clicks
    button:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonUp")
end

-- Enhanced initialization with multiple fallbacks
local ui = SpellMacroUI.new()
local addonFrame = CreateFrame("Frame")
addonFrame:RegisterEvent("ADDON_LOADED")
addonFrame:RegisterEvent("PLAYER_LOGIN")
addonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

local initAttempts = 0
local maxInitAttempts = 5

local function attemptInitialization()
    initAttempts = initAttempts + 1

    if PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame and PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame then
        ui:initialize()
        return true
    elseif initAttempts < maxInitAttempts then
        C_Timer.After(1, attemptInitialization)
        return false
    end

    print("SpellMacro: Failed to initialize after", maxInitAttempts, "attempts")
    return false
end

addonFrame:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" and addonName == "Blizzard_PlayerSpells" then
        C_Timer.After(0.5, attemptInitialization)
    elseif event == "PLAYER_LOGIN" then
        C_Timer.After(2, attemptInitialization)
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(3, attemptInitialization)
    end
end)

-- Also hook when spellbook is manually opened
local function hookSpellbookOpen()
    if PlayerSpellsFrame then
        PlayerSpellsFrame:HookScript("OnShow", function()
            if not ui.isInitialized then
                attemptInitialization()
            else
                -- Re-hook buttons when spellbook opens
                C_Timer.After(0.2, function()
                    ui:hookAllSpellButtons()
                end)
            end
        end)
    end
end

-- Try to hook spellbook open immediately, or wait for it to be available
if PlayerSpellsFrame then
    hookSpellbookOpen()
else
    local checkFrame = CreateFrame("Frame")
    checkFrame:RegisterEvent("ADDON_LOADED")
    checkFrame:SetScript("OnEvent", function(_, event, addonName)
        if addonName == "Blizzard_PlayerSpells" and PlayerSpellsFrame then
            hookSpellbookOpen()
            checkFrame:UnregisterEvent("ADDON_LOADED")
        end
    end)
end
