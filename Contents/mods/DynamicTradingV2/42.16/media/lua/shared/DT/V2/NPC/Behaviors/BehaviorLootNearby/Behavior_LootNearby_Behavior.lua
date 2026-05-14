-- ==============================================================================
-- Behavior_LootNearby_Behavior.lua
-- Main loot search behavior entry.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}
DTNPCLogic.Internal.LootNearby = DTNPCLogic.Internal.LootNearby or {}

local LootNearby = DTNPCLogic.Internal.LootNearby
local modules = LootNearby.Modules or {}

LootNearby.Modules = modules

if modules.Behavior then
    return
end

modules.Behavior = true

DTNPCLogic.Behaviors["LootNearby"] = function(zombie, npcData)
    if not zombie or not npcData then
        return
    end

    if isClient() and not isServer() then
        return
    end

    DTNPCProtect.EnsureDataDefaults(npcData)
    LootNearby.ClearLootTarget(npcData)

    local worker, apis = LootNearby.GetLinkedWorker(npcData)
    local registry = apis and apis.registry or nil
    if not worker or not registry then
        LootNearby.LootDebugLog(npcData, worker, "Init", "Looting unavailable: worker=" .. tostring(worker ~= nil) .. " registry=" .. tostring(registry ~= nil))
        LootNearby.StopLooting(zombie, npcData, "Looting isn't available right now.", "warning")
        return
    end

    local debugSignature = table.concat({
        tostring(npcData.state or "nil"),
        tostring(npcData.dcLootStatus or "nil"),
        LootNearby.FormatSourceConfigDebug(LootNearby.NormalizeLootConfig(npcData)),
        "mode=manual_search_collect",
    }, " | ")
    if npcData.dcLootDebugSignature ~= debugSignature then
        npcData.dcLootDebugSignature = debugSignature
        LootNearby.LootDebugLog(npcData, worker, "Init", debugSignature)
    end

    if LootNearby.RunLootCombat(zombie, npcData) then
        return
    end

    local commander = LootNearby.GetLootCommanderTarget(npcData, worker)
    if not commander then
        npcData.dcLootStatus = "idle"
        return
    end

    local lootState = DTNPCLootSearch.EnsureState(npcData)

    local visualCollectTarget = DTNPCLootSearch.GetVisualCollectTarget and DTNPCLootSearch.GetVisualCollectTarget(npcData) or nil
    if visualCollectTarget then
        lootState.currentSourceKey = visualCollectTarget.sourceKey or lootState.currentSourceKey
        LootNearby.TrackLootApproach(npcData, visualCollectTarget.key or visualCollectTarget.sourceKey)
        DTNPCLootSearch.MoveTowardSource(zombie, npcData, visualCollectTarget)
        npcData.dcLootStatus = "collecting"
        return
    end

    local queuedSourceKey = DTNPCLootSearch.GetQueuedSourceKey(npcData)
    if queuedSourceKey then
        lootState.currentSourceKey = queuedSourceKey
        local queuedSource = DTNPCLootSearch.FindSourceByKey(commander, npcData, queuedSourceKey)
        if queuedSource then
            LootNearby.TrackLootApproach(npcData, queuedSource.key)
            local moved, moveState = DTNPCLootSearch.MoveTowardSource(zombie, npcData, queuedSource)
            npcData.dcLootStatus = "collecting"
            if moveState == "arrived" or moveState == "close_enough" then
                LootNearby.ClearLootApproach(npcData, queuedSource.key)
                LootNearby.ClearLootInspection(npcData)
                LootNearby.ResetLootAntiStuck(npcData)
                local collectedCount = DTNPCLootSearch.TryCollectQueuedItems(zombie, npcData, worker, apis, queuedSource)
                DTNPCLootSearch.SendSyncToCommander(npcData, worker, queuedSource.key, true)
                npcData.dcLootStatus = collectedCount > 0 and "looting" or "collecting"
            elseif moveState == "exhausted" then
                LootNearby.ClearLootInspection(npcData)
                LootNearby.ResetLootAntiStuck(npcData)
                if DTNPCMobility and DTNPCMobility.Stop then
                    DTNPCMobility.Stop(zombie)
                end
            elseif moved or moveState == "damage_retreat" or (moveState and string.find(tostring(moveState), "interacted_", 1, true)) then
                LootNearby.ClearLootInspection(npcData)
                LootNearby.ResetLootAntiStuck(npcData)
                LootNearby.LootDebugLogChanged(npcData, worker, "collect_target", "Collect", "Moving to collect from " .. tostring(queuedSource.label or queuedSource.key))
            elseif LootNearby.ShouldTeleportLootApproach(npcData, queuedSource.key) and LootNearby.TeleportLootToSource(zombie, npcData, queuedSource) then
                LootNearby.ClearLootInspection(npcData)
                LootNearby.ResetLootAntiStuck(npcData)
                LootNearby.LootDebugLogChanged(npcData, worker, "collect_teleport", "Collect", "Teleported to collect source " .. tostring(queuedSource.label or queuedSource.key))
            elseif LootNearby.TryRecoverLootMovement(zombie, npcData, queuedSource, moved, moveState) then
                LootNearby.ClearLootInspection(npcData)
                LootNearby.ResetLootAntiStuck(npcData)
            end
            return
        end
        lootState.currentSourceKey = nil
    end

    local searchSource = nil
    if lootState.currentSourceKey and not lootState.searchedSources[lootState.currentSourceKey] then
        searchSource = DTNPCLootSearch.FindSourceByKey(commander, npcData, lootState.currentSourceKey)
    end
    if not searchSource then
        searchSource = DTNPCLootSearch.SelectNextUndiscoveredSource(commander, npcData)
        lootState.currentSourceKey = searchSource and searchSource.key or nil
    end

    if searchSource then
        LootNearby.TrackLootApproach(npcData, searchSource.key)
        local moved, moveState = DTNPCLootSearch.MoveTowardSource(zombie, npcData, searchSource)
        npcData.dcLootStatus = "searching"
        if moveState == "arrived" or moveState == "close_enough" then
            LootNearby.ClearLootApproach(npcData, searchSource.key)
            LootNearby.ResetLootAntiStuck(npcData)
            if LootNearby.BeginLootInspection(npcData, searchSource.key) then
                local discovered = DTNPCLootSearch.DiscoverSource(npcData, searchSource)
                LootNearby.ClearLootInspection(npcData, searchSource.key)
                lootState.currentSourceKey = nil
                npcData.dcLootStatus = "found"
                if discovered then
                    DTNPCLootSearch.SendSyncToCommander(npcData, worker, searchSource.key, true)
                    LootNearby.LootDebugLogChanged(npcData, worker, "discover_source", "Discover", "Discovered source " .. tostring(searchSource.label or searchSource.key) .. " items=" .. tostring(#(searchSource.items or {})))
                end
            else
                npcData.dcLootStatus = "inspecting"
                LootNearby.LootDebugLogChanged(npcData, worker, "inspect_wait", "Search", "Inspecting source " .. tostring(searchSource.label or searchSource.key) .. " before reveal")
            end
        elseif moveState == "exhausted" then
            LootNearby.ClearLootInspection(npcData, searchSource.key)
            LootNearby.ResetLootAntiStuck(npcData)
            if DTNPCMobility and DTNPCMobility.Stop then
                DTNPCMobility.Stop(zombie)
            end
        elseif moved or moveState == "damage_retreat" or (moveState and string.find(tostring(moveState), "interacted_", 1, true)) then
            LootNearby.ClearLootInspection(npcData, searchSource.key)
            LootNearby.ResetLootAntiStuck(npcData)
            LootNearby.LootDebugLogChanged(npcData, worker, "search_target", "Search", "Inspecting source " .. tostring(searchSource.label or searchSource.key))
        elseif LootNearby.ShouldTeleportLootApproach(npcData, searchSource.key) and LootNearby.TeleportLootToSource(zombie, npcData, searchSource) then
            LootNearby.ClearLootInspection(npcData, searchSource.key)
            LootNearby.ResetLootAntiStuck(npcData)
            LootNearby.LootDebugLogChanged(npcData, worker, "search_teleport", "Search", "Teleported to source " .. tostring(searchSource.label or searchSource.key))
        elseif LootNearby.TryRecoverLootMovement(zombie, npcData, searchSource, moved, moveState) then
            LootNearby.ClearLootInspection(npcData, searchSource.key)
            LootNearby.ResetLootAntiStuck(npcData)
        end
        return
    end

    LootNearby.ClearLootInspection(npcData)
    LootNearby.ClearLootApproach(npcData)
    LootNearby.ResetLootAntiStuck(npcData)
    lootState.currentSourceKey = nil

    local followDist = LootNearby.UpdateLootFollowEscort(zombie, npcData, commander)
    npcData.dcLootStatus = (followDist and followDist > 2.0) and "following" or "idle"
end
