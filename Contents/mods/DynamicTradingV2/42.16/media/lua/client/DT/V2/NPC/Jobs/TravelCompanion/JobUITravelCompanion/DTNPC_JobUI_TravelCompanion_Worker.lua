-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_Worker.lua
-- Companion worker resolution and legacy compatibility helpers.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}

CompanionUI.Modules = modules

if modules.Worker then
    return
end

modules.Worker = true

function CompanionUI.BuildWorkerLookupUI(ui, npc, npcData)
    if ui then
        return ui
    end

    return {
        interactionObj = npc,
        target = {
            id = npcData and npcData.uuid or nil,
            name = npcData and npcData.name or nil,
            factionID = npcData and npcData.factionID or nil,
            linkedWorkerID = npcData and npcData.linkedWorkerID or nil,
            master = npcData and npcData.master or nil,
            masterID = npcData and npcData.masterID or nil,
            isCompanion = true,
        }
    }
end

function CompanionUI.ResolveCompanionWorkerByID(workerID)
    if not workerID then
        return nil
    end

    local cache = DC_MainWindow and DC_MainWindow.cachedDetails or nil
    if type(cache) == "table" and type(cache[workerID]) == "table" then
        return cache[workerID]
    end

    local internal = DC_SupplyWindow and DC_SupplyWindow.Internal or nil
    if internal and internal.resolveWorkerDetail then
        local detail = internal.resolveWorkerDetail(workerID)
        if detail then
            return detail
        end
    end

    local registry = DC_Colony and DC_Colony.Registry or nil
    if registry and registry.GetWorker then
        local worker = registry.GetWorker(workerID)
        if worker then
            return worker
        end
    end

    if registry and registry.GetWorkerRaw then
        return registry.GetWorkerRaw(workerID)
    end

    return nil
end

function CompanionUI.IsWorkerDetailWarm(worker)
    if type(worker) ~= "table" then
        return false
    end

    return worker.nutritionLedger ~= nil
        or worker.toolLedger ~= nil
        or worker.outputLedger ~= nil
        or worker.haulLedger ~= nil
        or worker.skills ~= nil
        or worker.warehouse ~= nil
end

function CompanionUI.RequestCompanionInventorySummary(workerID)
    if not workerID or not DC_System or not DC_System.SendCommand then
        return false
    end

    local detailVersions = DC_MainWindow and DC_MainWindow.cachedDetailVersions or nil
    local knownWorkerVersion = detailVersions and detailVersions[workerID] or nil
    local warehouseVersion = DC_SupplyWindow and DC_SupplyWindow.instance and DC_SupplyWindow.instance.warehouseVersion or nil

    DC_System.SendCommand("RequestWorkerDetails", {
        workerID = workerID,
        knownVersion = knownWorkerVersion,
        includeWorkerLedgers = false
    })
    DC_System.SendCommand("RequestWarehouse", {
        knownVersion = warehouseVersion,
        includeLedgers = false
    })
    return true
end

function CompanionUI.GetCompanionWorker(ui, npc, npcData)
    local lookupUI = CompanionUI.BuildWorkerLookupUI(ui, npc, npcData)
    if DC_System and DC_System.GetConversationCompanionWorker then
        local ok, worker = pcall(DC_System.GetConversationCompanionWorker, lookupUI)
        if ok and worker then
            return worker
        end
    end

    local target = lookupUI and lookupUI.target or nil
    local linkedWorkerID = (npcData and npcData.linkedWorkerID)
        or (target and target.linkedWorkerID)
        or nil
    if linkedWorkerID then
        local worker = CompanionUI.ResolveCompanionWorkerByID(linkedWorkerID)
        if worker then
            return worker
        end
    end

    return nil
end

function CompanionUI.IsLegacyTravelCompanion(player, npcData)
    if not player or not npcData then
        return false
    end

    if tostring(npcData.dcCompanionJob or "") ~= "TravelCompanion" then
        return false
    end

    if npcData.dcCompanionActive ~= true then
        return false
    end

    local authority = CompanionUI.NormalizeText(CompanionUI.GetAuthorityUsername(player))
    local owner = CompanionUI.NormalizeText(npcData.dcCompanionOwner or npcData.ownerUsername or npcData.master or nil)
    return authority ~= nil and owner == authority
end

function CompanionUI.AttachNPCData(npc, npcData)
    if npc and npcData and DTNPC and DTNPC.AttachData then
        DTNPC.AttachData(npc, npcData)
    end
end
