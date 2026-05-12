local Internal = DT_TraderContacts.Internal

require "DT/Common/FlavorText/DT_FlavorText_TraderContacts"

local function hashText(value)
    local text = tostring(value or "")
    local hash = 0
    local index

    for index = 1, #text do
        hash = (hash * 33 + string.byte(text, index)) % 2147483647
    end

    return hash
end

function Internal.CloneDeathFlavor(contact)
    if not contact then
        return nil
    end

    local flavor = tostring(contact.deathFlavorText or "")
    if flavor ~= "" then
        return flavor
    end

    local seed = table.concat({
        tostring(contact.id or contact.uuid or contact.traderID or "unknown"),
        tostring(contact.factionID or "nofaction"),
        tostring(contact.name or "noname")
    }, "|")
    local flavorSeed = hashText(seed)
    local resolved = DynamicTrading.FlavorText
        and DynamicTrading.FlavorText.GetBySeed
        and DynamicTrading.FlavorText.GetBySeed("TraderContacts", "MissingContactDeath", flavorSeed)
        or ""

    return tostring(resolved or "")
end

function Internal.ClearTransientVisitState(normalized)
    normalized.returnTime = nil
    normalized.returnStatus = nil
    normalized.contactVisitActive = false
    normalized.contactVisitMode = nil
    normalized.contactVisitBackend = nil
    normalized.contactVisitRequestedBy = nil
    normalized.contactVisitRequestedByID = nil
    normalized.contactVisitTargetX = nil
    normalized.contactVisitTargetY = nil
    normalized.contactVisitTargetZ = nil
    normalized.contactVisitStartedAt = nil
    normalized.contactVisitReturnStatus = nil
end

function Internal.MarkTraderDead(normalized, deathReason, deathFlavorText)
    normalized.status = "Dead"
    normalized.state = "Dead"
    normalized.deathReason = deathReason
    normalized.deathFlavorText = deathFlavorText
    Internal.ClearTransientVisitState(normalized)
end

function Internal.GetVisitWalkHours()
    return tonumber(SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingWalkHours or 1.0) or 1.0
end

function Internal.FormatCountdownFromHours(hoursRemaining)
    local hours = tonumber(hoursRemaining)
    local totalSeconds
    local totalMinutes
    local remainingSeconds
    local wholeHours
    local remainingMinutes

    if not hours or hours <= 0 then
        return "now"
    end

    totalSeconds = math.max(1, math.floor(hours * 3600))
    totalMinutes = math.floor(totalSeconds / 60)
    remainingSeconds = totalSeconds % 60
    wholeHours = math.floor(totalMinutes / 60)
    remainingMinutes = totalMinutes % 60

    if wholeHours > 0 then
        return string.format("%dh %02dm", wholeHours, remainingMinutes)
    end
    if totalMinutes > 0 then
        return string.format("%dm %02ds", totalMinutes, remainingSeconds)
    end

    return string.format("%ds", totalSeconds)
end
