local MOD_DATA_KEY = DynamicTrading_Roster.MOD_DATA_KEY

local function stripMovementSpeed(npcData)
    if type(npcData) ~= "table" then return npcData end
    npcData.walkSpeed = nil
    npcData.runSpeed = nil
    return npcData
end

local function getFactionSnapshot(factionID)
    local key = factionID and tostring(factionID) or ""
    if key == "" or not DynamicTrading_Factions or not DynamicTrading_Factions.GetFaction then
        return nil
    end

    local ok, faction = pcall(function()
        return DynamicTrading_Factions.GetFaction(key)
    end)
    if ok and type(faction) == "table" then
        return faction
    end
    return nil
end

local function isAbstractNomadFaction(factionID)
    local key = factionID and tostring(factionID) or ""
    if key == "" then
        return false
    end

    if key == "Independent" then
        return true
    end

    local faction = getFactionSnapshot(key)
    local factionType = tostring(faction and faction.factionType or "")
    return (faction and faction.isNomadic == true)
        or factionType == "independent"
        or factionType == "bandit"
end

local function normalizeSoulAbstraction(npcData)
    if type(npcData) ~= "table" then
        return npcData
    end

    local shouldAbstract = (npcData.abstractResident == true) or isAbstractNomadFaction(npcData.factionID)
    npcData.abstractResident = shouldAbstract == true
    return npcData
end

function DynamicTrading_Roster.IsAbstractNomadFaction(factionID)
    return isAbstractNomadFaction(factionID)
end

function DynamicTrading_Roster.ShouldAbstractSoulAtRest(soulLike)
    local soul = nil
    if type(soulLike) == "table" then
        soul = soulLike
    elseif soulLike ~= nil then
        soul = DynamicTrading_Roster.GetSoulRegistry(tostring(soulLike))
    end

    if type(soul) ~= "table" then
        return false
    end

    local status = tostring(soul.status or "Resting")
    if status ~= "Resting" then
        return false
    end

    return normalizeSoulAbstraction(soul).abstractResident == true
end

function DynamicTrading_Roster.GetSouls(factionID)
    local data = ModData.get(MOD_DATA_KEY)
    if not data.FactionMembers[factionID] then
        data.FactionMembers[factionID] = {}
    end
    return data.FactionMembers[factionID]
end

function DynamicTrading_Roster.GetSoulRegistry(uuid)
    local data = ModData.get(MOD_DATA_KEY)
    return normalizeSoulAbstraction(data.Souls[uuid])
end

function DynamicTrading_Roster.GetSoul(uuid)
    local soulKey = "DTSOUL_" .. uuid
    if ModData.exists(soulKey) then
        return stripMovementSpeed(normalizeSoulAbstraction(ModData.get(soulKey)))
    end

    local registry = DynamicTrading_Roster.GetSoulRegistry(uuid)
    if registry and registry.name then
        return stripMovementSpeed(normalizeSoulAbstraction(registry))
    end

    return nil
end

function DynamicTrading_Roster.SaveSoul(uuid, npcData)
    npcData = stripMovementSpeed(normalizeSoulAbstraction(npcData))

    local soulKey = "DTSOUL_" .. uuid
    if not ModData.exists(soulKey) then
        ModData.add(soulKey, npcData)
    else
        local entry = ModData.get(soulKey)
        for key, value in pairs(npcData) do
            entry[key] = value
        end
        entry.walkSpeed = nil
        entry.runSpeed = nil
    end

    local data = ModData.get(MOD_DATA_KEY)
    data.Souls[uuid] = {
        uuid = uuid,
        name = npcData.name or "Unknown",
        factionID = npcData.factionID,
        archetypeID = npcData.archetypeID,
        homeCoords = npcData.homeCoords,
        workCoords = npcData.workCoords or { x = 0, y = 0, z = 0 },
        lastX = npcData.lastX,
        lastY = npcData.lastY,
        lastZ = npcData.lastZ,
        health = (npcData.combatHealth and npcData.combatHealth.current) or npcData.health or 1.0,
        combatHealthCurrent = npcData.combatHealth and npcData.combatHealth.current or nil,
        combatHealthMax = npcData.combatHealth and npcData.combatHealth.max or nil,
        status = npcData.status or "Resting",
        state = npcData.state,
        incapState = npcData.incapState,
        returnTime = npcData.returnTime,
        returnStatus = npcData.returnStatus,
        master = npcData.master,
        isFemale = npcData.isFemale,
        identitySeed = npcData.identitySeed or 1,
        linkedWorkerID = npcData.linkedWorkerID,
        ownerUsername = npcData.ownerUsername,
        isPlayerFactionTrader = npcData.isPlayerFactionTrader == true,
        abstractResident = npcData.abstractResident == true,
        tradeCycleMode = npcData.tradeCycleMode,
        tradeCycleDemandEligible = npcData.tradeCycleDemandEligible == true,
        tradeCycleAggroRadius = npcData.tradeCycleAggroRadius,
        tradeCycleTargetPlayerUsername = npcData.tradeCycleTargetPlayerUsername,
        tradeCycleTargetPlayerOnlineID = npcData.tradeCycleTargetPlayerOnlineID,
        banditRoamActive = npcData.banditRoamActive == true,
        banditRoamSite = npcData.banditRoamSite,
        banditRoamStartedAt = npcData.banditRoamStartedAt,
        banditRoamEndsAt = npcData.banditRoamEndsAt,
        banditRoamReturnStatus = npcData.banditRoamReturnStatus,
        banditRoamEncounterMode = npcData.banditRoamEncounterMode,
        banditRoamAggroRadius = npcData.banditRoamAggroRadius,
    }
end
