-- ==============================================================================
-- WorldTextDisplay_DebugMenu.lua
-- Debug Context Menu for WorldTextDisplay Integration with DTNPC
-- Build 42 Compatible
-- ==============================================================================

WorldTextDisplayDebug = WorldTextDisplayDebug or {}

-- Storage for NPC text IDs
WorldTextDisplayDebug.npcTexts = {}
WorldTextDisplayDebug.settings = {
    enabled = true,
    showHealth = false,
    showDistance = false,
    multiLine = false,
    autoUpdate = true
}

-- ==============================================================================
-- HELPER FUNCTIONS
-- ==============================================================================

local function getBrain(zombie)
    if not zombie then return nil end
    
    if DTNPCClient and DTNPCClient.GetBrain then
        local brain = DTNPCClient.GetBrain(zombie)
        if brain then return brain end
    end
    
    if DTNPC and DTNPC.GetBrain then
        return DTNPC.GetBrain(zombie)
    end
    
    return nil
end

local function calculateDistance(obj1, obj2)
    if not obj1 or not obj2 then return 9999 end
    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end

-- ==============================================================================
-- TEXT DISPLAY FUNCTIONS
-- ==============================================================================

function WorldTextDisplayDebug.createNPCText(npc, brain)
    if not npc or not brain then return nil end
    if not WorldTextDisplay then 
        print("[WorldTextDisplay] Module not loaded!")
        return nil 
    end
    
    local id = npc:getPersistentOutfitID() or npc:getID()
    
    -- Remove old text if exists
    WorldTextDisplayDebug.removeNPCText(id)
    
    local displayText = brain.name or "Unknown"
    local color = "WHITE"
    
    -- Determine color based on state
    if brain.isHostile then
        color = "RED"
    elseif brain.state == "Follow" then
        color = "CYAN"
    elseif brain.state == "Stay" or brain.state == "Guard" then
        color = "YELLOW"
    elseif brain.state == "GoTo" then
        color = "ORANGE"
    elseif brain.state == "Flee" then
        color = "PINK"
    elseif brain.state == "Attack" or brain.state == "AttackRange" then
        color = "DARK_RED"
    else
        color = "GREEN"
    end
    
    -- Add state to text
    if brain.state then
        displayText = displayText .. " [" .. brain.state .. "]"
    end
    
    local textId = WorldTextDisplay.addText(
        npc:getX(),
        npc:getY(),
        npc:getZ(),
        displayText,
        color,
        1.0,
        nil,
        1.0,
        0,
        -40
    )
    
    WorldTextDisplayDebug.npcTexts[id] = {
        textId = textId,
        npc = npc,
        brain = brain
    }
    
    return textId
end

function WorldTextDisplayDebug.createMultiLineNPCText(npc, brain)
    if not npc or not brain then return end
    if not WorldTextDisplay then return end
    
    local id = npc:getPersistentOutfitID() or npc:getID()
    WorldTextDisplayDebug.removeNPCText(id)
    
    local textIds = {}
    
    -- Name (top)
    textIds.name = WorldTextDisplay.addText(
        npc:getX(), npc:getY(), npc:getZ(),
        brain.name or "Unknown",
        "WHITE",
        1.0, nil, 1.0, 0, -50
    )
    
    -- State (middle)
    local stateColor = "GREEN"
    if brain.isHostile then stateColor = "RED"
    elseif brain.state == "Follow" then stateColor = "CYAN"
    elseif brain.state == "Stay" or brain.state == "Guard" then stateColor = "YELLOW"
    end
    
    textIds.state = WorldTextDisplay.addText(
        npc:getX(), npc:getY(), npc:getZ(),
        brain.state or "Idle",
        stateColor,
        1.0, nil, 0.9, 0, -35
    )
    
    -- Health bar (bottom) - if health tracking exists
    if brain.health and brain.maxHealth then
        local healthBars = math.floor((brain.health / brain.maxHealth) * 10)
        local healthText = "HP: " .. string.rep("█", healthBars) .. string.rep("░", 10 - healthBars)
        
        textIds.health = WorldTextDisplay.addText(
            npc:getX(), npc:getY(), npc:getZ(),
            healthText,
            "RED",
            1.0, nil, 0.8, 0, -20
        )
    end
    
    WorldTextDisplayDebug.npcTexts[id] = {
        textIds = textIds,
        npc = npc,
        brain = brain,
        multiLine = true
    }
end

function WorldTextDisplayDebug.updateNPCText(id)
    if not WorldTextDisplay then return end
    
    local data = WorldTextDisplayDebug.npcTexts[id]
    if not data or not data.npc or not data.brain then return end
    
    local npc = data.npc
    local brain = data.brain
    
    if data.multiLine and data.textIds then
        -- Update multi-line display
        for _, textId in pairs(data.textIds) do
            WorldTextDisplay.updatePosition(textId, npc:getX(), npc:getY(), npc:getZ())
        end
        
        -- Update state text and color
        local stateColor = "GREEN"
        if brain.isHostile then stateColor = "RED"
        elseif brain.state == "Follow" then stateColor = "CYAN"
        elseif brain.state == "Stay" or brain.state == "Guard" then stateColor = "YELLOW"
        end
        
        WorldTextDisplay.updateText(data.textIds.state, brain.state or "Idle")
        WorldTextDisplay.updateColor(data.textIds.state, stateColor)
        
        -- Update health if exists
        if data.textIds.health and brain.health and brain.maxHealth then
            local healthBars = math.floor((brain.health / brain.maxHealth) * 10)
            local healthText = "HP: " .. string.rep("█", healthBars) .. string.rep("░", 10 - healthBars)
            WorldTextDisplay.updateText(data.textIds.health, healthText)
        end
    else
        -- Update single-line display
        WorldTextDisplay.updatePosition(data.textId, npc:getX(), npc:getY(), npc:getZ())
        
        local displayText = brain.name or "Unknown"
        
        -- Add state
        if brain.state then
            displayText = displayText .. " [" .. brain.state .. "]"
        end
        
        -- Add distance if enabled
        if WorldTextDisplayDebug.settings.showDistance then
            local player = getSpecificPlayer(0)
            if player then
                local dist = calculateDistance(player, npc)
                displayText = displayText .. " (" .. math.floor(dist) .. "m)"
            end
        end
        
        -- Add health if enabled
        if WorldTextDisplayDebug.settings.showHealth and brain.health and brain.maxHealth then
            local healthPercent = math.floor((brain.health / brain.maxHealth) * 100)
            displayText = displayText .. " HP:" .. healthPercent .. "%"
        end
        
        WorldTextDisplay.updateText(data.textId, displayText)
        
        -- Update color based on state
        local color = "WHITE"
        if brain.isHostile then
            color = "RED"
        elseif brain.state == "Follow" then
            color = "CYAN"
        elseif brain.state == "Stay" or brain.state == "Guard" then
            color = "YELLOW"
        elseif brain.state == "GoTo" then
            color = "ORANGE"
        elseif brain.state == "Flee" then
            color = "PINK"
        elseif brain.state == "Attack" or brain.state == "AttackRange" then
            color = "DARK_RED"
        else
            color = "GREEN"
        end
        
        WorldTextDisplay.updateColor(data.textId, color)
    end
end

function WorldTextDisplayDebug.removeNPCText(id)
    if not WorldTextDisplay then return end
    
    local data = WorldTextDisplayDebug.npcTexts[id]
    if not data then return end
    
    if data.multiLine and data.textIds then
        for _, textId in pairs(data.textIds) do
            WorldTextDisplay.removeText(textId)
        end
    elseif data.textId then
        WorldTextDisplay.removeText(data.textId)
    end
    
    WorldTextDisplayDebug.npcTexts[id] = nil
end

function WorldTextDisplayDebug.toggleNPCText(npc)
    if not npc then return end
    
    local id = npc:getPersistentOutfitID() or npc:getID()
    local brain = getBrain(npc)
    if not brain then return end
    
    if WorldTextDisplayDebug.npcTexts[id] then
        WorldTextDisplayDebug.removeNPCText(id)
    else
        if WorldTextDisplayDebug.settings.multiLine then
            WorldTextDisplayDebug.createMultiLineNPCText(npc, brain)
        else
            WorldTextDisplayDebug.createNPCText(npc, brain)
        end
    end
end

function WorldTextDisplayDebug.showAllNPCs()
    if not WorldTextDisplay then return end
    
    local player = getSpecificPlayer(0)
    if not player then return end
    
    local count = 0
    
    -- Check DTNPCClient cache
    if DTNPCClient and DTNPCClient.NPCCache then
        for id, entry in pairs(DTNPCClient.NPCCache) do
            if entry.zombie and entry.brain then
                if WorldTextDisplayDebug.settings.multiLine then
                    WorldTextDisplayDebug.createMultiLineNPCText(entry.zombie, entry.brain)
                else
                    WorldTextDisplayDebug.createNPCText(entry.zombie, entry.brain)
                end
                count = count + 1
            end
        end
    end
    
    player:Say("Showing " .. count .. " NPCs")
end

function WorldTextDisplayDebug.hideAllNPCs()
    if not WorldTextDisplay then return end
    
    local count = 0
    for id, _ in pairs(WorldTextDisplayDebug.npcTexts) do
        WorldTextDisplayDebug.removeNPCText(id)
        count = count + 1
    end
    
    local player = getSpecificPlayer(0)
    if player then
        player:Say("Hid " .. count .. " NPCs")
    end
end

function WorldTextDisplayDebug.updateAll()
    for id, data in pairs(WorldTextDisplayDebug.npcTexts) do
        -- Refresh brain data
        if data.npc then
            local brain = getBrain(data.npc)
            if brain then
                data.brain = brain
                WorldTextDisplayDebug.updateNPCText(id)
            end
        end
    end
end

-- ==============================================================================
-- DEMO FUNCTIONS
-- ==============================================================================

function WorldTextDisplayDebug.spawnColorDemo(player)
    if not WorldTextDisplay then return end
    
    local px = player:getX()
    local py = player:getY()
    local pz = player:getZ()
    
    local colors = {"RED", "ORANGE", "YELLOW", "LIME", "GREEN", "CYAN", "BLUE", "PURPLE", "PINK"}
    local radius = 8
    
    for i, color in ipairs(colors) do
        local angle = (i / #colors) * math.pi * 2
        local x = px + math.cos(angle) * radius
        local y = py + math.sin(angle) * radius
        
        WorldTextDisplay.addText(
            x, y, pz,
            color,
            color,
            1.0, 10, 1.0, 0, -20
        )
    end
    
    WorldTextDisplay.addText(px, py, pz, "Color Demo", "GOLD", 1.0, 10, 1.2, 0, -35)
    player:Say("Color demo spawned (10s)")
end

function WorldTextDisplayDebug.showCoordinates(player)
    if not WorldTextDisplay then return end
    
    local x = math.floor(player:getX())
    local y = math.floor(player:getY())
    local z = player:getZ()
    
    local coordText = "Coords: " .. x .. ", " .. y .. ", " .. z
    WorldTextDisplay.addText(
        player:getX(),
        player:getY(),
        z,
        coordText,
        "CYAN",
        1.0, 5, 1.0, 0, -25
    )
    
    player:Say(coordText)
end

-- ==============================================================================
-- AUTO UPDATE LOOP
-- ==============================================================================

local updateCounter = 0
function WorldTextDisplayDebug.onTick()
    if not WorldTextDisplayDebug.settings.enabled or not WorldTextDisplayDebug.settings.autoUpdate then
        return
    end
    
    updateCounter = updateCounter + 1
    
    -- Update every 10 ticks (~0.5 seconds at 20 TPS)
    if updateCounter >= 10 then
        updateCounter = 0
        WorldTextDisplayDebug.updateAll()
    end
end

Events.OnTick.Add(WorldTextDisplayDebug.onTick)

-- ==============================================================================
-- CONTEXT MENU
-- ==============================================================================

function WorldTextDisplayDebug.OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    local player = getSpecificPlayer(playerNum)
    if not player or not WorldTextDisplay then return end

    local square = nil
    for _, obj in ipairs(worldObjects) do
        if obj:getSquare() then square = obj:getSquare(); break end
    end
    if not square then return end

    -- Find NPCs on this square
    local npcList = {}
    local processedIDs = {}

    local function scanSquare(sq)
        if not sq then return end
        local movingObjects = sq:getMovingObjects()
        for i = 0, movingObjects:size() - 1 do
            local obj = movingObjects:get(i)
            if instanceof(obj, "IsoZombie") then
                local brain = getBrain(obj)
                if brain then
                    local id = obj:getPersistentOutfitID() or obj:getID()
                    if not processedIDs[id] then
                        table.insert(npcList, obj)
                        processedIDs[id] = true
                    end
                end
            end
        end
    end

    scanSquare(square)
    local sx, sy, sz = square:getX(), square:getY(), square:getZ()
    for x = -1, 1 do
        for y = -1, 1 do
            if not (x == 0 and y == 0) then
                scanSquare(getCell():getGridSquare(sx + x, sy + y, sz))
            end
        end
    end

    -- Add per-NPC options
    if #npcList > 0 then
        for _, npc in ipairs(npcList) do
            local brain = getBrain(npc)
            local id = npc:getPersistentOutfitID() or npc:getID()
            local hasText = WorldTextDisplayDebug.npcTexts[id] ~= nil
            
            local npcName = brain and brain.name or "Unknown"
            local option = context:addOption("WorldText: " .. npcName)
            local subMenu = context:getNew(context)
            context:addSubMenu(option, subMenu)
            
            if hasText then
                subMenu:addOption("Hide Name Tag", npc, WorldTextDisplayDebug.toggleNPCText)
                subMenu:addOption("Update Display", nil, function()
                    local brain = getBrain(npc)
                    if brain then
                        WorldTextDisplayDebug.npcTexts[id].brain = brain
                        WorldTextDisplayDebug.updateNPCText(id)
                    end
                end)
            else
                subMenu:addOption("Show Name Tag", npc, WorldTextDisplayDebug.toggleNPCText)
            end
        end
    end

    -- Add global options
    local mainOption = context:addOption("WorldTextDisplay Debug")
    local mainMenu = context:getNew(context)
    context:addSubMenu(mainOption, mainMenu)
    
    -- NPC Display Options
    local npcOption = mainMenu:addOption("NPC Display")
    local npcMenu = mainMenu:getNew(mainMenu)
    context:addSubMenu(npcOption, npcMenu)
    
    npcMenu:addOption("Show All NPCs", player, WorldTextDisplayDebug.showAllNPCs)
    npcMenu:addOption("Hide All NPCs", player, WorldTextDisplayDebug.hideAllNPCs)
    npcMenu:addOption("Update All", nil, WorldTextDisplayDebug.updateAll)
    
    -- Settings
    local settingsOption = mainMenu:addOption("Settings")
    local settingsMenu = mainMenu:getNew(mainMenu)
    context:addSubMenu(settingsOption, settingsMenu)
    
    local enabledText = WorldTextDisplayDebug.settings.enabled and "✓" or "✗"
    settingsMenu:addOption(enabledText .. " Enabled", nil, function()
        WorldTextDisplayDebug.settings.enabled = not WorldTextDisplayDebug.settings.enabled
        if not WorldTextDisplayDebug.settings.enabled then
            WorldTextDisplayDebug.hideAllNPCs()
        end
    end)
    
    local autoText = WorldTextDisplayDebug.settings.autoUpdate and "✓" or "✗"
    settingsMenu:addOption(autoText .. " Auto-Update", nil, function()
        WorldTextDisplayDebug.settings.autoUpdate = not WorldTextDisplayDebug.settings.autoUpdate
    end)
    
    local multiText = WorldTextDisplayDebug.settings.multiLine and "✓" or "✗"
    settingsMenu:addOption(multiText .. " Multi-Line Mode", nil, function()
        WorldTextDisplayDebug.settings.multiLine = not WorldTextDisplayDebug.settings.multiLine
    end)
    
    local healthText = WorldTextDisplayDebug.settings.showHealth and "✓" or "✗"
    settingsMenu:addOption(healthText .. " Show Health", nil, function()
        WorldTextDisplayDebug.settings.showHealth = not WorldTextDisplayDebug.settings.showHealth
    end)
    
    local distText = WorldTextDisplayDebug.settings.showDistance and "✓" or "✗"
    settingsMenu:addOption(distText .. " Show Distance", nil, function()
        WorldTextDisplayDebug.settings.showDistance = not WorldTextDisplayDebug.settings.showDistance
    end)
    
    -- Demo Options
    local demoOption = mainMenu:addOption("Demos & Tests")
    local demoMenu = mainMenu:getNew(mainMenu)
    context:addSubMenu(demoOption, demoMenu)
    
    demoMenu:addOption("Color Demo (10s)", player, WorldTextDisplayDebug.spawnColorDemo)
    demoMenu:addOption("Show My Coordinates", player, WorldTextDisplayDebug.showCoordinates)
    demoMenu:addOption("Clear All Texts", nil, function()
        WorldTextDisplay.clearAll()
        WorldTextDisplayDebug.npcTexts = {}
        player:Say("Cleared all world texts")
    end)
    
    -- Info
    mainMenu:addOption("Active Texts: " .. WorldTextDisplay.getCount(), nil, function() end)
end

Events.OnFillWorldObjectContextMenu.Add(WorldTextDisplayDebug.OnFillWorldObjectContextMenu)

print("WorldTextDisplay Debug Menu loaded!")
print("Right-click anywhere for WorldTextDisplay options")