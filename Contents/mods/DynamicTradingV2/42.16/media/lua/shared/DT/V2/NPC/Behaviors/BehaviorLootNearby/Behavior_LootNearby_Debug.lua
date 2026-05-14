-- ==============================================================================
-- Behavior_LootNearby_Debug.lua
-- Debug logging and local loot scan helpers.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.LootNearby = DTNPCLogic.Internal.LootNearby or {}
DTNPCLootDebug = DTNPCLootDebug or {}

local LootNearby = DTNPCLogic.Internal.LootNearby
local modules = LootNearby.Modules or {}
local Constants = LootNearby.Constants or {}

LootNearby.Modules = modules
LootNearby.Constants = Constants

if modules.Debug then
    return
end

modules.Debug = true

function LootNearby.LootDebugLog(npcData, worker, stage, message)
    if not Constants.LOOT_DEBUG_ENABLED then
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

function LootNearby.LootDebugLogChanged(npcData, worker, cacheKey, stage, message)
    if not Constants.LOOT_DEBUG_ENABLED then
        return
    end

    if not npcData then
        LootNearby.LootDebugLog(npcData, worker, stage, message)
        return
    end

    npcData.dcLootDebugMessages = npcData.dcLootDebugMessages or {}
    if npcData.dcLootDebugMessages[cacheKey] == message then
        return
    end

    npcData.dcLootDebugMessages[cacheKey] = message
    LootNearby.LootDebugLog(npcData, worker, stage, message)
end

function LootNearby.BuildDebugItemLootState(item, worker, registry)
    local quantity = math.max(1, math.floor(tonumber(item and item.quantity) or 1))
    if not item or not item.fullType then
        return false, "invalid", 0, quantity
    end
    if not worker or not registry or not registry.GetFittingInventoryQuantity then
        return true, "visible", quantity, quantity
    end

    local fitQty = registry.GetFittingInventoryQuantity(worker, item.fullType, quantity) or 0
    fitQty = math.max(0, tonumber(fitQty) or 0)
    if fitQty <= 0 then
        return false, "no-capacity", fitQty, quantity
    end
    if fitQty < quantity then
        return true, "lootable-partial", fitQty, quantity
    end
    return true, "lootable", fitQty, quantity
end

function DTNPCLootDebug.ScanNearbySources(player, npcData, radiusOverride)
    if not player then
        return {
            sources = {},
            totalSources = 0,
            totalItems = 0,
            radius = tonumber(radiusOverride) or 0,
            filterActive = false,
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

    local worker, apis = LootNearby.GetLinkedWorker(mockNpcData)
    local registry = apis and apis.registry or nil
    local config = LootNearby.NormalizeLootConfig(mockNpcData)
    local rawSources = DTNPCLootSearch.ScanNearbySources(player, mockNpcData, false)
    local sources = {}
    local totalItems = 0

    for _, source in ipairs(rawSources or {}) do
        local debugItems = {}
        for _, item in ipairs(source.items or {}) do
            local lootable, lootReason, fitQty, requestedQty = LootNearby.BuildDebugItemLootState(item, worker, registry)
            debugItems[#debugItems + 1] = {
                key = item.key,
                itemID = item.itemID,
                displayName = item.displayName,
                fullType = item.fullType,
                quantity = item.quantity,
                depth = 0,
                lootable = lootable,
                lootReason = lootReason,
                fitQty = fitQty,
                requestedQty = requestedQty,
            }
        end
        totalItems = totalItems + #debugItems
        sources[#sources + 1] = {
            key = source.key,
            kind = source.kind,
            label = source.label,
            x = source.x,
            y = source.y,
            z = source.z,
            distance = source.distance,
            items = debugItems,
        }
    end

    return {
        sources = sources,
        totalSources = #sources,
        totalItems = totalItems,
        radius = config.radius,
        center = {
            x = math.floor(player:getX()),
            y = math.floor(player:getY()),
            z = math.floor(player:getZ()),
        },
        filterActive = false,
        workerName = worker and worker.name or nil,
        workerID = worker and worker.workerID or nil,
    }
end
