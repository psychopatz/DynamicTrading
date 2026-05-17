DTNPCColonyRuntime = DTNPCColonyRuntime or {}

local Runtime = DTNPCColonyRuntime

local function buildPoint(source)
    if type(source) ~= "table" then
        return nil
    end

    local x = tonumber(source.x)
    local y = tonumber(source.y)
    if x == nil or y == nil then
        return nil
    end

    return {
        x = math.floor(x),
        y = math.floor(y),
        z = math.floor(tonumber(source.z) or 0),
    }
end

local function pointFromNPCFields(npcData, prefix)
    if type(npcData) ~= "table" then
        return nil
    end

    local point = npcData[prefix]
    if type(point) == "table" then
        return buildPoint(point)
    end

    return nil
end

function Runtime.IsLinkedResident(npcData)
    return type(npcData) == "table" and npcData.linkedWorkerID ~= nil
end

function Runtime.GetOwnerUsername(npcData)
    return tostring(npcData and npcData.ownerUsername or "")
end

function Runtime.GetWorker(npcData)
    if not Runtime.IsLinkedResident(npcData) then
        return nil
    end

    local registry = DC_Colony and DC_Colony.Registry or nil
    if not registry or not registry.GetWorkerRaw then
        return nil
    end

    local worker = registry.GetWorkerRaw(npcData.linkedWorkerID)
    return worker
end

function Runtime.GetBehaviorState(npcData)
    local state = tostring(npcData and npcData.dcBehaviorState or "")
    if state ~= "" then
        return state
    end

    local dutyMode = tostring(npcData and npcData.dcDutyMode or "")
    if dutyMode == "guard" then
        return "Patrol"
    end
    if dutyMode == "work" or dutyMode == "patient" then
        return "ColonyWork"
    end
    return "ColonyCower"
end

function Runtime.GetHomePoint(npcData)
    return pointFromNPCFields(npcData, "homeCoords")
end

function Runtime.GetWorkPoint(npcData)
    return pointFromNPCFields(npcData, "workCoords")
end

function Runtime.GetSafePoint(npcData, worker)
    local dutyMode = tostring(npcData and npcData.dcDutyMode or "")
    local workPoint = Runtime.GetWorkPoint(npcData)
    if dutyMode == "patient" and workPoint then
        return workPoint
    end

    local homePoint = Runtime.GetHomePoint(npcData)
    if homePoint then
        return homePoint
    end

    local owner = Runtime.GetOwnerUsername(npcData)
    if owner ~= "" and DC_ZoneRealBase and DC_ZoneRealBase.ResolveSafeFallbackTarget then
        return buildPoint(DC_ZoneRealBase.ResolveSafeFallbackTarget(owner))
    end

    return workPoint
end

function Runtime.GetPerimeterPosts(npcData)
    local owner = Runtime.GetOwnerUsername(npcData)
    if owner == "" or not DC_Colony or not DC_Colony.Defense then
        return {}
    end

    local defense = DC_Colony.Defense
    local runtime = defense.GetRuntime and defense.GetRuntime(owner) or nil
    local zoneRevision = defense.GetZoneRevision and tostring(defense.GetZoneRevision(owner)) or "0"
    if type(runtime) == "table" then
        if runtime.perimeterPosts == nil or tostring(runtime.perimeterPostsRevision or "") ~= zoneRevision then
            runtime.perimeterPosts = DC_ZoneRealBase and DC_ZoneRealBase.ResolvePerimeterPosts and DC_ZoneRealBase.ResolvePerimeterPosts(owner, {
                spacing = 6,
                passableRadius = 1,
            }) or {}
            runtime.perimeterPostsRevision = zoneRevision
        end
        return runtime.perimeterPosts or {}
    end

    return DC_ZoneRealBase and DC_ZoneRealBase.ResolvePerimeterPosts and DC_ZoneRealBase.ResolvePerimeterPosts(owner, {
        spacing = 6,
        passableRadius = 1,
    }) or {}
end

function Runtime.GetNearestPostIndex(posts, x, y)
    local bestIndex = nil
    local bestDist = nil

    for index, point in ipairs(posts or {}) do
        local px = tonumber(point and point.x)
        local py = tonumber(point and point.y)
        if px ~= nil and py ~= nil then
            local dx = (tonumber(x) or px) - px
            local dy = (tonumber(y) or py) - py
            local dist = (dx * dx) + (dy * dy)
            if bestDist == nil or dist < bestDist then
                bestDist = dist
                bestIndex = index
            end
        end
    end

    return bestIndex or 1
end

function Runtime.RaiseAlert(npcData, source)
    local owner = Runtime.GetOwnerUsername(npcData)
    local defense = DC_Colony and DC_Colony.Defense or nil
    if owner == "" or not defense or not defense.RaiseAlert then
        return nil
    end
    return defense.RaiseAlert(owner, source or {})
end

function Runtime.GetAlert(npcData)
    local owner = Runtime.GetOwnerUsername(npcData)
    local defense = DC_Colony and DC_Colony.Defense or nil
    if owner == "" or not defense or not defense.GetAlert then
        return nil
    end
    return defense.GetAlert(owner)
end

function Runtime.ShouldSenseThreat(npcData, cooldownMs)
    local now = getTimeInMillis and getTimeInMillis() or 0
    local nextAt = tonumber(npcData and npcData.dcSenseThreatAfterMs) or 0
    if now < nextAt then
        return false
    end

    if type(npcData) == "table" then
        npcData.dcSenseThreatAfterMs = now + math.max(250, math.floor(tonumber(cooldownMs) or 1200))
    end
    return true
end

function Runtime.SyncBehaviorIdentity(npcData)
    if type(npcData) ~= "table" then
        return nil
    end

    local desiredState = Runtime.GetBehaviorState(npcData)
    npcData.dcBehaviorState = desiredState
    return desiredState
end

return Runtime
