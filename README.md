# SpellMacroDropDown

A World of Warcraft addon that adds right-click context menus to spells and equipment items for quick macro creation.

## Features

- **Spell Macros**: Right-click any spell in your spellbook to create various macro types
- **Equipment Macros**: Right-click equipment slots in your character panel to create item macros
- **Organized Categories**: Macros are organized into logical categories with submenus
- **Automatic Naming**: Creates uniquely named macros automatically
- **Macro Button**: Adds a "Macros" button to the spellbook for quick access to the macro interface

## Macro Categories

### Spell Macros
- **Basic Casting**: Normal cast, self-cast, cursor cast
- **Target-Based**: Target, target's target, focus, arena targets
- **Mouseover Casting**: Various mouseover options including smart priority
- **Pet Targeting**: Pet and pet's target macros
- **Party/Raid**: Party member targeting and random friendly
- **Conditional Casting**: Modifier keys, combat state, harm/help auto-targeting
- **Utility Macros**: Stop casting, cancel aura, sequence casting

### Item Macros
- **Basic Item Use**: Use item by name or equipment slot
- **Targeted Item Use**: Use on target, focus, or self
- **Mouseover Item Use**: Use on mouseover targets
- **Conditional Item Use**: Combat state and modifier-based usage

## Usage

1. Open your spellbook and right-click any spell to see macro options
2. Open your character panel and right-click any equipped item to see macro options
3. Select a macro type from the organized menu
4. The macro is automatically created and picked up for placement on your action bars

## Installation

1. Download the addon
2. Extract to your `World of Warcraft/_retail_/Interface/AddOns/` folder
3. Restart WoW or type `/reload` if the game is running

## Compatibility

- Tested with World of Warcraft Retail
- Uses modern WoW API (C_AddOns, C_Spell, etc.)
- Automatically loads required Blizzard UI components

## Technical Details

The addon hooks into the spellbook and character frames after they're loaded, ensuring reliable functionality without requiring manual commands. It uses secure hook scripts to maintain compatibility with Blizzard's UI protection systems.