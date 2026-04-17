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
