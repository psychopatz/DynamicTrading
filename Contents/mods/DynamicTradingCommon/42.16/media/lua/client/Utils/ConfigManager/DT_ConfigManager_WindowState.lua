local internal = DT_ConfigManagerInternal

function DT_ConfigManager.setWindowState(winID, x, y, w, h)
    local windows = internal.ensureWindows()
    windows[winID] = { x = x, y = y, w = w, h = h }
    DT_ConfigManager.save()
end

function DT_ConfigManager.getWindowState(winID)
    local windows = internal.ensureWindows()
    return windows[winID]
end

function DT_ConfigManager.clearWindowState(winID)
    local windows = internal.ensureWindows()
    windows[winID] = nil
    DT_ConfigManager.save()
end

function DT_ConfigManager.setFactionDiscoveryBannerState(x, y, w, h)
    DT_ConfigManager.setWindowState("FactionDiscoveryBanner", x, y, w, h)
end

function DT_ConfigManager.getFactionDiscoveryBannerState()
    return DT_ConfigManager.getWindowState("FactionDiscoveryBanner")
end

function DT_ConfigManager.clearFactionDiscoveryBannerState()
    DT_ConfigManager.clearWindowState("FactionDiscoveryBanner")
end

function DT_ConfigManager.setLastManualLocation(manualId, pageId, sectionId)
    DT_ConfigManager.settings.lastManualId = tostring(manualId or "")
    DT_ConfigManager.settings.lastManualPageId = tostring(pageId or "")
    DT_ConfigManager.settings.lastManualSectionId = tostring(sectionId or "")
    DT_ConfigManager.save()
end

function DT_ConfigManager.getLastManualLocation()
    return {
        manualId = DT_ConfigManager.settings.lastManualId or "",
        pageId = DT_ConfigManager.settings.lastManualPageId or "",
        sectionId = DT_ConfigManager.settings.lastManualSectionId or ""
    }
end
