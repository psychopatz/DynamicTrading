DT_Labour = DT_Labour or {}
DT_Labour.Network = DT_Labour.Network or {}

local Network = DT_Labour.Network
local Workers = Network.Workers or {}
local Internal = Network.Internal or {}
local Registry = DT_Labour.Registry
local Config = DT_Labour.Config
local Sim = DT_Labour.Sim
local Presentation = DT_Labour.Presentation

Workers.Shared = Workers.Shared or {}
Network.Workers = Workers
Network.Internal = Internal
Network.Handlers = Network.Handlers or {}

local Shared = Workers.Shared

function Shared.normalizeLedgerIndexes(args)
    local indexes = {}
    local seen = {}

    for _, index in ipairs(args and args.ledgerIndexes or {}) do
        local normalized = math.floor(tonumber(index) or 0)
        if normalized > 0 and not seen[normalized] then
            seen[normalized] = true
            indexes[#indexes + 1] = normalized
        end
    end

    if args and args.ledgerIndex then
        local normalized = math.floor(tonumber(args.ledgerIndex) or 0)
        if normalized > 0 and not seen[normalized] then
            indexes[#indexes + 1] = normalized
        end
    end

    table.sort(indexes, function(a, b)
        return a > b
    end)

    return indexes
end

function Shared.getCurrentWorldHours()
    return (Config.GetCurrentWorldHours and Config.GetCurrentWorldHours()) or Config.GetCurrentHour()
end

function Shared.saveAndRefreshProcessed(player, worker, syncProjection)
    Registry.Save()
    Sim.ProcessWorker(worker, Shared.getCurrentWorldHours())
    Presentation.SyncWorker(worker, { player })
    Internal.syncWorkerDetail(player, worker.workerID, syncProjection)
    Internal.syncWorkerList(player)
end

function Shared.saveAndRefreshBasic(player, worker, syncProjection)
    Registry.Save()
    Internal.syncWorkerDetail(player, worker.workerID, syncProjection)
    Internal.syncWorkerList(player)
end

return Network
