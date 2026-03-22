DT_Labour = DT_Labour or {}
DT_Labour.Interaction = DT_Labour.Interaction or {}

local Config = DT_Labour.Config
local Interaction = DT_Labour.Interaction

Interaction.getInteractionEntry = function(partID, keyPath)
    return DynamicTrading.ResolveInteractionString("Labour", partID, keyPath)
end

Interaction.getJobKey = function(worker)
    return tostring(Config.NormalizeJobType and Config.NormalizeJobType(worker and worker.jobType) or worker and worker.jobType or "")
end

Interaction.getTravelTotalHours = function()
    return math.max(
        0.01,
        tonumber(Config.GetScavengeTravelHours and Config.GetScavengeTravelHours())
            or tonumber(Config.DEFAULT_SCAVENGE_TRAVEL_HOURS)
            or 2
    )
end

Interaction.buildProgressTokens = function(worker, progressHours, cycleHours, remainingWorldHours)
    local place = Interaction.GetPlaceLabel(worker)
    return {
        place = place,
        count = tostring(math.max(0, tonumber(worker and worker.outputCount) or 0)),
        eta = Interaction.formatDurationHours(remainingWorldHours),
        progress = Interaction.formatDecimal(progressHours or 0, 1),
        total = Interaction.formatDecimal(cycleHours or 0, 1)
    }
end

return DT_Labour.Interaction
