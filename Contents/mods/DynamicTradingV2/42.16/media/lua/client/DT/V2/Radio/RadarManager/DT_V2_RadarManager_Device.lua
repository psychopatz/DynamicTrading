-- ==============================================================================
-- DT_V2_RadarManager_Device.lua
-- Device identity and range logic for radar scans.
-- ==============================================================================

local RadarManager = DT_V2_RadarManager

function RadarManager.GetDeviceInfo(device)
    if not device then
        return "Unknown Device", 0
    end

    local name = "Unknown Device"
    local typeID = "Unknown"
    local range = 0

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

    return name, range
end
