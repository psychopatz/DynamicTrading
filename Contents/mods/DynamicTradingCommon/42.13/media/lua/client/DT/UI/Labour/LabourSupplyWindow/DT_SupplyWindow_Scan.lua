DT_LabourSupplyWindow = DT_LabourSupplyWindow or {}
DT_LabourSupplyWindow.Internal = DT_LabourSupplyWindow.Internal or {}

local Internal = DT_LabourSupplyWindow.Internal

function DT_LabourSupplyWindow:registerVisibleEntry(entry)
    if not self.itemList or not entry then
        return
    end

    self.itemList:addItem(Internal.formatEntryLabel(entry), entry)
    entry.rowIndex = #self.itemList.items

    if not self.selectedEntry then
        self.itemList.selected = entry.rowIndex
        self.selectedEntry = entry
        self:updateItemDetail(entry)
    end
end

function DT_LabourSupplyWindow:addScannedItem(invItem)
    if not invItem then
        return false
    end

    local fullType = invItem.getFullType and invItem:getFullType() or nil
    if fullType == "Base.Money" or fullType == "Base.MoneyBundle" then
        return false
    end

    local entry = Internal.buildInventoryEntry(invItem)
    self.entries[#self.entries + 1] = entry
    self:registerVisibleEntry(entry)
    return true
end

function DT_LabourSupplyWindow:startInventoryScan()
    local player = Internal.getLocalPlayer()
    local rootContainer = player and player.getInventory and player:getInventory() or nil

    self.entries = {}
    self.selectedEntry = nil
    self.scanStack = {}
    self.scanProcessed = 0
    self.scanning = false

    if self.itemList then
        self.itemList:clear()
        self.itemList.selected = -1
    end

    if not rootContainer then
        self:updateItemDetail(nil)
        self:updateStatus("No player inventory found.")
        return
    end

    self.scanStack[#self.scanStack + 1] = {
        container = rootContainer,
        index = 0
    }
    self.scanning = true
    self:updateItemDetail(nil)
    self:updateStatus("Scanning inventory for labour supplies...")
end

function DT_LabourSupplyWindow:finishInventoryScan()
    self.scanning = false

    if self.itemList and self.itemList.items and #self.itemList.items > 0 then
        if not self.selectedEntry then
            self.itemList.selected = 1
            self.selectedEntry = self.itemList.items[1].item
        end
        self:updateItemDetail(self.selectedEntry)
    else
        self.selectedEntry = nil
        self:updateItemDetail(nil)
    end

    self:updateStatus(
        "Loaded "
        .. tostring(#(self.entries or {}))
        .. " visible entries from "
        .. tostring(self.scanProcessed or 0)
        .. " inventory items."
    )
end

function DT_LabourSupplyWindow:processInventoryScan(batchSize)
    if not self.scanning then
        return
    end

    local visibleProcessed = 0
    local rawSteps = 0
    while #self.scanStack > 0
        and visibleProcessed < (batchSize or Internal.ENTRY_SCAN_BATCH_SIZE)
        and rawSteps < Internal.RAW_SCAN_STEP_LIMIT do
        local frame = self.scanStack[#self.scanStack]
        local container = frame and frame.container or nil
        local items = container and container.getItems and container:getItems() or nil

        if not items then
            table.remove(self.scanStack)
        elseif frame.index >= items:size() then
            table.remove(self.scanStack)
        else
            local invItem = items:get(frame.index)
            frame.index = frame.index + 1
            rawSteps = rawSteps + 1

            if invItem then
                local addedVisibleEntry = self:addScannedItem(invItem)
                if addedVisibleEntry then
                    visibleProcessed = visibleProcessed + 1
                end
                self.scanProcessed = self.scanProcessed + 1

                if instanceof(invItem, "InventoryContainer") then
                    local subContainer = invItem:getItemContainer()
                    if subContainer then
                        self.scanStack[#self.scanStack + 1] = {
                            container = subContainer,
                            index = 0
                        }
                    end
                end
            end
        end
    end

    if #self.scanStack <= 0 then
        self:finishInventoryScan()
    elseif self.scanProcessed % 120 == 0 then
        self:updateStatus(
            "Scanning inventory... "
            .. tostring(self.scanProcessed)
            .. " items checked, "
            .. tostring(#(self.entries or {}))
            .. " visible entries."
        )
    end
end

function DT_LabourSupplyWindow:update()
    ISCollapsableWindow.update(self)

    if self.scanning then
        self:processInventoryScan(Internal.ENTRY_SCAN_BATCH_SIZE)
    end
end
