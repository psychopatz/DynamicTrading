--[[
    World Text Display - Demo Script
    This script demonstrates the mod working in-game
    Press 'F2' to spawn demo texts near the player
    Press 'F3' to clear all demo texts
]]--

WorldTextDisplayDemo = WorldTextDisplayDemo or {}
WorldTextDisplayDemo.demoIds = {}

-- Spawn demo texts near player
function WorldTextDisplayDemo.spawnDemoTexts()
    local player = getSpecificPlayer(0)
    if not player then 
        print("WorldTextDisplay Demo: No player found!")
        return 
    end
    
    local px = player:getX()
    local py = player:getY()
    local pz = player:getZ()
    
    -- Clear previous demo
    WorldTextDisplayDemo.clearDemoTexts()
    
    print("WorldTextDisplay Demo: Spawning demo texts around player...")
    
    -- Create a circle of colored texts
    local colors = {"RED", "ORANGE", "YELLOW", "LIME", "GREEN", "CYAN", "BLUE", "PURPLE", "PINK"}
    local radius = 5
    
    for i, color in ipairs(colors) do
        local angle = (i / #colors) * math.pi * 2
        local x = px + math.cos(angle) * radius
        local y = py + math.sin(angle) * radius
        
        local id = WorldTextDisplay.addText(
            x, y, pz,
            color .. " Text",
            color,
            1.0,
            nil,
            1.0,
            0,
            -20
        )
        table.insert(WorldTextDisplayDemo.demoIds, id)
    end
    
    -- Center text with animation info
    local centerId = WorldTextDisplay.addText(
        px, py, pz,
        "🎨 WorldTextDisplay Demo 🎨",
        "GOLD",
        1.0,
        nil,
        1.2,
        0,
        -40
    )
    table.insert(WorldTextDisplayDemo.demoIds, centerId)
    
    -- Info text
    local infoId = WorldTextDisplay.addText(
        px, py, pz,
        "Press F3 to clear",
        "WHITE",
        0.7,
        nil,
        0.8,
        0,
        -55
    )
    table.insert(WorldTextDisplayDemo.demoIds, infoId)
    
    -- Temporary text
    WorldTextDisplay.addText(
        px + 3, py, pz,
        "⏱ Temporary (5s)",
        "ORANGE",
        1.0,
        5,
        1.0,
        0,
        -30
    )
    
    -- Semi-transparent text
    local transparentId = WorldTextDisplay.addText(
        px - 3, py, pz,
        "👻 50% Transparent",
        "CYAN",
        0.5,
        nil,
        1.0,
        0,
        -30
    )
    table.insert(WorldTextDisplayDemo.demoIds, transparentId)
    
    print("WorldTextDisplay Demo: Spawned " .. #WorldTextDisplayDemo.demoIds .. " texts!")
    print("WorldTextDisplay Demo: Active text count: " .. WorldTextDisplay.getCount())
end

-- Clear all demo texts
function WorldTextDisplayDemo.clearDemoTexts()
    for _, id in ipairs(WorldTextDisplayDemo.demoIds) do
        WorldTextDisplay.removeText(id)
    end
    WorldTextDisplayDemo.demoIds = {}
    print("WorldTextDisplay Demo: Cleared all demo texts")
    print("WorldTextDisplay Demo: Active text count: " .. WorldTextDisplay.getCount())
end

-- Example: Animated text that changes over time
WorldTextDisplayDemo.animatedTextId = nil
WorldTextDisplayDemo.animationFrame = 0

function WorldTextDisplayDemo.updateAnimation()
    local player = getSpecificPlayer(0)
    if not player then return end
    
    WorldTextDisplayDemo.animationFrame = WorldTextDisplayDemo.animationFrame + 1
    
    -- Create animated text if it doesn't exist
    if not WorldTextDisplayDemo.animatedTextId then
        WorldTextDisplayDemo.animatedTextId = WorldTextDisplay.addText(
            player:getX() + 8,
            player:getY(),
            player:getZ(),
            "Loading",
            "CYAN",
            1.0,
            nil,
            1.0,
            0,
            -25
        )
    end
    
    -- Update every 10 frames
    if WorldTextDisplayDemo.animationFrame % 10 == 0 then
        local dots = string.rep(".", (WorldTextDisplayDemo.animationFrame / 10) % 4)
        WorldTextDisplay.updateText(WorldTextDisplayDemo.animatedTextId, "Loading" .. dots)
        
        -- Cycle colors
        local colors = {"CYAN", "BLUE", "PURPLE", "PINK"}
        local colorIndex = math.floor(WorldTextDisplayDemo.animationFrame / 40) % #colors + 1
        WorldTextDisplay.updateColor(WorldTextDisplayDemo.animatedTextId, colors[colorIndex])
    end
end

-- Key press handler
function WorldTextDisplayDemo.onKeyPressed(key)
    -- F2 = 61
    if key == 61 then
        WorldTextDisplayDemo.spawnDemoTexts()
    end
    
    -- F3 = 62
    if key == 62 then
        WorldTextDisplayDemo.clearDemoTexts()
    end
    
    -- F4 = 63 - Toggle animation
    if key == 63 then
        if WorldTextDisplayDemo.animatedTextId then
            WorldTextDisplay.removeText(WorldTextDisplayDemo.animatedTextId)
            WorldTextDisplayDemo.animatedTextId = nil
            print("WorldTextDisplay Demo: Animation stopped")
        else
            print("WorldTextDisplay Demo: Animation started (near player)")
        end
    end
end

-- Register event handlers
Events.OnKeyPressed.Add(WorldTextDisplayDemo.onKeyPressed)
Events.OnTick.Add(WorldTextDisplayDemo.updateAnimation)

print("===========================================")
print("WorldTextDisplay Demo loaded!")
print("Press F2 to spawn demo texts near player")
print("Press F3 to clear all demo texts")
print("Press F4 to toggle animated text")
print("===========================================")
