DT_Labour = DT_Labour or {}
DT_Labour.Registry = DT_Labour.Registry or {}
DT_Labour.Registry.Internal = DT_Labour.Registry.Internal or {}

local Registry = DT_Labour.Registry

function Registry.AddNutritionEntry(worker, entry)
    if not worker or not entry then return end
    worker.nutritionLedger = worker.nutritionLedger or {}
    worker.nutritionLedger[#worker.nutritionLedger + 1] = entry
    Registry.RecalculateWorker(worker)
end

function Registry.AddToolEntry(worker, entry)
    if not worker or not entry then return end
    worker.toolLedger = worker.toolLedger or {}
    worker.toolLedger[#worker.toolLedger + 1] = entry
    Registry.RecalculateWorker(worker)
end

function Registry.AddOutputEntry(worker, entry)
    if not worker or not entry or not entry.fullType then return end
    worker.outputLedger = worker.outputLedger or {}

    for _, existing in ipairs(worker.outputLedger) do
        if existing.fullType == entry.fullType then
            existing.qty = (existing.qty or 0) + (entry.qty or 1)
            Registry.RecalculateWorker(worker)
            return
        end
    end

    worker.outputLedger[#worker.outputLedger + 1] = {
        fullType = entry.fullType,
        qty = entry.qty or 1
    }
    Registry.RecalculateWorker(worker)
end

function Registry.AddMoney(worker, amount)
    if not worker then return end
    worker.moneyStored = math.max(0, math.floor(tonumber(worker.moneyStored) or 0) + math.floor(tonumber(amount) or 0))
    Registry.RecalculateWorker(worker)
end

function Registry.CollectOutput(worker)
    local output = worker and worker.outputLedger or {}
    worker.outputLedger = {}
    Registry.RecalculateWorker(worker)
    return output
end

return Registry
