require "DT/Common/Labour/LabourConfig/DT_LabourConfig"
require "DT/Common/InteractionStrings/DT_InteractionStrings"

DT_Labour = DT_Labour or {}
DT_Labour.Interaction = DT_Labour.Interaction or {}

local Config = DT_Labour.Config
local Interaction = DT_Labour.Interaction

local function normalizeText(value)
    local text = string.lower(tostring(value or ""))
    text = string.gsub(text, "[^%w]+", "")
    return text
end

local function formatDecimal(value, decimals)
    local places = tonumber(decimals) or 1
    return string.format("%." .. tostring(places) .. "f", tonumber(value) or 0)
end

local function formatDurationHours(hoursLeft)
    if hoursLeft == nil then
        return "n/a"
    end

    local safeHours = math.max(0, tonumber(hoursLeft) or 0)
    if safeHours <= 0 then
        return "now"
    end
    if safeHours < 1 then
        return "< 1h"
    end

    local roundedHours = math.floor(safeHours + 0.5)
    local days = math.floor(roundedHours / 24)
    local hours = roundedHours % 24
    if days <= 0 then
        return tostring(roundedHours) .. "h"
    end
    if hours <= 0 then
        return tostring(days) .. "d"
    end
    return tostring(days) .. "d " .. tostring(hours) .. "h"
end

local function getInteractionEntry(partID, keyPath)
    return DynamicTrading.ResolveInteractionString("Labour", partID, keyPath)
end

local function getJobKey(worker)
    return tostring(Config.NormalizeJobType and Config.NormalizeJobType(worker and worker.jobType) or worker and worker.jobType or "")
end

local function getRoomLabel(roomName)
    if type(roomName) == "table" then
        return nil
    end

    local roomKey = normalizeText(roomName)
    if roomKey == "" or string.find(roomKey, "^table0x") then
        return nil
    end

    local lookup = DynamicTrading.ResolveInteractionString("Labour", "Locations", "ScavengeRooms." .. roomKey)
    if lookup then
        return tostring(lookup)
    end

    local text = tostring(roomName or "")
    if text == "" or string.find(text, "^table:") or string.find(text, "^table 0x") then
        return nil
    end

    text = string.gsub(text, "_", " ")
    text = string.gsub(text, "(%a)([%w_']*)", function(first, rest)
        return string.upper(first) .. string.lower(rest)
    end)
    return text
end

local function prettifyContextLabel(rawText)
    local text = tostring(rawText or "")
    if text == "" then
        return nil
    end

    text = string.gsub(text, "_", " ")
    text = string.gsub(text, "(%l)(%u)", "%1 %2")
    text = string.gsub(text, "(%a)([%w']*)", function(first, rest)
        return string.upper(first) .. string.lower(rest)
    end)
    return text
end

local function getZoneLabel(zoneType)
    if type(zoneType) == "table" then
        return nil
    end

    local zoneKey = normalizeText(zoneType)
    if zoneKey == "" or zoneKey == "nav" or zoneKey == "zone" then
        return nil
    end

    local mapped = DynamicTrading.ResolveInteractionString("Labour", "Locations", "ZoneTypes." .. zoneKey)
    if mapped then
        return tostring(mapped)
    end

    if zoneKey == "townzone" or zoneKey == "vegitation" then
        return nil
    end

    local rawText = tostring(zoneType or "")
    if rawText == "" or string.find(rawText, "^table:") or string.find(rawText, "^table 0x") then
        return nil
    end

    return prettifyContextLabel(rawText)
end

function Interaction.GetScavengeFallbackProfileLabel(roomName, zoneType)
    local roomLabel = getRoomLabel(roomName)
    if roomLabel and roomLabel ~= "" then
        return roomLabel
    end

    local zoneLabel = getZoneLabel(zoneType)
    if zoneLabel and zoneLabel ~= "" then
        return zoneLabel
    end

    return tostring(DynamicTrading.ResolveInteractionString("Labour", "Locations", "JobPlaces.Scavenge.Default") or "Assigned Site")
end

function Interaction.GetPlaceLabel(worker)
    local jobKey = getJobKey(worker)

    if jobKey == tostring((Config.JobTypes or {}).Scavenge or "Scavenge") then
        local profileLabel = tostring(worker and worker.scavengeSiteProfileLabel or "")
        if profileLabel == "" or profileLabel == "Unsorted Location" then
            profileLabel = Interaction.GetScavengeFallbackProfileLabel(
                worker and worker.scavengeSiteRoomName,
                worker and worker.scavengeSiteZoneType
            )
        end

        local roomLabel = getRoomLabel(worker and worker.scavengeSiteRoomName)
        if roomLabel and roomLabel ~= "" then
            if profileLabel == roomLabel then
                return roomLabel
            end
            return profileLabel .. " " .. roomLabel
        end

        local zoneLabel = getZoneLabel(worker and worker.scavengeSiteZoneType)
        if zoneLabel and zoneLabel ~= "" and zoneLabel ~= profileLabel then
            return profileLabel .. " " .. zoneLabel
        end

        return profileLabel
    end

    local locationKey = jobKey ~= "" and ("JobPlaces." .. jobKey .. ".Default") or nil
    if locationKey then
        local place = DynamicTrading.ResolveInteractionString("Labour", "Locations", locationKey)
        if place then
            return tostring(place)
        end
    end

    return "Work Site"
end

local function getTravelTotalHours()
    return math.max(
        0.01,
        tonumber(Config.GetScavengeTravelHours and Config.GetScavengeTravelHours())
            or tonumber(Config.DEFAULT_SCAVENGE_TRAVEL_HOURS)
            or 2
    )
end

local function buildProgressTokens(worker, progressHours, cycleHours, remainingWorldHours)
    local place = Interaction.GetPlaceLabel(worker)
    return {
        place = place,
        count = tostring(math.max(0, tonumber(worker and worker.outputCount) or 0)),
        eta = formatDurationHours(remainingWorldHours),
        progress = formatDecimal(progressHours or 0, 1),
        total = formatDecimal(cycleHours or 0, 1)
    }
end

function Interaction.GetDisplayStateLabel(worker)
    local jobKey = getJobKey(worker)
    local presenceState = tostring(worker and worker.presenceState or "")
    local states = Config.PresenceStates or {}

    if jobKey == tostring((Config.JobTypes or {}).Scavenge or "Scavenge") then
        if presenceState == tostring(states.AwayToSite or "AwayToSite") then
            return tostring(getInteractionEntry("Progress", "Common.TravelToSite.stateLabel") or "Walking")
        end
        if presenceState == tostring(states.AwayToHome or "AwayToHome") then
            return tostring(getInteractionEntry("Progress", "Common.TravelToHome.stateLabel") or "Walking")
        end
    end

    return tostring(worker and worker.state or "Idle")
end

function Interaction.GetProgressDescriptor(worker, profile)
    if not worker then
        return nil
    end

    local jobKey = getJobKey(worker)
    local presenceState = tostring(worker.presenceState or "")
    local states = Config.PresenceStates or {}
    local tokens = nil

    if jobKey == tostring((Config.JobTypes or {}).Scavenge or "Scavenge") then
        local travelTemplate = nil
        if presenceState == tostring(states.AwayToSite or "AwayToSite") then
            travelTemplate = getInteractionEntry("Progress", "Common.TravelToSite")
        elseif presenceState == tostring(states.AwayToHome or "AwayToHome") then
            travelTemplate = getInteractionEntry("Progress", "Common.TravelToHome")
        end

        if type(travelTemplate) == "table" then
            local totalHours = getTravelTotalHours()
            local remainingWorldHours = math.max(0, tonumber(worker.travelHoursRemaining) or 0)
            local progressHours = math.max(0, totalHours - remainingWorldHours)
            tokens = buildProgressTokens(worker, progressHours, totalHours, remainingWorldHours)
            return {
                label = DynamicTrading.FormatInteractionString(travelTemplate.activeText, tokens),
                displayText = DynamicTrading.FormatInteractionString(travelTemplate.activeText, tokens),
                fillRatio = math.max(0, math.min(1, progressHours / totalHours)),
                captionText = DynamicTrading.FormatInteractionString(travelTemplate.captionText, tokens),
                summaryText = formatDecimal(progressHours, 1) .. " / " .. formatDecimal(totalHours, 1) .. "h",
                progressHours = progressHours,
                cycleHours = totalHours,
                remainingWorldHours = remainingWorldHours,
                color = travelTemplate.color
            }
        end
    end

    local workingState = tostring((Config.States or {}).Working or "Working")
    if tostring(worker.state or "") ~= workingState or worker.jobEnabled ~= true then
        return nil
    end

    local template = getInteractionEntry("Progress", jobKey .. ".Active")
    if type(template) ~= "table" then
        return nil
    end

    local cycleHours = math.max(
        0.01,
        tonumber(worker.workCycleHours)
            or tonumber(Config.GetEffectiveCycleHours and Config.GetEffectiveCycleHours(worker, profile))
            or tonumber(profile and profile.cycleHours)
            or 24
    )
    local progressHours = math.max(0, tonumber(worker.workProgress) or 0)
    if progressHours > cycleHours then
        progressHours = progressHours % cycleHours
    end

    local baseSpeed = math.max(
        0.01,
        tonumber(worker.baseWorkSpeedMultiplier)
            or tonumber(Config.GetBaseWorkSpeedMultiplier and Config.GetBaseWorkSpeedMultiplier(worker, profile))
            or 1
    )
    local archetypeSpeed = math.max(
        0.01,
        tonumber(Config.GetJobSpeedMultiplier and Config.GetJobSpeedMultiplier(worker.archetypeID, worker.jobType) or 1) or 1
    )
    local equipmentSpeed = math.max(0.01, tonumber(worker.scavengeSearchSpeedMultiplier) or 1)
    if jobKey ~= tostring((Config.JobTypes or {}).Scavenge or "Scavenge") then
        equipmentSpeed = 1
    end

    local effectiveSpeed = baseSpeed * archetypeSpeed * equipmentSpeed
    local remainingProgressHours = math.max(0, cycleHours - progressHours)
    local remainingWorldHours = effectiveSpeed > 0 and (remainingProgressHours / effectiveSpeed) or nil

    tokens = buildProgressTokens(worker, progressHours, cycleHours, remainingWorldHours)

    return {
        label = DynamicTrading.FormatInteractionString(template.activeText, tokens),
        displayText = DynamicTrading.FormatInteractionString(template.activeText, tokens),
        fillRatio = math.max(0, math.min(1, progressHours / cycleHours)),
        captionText = DynamicTrading.FormatInteractionString(template.captionText, tokens),
        summaryText = formatDecimal(progressHours, 1)
            .. " / "
            .. formatDecimal(cycleHours, 1)
            .. "h | Speed x"
            .. formatDecimal(effectiveSpeed, 2),
        progressHours = progressHours,
        cycleHours = cycleHours,
        remainingWorldHours = remainingWorldHours,
        baseSpeedMultiplier = baseSpeed,
        archetypeSpeedMultiplier = archetypeSpeed,
        equipmentSpeedMultiplier = equipmentSpeed,
        effectiveSpeedMultiplier = effectiveSpeed,
        color = template.color
    }
end

function Interaction.BuildOutcomeMessage(worker, jobKey, outcomeKey, tokens)
    local scopedKey = tostring(jobKey or "") .. "." .. tostring(outcomeKey or "")
    local template = getInteractionEntry("Outcome", scopedKey)
    if not template then
        template = getInteractionEntry("Outcome", "Common." .. tostring(outcomeKey or ""))
    end
    if not template then
        return nil
    end

    return DynamicTrading.FormatInteractionString(template, tokens or {})
end

function Interaction.BuildReturnReasonMessage(reason)
    local normalizedReason = tostring(reason or "")
    local reasons = Config.ReturnReasons or {}
    if normalizedReason == tostring(reasons.FullHaul or "FullHaul") then
        return tostring(getInteractionEntry("Outcome", "Common.ReturnReasons.FullHaul") or "Pack is full, heading home.")
    end
    if normalizedReason == tostring(reasons.LowFood or "LowFood") then
        return tostring(getInteractionEntry("Outcome", "Common.ReturnReasons.LowFood") or "Running low on food, heading home.")
    end
    if normalizedReason == tostring(reasons.LowDrink or "LowDrink") then
        return tostring(getInteractionEntry("Outcome", "Common.ReturnReasons.LowDrink") or "Running low on water, heading home.")
    end
    if normalizedReason == tostring(reasons.MissingTool or "MissingTool") then
        return tostring(getInteractionEntry("Outcome", "Common.ReturnReasons.MissingTool") or "Missing the right tool, heading home.")
    end
    if normalizedReason == tostring(reasons.MissingSite or "MissingSite") then
        return tostring(getInteractionEntry("Outcome", "Common.ReturnReasons.MissingSite") or "Lost the work site, heading home.")
    end
    return tostring(getInteractionEntry("Outcome", "Common.ReturnReasons.Manual") or "Heading home on command.")
end

return Interaction
