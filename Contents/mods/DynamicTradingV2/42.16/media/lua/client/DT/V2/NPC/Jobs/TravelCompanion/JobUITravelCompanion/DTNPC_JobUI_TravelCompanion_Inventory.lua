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

local function applyWarehouseInventoryPresentation(worker)
    local window = DC_SupplyWindow and DC_SupplyWindow.instance or nil
    if not window then
        return
    end

    local workerName = tostring(worker and (worker.name or worker.workerID) or "Worker")
    local title = CompanionUI.T("DTNPC_UI_WarehouseInventoryName", { name = workerName }, "Warehouse Inventory - " .. workerName)
    if window.setTitle then
        window:setTitle(title)
    else
        window.title = title
    end

    if window.updateStatus then
        window:updateStatus("Viewing warehouse inventory details...")
    end
end

local function openPendingCompanionInventory(entry)
    local workerToOpen = CompanionUI.ResolveCompanionWorkerByID(entry.workerID)
    if not workerToOpen or not workerToOpen.workerID or not DC_SupplyWindow or not DC_SupplyWindow.Open then
        return false
    end

    DC_SupplyWindow.Open(workerToOpen, entry.viewMode or "inventory", {
        companionOpen = true,
        requireCanonicalWorkerDetail = true,
        forceRefresh = true,
    })
    applyWarehouseInventoryPresentation(workerToOpen)

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
        local requestDue = (currentTime - (entry.lastRequestAt or 0)) >= Constants.COMPANION_INVENTORY_PREWARM_TIMEOUT_MS

        if isReady then
            if openPendingCompanionInventory(entry) then
                prewarm.pending[workerID] = nil
            else
                stillPending = true
            end
        else
            if requestDue then
                CompanionUI.RequestCompanionInventorySummary(workerID)
                entry.lastRequestAt = currentTime
            end
            stillPending = true
        end
    end

    if not stillPending and prewarm.tickHookAdded then
        Events.OnTick.Remove(CompanionUI.ProcessPendingCompanionInventoryOpens)
        prewarm.tickHookAdded = false
    end
end

function CompanionUI.QueueCompanionInventoryOpen(worker)
    local workerID = CompanionUI.NormalizeWorkerID(worker and worker.workerID or worker)
    if not workerID then
        return false
    end

    local prewarm = getPrewarmState()
    prewarm.pending[workerID] = {
        workerID = workerID,
        viewMode = "inventory",
        startedAt = CompanionUI.NowMs(),
        lastRequestAt = 0,
    }

    CompanionUI.RequestCompanionInventorySummary(workerID)
    prewarm.pending[workerID].lastRequestAt = CompanionUI.NowMs()

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

    local liveNPCData = npcData or CompanionUI.GetNPCData(npc)
    local resolvedWorkerID = CompanionUI.NormalizeWorkerID(
        worker and worker.workerID or CompanionUI.GetCompanionWorkerID(ui, npc, liveNPCData)
    )
    if not resolvedWorkerID then
        CompanionUI.DebugCompanionUI(
            "openCompanionInventory failed to resolve worker linkedWorkerID="
                .. tostring(liveNPCData and liveNPCData.linkedWorkerID or nil)
        )
        return false
    end

    local resolvedWorker = CompanionUI.ResolveCompanionWorkerByID(resolvedWorkerID)

    CompanionUI.DebugCompanionUI(
        "openCompanionInventory workerID=" .. tostring(resolvedWorkerID)
            .. " warm=" .. tostring(CompanionUI.IsWorkerDetailWarm(resolvedWorker))
    )

    local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
    if player and player.setHaloNote then
        player:setHaloNote(CompanionUI.T("DTNPC_UI_LoadingWarehouseInventory", nil, "Loading warehouse inventory..."), 170, 210, 255, 180)
    end

    if CompanionUI.IsWorkerDetailWarm(resolvedWorker) then
        if ui and ui.close then
            ui:close()
        end
        CompanionUI.RequestCompanionInventorySummary(resolvedWorkerID)
        DC_SupplyWindow.Open(resolvedWorker, "inventory", {
            companionOpen = true,
            requireCanonicalWorkerDetail = true,
            forceRefresh = true,
        })
        applyWarehouseInventoryPresentation(resolvedWorker)
        return true
    end

    if ui and ui.close then
        ui:close()
    end
    return CompanionUI.QueueCompanionInventoryOpen(resolvedWorkerID)
end
