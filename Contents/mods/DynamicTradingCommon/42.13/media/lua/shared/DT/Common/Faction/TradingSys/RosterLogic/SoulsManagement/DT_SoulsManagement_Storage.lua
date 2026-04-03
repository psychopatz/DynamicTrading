local MOD_DATA_KEY = DynamicTrading_Roster.MOD_DATA_KEY

local function stripMovementSpeed(npcData)
    if type(npcData) ~= "table" then return npcData end
    npcData.walkSpeed = nil
    npcData.runSpeed = nil
    return npcData
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
    return data.Souls[uuid]
end

function DynamicTrading_Roster.GetSoul(uuid)
    local soulKey = "DTSOUL_" .. uuid
    if ModData.exists(soulKey) then
        return stripMovementSpeed(ModData.get(soulKey))
    end

    local registry = DynamicTrading_Roster.GetSoulRegistry(uuid)
    if registry and registry.name then
        return stripMovementSpeed(registry)
    end

    return nil
end

function DynamicTrading_Roster.SaveSoul(uuid, npcData)
    npcData = stripMovementSpeed(npcData)

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
        health = npcData.health or 1.0,
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
        isPlayerFactionTrader = npcData.isPlayerFactionTrader == true
    }
end
