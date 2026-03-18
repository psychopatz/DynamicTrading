require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/DT_Labour_Nutrition"

DT_LabourSupplyWindow = ISCollapsableWindow:derive("DT_LabourSupplyWindow")
DT_LabourSupplyWindow.instance = nil

local Config = DT_Labour.Config
local Nutrition = DT_Labour.Nutrition
local ENTRY_SCAN_BATCH_SIZE = 40
local RAW_SCAN_STEP_LIMIT = 600
local NutritionPreviewCache = {}

local function getCommandModule()
    if type(Config) == "table" and Config.COMMAND_MODULE and Config.COMMAND_MODULE ~= "" then
        return Config.COMMAND_MODULE
    end
    return "DynamicTrading_V2"
end

local function getLocalPlayer()
    if Config.GetPlayerObject then
        return Config.GetPlayerObject()
    end
    if getSpecificPlayer then
        return getSpecificPlayer(0)
    end
    return getPlayer and getPlayer() or nil
end

local function getCachedNutritionPreview(invItem)
    if not invItem then
        return 0, 0
    end

    local hasDynamicFluid = invItem.getFluidContainer and invItem:getFluidContainer() ~= nil
    local fullType = invItem.getFullType and invItem:getFullType() or nil

    if not hasDynamicFluid and fullType and NutritionPreviewCache[fullType] then
        local cached = NutritionPreviewCache[fullType]
        return cached.calories or 0, cached.hydration or 0
    end

    local calories, hydration = Nutrition.GetItemNutrition(invItem)
    calories = math.max(0, tonumber(calories) or 0)
    hydration = math.max(0, tonumber(hydration) or 0)

    if not hasDynamicFluid and fullType then
        NutritionPreviewCache[fullType] = {
            calories = calories,
            hydration = hydration
        }
    end

    return calories, hydration
end

local function formatEntryLabel(entry)
    if not entry then
        return "Unknown Item"
    end

    return tostring(entry.displayName or entry.fullType or "Unknown Item")
end

local function buildInventoryEntry(invItem)
    local calories, hydration = getCachedNutritionPreview(invItem)
    return {
        invItem = invItem,
        itemID = invItem:getID(),
        displayName = invItem:getDisplayName(),
        fullType = invItem:getFullType(),
        calories = calories,
        hydration = hydration,
        canDeposit = calories > 0 or hydration > 0,
        texture = invItem.getTex and invItem:getTex() or nil,
    }
end

local LabourSupplyList = ISScrollingListBox:derive("LabourSupplyList")

function LabourSupplyList:new(x, y, width, height)
    local o = ISScrollingListBox:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.itemheight = 44
    o.selected = -1
    o.font = UIFont.Small
    return o
end

function LabourSupplyList:doDrawItem(y, item, alt)
    local entry = item.item
    if not entry then
        return y + self.itemheight
    end

    local width = self:getWidth()
    local isSelected = self.selected == item.index
    if isSelected then
        self:drawRect(0, y, width, self.itemheight, 0.25, 0.18, 0.38, 0.62)
    elseif not entry.canDeposit then
        self:drawRect(0, y, width, self.itemheight, 0.15, 0.15, 0.08, 0.08)
    elseif alt then
        self:drawRect(0, y, width, self.itemheight, 0.08, 1, 1, 1)
    end

    self:drawRectBorder(0, y, width, self.itemheight, 0.08, 1, 1, 1)

    if entry.texture then
        self:drawTextureScaled(entry.texture, 6, y + 6, 30, 30, entry.canDeposit and 1 or 0.35, 1, 1, 1)
    end

    local textR, textG, textB = 0.9, 0.9, 0.9
    if not entry.canDeposit then
        textR, textG, textB = 0.45, 0.45, 0.45
    end

    self:drawText(formatEntryLabel(entry), 44, y + 6, textR, textG, textB, 1, UIFont.Small)

    local statText
    if entry.canDeposit then
        statText = string.format("+%.0f cal | +%.0f hyd", entry.calories or 0, entry.hydration or 0)
    else
        statText = "No calories or hydration"
    end
    self:drawText(statText, 44, y + 24, 0.65, 0.8, 0.95, 1, UIFont.Small)

    return y + self.itemheight
end

function DT_LabourSupplyWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 760
    self.minimumHeight = 460
end

function DT_LabourSupplyWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local pad = 10
    local headerY = th + pad
    local listY = headerY + 36
    local footerH = 38
    local leftWidth = math.floor(self.width * 0.58)
    local contentHeight = self.height - listY - footerH - pad
    local rightX = leftWidth + (pad * 2)
    local rightWidth = self.width - rightX - pad

    self.btnRefresh = ISButton:new(10, headerY, 90, 28, "Refresh", self, self.onRefresh)
    self.btnRefresh:initialise()
    self:addChild(self.btnRefresh)

    self.btnDeposit = ISButton:new(110, headerY, 140, 28, "Deposit Selected", self, self.onDepositSelected)
    self.btnDeposit:initialise()
    self:addChild(self.btnDeposit)

    self.itemList = LabourSupplyList:new(10, listY, leftWidth, contentHeight)
    self.itemList:initialise()
    self.itemList:instantiate()
    self.itemList.target = self
    self.itemList.onmousedown = DT_LabourSupplyWindow.onItemListMouseDown
    self.itemList:setAnchorBottom(true)
    self:addChild(self.itemList)

    self.detailText = ISRichTextPanel:new(rightX, listY, rightWidth, contentHeight)
    self.detailText:initialise()
    self.detailText.backgroundColor = { r = 0, g = 0, b = 0, a = 0.2 }
    self.detailText.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    self.detailText:addScrollBars()
    self.detailText:setAnchorRight(true)
    self.detailText:setAnchorBottom(true)
    self:addChild(self.detailText)

    self.statusText = ISRichTextPanel:new(rightX, self.height - footerH - 4, rightWidth, 28)
    self.statusText:initialise()
    self.statusText.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.statusText.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.statusText:setAnchorRight(true)
    self.statusText:setAnchorBottom(true)
    self:addChild(self.statusText)

    self:updateStatus("Browse your inventory and deposit food or drinks into the selected worker.")
    self:updateItemDetail(nil)
end

function DT_LabourSupplyWindow:updateStatus(text)
    if not self.statusText then
        return
    end
    self.statusText:setText(" <RGB:0.75,0.75,0.75> " .. tostring(text or "") .. " ")
    self.statusText:paginate()
end

function DT_LabourSupplyWindow:updateItemDetail(entry)
    if not self.detailText then
        return
    end

    if not entry then
        self.detailText:setText(" <RGB:0.6,0.6,0.6> Select an inventory item to preview its labour upkeep value. Money is handled through the dedicated Give Money button. ")
        self.detailText:paginate()
        return
    end

    local text = ""
    text = text .. " <RGB:1,1,1> <SIZE:Large> " .. tostring(formatEntryLabel(entry)) .. " <LINE> <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Full Type: <RGB:1,1,1> " .. tostring(entry.fullType or "Unknown") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Adds Calories: <RGB:1,1,1> " .. string.format("%.0f", entry.calories or 0) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Adds Hydration: <RGB:1,1,1> " .. string.format("%.0f", entry.hydration or 0) .. " <LINE> <LINE> "

    if entry.canDeposit then
        text = text .. " <RGB:0.7,1,0.7> This item can be deposited into worker upkeep. "
    else
        text = text .. " <RGB:1,0.6,0.6> This item is visible for future labour item transfer, but upkeep only reads food and water right now. "
    end

    self.detailText:setText(text)
    self.detailText:paginate()
end

function DT_LabourSupplyWindow:registerVisibleEntry(entry)
    if not self.itemList or not entry then
        return
    end

    self.itemList:addItem(formatEntryLabel(entry), entry)
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

    local entry = buildInventoryEntry(invItem)
    self.entries[#self.entries + 1] = entry
    self:registerVisibleEntry(entry)
    return true
end

function DT_LabourSupplyWindow:startInventoryScan()
    local player = getLocalPlayer()
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
        and visibleProcessed < (batchSize or ENTRY_SCAN_BATCH_SIZE)
        and rawSteps < RAW_SCAN_STEP_LIMIT do
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

function DT_LabourSupplyWindow:onRefresh()
    self:startInventoryScan()
end

function DT_LabourSupplyWindow:onDepositSelected()
    local selectedEntry = self.selectedEntry

    if not self.workerID then
        self:updateStatus("No worker selected.")
        return
    end
    if not selectedEntry then
        if self.scanning then
            self:updateStatus("Inventory scan still in progress.")
            return
        end
        self:updateStatus("Select an item first.")
        return
    end
    if not selectedEntry.canDeposit then
        self:updateStatus("That item is visible for future labour transfer, but upkeep only accepts food and water.")
        return
    end

    local player = getLocalPlayer()
    if not player then
        self:updateStatus("Missing local player.")
        return
    end

    if isClient() and not isServer() then
        sendClientCommand(player, getCommandModule(), "DepositWorkerSupplies", {
            workerID = self.workerID,
            itemID = selectedEntry.itemID
        })
    elseif DT_Labour and DT_Labour.Network and DT_Labour.Network.HandleCommand then
        DT_Labour.Network.HandleCommand(player, "DepositWorkerSupplies", {
            workerID = self.workerID,
            itemID = selectedEntry.itemID
        })
    end

    self:updateStatus("Depositing " .. tostring(selectedEntry.displayName or selectedEntry.fullType or "selected item") .. "...")
end

function DT_LabourSupplyWindow:update()
    ISCollapsableWindow.update(self)

    if self.scanning then
        self:processInventoryScan(ENTRY_SCAN_BATCH_SIZE)
    end
end

function DT_LabourSupplyWindow.onItemListMouseDown(target, item)
    if not target or not item then
        return
    end
    local entry = item.item or item
    target.selectedEntry = entry
    target:updateItemDetail(entry)
end

function DT_LabourSupplyWindow.Open(worker)
    if not worker or not worker.workerID then
        return
    end

    local window = DT_LabourSupplyWindow.instance
    if not window then
        local width = 820
        local height = 520
        local x = (getCore():getScreenWidth() - width) / 2
        local y = (getCore():getScreenHeight() - height) / 2

        window = DT_LabourSupplyWindow:new(x, y, width, height)
        window:initialise()
        window:instantiate()
        DT_LabourSupplyWindow.instance = window
    end

    window.workerID = worker.workerID
    window.workerName = worker.name or worker.workerID
    window.title = "Labour Supplies - " .. tostring(window.workerName)
    window:setVisible(true)
    window:addToUIManager()
    window:bringToTop()
    window:startInventoryScan()
    window:updateStatus("Supplying " .. tostring(window.workerName) .. ".")
end

function DT_LabourSupplyWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_LabourSupplyWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Labour Supplies"
    o.resizable = true
    o.entries = {}
    o.selectedEntry = nil
    o.workerID = nil
    o.workerName = nil
    return o
end

local function onServerCommand(module, command, args)
    if module ~= getCommandModule() then
        return
    end
    if not DT_LabourSupplyWindow.instance or not DT_LabourSupplyWindow.instance:getIsVisible() then
        return
    end
    if command == "SyncWorkerDetails" or command == "SyncPlayerWorkers" then
        DT_LabourSupplyWindow.instance:startInventoryScan()
    end
end

if not DT_LabourSupplyWindow.EventsAdded then
    Events.OnServerCommand.Add(onServerCommand)
    DT_LabourSupplyWindow.EventsAdded = true
end

return DT_LabourSupplyWindow
