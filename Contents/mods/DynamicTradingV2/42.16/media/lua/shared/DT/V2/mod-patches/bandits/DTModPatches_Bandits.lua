-- ==============================================================================
-- DTModPatches_Bandits.lua
-- Runtime Bandits compatibility shim for Dynamic Trading NPC bodies.
-- ==============================================================================

DTModPatchesBandits = DTModPatchesBandits or {}
DTModPatchesBandits.Internal = DTModPatchesBandits.Internal or {}

local Patch = DTModPatchesBandits
local Internal = Patch.Internal

Internal.banditTargetCache = Internal.banditTargetCache or {}
Internal.banditProvocations = Internal.banditProvocations or {}

local BANDIT_TARGET_CACHE_BUCKET_MS = 250
local BANDIT_PROVOCATION_TTL_MS = 15000

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

local function normalizeText(value)
    if value == nil then
        return nil
    end

    local text = tostring(value)
    if text == "" then
        return nil
    end

    return text
end

local function nowMillis()
    if getTimeInMillis then
        return getTimeInMillis()
    end

    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor((tonumber(gameTime:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

local function currentTargetCacheBucket()
    return math.floor(nowMillis() / BANDIT_TARGET_CACHE_BUCKET_MS)
end

local function getNPCCombatIdentity(npcData)
    if type(npcData) ~= "table" then
        return nil
    end

    local factionID = normalizeText(npcData.factionID)
    if factionID and factionID ~= "Independent" and factionID ~= "Factionless" then
        return "faction:" .. factionID
    end

    local ownerID = npcData.masterID or npcData.ownerOnlineID
    if ownerID ~= nil then
        return "owner-id:" .. tostring(ownerID)
    end

    local ownerName = normalizeText(npcData.master or npcData.ownerUsername or npcData.dcCompanionOwner)
    if ownerName then
        return "owner-name:" .. ownerName
    end

    local uuid = normalizeText(npcData.uuid)
    if uuid then
        return "uuid:" .. uuid
    end

    return nil
end

local function isBanditTargetCacheEntryValid(entry, expectedID)
    if type(entry) ~= "table" then
        return false
    end

    local candidate = entry.zombie
    if not candidate or candidate.isDead == nil or candidate:isDead() then
        return false
    end

    if not Patch.IsBanditsNPC(candidate) then
        return false
    end

    local candidateID = Patch.GetBanditZombieID(candidate)
    if candidateID == nil then
        return false
    end

    return tostring(candidateID) == tostring(expectedID)
end

local function getCachedBanditTarget(idText)
    local entry = Internal.banditTargetCache[idText]
    if not isBanditTargetCacheEntryValid(entry, idText) then
        Internal.banditTargetCache[idText] = nil
        return nil
    end

    local bucket = currentTargetCacheBucket()
    if tonumber(entry.bucket) ~= bucket then
        Internal.banditTargetCache[idText] = nil
        return nil
    end

    return entry.zombie
end

local function rememberCachedBanditTarget(idText, zombie)
    if not idText or not zombie then
        return zombie
    end

    Internal.banditTargetCache[idText] = {
        zombie = zombie,
        bucket = currentTargetCacheBucket(),
    }
    return zombie
end

local function ensureBanditCustomLoaded()
    if Internal.banditCustomLoadAttempted == true then
        return BanditCustom ~= nil
    end

    Internal.banditCustomLoadAttempted = true

    if not BanditCustom then
        pcall(require, "BanditCustom")
    end

    if BanditCustom and BanditCustom.Load then
        pcall(BanditCustom.Load)
    end

    return BanditCustom ~= nil
end

local function getBanditClanDataByID(clanID)
    clanID = normalizeText(clanID)
    if not clanID then
        return nil
    end

    if not BanditCustom and not ensureBanditCustomLoaded() then
        return nil
    end

    if BanditCustom and BanditCustom.ClanGet then
        local ok, clanData = pcall(BanditCustom.ClanGet, clanID)
        if ok and type(clanData) == "table" then
            return clanData
        end
    end

    if BanditCustom and type(BanditCustom.clanData) == "table" then
        return BanditCustom.clanData[clanID]
    end

    return nil
end

local function getBanditClanFriendlyFlag(zombie)
    local clanData = Patch.GetBanditClanData(zombie)
    local spawnData = type(clanData) == "table" and clanData.spawn or nil
    if type(spawnData) == "table" and spawnData.friendly ~= nil then
        return spawnData.friendly == true
    end

    return nil
end

local function pruneExpiredProvocations()
    local cutoff = nowMillis()
    for key, record in pairs(Internal.banditProvocations) do
        if type(record) ~= "table" or tonumber(record.expiresAt) == nil or cutoff >= tonumber(record.expiresAt) then
            Internal.banditProvocations[key] = nil
        end
    end
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

function Patch.GetBanditClanID(zombie)
    local brain = Patch.GetBanditBrain(zombie)
    return brain and normalizeText(brain.cid) or nil
end

function Patch.GetBanditClanData(zombieOrClanID)
    local clanID = nil

    if type(zombieOrClanID) == "string" then
        clanID = zombieOrClanID
    else
        clanID = Patch.GetBanditClanID(zombieOrClanID)
    end

    return getBanditClanDataByID(clanID)
end

function Patch.GetBanditClanName(zombie)
    local clanData = Patch.GetBanditClanData(zombie)
    local general = type(clanData) == "table" and clanData.general or nil
    return general and normalizeText(general.name) or nil
end

function Patch.IsPeacefulBanditsClan(zombie)
    return getBanditClanFriendlyFlag(zombie) == true
end

function Patch.IsAggressiveBanditsClan(zombie)
    local friendly = getBanditClanFriendlyFlag(zombie)
    if friendly ~= nil then
        return friendly == false
    end

    local brain = Patch.GetBanditBrain(zombie)
    return brain and brain.hostile == true or false
end

function Patch.GetBanditsAggressionState(zombie)
    if not Patch.IsBanditsNPC(zombie) then
        return "none"
    end

    if Patch.IsAggressiveBanditsClan(zombie) then
        return "aggressive"
    end

    if Patch.IsPeacefulBanditsClan(zombie) then
        return "peaceful"
    end

    if Patch.IsHostileBanditsNPC(zombie) then
        return "hostile"
    end

    return "unknown"
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

function Patch.InvalidateBanditsNPC(zombieOrID)
    local key = nil

    if type(zombieOrID) == "string" or type(zombieOrID) == "number" then
        key = tostring(zombieOrID)
    else
        local zombieID = Patch.GetBanditZombieID(zombieOrID)
        if zombieID ~= nil then
            key = tostring(zombieID)
        end
    end

    if key ~= nil then
        Internal.banditTargetCache[key] = nil
        Internal.banditProvocations["bandits:" .. key] = nil
    end
end

local function noteBanditsProvocation(zombie, npcData)
    local combatTargetID = Patch.BuildBanditsCombatTargetID(zombie)
    local combatIdentity = getNPCCombatIdentity(npcData)
    if not combatTargetID or not combatIdentity then
        return false
    end

    pruneExpiredProvocations()
    Internal.banditProvocations[combatTargetID] = {
        attackerIdentity = combatIdentity,
        attackerUUID = type(npcData) == "table" and normalizeText(npcData.uuid) or nil,
        clanID = Patch.GetBanditClanID(zombie),
        expiresAt = nowMillis() + BANDIT_PROVOCATION_TTL_MS,
    }

    return true
end

function Patch.NoteBanditsProvokedByDTNPC(zombie, npcData)
    return noteBanditsProvocation(zombie, npcData)
end

function Patch.NoteBanditsAggressionAgainstDTNPC(zombie, npcData)
    return noteBanditsProvocation(zombie, npcData)
end

function Patch.TryWakeProvokedBanditsNPC(zombie)
    return false
end

function Patch.IsBanditsProvokedAgainstNPC(zombie, npcData)
    local combatTargetID = Patch.BuildBanditsCombatTargetID(zombie)
    if not combatTargetID then
        return false
    end

    pruneExpiredProvocations()

    local record = Internal.banditProvocations[combatTargetID]
    if type(record) ~= "table" then
        return false
    end

    local combatIdentity = getNPCCombatIdentity(npcData)
    if not combatIdentity then
        return false
    end

    return normalizeText(record.attackerIdentity) == combatIdentity
end

function Patch.ShouldBanditsNPCBeHostileToDTNPC(zombie, npcData)
    if not Patch.IsBanditsNPC(zombie) then
        return false
    end

    if Patch.IsBanditsProvokedAgainstNPC(zombie, npcData) then
        return true
    end

    if Patch.IsHostileBanditsNPC(zombie) then
        return true
    end

    if Patch.IsAggressiveBanditsClan(zombie) then
        return true
    end

    if Patch.IsPeacefulBanditsClan(zombie) then
        return false
    end

    return false
end

function Patch.FindBanditsNPCByCombatID(combatTargetID)
    local text = tostring(combatTargetID or "")
    local idText = string.match(text, "^bandits:(.+)$")
    if not idText or idText == "" then
        return nil
    end

    local cached = getCachedBanditTarget(idText)
    if cached then
        return cached
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
                return rememberCachedBanditTarget(idText, candidate)
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

local function getDTNPCData(zombie)
    if not Patch.IsDTNPC(zombie) then
        return nil
    end

    local modData = getZombieModData(zombie)
    local npcData = (DTNPC and DTNPC.GetData and DTNPC.GetData(zombie))
        or (modData and (modData.DTNPC_Data or modData.DTNPCBrain))
        or nil
    if npcData then
        return npcData
    end

    local uuid = modData and normalizeText(modData.DTNPC_UUID) or nil
    if uuid and DTNPCManager and type(DTNPCManager.Data) == "table" then
        return DTNPCManager.Data[uuid]
    end

    return nil
end

local function resolveBanditsSkillLevel(brain, attackType)
    if attackType == "ranged" then
        local accuracyBoost = tonumber(brain and brain.accuracyBoost) or 0
        return math.max(0, math.min(20, 10 + (accuracyBoost * 1.25)))
    end

    local strengthBoost = math.max(0.25, tonumber(brain and brain.strengthBoost) or 1.0)
    return math.max(0, math.min(20, 8 + ((strengthBoost - 1.0) * 8.0)))
end

local function resolveBanditsBaseDamage(weaponItem, attackType, brain)
    if not DT_DamageSystem then
        pcall(require, "Misc/DT_DamageSystem")
    end

    if attackType == "melee" then
        local fullType = weaponItem and weaponItem.getFullType and weaponItem:getFullType() or nil
        local strengthBoost = math.max(0.25, tonumber(brain and brain.strengthBoost) or 1.0)
        if fullType == "Base.BareHands" then
            return 0.35 * strengthBoost
        end
        if DT_DamageSystem and DT_DamageSystem.rollWeaponDamage then
            return DT_DamageSystem.rollWeaponDamage(weaponItem) * strengthBoost
        end
        return math.max(0.35, (tonumber(weaponItem and weaponItem.getMaxDamage and weaponItem:getMaxDamage()) or 0.5) * strengthBoost)
    end

    if DT_DamageSystem and DT_DamageSystem.rollWeaponDamage then
        return DT_DamageSystem.rollWeaponDamage(weaponItem)
    end

    local minDamage = tonumber(weaponItem and weaponItem.getMinDamage and weaponItem:getMinDamage()) or nil
    local maxDamage = tonumber(weaponItem and weaponItem.getMaxDamage and weaponItem:getMaxDamage()) or nil
    if minDamage and maxDamage then
        return math.max(0.1, (minDamage + maxDamage) * 0.5)
    end

    return math.max(0.1, maxDamage or minDamage or 0.5)
end

local function applyBanditsDamageToDTNPC(attacker, target, weaponItem, attackType, source, brain)
    if not attacker or not target or not DTNPCHealth or not DTNPCHealth.ApplyDamage then
        return false, false
    end

    local npcData = getDTNPCData(target)
    if not npcData then
        return false, false
    end

    if not DT_DamageSystem then
        pcall(require, "Misc/DT_DamageSystem")
    end
    if not DT_DamageSystem or not DT_DamageSystem.GetScaledDamage then
        return false, false
    end

    local skillLevel = resolveBanditsSkillLevel(brain, attackType)
    local baseDamage = resolveBanditsBaseDamage(weaponItem, attackType, brain)
    local damage = DT_DamageSystem.GetScaledDamage(nil, attackType, weaponItem, {
        baseDamage = baseDamage,
        skillLevel = skillLevel,
        applyDealtMultiplier = false,
    })

    if target.setAttackedBy then
        target:setAttackedBy(attacker)
    end
    if target.setPlayerAttackPosition and target.testDotSide then
        target:setPlayerAttackPosition(target:testDotSide(attacker))
    end
    if target.setHitFromBehind and attacker.isBehind then
        local ok, hitFromBehind = pcall(function()
            return attacker:isBehind(target)
        end)
        if ok then
            target:setHitFromBehind(hitFromBehind == true)
        end
    end
    if target.setHitReaction then
        target:setHitReaction(attackType == "ranged" and "ShotBelly" or "HitReaction")
    end

    if Patch.NoteBanditsAggressionAgainstDTNPC then
        Patch.NoteBanditsAggressionAgainstDTNPC(attacker, npcData)
    end

    local applied, killed = DTNPCHealth.ApplyDamage(target, npcData, damage, attacker, {
        source = source,
        attackType = attackType,
        weapon = weaponItem,
        weaponFullType = weaponItem and weaponItem.getFullType and weaponItem:getFullType() or nil,
        queueFallbackIgnore = false,
    })

    if applied and BanditCompatibility and BanditCompatibility.Splash then
        BanditCompatibility.Splash(target, weaponItem, attacker)
    end

    return applied, killed
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

local function wrapBanditUtilsHit()
    if Internal.banditUtilsHitWrapped == true then
        return true
    end

    local loaded = BanditUtils ~= nil
    if not loaded then
        loaded = pcall(require, "BanditUtils")
    end
    if not loaded or not BanditUtils or type(BanditUtils.Hit) ~= "function" then
        return false
    end

    Internal.originalBanditUtilsHit = Internal.originalBanditUtilsHit or BanditUtils.Hit
    BanditUtils.Hit = function(shooter, item, victim, damageSplit)
        if Patch.IsDTNPC(victim) then
            local brain = BanditBrain and BanditBrain.Get and BanditBrain.Get(shooter) or nil
            local applied = applyBanditsDamageToDTNPC(shooter, victim, item, "ranged", "bandits_ranged", brain)
            if applied == true then
                return true
            end
        end

        return Internal.originalBanditUtilsHit(shooter, item, victim, damageSplit)
    end

    Internal.banditUtilsHitWrapped = true
    return true
end

local function wrapZombieActionSmack()
    if Internal.banditSmackWrapped == true then
        return true
    end

    local loaded = type(ZombieActions) == "table"
        and type(ZombieActions.Smack) == "table"
        and type(ZombieActions.Smack.onWorking) == "function"
    if not loaded then
        pcall(require, "ZombieActions/ZASmack")
        loaded = type(ZombieActions) == "table"
            and type(ZombieActions.Smack) == "table"
            and type(ZombieActions.Smack.onWorking) == "function"
    end
    if not loaded then
        return false
    end

    Internal.originalBanditSmackOnWorking = Internal.originalBanditSmackOnWorking or ZombieActions.Smack.onWorking
    ZombieActions.Smack.onWorking = function(bandit, task)
        local enemy = BanditZombie and BanditZombie.Cache and BanditZombie.Cache[task and task.eid] or nil
        if not enemy or not Patch.IsDTNPC(enemy) then
            return Internal.originalBanditSmackOnWorking(bandit, task)
        end

        bandit:faceLocationF(task.x, task.y)
        local bumpType = bandit:getBumpType()
        if bumpType ~= task.anim then
            return false
        end

        if not task.hit and task.time <= task.attackTime then
            task.hit = true

            local asn = bandit:getActionStateName()
            if asn == "getup"
                or asn == "getup-fromonback"
                or asn == "getup-fromonfront"
                or asn == "getup-fromsitting"
                or asn == "staggerback"
                or asn == "staggerback-knockeddown" then
                return false
            end

            if Bandit and Bandit.UpdateTask then
                Bandit.UpdateTask(bandit, task)
            end

            local item = BanditCompatibility and BanditCompatibility.InstanceItem and BanditCompatibility.InstanceItem(task.weapon) or nil
            if item then
                local brainBandit = BanditBrain and BanditBrain.Get and BanditBrain.Get(bandit) or nil
                local brainEnemy = BanditBrain and BanditBrain.Get and BanditBrain.Get(enemy) or nil
                if not BanditUtils or not BanditUtils.AreEnemies or BanditUtils.AreEnemies(brainEnemy, brainBandit) then
                    applyBanditsDamageToDTNPC(bandit, enemy, item, "melee", "bandits_melee", brainBandit)
                end
            end
        end

        return false
    end

    Internal.banditSmackWrapped = true
    return true
end

function Patch.ApplyCombatDamageShim()
    if not Patch.IsActive() then
        return false
    end

    local wrappedHit = wrapBanditUtilsHit()
    local wrappedSmack = wrapZombieActionSmack()
    Internal.combatDamageShimApplied = wrappedHit == true and wrappedSmack == true
    return Internal.combatDamageShimApplied
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

local function tryApplyCombatDamageShim()
    Patch.ApplyCombatDamageShim()
end

if not Internal.bootstrapInstalled then
    Internal.bootstrapInstalled = true
    tryApplyEarlyShim()
    tryApplyCombatDamageShim()

    if Events then
        if Events.OnGameBoot then
            Events.OnGameBoot.Add(tryApplyEarlyShim)
            Events.OnGameBoot.Add(tryApplyCombatDamageShim)
        end
        if Events.OnGameStart then
            Events.OnGameStart.Add(tryApplyEarlyShim)
            Events.OnGameStart.Add(tryApplyCombatDamageShim)
        end
    end
end

return Patch
