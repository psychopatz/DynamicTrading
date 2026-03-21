DT_Labour = DT_Labour or {}
DT_Labour.Registry = DT_Labour.Registry or {}
DT_Labour.Registry.Internal = DT_Labour.Registry.Internal or {}

local Registry = DT_Labour.Registry
local Internal = Registry.Internal
local Nutrition = DT_Labour.Nutrition

function Registry.AddNutritionEntry(worker, entry)
    if not worker or not entry then return end
    worker.nutritionLedger = worker.nutritionLedger or {}
    local calories = 0
    local hydration = 0
    if Nutrition and Nutrition.SanitizeLedgerEntry then
        calories, hydration = Nutrition.SanitizeLedgerEntry(entry)
    end
    worker.nutritionLedger[#worker.nutritionLedger + 1] = entry
    if not Internal.ApplyNutritionCacheDelta(worker, calories, hydration) then
        Internal.MarkNutritionCacheDirty(worker)
    end
end

function Registry.AddToolEntry(worker, entry)
    if not worker or not entry then return end
    worker.toolLedger = worker.toolLedger or {}
    worker.toolLedger[#worker.toolLedger + 1] = entry
    if not Internal.ApplyToolTags(worker, entry.tags or {}) then
        Internal.MarkToolCacheDirty(worker)
    end
end

function Registry.AddOutputEntry(worker, entry)
    if not worker or not entry or not entry.fullType then return end
    worker.outputLedger = worker.outputLedger or {}
    local qtyDelta = tonumber(entry.qty) or 1

    for _, existing in ipairs(worker.outputLedger) do
        if existing.fullType == entry.fullType then
            existing.qty = (existing.qty or 0) + qtyDelta
            if not Internal.ApplyOutputCountDelta(worker, qtyDelta) then
                Internal.MarkOutputCacheDirty(worker)
            end
            return
        end
    end

    worker.outputLedger[#worker.outputLedger + 1] = {
        fullType = entry.fullType,
        qty = qtyDelta
    }
    if not Internal.ApplyOutputCountDelta(worker, qtyDelta) then
        Internal.MarkOutputCacheDirty(worker)
    end
end

function Registry.AddMoney(worker, amount)
    if not worker then return end
    worker.moneyStored = math.max(0, math.floor(tonumber(worker.moneyStored) or 0) + math.floor(tonumber(amount) or 0))
end

function Registry.CollectOutput(worker)
    local output = worker and worker.outputLedger or {}
    if not worker then
        return output
    end
    worker.outputLedger = {}
    Internal.ResetOutputCount(worker)
    return output
end

return Registry
