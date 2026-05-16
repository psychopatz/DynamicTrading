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

function CompanionUI.NormalizeWorkerID(workerID)
    if workerID == nil then
        return nil
    end

    local textID = tostring(workerID)
    if textID == "" then
        return nil
    end

    return textID
end

function CompanionUI.GetWorkerIDCandidates(workerID)
    local normalizedID = CompanionUI.NormalizeWorkerID(workerID)
    if not normalizedID then
        return {}
    end

    local candidates = { normalizedID }
    local numericID = tonumber(normalizedID)
    if numericID ~= nil then
        candidates[#candidates + 1] = numericID
    end
    return candidates
end

local function lookupWorkerInMap(map, workerID)
    if type(map) ~= "table" then
        return nil
    end

    for _, candidate in ipairs(CompanionUI.GetWorkerIDCandidates(workerID)) do
        local worker = map[candidate]
        if type(worker) == "table" then
            return worker
        end
    end

    return nil
end

local function lookupValueInMap(map, workerID)
    if type(map) ~= "table" then
        return nil
    end

    for _, candidate in ipairs(CompanionUI.GetWorkerIDCandidates(workerID)) do
        local value = map[candidate]
        if value ~= nil then
            return value
        end
    end

    return nil
end

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
    local normalizedID = CompanionUI.NormalizeWorkerID(workerID)
    if not normalizedID then
        return nil
    end

    local cache = DC_MainWindow and DC_MainWindow.cachedDetails or nil
    local cachedWorker = lookupWorkerInMap(cache, normalizedID)
    if cachedWorker then
        return cachedWorker
    end

    local internal = DC_SupplyWindow and DC_SupplyWindow.Internal or nil
    if internal and internal.resolveWorkerDetail then
        local detail = internal.resolveWorkerDetail(normalizedID)
        if detail then
            return detail
        end
    end

    local registry = DC_Colony and DC_Colony.Registry or nil
    if registry and registry.GetWorker then
        for _, candidate in ipairs(CompanionUI.GetWorkerIDCandidates(normalizedID)) do
            local worker = registry.GetWorker(candidate)
            if worker then
                return worker
            end
        end
    end

    if registry and registry.GetWorkerRaw then
        for _, candidate in ipairs(CompanionUI.GetWorkerIDCandidates(normalizedID)) do
            local worker = registry.GetWorkerRaw(candidate)
            if worker then
                return worker
            end
        end
    end

    return nil
end

function CompanionUI.IsWorkerDetailWarm(worker)
    if type(worker) ~= "table" then
        return false
    end

    local warehouse = type(worker.warehouse) == "table" and worker.warehouse or nil
    local warehouseLedgers = warehouse and warehouse.ledgers or nil

    return type(worker.nutritionLedger) == "table"
        and type(worker.toolLedger) == "table"
        and type(worker.skills) == "table"
        and type(warehouseLedgers) == "table"
        and type(warehouseLedgers.provisions) == "table"
        and type(warehouseLedgers.equipment) == "table"
        and type(warehouseLedgers.output) == "table"
end

function CompanionUI.RequestCompanionInventorySummary(workerID)
    local normalizedID = CompanionUI.NormalizeWorkerID(workerID)
    if not normalizedID or not DC_System or not DC_System.SendCommand then
        return false
    end

    local detailVersions = DC_MainWindow and DC_MainWindow.cachedDetailVersions or nil
    local knownWorkerVersion = lookupValueInMap(detailVersions, normalizedID)
    local warehouseVersion = DC_SupplyWindow and DC_SupplyWindow.instance and DC_SupplyWindow.instance.warehouseVersion or nil

    DC_System.SendCommand("RequestWorkerDetails", {
        workerID = normalizedID,
        knownVersion = knownWorkerVersion,
        includeWorkerLedgers = true
    })
    DC_System.SendCommand("RequestWarehouse", {
        knownVersion = warehouseVersion,
        includeLedgers = true
    })
    return true
end

function CompanionUI.GetCompanionWorkerID(ui, npc, npcData)
    local lookupUI = CompanionUI.BuildWorkerLookupUI(ui, npc, npcData)
    local target = lookupUI and lookupUI.target or nil
    return CompanionUI.NormalizeWorkerID(
        (npcData and npcData.linkedWorkerID)
            or (target and target.linkedWorkerID)
            or nil
    )
end

function CompanionUI.GetCompanionWorker(ui, npc, npcData)
    local lookupUI = CompanionUI.BuildWorkerLookupUI(ui, npc, npcData)
    if DC_System and DC_System.GetConversationCompanionWorker then
        local ok, worker = pcall(DC_System.GetConversationCompanionWorker, lookupUI)
        if ok and worker then
            return worker
        end
    end

    local linkedWorkerID = CompanionUI.GetCompanionWorkerID(lookupUI, npc, npcData)
    if linkedWorkerID then
        local worker = CompanionUI.ResolveCompanionWorkerByID(linkedWorkerID)
        if worker then
            return worker
        end
    end

    return nil
end

function CompanionUI.IsPlayerZoneResident(npcData, worker)
    if not npcData and not worker then
        return false
    end

    if tostring(npcData and npcData.state or "") == "PlayerZone" then
        return true
    end

    local linkedWorkerID = npcData and npcData.linkedWorkerID or worker and worker.workerID or nil
    if linkedWorkerID == nil then
        return false
    end

    return tostring(npcData and npcData.dcCompanionJob or "") ~= "TravelCompanion"
end

function CompanionUI.GetWorkerOwnerUsername(worker, npcData)
    return CompanionUI.NormalizeText(
        worker and worker.ownerUsername
            or npcData and (npcData.dcResidentOwnerUsername or npcData.dcCompanionOwner or npcData.ownerUsername or npcData.master)
            or nil
    )
end

function CompanionUI.GetOwnedFactionForWorker(worker, npcData)
    if not DynamicTrading_Factions or not DynamicTrading_Factions.GetPlayerFaction then
        return nil
    end

    local ownerUsername = CompanionUI.GetWorkerOwnerUsername(worker, npcData)
    if not ownerUsername then
        return nil
    end

    local faction = DynamicTrading_Factions.GetPlayerFaction(ownerUsername)
    if type(faction) == "table" and faction.playerOwned == true then
        return faction
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
