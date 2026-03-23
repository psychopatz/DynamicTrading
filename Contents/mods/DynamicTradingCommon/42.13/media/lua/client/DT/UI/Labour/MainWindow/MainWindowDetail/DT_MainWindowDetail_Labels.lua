DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

Internal.SCAVENGE_CAPABILITY_LABELS = {
    ["Scavenge.Access.LockedHome"] = "Locked homes",
    ["Scavenge.Access.ElectronicStore"] = "Electronics stores",
    ["Scavenge.Access.HeavyEntry"] = "Secure shutters and vaults",
    ["Scavenge.Extraction.CarpentryHammer"] = "Carpentry hammer",
    ["Scavenge.Extraction.CarpentrySaw"] = "Carpentry saw",
    ["Scavenge.Extraction.Plumbing"] = "Plumbing salvage",
    ["Scavenge.Extraction.MetalTorch"] = "Metal torch",
    ["Scavenge.Extraction.MetalMask"] = "Welding mask",
    ["Scavenge.Haul.Bag"] = "Hauling bag",
    ["Scavenge.Haul.Bulk"] = "Bulk loose loot",
    ["Scavenge.Haul.Bundle"] = "Bundle heavy items",
    ["Scavenge.Utility.Light"] = "Interior lighting",
    ["Scavenge.Utility.Map"] = "Route map",
    ["Scavenge.Utility.Pen"] = "Route notes"
}

function Internal.getScavengeCapabilitySummary(worker)
    local names = {}
    local seen = {}

    for _, capability in ipairs(worker and worker.scavengeCapabilities or {}) do
        local label = Internal.SCAVENGE_CAPABILITY_LABELS[capability] or tostring(capability)
        if not seen[label] then
            seen[label] = true
            names[#names + 1] = label
        end
    end

    if #names <= 0 then
        return "Open containers only"
    end

    return table.concat(names, ", ")
end

function Internal.getScavengePresenceDetailLabel(worker)
    local config = Internal.Config or {}
    local presenceState = tostring(worker and worker.presenceState or (config.PresenceStates and config.PresenceStates.Home) or "Home")
    local states = config.PresenceStates or {}
    if presenceState == states.AwayToSite then
        return "Away To Site"
    end
    if presenceState == states.AwayToHome then
        return "Away To Home"
    end
    if presenceState == states.Scavenging then
        return "Scavenging"
    end
    return "Home"
end

function Internal.getReturnReasonLabel(worker)
    local config = Internal.Config or {}
    local reason = tostring(worker and worker.returnReason or "")
    local reasons = config.ReturnReasons or {}
    if reason == reasons.FullHaul then
        return "Backpack Full"
    end
    if reason == reasons.LowTiredness then
        return "Low Tiredness"
    end
    if reason == reasons.LowFood then
        return "Low Food"
    end
    if reason == reasons.LowDrink then
        return "Low Drink"
    end
    if reason == reasons.MissingTool then
        return "Missing Tool"
    end
    if reason == reasons.MissingSite then
        return "Missing Site"
    end
    if reason == reasons.Manual then
        return "Manual Recall"
    end
    return "None"
end

function Internal.buildActivityLogText(worker)
    local entries = worker and worker.activityLog or {}
    if not entries or #entries <= 0 then
        return " <RGB:0.62,0.62,0.62> No recent worker activity yet. <LINE> "
    end

    local text = ""
    for index = #entries, 1, -1 do
        local entry = entries[index]
        local timestamp = Internal.formatActivityTimestamp(entry and entry.hour)
        local message = tostring((entry and (entry.text or entry.message)) or "Activity recorded.")
        text = text
            .. " <RGB:0.62,0.62,0.62> ["
            .. timestamp
            .. "] <RGB:0.9,0.9,0.9> "
            .. message
            .. " <LINE> "
    end

    return text
end
