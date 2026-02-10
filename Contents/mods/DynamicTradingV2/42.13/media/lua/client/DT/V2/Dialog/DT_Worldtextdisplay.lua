--[[
    World Text Display Module
    A modular system for displaying text at world coordinates with color coding
    Perfect for NPC mods, markers, and location-based text
]]--

WorldTextDisplay = WorldTextDisplay or {}

-- Color presets (RGB format 0-1)
WorldTextDisplay.Colors = {
    WHITE = {r = 1.0, g = 1.0, b = 1.0},
    RED = {r = 1.0, g = 0.0, b = 0.0},
    GREEN = {r = 0.0, g = 1.0, b = 0.0},
    BLUE = {r = 0.0, g = 0.5, b = 1.0},
    YELLOW = {r = 1.0, g = 1.0, b = 0.0},
    ORANGE = {r = 1.0, g = 0.65, b = 0.0},
    PURPLE = {r = 0.8, g = 0.0, b = 1.0},
    CYAN = {r = 0.0, g = 1.0, b = 1.0},
    PINK = {r = 1.0, g = 0.4, b = 0.7},
    LIME = {r = 0.5, g = 1.0, b = 0.0},
    GOLD = {r = 1.0, g = 0.84, b = 0.0},
    SILVER = {r = 0.75, g = 0.75, b = 0.75},
    GRAY = {r = 0.5, g = 0.5, b = 0.5},
    DARK_RED = {r = 0.5, g = 0.0, b = 0.0},
    DARK_GREEN = {r = 0.0, g = 0.5, b = 0.0},
    DARK_BLUE = {r = 0.0, g = 0.0, b = 0.5}
}

-- Active text displays storage
WorldTextDisplay.activeTexts = {}
WorldTextDisplay.nextId = 1

--[[
    Create a new text display at world coordinates
    @param x: X coordinate in world
    @param y: Y coordinate in world (not used for rendering but stored)
    @param z: Z coordinate in world (floor level)
    @param text: The text to display
    @param color: Color table {r, g, b} or color name string (optional, defaults to WHITE)
    @param alpha: Transparency 0-1 (optional, defaults to 1.0)
    @param duration: How long to display in seconds (optional, nil = permanent)
    @param scale: Text scale multiplier (optional, defaults to 1.0)
    @param offsetX: X offset from world position in pixels (optional, defaults to 0)
    @param offsetY: Y offset from world position in pixels (optional, defaults to 0)
    @return: ID of the created text display
]]--
function WorldTextDisplay.addText(x, y, z, text, color, alpha, duration, scale, offsetX, offsetY)
    local textData = {
        id = WorldTextDisplay.nextId,
        x = x,
        y = y,
        z = z or 0,
        text = text or "",
        alpha = alpha or 1.0,
        scale = scale or 1.0,
        offsetX = offsetX or 0,
        offsetY = offsetY or 0,
        createdTime = getTimestamp()
    }
    
    -- Handle color parameter
    if type(color) == "string" then
        textData.color = WorldTextDisplay.Colors[color] or WorldTextDisplay.Colors.WHITE
    elseif type(color) == "table" then
        textData.color = color
    else
        textData.color = WorldTextDisplay.Colors.WHITE
    end
    
    -- Handle duration
    if duration and duration > 0 then
        textData.expiresAt = getTimestamp() + duration
    end
    
    WorldTextDisplay.activeTexts[WorldTextDisplay.nextId] = textData
    WorldTextDisplay.nextId = WorldTextDisplay.nextId + 1
    
    return textData.id
end

--[[
    Remove a text display by ID
    @param id: The ID returned from addText
]]--
function WorldTextDisplay.removeText(id)
    if WorldTextDisplay.activeTexts[id] then
        WorldTextDisplay.activeTexts[id] = nil
        return true
    end
    return false
end

--[[
    Update text content for existing display
    @param id: The text display ID
    @param newText: New text to display
]]--
function WorldTextDisplay.updateText(id, newText)
    if WorldTextDisplay.activeTexts[id] then
        WorldTextDisplay.activeTexts[id].text = newText
        return true
    end
    return false
end

--[[
    Update text color for existing display
    @param id: The text display ID
    @param color: Color table {r, g, b} or color name string
]]--
function WorldTextDisplay.updateColor(id, color)
    if WorldTextDisplay.activeTexts[id] then
        if type(color) == "string" then
            WorldTextDisplay.activeTexts[id].color = WorldTextDisplay.Colors[color] or WorldTextDisplay.Colors.WHITE
        elseif type(color) == "table" then
            WorldTextDisplay.activeTexts[id].color = color
        end
        return true
    end
    return false
end

--[[
    Update text position
    @param id: The text display ID
    @param x, y, z: New coordinates
]]--
function WorldTextDisplay.updatePosition(id, x, y, z)
    if WorldTextDisplay.activeTexts[id] then
        WorldTextDisplay.activeTexts[id].x = x
        WorldTextDisplay.activeTexts[id].y = y
        WorldTextDisplay.activeTexts[id].z = z or WorldTextDisplay.activeTexts[id].z
        return true
    end
    return false
end

--[[
    Clear all text displays
]]--
function WorldTextDisplay.clearAll()
    WorldTextDisplay.activeTexts = {}
end

--[[
    Get count of active text displays
]]--
function WorldTextDisplay.getCount()
    local count = 0
    for _ in pairs(WorldTextDisplay.activeTexts) do
        count = count + 1
    end
    return count
end

--[[
    Create a custom color
    @param r, g, b: RGB values (0-1)
    @return: Color table
]]--
function WorldTextDisplay.createColor(r, g, b)
    return {
        r = math.max(0, math.min(1, r)),
        g = math.max(0, math.min(1, g)),
        b = math.max(0, math.min(1, b))
    }
end

-- Render function called every frame
function WorldTextDisplay.render()
    local player = getSpecificPlayer(0)
    if not player then return end
    
    local playerX = player:getX()
    local playerY = player:getY()
    local playerZ = player:getZ()
    
    local currentTime = getTimestamp()
    local toRemove = {}
    
    -- Iterate through all active texts
    for id, textData in pairs(WorldTextDisplay.activeTexts) do
        -- Check if expired
        if textData.expiresAt and currentTime >= textData.expiresAt then
            table.insert(toRemove, id)
        else
            -- Only render if on same floor level or close enough
            local zDiff = math.abs(textData.z - playerZ)
            if zDiff <= 1 then
                -- Convert world coordinates to screen coordinates
                local screenX = IsoUtils.XToScreen(textData.x, textData.y, textData.z, 0)
                local screenY = IsoUtils.YToScreen(textData.x, textData.y, textData.z, 0)
                
                -- Apply offsets
                screenX = screenX + textData.offsetX
                screenY = screenY + textData.offsetY
                
                -- Calculate distance-based alpha falloff (optional)
                local distance = math.sqrt((textData.x - playerX)^2 + (textData.y - playerY)^2)
                local distanceAlpha = 1.0
                if distance > 20 then
                    distanceAlpha = math.max(0, 1.0 - ((distance - 20) / 30))
                end
                
                local finalAlpha = textData.alpha * distanceAlpha
                
                -- Only render if visible
                if finalAlpha > 0.05 and screenX > -100 and screenX < getCore():getScreenWidth() + 100 
                   and screenY > -100 and screenY < getCore():getScreenHeight() + 100 then
                    
                    -- Set color and alpha
                    local color = textData.color
                    local r = color.r or 1
                    local g = color.g or 1
                    local b = color.b or 1
                    
                    -- Draw text with outline for better visibility
                    local scale = textData.scale
                    
                    -- Black outline
                    for dx = -1, 1 do
                        for dy = -1, 1 do
                            if dx ~= 0 or dy ~= 0 then
                                drawText(textData.text, screenX + dx, screenY + dy, 0, 0, 0, finalAlpha * 0.8, UIFont.Medium)
                            end
                        end
                    end
                    
                    -- Main text
                    drawText(textData.text, screenX, screenY, r, g, b, finalAlpha, UIFont.Medium)
                end
            end
        end
    end
    
    -- Remove expired texts
    for _, id in ipairs(toRemove) do
        WorldTextDisplay.activeTexts[id] = nil
    end
end

-- Register the render callback
Events.OnPostRender.Add(WorldTextDisplay.render)

print("WorldTextDisplay module loaded successfully!")
