-- ==============================================================================
-- DTNPC_LootSearch_Client.lua
-- Client-side loot search cache, blacklist, and server sync handling.
-- ==============================================================================

DTNPCLootSearchClient = DTNPCLootSearchClient or {}

if DTNPCLootSearchClient.Loaded then
    return
end

DTNPCLootSearchClient.Loaded = true
DTNPCLootSearchClient.Cache = DTNPCLootSearchClient.Cache or {}

local function findCacheByName(name)
    local normalized = tostring(name or "")
    if normalized == "" then
        return nil
    end

    for _, cache in pairs(DTNPCLootSearchClient.Cache) do
        if tostring(cache and cache.npcName or "") == normalized then
            return cache
        end
    end

    return nil
end

local function isEligibleCompanion(npcData)
    local uuid = type(npcData) == "table" and tostring(npcData.uuid or "") or ""
    local cache = uuid ~= "" and DTNPCLootSearchClient.Cache[uuid] or nil
    return type(npcData) == "table"
        and (
            (tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
                and tostring(npcData.linkedWorkerID or "") ~= "")
            or (cache and cache.dynamicColoniesExclusive == true)
        )
end

local function getPlayerObj(playerNum)
    return getSpecificPlayer(tonumber(playerNum) or 0)
end

local function getBlacklistTable(playerObj)
    local modData = playerObj and playerObj:getModData() or nil
    if not modData then
        return {}
    end

    modData.DTV2LootSearchBlacklist = type(modData.DTV2LootSearchBlacklist) == "table"
        and modData.DTV2LootSearchBlacklist
        or {}
    return modData.DTV2LootSearchBlacklist
end

function DTNPCLootSearchClient.IsBlacklisted(playerObj, fullType)
    return getBlacklistTable(playerObj)[tostring(fullType or "")] == true
end

function DTNPCLootSearchClient.ToggleBlacklist(playerObj, fullType)
    local normalized = tostring(fullType or "")
    if normalized == "" then
        return false
    end

    local blacklist = getBlacklistTable(playerObj)
    blacklist[normalized] = not blacklist[normalized]
    if playerObj and playerObj.transmitModData then
        playerObj:transmitModData()
    end
    return blacklist[normalized] == true
end

function DTNPCLootSearchClient.GetCache(uuid)
    if not uuid then
        return nil
    end
    return DTNPCLootSearchClient.Cache[tostring(uuid)] or nil
end

function DTNPCLootSearchClient.FindCache(npcData)
    if type(npcData) ~= "table" then
        return nil
    end

    local uuid = tostring(npcData.uuid or "")
    if uuid ~= "" and DTNPCLootSearchClient.Cache[uuid] then
        return DTNPCLootSearchClient.Cache[uuid]
    end

    return findCacheByName(npcData.name)
end

function DTNPCLootSearchClient.SetCache(args)
    if not args or not args.uuid then
        return nil
    end

    local cache = {
        uuid = args.uuid,
        npcName = args.npcName,
        state = args.state,
        status = args.status,
        currentSourceKey = args.currentSourceKey,
        sources = type(args.sources) == "table" and args.sources or {},
        workerCarry = type(args.workerCarry) == "table" and args.workerCarry or nil,
        autoOpen = args.autoOpen == true,
        dynamicColoniesExclusive = args.dynamicColoniesExclusive == true,
    }
    DTNPCLootSearchClient.Cache[tostring(args.uuid)] = cache
    return cache
end

function DTNPCLootSearchClient.RequestSync(player, npcData)
    if not player or not isEligibleCompanion(npcData) or not npcData.uuid then
        return false
    end

    sendClientCommand(player, "DTNPC", "LootSearchOpen", {
        uuid = npcData.uuid,
    })
    return true
end

function DTNPCLootSearchClient.RequestCollect(player, npcData, sourceKey, itemKeys)
    if not player or not isEligibleCompanion(npcData) or not npcData.uuid or not sourceKey or type(itemKeys) ~= "table" or #itemKeys <= 0 then
        return false
    end

    sendClientCommand(player, "DTNPC", "LootSearchCollect", {
        uuid = npcData.uuid,
        sourceKey = sourceKey,
        itemKeys = itemKeys,
    })
    return true
end

function DTNPCLootSearchClient.RequestModeToggle(player, npcData)
    if not player or not isEligibleCompanion(npcData) or not npcData.uuid then
        return false
    end

    if tostring(npcData.state or "") == "LootNearby" then
        sendClientCommand(player, "DTNPC", "Order", {
            uuid = npcData.uuid,
            state = "Follow",
            returnStatus = "Resting",
        })
        return true
    end

    sendClientCommand(player, "DTNPC", "Order", {
        uuid = npcData.uuid,
        state = "LootNearby",
        x = player:getX(),
        y = player:getY(),
        z = player:getZ(),
        lootRadius = npcData.dcLootConfig and npcData.dcLootConfig.radius or npcData.dcLootRadius,
        combatOrder = npcData.combatOrder,
        returnStatus = "Resting",
    })
    return true
end

function DTNPCLootSearchClient.OpenForNPC(playerNum, npcData)
    if not isEligibleCompanion(npcData) then
        return nil
    end
    require "DT/V2/NPC/LootSearch/DTNPC_LootSearch_Window"
    if DTNPCLootSearchWindow and DTNPCLootSearchWindow.Open then
        return DTNPCLootSearchWindow.Open(playerNum, npcData)
    end
    return nil
end

function DTNPCLootSearchClient.HandleSync(args)
    local cache = DTNPCLootSearchClient.SetCache(args)
    if not cache then
        return
    end

    if DTNPCLootSearchWindow and DTNPCLootSearchWindow.instance then
        if DTNPCLootSearchWindow.instance.npcData then
            DTNPCLootSearchWindow.instance.npcData.uuid = cache.uuid or DTNPCLootSearchWindow.instance.npcData.uuid
            DTNPCLootSearchWindow.instance.npcData.name = cache.npcName or DTNPCLootSearchWindow.instance.npcData.name
        end
        DTNPCLootSearchWindow.instance:refreshFromCache(cache)
    end

    if cache.autoOpen then
        local window = DTNPCLootSearchClient.OpenForNPC(0, {
            uuid = cache.uuid,
            name = cache.npcName,
        })
        if window and window.refreshFromCache then
            window:refreshFromCache(cache)
        end
    end
end
