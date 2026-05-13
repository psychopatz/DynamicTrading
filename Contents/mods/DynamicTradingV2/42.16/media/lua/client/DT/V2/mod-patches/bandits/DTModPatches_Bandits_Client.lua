-- ==============================================================================
-- DTModPatches_Bandits_Client.lua
-- Client-side Bandits cache cleanup and DT NPC combat mirroring.
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

local function refreshBanditZombieCounters()
    if type(BanditZombie) ~= "table" then
        return
    end

    if type(BanditZombie.CacheLightB) == "table" then
        BanditZombie.CacheLightBCnt = countEntries(BanditZombie.CacheLightB)
    end
    if type(BanditZombie.CacheLightZ) == "table" then
        BanditZombie.CacheLightZCnt = countEntries(BanditZombie.CacheLightZ)
    end
end

function Patch.ScrubBanditCachesForZombie(zombie)
    if not Patch.IsActive() or type(BanditZombie) ~= "table" or not Patch.IsDTNPC(zombie) then
        return false
    end

    local zombieID = Patch.GetBanditZombieID and Patch.GetBanditZombieID(zombie) or nil
    if zombieID == nil then
        return false
    end

    local removed = false
    local cache = type(BanditZombie.Cache) == "table" and BanditZombie.Cache or nil
    local cacheLight = type(BanditZombie.CacheLight) == "table" and BanditZombie.CacheLight or nil
    local cacheLightZ = type(BanditZombie.CacheLightZ) == "table" and BanditZombie.CacheLightZ or nil
    local cacheLightB = type(BanditZombie.CacheLightB) == "table" and BanditZombie.CacheLightB or nil
    local lightEntry = cacheLight and cacheLight[zombieID] or nil
    local hasCompatMirror = type(lightEntry) == "table"
        and lightEntry.isDTNPC == true
        and type(lightEntry.brain) == "table"
        and lightEntry.brain.dtCompat == true

    if cache and cache[zombieID] and not hasCompatMirror then
        cache[zombieID] = nil
        removed = true
    end
    if cacheLight and cacheLight[zombieID] and not hasCompatMirror then
        cacheLight[zombieID] = nil
        removed = true
    end
    if cacheLightZ and cacheLightZ[zombieID] then
        cacheLightZ[zombieID] = nil
        removed = true
    end
    if cacheLightB and cacheLightB[zombieID] then
        cacheLightB[zombieID] = nil
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

local function shouldExposeDTNPCToBanditCombat(zombie, npcData)
    if not zombie or zombie:isDead() then
        return false
    end

    if not npcData then
        return true
    end

    if npcData.incapState == "Active" or npcData.state == "Incapacitated" then
        return false
    end

    return true
end

function Patch.PublishDTNPCToBanditCombatCache(zombie, npcData)
    if not Patch.IsActive() or type(BanditZombie) ~= "table" or not Patch.IsDTNPC(zombie) then
        return false
    end

    local zombieID = Patch.GetBanditZombieID and Patch.GetBanditZombieID(zombie) or nil
    if zombieID == nil then
        return false
    end

    if not shouldExposeDTNPCToBanditCombat(zombie, npcData) then
        return false
    end

    BanditZombie.Cache = BanditZombie.Cache or {}
    BanditZombie.CacheLight = BanditZombie.CacheLight or {}
    BanditZombie.CacheLightZ = BanditZombie.CacheLightZ or {}
    BanditZombie.CacheLightB = BanditZombie.CacheLightB or {}

    local light = BanditZombie.CacheLight[zombieID]
    if type(light) ~= "table" then
        light = {}
        BanditZombie.CacheLight[zombieID] = light
    end

    light.id = zombieID
    light.x = zombie:getX()
    light.y = zombie:getY()
    light.z = zombie:getZ()
    light.d = zombie:getDirectionAngle()
    light.isBandit = false
    light.isDTNPC = true
    light.brain = type(light.brain) == "table" and light.brain or {}
    light.brain.clan = "DynamicTrading"
    light.brain.hostile = false
    light.brain.hostileP = false
    light.brain.loyal = true
    light.brain.dtCompat = true
    light.rid = nil

    BanditZombie.Cache[zombieID] = zombie
    BanditZombie.CacheLight[zombieID] = light

    local removedBucket = false
    if BanditZombie.CacheLightZ[zombieID] then
        BanditZombie.CacheLightZ[zombieID] = nil
        removedBucket = true
    end
    if BanditZombie.CacheLightB[zombieID] then
        BanditZombie.CacheLightB[zombieID] = nil
        removedBucket = true
    end

    if removedBucket then
        refreshBanditZombieCounters()
    end

    return true
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
    local mirrored = Patch.PublishDTNPCToBanditCombatCache(zombie, npcData)

    if (scrubbed or decontaminated) and DTNPCClient and DTNPCClient.ApplySafetyToMarkedZombie then
        DTNPCClient.ApplySafetyToMarkedZombie(zombie, npcData)
    end

    return scrubbed == true or decontaminated == true or mirrored == true
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
