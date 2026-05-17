DTNPCColonyRuntime = DTNPCColonyRuntime or {}

require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_ColonyAlert"

local Runtime = DTNPCColonyRuntime
Runtime.ALERT_NOTICE_COOLDOWN_MS = Runtime.ALERT_NOTICE_COOLDOWN_MS or 5000

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
    return "ColonyIdle"
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

function Runtime.GetPatrolRoutePoints(npcData)
    local owner = Runtime.GetOwnerUsername(npcData)
    if owner == "" or not DC_Colony or not DC_Colony.Defense then
        return {}
    end

    local defense = DC_Colony.Defense
    local runtime = defense.GetRuntime and defense.GetRuntime(owner) or nil
    local zoneRevision = defense.GetZoneRevision and tostring(defense.GetZoneRevision(owner)) or "0"
    if type(runtime) == "table" then
        if runtime.patrolRoutePoints == nil or tostring(runtime.patrolRouteRevision or "") ~= zoneRevision then
            runtime.patrolRoutePoints = DC_ZoneRealBase
                and DC_ZoneRealBase.ResolvePatrolRoutePoints
                and DC_ZoneRealBase.ResolvePatrolRoutePoints(owner, {
                    passableRadius = 1,
                    edgeInset = 1,
                    spacing = 6,
                })
                or {}
            runtime.patrolRouteRevision = zoneRevision
        end
        return runtime.patrolRoutePoints or {}
    end

    return DC_ZoneRealBase
        and DC_ZoneRealBase.ResolvePatrolRoutePoints
        and DC_ZoneRealBase.ResolvePatrolRoutePoints(owner, {
            passableRadius = 1,
            edgeInset = 1,
            spacing = 6,
        })
        or {}
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

local function getThreatIdentity(target)
    if not target then
        return nil
    end

    if target.getModData then
        local modData = target:getModData()
        local brain = modData and (modData.DTNPC_Data or modData.DTNPCBrain) or nil
        if modData and modData.DTNPC_UUID then
            return "dtnpc:" .. tostring(modData.DTNPC_UUID)
        end
        if brain and brain.uuid then
            return "dtnpc:" .. tostring(brain.uuid)
        end
    end

    if instanceof and instanceof(target, "IsoZombie") then
        return "zombie:" .. tostring(target.getOnlineID and target:getOnlineID() or target)
    end

    if target.getOnlineID then
        local onlineID = target:getOnlineID()
        if onlineID ~= nil then
            return "online:" .. tostring(onlineID)
        end
    end

    return tostring(target)
end

local function getThreatFlavorKind(role, target)
    local prefix = role == "guard" and "ColonyGuard" or "ColonyCivilian"

    if target and instanceof and instanceof(target, "IsoZombie") then
        return prefix .. "SpotZombie"
    end

    if target and target.getModData then
        local modData = target:getModData()
        local brain = modData and (modData.DTNPC_Data or modData.DTNPCBrain) or nil
        if brain and tostring(brain.factionID or "") == "Bandits" then
            return prefix .. "SpotBandits"
        end
    end

    return prefix .. "SpotHostile"
end

function Runtime.PushAlertNotice(zombie, npcData, role, target)
    if not zombie or type(npcData) ~= "table" or not DTNPCProtect or not DTNPCProtect.PushCompanionNotice then
        return false
    end

    local now = getTimeInMillis and getTimeInMillis() or 0
    local targetID = getThreatIdentity(target)
    local keyPrefix = role == "guard" and "dcGuardAlertNotice" or "dcCivilianAlertNotice"
    local lastAt = tonumber(npcData[keyPrefix .. "At"]) or 0
    local lastTargetID = npcData[keyPrefix .. "TargetID"]
    if lastAt > 0 and (now - lastAt) < Runtime.ALERT_NOTICE_COOLDOWN_MS then
        if targetID == nil or tostring(lastTargetID or "") == tostring(targetID or "") then
            return false
        end
    end

    local flavorKind = getThreatFlavorKind(role, target)
    local line = DynamicTrading
        and DynamicTrading.FlavorText
        and DynamicTrading.FlavorText.GetRandom
        and DynamicTrading.FlavorText.GetRandom("CompanionCombat", flavorKind)
        or ""
    if not line or line == "" then
        line = role == "guard" and "Contact on the perimeter. Engaging." or "Enemy sighted! Guards, now!"
    end

    npcData[keyPrefix .. "At"] = now
    npcData[keyPrefix .. "TargetID"] = targetID
    return DTNPCProtect.PushCompanionNotice(zombie, npcData, line, "warning", "Chat")
end

function Runtime.SyncBehaviorIdentity(npcData)
    if type(npcData) ~= "table" then
        return nil
    end

    local desiredState = Runtime.GetBehaviorState(npcData)
    npcData.dcBehaviorState = desiredState
    return desiredState
end

require "DT/V2/NPC/Sys/Colony/DTNPC_ColonyRuntime_CorpseRemoval"

return Runtime
