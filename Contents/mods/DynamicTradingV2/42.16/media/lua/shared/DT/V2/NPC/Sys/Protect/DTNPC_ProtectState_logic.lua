-- ==============================================================================
-- DTNPC_ProtectState_logic.lua
-- State/default management for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

local function nowMillis()
    if getTimeInMillis then
        local ms = tonumber(getTimeInMillis())
        if ms and ms > 0 then
            return math.floor(ms)
        end
    end

    local gt = getGameTime and getGameTime() or nil
    if gt and gt.getWorldAgeHours then
        return math.floor((tonumber(gt:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

local function buildPointTarget(x, y, z)
    if x == nil or y == nil then
        return nil
    end

    local px = tonumber(x)
    local py = tonumber(y)
    local pz = tonumber(z) or 0
    return {
        getX = function() return px end,
        getY = function() return py end,
        getZ = function() return pz end,
    }
end

local function resolveTrackedTargetID(npcData, target)
    if npcData and npcData.combatTargetID then
        return tostring(npcData.combatTargetID)
    end

    if not target then
        return nil
    end

    local onlineID = target.getOnlineID and target:getOnlineID() or nil
    if onlineID and onlineID ~= 0 then
        return "online:" .. tostring(onlineID)
    end
    local outfitID = target.getPersistentOutfitID and target:getPersistentOutfitID() or nil
    if outfitID and outfitID ~= 0 then
        return "outfit:" .. tostring(outfitID)
    end
    local objectID = target.getID and target:getID() or nil
    if objectID and objectID ~= 0 then
        return "id:" .. tostring(objectID)
    end

    return tostring(target)
end

function DTNPCProtect.EnsureDataDefaults(npcData)
    if not npcData then
        return nil
    end

    if npcData.enableRangedSightAnim == nil then npcData.enableRangedSightAnim = false end
    if npcData.enableMeleeCombatAnim == nil then npcData.enableMeleeCombatAnim = false end
    if npcData.combatResumeState == nil then npcData.combatResumeState = nil end
    if npcData.isPlayerFactionTrader == nil then npcData.isPlayerFactionTrader = false end
    if npcData.combatOrder == nil then npcData.combatOrder = nil end
    if npcData.guardCombatOrder == nil then npcData.guardCombatOrder = nil end
    if npcData.guardAttackMode == nil then npcData.guardAttackMode = nil end
    if npcData.combatTargetID == nil then npcData.combatTargetID = nil end
    if npcData.combatTargetType == nil then npcData.combatTargetType = nil end
    if npcData.combatFallbackAnnouncedAt == nil then npcData.combatFallbackAnnouncedAt = nil end
    if npcData.protectNoticeSerial == nil then npcData.protectNoticeSerial = 0 end
    if npcData.protectNoticeText == nil then npcData.protectNoticeText = nil end
    if npcData.protectNoticeSentiment == nil then npcData.protectNoticeSentiment = "neutral" end
    if npcData.protectNoticeDialogueStatus == nil then npcData.protectNoticeDialogueStatus = nil end
    if npcData.protectNoticeDialogueState == nil then npcData.protectNoticeDialogueState = nil end
    if npcData.companionAmbientMode == nil then npcData.companionAmbientMode = nil end
    if npcData.companionCombatActive == nil then npcData.companionCombatActive = false end
    if npcData.companionLastCombatTargetID == nil then npcData.companionLastCombatTargetID = nil end
    if npcData.companionLastRangedTargetID == nil then npcData.companionLastRangedTargetID = nil end
    if npcData.combatPursuitTargetID == nil then npcData.combatPursuitTargetID = nil end
    if npcData.combatPursuitStartedAt == nil then npcData.combatPursuitStartedAt = 0 end
    if npcData.combatPursuitLastProgressAt == nil then npcData.combatPursuitLastProgressAt = 0 end
    if npcData.combatPursuitLastAttackAt == nil then npcData.combatPursuitLastAttackAt = 0 end
    if npcData.combatPursuitLastDistance == nil then npcData.combatPursuitLastDistance = nil end
    if type(npcData.skillXP) ~= "table" then npcData.skillXP = {} end
    if npcData.loadout == nil or type(npcData.loadout) ~= "table" then
        npcData.loadout = {}
    end

    local loadout = npcData.loadout
    if loadout.rangedWeapon == nil then loadout.rangedWeapon = nil end
    if loadout.rangedAmmoType == nil then loadout.rangedAmmoType = nil end
    if loadout.ammoCount == nil then loadout.ammoCount = 0 end
    if loadout.meleeWeapon == nil then loadout.meleeWeapon = nil end
    if loadout.bag == nil then loadout.bag = nil end
    if loadout.rangedCondition == nil then loadout.rangedCondition = nil end
    if loadout.meleeCondition == nil then loadout.meleeCondition = nil end

    local trackCondition = Internal.isPlayerOwnedTraderRaw(npcData)
    Internal.normalizeWeaponCondition(loadout, "rangedWeapon", "rangedCondition", trackCondition)
    Internal.normalizeWeaponCondition(loadout, "meleeWeapon", "meleeCondition", trackCondition)

    if not trackCondition
        and (not loadout.meleeWeapon or loadout.meleeWeapon == "")
        and (not loadout.rangedWeapon or loadout.rangedWeapon == "") then
        local seededLoadout, loadoutType = Internal.buildSeededWorldLoadout(npcData)
        npcData.loadout = seededLoadout
        npcData.randomLoadoutType = loadoutType
        loadout = npcData.loadout
    end

    if npcData.skillXP.Melee == nil then npcData.skillXP.Melee = 0 end
    if npcData.skillXP.Shooting == nil then npcData.skillXP.Shooting = 0 end
    if DTNPCHealth and DTNPCHealth.EnsureDefaults then
        DTNPCHealth.EnsureDefaults(npcData)
    end

    return npcData
end

function DTNPCProtect.GetStationaryCombatLeashRadius(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    return math.max(1, tonumber(npcData and npcData.stationaryCombatLeashRadius) or tonumber(DTNPCProtect.CONFIG.StationaryCombatLeashRadius) or 10)
end

function DTNPCProtect.GetCombatUnreachableTimeoutMs(npcData)
    DTNPCProtect.EnsureDataDefaults(npcData)
    return math.max(1000, tonumber(npcData and npcData.combatUnreachableTimeoutMs) or tonumber(DTNPCProtect.CONFIG.CombatUnreachableTimeoutMs) or 6000)
end

function DTNPCProtect.GetCombatAnchor(npcData, zombie)
    if npcData then
        local postX = tonumber(npcData.stationaryPostX)
        local postY = tonumber(npcData.stationaryPostY)
        if postX ~= nil and postY ~= nil then
            return postX, postY, tonumber(npcData.stationaryPostZ) or 0
        end

        local home = npcData.homeCoords
        if type(home) == "table" and home.x ~= nil and home.y ~= nil then
            return tonumber(home.x), tonumber(home.y), tonumber(home.z) or 0
        end

        local anchorX = tonumber(npcData.anchorX)
        local anchorY = tonumber(npcData.anchorY)
        if anchorX ~= nil and anchorY ~= nil then
            return anchorX, anchorY, tonumber(npcData.anchorZ) or 0
        end
    end

    if zombie then
        return zombie:getX(), zombie:getY(), zombie:getZ() or 0
    end

    return nil, nil, nil
end

function DTNPCProtect.GetCombatAnchorTarget(npcData, zombie)
    local x, y, z = DTNPCProtect.GetCombatAnchor(npcData, zombie)
    return buildPointTarget(x, y, z)
end

function DTNPCProtect.GetDistanceToCombatAnchor(x, y, z, npcData, zombie)
    local anchorX, anchorY, anchorZ = DTNPCProtect.GetCombatAnchor(npcData, zombie)
    if anchorX == nil or anchorY == nil then
        return nil
    end

    local actualZ = tonumber(z) or anchorZ or 0
    local resolvedAnchorZ = tonumber(anchorZ) or 0
    if math.abs(actualZ - resolvedAnchorZ) > 1.1 then
        return 9999
    end

    local dx = (tonumber(x) or anchorX) - anchorX
    local dy = (tonumber(y) or anchorY) - anchorY
    return math.sqrt((dx * dx) + (dy * dy))
end

function DTNPCProtect.ResetCombatPursuit(npcData)
    if not npcData then
        return
    end

    npcData.combatPursuitTargetID = nil
    npcData.combatPursuitStartedAt = 0
    npcData.combatPursuitLastProgressAt = 0
    npcData.combatPursuitLastAttackAt = 0
    npcData.combatPursuitLastDistance = nil
end

function DTNPCProtect.MarkCombatPursuit(npcData, target, currentDistance, attacked)
    if not npcData then
        return
    end

    DTNPCProtect.EnsureDataDefaults(npcData)

    local now = nowMillis()
    local trackedTargetID = resolveTrackedTargetID(npcData, target)
    if trackedTargetID ~= nil and npcData.combatPursuitTargetID ~= trackedTargetID then
        npcData.combatPursuitTargetID = trackedTargetID
        npcData.combatPursuitStartedAt = now
        npcData.combatPursuitLastProgressAt = now
        npcData.combatPursuitLastAttackAt = 0
        npcData.combatPursuitLastDistance = tonumber(currentDistance)
    end

    local progressThreshold = math.max(0.05, tonumber(DTNPCProtect.CONFIG.CombatProgressDistance) or 0.35)
    local previousDistance = tonumber(npcData.combatPursuitLastDistance)
    local distance = tonumber(currentDistance)
    if distance ~= nil then
        if previousDistance == nil or distance <= (previousDistance - progressThreshold) then
            npcData.combatPursuitLastProgressAt = now
        end
        npcData.combatPursuitLastDistance = distance
    end

    if attacked == true then
        npcData.combatPursuitLastAttackAt = now
        npcData.combatPursuitLastProgressAt = now
    end
end

function DTNPCProtect.ShouldAbortCombatPursuit(npcData, timeoutMs)
    if not npcData or not npcData.combatPursuitTargetID then
        return false
    end

    local timeout = math.max(1000, tonumber(timeoutMs) or DTNPCProtect.GetCombatUnreachableTimeoutMs(npcData))
    local now = nowMillis()
    local lastProgress = math.max(
        tonumber(npcData.combatPursuitStartedAt) or 0,
        tonumber(npcData.combatPursuitLastProgressAt) or 0,
        tonumber(npcData.combatPursuitLastAttackAt) or 0
    )

    return (now - lastProgress) >= timeout
end

function DTNPCProtect.RememberStationaryPost(zombie, npcData, state, force)
    if not zombie or not npcData then
        return false
    end

    DTNPCProtect.EnsureDataDefaults(npcData)

    local desiredState = state or npcData.state or "Idle"
    local currentX = zombie:getX()
    local currentY = zombie:getY()
    local currentZ = zombie:getZ()
    local resetDistance = tonumber(DTNPCProtect.CONFIG.StationaryPostResetDistance) or 4
    local storedX = tonumber(npcData.stationaryPostX)
    local storedY = tonumber(npcData.stationaryPostY)
    local storedZ = tonumber(npcData.stationaryPostZ) or currentZ
    local dist = 9999

    if storedX ~= nil and storedY ~= nil then
        local dx = currentX - storedX
        local dy = currentY - storedY
        dist = math.sqrt((dx * dx) + (dy * dy))
    end

    local shouldUpdate = force == true
        or storedX == nil
        or storedY == nil
        or npcData.stationaryPostState ~= desiredState
        or (npcData.combatResumeState == nil and dist > resetDistance)
        or math.abs(currentZ - storedZ) > 0.1

    if not shouldUpdate then
        return false
    end

    npcData.stationaryPostX = currentX
    npcData.stationaryPostY = currentY
    npcData.stationaryPostZ = currentZ
    npcData.stationaryPostState = desiredState
    return true
end

function DTNPCProtect.GetStationaryPost(npcData)
    if not npcData then
        return nil, nil, nil
    end

    local x = tonumber(npcData.stationaryPostX)
    local y = tonumber(npcData.stationaryPostY)
    local z = tonumber(npcData.stationaryPostZ) or 0
    if x == nil or y == nil then
        return nil, nil, nil
    end

    return x, y, z
end

function DTNPCProtect.GetRequestedProtectState(npcData, preferredState)
    DTNPCProtect.EnsureDataDefaults(npcData)
    if preferredState == "ProtectRanged" or preferredState == "ProtectMelee" or preferredState == "ProtectAuto" then
        return preferredState
    end
    if npcData.combatOrder == "ProtectRanged" or npcData.combatOrder == "ProtectMelee" or npcData.combatOrder == "ProtectAuto" then
        return npcData.combatOrder
    end
    if npcData.state == "ProtectRanged" or npcData.state == "ProtectMelee" or npcData.state == "ProtectAuto" then
        return npcData.state
    end
    return nil
end

function DTNPCProtect.GetAutoProtectState(npcData, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    if not hasRanged and not hasMelee then
        return nil
    end

    local distance = tonumber(targetDist) or 9999
    if hasMelee and distance <= 1.85 then
        return "ProtectMelee"
    end
    if hasRanged then
        return "ProtectRanged"
    end
    if hasMelee then
        return "ProtectMelee"
    end

    return nil
end

local function normalizeGuardModeToken(value)
    local token = tostring(value or "")
    if token == "" then
        return nil
    end

    if token == "GuardRanged" or token == "ProtectRanged" or token == "ranged" then
        return "GuardRanged"
    end
    if token == "GuardMelee" or token == "ProtectMelee" or token == "melee" then
        return "GuardMelee"
    end
    if token == "GuardAuto" or token == "ProtectAuto" or token == "auto" then
        return "GuardAuto"
    end

    return nil
end

function DTNPCProtect.GetRequestedGuardState(npcData, preferredState)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local requested = normalizeGuardModeToken(preferredState)
    if requested then
        return requested
    end

    requested = normalizeGuardModeToken(npcData and npcData.guardCombatOrder)
    if requested then
        return requested
    end

    requested = normalizeGuardModeToken(npcData and npcData.guardAttackMode)
    if requested then
        return requested
    end

    requested = normalizeGuardModeToken(npcData and npcData.combatOrder)
    if requested then
        return requested
    end

    return "GuardAuto"
end

function DTNPCProtect.GetAutoGuardState(npcData, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    if not hasRanged and not hasMelee then
        return nil
    end

    local distance = tonumber(targetDist) or 9999
    if hasMelee and distance <= 1.85 then
        return "GuardMelee"
    end
    if hasRanged then
        return "GuardRanged"
    end
    if hasMelee then
        return "GuardMelee"
    end

    return nil
end

function DTNPCProtect.ResolveGuardCombatState(npcData, targetDist, preferredState)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local requested = DTNPCProtect.GetRequestedGuardState(npcData, preferredState)
    if requested ~= "GuardRanged" and requested ~= "GuardMelee" and requested ~= "GuardAuto" then
        return nil
    end

    if requested == "GuardAuto" then
        return DTNPCProtect.GetAutoGuardState(npcData, targetDist)
    end

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local resolvedState = nil

    if requested == "GuardRanged" then
        if hasRanged then
            resolvedState = "GuardRanged"
        elseif hasMelee then
            resolvedState = "GuardMelee"
        end
    elseif requested == "GuardMelee" then
        if hasMelee then
            resolvedState = "GuardMelee"
        elseif hasRanged then
            resolvedState = "GuardRanged"
        end
    end

    if resolvedState ~= requested then
        local fallbackRequested = requested == "GuardRanged" and "ProtectRanged"
            or requested == "GuardMelee" and "ProtectMelee"
            or "ProtectAuto"
        local fallbackResolved = resolvedState == "GuardRanged" and "ProtectRanged"
            or resolvedState == "GuardMelee" and "ProtectMelee"
            or nil
        local text, sentiment = DTNPCProtect.BuildFallbackNotice(fallbackRequested, fallbackResolved)
        DTNPCProtect.PushFallbackNotice(npcData, text, sentiment)
    end

    return resolvedState
end

function DTNPCProtect.GetHostileCombatState(npcData, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local distance = tonumber(targetDist) or 9999

    if hasMelee and distance <= 1.85 then
        return "Attack"
    end
    if hasRanged then
        return "AttackRange"
    end
    if hasMelee then
        return "Attack"
    end

    -- Failsafe: if loadout resolution is ambiguous, keep combat in melee mode.
    return "Attack"
end

function DTNPCProtect.ResolveHostileCombatState(npcData, preferredState, targetDist)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local requestedState = preferredState
    local distance = tonumber(targetDist) or 9999

    if requestedState ~= "Attack" and requestedState ~= "AttackRange" then
        requestedState = npcData and npcData.state or nil
    end

    if requestedState == "AttackRange" then
        if hasMelee and distance <= 1.85 then
            return "Attack"
        end
        if hasRanged then
            return "AttackRange"
        end
        if hasMelee then
            return "Attack"
        end
        return "Attack"
    end

    if requestedState == "Attack" then
        if hasRanged and not hasMelee then
            return "AttackRange"
        end
        if hasMelee and distance <= 1.85 then
            return "Attack"
        end
        if hasRanged then
            return "AttackRange"
        end
        if hasMelee then
            return "Attack"
        end
        return "Attack"
    end

    return DTNPCProtect.GetHostileCombatState(npcData, targetDist)
end

function DTNPCProtect.ResolveProtectState(npcData, preferredState)
    DTNPCProtect.EnsureDataDefaults(npcData)

    local requestedState = DTNPCProtect.GetRequestedProtectState(npcData, preferredState)
    if requestedState ~= "ProtectRanged" and requestedState ~= "ProtectMelee" and requestedState ~= "ProtectAuto" then
        return nil
    end

    if requestedState == "ProtectAuto" then
        return DTNPCProtect.GetAutoProtectState(npcData)
    end

    local hasRanged = DTNPCProtect.HasUsableRangedLoadout(npcData)
    local hasMelee = DTNPCProtect.HasUsableMeleeLoadout(npcData)
    local resolvedState = nil

    if requestedState == "ProtectRanged" then
        if hasRanged then
            resolvedState = "ProtectRanged"
        elseif hasMelee then
            resolvedState = "ProtectMelee"
        end
    elseif requestedState == "ProtectMelee" then
        if hasMelee then
            resolvedState = "ProtectMelee"
        elseif hasRanged then
            resolvedState = "ProtectRanged"
        end
    end

    if resolvedState ~= requestedState then
        local text, sentiment = DTNPCProtect.BuildFallbackNotice(requestedState, resolvedState)
        DTNPCProtect.PushFallbackNotice(npcData, text, sentiment)
    end

    return resolvedState
end

function DTNPCProtect.ClearCombatTarget(npcData)
    if npcData then
        npcData.combatTargetID = nil
        npcData.combatTargetType = nil
        DTNPCProtect.ResetCombatPursuit(npcData)
    end
end
