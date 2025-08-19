-- SpellMacroDropDown Utils
-- Helper functions and utilities

local addonName, addonTable = ...
local SpellMacroDropDown = addonTable

-- Create Utils namespace
local Utils = {}
SpellMacroDropDown.Utils = Utils

-- Helper function to extract item name from item link
function Utils.GetItemNameFromLink(itemLink)
    if not itemLink then return nil end
    local itemName = itemLink:match("|h%[(.-)%]|h")
    return itemName
end

-- Equipment slot names mapping
Utils.SLOT_NAMES = {
    [1] = "HeadSlot",
    [2] = "NeckSlot", 
    [3] = "ShoulderSlot",
    [4] = "ShirtSlot",
    [5] = "ChestSlot",
    [6] = "WaistSlot",
    [7] = "LegsSlot",
    [8] = "FeetSlot",
    [9] = "WristSlot",
    [10] = "HandsSlot",
    [11] = "Finger0Slot",
    [12] = "Finger1Slot", 
    [13] = "Trinket0Slot",
    [14] = "Trinket1Slot",
    [15] = "BackSlot",
    [16] = "MainHandSlot",
    [17] = "SecondaryHandSlot",
    [18] = "RangedSlot",
    [19] = "TabardSlot"
}