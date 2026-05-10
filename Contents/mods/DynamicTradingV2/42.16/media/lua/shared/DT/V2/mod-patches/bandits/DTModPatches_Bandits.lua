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

function Patch.GetBanditZombieID(zombie)
    if not zombie then
        return nil
    end

    if BanditUtils and BanditUtils.GetZombieID then
        local ok, id = pcall(BanditUtils.GetZombieID, zombie)
        if ok and id ~= nil then
            return id
        end
    end

    if zombie.getPersistentOutfitID then
        return zombie:getPersistentOutfitID()
    end

    return nil
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

function Patch.IsBanditsNPC(zombie)
    if not Patch.IsActive() or not zombie or Patch.IsDTNPC(zombie) then
        return false
    end

    local modData = getZombieModData(zombie)
    if getZombieVariableBoolean(zombie, "Bandit") then
        return true
    end

    return modData and (modData.brain ~= nil or modData.brainId ~= nil) or false
end

function Patch.GetBanditBrain(zombie)
    if not Patch.IsBanditsNPC(zombie) then
        return nil
    end

    if BanditBrain and BanditBrain.Get then
        local ok, brain = pcall(BanditBrain.Get, zombie)
        if ok and brain then
            return brain
        end
    end

    local modData = getZombieModData(zombie)
    return modData and modData.brain or nil
end

function Patch.IsHostileBanditsNPC(zombie)
    local brain = Patch.GetBanditBrain(zombie)
    return brain and (brain.hostile == true or brain.hostileP == true) or false
end

function Patch.BuildBanditsCombatTargetID(zombie)
    local zombieID = Patch.GetBanditZombieID(zombie)
    if zombieID == nil then
        return nil
    end

    return "bandits:" .. tostring(zombieID)
end

function Patch.FindBanditsNPCByCombatID(combatTargetID)
    local text = tostring(combatTargetID or "")
    local idText = string.match(text, "^bandits:(.+)$")
    if not idText or idText == "" then
        return nil
    end

    local zombieList = getCell and getCell() and getCell():getZombieList() or nil
    if not zombieList then
        return nil
    end

    for i = 0, zombieList:size() - 1 do
        local candidate = zombieList:get(i)
        if candidate and not candidate:isDead() and Patch.IsBanditsNPC(candidate) then
            local candidateID = Patch.GetBanditZombieID(candidate)
            if candidateID ~= nil and tostring(candidateID) == idText then
                return candidate
            end
        end
    end

    return nil
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
