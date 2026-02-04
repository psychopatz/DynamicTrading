-- ==============================================================================
-- DT_V2_RadarManager.lua
-- NPC Radar Logic: Manages scanning, discovery, and coordinate tracking of traders.
-- ==============================================================================

DT_V2_RadarManager = {}
DT_V2_RadarManager.FoundTraders = {} -- Persistent list of UUIDs

-- Ranges based on device type or display name
DT_V2_RadarManager.Ranges = {
    ["Base.WalkieTalkie1"] = 500,
    ["Base.WalkieTalkie2"] = 750,
    ["Base.WalkieTalkie3"] = 1000,
    ["Base.WalkieTalkie4"] = 1250,
    ["Base.WalkieTalkie5"] = 1500,
    ["Base.HamRadio1"] = 2500,
    ["Base.HamRadio2"] = 5000,
    ["Base.ManPackRadio"] = 2000,
    ["Base.WalkieTalkieMakeShift"] = 400,
    ["Base.HamRadioMakeShift"] = 1500,
    -- World Object Name Mappings (Dynamic Names)
    ["Makeshift Ham Radio"] = 1500,
    ["Premium Technologies Ham Radio"] = 2500,
    ["US ARMY COMM. Ham Radio"] = 5000,
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

-- Scan for traders in vicinity
function DT_V2_RadarManager.Scan(player, device)
    if not player or not device then return end
    
    -- "Name Trick" Fix: Safely get the type/name (World objects don't have getFullType)
    local typeID = "Unknown"
    local deviceName = "Unknown"

    if device.getFullType then 
        typeID = device:getFullType() or "Unknown"
        deviceName = device:getName() or "Walkie-Talkie"
    elseif device.getDeviceData then
        local dd = device:getDeviceData()
        if dd then
            typeID = dd:getDeviceName() or "Unknown"
            deviceName = typeID
        end
    end

    -- Deep Sprite/Instance Inspection for World Objects
    if typeID == "Unknown" or typeID == "" then
        if device.getSprite and device:getSprite() then
            typeID = device:getSprite():getName() or "Unknown"
            deviceName = "Fixed Radio"
        end
    end
    
    -- Prioritize specific range lookup
    local range = DT_V2_RadarManager.Ranges[typeID] or DT_V2_RadarManager.Ranges[deviceName] or 500
    
    -- Robust Ham Radio detection fallback ONLY if specific range not found
    if range == 500 then
        local checkStr = string.lower(tostring(typeID) .. " " .. tostring(deviceName))
        if string.find(checkStr, "ham") or string.find(checkStr, "location_business_office") then 
            range = 2500
            deviceName = (deviceName == "Unknown") and "Ham Radio" or deviceName
        elseif string.find(checkStr, "military") or string.find(checkStr, "walkie") then 
            range = 1000 
        end
    end
    
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
