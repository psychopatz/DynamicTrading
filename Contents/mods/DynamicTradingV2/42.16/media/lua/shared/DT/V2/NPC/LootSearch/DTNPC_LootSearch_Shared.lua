-- ==============================================================================
-- DTNPC_LootSearch_Shared.lua
-- Shared loot search helpers for travel companions.
-- ==============================================================================

DTNPCLootSearch = DTNPCLootSearch or {}

if DTNPCLootSearch.SharedLoaded then
    return
end

DTNPCLootSearch.SharedLoaded = true

require "DT/V2/NPC/Sys/Mobility/DTNPC_Mobility"

pcall(require, "DC/Common/Colony/ColonyRegistry/DC_ColonyRegistry")
pcall(require, "DC/Common/Colony/ColonyNetwork/DC_ColonyNetwork")

local SEARCH_STOP_DISTANCE = 1.55
local SEARCH_WORLD_STOP_DISTANCE = 1.35
local SEARCH_CORPSE_STOP_DISTANCE = 1.6
local SEARCH_GROUND_STOP_DISTANCE = 1.4
local SEARCH_VEHICLE_STOP_DISTANCE = 2.1
local SEARCH_SOURCE_LIMIT = 24
local SEARCH_ITEM_LIMIT = 48
local SEARCH_SYNC_COOLDOWN_MS = 1000
local SEARCH_RECENT_COLLECT_TTL_MS = 4000

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function clamp(value, minValue, maxValue)
    local numeric = tonumber(value) or minValue
    if numeric < minValue then
        return minValue
    end
    if numeric > maxValue then
        return maxValue
    end
    return numeric
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

local function getDistance(ax, ay, bx, by)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dy = (tonumber(ay) or 0) - (tonumber(by) or 0)
    return math.sqrt((dx * dx) + (dy * dy))
end

local function getItemDisplayName(invItem)
    if not invItem then
        return "Unknown"
    end
    if invItem.getDisplayName then
        return tostring(invItem:getDisplayName())
    end
    if invItem.getName then
        return tostring(invItem:getName())
    end
    if invItem.getFullType then
        return tostring(invItem:getFullType())
    end
    return tostring(invItem)
end

local function getInventoryItemQuantity(invItem)
    local count = invItem and invItem.getCount and tonumber(invItem:getCount()) or 1
    if count and count > 1 then
        return math.max(1, math.floor(count))
    end
    return 1
end

local function getInventoryItemID(invItem)
    if not invItem then
        return nil
    end
    if invItem.getID then
        return invItem:getID()
    end
    return nil
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

local function resolveApproachPoint(source, referenceX, referenceY)
    if type(source) ~= "table" then
        return nil
    end

    local targetX = tonumber(source.x)
    local targetY = tonumber(source.y)
    local targetZ = tonumber(source.z) or 0
    if targetX == nil or targetY == nil then
        return nil
    end

    if source.kind ~= "world" and source.kind ~= "vehicle" then
        local stopDistance = tonumber(source.stopDistance) or SEARCH_STOP_DISTANCE
        if source.kind == "corpse" then
            stopDistance = math.max(stopDistance, SEARCH_CORPSE_STOP_DISTANCE)
        elseif source.kind == "groundItem" or source.kind == "bag" then
            stopDistance = math.max(stopDistance, SEARCH_GROUND_STOP_DISTANCE)
        end
        return {
            x = targetX,
            y = targetY,
            z = targetZ,
            stopDistance = stopDistance,
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

    local bestCandidate = nil
    local bestDistance = nil
    local originX = tonumber(referenceX) or targetX
    local originY = tonumber(referenceY) or targetY

    for _, candidate in ipairs(candidates) do
        if isLootTileSafe(candidate.x, candidate.y, candidate.z) then
            local candidateDistance = getDistance(originX, originY, candidate.x, candidate.y)
            if not bestCandidate or candidateDistance < bestDistance then
                bestCandidate = candidate
                bestDistance = candidateDistance
            end
        end
    end

    if bestCandidate then
        if source.kind == "vehicle" then
            bestCandidate.stopDistance = SEARCH_VEHICLE_STOP_DISTANCE
        else
            bestCandidate.stopDistance = SEARCH_WORLD_STOP_DISTANCE
        end
        return bestCandidate
    end

    return {
        x = targetX,
        y = targetY,
        z = targetZ,
        stopDistance = source.kind == "vehicle" and SEARCH_VEHICLE_STOP_DISTANCE or SEARCH_WORLD_STOP_DISTANCE,
    }
end

local function getColonyApis()
    local colony = DC_Colony or nil
    return {
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

local function getWorkerCarryState(worker, apis)
    local registry = apis and apis.registry or nil
    local state = registry and registry.GetInventoryWeightState and registry.GetInventoryWeightState(worker) or nil
    if not state then
        return nil
    end

    return {
        usedWeight = math.max(0, tonumber(state.usedWeight) or 0),
        maxWeight = math.max(0, tonumber(state.maxWeight) or 0),
        remainingWeight = math.max(0, tonumber(state.remainingWeight) or 0),
    }
end

local function isTableEmpty(value)
    if type(value) ~= "table" then
        return true
    end

    for _ in pairs(value) do
        return false
    end
    return true
end

local function pruneRecentCollects(state)
    local recent = type(state and state.recentCollects) == "table" and state.recentCollects or nil
    if not recent then
        return
    end

    local currentTime = nowMillis()
    for sourceKey, entries in pairs(recent) do
        if type(entries) == "table" then
            for itemKey, expiresAt in pairs(entries) do
                if (tonumber(expiresAt) or 0) <= currentTime then
                    entries[itemKey] = nil
                end
            end
            if isTableEmpty(entries) then
                recent[sourceKey] = nil
            end
        else
            recent[sourceKey] = nil
        end
    end
end

local function wasRecentlyCollected(state, sourceKey, itemKey)
    if type(state) ~= "table" or not sourceKey or not itemKey then
        return false
    end

    pruneRecentCollects(state)
    local entries = state.recentCollects and state.recentCollects[tostring(sourceKey)] or nil
    return type(entries) == "table" and (tonumber(entries[tostring(itemKey)]) or 0) > nowMillis()
end

local function markRecentlyCollected(state, sourceKey, itemKey)
    if type(state) ~= "table" or not sourceKey or not itemKey then
        return
    end

    state.recentCollects = type(state.recentCollects) == "table" and state.recentCollects or {}
    local normalizedSourceKey = tostring(sourceKey)
    local entries = state.recentCollects[normalizedSourceKey]
    if type(entries) ~= "table" then
        entries = {}
        state.recentCollects[normalizedSourceKey] = entries
    end
    entries[tostring(itemKey)] = nowMillis() + SEARCH_RECENT_COLLECT_TTL_MS
end

local function findOnlinePlayer(username)
    local resolved = tostring(username or "")
    if resolved == "" then
        return nil
    end

    local onlinePlayers = getOnlinePlayers and getOnlinePlayers() or nil
    if onlinePlayers then
        for index = 0, onlinePlayers:size() - 1 do
            local player = onlinePlayers:get(index)
            if player and player.getUsername and player:getUsername() == resolved then
                return player
            end
        end
    end

    local localPlayer = getSpecificPlayer and getSpecificPlayer(0) or nil
    if localPlayer and localPlayer.getUsername and localPlayer:getUsername() == resolved then
        return localPlayer
    end

    return nil
end

local function getCommanderUsername(npcData, worker)
    if npcData and tostring(npcData.dcCommanderUsername or "") ~= "" then
        return tostring(npcData.dcCommanderUsername)
    end
    if npcData and tostring(npcData.master or "") ~= "" then
        return tostring(npcData.master)
    end
    if worker and tostring(worker.ownerUsername or "") ~= "" then
        return tostring(worker.ownerUsername)
    end
    return nil
end

local function normalizeConfig(npcData)
    local config = type(npcData and npcData.dcLootConfig) == "table" and npcData.dcLootConfig or {}
    return {
        radius = clamp(npcData and npcData.dcLootRadius or config.radius or 8, 2, 25),
        includeLooseWorldItems = config.includeLooseWorldItems ~= false,
        includeGroundContainers = config.includeGroundContainers ~= false,
        includeFurnitureContainers = config.includeFurnitureContainers ~= false,
        includeCorpseContainers = config.includeCorpseContainers ~= false,
        includeVehicleContainers = config.includeVehicleContainers ~= false,
    }
end

function DTNPCLootSearch.IsDynamicColoniesCompanion(npcData)
    return type(npcData) == "table"
        and tostring(npcData.dcCompanionJob or "") == "TravelCompanion"
        and tostring(npcData.linkedWorkerID or "") ~= ""
end

function DTNPCLootSearch.EnsureState(npcData)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) then
        return {}
    end
    npcData.dcLootSearch = type(npcData and npcData.dcLootSearch) == "table" and npcData.dcLootSearch or {}
    local state = npcData.dcLootSearch
    state.searchedSources = type(state.searchedSources) == "table" and state.searchedSources or {}
    state.discoveredSources = type(state.discoveredSources) == "table" and state.discoveredSources or {}
    state.pendingCollects = type(state.pendingCollects) == "table" and state.pendingCollects or {}
    state.recentCollects = type(state.recentCollects) == "table" and state.recentCollects or {}
    state.currentSourceKey = state.currentSourceKey or nil
    state.lastSyncAt = tonumber(state.lastSyncAt) or 0
    pruneRecentCollects(state)
    return state
end

local function appendItemEntry(items, invItem, sourceKey, prefix, limit, includeRuntimeRefs)
    if not invItem or #items >= limit then
        return
    end

    local itemID = getInventoryItemID(invItem)
    local itemKey = tostring(sourceKey) .. ":item:" .. tostring(itemID or ((invItem.getFullType and invItem:getFullType()) or "unknown") .. ":" .. tostring(#items + 1))
    local entry = {
        key = itemKey,
        itemID = itemID,
        displayName = tostring(prefix or "") .. getItemDisplayName(invItem),
        fullType = invItem.getFullType and invItem:getFullType() or nil,
        quantity = getInventoryItemQuantity(invItem),
    }
    if includeRuntimeRefs then
        entry.ref = invItem
    end
    items[#items + 1] = entry

    local nestedInventory = invItem.getInventory and invItem:getInventory() or nil
    if nestedInventory and #items < limit then
        local nestedItems = nestedInventory.getItems and nestedInventory:getItems() or nil
        if nestedItems then
            local nestedPrefix = tostring(prefix or "") .. getItemDisplayName(invItem) .. " > "
            for nestedIndex = 0, nestedItems:size() - 1 do
                appendItemEntry(items, nestedItems:get(nestedIndex), sourceKey, nestedPrefix, limit, includeRuntimeRefs)
                if #items >= limit then
                    break
                end
            end
        end
    end
end

local function serializeSource(source)
    local items = {}
    for _, item in ipairs(source.items or {}) do
        items[#items + 1] = {
            key = item.key,
            itemID = item.itemID,
            displayName = item.displayName,
            fullType = item.fullType,
            quantity = item.quantity,
        }
    end

    return {
        key = source.key,
        kind = source.kind,
        label = source.label,
        x = source.x,
        y = source.y,
        z = source.z,
        distance = source.distance,
        items = items,
        discoveredAt = tonumber(source.discoveredAt) or nowMillis(),
    }
end

local function addSource(result, source, limit)
    if not source or #(source.items or {}) <= 0 or #result >= limit then
        return
    end

    local approach = resolveApproachPoint(source)
    source.approachX = approach and approach.x or source.x
    source.approachY = approach and approach.y or source.y
    source.approachZ = approach and approach.z or source.z
    source.stopDistance = approach and approach.stopDistance or SEARCH_STOP_DISTANCE
    result[#result + 1] = source
end

function DTNPCLootSearch.ScanNearbySources(anchor, npcData, includeRuntimeRefs)
    if not anchor then
        return {}
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return {}
    end

    local config = normalizeConfig(npcData)
    local anchorX = math.floor(anchor:getX())
    local anchorY = math.floor(anchor:getY())
    local anchorZ = math.floor(anchor:getZ())
    local sources = {}
    local seenVehicles = {}

    for y = anchorY - config.radius, anchorY + config.radius do
        for x = anchorX - config.radius, anchorX + config.radius do
            if #sources >= SEARCH_SOURCE_LIMIT then
                break
            end

            local square = cell:getGridSquare(x, y, anchorZ)
            if square then
                local distance = getDistance(anchorX, anchorY, x, y)

                if config.includeGroundContainers or config.includeLooseWorldItems then
                    local worldObjects = square:getWorldObjects()
                    if worldObjects then
                        for worldIndex = 0, worldObjects:size() - 1 do
                            local worldObject = worldObjects:get(worldIndex)
                            local item = worldObject and worldObject.getItem and worldObject:getItem() or nil
                            local inventory = item and item.getInventory and item:getInventory() or nil

                            if item and inventory and lower(item.getCategory and item:getCategory() or "") == "container" and config.includeGroundContainers then
                                local sourceKey = "bag:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(item:getID())
                                local source = {
                                    key = sourceKey,
                                    kind = "bag",
                                    label = getItemDisplayName(item),
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    distance = distance,
                                    items = {},
                                }
                                local bagItems = inventory.getItems and inventory:getItems() or nil
                                if bagItems then
                                    for bagIndex = 0, bagItems:size() - 1 do
                                        appendItemEntry(source.items, bagItems:get(bagIndex), sourceKey, "", SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                                        if #source.items >= SEARCH_ITEM_LIMIT then
                                            break
                                        end
                                    end
                                end
                                addSource(sources, source, SEARCH_SOURCE_LIMIT)
                            elseif item and not inventory and config.includeLooseWorldItems then
                                local sourceKey = "groundItem:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(item:getID())
                                local source = {
                                    key = sourceKey,
                                    kind = "groundItem",
                                    label = "Ground Item",
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    distance = distance,
                                    items = {},
                                }
                                appendItemEntry(source.items, item, sourceKey, "", SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                                addSource(sources, source, SEARCH_SOURCE_LIMIT)
                            end
                        end
                    end
                end

                if config.includeFurnitureContainers then
                    local objects = square:getObjects()
                    if objects then
                        for objectIndex = 0, objects:size() - 1 do
                            if #sources >= SEARCH_SOURCE_LIMIT then
                                break
                            end
                            local object = objects:get(objectIndex)
                            local containerCount = object and object.getContainerCount and tonumber(object:getContainerCount()) or 0
                            for containerIndex = 0, math.max(0, containerCount - 1) do
                                local container = object and object.getContainerByIndex and object:getContainerByIndex(containerIndex) or nil
                                local items = container and container.getItems and container:getItems() or nil
                                if items and items:size() > 0 then
                                    local sourceKey = "world:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(objectIndex) .. ":" .. tostring(containerIndex)
                                    local source = {
                                        key = sourceKey,
                                        kind = "world",
                                        label = container.getType and tostring(container:getType()) or "Container",
                                        x = x,
                                        y = y,
                                        z = anchorZ,
                                        distance = distance,
                                        items = {},
                                    }
                                    for itemIndex = 0, items:size() - 1 do
                                        appendItemEntry(source.items, items:get(itemIndex), sourceKey, "", SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                                        if #source.items >= SEARCH_ITEM_LIMIT then
                                            break
                                        end
                                    end
                                    addSource(sources, source, SEARCH_SOURCE_LIMIT)
                                end
                            end
                        end
                    end
                end

                if config.includeCorpseContainers then
                    local staticObjects = square:getStaticMovingObjects()
                    if staticObjects then
                        for staticIndex = 0, staticObjects:size() - 1 do
                            if #sources >= SEARCH_SOURCE_LIMIT then
                                break
                            end
                            local staticObject = staticObjects:get(staticIndex)
                            local container = staticObject and staticObject.getContainer and staticObject:getContainer() or nil
                            local items = container and container.getItems and container:getItems() or nil
                            if items and items:size() > 0 then
                                local sourceKey = "corpse:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(staticObject:getID())
                                local source = {
                                    key = sourceKey,
                                    kind = "corpse",
                                    label = "Corpse",
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    distance = distance,
                                    items = {},
                                }
                                for itemIndex = 0, items:size() - 1 do
                                    appendItemEntry(source.items, items:get(itemIndex), sourceKey, "", SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                                    if #source.items >= SEARCH_ITEM_LIMIT then
                                        break
                                    end
                                end
                                addSource(sources, source, SEARCH_SOURCE_LIMIT)
                            end
                        end
                    end
                end

                if config.includeVehicleContainers then
                    local vehicle = square:getVehicleContainer()
                    if vehicle and not seenVehicles[vehicle] then
                        seenVehicles[vehicle] = true
                        local vehicleID = vehicle.getId and vehicle:getId() or vehicle.getID and vehicle:getID() or tostring(vehicle)
                        for partIndex = 0, vehicle:getPartCount() - 1 do
                            local vehiclePart = vehicle:getPartByIndex(partIndex)
                            local container = vehiclePart and vehiclePart.getItemContainer and vehiclePart:getItemContainer() or nil
                            local items = container and container.getItems and container:getItems() or nil
                            if items and items:size() > 0 then
                                local sourceKey = "vehicle:" .. tostring(vehicleID) .. ":" .. tostring(partIndex)
                                local source = {
                                    key = sourceKey,
                                    kind = "vehicle",
                                    label = container.getType and tostring(container:getType()) or "Vehicle",
                                    x = x,
                                    y = y,
                                    z = anchorZ,
                                    distance = distance,
                                    items = {},
                                }
                                for itemIndex = 0, items:size() - 1 do
                                    appendItemEntry(source.items, items:get(itemIndex), sourceKey, "", SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                                    if #source.items >= SEARCH_ITEM_LIMIT then
                                        break
                                    end
                                end
                                addSource(sources, source, SEARCH_SOURCE_LIMIT)
                            end
                        end
                    end
                end
            end
        end
        if #sources >= SEARCH_SOURCE_LIMIT then
            break
        end
    end

    table.sort(sources, function(left, right)
        if math.abs((left.distance or 0) - (right.distance or 0)) > 0.05 then
            return (left.distance or 0) < (right.distance or 0)
        end
        return tostring(left.key or "") < tostring(right.key or "")
    end)

    return sources
end

function DTNPCLootSearch.SelectNextUndiscoveredSource(anchor, npcData)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) then
        return nil
    end
    local state = DTNPCLootSearch.EnsureState(npcData)
    local sources = DTNPCLootSearch.ScanNearbySources(anchor, npcData, true)
    for _, source in ipairs(sources) do
        if not state.searchedSources[source.key] then
            return source
        end
    end
    return nil
end

function DTNPCLootSearch.FindSourceByKey(anchor, npcData, sourceKey)
    if not anchor or not sourceKey then
        return nil
    end

    local sources = DTNPCLootSearch.ScanNearbySources(anchor, npcData, true)
    for _, source in ipairs(sources) do
        if source.key == sourceKey then
            return source
        end
    end
    return nil
end

function DTNPCLootSearch.MoveTowardSource(zombie, npcData, source)
    if not zombie or not npcData or not source then
        return false, "invalid"
    end

    local approach = resolveApproachPoint(source, zombie:getX(), zombie:getY())
    source.approachX = approach and approach.x or source.approachX or source.x
    source.approachY = approach and approach.y or source.approachY or source.y
    source.approachZ = approach and approach.z or source.approachZ or source.z
    source.stopDistance = approach and approach.stopDistance or source.stopDistance or SEARCH_STOP_DISTANCE

    local target = {
        getX = function() return tonumber(source.approachX or source.x) or zombie:getX() end,
        getY = function() return tonumber(source.approachY or source.y) or zombie:getY() end,
        getZ = function() return tonumber(source.approachZ or source.z) or zombie:getZ() end,
    }

    return DTNPCMobility.MoveTowardTarget(zombie, npcData, {
        target = target,
        speed = DynamicTrading.GetNPCWalkSpeed and DynamicTrading.GetNPCWalkSpeed() or 0.035,
        stopDistance = tonumber(source.stopDistance) or SEARCH_STOP_DISTANCE,
        allowObstacleInteract = true,
        allowDamageRetreat = true,
        blockCounterKey = "lootSearchBlockedTicks",
        stuckTicks = 14,
        targetZ = tonumber(source.approachZ or source.z) or zombie:getZ(),
        faceX = tonumber(source.x) or target:getX(),
        faceY = tonumber(source.y) or target:getY(),
        closeDoorSafeRadius = 3.0,
        anim = {
            animSpeed = 1.0,
            isRunning = false,
            dtWalkType = "Walk",
        },
    })
end

function DTNPCLootSearch.HasQueuedCollects(npcData)
    local state = DTNPCLootSearch.EnsureState(npcData)
    for _, queue in pairs(state.pendingCollects or {}) do
        if type(queue) == "table" and #queue > 0 then
            return true
        end
    end
    return false
end

function DTNPCLootSearch.GetQueuedSourceKey(npcData)
    local state = DTNPCLootSearch.EnsureState(npcData)
    for sourceKey, queue in pairs(state.pendingCollects or {}) do
        if type(queue) == "table" and #queue > 0 then
            return sourceKey
        end
    end
    return nil
end

function DTNPCLootSearch.QueueCollectRequest(npcData, sourceKey, itemKeys, requesterUsername)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) or not sourceKey or type(itemKeys) ~= "table" then
        return false
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    local queue = state.pendingCollects[sourceKey]
    if type(queue) ~= "table" then
        queue = {}
        state.pendingCollects[sourceKey] = queue
    end

    local seen = {}
    for _, existingKey in ipairs(queue) do
        seen[tostring(existingKey)] = true
    end

    local changed = false
    for _, itemKey in ipairs(itemKeys) do
        local normalized = tostring(itemKey or "")
        if normalized ~= "" and not seen[normalized] and not wasRecentlyCollected(state, sourceKey, normalized) then
            queue[#queue + 1] = normalized
            seen[normalized] = true
            changed = true
        end
    end

    state.requestedBy = requesterUsername or state.requestedBy
    state.currentSourceKey = sourceKey
    return changed
end

function DTNPCLootSearch.DiscoverSource(npcData, source)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) or not source then
        return false
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    local serialized = serializeSource(source)
    local existing = state.discoveredSources[source.key]
    state.searchedSources[source.key] = true
    state.discoveredSources[source.key] = serialized
    state.currentSourceKey = source.key
    return existing == nil or #((existing and existing.items) or {}) ~= #(serialized.items or {})
end

function DTNPCLootSearch.UpdateDiscoveredSource(npcData, source)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) or not source then
        return false
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    state.discoveredSources[source.key] = serializeSource(source)
    return true
end

local function buildSyncSources(anchor, npcData, state)
    local sources = {}
    if anchor then
        local scannedSources = DTNPCLootSearch.ScanNearbySources(anchor, npcData, false)
        for _, source in ipairs(scannedSources or {}) do
            sources[#sources + 1] = serializeSource(source)
        end
    else
        for _, source in pairs(state.discoveredSources or {}) do
            sources[#sources + 1] = source
        end
    end

    table.sort(sources, function(left, right)
        local leftDistance = tonumber(left and left.distance) or math.huge
        local rightDistance = tonumber(right and right.distance) or math.huge
        if math.abs(leftDistance - rightDistance) > 0.05 then
            return leftDistance < rightDistance
        end

        local leftTime = tonumber(left and left.discoveredAt) or 0
        local rightTime = tonumber(right and right.discoveredAt) or 0
        if leftTime ~= rightTime then
            return leftTime > rightTime
        end
        return tostring(left and left.key or "") < tostring(right and right.key or "")
    end)

    return sources
end

function DTNPCLootSearch.BuildSyncPayload(npcData, sourceKey, autoOpen, anchor)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) then
        return {
            uuid = npcData and npcData.uuid or nil,
            npcName = npcData and npcData.name or nil,
            state = npcData and npcData.state or nil,
            status = npcData and npcData.dcLootStatus or nil,
            currentSourceKey = nil,
            autoOpen = autoOpen == true,
            sources = {},
            dynamicColoniesExclusive = true,
        }
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    local worker, apis = getLinkedWorker(npcData)
    local resolvedAnchor = anchor or findOnlinePlayer(getCommanderUsername(npcData, worker))
    local sources = buildSyncSources(resolvedAnchor, npcData, state)

    return {
        uuid = npcData.uuid,
        npcName = npcData.name,
        state = npcData.state,
        status = npcData.dcLootStatus,
        currentSourceKey = sourceKey or state.currentSourceKey,
        autoOpen = autoOpen == true,
        sources = sources,
        workerCarry = getWorkerCarryState(worker, apis),
        dynamicColoniesExclusive = true,
    }
end

function DTNPCLootSearch.SendSyncToCommander(npcData, worker, sourceKey, autoOpen)
    if isClient() and not isServer() then
        return false
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    local currentTime = nowMillis()
    if autoOpen ~= true and currentTime > 0 and (currentTime - (state.lastSyncAt or 0)) < SEARCH_SYNC_COOLDOWN_MS then
        return false
    end

    local player = findOnlinePlayer(getCommanderUsername(npcData, worker))
    if not player then
        return false
    end

    state.lastSyncAt = currentTime
    sendServerCommand(player, "DTNPC", "LootSearchSync", DTNPCLootSearch.BuildSyncPayload(npcData, sourceKey, autoOpen, player))
    return true
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

    local usernames = {
        tostring(getCommanderUsername(npcData, worker) or ""),
        tostring(worker.ownerUsername or ""),
    }
    local sent = {}
    for _, username in ipairs(usernames) do
        if username ~= "" and not sent[username] then
            sent[username] = true
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

local function transferItemToWorker(zombie, npcData, worker, apis, invItem)
    local registry = apis and apis.registry or nil
    if not registry or not worker or not invItem then
        return false, "invalid", getWorkerCarryState(worker, apis)
    end

    local requestedQty = getInventoryItemQuantity(invItem)
    local fitQty = registry.GetFittingInventoryQuantity
        and registry.GetFittingInventoryQuantity(worker, invItem:getFullType(), requestedQty)
        or requestedQty
    fitQty = math.max(0, tonumber(fitQty) or 0)
    local carryState = getWorkerCarryState(worker, apis)
    if fitQty < requestedQty then
        return false, "no_capacity", carryState
    end

    local outputBuilder = registry.Internal and registry.Internal.BuildOutputEntryFromInventoryItem or nil
    local outputEntry = outputBuilder and outputBuilder(invItem) or {
        fullType = invItem:getFullType(),
        displayName = getItemDisplayName(invItem),
        qty = requestedQty,
    }
    if not outputEntry or not outputEntry.fullType then
        return false, "invalid", carryState
    end

    outputEntry.qty = math.max(1, math.floor(tonumber(outputEntry.qty) or requestedQty))
    local container = invItem.getContainer and invItem:getContainer() or nil
    local storedQty = registry.AddOutputEntry and registry.AddOutputEntry(worker, outputEntry) or 0
    if storedQty < requestedQty then
        return false, "no_capacity", carryState
    end

    if container and container.DoRemoveItem then
        container:DoRemoveItem(invItem)
    elseif DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.RemoveItem then
        DynamicTrading.ServerHelpers.RemoveItem(invItem)
    end

    syncWorkerLootUpdate(worker, npcData, apis)
    if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        DTNPCProtect.PushCompanionNotice(zombie, npcData, "Collected " .. tostring(outputEntry.displayName or outputEntry.fullType) .. ".", "positive")
    end
    return true, "collected", getWorkerCarryState(worker, apis)
end

function DTNPCLootSearch.TryCollectQueuedItems(zombie, npcData, worker, apis, source)
    if not source or not worker or not npcData then
        return 0
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    local queue = state.pendingCollects[source.key]
    if type(queue) ~= "table" or #queue <= 0 then
        return 0
    end

    local itemByKey = {}
    for _, item in ipairs(source.items or {}) do
        itemByKey[tostring(item.key)] = item
    end

    local remaining = {}
    local collected = 0
    local blockedByCapacity = false
    local carryState = getWorkerCarryState(worker, apis)
    for _, itemKey in ipairs(queue) do
        local normalizedItemKey = tostring(itemKey)
        local entry = itemByKey[tostring(itemKey)]
        local invItem = entry and entry.ref or nil
        if wasRecentlyCollected(state, source.key, normalizedItemKey) then
        elseif invItem then
            local transferred, reason, updatedCarryState = transferItemToWorker(zombie, npcData, worker, apis, invItem)
            carryState = updatedCarryState or carryState
            if transferred then
                markRecentlyCollected(state, source.key, normalizedItemKey)
                collected = collected + 1
            elseif reason == "no_capacity" then
                blockedByCapacity = true
            else
                remaining[#remaining + 1] = normalizedItemKey
            end
        end
    end

    if #remaining > 0 then
        state.pendingCollects[source.key] = remaining
    else
        state.pendingCollects[source.key] = nil
    end

    local refreshed = DTNPCLootSearch.FindSourceByKey({
        getX = function() return source.x end,
        getY = function() return source.y end,
        getZ = function() return source.z end,
    }, npcData, source.key)
    if refreshed then
        DTNPCLootSearch.UpdateDiscoveredSource(npcData, refreshed)
    elseif state.discoveredSources[source.key] then
        state.discoveredSources[source.key].items = {}
    end

    npcData.dcLootLastCarryState = carryState
    if blockedByCapacity and DTNPCProtect and DTNPCProtect.PushCompanionNotice and carryState then
        DTNPCProtect.PushCompanionNotice(
            zombie,
            npcData,
            string.format("Carry full %.1f / %.1f.", carryState.usedWeight or 0, carryState.maxWeight or 0),
            "warning"
        )
    end

    return collected
end

function DTNPCLootSearch.ResolveWorker(npcData)
    return getLinkedWorker(npcData)
end

function DTNPCLootSearch.GetWorkerCarryState(npcData)
    local worker, apis = getLinkedWorker(npcData)
    return getWorkerCarryState(worker, apis)
end
