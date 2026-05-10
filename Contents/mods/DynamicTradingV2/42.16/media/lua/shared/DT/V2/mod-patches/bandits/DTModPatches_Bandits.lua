-- ==============================================================================
-- DTModPatches_Bandits.lua
-- Runtime Bandits compatibility shim for Dynamic Trading NPC bodies.
-- ==============================================================================

DTModPatchesBandits = DTModPatchesBandits or {}
DTModPatchesBandits.Internal = DTModPatchesBandits.Internal or {}

local Patch = DTModPatchesBandits
local Internal = Patch.Internal

local function hasActivatedMod(modID)
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains(modID) or false
end

function Patch.IsActive()
    return hasActivatedMod("Bandits2")
end

local function getZombieModData(zombie)
    if not zombie or not zombie.getModData then
        return nil
    end

    return zombie:getModData()
end

local function getZombieVariableBoolean(zombie, variableName)
    if not zombie or not zombie.getVariableBoolean then
        return false
    end

    local ok, value = pcall(zombie.getVariableBoolean, zombie, variableName)
    return ok and value == true or false
end

function Patch.IsDTNPC(zombie)
    if not zombie then
        return false
    end

    local modData = getZombieModData(zombie)
    if modData and (
        modData.IsDTNPC == true
        or modData.DTNPC_UUID ~= nil
        or modData.DTNPC_Data ~= nil
        or modData.DTNPCBrain ~= nil
    ) then
        return true
    end

    return getZombieVariableBoolean(zombie, "DTNPC")
end

local function compatibilityLog(level, message)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTV2", "NPC", level or "Compat", tostring(message or ""))
    end
end

local function wrapCompatibilityFlag(functionName)
    if not BanditCompatibility or type(functionName) ~= "string" then
        return false
    end

    local current = BanditCompatibility[functionName]
    if type(current) ~= "function" then
        return false
    end

    Internal.originalCompatibilityFns = Internal.originalCompatibilityFns or {}
    if not Internal.originalCompatibilityFns[functionName] then
        Internal.originalCompatibilityFns[functionName] = current
    end

    if Internal.wrappedCompatibilityFns and Internal.wrappedCompatibilityFns[functionName] == true then
        return true
    end

    BanditCompatibility[functionName] = function(zombie, ...)
        if Patch.IsDTNPC(zombie) then
            return true
        end

        return Internal.originalCompatibilityFns[functionName](zombie, ...)
    end

    Internal.wrappedCompatibilityFns = Internal.wrappedCompatibilityFns or {}
    Internal.wrappedCompatibilityFns[functionName] = true
    return true
end

function Patch.ApplyEarlyShim()
    if not Patch.IsActive() then
        return false
    end

    if Internal.earlyShimApplied == true then
        return true
    end

    local loaded = BanditCompatibility ~= nil
    if not loaded then
        loaded = pcall(require, "BanditCompatibility")
    end
    if not loaded or not BanditCompatibility then
        return false
    end

    local wrappedReanimated = wrapCompatibilityFlag("IsReanimatedForGrappleOnly")
    local wrappedRagdoll = wrapCompatibilityFlag("IsRagdoll")
    Internal.earlyShimApplied = wrappedReanimated == true and wrappedRagdoll == true

    if Internal.earlyShimApplied and not Internal.loggedEarlyShimApplied then
        compatibilityLog("Compat", "Bandits compatibility shim applied for DT NPC bodies")
        Internal.loggedEarlyShimApplied = true
    end

    return Internal.earlyShimApplied
end

local function tryApplyEarlyShim()
    Patch.ApplyEarlyShim()
end

if not Internal.bootstrapInstalled then
    Internal.bootstrapInstalled = true
    tryApplyEarlyShim()

    if Events then
        if Events.OnGameBoot then
            Events.OnGameBoot.Add(tryApplyEarlyShim)
        end
        if Events.OnGameStart then
            Events.OnGameStart.Add(tryApplyEarlyShim)
        end
    end
end

return Patch
