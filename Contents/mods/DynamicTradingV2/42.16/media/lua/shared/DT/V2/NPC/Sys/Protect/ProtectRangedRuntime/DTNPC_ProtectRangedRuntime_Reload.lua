-- ==============================================================================
-- DTNPC_ProtectRangedRuntime_Reload.lua
-- Reload action lifecycle for DTNPC ranged combat.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local nowMillis = Internal.nowMillis
local clearRangedRuntime = Internal.ClearRangedRuntime

function DTNPCProtect.StartRangedReload(zombie, npcData, options)
    if not npcData then
        return false
    end

    local runtime = DTNPCProtect.EnsureRangedRuntime(npcData)
    if not runtime then
        return false
    end

    local currentTime = nowMillis()
    local reloadUntil = currentTime + math.max(900, tonumber(runtime.reloadDurationMs) or 1650)

    npcData._dtReloadUntil = reloadUntil
    npcData._dtReloadFamily = runtime.reloadFamily
    npcData._dtReloadAnim = runtime.reloadAnim
    npcData._dtReloadActionSeq = (tonumber(npcData._dtReloadActionSeq) or 0) + 1
    npcData._dtSpecialAction = "reload"
    npcData._dtSpecialActionMode = runtime.reloadFamily
    npcData._dtSpecialActionUntil = reloadUntil
    npcData._dtSpecialActionSeq = (tonumber(npcData._dtSpecialActionSeq) or 0) + 1
    npcData.attackTimer = 0
    npcData.reactionTimer = 0
    npcData.isMovingState = false

    if DTNPC and DTNPC.TriggerRangedReloadAnim then
        DTNPC.TriggerRangedReloadAnim(zombie, npcData)
    elseif DTNPC and DTNPC.SetRangedCombatIdleState then
        DTNPC.SetRangedCombatIdleState(zombie, npcData)
    end

    if options and options.faceTarget and zombie and options.faceTarget.getX then
        zombie:faceLocation(options.faceTarget:getX(), options.faceTarget:getY())
    end

    DTNPCProtect.PushCombatFlavorNotice(zombie, npcData, "Reloading", "warning", "Companion", "Reloading")
    return true
end

function DTNPCProtect.CompleteRangedReload(zombie, npcData)
    if not npcData then
        return false
    end

    local runtime = DTNPCProtect.EnsureRangedRuntime(npcData)
    if not runtime then
        clearRangedRuntime(npcData)
        return false
    end

    local finiteAmmo = DTNPCProtect.IsFiniteAmmoTrader and DTNPCProtect.IsFiniteAmmoTrader(npcData) or false
    local totalAmmo = math.max(0, math.floor(tonumber(npcData.loadout and npcData.loadout.ammoCount) or 0))
    if finiteAmmo then
        npcData._dtMagAmmo = math.min(runtime.magSize, totalAmmo)
    else
        npcData._dtMagAmmo = runtime.magSize
    end

    npcData._dtReloadUntil = nil
    if npcData._dtSpecialAction == "reload" then
        npcData._dtSpecialAction = nil
        npcData._dtSpecialActionUntil = nil
        npcData._dtSpecialActionMode = nil
    end

    if DTNPC and DTNPC.SetRangedCombatIdleState then
        DTNPC.SetRangedCombatIdleState(zombie, npcData)
    end
    return true
end

function DTNPCProtect.UpdateRangedReloadAction(zombie, npcData, target)
    if not npcData then
        return false, nil
    end

    DTNPCProtect.EnsureRangedRuntime(npcData)

    local reloadUntil = tonumber(npcData._dtReloadUntil) or 0
    if reloadUntil > 0 then
        if (nowMillis() or 0) >= reloadUntil then
            DTNPCProtect.CompleteRangedReload(zombie, npcData)
            return false, "reloaded"
        end

        if target and zombie and target.getX then
            zombie:faceLocation(target:getX(), target:getY())
        end
        if DTNPC and DTNPC.SetRangedCombatIdleState then
            DTNPC.SetRangedCombatIdleState(zombie, npcData)
        end
        return true, "reloading"
    end

    if DTNPCProtect.NeedsRangedReload(npcData) then
        DTNPCProtect.StartRangedReload(zombie, npcData, { faceTarget = target })
        return true, "reload_start"
    end

    return false, nil
end
