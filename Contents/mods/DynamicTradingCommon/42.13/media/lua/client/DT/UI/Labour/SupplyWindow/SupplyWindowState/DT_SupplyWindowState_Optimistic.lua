DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

function DT_SupplyWindow:applyOptimisticDeposit(entries)
    local changed = false

    for _, entry in ipairs(entries or {}) do
        local removed = self:removePlayerEntryByID(entry.itemID)
        if removed then
            changed = true
        end
    end

    if changed then
        self:rebuildPlayerList()
        self:refreshWorkerEntries()
    end
end

function DT_SupplyWindow:applyOptimisticToolAssign(entries)
    local changed = false

    for _, entry in ipairs(entries or {}) do
        local removed = self:removePlayerEntryByID(entry.itemID)
        if removed then
            changed = true
        end
    end

    if changed then
        self:rebuildPlayerList()
        self:refreshWorkerEntries()
    end
end

