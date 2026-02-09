-- MacroTemplate Class
local MacroTemplate = {}
MacroTemplate.__index = MacroTemplate

function MacroTemplate.new()
    local self = setmetatable({}, MacroTemplate)

    -- Hierarchical categories with items
    self.categories = {
        {
            name = "Basic",
            items = {
                { label = "Normal", template = "#showtooltip\n/cast %s" },
                { label = "Stopcasting + Cast", template = "#showtooltip\n/stopcasting\n/cast %s" },
                { label = "@Cursor", template = "#showtooltip\n/cast [@cursor] %s" },
            }
        },
        {
            name = "Mouseover",
            items = {
                { label = "Basic", template = "#showtooltip\n/cast [@mouseover,exists,nodead][] %s" },
                { label = "Harm Only", template = "#showtooltip\n/cast [@mouseover,harm,nodead][] %s" },
                { label = "Help Only", template = "#showtooltip\n/cast [@mouseover,help,nodead][] %s" },
                { label = "Any", template = "#showtooltip\n/cast [@mouseover] %s" },
            }
        },
        {
            name = "Friendly Targets",
            items = {
                { label = "@Self", template = "#showtooltip\n/stopspelltarget\n/cast [@player] %s" },
                { label = "@Pet", template = "#showtooltip\n/cast [@pet,exists,nodead][] %s" },
                { label = "@Focus", template = "#showtooltip\n/cast [@focus,exists,nodead][@mouseover,exists,nodead][] %s" },
                { label = "@Tank", template = "#showtooltip\n/cast [@tank,exists,nodead][] %s" },
                { label = "@Party1", template = "#showtooltip\n/cast [@party1,exists,nodead] %s" },
                { label = "@Party2", template = "#showtooltip\n/cast [@party2,exists,nodead] %s" },
                { label = "@Party3", template = "#showtooltip\n/cast [@party3,exists,nodead] %s" },
                { label = "@Party4", template = "#showtooltip\n/cast [@party4,exists,nodead] %s" },
                { label = "Random Friend", template = "#showtooltip\n/targetfriendplayer\n/cast %s\n/cleartarget" },
            }
        },
        {
            name = "Enemy Targets",
            items = {
                { label = "@Boss1", template = "#showtooltip\n/cast [@boss1,exists] %s" },
                { label = "@Boss2", template = "#showtooltip\n/cast [@boss2,exists] %s" },
                { label = "@Boss3", template = "#showtooltip\n/cast [@boss3,exists] %s" },
                { label = "@Boss4", template = "#showtooltip\n/cast [@boss4,exists] %s" },
                { label = "@Boss5", template = "#showtooltip\n/cast [@boss5,exists] %s" },
                { label = "@Arena1", template = "#showtooltip\n/cast [@arena1,exists] %s" },
                { label = "@Arena2", template = "#showtooltip\n/cast [@arena2,exists] %s" },
                { label = "@Arena3", template = "#showtooltip\n/cast [@arena3,exists] %s" },
                { label = "Random Enemy", template = "#showtooltip\n/targetenemyplayer\n/cast %s\n/cleartarget" },
            }
        },
        {
            name = "Smart Targeting",
            items = {
                { label = "Mouseover > Focus > Target", template = "#showtooltip\n/cast [@mouseover,exists,nodead][@focus,exists,nodead][] %s" },
                { label = "Mouseover > Focus > Self", template = "#showtooltip\n/cast [@mouseover,exists,nodead][@focus,exists,nodead][@player] %s" },
                { label = "Focus > Mouseover > Target", template = "#showtooltip\n/cast [@focus,exists,nodead][@mouseover,exists,nodead][] %s" },
                { label = "Focus > Pet > Self", template = "#showtooltip\n/cast [@focus,exists,nodead][@pet,exists,nodead][@player] %s" },
                { label = "Pet > Focus > Tank", template = "#showtooltip\n/cast [@pet,exists,nodead][@focus,exists,nodead][@tank,exists,nodead] %s" },
                { label = "Mouseover > Tank > Self", template = "#showtooltip\n/cast [@mouseover,exists,nodead][@tank,exists,nodead][@player] %s" },
                { label = "Focus > Tank > Self", template = "#showtooltip\n/cast [@focus,exists,nodead][@tank,exists,nodead][@player] %s" },
            }
        },
        {
            name = "Pet Commands",
            items = {
                { label = "Cast + Pet Attack", template = "#showtooltip\n/petattack\n/cast %s" },
                { label = "Cast + Pet Follow", template = "#showtooltip\n/petfollow\n/cast %s" },
                { label = "Stopcasting + Pet Attack", template = "#showtooltip\n/stopcasting\n/petattack\n/cast %s" },
                { label = "Cast on Pet", template = "#showtooltip\n/cast [@pet,exists,nodead] %s" },
                { label = "Mouseover + Pet Attack", template = "#showtooltip\n/petattack\n/cast [@mouseover,exists,nodead][] %s" },
                { label = "Cast + Pet Assist", template = "#showtooltip\n/petassist\n/cast %s" },
                { label = "Cast + Pet Passive", template = "#showtooltip\n/petpassive\n/cast %s" },
                { label = "Pet Toggle + Cast", template = "#showtooltip\n/petfollow [@pettarget,exists]\n/petattack [@pettarget,noexists]\n/cast %s" },
            }
        },
    }

    -- Build lookup table for getTemplate
    self.templateLookup = {}
    for _, category in ipairs(self.categories) do
        for _, item in ipairs(category.items) do
            self.templateLookup[item.label] = item.template
        end
    end

    return self
end

function MacroTemplate:getTemplate(macroType)
    return self.templateLookup[macroType] or "#showtooltip\n/cast %s"
end

-- SpellMacroManager Class
local SpellMacroManager = {}
SpellMacroManager.__index = SpellMacroManager

function SpellMacroManager.new()
    local self = setmetatable({}, SpellMacroManager)
    self.macroTemplate = MacroTemplate.new()
    return self
end

function SpellMacroManager:buildContextMenu(spellId, rootDescription)
    rootDescription:CreateTitle("Create Macro")
    for _, category in ipairs(self.macroTemplate.categories) do
        local submenu = rootDescription:CreateButton(category.name)
        for _, item in ipairs(category.items) do
            submenu:CreateButton(item.label, function()
                self:generateSpellMacro(spellId, item.label)
            end)
        end
    end
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
    self.hookedButtons = setmetatable({}, {__mode = "k"}) -- Weak keys for GC
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

    -- Re-hook on spellbook updates (page changes, tab switches)
    local pagedFrame = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame
    if pagedFrame and pagedFrame.UpdateSpells then
        hooksecurefunc(pagedFrame, "UpdateSpells", function()
            C_Timer.After(0, function()
                self:hookAllSpellButtons()
            end)
        end)
    end

    -- Re-hook every time the spellbook is shown (handles stale pool frames)
    PlayerSpellsFrame.SpellBookFrame:HookScript("OnShow", function()
        C_Timer.After(0, function()
            self:hookAllSpellButtons()
        end)
    end)

    -- Hook current buttons now
    self:hookAllSpellButtons()
end

-- Hook spell buttons with proper right-click handling
function SpellMacroUI:hookAllSpellButtons()
    local self_ref = self
    local pagedFrame = PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame
    if not pagedFrame or not pagedFrame.framePoolCollection then return end

    -- Enumerate all active frames from all pools (more reliable than GetPool with specific keys)
    for elementFrame in pagedFrame.framePoolCollection:EnumerateActive() do
        if elementFrame.Button and not self_ref.hookedButtons[elementFrame.Button] then
            -- PreClick: Block right-click spell cast
            elementFrame.Button:HookScript("PreClick", function(button_self, mouseButton)
                if mouseButton == "RightButton" and not InCombatLockdown() then
                    button_self:SetAttribute("type", nil)
                    button_self.__SMD_RightClicked = true
                end
            end)

            -- PostClick: Restore and show menu
            elementFrame.Button:HookScript("PostClick", function(button_self, mouseButton)
                if mouseButton == "RightButton" and button_self.__SMD_RightClicked then
                    button_self.__SMD_RightClicked = nil
                    if not InCombatLockdown() then
                        button_self:SetAttribute("type", "spell")
                    end
                    local spellID = elementFrame.spellBookItemInfo and elementFrame.spellBookItemInfo.spellID
                    if spellID then
                        MenuUtil.CreateContextMenu(button_self, function(ownerRegion, rootDescription)
                            self_ref.spellMacroManager:buildContextMenu(spellID, rootDescription)
                        end)
                    end
                end
            end)

            self_ref.hookedButtons[elementFrame.Button] = true
        end
    end
end

-- Initialize the addon
local ui = SpellMacroUI.new()
local addonFrame = CreateFrame("Frame")

local function setupPlayerSpellsHooks()
    if not PlayerSpellsFrame then return end

    PlayerSpellsFrame:HookScript("OnShow", function()
        ui:initialize()
    end)

    -- Initialize immediately if already visible
    if PlayerSpellsFrame:IsVisible() then
        ui:initialize()
    end
end

-- Check if Blizzard_PlayerSpells is already loaded (e.g., /reload while spellbook was open)
if C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells") then
    setupPlayerSpellsHooks()
else
    addonFrame:RegisterEvent("ADDON_LOADED")
    addonFrame:SetScript("OnEvent", function(_, event, addonName)
        if event == "ADDON_LOADED" and addonName == "Blizzard_PlayerSpells" then
            addonFrame:UnregisterEvent("ADDON_LOADED")
            setupPlayerSpellsHooks()
        end
    end)
end
