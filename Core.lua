-- SpellMacroDropDown Core
-- Main addon namespace and initialization

local addonName, addonTable = ...

-- Create main addon namespace
SpellMacroDropDown = addonTable
addonTable.version = "1.2.0"

-- Addon initialization
local Core = {}
SpellMacroDropDown.Core = Core

-- Initialize addon components
function Core:Initialize()
    -- Create UI instance
    self.ui = SpellMacroDropDown.UI.new()
    
    -- Enhanced initialization with multiple fallbacks
    local initAttempts = 0
    local maxInitAttempts = 5

    local function attemptInitialization()
        initAttempts = initAttempts + 1

        if PlayerSpellsFrame and PlayerSpellsFrame.SpellBookFrame and PlayerSpellsFrame.SpellBookFrame.PagedSpellsFrame then
            self.ui:initialize()
            return true
        elseif initAttempts < maxInitAttempts then
            C_Timer.After(1, attemptInitialization)
            return false
        end

        -- Failed to initialize after max attempts
        return false
    end

    -- Event frame for addon initialization
    local addonFrame = CreateFrame("Frame")
    addonFrame:RegisterEvent("ADDON_LOADED")
    addonFrame:RegisterEvent("PLAYER_LOGIN")
    addonFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

    addonFrame:SetScript("OnEvent", function(_, event, addonLoadedName)
        if event == "ADDON_LOADED" and addonLoadedName == "Blizzard_PlayerSpells" then
            C_Timer.After(0.5, attemptInitialization)
        elseif event == "PLAYER_LOGIN" then
            C_Timer.After(2, attemptInitialization)
        elseif event == "PLAYER_ENTERING_WORLD" then
            C_Timer.After(3, attemptInitialization)
        end
    end)

    -- Hook spellbook open
    local function hookSpellbookOpen()
        if PlayerSpellsFrame then
            PlayerSpellsFrame:HookScript("OnShow", function()
                if not self.ui.isInitialized then
                    attemptInitialization()
                else
                    -- Re-hook buttons when spellbook opens
                    C_Timer.After(0.2, function()
                        self.ui:hookAllSpellButtons()
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
        checkFrame:SetScript("OnEvent", function(_, event, addonLoadedName)
            if addonLoadedName == "Blizzard_PlayerSpells" and PlayerSpellsFrame then
                hookSpellbookOpen()
                checkFrame:UnregisterEvent("ADDON_LOADED")
            end
        end)
    end

    -- Character frame initialization
    local characterInitFrame = CreateFrame("Frame")
    characterInitFrame:RegisterEvent("PLAYER_LOGIN")
    characterInitFrame:RegisterEvent("ADDON_LOADED")
    characterInitFrame:SetScript("OnEvent", function(frame, event, arg1)
        if event == "PLAYER_LOGIN" then
            -- Setup character frame hooks on player login
            C_Timer.After(2, function()
                self.ui:setupCharacterFrameHooks()
            end)
        elseif event == "ADDON_LOADED" and arg1 == "SpellMacroDropDown" then
            -- Also try during our own addon load
            C_Timer.After(1, function()
                self.ui:setupCharacterFrameHooks()
            end)
        end
    end)
end

-- Auto-initialize when Core is loaded
Core:Initialize()