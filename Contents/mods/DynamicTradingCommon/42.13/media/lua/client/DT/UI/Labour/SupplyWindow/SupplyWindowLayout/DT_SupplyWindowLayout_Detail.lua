DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function DT_SupplyWindow:updateItemDetail(entry, side)
    if not self.detailText then
        return
    end

    if not entry then
        local workerTabLabel = Internal.getActiveWorkerTabLabel(self)
        self.detailText:setText(
            " <RGB:0.78,0.78,0.78> Left side shows your inventory cache, right side shows what "
                .. tostring(self.workerName or "the worker")
                .. " currently has stored in "
                .. workerTabLabel
                .. ". "
                .. "<LINE> <RGB:0.62,0.62,0.62> Use "
                .. "<RGB:1,1,1> > <RGB:0.62,0.62,0.62> for one selected item or "
                .. "<RGB:1,1,1> >> <RGB:0.62,0.62,0.62> to send every visible filtered item when the active tab supports transfers. "
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
        if self.activeTab == Internal.Tabs.Equipment then
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
        if self.activeTab == Internal.Tabs.Equipment then
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
