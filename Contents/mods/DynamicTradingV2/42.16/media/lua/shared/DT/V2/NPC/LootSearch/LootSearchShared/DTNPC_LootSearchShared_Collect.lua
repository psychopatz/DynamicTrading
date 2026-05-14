-- ==============================================================================
-- DTNPC_LootSearchShared_Collect.lua
-- Collection and transfer helpers.
-- ==============================================================================

DTNPCLootSearch = DTNPCLootSearch or {}
DTNPCLootSearch.Internal = DTNPCLootSearch.Internal or {}
DTNPCLootSearch.Modules = DTNPCLootSearch.Modules or {}

if DTNPCLootSearch.Modules.Collect then
    return
end

DTNPCLootSearch.Modules.Collect = true

local Internal = DTNPCLootSearch.Internal

function Internal.syncWorkerLootUpdate(worker, npcData, apis)
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
        tostring(Internal.getCommanderUsername(npcData, worker) or ""),
        tostring(worker.ownerUsername or ""),
    }
    local sent = {}
    for _, username in ipairs(usernames) do
        if username ~= "" and not sent[username] then
            sent[username] = true
            local player = Internal.findOnlinePlayer(username)
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

function Internal.rollbackWorkerOutputEntry(worker, registry, outputEntry, storedQty)
    local ledger = worker and worker.outputLedger or nil
    if type(ledger) ~= "table" or storedQty <= 0 or not outputEntry or not registry then
        return false
    end

    local internal = registry.Internal or nil
    local signatureBuilder = internal and internal.GetOutputEntryStateSignature or nil
    local targetSignature = signatureBuilder and signatureBuilder(outputEntry) or nil
    for index = #ledger, 1, -1 do
        local entry = ledger[index]
        local sameEntry = false
        if targetSignature and signatureBuilder then
            sameEntry = signatureBuilder(entry) == targetSignature
        else
            sameEntry = tostring(entry and entry.fullType or "") == tostring(outputEntry.fullType or "")
                and tostring(entry and entry.displayName or "") == tostring(outputEntry.displayName or "")
        end

        if sameEntry then
            local currentQty = math.max(0, tonumber(entry and entry.qty) or 0)
            local nextQty = currentQty - storedQty
            if nextQty > 0 then
                entry.qty = nextQty
            else
                table.remove(ledger, index)
            end
            if internal and internal.MarkOutputCacheDirty then
                internal.MarkOutputCacheDirty(worker)
            end
            return true
        end
    end

    return false
end

function Internal.isRemovedFromSource(invItem, originalContainer)
    if not invItem then
        return false
    end

    local currentContainer = invItem.getContainer and invItem:getContainer() or nil
    if originalContainer then
        return currentContainer ~= originalContainer
    end

    local worldItem = invItem.getWorldItem and invItem:getWorldItem() or nil
    return currentContainer == nil and worldItem == nil
end

function Internal.removeInventoryItemFromSource(invItem)
    if not invItem then
        return false
    end

    local container = invItem.getContainer and invItem:getContainer() or nil
    if container and container.DoRemoveItem then
        container:DoRemoveItem(invItem)
        if sendRemoveItemFromContainer then
            sendRemoveItemFromContainer(container, invItem)
        end
        if Internal.isRemovedFromSource(invItem, container) then
            return true
        end
    end

    if DynamicTrading and DynamicTrading.ServerHelpers and DynamicTrading.ServerHelpers.RemoveItem then
        DynamicTrading.ServerHelpers.RemoveItem(invItem)
        if Internal.isRemovedFromSource(invItem, container) then
            return true
        end
    end

    return false
end

function Internal.transferItemToWorker(zombie, npcData, worker, apis, invItem)
    local registry = apis and apis.registry or nil
    if not registry or not worker or not invItem then
        return false, "invalid", Internal.getWorkerCarryState(worker, apis)
    end

    local requestedQty = Internal.getInventoryItemQuantity(invItem)
    local fitQty = registry.GetFittingInventoryQuantity
        and registry.GetFittingInventoryQuantity(worker, invItem:getFullType(), requestedQty)
        or requestedQty
    fitQty = math.max(0, tonumber(fitQty) or 0)
    local carryState = Internal.getWorkerCarryState(worker, apis)
    if fitQty < requestedQty then
        return false, "no_capacity", carryState
    end

    local outputBuilder = registry.Internal and registry.Internal.BuildOutputEntryFromInventoryItem or nil
    local outputEntry = outputBuilder and outputBuilder(invItem) or {
        fullType = invItem:getFullType(),
        displayName = Internal.getItemDisplayName(invItem),
        qty = requestedQty,
    }
    if not outputEntry or not outputEntry.fullType then
        return false, "invalid", carryState
    end

    outputEntry.qty = math.max(1, math.floor(tonumber(outputEntry.qty) or requestedQty))
    local storedQty = registry.AddOutputEntry and registry.AddOutputEntry(worker, outputEntry) or 0
    if storedQty < requestedQty then
        return false, "no_capacity", carryState
    end

    if not Internal.removeInventoryItemFromSource(invItem) then
        Internal.rollbackWorkerOutputEntry(worker, registry, outputEntry, storedQty)
        if registry.RecalculateWorker then
            registry.RecalculateWorker(worker)
        end
        return false, "remove_failed", Internal.getWorkerCarryState(worker, apis)
    end

    Internal.syncWorkerLootUpdate(worker, npcData, apis)
    if DTNPCProtect and DTNPCProtect.PushCompanionNotice then
        DTNPCProtect.PushCompanionNotice(zombie, npcData, "Collected " .. tostring(outputEntry.displayName or outputEntry.fullType) .. ".", "positive")
    end
    return true, "collected", Internal.getWorkerCarryState(worker, apis)
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
    local carryState = Internal.getWorkerCarryState(worker, apis)
    local stateChanged = false
    for _, itemKey in ipairs(queue) do
        local normalizedItemKey = tostring(itemKey)
        local entry = itemByKey[tostring(itemKey)]
        local invItem = entry and entry.ref or nil
        if Internal.wasRecentlyCollected(state, source.key, normalizedItemKey) then
        elseif invItem then
            local transferred, reason, updatedCarryState = Internal.transferItemToWorker(zombie, npcData, worker, apis, invItem)
            carryState = updatedCarryState or carryState
            if transferred then
                Internal.markRecentlyCollected(state, source.key, normalizedItemKey)
                collected = collected + 1
                stateChanged = true
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

    if stateChanged then
        DTNPCLootSearch.InvalidateNearbySources(nil, npcData)
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
        Internal.setCollectEvent(state, "no_capacity", source.key, carryState, state.requestedBy or Internal.getCommanderUsername(npcData, worker))
        DTNPCProtect.PushCompanionNotice(
            zombie,
            npcData,
            string.format("Carry full %.1f / %.1f.", carryState.usedWeight or 0, carryState.maxWeight or 0),
            "warning"
        )
        stateChanged = true
    elseif stateChanged then
        state.lastCollectEvent = nil
    end

    return collected
end

function DTNPCLootSearch.CollectItemsImmediately(anchor, zombie, npcData, sourceKey, itemKeys, requesterUsername)
    if not anchor or not DTNPCLootSearch.IsDynamicColoniesCompanion(npcData) or not sourceKey or type(itemKeys) ~= "table" or #itemKeys <= 0 then
        return false, 0
    end

    local worker, apis = Internal.getLinkedWorker(npcData)
    if not worker or not (apis and apis.registry) then
        return false, 0
    end

    local source = DTNPCLootSearch.FindSourceByKey(anchor, npcData, sourceKey)
    if not source then
        return false, 0
    end

    local changed = DTNPCLootSearch.QueueCollectRequest(npcData, sourceKey, itemKeys, requesterUsername)
    if not changed then
        return false, 0
    end

    local state = DTNPCLootSearch.EnsureState(npcData)
    Internal.setVisualCollectTarget(state, source)
    local collectedCount = DTNPCLootSearch.TryCollectQueuedItems(zombie, npcData, worker, apis, source)
    npcData.dcLootStatus = collectedCount > 0 and "looting" or "collecting"
    state.currentSourceKey = source.key
    return true, collectedCount
end
