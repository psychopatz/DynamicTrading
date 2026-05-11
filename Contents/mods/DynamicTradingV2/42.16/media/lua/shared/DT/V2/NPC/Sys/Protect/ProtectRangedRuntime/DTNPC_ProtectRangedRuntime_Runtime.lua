-- ==============================================================================
-- DTNPC_ProtectRangedRuntime_Runtime.lua
-- Runtime state helpers for DTNPC ranged combat.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal
local nowMillis = Internal.nowMillis

local function clearRangedRuntime(npcData)
    if not npcData then
        return
    end

    npcData._dtMagAmmo = nil
    npcData._dtMagSize = nil
    npcData._dtReloadUntil = nil
    npcData._dtReloadFamily = nil
    npcData._dtReloadAnim = nil
    npcData._dtSpecialActionMode = nil
end

Internal.ClearRangedRuntime = clearRangedRuntime

function DTNPCProtect.EnsureRangedRuntime(npcData)
    local runtime = DTNPCProtect.GetRangedWeaponRuntime(npcData)
    if not runtime then
        return nil
    end

    local finiteAmmo = DTNPCProtect.IsFiniteAmmoTrader and DTNPCProtect.IsFiniteAmmoTrader(npcData) or false
    local totalAmmo = math.max(0, math.floor(tonumber(npcData.loadout and npcData.loadout.ammoCount) or 0))
    local targetMagSize = math.max(1, tonumber(runtime.magSize) or 1)

    npcData._dtMagSize = targetMagSize
    npcData._dtReloadFamily = runtime.reloadFamily
    npcData._dtReloadAnim = runtime.reloadAnim

    local currentMag = tonumber(npcData._dtMagAmmo)
    if currentMag == nil then
        if finiteAmmo then
            currentMag = math.min(targetMagSize, totalAmmo)
        else
            currentMag = targetMagSize
        end
    end

    currentMag = math.max(0, math.min(targetMagSize, math.floor(currentMag)))
    if finiteAmmo and currentMag > totalAmmo then
        currentMag = totalAmmo
    end

    npcData._dtMagAmmo = currentMag
    return runtime
end

function DTNPCProtect.IsRangedReloading(npcData)
    if not npcData then
        return false
    end
    local reloadUntil = tonumber(npcData._dtReloadUntil) or 0
    if reloadUntil <= 0 then
        return false
    end
    return (nowMillis() or 0) < reloadUntil
end

function DTNPCProtect.NeedsRangedReload(npcData)
    if not npcData then
        return false
    end

    local runtime = DTNPCProtect.EnsureRangedRuntime(npcData)
    if not runtime then
        return false
    end

    local magAmmo = math.max(0, math.floor(tonumber(npcData._dtMagAmmo) or 0))
    if magAmmo > 0 then
        return false
    end

    if DTNPCProtect.IsFiniteAmmoTrader and DTNPCProtect.IsFiniteAmmoTrader(npcData) then
        return math.max(0, tonumber(npcData.loadout and npcData.loadout.ammoCount) or 0) > 0
    end

    return true
end

function DTNPCProtect.ConsumeRangedShot(npcData, amount)
    if not npcData then
        return 0, 0
    end

    local runtime = DTNPCProtect.EnsureRangedRuntime(npcData)
    local spend = math.max(1, math.floor(tonumber(amount) or 1))
    if runtime then
        npcData._dtMagAmmo = math.max(0, math.floor(tonumber(npcData._dtMagAmmo) or runtime.magSize) - spend)
    end

    local remaining = DTNPCProtect.ConsumeAmmo(npcData, spend)
    return math.max(0, tonumber(npcData._dtMagAmmo) or 0), math.max(0, tonumber(remaining) or 0)
end
