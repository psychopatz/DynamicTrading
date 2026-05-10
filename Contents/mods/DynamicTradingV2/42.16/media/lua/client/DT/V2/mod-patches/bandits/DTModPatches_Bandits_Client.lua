-- ==============================================================================
-- DTModPatches_Bandits_Client.lua
-- Client-side Bandits cache cleanup and DT NPC re-suppression.
-- ==============================================================================

require "DT/V2/mod-patches/bandits/DTModPatches_Bandits"

DTModPatchesBandits = DTModPatchesBandits or {}
DTModPatchesBandits.Client = DTModPatchesBandits.Client or {}

local Patch = DTModPatchesBandits
local Client = Patch.Client

if Client.EntryLoaded then
    return Patch
end

Client.EntryLoaded = true

local function countEntries(tbl)
    local count = 0
    if type(tbl) ~= "table" then
        return count
    end

    for _, _ in pairs(tbl) do
        count = count + 1
    end

    return count
end

local function getBanditZombieID(zombie)
    if not zombie then
        return nil
    end

    if BanditUtils and BanditUtils.GetZombieID then
        local ok, id = pcall(BanditUtils.GetZombieID, zombie)
        if ok then
            return id
        end
    end

    if zombie.getPersistentOutfitID then
        return zombie:getPersistentOutfitID()
    end

    return nil
end

local function refreshBanditZombieCounters()
    if not BanditZombie then
        return
    end

    BanditZombie.CacheLightBCnt = countEntries(BanditZombie.CacheLightB)
    BanditZombie.CacheLightZCnt = countEntries(BanditZombie.CacheLightZ)
end

function Patch.ScrubBanditCachesForZombie(zombie)
    if not Patch.IsActive() or not BanditZombie or not Patch.IsDTNPC(zombie) then
        return false
    end

    local zombieID = getBanditZombieID(zombie)
    if zombieID == nil then
        return false
    end

    local removed = false

    if BanditZombie.Cache and BanditZombie.Cache[zombieID] then
        BanditZombie.Cache[zombieID] = nil
        removed = true
    end
    if BanditZombie.CacheLight and BanditZombie.CacheLight[zombieID] then
        BanditZombie.CacheLight[zombieID] = nil
        removed = true
    end
    if BanditZombie.CacheLightZ and BanditZombie.CacheLightZ[zombieID] then
        BanditZombie.CacheLightZ[zombieID] = nil
        removed = true
    end
    if BanditZombie.CacheLightB and BanditZombie.CacheLightB[zombieID] then
        BanditZombie.CacheLightB[zombieID] = nil
        removed = true
    end

    if removed then
        refreshBanditZombieCounters()
    end

    return removed
end

local function clearBanditContamination(zombie)
    if not zombie then
        return false
    end

    local changed = false
    local modData = zombie.getModData and zombie:getModData() or nil

    if modData then
        if modData.brain ~= nil then
            modData.brain = nil
            changed = true
        end
        if modData.brainId ~= nil then
            modData.brainId = nil
            changed = true
        end
        if modData.isDeadBandit ~= nil then
            modData.isDeadBandit = nil
            changed = true
        end
    end

    if zombie.getVariableBoolean and zombie:getVariableBoolean("Bandit") == true then
        zombie:setVariable("Bandit", false)
        changed = true
    end

    local clearVariables = {
        "BanditPrimary",
        "BanditSecondary",
        "BanditPrimaryType",
        "BanditSecondaryType",
        "BanditWalkType",
        "BanditTorch",
        "BanditImmediateAnim",
        "BanditBecomingCorpse",
    }

    for i = 1, #clearVariables do
        local key = clearVariables[i]
        if zombie.getVariableString and zombie.clearVariable then
            local current = zombie:getVariableString(key)
            if current and current ~= "" then
                zombie:clearVariable(key)
                changed = true
            end
        end
    end

    return changed
end

function Patch.ReconcileDTNPC(zombie)
    if not Patch.IsActive() or not zombie or zombie:isDead() or not Patch.IsDTNPC(zombie) then
        return false
    end

    Patch.ApplyEarlyShim()

    local npcData = DTNPC and DTNPC.GetData and DTNPC.GetData(zombie) or nil
    if npcData and DTNPC and DTNPC.MarkBodyOwnership then
        DTNPC.MarkBodyOwnership(zombie, npcData)
    end

    local scrubbed = Patch.ScrubBanditCachesForZombie(zombie)
    local decontaminated = clearBanditContamination(zombie)

    if (scrubbed or decontaminated) and DTNPCClient and DTNPCClient.ApplySafetyToMarkedZombie then
        DTNPCClient.ApplySafetyToMarkedZombie(zombie, npcData)
    end

    return scrubbed == true or decontaminated == true
end

local function reconcileAllDTNPCs()
    if not Patch.IsActive() then
        return
    end

    Patch.ApplyEarlyShim()

    local cell = getCell()
    local zombieList = cell and cell:getZombieList() or nil
    if not zombieList then
        return
    end

    for i = 0, zombieList:size() - 1 do
        local zombie = zombieList:get(i)
        if zombie and Patch.IsDTNPC(zombie) then
            Patch.ReconcileDTNPC(zombie)
        end
    end
end

local function onZombieUpdate(zombie)
    if zombie and Patch.IsDTNPC(zombie) then
        Patch.ReconcileDTNPC(zombie)
    end
end

local function registerHandlers()
    if not Events then
        return
    end

    if Events.OnZombieUpdate then
        Events.OnZombieUpdate.Remove(onZombieUpdate)
        Events.OnZombieUpdate.Add(onZombieUpdate)
    end

    if Events.EveryOneMinute then
        Events.EveryOneMinute.Remove(reconcileAllDTNPCs)
        Events.EveryOneMinute.Add(reconcileAllDTNPCs)
    end
end

local function onGameStart()
    registerHandlers()
    reconcileAllDTNPCs()
end

Patch.ApplyEarlyShim()
registerHandlers()

if Events and Events.OnGameStart then
    Events.OnGameStart.Add(onGameStart)
end

return Patch
