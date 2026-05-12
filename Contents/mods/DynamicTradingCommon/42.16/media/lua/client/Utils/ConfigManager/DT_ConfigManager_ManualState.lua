local internal = DT_ConfigManagerInternal

internal.manualModDataKey = "DT_ManualState"

function DT_ConfigManager.getManualModData()
    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if not player then
        return nil
    end

    local modData = player:getModData()
    if not modData[internal.manualModDataKey] then
        modData[internal.manualModDataKey] = {}
    end
    return modData[internal.manualModDataKey]
end

function DT_ConfigManager.setLastSeenReleaseVersion(version)
    local modData = DT_ConfigManager.getManualModData()
    if modData then
        modData.lastSeenReleaseVersion = tostring(version or "")
    end
end

function DT_ConfigManager.getLastSeenReleaseVersion()
    local modData = DT_ConfigManager.getManualModData()
    return modData and tostring(modData.lastSeenReleaseVersion or "") or ""
end

function DT_ConfigManager.setLastSeenWhatsNewCount(count)
    local modData = DT_ConfigManager.getManualModData()
    if modData then
        modData.lastSeenWhatsNewCount = tonumber(count or 0) or 0
    end
end

function DT_ConfigManager.getLastSeenWhatsNewCount()
    local modData = DT_ConfigManager.getManualModData()
    return modData and tonumber(modData.lastSeenWhatsNewCount or 0) or 0
end

function DT_ConfigManager.setLastAutoOpenedReleaseVersion(version)
    local modData = DT_ConfigManager.getManualModData()
    if modData then
        modData.lastAutoOpenedReleaseVersion = tostring(version or "")
    end
end

function DT_ConfigManager.getLastAutoOpenedReleaseVersion()
    local modData = DT_ConfigManager.getManualModData()
    return modData and tostring(modData.lastAutoOpenedReleaseVersion or "") or ""
end

function DT_ConfigManager.setDisabledAutoOpenReleaseVersion(version)
    local modData = DT_ConfigManager.getManualModData()
    if modData then
        modData.disabledAutoOpenReleaseVersion = tostring(version or "")
    end
end

function DT_ConfigManager.getDisabledAutoOpenReleaseVersion()
    local modData = DT_ConfigManager.getManualModData()
    return modData and tostring(modData.disabledAutoOpenReleaseVersion or "") or ""
end

function DT_ConfigManager.setDismissedSupportBannerVersion(version)
    local modData = DT_ConfigManager.getManualModData()
    if modData then
        modData.dismissedSupportBannerVersion = tostring(version or "")
    end
end

function DT_ConfigManager.getDismissedSupportBannerVersion()
    local modData = DT_ConfigManager.getManualModData()
    return modData and tostring(modData.dismissedSupportBannerVersion or "") or ""
end
