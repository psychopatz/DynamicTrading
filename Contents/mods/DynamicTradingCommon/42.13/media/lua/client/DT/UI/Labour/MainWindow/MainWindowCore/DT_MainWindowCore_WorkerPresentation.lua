DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal

function Internal.getWorkerGender(worker)
    return worker and worker.isFemale and "Female" or "Male"
end

function Internal.getWorkerPortraitTexture(worker)
    if not worker then
        return nil
    end

    local archetype = tostring(worker.archetypeID or "General")
    local gender = Internal.getWorkerGender(worker)
    local seed = tonumber(worker.identitySeed) or 1
    local portraitID = 1
    local pathFolder = "media/ui/Portraits/" .. archetype .. "/" .. gender .. "/"

    if DynamicTrading and DynamicTrading.Portraits then
        if DynamicTrading.Portraits.GetMappedID then
            portraitID = DynamicTrading.Portraits.GetMappedID(archetype, gender, seed)
        end
        if DynamicTrading.Portraits.GetPathFolder then
            pathFolder = DynamicTrading.Portraits.GetPathFolder(archetype, gender)
        end
    end

    local tex = getTexture(pathFolder .. tostring(portraitID) .. ".png")
    if tex then
        return tex
    end

    return getTexture("media/ui/Portraits/General/" .. gender .. "/1.png")
end

function Internal.getJobDisplayName(worker, profile)
    local sourceProfile = profile or (Internal.Config.GetJobProfile and Internal.Config.GetJobProfile(worker and worker.jobType)) or {}
    return tostring(sourceProfile.displayName or worker.jobType or worker.profession or "Unknown")
end

function Internal.getNpcConditionLabel(worker)
    local state = tostring(worker and worker.state or "Idle")
    if state == "Dehydrated" then
        return "Dehydrated"
    end
    if state == "Starving" then
        return "Starving"
    end
    if state == "Dead" then
        return "Dead"
    end
    return "Stable"
end

function Internal.formatWorkerListSubtitle(worker)
    local npcCondition = Internal.getNpcConditionLabel(worker)
    local jobType = Internal.getJobDisplayName(worker)
    local state = tostring(worker.state or "Idle")
    return npcCondition .. " | " .. jobType .. " | " .. state
end

function Internal.buildToolInputText(worker)
    local parts = {}
    for _, entry in ipairs(worker.toolLedger or {}) do
        parts[#parts + 1] = tostring(entry.displayName or entry.fullType or "Unknown Tool")
    end

    if #parts == 0 then
        return "None assigned yet."
    end

    return table.concat(parts, ", ")
end

function Internal.buildSupplyInputText(worker)
    local parts = {}
    for _, entry in ipairs(worker.nutritionLedger or {}) do
        local name = tostring(entry.displayName or entry.fullType or "Supply")
        local calories = Internal.formatReserveValue(entry.caloriesRemaining)
        local hydration = Internal.formatReserveValue(entry.hydrationRemaining)
        parts[#parts + 1] = name .. " [" .. calories .. " cal, " .. hydration .. " hyd]"
    end

    if #parts == 0 then
        return "None stored yet."
    end

    return table.concat(parts, ", ")
end

