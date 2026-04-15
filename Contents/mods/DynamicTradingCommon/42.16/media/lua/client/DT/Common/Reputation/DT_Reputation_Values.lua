if isServer() then return end

DT_Reputation = DT_Reputation or {}

function DT_Reputation.Clamp(value)
    local n = tonumber(value) or 0
    if n < DT_Reputation.REP_MIN then
        return DT_Reputation.REP_MIN
    end
    if n > DT_Reputation.REP_MAX then
        return DT_Reputation.REP_MAX
    end
    return math.floor(n + (n >= 0 and 0.5 or -0.5))
end

function DT_Reputation.GetStageData(rep)
    local value = DT_Reputation.Clamp(rep)

    if value >= 80 then
        return { label = "Exalted", color = { r = 1.0, g = 0.8, b = 0.0 } }
    elseif value >= 40 then
        return { label = "Honored", color = { r = 0.2, g = 1.0, b = 0.2 } }
    elseif value >= 10 then
        return { label = "Friendly", color = { r = 0.5, g = 1.0, b = 0.5 } }
    elseif value > -10 then
        return { label = "Neutral", color = { r = 0.8, g = 0.8, b = 0.8 } }
    elseif value > -40 then
        return { label = "Unfriendly", color = { r = 1.0, g = 0.5, b = 0.2 } }
    elseif value > -80 then
        return { label = "Hostile", color = { r = 1.0, g = 0.2, b = 0.2 } }
    end

    return { label = "Nemesis", color = { r = 0.8, g = 0.0, b = 0.0 } }
end
