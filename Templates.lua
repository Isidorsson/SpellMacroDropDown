-- SpellMacroDropDown Templates
-- Macro template definitions and categories

local addonName, addonTable = ...
local SpellMacroDropDown = addonTable

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
    
    -- Item-specific category order
    self.itemCategoryOrder = {
        "ITEM_BASIC",
        "ITEM_TARGET",
        "ITEM_MOUSEOVER",
        "ITEM_CONDITIONAL"
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
        },
        ITEM_BASIC = {
            "ITEM_USE",
            "ITEM_USE_SLOT"
        },
        ITEM_TARGET = {
            "ITEM_USE_TARGET",
            "ITEM_USE_FOCUS",
            "ITEM_USE_PLAYER"
        },
        ITEM_MOUSEOVER = {
            "ITEM_USE_MOUSEOVER",
            "ITEM_USE_MOUSEOVER_HELP"
        },
        ITEM_CONDITIONAL = {
            "ITEM_USE_COMBAT",
            "ITEM_USE_MODIFIER"
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
        },
        ITEM_BASIC = {
            name = "Basic Item Use",
            macros = {
                ITEM_USE = "Use Item",
                ITEM_USE_SLOT = "Use Equipment Slot"
            }
        },
        ITEM_TARGET = {
            name = "Targeted Item Use",
            macros = {
                ITEM_USE_TARGET = "Use on Target",
                ITEM_USE_FOCUS = "Use on Focus",
                ITEM_USE_PLAYER = "Use on Self"
            }
        },
        ITEM_MOUSEOVER = {
            name = "Mouseover Item Use",
            macros = {
                ITEM_USE_MOUSEOVER = "Use on Mouseover",
                ITEM_USE_MOUSEOVER_HELP = "Use on Friendly Mouseover"
            }
        },
        ITEM_CONDITIONAL = {
            name = "Conditional Item Use",
            macros = {
                ITEM_USE_COMBAT = "Use in/out of Combat",
                ITEM_USE_MODIFIER = "Use with Modifier"
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
        RANDOM_ENEMY = "#showtooltip\n/targetenemyplayer\n/cast %s\n/cleartarget",
        
        -- Item Macros
        ITEM_USE = "#showtooltip\n/use %s",
        ITEM_USE_SLOT = "#showtooltip\n/use %d",
        ITEM_USE_TARGET = "#showtooltip\n/use [@target,exists,nodead] %s",
        ITEM_USE_FOCUS = "#showtooltip\n/use [@focus,exists,nodead] %s",
        ITEM_USE_PLAYER = "#showtooltip\n/use [@player] %s",
        ITEM_USE_MOUSEOVER = "#showtooltip\n/use [@mouseover,exists] [] %s",
        ITEM_USE_MOUSEOVER_HELP = "#showtooltip\n/use [@mouseover,help,nodead] [] %s",
        ITEM_USE_COMBAT = "#showtooltip\n/use [combat] %s",
        ITEM_USE_MODIFIER = "#showtooltip\n/use [mod:shift] %s"
    }
    return self
end

function MacroTemplate:getTemplate(macroType)
    return self.templates[macroType] or self.templates.NORMAL_CAST
end

-- Export MacroTemplate to addon namespace
SpellMacroDropDown.MacroTemplate = MacroTemplate