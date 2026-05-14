-- ==============================================================================
-- DTNPC_LootSearchShared_Scan.lua
-- Nearby loot source scanning and cache helpers.
-- ==============================================================================

DTNPCLootSearch = DTNPCLootSearch or {}
DTNPCLootSearch.Internal = DTNPCLootSearch.Internal or {}
DTNPCLootSearch.Modules = DTNPCLootSearch.Modules or {}

if DTNPCLootSearch.Modules.Scan then
    return
end

DTNPCLootSearch.Modules.Scan = true

local Internal = DTNPCLootSearch.Internal
local Constants = Internal.Constants

DTNPCLootSearch.RuntimeScanCache = DTNPCLootSearch.RuntimeScanCache or {}

function Internal.appendItemEntry(items, invItem, sourceKey, prefix, limit, includeRuntimeRefs)
    if not invItem or #items >= limit then
        return
    end

    local itemID = Internal.getInventoryItemID(invItem)
    local itemKey = tostring(sourceKey) .. ":item:" .. tostring(itemID or ((invItem.getFullType and invItem:getFullType()) or "unknown") .. ":" .. tostring(#items + 1))
    local entry = {
        key = itemKey,
        itemID = itemID,
        displayName = tostring(prefix or "") .. Internal.getItemDisplayName(invItem),
        fullType = invItem.getFullType and invItem:getFullType() or nil,
        quantity = Internal.getInventoryItemQuantity(invItem),
    }
    if includeRuntimeRefs then
        entry.ref = invItem
    end
    items[#items + 1] = entry

    local nestedInventory = invItem.getInventory and invItem:getInventory() or nil
    if nestedInventory and #items < limit then
        local nestedItems = nestedInventory.getItems and nestedInventory:getItems() or nil
        if nestedItems then
            local nestedPrefix = tostring(prefix or "") .. Internal.getItemDisplayName(invItem) .. " > "
            for nestedIndex = 0, nestedItems:size() - 1 do
                Internal.appendItemEntry(items, nestedItems:get(nestedIndex), sourceKey, nestedPrefix, limit, includeRuntimeRefs)
                if #items >= limit then
                    break
                end
            end
        end
    end
end

function Internal.getLootConfigSignature(config)
    return table.concat({
        tostring(config and config.radius or 0),
        tostring(config and config.includeLooseWorldItems == true),
        tostring(config and config.includeGroundContainers == true),
        tostring(config and config.includeFurnitureContainers == true),
        tostring(config and config.includeCorpseContainers == true),
        tostring(config and config.includeVehicleContainers == true),
    }, "|")
end

function Internal.getAnchorBucketValue(value)
    return math.floor((tonumber(value) or 0) / Constants.SEARCH_SCAN_BUCKET_SIZE)
end

function Internal.getScanCacheKey(anchor, npcData, config, includeRuntimeRefs, expandItems)
    if not anchor then
        return nil
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    return table.concat({
        tostring(npcData and npcData.uuid or "global"),
        tostring(Internal.getAnchorBucketValue(anchor:getX())),
        tostring(Internal.getAnchorBucketValue(anchor:getY())),
        tostring(math.floor(tonumber(anchor:getZ()) or 0)),
        Internal.getLootConfigSignature(config),
        includeRuntimeRefs == true and "runtime" or "plain",
        expandItems == false and "summary" or "detail",
        tostring(state.scanCacheNonce or 0),
        tostring(Constants.SEARCH_SOURCE_LIMIT),
        tostring(Constants.SEARCH_ITEM_LIMIT),
    }, "|")
end

function Internal.serializeSource(source)
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
        discoveredAt = tonumber(source.discoveredAt) or Internal.nowMillis(),
    }
end

function Internal.addSource(result, source, limit)
    if not source or #result >= limit then
        return
    end

    if source.hasItems ~= true and #(source.items or {}) <= 0 then
        return
    end

    local approach = Internal.resolveApproachPoint(source)
    source.approachX = approach and approach.x or source.x
    source.approachY = approach and approach.y or source.y
    source.approachZ = approach and approach.z or source.z
    source.stopDistance = approach and approach.stopDistance or Constants.SEARCH_STOP_DISTANCE
    result[#result + 1] = source
end

function Internal.createSource(sourceKey, kind, label, x, y, z, distance, stopDistance)
    return {
        key = sourceKey,
        kind = kind,
        label = label,
        x = x,
        y = y,
        z = z,
        distance = distance,
        stopDistance = stopDistance,
        items = {},
        hasItems = false,
        itemsExpanded = false,
    }
end

function DTNPCLootSearch.ExpandSourceItems(source, includeRuntimeRefs)
    if type(source) ~= "table" then
        return nil
    end

    if source.itemsExpanded == true then
        return source
    end

    local items = {}
    if source.kind == "bag" then
        local bagItem = source.runtimeBagItem
        local inventory = bagItem and bagItem.getInventory and bagItem:getInventory() or nil
        local bagItems = inventory and inventory.getItems and inventory:getItems() or nil
        if bagItems then
            for bagIndex = 0, bagItems:size() - 1 do
                Internal.appendItemEntry(items, bagItems:get(bagIndex), source.key, "", Constants.SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                if #items >= Constants.SEARCH_ITEM_LIMIT then
                    break
                end
            end
        end
    elseif source.kind == "groundItem" then
        Internal.appendItemEntry(items, source.runtimeItem, source.key, "", Constants.SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
    else
        local container = source.runtimeContainer
        local containerItems = container and container.getItems and container:getItems() or nil
        if containerItems then
            for itemIndex = 0, containerItems:size() - 1 do
                Internal.appendItemEntry(items, containerItems:get(itemIndex), source.key, "", Constants.SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                if #items >= Constants.SEARCH_ITEM_LIMIT then
                    break
                end
            end
        end
    end

    source.items = items
    source.hasItems = #items > 0
    source.itemsExpanded = true
    return source
end

function Internal.buildScanSources(anchor, npcData, includeRuntimeRefs, expandItems)
    if not anchor then
        return {}
    end

    local cell = getCell and getCell() or nil
    if not cell then
        return {}
    end

    local config = Internal.normalizeConfig(npcData)
    local anchorX = math.floor(anchor:getX())
    local anchorY = math.floor(anchor:getY())
    local anchorZ = math.floor(anchor:getZ())
    local sources = {}
    local seenVehicles = {}

    for y = anchorY - config.radius, anchorY + config.radius do
        for x = anchorX - config.radius, anchorX + config.radius do
            if #sources >= Constants.SEARCH_SOURCE_LIMIT then
                break
            end

            local square = cell:getGridSquare(x, y, anchorZ)
            if square then
                local distance = Internal.getDistance(anchorX, anchorY, x, y)

                if config.includeGroundContainers or config.includeLooseWorldItems then
                    local worldObjects = square:getWorldObjects()
                    if worldObjects then
                        for worldIndex = 0, worldObjects:size() - 1 do
                            local worldObject = worldObjects:get(worldIndex)
                            local item = worldObject and worldObject.getItem and worldObject:getItem() or nil
                            local inventory = item and item.getInventory and item:getInventory() or nil

                            if item and inventory and Internal.lower(item.getCategory and item:getCategory() or "") == "container" and config.includeGroundContainers then
                                local sourceKey = "bag:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(item:getID())
                                local source = Internal.createSource(sourceKey, "bag", Internal.getItemDisplayName(item), x, y, anchorZ, distance, Constants.SEARCH_GROUND_STOP_DISTANCE)
                                source.runtimeBagItem = includeRuntimeRefs == true and item or nil

                                local bagItems = inventory.getItems and inventory:getItems() or nil
                                if bagItems and bagItems:size() > 0 then
                                    source.hasItems = true
                                end
                                if expandItems and bagItems then
                                    for bagIndex = 0, bagItems:size() - 1 do
                                        Internal.appendItemEntry(source.items, bagItems:get(bagIndex), sourceKey, "", Constants.SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                                        if #source.items >= Constants.SEARCH_ITEM_LIMIT then
                                            break
                                        end
                                    end
                                    source.itemsExpanded = true
                                    source.hasItems = #source.items > 0
                                end
                                Internal.addSource(sources, source, Constants.SEARCH_SOURCE_LIMIT)
                            elseif item and not inventory and config.includeLooseWorldItems then
                                local sourceKey = "groundItem:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(item:getID())
                                local source = Internal.createSource(sourceKey, "groundItem", "Ground Item", x, y, anchorZ, distance, Constants.SEARCH_GROUND_STOP_DISTANCE)
                                source.runtimeItem = includeRuntimeRefs == true and item or nil
                                source.hasItems = true
                                if expandItems then
                                    Internal.appendItemEntry(source.items, item, sourceKey, "", Constants.SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                                    source.itemsExpanded = true
                                end
                                Internal.addSource(sources, source, Constants.SEARCH_SOURCE_LIMIT)
                            end
                        end
                    end
                end

                if config.includeFurnitureContainers then
                    local objects = square:getObjects()
                    if objects then
                        for objectIndex = 0, objects:size() - 1 do
                            if #sources >= Constants.SEARCH_SOURCE_LIMIT then
                                break
                            end
                            local object = objects:get(objectIndex)
                            local containerCount = object and object.getContainerCount and tonumber(object:getContainerCount()) or 0
                            for containerIndex = 0, math.max(0, containerCount - 1) do
                                local container = object and object.getContainerByIndex and object:getContainerByIndex(containerIndex) or nil
                                local items = container and container.getItems and container:getItems() or nil
                                if items and items:size() > 0 then
                                    local sourceKey = "world:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(objectIndex) .. ":" .. tostring(containerIndex)
                                    local source = Internal.createSource(
                                        sourceKey,
                                        "world",
                                        container.getType and tostring(container:getType()) or "Container",
                                        x,
                                        y,
                                        anchorZ,
                                        distance,
                                        Constants.SEARCH_WORLD_STOP_DISTANCE
                                    )
                                    source.runtimeContainer = includeRuntimeRefs == true and container or nil
                                    source.hasItems = true
                                    if expandItems then
                                        for itemIndex = 0, items:size() - 1 do
                                            Internal.appendItemEntry(source.items, items:get(itemIndex), sourceKey, "", Constants.SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                                            if #source.items >= Constants.SEARCH_ITEM_LIMIT then
                                                break
                                            end
                                        end
                                        source.itemsExpanded = true
                                        source.hasItems = #source.items > 0
                                    end
                                    Internal.addSource(sources, source, Constants.SEARCH_SOURCE_LIMIT)
                                end
                            end
                        end
                    end
                end

                if config.includeCorpseContainers then
                    local staticObjects = square:getStaticMovingObjects()
                    if staticObjects then
                        for staticIndex = 0, staticObjects:size() - 1 do
                            if #sources >= Constants.SEARCH_SOURCE_LIMIT then
                                break
                            end
                            local staticObject = staticObjects:get(staticIndex)
                            local container = staticObject and staticObject.getContainer and staticObject:getContainer() or nil
                            local items = container and container.getItems and container:getItems() or nil
                            if items and items:size() > 0 then
                                local sourceKey = "corpse:" .. tostring(x) .. ":" .. tostring(y) .. ":" .. tostring(anchorZ) .. ":" .. tostring(staticObject:getID())
                                local source = Internal.createSource(sourceKey, "corpse", "Corpse", x, y, anchorZ, distance, Constants.SEARCH_CORPSE_STOP_DISTANCE)
                                source.runtimeContainer = includeRuntimeRefs == true and container or nil
                                source.hasItems = true
                                if expandItems then
                                    for itemIndex = 0, items:size() - 1 do
                                        Internal.appendItemEntry(source.items, items:get(itemIndex), sourceKey, "", Constants.SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                                        if #source.items >= Constants.SEARCH_ITEM_LIMIT then
                                            break
                                        end
                                    end
                                    source.itemsExpanded = true
                                    source.hasItems = #source.items > 0
                                end
                                Internal.addSource(sources, source, Constants.SEARCH_SOURCE_LIMIT)
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
                                local source = Internal.createSource(
                                    sourceKey,
                                    "vehicle",
                                    container.getType and tostring(container:getType()) or "Vehicle",
                                    x,
                                    y,
                                    anchorZ,
                                    distance,
                                    Constants.SEARCH_VEHICLE_STOP_DISTANCE
                                )
                                source.runtimeContainer = includeRuntimeRefs == true and container or nil
                                source.hasItems = true
                                if expandItems then
                                    for itemIndex = 0, items:size() - 1 do
                                        Internal.appendItemEntry(source.items, items:get(itemIndex), sourceKey, "", Constants.SEARCH_ITEM_LIMIT, includeRuntimeRefs == true)
                                        if #source.items >= Constants.SEARCH_ITEM_LIMIT then
                                            break
                                        end
                                    end
                                    source.itemsExpanded = true
                                    source.hasItems = #source.items > 0
                                end
                                Internal.addSource(sources, source, Constants.SEARCH_SOURCE_LIMIT)
                            end
                        end
                    end
                end
            end
        end
        if #sources >= Constants.SEARCH_SOURCE_LIMIT then
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

function DTNPCLootSearch.GetCachedNearbySources(anchor, npcData, includeRuntimeRefs, expandItems)
    if not anchor then
        return {}
    end

    local config = Internal.normalizeConfig(npcData)
    local cacheKey = Internal.getScanCacheKey(anchor, npcData, config, includeRuntimeRefs, expandItems ~= false)
    local currentTime = Internal.nowMillis()
    if (tonumber(DTNPCLootSearch.RuntimeScanCacheLastPruneAt) or 0) + Constants.SEARCH_SCAN_CACHE_TTL_MS <= currentTime then
        for key, entry in pairs(DTNPCLootSearch.RuntimeScanCache) do
            if (tonumber(entry and entry.expiresAt) or 0) <= currentTime then
                DTNPCLootSearch.RuntimeScanCache[key] = nil
            end
        end
        DTNPCLootSearch.RuntimeScanCacheLastPruneAt = currentTime
    end

    local cacheEntry = cacheKey and DTNPCLootSearch.RuntimeScanCache[cacheKey] or nil
    if cacheEntry and (tonumber(cacheEntry.expiresAt) or 0) > currentTime then
        return cacheEntry.sources or {}
    end

    local sources = Internal.buildScanSources(anchor, npcData, includeRuntimeRefs == true, expandItems ~= false)
    if cacheKey then
        DTNPCLootSearch.RuntimeScanCache[cacheKey] = {
            expiresAt = currentTime + Constants.SEARCH_SCAN_CACHE_TTL_MS,
            sources = sources,
        }
    end
    return sources
end

function DTNPCLootSearch.InvalidateNearbySources(anchor, npcData)
    local state = DTNPCLootSearch.EnsureState(npcData)
    state.scanCacheNonce = math.max(0, math.floor(tonumber(state.scanCacheNonce) or 0)) + 1
end

function DTNPCLootSearch.ScanNearbySources(anchor, npcData, includeRuntimeRefs)
    return DTNPCLootSearch.GetCachedNearbySources(anchor, npcData, includeRuntimeRefs == true, true)
end

function DTNPCLootSearch.SelectNextUndiscoveredSource(anchor, npcData)
    if not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) then
        return nil
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    local sources = DTNPCLootSearch.GetCachedNearbySources(anchor, npcData, true, false)
    for _, source in ipairs(sources) do
        if not state.searchedSources[source.key] then
            return DTNPCLootSearch.ExpandSourceItems(source, true)
        end
    end
    return nil
end

function DTNPCLootSearch.FindSourceByKey(anchor, npcData, sourceKey)
    if not anchor or not sourceKey then
        return nil
    end

    local sources = DTNPCLootSearch.GetCachedNearbySources(anchor, npcData, true, false)
    for _, source in ipairs(sources) do
        if source.key == sourceKey then
            return DTNPCLootSearch.ExpandSourceItems(source, true)
        end
    end
    return nil
end
