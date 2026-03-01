-- ==============================================================================
-- DT_V2_RadarManager.lua
-- NPC Radar Logic: Manages scanning, discovery, and coordinate tracking of traders.
-- ==============================================================================

-- We require the new handler to delegate location tasks
require "DT/V2/Radio/DT_V2_RadarLocationHandler"

DT_V2_RadarManager = {}
DT_V2_RadarManager.FoundTraders = {} -- Persistent list of UUIDs
DT_V2_RadarManager.ClientRoster = nil -- Local cache of server roster for MP
DT_V2_RadarManager.ClientFactions = nil -- Local cache of server factions for MP

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
    -- Tier Mappings
    ["Makeshift Ham Radio"] = 10000,
    ["US ARMY COMM. Ham Radio"] = 15000,
    ["Premium Technologies Ham Radio"] = 12000,
}

-- ==============================================================================
-- INITIALIZATION
-- ==============================================================================
function DT_V2_RadarManager.Init()
    local data = ModData.getOrCreate("DT_V2_RadarFound")
    DT_V2_RadarManager.FoundTraders = data
    
    -- In SP, we can just grab the roster directly. 
    -- In MP, we start nil and wait for sync.
    if not isClient() then 
        DT_V2_RadarManager.ClientRoster = ModData.get("DynamicTrading_Roster")
        DT_V2_RadarManager.ClientFactions = ModData.get("DynamicTrading_Factions")
    end

    print("[DT_RADAR] Manager Initialized. Traders in cache: " .. DT_V2_RadarManager.GetCount())
end

-- ==============================================================================
-- NETWORK SYNC (MP)
-- ==============================================================================
-- Request fresh roster data from server (MP Only)
function DT_V2_RadarManager.RequestRoster()
    if isServer() then return end
    print("[DT_RADAR] Requesting fresh Roster from Server...")
    sendClientCommand(getSpecificPlayer(0), "DynamicTrading_V2", "RequestRoster", {})
end

-- Handle incoming roster/faction data from Server
local function OnServerCommand(module, command, arguments)
    if module == "DynamicTrading_V2" and command == "SyncRoster" then
        print("[DT_RADAR] Received Roster & Faction Sync from Server.")
        DT_V2_RadarManager.ClientRoster = arguments.roster
        DT_V2_RadarManager.ClientFactions = arguments.factions
    end
end
Events.OnServerCommand.Add(OnServerCommand)

function DT_V2_RadarManager.GetCount()
    local count = 0
    for _ in pairs(DT_V2_RadarManager.FoundTraders) do count = count + 1 end
    return count
end

-- ==============================================================================
-- COORDINATE LOGIC
-- ==============================================================================
-- Determine the best available coordinate for a trader
function DT_V2_RadarManager.GetTraderCoords(uuid)
    -- 1. Check Live NPCs (Spawned in World) - Most Accurate
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

    -- 2. Fallback to Roster Data (Cached or Global) - Virtual Location
    local rosterData = DT_V2_RadarManager.ClientRoster
    if not isClient() and not rosterData then
         rosterData = ModData.get("DynamicTrading_Roster")
    end
    
    if rosterData and rosterData.Souls and rosterData.Souls[uuid] then
        local soul = rosterData.Souls[uuid]
        -- Use last known location, or home coords if never seen
        local x = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
        local y = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
        local z = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0
        return x, y, z, false -- false = Cached/Static
    end

    return nil, nil, nil, false
end

-- ==============================================================================
-- DEVICE INFO
-- ==============================================================================
-- Centralized Device Info Extraction to determine range
function DT_V2_RadarManager.GetDeviceInfo(device)
    if not device then return "Unknown Device", 0 end

    local name = "Unknown Device"
    local typeID = "Unknown"
    local range = 0

    -- 1. Try to get a clean name and type
    if device.getDisplayName then
        name = device:getDisplayName() or name 
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
                if name == "Unknown Device" then name = rawName end
            end
        end
    end
    
    -- 2. World Object Fallbacks (Sprites)
    if name == "Unknown Device" and device.getSprite then
        local sprite = device:getSprite()
        if sprite and sprite:getName() then
             if typeID == "Unknown" then typeID = sprite:getName() end
        end
    end

    -- 3. Determine Range based on Name or Type
    if DT_V2_RadarManager.Ranges[typeID] then
        range = DT_V2_RadarManager.Ranges[typeID]
    elseif DT_V2_RadarManager.Ranges[name] then
        range = DT_V2_RadarManager.Ranges[name]
    else
        -- 4. Fuzzy Matching / Heuristics
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

-- ==============================================================================
-- SCAN LOGIC
-- ==============================================================================
function DT_V2_RadarManager.Scan(player, device)
    if not player or not device then return end
    
    local deviceName, range = DT_V2_RadarManager.GetDeviceInfo(device)
    
    print("[DT_RADAR] [V3.0] Starting scan with " .. tostring(deviceName) .. " (Range: " .. tostring(range) .. ")")
    
    -- ==========================================================
    -- DELEGATE LOCATION DEBUG TO HANDLER
    -- ==========================================================
    -- This prints the detailed player location info to console
    if DT_V2_RadarLocationHandler then
        DT_V2_RadarLocationHandler.PrintDebug(player)
    end
    -- ==========================================================
    
    local rosterData = DT_V2_RadarManager.ClientRoster
    
    -- Safety Fallback for SP
    if not isClient() and not rosterData then
        rosterData = ModData.get("DynamicTrading_Roster")
    end

    if not rosterData or not rosterData.Souls then
        if isClient() then
            -- Auto-request if missing
            DT_V2_RadarManager.RequestRoster()
            player:Say("Syncing radar frequencies... try again.")
        else
            player:Say("Static... no frequencies found.")
        end
        return
    end

    local foundNew = false
    local px, py = player:getX(), player:getY()
    
    -- [UNIFIED] Get Event Modifiers
    local globalRangeMult = 1.0
    local globalChanceMult = 1.0
    if DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
        globalRangeMult = DynamicTrading.Events.GetFactionSystemModifier(nil, "signalRange")
        globalChanceMult = DynamicTrading.Events.GetFactionSystemModifier(nil, "scanChance")
    end

    local effectiveRange = range * globalRangeMult
    
    -- Filter Roster for "Trading" souls within range
    for uuid, soul in pairs(rosterData.Souls) do
        if soul.status == "Trading" then
            local tx, ty = soul.lastX, soul.lastY
            if tx and ty then
                local dx = tx - px
                local dy = ty - py
                local dist = math.sqrt(dx*dx + dy*dy)
                
                if dist <= effectiveRange then
                    -- [UNIFIED] Apply Faction-Specific Modifiers
                    local factionChanceMult = 1.0
                    if DynamicTrading.Events and DynamicTrading.Events.GetFactionSystemModifier then
                        local faction = DT_V2_RadarManager.GetFaction(soul.factionID)
                        factionChanceMult = DynamicTrading.Events.GetFactionSystemModifier(faction, "scanChance")
                    end

                    -- Proximity check passed! Now add random chance.
                    -- Skill bonus: Electricity skill improves detection
                    local elecLevel = player:getPerkLevel(Perks.Electricity)
                    local chance = (20 + (elecLevel * 5)) * globalChanceMult * factionChanceMult
                    
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

    -- Cleanup expired traders (status no longer Trading)
    DT_V2_RadarManager.Cleanup()

    if foundNew then
        player:Say("Found something! Frequency locked.")
        
        -- [MODIFIED] Auto-open window for visual feedback
        if DT_V2_RadarWindow then
            -- 1. Check if window is already OPEN and VISIBLE
            if DT_V2_RadarWindow.instance and DT_V2_RadarWindow.instance:getIsVisible() then
                -- Just refresh the list
                DT_V2_RadarWindow.instance:refresh()
            else
                -- 2. If NOT open, Force Open it (Pop out)
                DT_V2_RadarWindow.ToggleWindow(device)
            end
        end
    else
        player:Say("Nothing but static...")
    end
end

function DT_V2_RadarManager.Cleanup()
    local rosterData = DT_V2_RadarManager.ClientRoster
    if not isClient() and not rosterData then rosterData = ModData.get("DynamicTrading_Roster") end

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

-- ==========================================================
-- SAFE ACCESSORS (Unified SP/MP)
-- ==========================================================
function DT_V2_RadarManager.GetSoul(uuid)
    -- 1. Try Client Cache for MP
    if isClient() and DT_V2_RadarManager.ClientRoster and DT_V2_RadarManager.ClientRoster.Souls then
        return DT_V2_RadarManager.ClientRoster.Souls[uuid]
    end
    
    -- 2. Try ModData for SP (or Client Fallback if initialized)
    local data = ModData.get("DynamicTrading_Roster")
    if data and data.Souls then return data.Souls[uuid] end
    
    return nil
end

function DT_V2_RadarManager.GetFaction(factionID)
    -- 1. Try Client Cache for MP
    if isClient() and DT_V2_RadarManager.ClientFactions then
        return DT_V2_RadarManager.ClientFactions[factionID]
    end
    
    -- 2. Try ModData for SP
    local data = ModData.get("DynamicTrading_Factions")
    if data then return data[factionID] end
    
    return nil
end

Events.OnGameStart.Add(DT_V2_RadarManager.Init)
