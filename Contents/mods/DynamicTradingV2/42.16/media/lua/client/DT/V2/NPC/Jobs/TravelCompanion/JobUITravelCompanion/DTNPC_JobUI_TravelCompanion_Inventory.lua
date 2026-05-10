-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_Inventory.lua
-- Companion inventory prewarm and opening flow.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}
local Constants = CompanionUI.Constants or {}
local State = CompanionUI.State or {}

CompanionUI.Modules = modules
CompanionUI.Constants = Constants
CompanionUI.State = State

if modules.Inventory then
    return
end

modules.Inventory = true

local function getPrewarmState()
    State.companionInventoryPrewarm = State.companionInventoryPrewarm or {
        pending = {},
        tickHookAdded = false,
    }
    return State.companionInventoryPrewarm
end

local function openPendingCompanionInventory(entry)
    local workerToOpen = CompanionUI.ResolveCompanionWorkerByID(entry.workerID) or entry.worker
    if not workerToOpen or not workerToOpen.workerID or not DC_SupplyWindow or not DC_SupplyWindow.Open then
        return false
    end

    DC_SupplyWindow.Open(workerToOpen, entry.viewMode or "inventory")
    if DC_SupplyWindow.instance and DC_SupplyWindow.instance.updateStatus then
        DC_SupplyWindow.instance:updateStatus("Loading full inventory details...")
    end

    if DynamicTrading and DynamicTrading.DebugPerformance == true then
        CompanionUI.DebugCompanionUI(
            "companion inventory opened workerID=" .. tostring(entry.workerID)
                .. " latencyMs=" .. tostring(CompanionUI.NowMs() - (entry.startedAt or CompanionUI.NowMs()))
        )
    end
    return true
end

function CompanionUI.ProcessPendingCompanionInventoryOpens()
    local prewarm = getPrewarmState()
    local stillPending = false
    local currentTime = CompanionUI.NowMs()
    local hasPending = false

    for _ in pairs(prewarm.pending) do
        hasPending = true
        break
    end

    if hasPending
        and DC_SupplyWindow
        and DC_SupplyWindow.Preload
        and not DC_SupplyWindow.instance
    then
        pcall(DC_SupplyWindow.Preload)
    end

    for workerID, entry in pairs(prewarm.pending) do
        local warmedWorker = CompanionUI.ResolveCompanionWorkerByID(workerID)
        local isReady = CompanionUI.IsWorkerDetailWarm(warmedWorker)
        local expired = (currentTime - (entry.startedAt or currentTime)) >= Constants.COMPANION_INVENTORY_PREWARM_TIMEOUT_MS

        if isReady or expired then
            if openPendingCompanionInventory(entry) then
                prewarm.pending[workerID] = nil
            else
                stillPending = true
            end
        else
            stillPending = true
        end
    end

    if not stillPending and prewarm.tickHookAdded then
        Events.OnTick.Remove(CompanionUI.ProcessPendingCompanionInventoryOpens)
        prewarm.tickHookAdded = false
    end
end

function CompanionUI.QueueCompanionInventoryOpen(worker)
    if not worker or not worker.workerID then
        return false
    end

    local prewarm = getPrewarmState()
    prewarm.pending[worker.workerID] = {
        workerID = worker.workerID,
        worker = worker,
        viewMode = "inventory",
        startedAt = CompanionUI.NowMs(),
    }

    CompanionUI.RequestCompanionInventorySummary(worker.workerID)

    if not prewarm.tickHookAdded then
        Events.OnTick.Add(CompanionUI.ProcessPendingCompanionInventoryOpens)
        prewarm.tickHookAdded = true
    end

    return true
end

function CompanionUI.OpenCompanionInventory(ui, worker, npc, npcData)
    if not DC_SupplyWindow or not DC_SupplyWindow.Open then
        CompanionUI.DebugCompanionUI("openCompanionInventory missing DC_SupplyWindow.Open")
        return false
    end

    local resolvedWorker = nil
    local liveNPCData = npcData or CompanionUI.GetNPCData(npc)

    if worker and worker.workerID then
        resolvedWorker = {
            workerID = worker.workerID,
            name = worker.name or worker.workerID,
            ownerUsername = worker.ownerUsername,
        }
    end

    if (not resolvedWorker or not resolvedWorker.workerID) and (liveNPCData and liveNPCData.linkedWorkerID) then
        resolvedWorker = {
            workerID = liveNPCData.linkedWorkerID,
            name = liveNPCData.name or liveNPCData.linkedWorkerID,
            ownerUsername = liveNPCData.ownerUsername,
        }
    end

    if not resolvedWorker or not resolvedWorker.workerID then
        CompanionUI.DebugCompanionUI(
            "openCompanionInventory failed to resolve worker linkedWorkerID="
                .. tostring(liveNPCData and liveNPCData.linkedWorkerID or nil)
        )
        return false
    end

    CompanionUI.DebugCompanionUI(
        "openCompanionInventory workerID=" .. tostring(resolvedWorker.workerID)
            .. " name=" .. tostring(resolvedWorker.name or resolvedWorker.workerID)
    )

    if ui and ui.close then
        ui:close()
    end

    local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
    if player and player.setHaloNote then
        player:setHaloNote("Loading companion inventory...", 170, 210, 255, 180)
    end

    if CompanionUI.IsWorkerDetailWarm(resolvedWorker) then
        CompanionUI.RequestCompanionInventorySummary(resolvedWorker.workerID)
        DC_SupplyWindow.Open(resolvedWorker, "inventory")
        if DC_SupplyWindow.instance and DC_SupplyWindow.instance.updateStatus then
            DC_SupplyWindow.instance:updateStatus("Refreshing inventory details...")
        end
        return true
    end

    return CompanionUI.QueueCompanionInventoryOpen(resolvedWorker)
end
