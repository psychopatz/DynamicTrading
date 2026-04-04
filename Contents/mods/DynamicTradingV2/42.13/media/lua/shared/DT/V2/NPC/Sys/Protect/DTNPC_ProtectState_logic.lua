-- ==============================================================================
-- DTNPC_ProtectState_logic.lua
-- State/default management for DTNPCProtect.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

function DTNPCProtect.EnsureDataDefaults(npcData)
    if not npcData then
        return nil
    end

    if npcData.enableRangedSightAnim == nil then npcData.enableRangedSightAnim = false end
    if npcData.enableMeleeCombatAnim == nil then npcData.enableMeleeCombatAnim = false end
    if npcData.combatResumeState == nil then npcData.combatResumeState = nil end
    if npcData.isPlayerFactionTrader == nil then npcData.isPlayerFactionTrader = false end
    if npcData.combatOrder == nil then npcData.combatOrder = nil end
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

    return npcData
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
    end
end
