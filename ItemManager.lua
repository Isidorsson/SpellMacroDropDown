-- SpellMacroDropDown ItemManager
-- Handles item macro generation and menu creation

local addonName, addonTable = ...
local SpellMacroDropDown = addonTable

-- ItemMacroManager Class
local ItemMacroManager = {}
ItemMacroManager.__index = ItemMacroManager

function ItemMacroManager.new()
    local self = setmetatable({}, ItemMacroManager)
    self.macroTemplate = SpellMacroDropDown.MacroTemplate.new()
    return self
end

function ItemMacroManager:generateItemMenuItems(itemID, slotID)
    local menuItems = {}
    
    -- Create hierarchical menu structure for items
    for _, categoryKey in ipairs(self.macroTemplate.itemCategoryOrder) do
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
                                self:generateItemMacro(itemID, slotID, macroKey)
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

function ItemMacroManager:generateItemMacro(itemID, slotID, macroType)
    local itemName, itemLink, itemTexture
    
    -- For equipped items, use GetInventoryItemLink (more reliable)
    if slotID then
        itemLink = GetInventoryItemLink("player", slotID)
        itemName = SpellMacroDropDown.Utils.GetItemNameFromLink(itemLink)
        itemTexture = GetInventoryItemTexture("player", slotID)
    end
    
    -- Fallback to C_Item.GetItemInfo if not equipped or if above failed
    if not itemName then
        local itemInfo = C_Item.GetItemInfo(itemID)
        if itemInfo then
            itemName, itemLink, itemTexture = itemInfo.itemName, itemInfo.itemLink, itemInfo.itemIcon
        end
    end
    
    if not itemName then
        print("SpellMacroDropDown: Invalid item ID or item name not found: " .. tostring(itemID))
        return
    end
    
    local template = self.macroTemplate:getTemplate(macroType)
    local macroText
    
    -- Use slot ID for equipment slot macros, item name for others
    if macroType == "ITEM_USE_SLOT" and slotID then
        macroText = string.format(template, slotID)
    else
        macroText = string.format(template, itemName)
    end
    
    local baseMacroName = itemName
    local macroName = baseMacroName
    local counter = 1
    
    -- Ensure unique macro name
    while GetMacroInfo(macroName) do
        macroName = baseMacroName .. counter
        counter = counter + 1
    end
    
    local success = pcall(CreateMacro, macroName, itemTexture, macroText, true)
    if success then
        PickupMacro(macroName)
        print("SpellMacroDropDown: Created item macro '" .. macroName .. "'")
    else
        print("SpellMacroDropDown: Failed to create item macro '" .. macroName .. "' - you may have reached the macro limit")
    end
end

-- Export ItemMacroManager to addon namespace
SpellMacroDropDown.ItemMacroManager = ItemMacroManager