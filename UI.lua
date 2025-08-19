-- SpellMacroDropDown UI
-- Handles all UI interactions, button hooks, and event management

local addonName, addonTable = ...
local SpellMacroDropDown = addonTable

-- SpellMacroUI Class
local SpellMacroUI = {}
SpellMacroUI.__index = SpellMacroUI

function SpellMacroUI.new()
    local self = setmetatable({}, SpellMacroUI)
    self.isInitialized = false
    self.spellMacroManager = SpellMacroDropDown.SpellMacroManager.new()
    self.itemMacroManager = SpellMacroDropDown.ItemMacroManager.new()
    self.hookedSlots = {} -- Track hooked equipment slots
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
        if not C_AddOns.IsAddOnLoaded("Blizzard_MacroUI") then
            C_AddOns.LoadAddOn("Blizzard_MacroUI")
        end
        ShowUIPanel(MacroFrame)
    end)
    macroButton:Show()

    -- Hook spellbook events more reliably
    self:setupSpellbookHooks()
    
    -- Setup character frame hooks (will handle its own loading)
    self:setupCharacterFrameHooks()

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

    -- Re-hook all buttons to ensure correct spell IDs after tab changes

    local templates = {
        {template = "SpellBookItemTemplate", kind = "SPELL"},
        {template = "SpellBookItemTemplateRightPage", kind = "SPELL_RIGHT"},
    }

    for _, info in ipairs(templates) do
        local pool = pagedFrame.framePoolCollection:GetPool(info.template, info.kind)
        if pool then
            for elementFrame in pool:EnumerateActive() do
                if elementFrame.Button and elementFrame.spellBookItemInfo and elementFrame.spellBookItemInfo.spellID then
                    -- Always re-hook buttons to ensure correct spell ID after tab changes
                    self:hookSpellButton(elementFrame.Button, elementFrame)
                end
            end
        end
    end
end

function SpellMacroUI:hookSpellButton(button, elementFrame)
    local self_ref = self

    -- Use HookScript to avoid overwriting existing handlers
    button:HookScript("OnClick", function(button_self, mouseButton, down)
        if mouseButton == "RightButton" and not down then
            -- Get current spell ID dynamically from elementFrame
            local currentSpellID = elementFrame.spellBookItemInfo and elementFrame.spellBookItemInfo.spellID
            if not currentSpellID then return end
            
            -- Handle right-click for macro creation
            local spellInfo = C_Spell.GetSpellInfo(currentSpellID)
            local spellName = (spellInfo and spellInfo.name) and spellInfo.name or "Unknown Spell"
            local menuItems = self_ref.spellMacroManager:generateMenuItems(currentSpellID)
            MenuUtil.CreateContextMenu(button_self, function(ownerRegion, rootDescription)
                rootDescription:CreateTitle(spellName)

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
        end
    end)
end

-- Equipment slot functions and hooks
function SpellMacroUI:setupCharacterFrameHooks()
    local self_ref = self
    
    -- Setting up character frame hooks
    
    -- Track if we've successfully hooked the character frame
    self.characterFrameHooked = false
    
    -- Function to hook character frame when it's available
    local function hookCharacterFrame()
        if CharacterFrame then
            -- CharacterFrame found, setting up hooks
            
            -- Only hook OnShow once
            if not self_ref.characterFrameHooked then
                self_ref.characterFrameHooked = true
                
                CharacterFrame:HookScript("OnShow", function()
                    -- CharacterFrame shown, hooking equipment slots after delay
                    -- Delay to ensure all equipment slots are created
                    C_Timer.After(0.5, function()
                        -- Clear and re-hook to ensure fresh hooks
                        self_ref.hookedSlots = {}
                        self_ref:hookEquipmentSlots()
                    end)
                end)
            end
            
            -- If character frame is already visible, hook immediately with delay
            if CharacterFrame:IsVisible() then
                -- CharacterFrame already visible, hooking equipment slots
                C_Timer.After(0.5, function()
                    self_ref.hookedSlots = {}
                    self_ref:hookEquipmentSlots()
                end)
            end
            return true
        end
        return false
    end
    
    -- Create a persistent frame to handle character UI loading
    if not self.characterUIWatcher then
        self.characterUIWatcher = CreateFrame("Frame")
        self.characterUIWatcher:RegisterEvent("ADDON_LOADED")
        self.characterUIWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
        
        self.characterUIWatcher:SetScript("OnEvent", function(frame, event, arg1)
            if event == "ADDON_LOADED" and arg1 == "Blizzard_CharacterUI" then
                -- Blizzard_CharacterUI loaded via event
                C_Timer.After(0.1, function()
                    hookCharacterFrame()
                end)
            elseif event == "PLAYER_ENTERING_WORLD" then
                -- Try to load the addon if not already loaded
                if not C_AddOns.IsAddOnLoaded("Blizzard_CharacterUI") then
                    C_AddOns.LoadAddOn("Blizzard_CharacterUI")
                end
                -- Always attempt to hook on entering world
                C_Timer.After(1, function()
                    hookCharacterFrame()
                end)
            end
        end)
    end
    
    -- Try to load and hook immediately
    if not C_AddOns.IsAddOnLoaded("Blizzard_CharacterUI") then
        C_AddOns.LoadAddOn("Blizzard_CharacterUI")
    end
    
    -- Attempt immediate hook with short delay
    C_Timer.After(0.1, function()
        if not hookCharacterFrame() then
            -- Initial character frame hook failed, will retry via events
        end
    end)
    
    -- Also monitor equipment changes
    if not self.equipmentWatcher then
        self.equipmentWatcher = CreateFrame("Frame")
        self.equipmentWatcher:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
        self.equipmentWatcher:SetScript("OnEvent", function(_, event, slotID)
            if CharacterFrame and CharacterFrame:IsVisible() then
                -- Debounce equipment changes
                if self_ref.equipmentChangeTimer then
                    self_ref.equipmentChangeTimer:Cancel()
                end
                self_ref.equipmentChangeTimer = C_Timer.NewTimer(0.5, function()
                    self_ref:hookEquipmentSlots()
                end)
            end
        end)
    end
end

function SpellMacroUI:hookEquipmentSlots()
    -- Attempting to hook equipment slots
    local hooked = 0
    
    for slotID, slotName in pairs(SpellMacroDropDown.Utils.SLOT_NAMES) do
        local button = _G["Character" .. slotName]
        if button then
            -- Always re-hook to ensure fresh hooks
            self:hookEquipmentButton(button, slotID)
            self.hookedSlots[slotID] = true
            hooked = hooked + 1
        else
            -- Failed to find button for slot
        end
    end
    
    -- Successfully hooked equipment slots
end

function SpellMacroUI:hookEquipmentButton(button, slotID)
    local self_ref = self
    
    -- Hooking equipment slot
    
    -- Ensure button registers right-clicks
    button:RegisterForClicks("LeftButtonUp", "LeftButtonDown", "RightButtonUp", "RightButtonDown")
    
    -- Use HookScript for secure frames instead of SetScript
    button:HookScript("OnClick", function(button_self, mouseButton, down)
        -- Equipment slot clicked
        
        if mouseButton == "RightButton" and not down then
            -- Get equipped item
            local itemID = GetInventoryItemID("player", slotID)
            -- Item ID found
            
            if itemID then
                -- Get item info for menu title using inventory link (more reliable for equipped items)
                local itemLink = GetInventoryItemLink("player", slotID)
                local itemName = SpellMacroDropDown.Utils.GetItemNameFromLink(itemLink) or "Unknown Item"
                
                -- Generate and show menu
                local menuItems = self_ref.itemMacroManager:generateItemMenuItems(itemID, slotID)
                -- Menu items generated
                
                MenuUtil.CreateContextMenu(button_self, function(ownerRegion, rootDescription)
                    rootDescription:CreateTitle(itemName)
                    
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
            end
        end
    end)
end

-- Export SpellMacroUI to addon namespace
SpellMacroDropDown.UI = SpellMacroUI