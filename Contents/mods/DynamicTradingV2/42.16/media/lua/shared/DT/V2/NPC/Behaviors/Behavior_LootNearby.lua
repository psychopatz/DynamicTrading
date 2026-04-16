-- ==============================================================================
-- Behavior_LootNearby.lua
-- Anchored companion looting with protect-style combat interruption.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLootDebug = DTNPCLootDebug or {}

require "DT/V2/NPC/Sys/DTNPC_Protect"
require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

pcall(require, "DC/Common/Colony/ColonyConfig/DC_ColonyConfig")
pcall(require, "DC/Common/Colony/ColonyRegistry/DC_ColonyRegistry")
pcall(require, "DC/Common/Colony/ColonyNetwork/DC_ColonyNetwork")
pcall(require, "DC/Common/Colony/Job/Scavenging/DC_Job_Scavenging_ConfigLogic")
pcall(require, "DC/Common/Colony/Job/Scavenging/DC_Job_Scavenging_ConfigData")
pcall(require, "DC/Common/Colony/Job/Scavenging/DC_Job_Scavenging_ConfigProfiles")

local LOOT_MOVE_SPEED = 0.045
local LOOT_STOP_DISTANCE = 1.15
local LOOT_VEHICLE_STOP_DISTANCE = 1.8
local LOOT_MOVE_STUCK_TICKS = 12
local LOOT_MOVE_ABORT_TICKS = 30
local LOOT_THREAT_RADIUS = 10
local LOOT_THREAT_LEASH_BONUS = 2
local LOOT_SYNC_COOLDOWN_MS = 1250
local LOOT_MAX_ITEM_CANDIDATES = 48
local LOOT_DEBUG_ENABLED = true

-- Forward references for local functions defined later in the file
local itemMatchesLootFilter
local resolveLootTargetContainer
local resolveLootTargetGroundItem

local function buildPointTarget(x, y, z)
    if x == nil or y == nil then
        return nil
    end

    local px = tonumber(x)
    local py = tonumber(y)
    local pz = tonumber(z) or 0
    return {
        getX = function() return px end,
        getY = function() return py end,
        getZ = function() return pz end,
    }
end

local function nowMillis()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end
    local gameTime = getGameTime and getGameTime() or nil
    if gameTime and gameTime.getWorldAgeHours then
        return math.floor((tonumber(gameTime:getWorldAgeHours()) or 0) * 3600000)
    end
    return 0
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function getDistance(ax, ay, bx, by)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dy = (tonumber(ay) or 0) - (tonumber(by) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

local function isLootTileSafe(x, y, z)
    if DTNPCMobility and DTNPCMobility.IsTileSafe then
        return DTNPCMobility.IsTileSafe(x, y, z)
    end

    local cell = getCell and getCell() or nil
    local square = cell and cell:getGridSquare(x, y, z or 0) or nil
    if not square then
        return true
    end
    if not square:isFree(false) then
        return false
    end
    if square:isSolid() or square:isSolidTrans() then
        return false
    end
    return true
end

local function shouldUseAdjacentApproach(target)
    return type(target) == "table" and (target.kind == "world" or target.kind == "vehicle")
end

local function resolveLootApproachPoint(target, zombie)
    if type(target) ~= "table" then
        return nil
    end

    local targetX = tonumber(target.x)
    local targetY = tonumber(target.y)
    local targetZ = tonumber(target.z) or 0
    if targetX == nil or targetY == nil then
        return nil
    end

    if not shouldUseAdjacentApproach(target) then
        return {
            x = targetX,
            y = targetY,
            z = targetZ,
            stopDistance = tonumber(target.stopDistance) or LOOT_STOP_DISTANCE,
        }
    end

    local candidates = {
        { x = targetX - 1, y = targetY, z = targetZ },
        { x = targetX + 1, y = targetY, z = targetZ },
        { x = targetX, y = targetY - 1, z = targetZ },
        { x = targetX, y = targetY + 1, z = targetZ },
        { x = targetX - 1, y = targetY - 1, z = targetZ },
        { x = targetX + 1, y = targetY - 1, z = targetZ },
        { x = targetX - 1, y = targetY + 1, z = targetZ },
        { x = targetX + 1, y = targetY + 1, z = targetZ },
        { x = targetX, y = targetY, z = targetZ },
    }

    local zombieX = zombie and zombie.getX and zombie:getX() or targetX
    local zombieY = zombie and zombie.getY and zombie:getY() or targetY
    local bestCandidate = nil
    local bestDistance = nil

    for _, candidate in ipairs(candidates) do
        if isLootTileSafe(candidate.x, candidate.y, candidate.z) then
            local candidateDistance = getDistance(zombieX, zombieY, candidate.x, candidate.y)
            if not bestCandidate or candidateDistance < bestDistance then
                bestCandidate = candidate
                bestDistance = candidateDistance
            end
        end
    end

    if bestCandidate then
        bestCandidate.stopDistance = 0.55
        return bestCandidate
    end

    return {
        x = targetX,
        y = targetY,
        z = targetZ,
        stopDistance = tonumber(target.stopDistance) or LOOT_STOP_DISTANCE,
    }
end

local function ensureLootApproachPoint(target, zombie)
    if type(target) ~= "table" then
        return nil
    end

    local approach = resolveLootApproachPoint(target, zombie)
    if not approach then
        return nil
    end

    target.approachX = approach.x
    target.approachY = approach.y
    target.approachZ = approach.z
    target.approachStopDistance = approach.stopDistance
    return approach
end

local function lootDebugLog(npcData, worker, stage, message)
    if not LOOT_DEBUG_ENABLED then
        return
    end

    local name = tostring(npcData and npcData.name or worker and worker.name or "Unknown")
    local uuid = tostring(npcData and npcData.uuid or "nil")
    local workerID = tostring(worker and worker.workerID or npcData and npcData.linkedWorkerID or "nil")
    local text = "[DTV2 Loot Debug][" .. tostring(stage or "Trace") .. "][" .. name .. "][uuid=" .. uuid .. "][workerID=" .. workerID .. "] " .. tostring(message or "")
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTV2", "NPC", "LootDebug", text)
    else
        print(text)
    end
end

local function lootDebugLogChanged(npcData, worker, cacheKey, stage, message)
    if not LOOT_DEBUG_ENABLED then
        return
    end

    if not npcData then
        lootDebugLog(npcData, worker, stage, message)
        return
    end

    npcData.dcLootDebugMessages = npcData.dcLootDebugMessages or {}
    if npcData.dcLootDebugMessages[cacheKey] == message then
        return
    end

    npcData.dcLootDebugMessages[cacheKey] = message
    lootDebugLog(npcData, worker, stage, message)
end

local function formatTargetDebug(target)
    if type(target) ~= "table" then
        return "nil"
    end

    return tostring(target.kind or "?")
        .. " key=" .. tostring(target.key or "nil")
        .. " pos=" .. tostring(target.x or "?") .. "," .. tostring(target.y or "?") .. "," .. tostring(target.z or 0)
        .. " approach=" .. tostring(target.approachX or target.x or "?") .. "," .. tostring(target.approachY or target.y or "?") .. "," .. tostring(target.approachZ or target.z or 0)
        .. " stop=" .. tostring(target.stopDistance or "?")
end

local function formatSourceConfigDebug(config)
    if type(config) ~= "table" then
        return "no-config"
    end

    return table.concat({
        "radius=" .. tostring(config.radius or "nil"),
        "groundItems=" .. tostring(config.includeLooseWorldItems ~= false),
        "groundBags=" .. tostring(config.includeGroundContainers ~= false),
        "furniture=" .. tostring(config.includeFurnitureContainers ~= false),
        "corpses=" .. tostring(config.includeCorpseContainers ~= false),
        "vehicles=" .. tostring(config.includeVehicleContainers ~= false),
        "profile=" .. tostring(config.profileID or "nil"),
        "rawTags=" .. tostring(#(config.rawTags or {})),
    }, " ")
end

local function getItemDisplayName(invItem)
    if not invItem then
        return "nil"
    end

    return tostring(invItem.getDisplayName and invItem:getDisplayName() or invItem.getFullType and invItem:getFullType() or "unknown-item")
end

local function getInventoryItemID(invItem)
    if not invItem then
        return nil
    end
    if invItem.getID then
        return tonumber(invItem:getID())
    end
    return nil
end

local function summarizeContainerItems(container, filterContext, limit)
    local items = container and container.getItems and container:getItems() or nil
    if not items then
        return "items=0"
    end

    local names = {}
    local maxCount = math.max(1, tonumber(limit) or 5)
    local matched = 0
    for index = 0, items:size() - 1 do
        local invItem = items:get(index)
        if invItem and #names < maxCount then
            names[#names + 1] = getItemDisplayName(invItem)
        end
        if invItem and filterContext and itemMatchesLootFilter(invItem, filterContext) then
            matched = matched + 1
        end
    end

    local suffix = items:size() > #names and (", ... +" .. tostring(items:size() - #names)) or ""
    return "items=" .. tostring(items:size())
        .. " matched=" .. tostring(matched)
        .. " preview=[" .. table.concat(names, ", ") .. suffix .. "]"
end

local function describeLootTarget(target, filterContext)
    if type(target) ~= "table" then
        return "nil-target"
    end

    local itemLabel = ""
    if target.lootDisplayName or target.lootFullType then
        itemLabel = " item=" .. tostring(target.lootDisplayName or target.lootFullType)
    end

    if target.kind == "groundItem" then
        local invItem = resolveLootTargetGroundItem(target)
        return "Ground Item " .. getItemDisplayName(invItem) .. itemLabel
    end

    local container = resolveLootTargetContainer(target)
    if target.kind == "bag" then
        local cell = getCell and getCell() or nil
        local square = cell and cell:getGridSquare(tonumber(target.x) or 0, tonumber(target.y) or 0, tonumber(target.z) or 0) or nil
        local label = "Ground Bag"
        if square and square.getWorldObjects then
            local worldObjects = square:getWorldObjects()
            for index = 0, worldObjects:size() - 1 do
                local worldObject = worldObjects:get(index)
                local item = worldObject and worldObject.getItem and worldObject:getItem() or nil
                if item and tonumber(item.getID and item:getID() or 0) == tonumber(target.itemID) then
                    label = getItemDisplayName(item)
                    break
                end
            end
        end
        return label .. itemLabel .. " | " .. summarizeContainerItems(container, filterContext, 5)
    end

    if target.kind == "corpse" then
        return "Corpse" .. itemLabel .. " | " .. summarizeContainerItems(container, filterContext, 6)
    end

    if target.kind == "vehicle" then
        local containerType = container and container.getType and container:getType() or "VehicleContainer"
        return tostring(containerType) .. itemLabel .. " | " .. summarizeContainerItems(container, filterContext, 5)
    end

    if target.kind == "world" then
        local containerType = container and container.getType and container:getType() or "WorldContainer"
        return tostring(containerType) .. itemLabel .. " | " .. summarizeContainerItems(container, filterContext, 5)
    end

    return tostring(target.kind or "unknown") .. itemLabel .. " | " .. summarizeContainerItems(container, filterContext, 5)
end

local function normalizeLootConfig(npcData)
    local config = type(npcData and npcData.dcLootConfig) == "table" and npcData.dcLootConfig or {}
    local includeWorldContainers = config.includeWorldContainers ~= false
    local includeLooseWorldItems = config.includeLooseWorldItems ~= nil
        and config.includeLooseWorldItems ~= false
        or (config.includeLooseWorldItems == nil and includeWorldContainers)
    local includeGroundContainers = config.includeGroundContainers ~= nil
        and config.includeGroundContainers ~= false
        or (config.includeGroundContainers == nil and includeWorldContainers)
    local includeFurnitureContainers = config.includeFurnitureContainers ~= nil
        and config.includeFurnitureContainers ~= false
        or (config.includeFurnitureContainers == nil and includeWorldContainers)
    return {
        radius = math.max(2, math.min(25, math.floor(tonumber(npcData and npcData.dcLootRadius or config.radius) or 10))),
        includeWorldContainers = includeWorldContainers,
        includeLooseWorldItems = includeLooseWorldItems,
        includeGroundContainers = includeGroundContainers,
        includeFurnitureContainers = includeFurnitureContainers,
        includeCorpseContainers = config.includeCorpseContainers ~= false,
        includeVehicleContainers = config.includeVehicleContainers ~= false,
        profileID = tostring(config.profileID or "") ~= "" and tostring(config.profileID) or nil,
        rawTags = type(config.rawTags) == "table" and config.rawTags or {},
    }
end

local function clearLootTarget(npcData, nextStatus)
    if not npcData then
        return
    end

    npcData.dcLootTarget = nil
    npcData.dcLootTargetKey = nil
    npcData.dcLootMoveBlockedTicks = 0
    npcData.isMovingState = false
    if nextStatus ~= nil then
        npcData.dcLootStatus = nextStatus
    end
end

local function markLootContainerVisited(npcData, key)
    if not npcData or not key then
        return
    end

    npcData.dcLootVisited = type(npcData.dcLootVisited) == "table" and npcData.dcLootVisited or {}
    npcData.dcLootVisited[key] = true
end

local function isLootContainerVisited(npcData, key)
    return type(npcData and npcData.dcLootVisited) == "table" and npcData.dcLootVisited[key] == true
end

local function getColonyApis()
    local colony = DC_Colony or nil
    return {
        config = colony and colony.Config or nil,
        registry = colony and colony.Registry or nil,
        network = colony and colony.Network or nil,
    }
end

local function getLinkedWorker(npcData)
    local apis = getColonyApis()
    local registry = apis.registry
    if not registry or not registry.GetWorker or not npcData or not npcData.linkedWorkerID then
        return nil, apis
    end

    return registry.GetWorker(npcData.linkedWorkerID), apis
end

local function addUniqueTag(result, seen, tag)
    local normalized = tostring(tag or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if normalized == "" or seen[normalized] then
        return
    end
    seen[normalized] = true
    result[#result + 1] = normalized
end

local function buildPresetTags(config, colonyConfig)
    local result = {}
    local seen = {}
    if not colonyConfig or not config or not config.profileID then
        return result
    end

    local profile = colonyConfig.GetScavengeSiteProfile and colonyConfig.GetScavengeSiteProfile(config.profileID) or nil
    local ruleWeights = type(profile and profile.ruleWeights) == "table" and profile.ruleWeights or nil
    for _, rule in ipairs(colonyConfig.ScavengeLootRules or {}) do
        local weight = ruleWeights and tonumber(ruleWeights[rule.id]) or 0
        if weight and weight > 0 then
            for _, tag in ipairs(rule.tags or {}) do
                addUniqueTag(result, seen, tag)
            end
        end
    end

    return result
end

local function buildLootFilterContext(npcData)
    local apis = getColonyApis()
    local colonyConfig = apis.config
    local config = normalizeLootConfig(npcData)
    local presetTags = buildPresetTags(config, colonyConfig)
    local rawTags = {}
    local seen = {}

    for _, tag in ipairs(config.rawTags or {}) do
        addUniqueTag(rawTags, seen, tag)
    end

    return {
        config = config,
        presetTags = presetTags,
        rawTags = rawTags,
        hasAnyFilter = (#presetTags > 0) or (#rawTags > 0),
        colonyConfig = colonyConfig,
        apis = apis,
    }
end

local function getItemTags(fullType, filterContext)
    local colonyConfig = filterContext and filterContext.colonyConfig or nil
    if colonyConfig and colonyConfig.GetItemCombinedTags then
        return colonyConfig.GetItemCombinedTags(fullType) or {}
    end
    if colonyConfig and colonyConfig.FindItemTags then
        return colonyConfig.FindItemTags(fullType) or {}
    end

    local masterList = DynamicTrading and DynamicTrading.Config and DynamicTrading.Config.MasterList or nil
    local entry = masterList and masterList[fullType] or nil
    return type(entry and entry.tags) == "table" and entry.tags or {}
end

local function tagMatches(itemTags, queryTag, filterContext)
    local colonyConfig = filterContext and filterContext.colonyConfig or nil
    if colonyConfig and colonyConfig.HasMatchingTag then
        return colonyConfig.HasMatchingTag(itemTags, queryTag)
    end
    if DynamicTrading and DynamicTrading.Economy and DynamicTrading.Economy.Common and DynamicTrading.Economy.Common.HasMatchingTag then
        return DynamicTrading.Economy.Common.HasMatchingTag(itemTags, queryTag)
    end

    local normalizedQuery = tostring(queryTag or "")
    for _, itemTag in ipairs(itemTags or {}) do
        if itemTag == normalizedQuery or string.find(tostring(itemTag), normalizedQuery .. "%.") == 1 then
            return true
        end
    end
    return false
end

itemMatchesLootFilter = function(invItem, filterContext)
    if not invItem or not filterContext or not filterContext.hasAnyFilter then
        return false
    end

    local fullType = invItem.getFullType and invItem:getFullType() or nil
    if not fullType then
        return false
    end

    local itemTags = getItemTags(fullType, filterContext)
    for _, tag in ipairs(filterContext.rawTags or {}) do
        if tagMatches(itemTags, tag, filterContext) then
            return true
        end
    end
    for _, tag in ipairs(filterContext.presetTags or {}) do
        if tagMatches(itemTags, tag, filterContext) then
            return true
        end
    end
    return false
end

local function getInventoryItemQuantity(invItem)
    local count = invItem and invItem.getCount and tonumber(invItem:getCount()) or 1
    if count and count > 1 then
        return math.max(1, math.floor(count))
    end
    return 1
end

local function getDebugItemLootability(invItem, filterContext, worker, registry)
    if not invItem then
        return false, "invalid", 0, 0
    end

    local requestedQty = getInventoryItemQuantity(invItem)

    if not filterContext then
        return false, "no-context", 0, requestedQty
    end

    if not filterContext.hasAnyFilter then
        return false, "no-filter", 0, requestedQty
    end

    if not itemMatchesLootFilter(invItem, filterContext) then
        return false, "filtered", 0, requestedQty
    end

    if not worker or not registry or not registry.GetFittingInventoryQuantity then
        return true, "filter-match", requestedQty, requestedQty
    end

    local fitQty = registry.GetFittingInventoryQuantity(worker, invItem:getFullType(), requestedQty) or 0
    if fitQty <= 0 then
        return false, "no-capacity", fitQty, requestedQty
    end

    return true, "lootable", fitQty, requestedQty
end

local function appendDebugItemEntry(result, invItem, prefix, depth, limit, filterContext, worker, registry)
    if not invItem or #result >= limit then
        return
    end

    local labelPrefix = tostring(prefix or "")
    local lootable, lootReason, fitQty, requestedQty = getDebugItemLootability(invItem, filterContext, worker, registry)
    result[#result + 1] = {
        displayName = labelPrefix .. getItemDisplayName(invItem),
        fullType = invItem.getFullType and invItem:getFullType() or nil,
        quantity = getInventoryItemQuantity(invItem),
        depth = tonumber(depth) or 0,
        lootable = lootable,
        lootReason = lootReason,
        fitQty = fitQty,
        requestedQty = requestedQty,
    }
end

local function collectDebugItemsRecursive(container, result, prefix, depth, limit, filterContext, worker, registry)
    if not container or #result >= limit then
        return
    end

    local items = container.getItems and container:getItems() or nil
    if not items then
        return
    end

    for index = 0, items:size() - 1 do
        if #result >= limit then
            return
        end

        local invItem = items:get(index)
        if invItem then
            appendDebugItemEntry(result, invItem, prefix, depth, limit, filterContext, worker, registry)

            local nestedInventory = invItem.getInventory and invItem:getInventory() or nil
            if nestedInventory and #result < limit then
                local nestedPrefix = tostring(prefix or "") .. getItemDisplayName(invItem) .. " > "
                collectDebugItemsRecursive(nestedInventory, result, nestedPrefix, (tonumber(depth) or 0) + 1, limit, filterContext, worker, registry)
            end
        end
    end
end

local function getDebugItemsFromContainer(container, limit, filterContext, worker, registry)
    local result = {}
    collectDebugItemsRecursive(container, result, "", 0, math.max(1, tonumber(limit) or 40), filterContext, worker, registry)
    return result
end

local function buildDebugSourceEntry(kind, x, y, z, key, label, distance, items)
    return {
        kind = kind,
        x = x,
        y = y,
        z = z or 0,
        key = key,
        label = label,
        distance = distance or 0,
        items = items or {},
    }
end

local function sortDebugSources(sources)
    table.sort(sources, function(a, b)
        if math.abs((a.distance or 0) - (b.distance or 0)) > 0.05 then
            return (a.distance or 0) < (b.distance or 0)
        end
        return tostring(a.key or "") < tostring(b.key or "")
    end)
end

function DTNPCLootDebug.ScanNearbySources(player, npcData, radiusOverride)
    if not player then
        return {
            sources = {},
            totalSources = 0,
            totalItems = 0,
            radius = tonumber(radiusOverride) or 0,
        }
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return {
            sources = {},
            totalSources = 0,
            totalItems = 0,
            radius = tonumber(radiusOverride) or 0,
        }
    end

    local mockNpcData = type(npcData) == "table" and npcData or {}
    if radiusOverride ~= nil then
        mockNpcData = {}
        for key, value in pairs(type(npcData) == "table" and npcData or {}) do
            mockNpcData[key] = value
        end
        mockNpcData.dcLootRadius = radiusOverride
    end

    local config = normalizeLootConfig(mockNpcData)
    local filterContext = nil
    local worker = nil
    local registry = nil
    if type(npcData) == "table" then
        filterContext = buildLootFilterContext(mockNpcData)
        worker = getLinkedWorker(mockNpcData)
        local apis = filterContext and filterContext.apis or getColonyApis()
        registry = apis and apis.registry or nil
    end
    local radius = math.max(1, math.min(25, math.floor(tonumber(config.radius) or 10)))
    local anchorX = math.floor(player:getX())
    local anchorY = math.floor(player:getY())
    local anchorZ = math.floor(player:getZ())
    local sources = {}
    local seenVehicles = {}
    local totalItems = 0
    local itemLimitPerSource = 40

    for y = anchorY - radius, anchorY + radius do
        for x = anchorX - radius, anchorX + radius do
            local square = cell:getGridSquare(x, y, anchorZ)
            if square then
                local distance = getDistance(anchorX, anchorY, x, y)

                if config.includeWorldContainers then
                    local worldObjects = square:getWorldObjects()
                    if worldObjects then
                        for index = 0, worldObjects:size() - 1 do
                            local worldObject = worldObjects:get(index)
                            local item = worldObject and worldObject.getItem and worldObject:getItem() or nil
                            local inventory = item and item.getInventory and item:getInventory() or nil

                            if item and inventory and lower(item.getCategory and item:getCategory() or "") == "container"
                                and config.includeGroundContainers then
                                local debugItems = getDebugItemsFromContainer(inventory, itemLimitPerSource, filterContext, worker, registry)
                                totalItems = totalItems + #debugItems
                                sources[#sources + 1] = buildDebugSourceEntry(
                                    "bag",
                                    x,
                                    y,
                                    anchorZ,
                                    "bag:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(item:getID()),
                                    getItemDisplayName(item),
                                    distance,
                                    debugItems
                                )
                            elseif item and not inventory and config.includeLooseWorldItems then
                                local lootable, lootReason, fitQty, requestedQty = getDebugItemLootability(item, filterContext, worker, registry)
                                local debugItems = {
                                    {
                                        displayName = getItemDisplayName(item),
                                        fullType = item.getFullType and item:getFullType() or nil,
                                        quantity = getInventoryItemQuantity(item),
                                        depth = 0,
                                        lootable = lootable,
                                        lootReason = lootReason,
                                        fitQty = fitQty,
                                        requestedQty = requestedQty,
                                    }
                                }
                                totalItems = totalItems + 1
                                sources[#sources + 1] = buildDebugSourceEntry(
                                    "groundItem",
                                    x,
                                    y,
                                    anchorZ,
                                    "groundItem:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(item:getID()),
                                    "Ground Item",
                                    distance,
                                    debugItems
                                )
                            end
                        end
                    end

                    if config.includeFurnitureContainers then
                        local objects = square:getObjects()
                        if objects then
                            for objectIndex = 0, objects:size() - 1 do
                                local object = objects:get(objectIndex)
                                local containerCount = object and object.getContainerCount and tonumber(object:getContainerCount()) or 0
                                for containerIndex = 0, math.max(0, containerCount - 1) do
                                    local container = object and object.getContainerByIndex and object:getContainerByIndex(containerIndex) or nil
                                    local items = container and container.getItems and container:getItems() or nil
                                    if items and items:size() > 0 then
                                        local debugItems = getDebugItemsFromContainer(container, itemLimitPerSource, filterContext, worker, registry)
                                        totalItems = totalItems + #debugItems
                                        local label = container.getType and tostring(container:getType()) or "WorldContainer"
                                        sources[#sources + 1] = buildDebugSourceEntry(
                                            "world",
                                            x,
                                            y,
                                            anchorZ,
                                            "world:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(objectIndex) .. ":" .. tostring(containerIndex),
                                            label,
                                            distance,
                                            debugItems
                                        )
                                    end
                                end
                            end
                        end
                    end
                end

                if config.includeCorpseContainers then
                    local staticObjects = square:getStaticMovingObjects()
                    if staticObjects then
                        for index = 0, staticObjects:size() - 1 do
                            local staticObject = staticObjects:get(index)
                            local container = staticObject and staticObject.getContainer and staticObject:getContainer() or nil
                            local items = container and container.getItems and container:getItems() or nil
                            if items and items:size() > 0 then
                                local debugItems = getDebugItemsFromContainer(container, itemLimitPerSource, filterContext, worker, registry)
                                totalItems = totalItems + #debugItems
                                sources[#sources + 1] = buildDebugSourceEntry(
                                    "corpse",
                                    x,
                                    y,
                                    anchorZ,
                                    "corpse:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(staticObject:getID()),
                                    "Corpse",
                                    distance,
                                    debugItems
                                )
                            end
                        end
                    end
                end

                if config.includeVehicleContainers then
                    local vehicle = square:getVehicleContainer()
                    if vehicle and not seenVehicles[vehicle] then
                        seenVehicles[vehicle] = true
                        local vehicleID = vehicle.getId and vehicle:getId()
                            or vehicle.getID and vehicle:getID()
                            or tostring(vehicle)
                        for partIndex = 0, vehicle:getPartCount() - 1 do
                            local vehiclePart = vehicle:getPartByIndex(partIndex)
                            local container = vehiclePart and vehiclePart.getItemContainer and vehiclePart:getItemContainer() or nil
                            local items = container and container.getItems and container:getItems() or nil
                            if items and items:size() > 0 then
                                local debugItems = getDebugItemsFromContainer(container, itemLimitPerSource, filterContext, worker, registry)
                                totalItems = totalItems + #debugItems
                                local label = container.getType and tostring(container:getType()) or "VehicleContainer"
                                sources[#sources + 1] = buildDebugSourceEntry(
                                    "vehicle",
                                    x,
                                    y,
                                    anchorZ,
                                    "vehicle:" .. tostring(vehicleID) .. ":" .. tostring(partIndex),
                                    label,
                                    distance,
                                    debugItems
                                )
                            end
                        end
                    end
                end
            end
        end
    end

    sortDebugSources(sources)

    return {
        sources = sources,
        totalSources = #sources,
        totalItems = totalItems,
        radius = radius,
        center = { x = anchorX, y = anchorY, z = anchorZ },
        filterActive = filterContext and filterContext.hasAnyFilter or false,
        filterPresetCount = filterContext and #(filterContext.presetTags or {}) or 0,
        filterRawCount = filterContext and #(filterContext.rawTags or {}) or 0,
        workerName = worker and worker.name or nil,
        workerID = worker and worker.workerID or nil,
    }
end

local function copyLootTarget(baseTarget)
    local copy = {}
    for key, value in pairs(baseTarget or {}) do
        copy[key] = value
    end
    return copy
end

local function appendMatchedItemCandidate(candidates, baseTarget, invItem, requestedQty, fitQty)
    if not baseTarget or not invItem or fitQty <= 0 then
        return
    end

    local itemID = getInventoryItemID(invItem)
    local candidate = copyLootTarget(baseTarget)
    candidate.key = tostring(baseTarget.key) .. ":item:" .. tostring(itemID or invItem:getFullType() or "unknown")
    candidate.lootItemID = itemID
    candidate.lootFullType = invItem.getFullType and invItem:getFullType() or nil
    candidate.lootDisplayName = getItemDisplayName(invItem)
    candidate.requestedQty = requestedQty
    candidate.fitQty = fitQty
    candidates[#candidates + 1] = candidate
end

local function collectMatchingItemsRecursive(candidates, baseTarget, container, filterContext, worker, registry, limit)
    if not container or not filterContext or not filterContext.hasAnyFilter then
        return
    end

    local items = container.getItems and container:getItems() or nil
    if not items then
        return
    end

    for index = 0, items:size() - 1 do
        if #candidates >= limit then
            return
        end

        local invItem = items:get(index)
        if invItem then
            if itemMatchesLootFilter(invItem, filterContext) then
                local requestedQty = getInventoryItemQuantity(invItem)
                local fitQty = registry and registry.GetFittingInventoryQuantity
                    and registry.GetFittingInventoryQuantity(worker, invItem:getFullType(), requestedQty)
                    or requestedQty
                if fitQty > 0 then
                    appendMatchedItemCandidate(candidates, baseTarget, invItem, requestedQty, fitQty)
                end
            end

            local nestedInventory = invItem.getInventory and invItem:getInventory() or nil
            if nestedInventory and #candidates < limit then
                collectMatchingItemsRecursive(candidates, baseTarget, nestedInventory, filterContext, worker, registry, limit)
            end
        end
    end
end

local function findItemInContainerRecursive(container, lootItemID, lootFullType)
    if not container then
        return nil
    end

    local items = container.getItems and container:getItems() or nil
    if not items then
        return nil
    end

    for index = 0, items:size() - 1 do
        local invItem = items:get(index)
        if invItem then
            local invItemID = getInventoryItemID(invItem)
            if (lootItemID ~= nil and invItemID == lootItemID)
                or (lootItemID == nil and lootFullType ~= nil and invItem.getFullType and invItem:getFullType() == lootFullType) then
                return invItem
            end

            local nestedInventory = invItem.getInventory and invItem:getInventory() or nil
            local nestedItem = nestedInventory and findItemInContainerRecursive(nestedInventory, lootItemID, lootFullType) or nil
            if nestedItem then
                return nestedItem
            end
        end
    end

    return nil
end

local function findMatchingItemRecursive(container, filterContext, worker, registry)
    if not container or not filterContext or not filterContext.hasAnyFilter then
        return nil, 0
    end

    local items = container.getItems and container:getItems() or nil
    if not items then
        return nil, 0
    end

    for index = 0, items:size() - 1 do
        local invItem = items:get(index)
        local nestedInventory = invItem and invItem.getInventory and invItem:getInventory() or nil
        if nestedInventory then
            local nestedItem, nestedQty = findMatchingItemRecursive(nestedInventory, filterContext, worker, registry)
            if nestedItem and nestedQty > 0 then
                return nestedItem, nestedQty
            end
        end

        if invItem and itemMatchesLootFilter(invItem, filterContext) then
            local requestedQty = getInventoryItemQuantity(invItem)
            local fitQty = registry and registry.GetFittingInventoryQuantity
                and registry.GetFittingInventoryQuantity(worker, invItem:getFullType(), requestedQty)
                or requestedQty
            if fitQty > 0 then
                return invItem, fitQty
            end
        end
    end

    return nil, 0
end

resolveLootTargetContainer = function(target)
    if type(target) ~= "table" then
        return nil
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return nil
    end

    local square = cell:getGridSquare(tonumber(target.x) or 0, tonumber(target.y) or 0, tonumber(target.z) or 0)
    if not square then
        return nil
    end

    if target.kind == "world" then
        local objects = square:getObjects()
        if not objects then
            return nil
        end
        local object = objects:get(tonumber(target.objectIndex) or -1)
        if not object or not object.getContainerByIndex then
            return nil
        end
        return object:getContainerByIndex(tonumber(target.containerIndex) or 0)
    end

    if target.kind == "bag" then
        local worldObjects = square:getWorldObjects()
        if not worldObjects then
            return nil
        end
        local itemID = tonumber(target.itemID)
        for index = 0, worldObjects:size() - 1 do
            local worldObject = worldObjects:get(index)
            local item = worldObject and worldObject.getItem and worldObject:getItem() or nil
            if item and tonumber(item.getID and item:getID() or 0) == itemID then
                return item.getInventory and item:getInventory() or nil
            end
        end
        return nil
    end

    if target.kind == "corpse" then
        local staticObjects = square:getStaticMovingObjects()
        if not staticObjects then
            return nil
        end
        local objectID = tonumber(target.objectID)
        for index = 0, staticObjects:size() - 1 do
            local staticObject = staticObjects:get(index)
            if staticObject and tonumber(staticObject.getID and staticObject:getID() or 0) == objectID then
                return staticObject.getContainer and staticObject:getContainer() or nil
            end
        end
        return nil
    end

    if target.kind == "vehicle" then
        local vehicle = square:getVehicleContainer()
        if not vehicle then
            return nil
        end
        local part = vehicle:getPartByIndex(tonumber(target.partIndex) or -1)
        return part and part.getItemContainer and part:getItemContainer() or nil
    end

    return nil
end

resolveLootTargetGroundItem = function(target)
    if type(target) ~= "table" then
        return nil, nil
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return nil, nil
    end

    local square = cell:getGridSquare(tonumber(target.x) or 0, tonumber(target.y) or 0, tonumber(target.z) or 0)
    if not square then
        return nil, nil
    end

    local worldObjects = square:getWorldObjects()
    if not worldObjects then
        return nil, square
    end

    local itemID = tonumber(target.itemID)
    for index = 0, worldObjects:size() - 1 do
        local worldObject = worldObjects:get(index)
        local item = worldObject and worldObject.getItem and worldObject:getItem() or nil
        if item and tonumber(item.getID and item:getID() or 0) == itemID then
            return item, square
        end
    end

    return nil, square
end

local function canAccessVehicleTarget(target, zombie)
    if not target or target.kind ~= "vehicle" then
        return true
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return false
    end

    local square = cell:getGridSquare(tonumber(target.x) or 0, tonumber(target.y) or 0, tonumber(target.z) or 0)
    local vehicle = square and square.getVehicleContainer and square:getVehicleContainer() or nil
    if not vehicle then
        return false
    end

    if vehicle.canAccessContainer then
        return vehicle:canAccessContainer(tonumber(target.partIndex) or -1, zombie)
    end

    return true
end

local function getLootableTargetItem(target, filterContext, worker, registry)
    if not target then
        return nil, 0
    end

    if target.kind == "groundItem" then
        local invItem = resolveLootTargetGroundItem(target)
        if target.lootItemID and getInventoryItemID(invItem) ~= tonumber(target.lootItemID) then
            return nil, 0
        end
        if not invItem or not itemMatchesLootFilter(invItem, filterContext) then
            if invItem then
                lootDebugLog(nil, worker, "Match", "Ground item did not match filters: " .. tostring(invItem:getFullType()))
            end
            return nil, 0
        end

        local requestedQty = getInventoryItemQuantity(invItem)
        local fitQty = registry and registry.GetFittingInventoryQuantity
            and registry.GetFittingInventoryQuantity(worker, invItem:getFullType(), requestedQty)
            or requestedQty
        if fitQty <= 0 or fitQty < requestedQty then
            lootDebugLog(nil, worker, "Capacity", "Ground item fit failed: fullType=" .. tostring(invItem:getFullType()) .. " requested=" .. tostring(requestedQty) .. " fit=" .. tostring(fitQty))
            return nil, 0
        end
        return invItem, fitQty
    end

    local container = resolveLootTargetContainer(target)
    if not container then
        return nil, 0
    end

    if target.lootItemID ~= nil or target.lootFullType ~= nil then
        local invItem = findItemInContainerRecursive(container, tonumber(target.lootItemID), target.lootFullType)
        if not invItem or not itemMatchesLootFilter(invItem, filterContext) then
            return nil, 0
        end

        local requestedQty = getInventoryItemQuantity(invItem)
        local fitQty = registry and registry.GetFittingInventoryQuantity
            and registry.GetFittingInventoryQuantity(worker, invItem:getFullType(), requestedQty)
            or requestedQty
        if fitQty <= 0 then
            return nil, 0
        end
        return invItem, fitQty
    end

    return findMatchingItemRecursive(container, filterContext, worker, registry)
end

local function canLootTarget(target, zombie, filterContext, worker, registry)
    if not target then
        return false
    end

    if target.kind == "vehicle" and not canAccessVehicleTarget(target, zombie) then
        lootDebugLog(nil, worker, "Access", "Vehicle target not accessible: " .. formatTargetDebug(target))
        return false
    end

    if target.kind == "groundItem" then
        local invItem = resolveLootTargetGroundItem(target)
        if not invItem then
            return false
        end
        if filterContext and worker and registry then
            local matchedItem, fitQty = getLootableTargetItem(target, filterContext, worker, registry)
            return matchedItem ~= nil and fitQty > 0
        end
        return true
    end

    local container = resolveLootTargetContainer(target)
    if not container then
        return false
    end

    local items = container.getItems and container:getItems() or nil
    if not items or items:size() <= 0 then
        return false
    end

    if filterContext and worker and registry then
        local matchedItem, fitQty = getLootableTargetItem(target, filterContext, worker, registry)
        return matchedItem ~= nil and fitQty > 0
    end

    return true
end

local function addCandidate(candidates, npcData, target)
    if not target or not target.key or isLootContainerVisited(npcData, target.key) then
        return
    end
    candidates[#candidates + 1] = target
end

local function addLootItemCandidates(candidates, npcData, baseTarget, container, filterContext, worker, registry)
    if not baseTarget or isLootContainerVisited(npcData, baseTarget.key) then
        return
    end

    if baseTarget.kind == "groundItem" then
        local invItem = resolveLootTargetGroundItem(baseTarget)
        if not invItem or not itemMatchesLootFilter(invItem, filterContext) then
            return
        end

        local requestedQty = getInventoryItemQuantity(invItem)
        local fitQty = registry and registry.GetFittingInventoryQuantity
            and registry.GetFittingInventoryQuantity(worker, invItem:getFullType(), requestedQty)
            or requestedQty
        if fitQty > 0 then
            appendMatchedItemCandidate(candidates, baseTarget, invItem, requestedQty, fitQty)
        end
        return
    end

    collectMatchingItemsRecursive(candidates, baseTarget, container, filterContext, worker, registry, LOOT_MAX_ITEM_CANDIDATES)
end

local function buildLootCandidates(zombie, npcData, filterContext, worker, registry)
    local cell = getCell and getCell() or nil
    if not cell or not zombie or not npcData or not worker or not registry then
        return {}
    end

    local radius = filterContext.config.radius
    local anchorX = tonumber(npcData.dcLootAnchorX or npcData.anchorX or zombie:getX()) or zombie:getX()
    local anchorY = tonumber(npcData.dcLootAnchorY or npcData.anchorY or zombie:getY()) or zombie:getY()
    local anchorZ = tonumber(npcData.dcLootAnchorZ or npcData.anchorZ or zombie:getZ()) or zombie:getZ()
    local candidates = {}
    local seenVehicles = {}

    for y = math.floor(anchorY - radius), math.floor(anchorY + radius) do
        for x = math.floor(anchorX - radius), math.floor(anchorX + radius) do
            local square = cell:getGridSquare(x, y, anchorZ)
            if square then
                if filterContext.config.includeWorldContainers then
                    local worldObjects = square:getWorldObjects()
                    if worldObjects then
                        for index = 0, worldObjects:size() - 1 do
                            local worldObject = worldObjects:get(index)
                            local item = worldObject and worldObject.getItem and worldObject:getItem() or nil
                            local inventory = item and item.getInventory and item:getInventory() or nil
                            if item and inventory and lower(item.getCategory and item:getCategory() or "") == "container"
                                and filterContext.config.includeGroundContainers then
                                addLootItemCandidates(candidates, npcData, {
                                    key = "bag:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(item:getID()),
                                    kind = "bag",
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    itemID = item:getID(),
                                    distance = getDistance(anchorX, anchorY, x, y),
                                    stopDistance = LOOT_STOP_DISTANCE,
                                }, inventory, filterContext, worker, registry)
                            elseif item and not inventory and filterContext.config.includeLooseWorldItems then
                                addLootItemCandidates(candidates, npcData, {
                                    key = "groundItem:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(item:getID()),
                                    kind = "groundItem",
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    itemID = item:getID(),
                                    distance = getDistance(anchorX, anchorY, x, y),
                                    stopDistance = LOOT_STOP_DISTANCE,
                                }, nil, filterContext, worker, registry)
                            end

                            if #candidates >= LOOT_MAX_ITEM_CANDIDATES then
                                break
                            end
                        end
                    end

                    if filterContext.config.includeFurnitureContainers then
                        local objects = square:getObjects()
                        if objects then
                            for objectIndex = 0, objects:size() - 1 do
                                local object = objects:get(objectIndex)
                                local containerCount = object and object.getContainerCount and tonumber(object:getContainerCount()) or 0
                                for containerIndex = 0, math.max(0, containerCount - 1) do
                                    local container = object and object.getContainerByIndex and object:getContainerByIndex(containerIndex) or nil
                                    local items = container and container.getItems and container:getItems() or nil
                                    if items and items:size() > 0 then
                                        addLootItemCandidates(candidates, npcData, {
                                            key = "world:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(objectIndex) .. ":" .. tostring(containerIndex),
                                            kind = "world",
                                            x = x,
                                            y = y,
                                            z = anchorZ,
                                            objectIndex = objectIndex,
                                            containerIndex = containerIndex,
                                            distance = getDistance(anchorX, anchorY, x, y),
                                            stopDistance = LOOT_STOP_DISTANCE,
                                        }, container, filterContext, worker, registry)
                                    end
                                    if #candidates >= LOOT_MAX_ITEM_CANDIDATES then
                                        break
                                    end
                                end
                                if #candidates >= LOOT_MAX_ITEM_CANDIDATES then
                                    break
                                end
                            end
                        end
                    end
                end

                if filterContext.config.includeCorpseContainers then
                    local staticObjects = square:getStaticMovingObjects()
                    if staticObjects then
                        for index = 0, staticObjects:size() - 1 do
                            local staticObject = staticObjects:get(index)
                            local container = staticObject and staticObject.getContainer and staticObject:getContainer() or nil
                            local items = container and container.getItems and container:getItems() or nil
                            if items and items:size() > 0 then
                                addLootItemCandidates(candidates, npcData, {
                                    key = "corpse:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(staticObject:getID()),
                                    kind = "corpse",
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    objectID = staticObject:getID(),
                                    distance = getDistance(anchorX, anchorY, x, y),
                                    stopDistance = LOOT_STOP_DISTANCE,
                                }, container, filterContext, worker, registry)
                            end
                            if #candidates >= LOOT_MAX_ITEM_CANDIDATES then
                                break
                            end
                        end
                    end
                end

                if filterContext.config.includeVehicleContainers then
                    local vehicle = square:getVehicleContainer()
                    if vehicle and not seenVehicles[vehicle] then
                        seenVehicles[vehicle] = true
                        local vehicleID = vehicle.getId and vehicle:getId()
                            or vehicle.getID and vehicle:getID()
                            or tostring(vehicle)
                        for partIndex = 0, vehicle:getPartCount() - 1 do
                            local vehiclePart = vehicle:getPartByIndex(partIndex)
                            local container = vehiclePart and vehiclePart.getItemContainer and vehiclePart:getItemContainer() or nil
                            local items = container and container.getItems and container:getItems() or nil
                            if items and items:size() > 0 and canAccessVehicleTarget({
                                kind = "vehicle",
                                x = x,
                                y = y,
                                z = anchorZ,
                                partIndex = partIndex,
                            }, zombie) then
                                addLootItemCandidates(candidates, npcData, {
                                    key = "vehicle:" .. tostring(vehicleID) .. ":" .. tostring(partIndex),
                                    kind = "vehicle",
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    partIndex = partIndex,
                                    distance = getDistance(anchorX, anchorY, x, y),
                                    stopDistance = LOOT_VEHICLE_STOP_DISTANCE,
                                }, container, filterContext, worker, registry)
                            end
                            if #candidates >= LOOT_MAX_ITEM_CANDIDATES then
                                break
                            end
                        end
                    end
                end
            end

            if #candidates >= LOOT_MAX_ITEM_CANDIDATES then
                break
            end
        end

        if #candidates >= LOOT_MAX_ITEM_CANDIDATES then
            break
        end
    end

    table.sort(candidates, function(a, b)
        if math.abs((a.distance or 0) - (b.distance or 0)) > 0.05 then
            return (a.distance or 0) < (b.distance or 0)
        end
        return tostring(a.key or "") < tostring(b.key or "")
    end)

    local roundedAnchorX = math.floor((tonumber(anchorX) or 0) * 10 + 0.5) / 10
    local roundedAnchorY = math.floor((tonumber(anchorY) or 0) * 10 + 0.5) / 10
    local roundedAnchorZ = math.floor((tonumber(anchorZ) or 0) * 10 + 0.5) / 10
    local candidateSummary = "Built " .. tostring(#candidates) .. " candidates around anchor=" .. tostring(roundedAnchorX) .. "," .. tostring(roundedAnchorY) .. "," .. tostring(roundedAnchorZ)
    lootDebugLogChanged(npcData, nil, "candidate_count", "Candidates", candidateSummary)
    if #candidates > 0 then
        local preview = {}
        local limit = math.min(#candidates, 6)
        for index = 1, limit do
            local candidate = candidates[index]
            preview[#preview + 1] = formatTargetDebug(candidate) .. " | " .. describeLootTarget(candidate, filterContext)
        end
        lootDebugLogChanged(npcData, nil, "candidate_preview", "Candidates", "Candidate preview: " .. table.concat(preview, " || "))
    end

    return candidates
end

local function selectNextLootTarget(zombie, npcData, filterContext, worker, registry)
    local candidates = buildLootCandidates(zombie, npcData, filterContext, worker, registry)
    for _, candidate in ipairs(candidates) do
        if canLootTarget(candidate, zombie, filterContext, worker, registry) then
            ensureLootApproachPoint(candidate, zombie)
            lootDebugLog(npcData, worker, "Target", "Selected target: " .. formatTargetDebug(candidate) .. " | " .. describeLootTarget(candidate, filterContext))
            return candidate
        end
        lootDebugLog(npcData, worker, "Target", "Rejected target: " .. formatTargetDebug(candidate) .. " | " .. describeLootTarget(candidate, filterContext))
        markLootContainerVisited(npcData, candidate.key)
    end
    lootDebugLog(npcData, worker, "Target", "No valid target found after filtering candidates")
    return nil
end

local function stopLooting(zombie, npcData, notice, sentiment)
    lootDebugLog(npcData, nil, "Stop", "Looting stopped. notice=" .. tostring(notice) .. " sentiment=" .. tostring(sentiment))
    if npcData then
        npcData.state = "Stay"
        npcData.dcLootStatus = notice and "idle" or npcData.dcLootStatus
        npcData.dcLootTarget = nil
        npcData.dcLootTargetKey = nil
        npcData.isMovingState = false
    end
    if DTNPCProtect and DTNPCProtect.ResetGuardedCombatState then
        DTNPCProtect.ResetGuardedCombatState(zombie, npcData, {
            clearAutoProtectState = true,
        })
    end
    if zombie and DTNPCMobility and DTNPCMobility.Stop then
        DTNPCMobility.Stop(zombie)
    end
    if notice and DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        DTNPCProtect.PushCompanionNotice(zombie, npcData, notice, sentiment or "neutral")
    end
end

local function findOnlinePlayer(username)
    if not username or username == "" then
        return nil
    end

    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            if player and player.getUsername and player:getUsername() == username then
                return player
            end
        end
    end

    local localPlayer = getSpecificPlayer and getSpecificPlayer(0) or nil
    if localPlayer and localPlayer.getUsername and localPlayer:getUsername() == username then
        return localPlayer
    end

    return nil
end

local function syncWorkerLootUpdate(worker, npcData, apis)
    local registry = apis and apis.registry or nil
    local network = apis and apis.network or nil
    if not worker or not registry then
        return
    end

    if registry.RecalculateWorker then
        registry.RecalculateWorker(worker)
    end
    if registry.Save then
        registry.Save()
    end

    local currentTime = nowMillis()
    if currentTime > 0 and (tonumber(npcData.dcLootLastWorkerSyncAt) or 0) > 0
        and (currentTime - tonumber(npcData.dcLootLastWorkerSyncAt or 0)) < LOOT_SYNC_COOLDOWN_MS then
        return
    end
    npcData.dcLootLastWorkerSyncAt = currentTime

    local synced = {}
    local usernames = {
        tostring(npcData and npcData.dcCommanderUsername or ""),
        tostring(worker.ownerUsername or ""),
    }
    for _, username in ipairs(usernames) do
        if username ~= "" and not synced[username] then
            synced[username] = true
            local player = findOnlinePlayer(username)
            if player and network and network.Internal then
                if network.Internal.syncWorkerDetail then
                    network.Internal.syncWorkerDetail(player, worker.workerID, nil, true)
                end
                if network.Internal.syncWorkerList then
                    network.Internal.syncWorkerList(player)
                end
            end
        end
    end
end

local function transferLootToWorker(zombie, npcData, worker, invItem, movedQty, filterContext)
    local apis = filterContext and filterContext.apis or getColonyApis()
    local registry = apis and apis.registry or nil
    local helpers = DynamicTrading and DynamicTrading.ServerHelpers or nil
    if not registry or not invItem or movedQty <= 0 then
        lootDebugLog(npcData, worker, "Transfer", "Aborted before transfer: registry=" .. tostring(registry ~= nil) .. " invItem=" .. tostring(invItem ~= nil) .. " movedQty=" .. tostring(movedQty))
        return false
    end

    local outputBuilder = registry.Internal and registry.Internal.BuildOutputEntryFromInventoryItem or nil
    local outputEntry = outputBuilder and outputBuilder(invItem) or {
        fullType = invItem:getFullType(),
        displayName = invItem.getDisplayName and invItem:getDisplayName() or invItem:getFullType(),
        qty = movedQty,
    }
    if not outputEntry or not outputEntry.fullType then
        lootDebugLog(npcData, worker, "Transfer", "Failed to build output entry for item")
        return false
    end

    local availableQty = math.max(1, tonumber(outputEntry.qty) or getInventoryItemQuantity(invItem))
    local container = invItem.getContainer and invItem:getContainer() or nil
    lootDebugLog(npcData, worker, "Transfer", "Attempting transfer: fullType=" .. tostring(invItem:getFullType()) .. " movedQty=" .. tostring(movedQty) .. " display=" .. tostring(invItem.getDisplayName and invItem:getDisplayName() or "nil") .. " container=" .. tostring(container and container.getType and container:getType() or "ground-or-nil"))
    outputEntry.qty = math.max(1, math.min(availableQty, math.floor(movedQty)))
    lootDebugLog(npcData, worker, "Transfer", "Built output entry: fullType=" .. tostring(outputEntry.fullType) .. " availableQty=" .. tostring(availableQty) .. " requestedStoreQty=" .. tostring(outputEntry.qty) .. " hasContainer=" .. tostring(container ~= nil))

    local storedQty = registry.AddOutputEntry and registry.AddOutputEntry(worker, outputEntry) or 0
    if storedQty <= 0 then
        lootDebugLog(npcData, worker, "Transfer", "Registry rejected item: fullType=" .. tostring(outputEntry.fullType) .. " storedQty=" .. tostring(storedQty))
        return false
    end

    lootDebugLog(npcData, worker, "Transfer", "Registry stored item: fullType=" .. tostring(outputEntry.fullType) .. " storedQty=" .. tostring(storedQty))

    if helpers and helpers.RemoveItem then
        lootDebugLog(npcData, worker, "Transfer", "Removing source item via ServerHelpers.RemoveItem")
        helpers.RemoveItem(invItem)
    elseif container and container.DoRemoveItem then
        lootDebugLog(npcData, worker, "Transfer", "Removing source item via container:DoRemoveItem")
        container:DoRemoveItem(invItem)
    else
        lootDebugLog(npcData, worker, "Transfer", "No removal path found for source item")
    end

    if availableQty > storedQty and container then
        local customData = registry.Internal and registry.Internal.BuildOutputAddItemCustomData
            and registry.Internal.BuildOutputAddItemCustomData(outputEntry)
            or nil
        lootDebugLog(npcData, worker, "Transfer", "Returning remainder to source container: remainder=" .. tostring(availableQty - storedQty))
        if helpers and helpers.AddItemWithCondition then
            helpers.AddItemWithCondition(container, outputEntry.fullType, availableQty - storedQty, customData)
        elseif container.AddItems then
            container:AddItems(outputEntry.fullType, availableQty - storedQty)
        end
    end

    syncWorkerLootUpdate(worker, npcData, apis)

    if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        local displayName = tostring(outputEntry.displayName or outputEntry.fullType or "loot")
        local countText = storedQty > 1 and ("x" .. tostring(storedQty) .. " ") or ""
        DTNPCProtect.PushCompanionNotice(zombie, npcData, "Grabbed " .. countText .. displayName .. ".", "positive")
    end

    npcData.dcLootStatus = "looting"
    return true
end

local function runLootCombat(zombie, npcData)
    if not zombie or not npcData or not DTNPCProtect then
        return false
    end

    local anchorTarget = DTNPCProtect.GetCombatAnchorTarget and DTNPCProtect.GetCombatAnchorTarget(npcData, zombie) or buildPointTarget(zombie:getX(), zombie:getY(), zombie:getZ())
    local engageRadius = tonumber(npcData.protectEngageRadius) or LOOT_THREAT_RADIUS
    local leashRadius = math.max(engageRadius + LOOT_THREAT_LEASH_BONUS, tonumber(npcData.dcLootRadius) or engageRadius)
    local target, targetDist = DTNPCProtect.SelectNearestThreat(
        zombie,
        npcData,
        engageRadius,
        anchorTarget,
        leashRadius
    )

    if not target then
        if DTNPCProtect.ResetGuardedCombatState then
            DTNPCProtect.ResetGuardedCombatState(zombie, npcData, {
                clearAutoProtectState = true,
            })
        end
        npcData.dcLootStatus = npcData.dcLootStatus == "combat" and "searching" or npcData.dcLootStatus
        return false
    end

    local requestedState = npcData.combatOrder or "ProtectAuto"
    local resolvedState = DTNPCProtect.ResolveProtectState and DTNPCProtect.ResolveProtectState(npcData, requestedState) or requestedState
    if requestedState == "ProtectAuto" and DTNPCProtect.GetAutoProtectState then
        resolvedState = DTNPCProtect.GetAutoProtectState(npcData, targetDist)
    end

    npcData.autoProtectActiveState = resolvedState
    npcData.dcLootStatus = "combat"
    if DTNPCProtect.EnsureManualCombatControl then
        DTNPCProtect.EnsureManualCombatControl(zombie)
    end
    if DTNPCProtect.AnnounceCompanionCombatEngage then
        DTNPCProtect.AnnounceCompanionCombatEngage(zombie, npcData, "loot")
    end

    if resolvedState == "ProtectRanged" and DTNPCProtect.ExecuteGuardedRangedCombat then
        DTNPCProtect.ExecuteGuardedRangedCombat(zombie, npcData, target, targetDist, {
            mode = "loot",
            issuePrefix = "LootRanged",
            unavailableText = "Can't cover the loot. No usable firearm.",
            onRangedAttack = function(attackZombie, attackNpcData)
                if DTNPCProtect and DTNPCProtect.AnnounceCompanionRangedAttack then
                    DTNPCProtect.AnnounceCompanionRangedAttack(attackZombie, attackNpcData, "loot")
                end
            end,
        })
        return true
    end

    if resolvedState == "ProtectMelee" and DTNPCProtect.ExecuteGuardedMeleeCombat then
        local anchorX = anchorTarget and anchorTarget.getX and anchorTarget:getX() or zombie:getX()
        local anchorY = anchorTarget and anchorTarget.getY and anchorTarget:getY() or zombie:getY()
        local anchorZ = anchorTarget and anchorTarget.getZ and anchorTarget:getZ() or zombie:getZ()
        DTNPCProtect.ExecuteGuardedMeleeCombat(zombie, npcData, target, targetDist, {
            mode = "loot",
            issuePrefix = "LootMelee",
            unavailableText = "Can't defend the loot. No usable melee weapon.",
            blockedText = "Can't reach that threat from the looting area.",
            blockCounterKey = "lootCombatBlockedTicks",
            fallbackReach = 1.25,
            defaultSpeed = 0.05,
            enterBuffer = 0.25,
            holdBuffer = 0.45,
            stopBuffer = 0.16,
            debugLabel = "LootMeleeSwing",
            anchorX = anchorX,
            anchorY = anchorY,
            anchorZ = anchorZ,
            leashRadius = leashRadius,
        })
        return true
    end

    if DTNPCProtect.ReportCombatIssue then
        local text, sentiment = nil, nil
        if DTNPCProtect.BuildFallbackNotice then
            text, sentiment = DTNPCProtect.BuildFallbackNotice(requestedState, resolvedState)
        end
        DTNPCProtect.ReportCombatIssue(
            zombie,
            npcData,
            "LootNoLoadout",
            text or "No combat loadout ready to cover looting.",
            sentiment or "warning",
            "requested=" .. tostring(requestedState) .. " resolved=" .. tostring(resolvedState)
        )
    end
    return false
end

local function getLootCommanderTarget(npcData, worker)
    local usernames = {
        tostring(npcData and npcData.dcCommanderUsername or ""),
        tostring(worker and worker.ownerUsername or ""),
    }

    for _, username in ipairs(usernames) do
        if username ~= "" then
            local player = findOnlinePlayer(username)
            if player then
                return player
            end
        end
    end

    return nil
end

local function updateLootFollowEscort(zombie, npcData, commander)
    if not zombie or not npcData or not commander then
        return nil
    end

    local dist = getDistance(zombie:getX(), zombie:getY(), commander:getX(), commander:getY())
    if DTNPCLogic and DTNPCLogic.Behaviors and DTNPCLogic.Behaviors["Follow"] then
        DTNPCLogic.Behaviors["Follow"](zombie, npcData, commander, dist)
    end
    return dist
end

local function performNearbyAutoLoot(zombie, npcData, worker, filterContext, registry)
    if not zombie or not npcData or not worker or not filterContext or not registry then
        return 0
    end

    local originalRadius = tonumber(filterContext.config and filterContext.config.radius) or 2
    local autoLootRadius = math.max(1, math.min(3, math.floor(originalRadius)))
    filterContext.config.radius = autoLootRadius

    npcData.dcLootAnchorX = zombie:getX()
    npcData.dcLootAnchorY = zombie:getY()
    npcData.dcLootAnchorZ = zombie:getZ()

    local candidates = buildLootCandidates(zombie, npcData, filterContext, worker, registry)
    local transferredCount = 0
    local transferLimit = 2

    if #candidates > 0 then
        local preview = {}
        local limit = math.min(#candidates, 4)
        for index = 1, limit do
            preview[#preview + 1] = describeLootTarget(candidates[index], filterContext)
        end
        lootDebugLogChanged(
            npcData,
            worker,
            "autoloot_scan",
            "AutoLoot",
            "Nearby scan radius=" .. tostring(autoLootRadius) .. " candidates=" .. tostring(#candidates) .. " preview=[" .. table.concat(preview, " || ") .. "]"
        )
    end

    for _, candidate in ipairs(candidates) do
        if transferredCount >= transferLimit then
            break
        end

        local invItem, fitQty = getLootableTargetItem(candidate, filterContext, worker, registry)
        if invItem and fitQty > 0 then
            lootDebugLog(npcData, worker, "AutoLoot", "Auto-grab item: " .. formatTargetDebug(candidate) .. " | " .. describeLootTarget(candidate, filterContext))
            local transferred = transferLootToWorker(zombie, npcData, worker, invItem, fitQty, filterContext)
            if transferred then
                transferredCount = transferredCount + 1
            end
            markLootContainerVisited(npcData, candidate.key)
        end
    end

    filterContext.config.radius = originalRadius
    return transferredCount
end

DTNPCLogic.Behaviors["LootNearby"] = function(zombie, npcData)
    if not zombie or not npcData then
        return
    end

    if isClient() and not isServer() then
        return
    end

    DTNPCProtect.EnsureDataDefaults(npcData)
    clearLootTarget(npcData)

    local worker, apis = getLinkedWorker(npcData)
    local registry = apis and apis.registry or nil
    if not worker or not registry then
        lootDebugLog(npcData, worker, "Init", "Looting unavailable: worker=" .. tostring(worker ~= nil) .. " registry=" .. tostring(registry ~= nil))
        stopLooting(zombie, npcData, "Looting isn't available right now.", "warning")
        return
    end

    if registry.GetInventoryRemainingCapacity and registry.GetInventoryRemainingCapacity(worker) <= 0 then
        lootDebugLog(npcData, worker, "Init", "Worker has no remaining capacity")
        stopLooting(zombie, npcData, "I'm full. Can't carry more loot.", "warning")
        return
    end

    local filterContext = buildLootFilterContext(npcData)
    filterContext.apis = apis

    local debugSignature = table.concat({
        tostring(npcData.state or "nil"),
        tostring(npcData.dcLootStatus or "nil"),
        formatSourceConfigDebug(filterContext.config),
        "hasFilter=" .. tostring(filterContext.hasAnyFilter),
        "mode=follow_autograb",
    }, " | ")
    if npcData.dcLootDebugSignature ~= debugSignature then
        npcData.dcLootDebugSignature = debugSignature
        lootDebugLog(npcData, worker, "Init", debugSignature)
    end

    if not filterContext.hasAnyFilter then
        lootDebugLog(npcData, worker, "Init", "No filters configured; refusing to loot")
        stopLooting(zombie, npcData, "Set loot filters first.", "warning")
        return
    end

    if runLootCombat(zombie, npcData) then
        return
    end

    local commander = getLootCommanderTarget(npcData, worker)
    local followDist = commander and updateLootFollowEscort(zombie, npcData, commander) or nil

    local movedCount = performNearbyAutoLoot(zombie, npcData, worker, filterContext, registry)
    if movedCount > 0 then
        npcData.dcLootStatus = "looting"
        return
    end

    if commander then
        npcData.dcLootStatus = (followDist and followDist > 2.0) and "following" or "idle"
    else
        npcData.dcLootStatus = "idle"
    end
end
