-- ==============================================================================
-- DT_V2_RadarManager.lua
-- NPC Radar Logic: Manages scanning, discovery, and coordinate tracking of traders.
-- ==============================================================================

DT_V2_RadarManager = {}
DT_V2_RadarManager.FoundTraders = {} -- Persistent list of UUIDs

-- Ranges based on device type or display name
DT_V2_RadarManager.Ranges = {
    ["Base.WalkieTalkie1"] = 750,
    ["Base.WalkieTalkie2"] = 2000,
    ["Base.WalkieTalkie3"] = 4000,
    ["Base.WalkieTalkie4"] = 8000,
    ["Base.WalkieTalkie5"] = 10000,
    ["Base.HamRadio1"] = 12000,
    ["Base.HamRadio2"] = 15000,
    ["Base.ManPackRadio"] = 12000,
    ["Base.WalkieTalkieMakeShift"] = 1000,
    ["Base.HamRadioMakeShift"] = 10000,
    -- Tier Mappings (Matches getDeviceName())
    ["Makeshift Ham Radio"] = 10000,
    ["US ARMY COMM. Ham Radio"] = 15000,
    ["Premium Technologies Ham Radio"] = 12000,
}

function DT_V2_RadarManager.Init()
    local data = ModData.getOrCreate("DT_V2_RadarFound")
    DT_V2_RadarManager.FoundTraders = data
    print("[DT_RADAR] Manager Initialized. Traders in cache: " .. DT_V2_RadarManager.GetCount())
end

function DT_V2_RadarManager.GetCount()
    local count = 0
    for _ in pairs(DT_V2_RadarManager.FoundTraders) do count = count + 1 end
    return count
end

-- Determine the best available coordinate for a trader
function DT_V2_RadarManager.GetTraderCoords(uuid)
    -- 1. Check Live NPCs (Spawned in World)
    local cell = getCell()
    if cell then
        local zombieList = cell:getZombieList()
        if zombieList then
            for i = 0, zombieList:size() - 1 do
                local zombie = zombieList:get(i)
                if zombie then
                    local modData = zombie:getModData()
                    if modData.DTNPC_UUID == uuid then
                        return zombie:getX(), zombie:getY(), zombie:getZ(), true -- true = Live
                    end
                end
            end
        end
    end

    -- 2. Fallback to Roster Data (Cached or Global)
    local rosterData = ModData.get("DynamicTrading_Roster")
    if rosterData and rosterData.Souls and rosterData.Souls[uuid] then
        local soul = rosterData.Souls[uuid]
        local x = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
        local y = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
        local z = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0
        return x, y, z, false -- false = Cached/Static
    end

    return nil, nil, nil, false
end

-- Centralized Device Info Extraction
function DT_V2_RadarManager.GetDeviceInfo(device)
    if not device then return "Unknown Device", 0 end

    local name = "Unknown Device"
    local typeID = "Unknown"
    local range = 0

    -- 1. Try to get a clean name and type
    if device.getDisplayName then
        name = device:getDisplayName() or name -- Best for InventoryItems
    elseif device.getName then
        name = device:getName() or name
    end
    
    if device.getFullType then
        typeID = device:getFullType() or typeID
    elseif device.getDeviceData then
        local dd = device:getDeviceData()
        if dd then 
            local rawName = dd:getDeviceName()
            if rawName and rawName ~= "" then
                typeID = rawName
                -- If we still don't have a good display name, use the device data name
                if name == "Unknown Device" then
                    name = rawName
                end
            end
        end
    end
    
    -- 2. World Object Fallbacks (Sprites)
    if name == "Unknown Device" and device.getSprite then
        local sprite = device:getSprite()
        if sprite and sprite:getName() then
             -- Try to infer from sprite name if strictly necessary
             -- But don't overwrite typeID if we already have a specific one
             if typeID == "Unknown" then typeID = sprite:getName() end
        end
    end

    -- 3. Determine Range based on Name or Type
    -- Check specific TypeID first (e.g. Base.HamRadioMakeShift)
    if DT_V2_RadarManager.Ranges[typeID] then
        range = DT_V2_RadarManager.Ranges[typeID]
    elseif DT_V2_RadarManager.Ranges[name] then
        range = DT_V2_RadarManager.Ranges[name]
    else
        -- 4. Fuzzy Matching / Heuristics
        -- Ensure neither is nil for string ops
        local safeType = typeID or ""
        local safeName = name or ""
        local checkStr = string.lower(tostring(safeType) .. " " .. tostring(safeName))
        
        if string.find(checkStr, "ham") or string.find(checkStr, "location_business_office") then
            range = 2500
            if name == "Unknown Device" then name = "Ham Radio" end
        elseif string.find(checkStr, "walkie") then
            range = 750
            if name == "Unknown Device" then name = "Walkie Talkie" end
        elseif string.find(checkStr, "manpack") or string.find(checkStr, "military") then
            range = 2000
             if name == "Unknown Device" then name = "Military Radio" end
        else
            range = 500 -- Default fallback
        end
    end

    return name, range
end

-- Scan for traders in vicinity
function DT_V2_RadarManager.Scan(player, device)
    if not player or not device then return end
    
    local deviceName, range = DT_V2_RadarManager.GetDeviceInfo(device)
    
    print("[DT_RADAR] [V3.0] Starting scan with " .. tostring(deviceName) .. " (Range: " .. tostring(range) .. ")")
    
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then
        player:Say("Static... no frequencies found.")
        return
    end

    local foundNew = false
    local px, py = player:getX(), player:getY()
    
    -- Filter Roster for "Trading" souls within range
    for uuid, soul in pairs(rosterData.Souls) do
        if soul.status == "Trading" then
            local tx, ty = soul.lastX, soul.lastY
            if tx and ty then
                local dx = tx - px
                local dy = ty - py
                local dist = math.sqrt(dx*dx + dy*dy)
                
                if dist <= range then
                    -- Proximity check passed! Now add random chance.
                    -- Skill bonus
                    local elecLevel = player:getPerkLevel(Perks.Electricity)
                    local chance = 20 + (elecLevel * 5) -- 20% to 70% chance
                    
                    if ZombRand(100) < chance then
                        if not DT_V2_RadarManager.FoundTraders[uuid] then
                            DT_V2_RadarManager.FoundTraders[uuid] = {
                                name = soul.name or "Unknown Trader",
                                faction = soul.factionID or "Independent",
                                discoveredAt = getGameTime():getWorldAgeHours()
                            }
                            foundNew = true
                            print("[DT_RADAR] Discovered trader: " .. soul.name .. " (UUID: " .. uuid .. ")")
                        end
                    end
                end
            end
        end
    end

    -- Cleanup expired traders
    DT_V2_RadarManager.Cleanup()

    if foundNew then
        player:Say("Found something! Frequency locked.")
        -- Trigger UI Refresh if open
        if DT_V2_RadarWindow and DT_V2_RadarWindow.instance then
            DT_V2_RadarWindow.instance:refresh()
        end
    else
        player:Say("Nothing but static...")
    end
end

function DT_V2_RadarManager.Cleanup()
    local rosterData = ModData.get("DynamicTrading_Roster")
    if not rosterData or not rosterData.Souls then return end
    
    local toRemove = {}
    for uuid, _ in pairs(DT_V2_RadarManager.FoundTraders) do
        local soul = rosterData.Souls[uuid]
        if not soul or soul.status ~= "Trading" then
            table.insert(toRemove, uuid)
        end
    end
    
    for _, uuid in ipairs(toRemove) do
        print("[DT_RADAR] Removing expired/inactive trader from radar: " .. uuid)
        DT_V2_RadarManager.FoundTraders[uuid] = nil
    end
end

Events.OnGameStart.Add(DT_V2_RadarManager.Init)
