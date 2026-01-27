--[[
    World Text Display - Example Usage
    This file demonstrates how to use the WorldTextDisplay module
    Remove or comment out this file in production
]]--

-- Example 1: Simple text display at coordinates
local function exampleSimpleText()
    -- Display white text at coordinates (100, 100, 0)
    local id = WorldTextDisplay.addText(100, 100, 0, "Hello World!")
    print("Created text with ID: " .. id)
end

-- Example 2: Colored text with preset colors
local function exampleColoredText()
    -- Red text
    WorldTextDisplay.addText(105, 100, 0, "Danger Zone!", "RED")
    
    -- Green text
    WorldTextDisplay.addText(110, 100, 0, "Safe Area", "GREEN")
    
    -- Yellow text
    WorldTextDisplay.addText(115, 100, 0, "Caution", "YELLOW")
end

-- Example 3: Temporary text (disappears after duration)
local function exampleTemporaryText()
    -- Display text for 5 seconds
    WorldTextDisplay.addText(120, 100, 0, "This disappears!", "ORANGE", 1.0, 5)
end

-- Example 4: Custom color
local function exampleCustomColor()
    -- Create a custom purple color (R, G, B values from 0 to 1)
    local customColor = WorldTextDisplay.createColor(0.7, 0.3, 0.9)
    WorldTextDisplay.addText(125, 100, 0, "Custom Color", customColor)
end

-- Example 5: Semi-transparent text
local function exampleTransparentText()
    -- Text with 50% transparency (alpha = 0.5)
    WorldTextDisplay.addText(130, 100, 0, "Semi-Transparent", "CYAN", 0.5)
end

-- Example 6: Updating text dynamically
local function exampleDynamicText()
    local id = WorldTextDisplay.addText(135, 100, 0, "Initial Text", "WHITE")
    
    -- Update after 2 seconds
    Events.OnTick.Add(function()
        WorldTextDisplay.updateText(id, "Updated Text!")
        WorldTextDisplay.updateColor(id, "GREEN")
    end)
end

-- Example 7: NPC Integration Example
-- This is how you might use it with an NPC mod
local function exampleNPCIntegration()
    -- Assume you have an NPC object with getX(), getY(), getZ() methods
    local npcTextId = nil
    
    local function updateNPCText(npc)
        if npcTextId then
            -- Update existing text position to follow NPC
            WorldTextDisplay.updatePosition(npcTextId, npc:getX(), npc:getY(), npc:getZ())
            WorldTextDisplay.updateText(npcTextId, npc:getName() .. " [HP: " .. npc:getHealth() .. "]")
            
            -- Change color based on health
            if npc:getHealth() < 30 then
                WorldTextDisplay.updateColor(npcTextId, "RED")
            elseif npc:getHealth() < 70 then
                WorldTextDisplay.updateColor(npcTextId, "YELLOW")
            else
                WorldTextDisplay.updateColor(npcTextId, "GREEN")
            end
        else
            -- Create new text above NPC
            npcTextId = WorldTextDisplay.addText(
                npc:getX(), 
                npc:getY(), 
                npc:getZ(),
                npc:getName(),
                "WHITE",
                1.0,      -- alpha
                nil,      -- duration (nil = permanent)
                1.0,      -- scale
                0,        -- offsetX
                -30       -- offsetY (raise above NPC)
            )
        end
    end
    
    -- Call updateNPCText(npc) every frame or when NPC updates
end

-- Example 8: Multiple texts for one NPC (name + status)
local function exampleMultiLineNPC()
    local x, y, z = 140, 100, 0
    
    -- Name above NPC
    WorldTextDisplay.addText(x, y, z, "John Doe", "WHITE", 1.0, nil, 1.0, 0, -40)
    
    -- Status below name
    WorldTextDisplay.addText(x, y, z, "Following", "GREEN", 1.0, nil, 0.8, 0, -25)
    
    -- Health bar representation
    WorldTextDisplay.addText(x, y, z, "HP: ████████░░", "RED", 1.0, nil, 0.7, 0, -10)
end

-- Example 9: Location markers
local function exampleLocationMarkers()
    -- Mark important locations
    WorldTextDisplay.addText(150, 120, 0, "🏠 Safe House", "LIME")
    WorldTextDisplay.addText(160, 130, 0, "⚠ Zombie Horde", "RED")
    WorldTextDisplay.addText(170, 140, 0, "📦 Loot Stash", "GOLD")
end

-- Example 10: Getting all active texts info
local function exampleGetInfo()
    print("Active text displays: " .. WorldTextDisplay.getCount())
end

-- Example 11: Clear all texts
local function exampleClearAll()
    WorldTextDisplay.clearAll()
    print("All text displays cleared")
end

--[[
    INTEGRATION WITH YOUR NPC MOD:
    
    1. When spawning an NPC:
       npc.textId = WorldTextDisplay.addText(npc:getX(), npc:getY(), npc:getZ(), npc.name, "WHITE")
    
    2. In your NPC update loop:
       WorldTextDisplay.updatePosition(npc.textId, npc:getX(), npc:getY(), npc:getZ())
       WorldTextDisplay.updateText(npc.textId, npc.name .. " [" .. npc.state .. "]")
    
    3. When NPC is removed:
       WorldTextDisplay.removeText(npc.textId)
    
    4. For combat state changes:
       if npc.inCombat then
           WorldTextDisplay.updateColor(npc.textId, "RED")
       else
           WorldTextDisplay.updateColor(npc.textId, "WHITE")
       end
]]--

-- Uncomment to test examples on game start
-- Events.OnGameStart.Add(function()
--     exampleSimpleText()
--     exampleColoredText()
--     print("WorldTextDisplay examples loaded!")
-- end)

print("WorldTextDisplay examples loaded!")
