-- Debug context menu for testing Event Markers

local EventMarkerDebug = {}

-- Available icon types
EventMarkerDebug.iconTypes = {
    "raid.png",
    "crew.png",
    "defend.png",
    "friend.png",
    "loot.png",
    "roadblock.png",
    "tent.png",
    "thief.png"
}

-- Available colors
EventMarkerDebug.colors = {
    {name = "Red", color = {r=1, g=0.2, b=0.2}},
    {name = "Green", color = {r=0.2, g=1, b=0.2}},
    {name = "Blue", color = {r=0.2, g=0.2, b=1}},
    {name = "Yellow", color = {r=1, g=1, b=0.2}},
    {name = "Orange", color = {r=1, g=0.5, b=0.2}},
    {name = "Purple", color = {r=0.8, g=0.2, b=0.8}},
    {name = "White", color = {r=1, g=1, b=1}},
}

-- Test marker counter
EventMarkerDebug.markerCounter = 0

-- Create marker at player location with offset
local function createTestMarker(icon, distance, duration, color, desc)
    local player = getSpecificPlayer(0)
    if not player then return end
    
    -- Calculate position based on distance and random angle
    local angle = ZombRand(360)
    local radians = math.rad(angle)
    local posX = player:getX() + (distance * math.cos(radians))
    local posY = player:getY() + (distance * math.sin(radians))
    
    EventMarkerDebug.markerCounter = EventMarkerDebug.markerCounter + 1
    local markerID = "debug_marker_" .. EventMarkerDebug.markerCounter
    
    EventMarkerHandler.set(markerID, icon, duration, posX, posY, color, desc)
    
    player:Say("Created marker: " .. markerID)
end

-- Create marker at specific coordinates
local function createMarkerAtCoords(icon, x, y, duration, color, desc)
    EventMarkerDebug.markerCounter = EventMarkerDebug.markerCounter + 1
    local markerID = "debug_marker_" .. EventMarkerDebug.markerCounter
    
    EventMarkerHandler.set(markerID, icon, duration, x, y, color, desc)
    
    local player = getSpecificPlayer(0)
    if player then
        player:Say("Created marker at " .. x .. ", " .. y)
    end
end

-- Context menu creation
local function createDebugMenu(player, context, worldobjects, test)
    if test and ISWorldObjectContextMenu.Test then return true end
    
    local playerObj = getSpecificPlayer(0)
    if not playerObj then return end
    
    -- Main menu
    local mainMenu = context:addOption("Event Marker Debug", worldobjects, nil)
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(mainMenu, subMenu)
    
    -- Quick test markers
    local quickTest = subMenu:addOption("Quick Tests", worldobjects, nil)
    local quickTestMenu = ISContextMenu:getNew(subMenu)
    subMenu:addSubMenu(quickTest, quickTestMenu)
    
    quickTestMenu:addOption("Close Raid (50 tiles)", worldobjects, function()
        createTestMarker("raid.png", 50, 3600, {r=1, g=0.2, b=0.2}, "Raid Nearby")
    end)
    
    quickTestMenu:addOption("Medium Loot (150 tiles)", worldobjects, function()
        createTestMarker("loot.png", 150, 3600, {r=1, g=1, b=0.2}, "Loot Cache")
    end)
    
    quickTestMenu:addOption("Far Camp (400 tiles)", worldobjects, function()
        createTestMarker("tent.png", 400, 3600, {r=0.2, g=1, b=0.2}, "Base Camp")
    end)
    
    -- Create by icon type
    local iconMenu = subMenu:addOption("Create by Icon", worldobjects, nil)
    local iconSubMenu = ISContextMenu:getNew(subMenu)
    subMenu:addSubMenu(iconMenu, iconSubMenu)
    
    for i, iconFile in ipairs(EventMarkerDebug.iconTypes) do
        local iconName = iconFile:gsub(".png", "")
        iconSubMenu:addOption(iconName:gsub("^%l", string.upper), worldobjects, function()
            createTestMarker(iconFile, 200, 3600, {r=1, g=0.5, b=0.2}, iconName:upper())
        end)
    end
    
    -- Create at cursor position
    if test and test.square then
        local square = test.square
        local x = square:getX()
        local y = square:getY()
        
        local cursorMenu = subMenu:addOption("Create at Cursor (" .. x .. ", " .. y .. ")", worldobjects, nil)
        local cursorSubMenu = ISContextMenu:getNew(subMenu)
        subMenu:addSubMenu(cursorMenu, cursorSubMenu)
        
        for i, iconFile in ipairs(EventMarkerDebug.iconTypes) do
            local iconName = iconFile:gsub(".png", "")
            cursorSubMenu:addOption(iconName:gsub("^%l", string.upper), worldobjects, function()
                createMarkerAtCoords(iconFile, x, y, 3600, {r=0.2, g=0.8, b=1}, iconName:upper())
            end)
        end
    end
    
    -- Duration options
    local durationMenu = subMenu:addOption("Test Durations", worldobjects, nil)
    local durationSubMenu = ISContextMenu:getNew(subMenu)
    subMenu:addSubMenu(durationMenu, durationSubMenu)
    
    durationSubMenu:addOption("30 seconds", worldobjects, function()
        createTestMarker("crew.png", 100, 30, {r=0.2, g=1, b=0.2}, "30s Test")
    end)
    
    durationSubMenu:addOption("5 minutes", worldobjects, function()
        createTestMarker("crew.png", 100, 300, {r=0.2, g=1, b=0.2}, "5min Test")
    end)
    
    durationSubMenu:addOption("1 hour", worldobjects, function()
        createTestMarker("crew.png", 100, 3600, {r=0.2, g=1, b=0.2}, "1hr Test")
    end)
    
    -- Color tests
    local colorMenu = subMenu:addOption("Test Colors", worldobjects, nil)
    local colorSubMenu = ISContextMenu:getNew(subMenu)
    subMenu:addSubMenu(colorMenu, colorSubMenu)
    
    for i, colorData in ipairs(EventMarkerDebug.colors) do
        colorSubMenu:addOption(colorData.name, worldobjects, function()
            createTestMarker("defend.png", 150, 3600, colorData.color, colorData.name)
        end)
    end
    
    -- Management options
    subMenu:addOption("Remove All Markers", worldobjects, function()
        EventMarkerHandler.removeAll()
        playerObj:Say("All markers removed")
    end)
    
    -- Info
    subMenu:addOption("Show Active Markers", worldobjects, function()
        local count = 0
        for _ in pairs(EventMarkerHandler.markers) do
            count = count + 1
        end
        playerObj:Say("Active markers: " .. count)
    end)
end

Events.OnFillWorldObjectContextMenu.Add(createDebugMenu)