-- ==============================================================================
-- DT_V2_RadarLocationHandler.lua
-- LOCATION INTELLIGENCE MODULE
-- ==============================================================================

DT_V2_RadarLocationHandler = {}

-- ==============================================================================
-- 1. DATA GATHERING
-- ==============================================================================
function DT_V2_RadarLocationHandler.GetLocationData(player)
    if not player then return {} end
    
    local x, y, z = math.floor(player:getX()), math.floor(player:getY()), math.floor(player:getZ())
    local sq = player:getSquare()
    
    -- 1. GEOGRAPHY
    local county = "Unknown"
    local town = "Unknown"
    if DTM and DTM.GetCountyName then county = DTM.GetCountyName(x, y) end
    if DTM and DTM.GetTownName then town = DTM.GetTownName(x, y) end

    -- 2. TRADER CENSUS (Town Population & Global Active)
    local townPopulation = 0
    local totalActiveTraders = 0
    
    local roster = nil
    -- Try Manager Client Cache first (MP Sync)
    if DT_V2_RadarManager and DT_V2_RadarManager.ClientRoster then
        roster = DT_V2_RadarManager.ClientRoster
    -- Fallback to direct ModData (SP)
    else
        roster = ModData.get("DynamicTrading_Roster")
    end
    
    if roster and roster.Souls then
        for uuid, soul in pairs(roster.Souls) do
            -- Only check living NPCs
            if soul.status and soul.status ~= "Dead" then
                
                -- A. Count Global Active Traders (Status specific)
                if soul.status == "Trading" then
                    totalActiveTraders = totalActiveTraders + 1
                end

                -- B. Count Town Population (Location specific, ANY Status)
                if town ~= "Unknown" then
                    local sx = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
                    local sy = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
                    
                    if sx and sy then
                        -- Check if NPC is in the same town as Player
                        local sTown = DTM.GetTownName(sx, sy)
                        if sTown == town then
                            townPopulation = townPopulation + 1
                        end
                    end
                end
            end
        end
    end
    
    -- 3. STRUCTURE ANALYSIS
    local roomName = "Outside"
    local buildingInfo = "None"
    local isInside = false
    
    if sq then
        -- Check if we are inside a specific room
        local room = sq:getRoom()
        if room then
            roomName = room:getName() or "Unknown Room"
            isInside = true
            
            -- Analyze building
            local b = sq:getBuilding()
            if b then
                local def = b:getDef()
                if def then 
                    local w, h = def:getW(), def:getH()
                    local area = w * h
                    local keyId = def:getKeyId() or 0
                    buildingInfo = string.format("Area: %d (%dx%d) [ID:%d]", area, w, h, keyId)
                end
            end
        end
    end

    -- 4. META ZONES
    local zoneType = "None"
    local meta = getWorld():getMetaGrid()
    if meta then
        local zones = meta:getZonesAt(x, y, z)
        if zones and zones:size() > 0 then
            for i = 0, zones:size() - 1 do
                local zObj = zones:get(i)
                local zType = zObj:getType()
                if zType ~= "World" then 
                    zoneType = zType
                    break
                end
            end
        end
    end

    -- 5. UTILITIES & ENVIRONMENT
    local hasPower = "No"
    local hasWater = "No"
    local lightLevel = 0.0
    local temperature = 0.0
    
    if sq then
        -- B42 SAFETY: Check if methods exist before calling
        if sq.haveElectricity and sq:haveElectricity() then 
            hasPower = "Yes" 
        end 
        
        -- ModData check
        if sq.getModData then
            local data = sq:getModData()
            if data and data.waterAmount then 
                hasWater = "Yes (Container)" 
            end
        end
        
        -- B42 Lighting: getLightLevel might be deprecated or changed.
        if sq.getLightLevel then
            lightLevel = sq:getLightLevel(0)
        end
    end
    
    local clim = getClimateManager()
    if clim and clim.getAirTemperatureForCharacter then
        temperature = clim:getAirTemperatureForCharacter(player)
    end
    
    -- 6. SAFEHOUSE STATUS
    local safehouseTxt = "None"
    if sq and SafeHouse and SafeHouse.getSafeHouse then
        local safehouse = SafeHouse.getSafeHouse(sq)
        if safehouse then
            local owner = tostring(safehouse:getOwner() or "Unknown")
            local title = tostring(safehouse:getTitle() or "Safehouse")
            safehouseTxt = owner .. " (" .. title .. ")"
        end
    end
    
    return {
        x = x, y = y, z = z,
        county = county,
        town = town,
        townPop = townPopulation,         -- All living NPCs in town
        activeTraders = totalActiveTraders, -- All "Trading" NPCs globally
        room = roomName,
        building = buildingInfo,
        zone = zoneType,
        isInside = isInside,
        power = hasPower,
        light = string.format("%.2f", lightLevel),
        temp = string.format("%.1f C", temperature),
        safehouse = safehouseTxt
    }
end

-- ==============================================================================
-- 2. DEBUG PRINTING
-- ==============================================================================
function DT_V2_RadarLocationHandler.PrintDebug(player)
    local loc = DT_V2_RadarLocationHandler.GetLocationData(player)
    
    print("==================================================")
    print("[DT_SCAN_DEBUG] PLAYER LOCATION REPORT")
    print("--------------------------------------------------")
    print(string.format("COORDS    : %d, %d, %d", loc.x, loc.y, loc.z))
    print(string.format("COUNTY    : %s", loc.county))
    print(string.format("TOWN      : %s", loc.town))
    print(string.format("TOWN POP  : %d", loc.townPop))
    print(string.format("ACTIVE    : %d", loc.activeTraders))
    print(string.format("ZONE      : %s", loc.zone))
    print("--------------------------------------------------")
    print(string.format("ROOM      : %s", loc.room))
    print(string.format("BUILDING  : %s", loc.building))
    print(string.format("SAFEHOUSE : %s", loc.safehouse))
    print("--------------------------------------------------")
    print(string.format("POWER     : %s", loc.power))
    print(string.format("LIGHT     : %s", loc.light))
    print(string.format("TEMP      : %s", loc.temp))
    print("==================================================")
end

-- ==============================================================================
-- 3. UI POPULATION
-- ==============================================================================
function DT_V2_RadarLocationHandler.PopulateList(listbox, player)
    if not listbox or not player then return end
    
    -- Safety wrap the data gathering to prevent UI crash
    local status, loc = pcall(DT_V2_RadarLocationHandler.GetLocationData, player)
    
    if not status then
        listbox:addItem("Error Reading Location Data", { isLocationInfo=true, label="Error", value="See Console" })
        print("[DT_ERROR] Location Handler Failed: " .. tostring(loc))
        return
    end
    
    local function addLocItem(label, value)
        listbox:addItem(label, { isLocationInfo=true, label=label, value=value })
    end
    
    addLocItem("Coordinates", loc.x .. ", " .. loc.y .. ", " .. loc.z)
    addLocItem("Region", loc.town .. " (" .. loc.county .. ")")
    addLocItem("Town Population", tostring(loc.townPop))         
    addLocItem("Current Traders", tostring(loc.activeTraders))   
    addLocItem("Zone Type", loc.zone)
    addLocItem("Room Name", loc.room)
    addLocItem("Building Info", loc.building)
    addLocItem("Has Power?", loc.power)
    addLocItem("Light Level", loc.light)
    addLocItem("Temperature", loc.temp)
    
    if loc.safehouse ~= "None" then
        addLocItem("Safehouse", loc.safehouse)
    end
end
