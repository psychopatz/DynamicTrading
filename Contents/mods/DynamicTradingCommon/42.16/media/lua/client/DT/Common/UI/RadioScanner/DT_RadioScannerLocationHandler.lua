DT_RadioScannerLocationHandler = {}

function DT_RadioScannerLocationHandler.GetLocationData(player)
    if not player then return {} end

    local x, y, z = math.floor(player:getX()), math.floor(player:getY()), math.floor(player:getZ())
    local sq = player:getSquare()

    local county = "Unknown"
    local town = "Unknown"
    if DTM and DTM.GetCountyName then county = DTM.GetCountyName(x, y) end
    if DTM and DTM.GetTownName then town = DTM.GetTownName(x, y) end

    local townPopulation = 0
    local totalActiveTraders = 0
    local roster = nil
    if DT_RadioScannerManager and DT_RadioScannerManager.ClientRoster then
        roster = DT_RadioScannerManager.ClientRoster
    else
        roster = ModData.get("DynamicTrading_Roster")
    end

    if roster and roster.Souls then
        for _, soul in pairs(roster.Souls) do
            if soul.status and soul.status ~= "Dead" then
                if soul.status == "Trading" then
                    totalActiveTraders = totalActiveTraders + 1
                end

                if town ~= "Unknown" then
                    local sx = soul.lastX or (soul.homeCoords and soul.homeCoords.x)
                    local sy = soul.lastY or (soul.homeCoords and soul.homeCoords.y)
                    if sx and sy then
                        local soulTown = DTM.GetTownName(sx, sy)
                        if soulTown == town then
                            townPopulation = townPopulation + 1
                        end
                    end
                end
            end
        end
    end

    local roomName = "Outside"
    local buildingInfo = "None"
    local isInside = false
    if sq then
        local room = sq:getRoom()
        if room then
            roomName = room:getName() or "Unknown Room"
            isInside = true
            local building = sq:getBuilding()
            if building then
                local def = building:getDef()
                if def then
                    local w, h = def:getW(), def:getH()
                    buildingInfo = string.format("Area: %d (%dx%d) [ID:%d]", w * h, w, h, def:getKeyId() or 0)
                end
            end
        end
    end

    local zoneType = "None"
    local meta = getWorld():getMetaGrid()
    if meta then
        local zones = meta:getZonesAt(x, y, z)
        if zones and zones:size() > 0 then
            for i = 0, zones:size() - 1 do
                local zone = zones:get(i)
                local currentType = zone:getType()
                if currentType ~= "World" then
                    zoneType = currentType
                    break
                end
            end
        end
    end

    local hasPower = "No"
    local hasWater = "No"
    local lightLevel = 0.0
    local temperature = 0.0
    if sq then
        if sq.haveElectricity and sq:haveElectricity() then
            hasPower = "Yes"
        end
        if sq.getModData then
            local data = sq:getModData()
            if data and data.waterAmount then
                hasWater = "Yes (Container)"
            end
        end
        if sq.getLightLevel then
            lightLevel = sq:getLightLevel(0)
        end
    end

    local climate = getClimateManager()
    if climate and climate.getAirTemperatureForCharacter then
        temperature = climate:getAirTemperatureForCharacter(player)
    end

    local safehouseText = "None"
    if sq and SafeHouse and SafeHouse.getSafeHouse then
        local safehouse = SafeHouse.getSafeHouse(sq)
        if safehouse then
            safehouseText = tostring(safehouse:getOwner() or "Unknown") .. " (" .. tostring(safehouse:getTitle() or "Safehouse") .. ")"
        end
    end

    return {
        x = x, y = y, z = z,
        county = county,
        town = town,
        townPop = townPopulation,
        activeTraders = totalActiveTraders,
        room = roomName,
        building = buildingInfo,
        zone = zoneType,
        isInside = isInside,
        power = hasPower,
        water = hasWater,
        light = string.format("%.2f", lightLevel),
        temp = string.format("%.1f C", temperature),
        safehouse = safehouseText,
    }
end

function DT_RadioScannerLocationHandler.PrintDebug(player)
    local loc = DT_RadioScannerLocationHandler.GetLocationData(player)

    DynamicTrading.Log("DTCommon", "Radio", "Debug", "==================================================")
    DynamicTrading.Log("DTCommon", "Radio", "Debug", "PLAYER LOCATION REPORT")
    DynamicTrading.Log("DTCommon", "Radio", "Debug", "--------------------------------------------------")
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("COORDS    : %d, %d, %d", loc.x, loc.y, loc.z))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("COUNTY    : %s", loc.county))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("TOWN      : %s", loc.town))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("TOWN POP  : %d", loc.townPop))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("ACTIVE    : %d", loc.activeTraders))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("ZONE      : %s", loc.zone))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", "--------------------------------------------------")
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("ROOM      : %s", loc.room))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("BUILDING  : %s", loc.building))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("SAFEHOUSE : %s", loc.safehouse))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", "--------------------------------------------------")
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("POWER     : %s", loc.power))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("WATER     : %s", loc.water))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("LIGHT     : %s", loc.light))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", string.format("TEMP      : %s", loc.temp))
    DynamicTrading.Log("DTCommon", "Radio", "Debug", "==================================================")
end

function DT_RadioScannerLocationHandler.PopulateList(listbox, player)
    if not listbox or not player then return end

    local ok, loc = pcall(DT_RadioScannerLocationHandler.GetLocationData, player)
    if not ok then
        listbox:addItem("Error Reading Location Data", { isLocationInfo = true, label = "Error", value = "See Console" })
        DynamicTrading.Log("DTCommon", "Radio", "Error", "Location Handler Failed: " .. tostring(loc))
        return
    end

    local function addItem(label, value)
        listbox:addItem(label, { isLocationInfo = true, label = label, value = value })
    end

    addItem("Coordinates", loc.x .. ", " .. loc.y .. ", " .. loc.z)
    addItem("Region", loc.town .. " (" .. loc.county .. ")")
    addItem("Town Population", tostring(loc.townPop))
    addItem("Current Traders", tostring(loc.activeTraders))
    addItem("Zone Type", loc.zone)
    addItem("Room Name", loc.room)
    addItem("Building Info", loc.building)
    addItem("Has Power?", loc.power)
    addItem("Has Water?", loc.water)
    addItem("Light Level", loc.light)
    addItem("Temperature", loc.temp)

    if loc.safehouse ~= "None" then
        addItem("Safehouse", loc.safehouse)
    end
end