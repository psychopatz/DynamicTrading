-- ==============================================================================
-- DT_V2_RadarManager_Device.lua
-- Device identity and range logic for radar scans.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

function RadarManager.GetDeviceTypeID(device)
    if not device then
        return nil
    end

    if instanceof(device, "InventoryItem") then
        local typeID = device:getFullType()
        if DynamicTrading.Config.RadioTiers[typeID] then
            return typeID
        end
        return nil
    end

    if instanceof(device, "IsoWorldInventoryObject") then
        local item = device:getItem()
        if item then
            local typeID = item:getFullType()
            if DynamicTrading.Config.RadioTiers[typeID] then
                return typeID
            end
        end
        return nil
    end

    if instanceof(device, "IsoWaveSignal") then
        local data = device:getDeviceData()
        if not data or not data:getIsTwoWay() then
            return nil
        end

        local sprite = device:getSprite() and device:getSprite():getName() or ""
        local range = data:getTransmitRange()
        local isPortable = data:getIsPortable()

        if sprite == "appliances_com_01_8" or sprite == "appliances_com_01_9"
            or sprite == "appliances_com_01_10" or sprite == "appliances_com_01_11"
            or sprite == "appliances_radio_01_5"
        then
            return "Base.HamRadio2"
        end

        if sprite == "appliances_com_01_0" or sprite == "appliances_com_01_1"
            or sprite == "appliances_com_01_2" or sprite == "appliances_com_01_3"
            or sprite == "appliances_radio_01_4"
        then
            return "Base.HamRadio1"
        end

        if sprite == "appliances_com_01_56" or sprite == "appliances_com_01_57"
            or sprite == "appliances_com_01_58" or sprite == "appliances_com_01_59"
        then
            return "Base.HamRadioMakeShift"
        end

        if range >= 1000000 then return "Base.HamRadio2" end
        if range >= 100000 then return "Base.HamRadio1" end
        if isPortable and range >= 40000 then return "Base.ManPackRadio" end

        if isPortable then
            if range >= 16000 then return "Base.WalkieTalkie5" end
            if range >= 8000 then return "Base.WalkieTalkie4" end
            if range >= 4000 then return "Base.WalkieTalkie3" end
            if range >= 2000 then return "Base.WalkieTalkie2" end
            if range >= 750 then return "Base.WalkieTalkie1" end
            return "Base.WalkieTalkieMakeShift"
        end

        if string.find(sprite, "makeshift") or string.find(sprite, "crafted") then
            return "Base.HamRadioMakeShift"
        end

        return "Base.HamRadio1"
    end

    return nil
end

function RadarManager.GetDeviceProfile(device)
    local typeID = RadarManager.GetDeviceTypeID(device)
    local radioData = typeID and DynamicTrading.Config.GetRadioData(typeID) or nil
    local name, range = RadarManager.GetDeviceInfo(device)

    return {
        name = name,
        typeID = typeID,
        range = range,
        radioData = radioData,
        description = radioData and radioData.desc or "Unknown Device",
        power = radioData and radioData.power or 0.5,
        capacity = radioData and radioData.capacity or 1,
    }
end

function RadarManager.GetDeviceInfo(device)
    if not device then
        return "Unknown Device", 0
    end

    local name = "Unknown Device"
    local typeID = RadarManager.GetDeviceTypeID(device) or "Unknown"
    local range = 0

    if device.getDisplayName then
        name = device:getDisplayName() or name
    elseif device.getName then
        name = device:getName() or name
    end

    if device.getDeviceData then
        local dd = device:getDeviceData()
        if dd then
            local rawName = dd:getDeviceName()
            if rawName and rawName ~= "" then
                if name == "Unknown Device" then
                    name = rawName
                end
            end
        end
    end

    if name == "Unknown Device" and device.getSprite then
        local sprite = device:getSprite()
        if sprite and sprite:getName() and typeID == "Unknown" then
            typeID = sprite:getName()
        end
    end

    if RadarManager.Ranges[typeID] then
        range = RadarManager.Ranges[typeID]
    elseif RadarManager.Ranges[name] then
        range = RadarManager.Ranges[name]
    else
        local safeType = typeID or ""
        local safeName = name or ""
        local checkStr = string.lower(tostring(safeType) .. " " .. tostring(safeName))

        if string.find(checkStr, "ham") or string.find(checkStr, "location_business_office") then
            range = 2500
            if name == "Unknown Device" then
                name = "Ham Radio"
            end
        elseif string.find(checkStr, "walkie") then
            range = 750
            if name == "Unknown Device" then
                name = "Walkie Talkie"
            end
        elseif string.find(checkStr, "manpack") or string.find(checkStr, "military") then
            range = 2000
            if name == "Unknown Device" then
                name = "Military Radio"
            end
        else
            range = 500
        end
    end

    if name == "Unknown Device" and typeID ~= "Unknown" then
        local radioData = DynamicTrading.Config.GetRadioData(typeID)
        if radioData and radioData.desc then
            name = radioData.desc
        end
    end

    return name, range
end

function RadarManager.HasActiveRadio(player, currentDevice)
    if not player then return nil end
    
    local function isValidOn(obj)
        if not obj then return false end
        
        local deviceData = nil
        if obj.getDeviceData then
            deviceData = obj:getDeviceData()
        end
        if not deviceData then return false end

        -- Use the existing operational power check from DynamicTrading.Utils if available
        if DynamicTrading and DynamicTrading.Utils and DynamicTrading.Utils.HasOperationalRadioPower then
            return DynamicTrading.Utils.HasOperationalRadioPower(obj, deviceData)
        end

        -- Fallback if Utils not available yet
        if not deviceData:getIsTurnedOn() then return false end
        
        -- Be VERY lenient on power (0.0001) to avoid flickering
        return deviceData:getPower() > 0.0001
    end

    -- 1. Check current device first (for continuity)
    if currentDevice and isValidOn(currentDevice) then
        return currentDevice
    end

    -- 2. Check Primary/Secondary Hands
    local primary = player:getPrimaryHandItem()
    if primary and primary:getCategory() == "Communications" and isValidOn(primary) then
        return primary
    end
    local secondary = player:getSecondaryHandItem()
    if secondary and secondary:getCategory() == "Communications" and isValidOn(secondary) then
        return secondary
    end

    -- 3. Check Inventory (All Items)
    local inv = player:getInventory()
    local it = inv:getItems()
    for i=0, it:size()-1 do
        local item = it:get(i)
        if item:getCategory() == "Communications" and isValidOn(item) then
            return item
        end
    end

    -- 4. Check Nearby World Objects (V1 Style Hub check) - ONLY if no handheld found
    local px, py, pz = player:getX(), player:getY(), player:getZ()
    local range = 5 -- Standard range for world radio interaction
    for x = -range, range do
        for y = -range, range do
            local sq = getCell():getGridSquare(px + x, py + y, pz)
            if sq then
                local objs = sq:getObjects()
                for i=0, objs:size()-1 do
                    local obj = objs:get(i)
                    if instanceof(obj, "IsoWaveSignal") and isValidOn(obj) then
                        -- Check if it's a 2-way radio
                        local dd = obj:getDeviceData()
                        if dd and dd:getIsTwoWay() then
                            return obj
                        end
                    end
                end
            end
        end
    end

    return nil
end
