DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function DT_SupplyWindow:updateItemDetail(entry, side)
    if not self.detailText then
        return
    end

    if not entry then
        local workerTabLabel = Internal.getActiveWorkerTabLabel(self)
        local workerStorageLabel = "stored in "
        local transferAllowed = Internal.canTransferWithWorker(self.workerData)
        if self.activeTab == Internal.Tabs.Output and not transferAllowed then
            workerStorageLabel = "currently carrying in "
        end
        local transferGuidance = ""
        if transferAllowed then
            transferGuidance =
                "<LINE> <RGB:0.62,0.62,0.62> Use "
                .. "<RGB:1,1,1> < <RGB:0.62,0.62,0.62> for one selected worker item or "
                .. "<RGB:1,1,1> << <RGB:0.62,0.62,0.62> to pull every visible filtered worker item back to your inventory. "
                .. "<LINE> <RGB:0.62,0.62,0.62> Use "
                .. "<RGB:1,1,1> > <RGB:0.62,0.62,0.62> for one selected item or "
                .. "<RGB:1,1,1> >> <RGB:0.62,0.62,0.62> to send every visible filtered item when the active tab supports transfers. "
                .. "<LINE> <RGB:0.62,0.62,0.62> Select the "
                .. "<RGB:1,1,1> cash <RGB:0.62,0.62,0.62> entry on Provisions and use "
                .. "<RGB:1,1,1> > <RGB:0.62,0.62,0.62> or "
                .. "<RGB:1,1,1> < <RGB:0.62,0.62,0.62> to open the money transfer modal. "
        else
            transferGuidance =
                "<LINE> <RGB:0.85,0.72,0.38> "
                .. Internal.getTransferBlockedReason(self.workerData)
                .. " "
                .. "<LINE> <RGB:0.62,0.62,0.62> This window is read-only while they are away, so you can inspect the haul but not move items. "
        end
        self.detailText:setText(
            " <RGB:0.78,0.78,0.78> Left side shows your inventory cache, right side shows what "
                .. tostring(self.workerName or "the worker")
                .. " is "
                .. workerStorageLabel
                .. workerTabLabel
                .. ". "
                .. transferGuidance
                .. "<LINE> <RGB:0.62,0.62,0.62> Active worker tab: <RGB:1,1,1> "
                .. workerTabLabel
                .. " <RGB:0.62,0.62,0.62> | "
                .. Internal.getWorkerTabSummary(self, self.workerEntries)
        )
        self.detailText:paginate()
        return
    end

    local text = ""
    if side == "worker" then
        text = text .. " <RGB:1,1,1> <SIZE:Large> " .. Internal.getActiveWorkerTabLabel(self) .. " <LINE> <LINE> "
        text = text .. " <RGB:0.82,0.82,0.82> Item: <RGB:1,1,1> " .. tostring(Internal.formatEntryLabel(entry)) .. " <LINE> "
        text = text .. " <RGB:0.82,0.82,0.82> Full Type: <RGB:1,1,1> " .. tostring(entry.fullType or "Unknown") .. " <LINE> "
        if entry.kind == "money" then
            text = text .. " <RGB:0.82,0.82,0.82> Stored Dollars: <RGB:1,1,1> $" .. tostring(math.max(0, math.floor(tonumber(entry.amount) or 0))) .. " <LINE> "
            text = text .. " <RGB:0.82,0.82,0.82> Action: <RGB:1,1,1> Use < to withdraw a chosen amount. <LINE> "
        elseif self.activeTab == Internal.Tabs.Equipment then
            local tags = entry.tags or {}
            text = text .. " <RGB:0.82,0.82,0.82> Tool Tags: <RGB:1,1,1> "
                .. ((#tags > 0 and table.concat(tags, ", ")) or "None")
                .. " <LINE> "
        elseif self.activeTab == Internal.Tabs.Output then
            text = text .. " <RGB:0.82,0.82,0.82> Quantity: <RGB:1,1,1> " .. tostring(entry.qty or 1) .. " <LINE> "
        else
            text = text .. " <RGB:0.82,0.82,0.82> Remaining Calories: <RGB:1,1,1> " .. string.format("%.0f", entry.calories or 0) .. " <LINE> "
            text = text .. " <RGB:0.82,0.82,0.82> Remaining Hydration: <RGB:1,1,1> " .. string.format("%.0f", entry.hydration or 0) .. " <LINE> "
        end
    else
        text = text .. " <RGB:1,1,1> <SIZE:Large> Player Item <LINE> <LINE> "
        text = text .. " <RGB:0.82,0.82,0.82> Item: <RGB:1,1,1> " .. tostring(Internal.formatEntryLabel(entry)) .. " <LINE> "
        text = text .. " <RGB:0.82,0.82,0.82> Full Type: <RGB:1,1,1> " .. tostring(entry.fullType or "Unknown") .. " <LINE> "
        if entry.kind == "money" then
            text = text .. " <RGB:0.82,0.82,0.82> Available Dollars: <RGB:1,1,1> $" .. tostring(math.max(0, math.floor(tonumber(entry.amount) or 0))) .. " <LINE> "
            text = text .. " <RGB:0.82,0.82,0.82> Action: <RGB:1,1,1> Use > to deposit a chosen amount. <LINE> "
        elseif self.activeTab == Internal.Tabs.Equipment then
            local tags = entry.tags or {}
            text = text .. " <RGB:0.82,0.82,0.82> Tool Tags: <RGB:1,1,1> "
                .. ((#tags > 0 and table.concat(tags, ", ")) or "None")
                .. " <LINE> "
            text = text .. " <RGB:0.82,0.82,0.82> Required For Worker: <RGB:1,1,1> " .. Internal.getRequiredToolSummary(self.workerData) .. " <LINE> "
        else
            text = text .. " <RGB:0.82,0.82,0.82> Adds Calories: <RGB:1,1,1> " .. string.format("%.0f", entry.calories or 0) .. " <LINE> "
            text = text .. " <RGB:0.82,0.82,0.82> Adds Hydration: <RGB:1,1,1> " .. string.format("%.0f", entry.hydration or 0) .. " <LINE> "
        end
    end

    self.detailText:setText(text)
    self.detailText:paginate()
end
