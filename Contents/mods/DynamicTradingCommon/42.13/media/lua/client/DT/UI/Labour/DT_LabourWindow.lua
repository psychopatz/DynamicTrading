require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
require "DT/UI/Labour/DT_LabourQuantityModal"
require "DT/UI/Labour/LabourSupplyWindow/DT_LabourSupplyWindow"
require "DT/Common/Labour/DT_Labour_Config"
require "DT/Common/Labour/DT_Labour_Registry"
require "DT/Common/Labour/DT_Labour_Network"
require "DT/Common/UI/Trading/Provider/DT_TradingProvider_Core"

DT_LabourWindow = ISCollapsableWindow:derive("DT_LabourWindow")
DT_LabourWindow.instance = nil
DT_LabourWindow.cachedWorkers = DT_LabourWindow.cachedWorkers or {}
DT_LabourWindow.cachedDetails = DT_LabourWindow.cachedDetails or {}

local Config = DT_Labour.Config
local MoneyProvider = DT_LabourWindow.MoneyProvider or {}
DynamicTrading.TradingProvider.AttachCore(MoneyProvider)
DT_LabourWindow.MoneyProvider = MoneyProvider

local function formatReserveValue(value)
    return string.format("%.0f", tonumber(value) or 0)
end

local function getReserveDaysLeft(storedAmount, dailyNeed)
    local perDay = tonumber(dailyNeed) or 0
    if perDay <= 0 then
        return "n/a"
    end

    local days = (tonumber(storedAmount) or 0) / perDay
    return string.format("%.2f", math.max(0, days))
end

local function formatWorkerListSubtitle(worker)
    local archetype = tostring(worker.archetypeID or "General")
    local jobType = tostring(worker.jobType or worker.profession or "Scavenge")
    local state = tostring(worker.state or "Idle")
    return archetype .. " -> " .. jobType .. " | " .. state
end

local function buildToolInputText(worker)
    local parts = {}
    for _, entry in ipairs(worker.toolLedger or {}) do
        parts[#parts + 1] = tostring(entry.displayName or entry.fullType or "Unknown Tool")
    end

    if #parts == 0 then
        return "None assigned yet."
    end

    return table.concat(parts, ", ")
end

local function buildSupplyInputText(worker)
    local parts = {}
    for _, entry in ipairs(worker.nutritionLedger or {}) do
        local name = tostring(entry.displayName or entry.fullType or "Supply")
        local calories = formatReserveValue(entry.caloriesRemaining)
        local hydration = formatReserveValue(entry.hydrationRemaining)
        parts[#parts + 1] = name .. " [" .. calories .. " cal, " .. hydration .. " hyd]"
    end

    if #parts == 0 then
        return "None stored yet."
    end

    return table.concat(parts, ", ")
end

local function getPlayerWealth(player)
    if DT_LabourWindow.MoneyProvider and DT_LabourWindow.MoneyProvider.getPlayerWealth then
        return DT_LabourWindow.MoneyProvider:getPlayerWealth(player)
    end
    return 0
end

local function getOwnerUsername()
    local player = Config.GetPlayerObject and Config.GetPlayerObject() or nil
    if Config.GetOwnerUsername then
        return Config.GetOwnerUsername(player)
    end
    return "local"
end

local function appendHeldItem(targetList, seenIDs, itemObj)
    if not itemObj or not itemObj.getID then
        return
    end

    local itemID = itemObj:getID()
    if itemID == nil or seenIDs[itemID] then
        return
    end

    seenIDs[itemID] = true
    targetList[#targetList + 1] = itemObj
end

local function getHeldItems()
    local player = Config.GetPlayerObject and Config.GetPlayerObject() or nil
    if not player then
        return {}
    end

    local items = {}
    local seenIDs = {}
    appendHeldItem(items, seenIDs, player.getPrimaryHandItem and player:getPrimaryHandItem() or nil)
    appendHeldItem(items, seenIDs, player.getSecondaryHandItem and player:getSecondaryHandItem() or nil)
    return items
end

local function resolveWorkerSummaries()
    if isClient() and not isServer() then
        return DT_LabourWindow.cachedWorkers or {}
    end

    if DT_Labour and DT_Labour.Registry and DT_Labour.Registry.GetWorkerSummariesForOwner then
        return DT_Labour.Registry.GetWorkerSummariesForOwner(getOwnerUsername())
    end

    return {}
end

local function resolveWorkerDetail(workerID)
    if not workerID then return nil end

    if isClient() and not isServer() then
        local cache = DT_LabourWindow.cachedDetails or {}
        return cache[workerID]
    end

    if DT_Labour and DT_Labour.Registry and DT_Labour.Registry.GetWorkerDetailsForOwner then
        return DT_Labour.Registry.GetWorkerDetailsForOwner(getOwnerUsername(), workerID)
    end

    return nil
end

local LabourWorkerList = ISScrollingListBox:derive("LabourWorkerList")

function LabourWorkerList:new(x, y, width, height)
    local o = ISScrollingListBox:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.itemheight = 56
    o.selected = 1
    o.drawBorder = true
    o.font = UIFont.Medium
    return o
end

function LabourWorkerList:doDrawItem(y, item, alt)
    local worker = item.item
    if not worker then return y + self.itemheight end

    if item.selected then
        self:drawRect(0, y, self.width, self.itemheight, 0.25, 0.18, 0.38, 0.62)
    elseif alt then
        self:drawRect(0, y, self.width, self.itemheight, 0.08, 1, 1, 1)
    else
        self:drawRect(0, y, self.width, self.itemheight, 0.08, 0, 0, 0)
    end

    self:drawText(tostring(worker.name or worker.workerID), 10, y + 6, 0.85, 0.9, 1, 1, UIFont.Medium)
    self:drawText(
        formatWorkerListSubtitle(worker),
        10,
        y + 30,
        0.7,
        0.7,
        0.7,
        0.95,
        UIFont.Small
    )
    self:drawRectBorder(0, y, self.width, self.itemheight, 0.08, 1, 1, 1)
    return y + self.itemheight
end

function DT_LabourWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
    self.minimumWidth = 860
    self.minimumHeight = 540
end

function DT_LabourWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local pad = 10
    local headerY = th + pad
    local buttonY = headerY
    local listY = headerY + 38
    local footerH = 38
    local listWidth = 280
    local contentHeight = self.height - listY - footerH - pad
    local rightX = listWidth + (pad * 2)
    local rightWidth = self.width - rightX - pad

    self.btnRefresh = ISButton:new(10, buttonY, 90, 28, "Refresh", self, self.onRefresh)
    self.btnRefresh:initialise()
    self:addChild(self.btnRefresh)

    self.btnCollect = ISButton:new(110, buttonY, 120, 28, "Collect Output", self, self.onCollectOutput)
    self.btnCollect:initialise()
    self:addChild(self.btnCollect)

    self.btnToggleJob = ISButton:new(240, buttonY, 100, 28, "Start Job", self, self.onToggleJob)
    self.btnToggleJob:initialise()
    self:addChild(self.btnToggleJob)

    self.btnCycleJob = ISButton:new(350, buttonY, 100, 28, "Change Job", self, self.onCycleJob)
    self.btnCycleJob:initialise()
    self:addChild(self.btnCycleJob)

    self.btnAssignHeldTool = ISButton:new(460, buttonY, 140, 28, "Assign Held Tool", self, self.onAssignHeldTool)
    self.btnAssignHeldTool:initialise()
    self:addChild(self.btnAssignHeldTool)

    self.btnGiveMoney = ISButton:new(610, buttonY, 110, 28, "Give Money", self, self.onGiveMoney)
    self.btnGiveMoney:initialise()
    self:addChild(self.btnGiveMoney)

    self.btnManageSupplies = ISButton:new(730, buttonY, 150, 28, "Manage Supplies", self, self.onManageSupplies)
    self.btnManageSupplies:initialise()
    self:addChild(self.btnManageSupplies)

    self.workerList = LabourWorkerList:new(10, listY, listWidth, contentHeight)
    self.workerList:initialise()
    self.workerList:instantiate()
    self.workerList.target = self
    self.workerList.onmousedown = DT_LabourWindow.onWorkerListMouseDown
    self.workerList:setAnchorLeft(true)
    self.workerList:setAnchorTop(true)
    self.workerList:setAnchorBottom(true)
    self:addChild(self.workerList)

    self.detailText = ISRichTextPanel:new(rightX, listY, rightWidth, contentHeight)
    self.detailText:initialise()
    self.detailText.backgroundColor = { r = 0, g = 0, b = 0, a = 0.2 }
    self.detailText.borderColor = { r = 1, g = 1, b = 1, a = 0.1 }
    self.detailText:setAnchorRight(true)
    self.detailText:setAnchorBottom(true)
    self.detailText:addScrollBars()
    self:addChild(self.detailText)

    self.statusText = ISRichTextPanel:new(rightX, self.height - footerH - 4, rightWidth, 28)
    self.statusText:initialise()
    self.statusText.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.statusText.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.statusText:setAnchorRight(true)
    self.statusText:setAnchorBottom(true)
    self:addChild(self.statusText)

    self:updateStatus("Labour Management ready. Jobs are tool-gated, workplaces are deferred, and food/water remain upkeep.")
    self:populateWorkerList(DT_LabourWindow.cachedWorkers or {})
end

function DT_LabourWindow:prerender()
    ISCollapsableWindow.prerender(self)
    local th = self:titleBarHeight()
    local pad = 10
    local listY = th + pad + 38
    local contentHeight = self.height - listY - 38 - pad
    self:drawRectBorder(10, listY, 280, contentHeight, 0.4, 1, 1, 1)
    self:drawTextCentre("LABOUR MANAGEMENT", self.width / 2, th + 6, 1, 1, 1, 1, UIFont.Large)
end

function DT_LabourWindow:updateStatus(text)
    if not self.statusText then return end
    self.statusText:setText(" <RGB:0.75,0.75,0.75> " .. tostring(text or "") .. " ")
    self.statusText:paginate()
end

function DT_LabourWindow:sendLabourCommand(command, args)
    local player = Config.GetPlayerObject and Config.GetPlayerObject() or nil
    if not player then return false end

    if isClient() and not isServer() then
        sendClientCommand(player, "DynamicTrading_V2", command, args or {})
        return true
    end

    if DT_Labour and DT_Labour.Network and DT_Labour.Network.HandleCommand then
        DT_Labour.Network.HandleCommand(player, command, args or {})
        return true
    end

    return false
end

function DT_LabourWindow:onRefresh()
    self:updateStatus("Refreshing labour roster...")

    if isClient() and not isServer() then
        if not self:sendLabourCommand("RequestPlayerWorkers", {}) then
            self:updateStatus("Unable to request worker data.")
        end
        return
    end

    self:populateWorkerList(resolveWorkerSummaries())
    self:updateStatus("Loaded local worker data.")
end

function DT_LabourWindow:populateWorkerList(workers)
    if not self.workerList then return end
    self.workerList:clear()

    local preferredID = self.selectedWorkerSummary and self.selectedWorkerSummary.workerID or nil
    local selectedIndex = nil

    for _, worker in ipairs(workers or {}) do
        self.workerList:addItem(worker.name or worker.workerID, worker)
        if preferredID and preferredID == worker.workerID then
            selectedIndex = #self.workerList.items
        end
    end

    if self.workerList.items and #self.workerList.items > 0 then
        local targetIndex = selectedIndex or 1
        self.workerList.selected = targetIndex
        self:applyWorkerSelection(self.workerList.items[targetIndex].item, false)
    else
        self.selectedWorkerSummary = nil
        self.selectedWorker = nil
        self:updateWorkerDetail(nil)
    end
end

function DT_LabourWindow:updateWorkerDetail(worker)
    self.selectedWorker = worker

    if not self.detailText then return end

    if not worker then
        self.detailText:setText(" <RGB:0.6,0.6,0.6> No worker selected. Recruit one from ConversationUI or load an existing worker. ")
        self.detailText:paginate()
        if self.btnToggleJob then
            self.btnToggleJob:setTitle("Start Job")
        end
        return
    end

    local profile = Config.GetJobProfile(worker.jobType)
    local toolTags = profile.requiredToolTags or {}
    local bonusMultiplier = Config.GetJobSpeedMultiplier(worker.archetypeID, worker.jobType)
    local caloriesDays = getReserveDaysLeft(worker.caloriesCached, worker.dailyCaloriesNeed)
    local hydrationDays = getReserveDaysLeft(worker.hydrationCached, worker.dailyHydrationNeed)

    local text = ""
    text = text .. " <RGB:1,1,1> <SIZE:Large> " .. tostring(worker.name or "Worker") .. " <LINE> <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Archetype: <RGB:0.4,0.8,1> " .. tostring(worker.archetypeID or "Unknown") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Current Job: <RGB:1,1,1> " .. tostring(worker.jobType or worker.profession or "Unknown") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> State: <RGB:1,1,1> " .. tostring(worker.state or "Idle") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Job Enabled: <RGB:1,1,1> " .. tostring(worker.jobEnabled == true) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Specialist Bonus: <RGB:1,1,1> x" .. string.format("%.2f", bonusMultiplier) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Workplace: <RGB:1,1,1> TODO / deferred <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Required Tools: <RGB:1,1,1> " .. table.concat(toolTags, ", ") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Work Coordinates: <RGB:1,1,1> " .. tostring(worker.workX or "-") .. ", " .. tostring(worker.workY or "-") .. ", " .. tostring(worker.workZ or 0) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Site State: <RGB:1,1,1> " .. tostring(worker.siteState or "Deferred") .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Tool State: <RGB:1,1,1> " .. tostring(worker.toolState or "Missing") .. " <LINE> <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Calories Stored: <RGB:1,1,1> " .. formatReserveValue(worker.caloriesCached) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Hydration Stored: <RGB:1,1,1> " .. formatReserveValue(worker.hydrationCached) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Calories Days Left: <RGB:1,1,1> " .. caloriesDays .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Hydration Days Left: <RGB:1,1,1> " .. hydrationDays .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Fatal Threshold: <RGB:1,1,1> 3 days at zero calories or hydration <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Nutrition Entries: <RGB:1,1,1> " .. tostring(#(worker.nutritionLedger or {})) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Assigned Tools: <RGB:1,1,1> " .. tostring(#(worker.toolLedger or {})) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Pending Output: <RGB:1,1,1> " .. tostring(worker.outputCount or 0) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Stored Money: <RGB:1,1,1> $" .. tostring(math.floor(tonumber(worker.moneyStored) or 0)) .. " <LINE> "
    text = text .. " <LINE> <RGB:1,1,1> <SIZE:Medium> Foundation Inputs <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Tool Inputs: <RGB:1,1,1> " .. buildToolInputText(worker) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Food / Water Inputs: <RGB:1,1,1> " .. buildSupplyInputText(worker) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Money Reserve: <RGB:1,1,1> $" .. tostring(math.floor(tonumber(worker.moneyStored) or 0)) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Productive Consumables: <RGB:1,1,1> TODO after foundation polish <LINE> "

    self.detailText:setText(text)
    self.detailText:paginate()

    if self.btnToggleJob then
        self.btnToggleJob:setTitle(worker.jobEnabled and "Stop Job" or "Start Job")
    end
end

function DT_LabourWindow:applyWorkerSelection(summary, requestDetail)
    if not summary then return end
    self.selectedWorkerSummary = summary

    local detail = resolveWorkerDetail(summary.workerID) or summary
    self:updateWorkerDetail(detail)

    if requestDetail and isClient() and not isServer() then
        self:updateStatus("Requesting worker details for " .. tostring(summary.name or summary.workerID) .. "...")
        self:sendLabourCommand("RequestWorkerDetails", { workerID = summary.workerID })
    end
end

function DT_LabourWindow:onCollectOutput()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    self:sendLabourCommand("CollectWorkerOutput", { workerID = self.selectedWorkerSummary.workerID })
    self:updateStatus("Collecting worker output...")
end

function DT_LabourWindow:onToggleJob()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    local enabled = not (self.selectedWorker and self.selectedWorker.jobEnabled)
    self:sendLabourCommand("SetWorkerJobEnabled", {
        workerID = self.selectedWorkerSummary.workerID,
        enabled = enabled
    })
    self:updateStatus(enabled and "Starting job..." or "Stopping job...")
end

function DT_LabourWindow:onCycleJob()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    local currentJobType = self.selectedWorker and self.selectedWorker.jobType or self.selectedWorkerSummary.jobType
    local nextJobType = Config.GetNextJobType(currentJobType)
    self:sendLabourCommand("SetWorkerJobType", {
        workerID = self.selectedWorkerSummary.workerID,
        jobType = nextJobType
    })
    self:updateStatus("Changing worker job to " .. tostring(nextJobType) .. "...")
end

function DT_LabourWindow:onAssignHeldTool()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    for _, itemObj in ipairs(getHeldItems()) do
        if Config.IsToolItem and Config.IsToolItem(itemObj) then
            self:sendLabourCommand("AssignWorkerToolset", {
                workerID = self.selectedWorkerSummary.workerID,
                itemID = itemObj:getID()
            })
            self:updateStatus("Assigning held tool to " .. tostring(self.selectedWorkerSummary.name or self.selectedWorkerSummary.workerID) .. "...")
            return
        end
    end

    self:updateStatus("Hold a tool in your primary or secondary hand first.")
end

function DT_LabourWindow:onManageSupplies()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    DT_LabourSupplyWindow.Open(self.selectedWorker or self.selectedWorkerSummary)
    self:updateStatus("Opening supply manager...")
end

function DT_LabourWindow:onGiveMoney()
    if not self.selectedWorkerSummary then
        self:updateStatus("Select a worker first.")
        return
    end

    local player = Config.GetPlayerObject and Config.GetPlayerObject() or getSpecificPlayer(0)
    local wealth = getPlayerWealth(player)
    if wealth <= 0 then
        self:updateStatus("You do not have any money to give.")
        return
    end

    local workerName = tostring((self.selectedWorker and self.selectedWorker.name) or self.selectedWorkerSummary.name or self.selectedWorkerSummary.workerID)
    DT_LabourQuantityModal.Open({
        title = "Give Money",
        promptText = "How much money do you want to give to " .. workerName .. "?",
        maxValue = wealth,
        defaultValue = wealth,
        onConfirm = function(quantity)
            self:sendLabourCommand("GiveWorkerMoney", {
                workerID = self.selectedWorkerSummary.workerID,
                amount = quantity
            })
            self:updateStatus("Giving $" .. tostring(quantity) .. " to " .. workerName .. "...")
        end
    })
end

function DT_LabourWindow.onWorkerListMouseDown(target, item)
    if not item then return end
    local win = target or DT_LabourWindow.instance
    if not win or not win.applyWorkerSelection then return end
    win:applyWorkerSelection(item, true)
end

local function onServerCommand(module, command, args)
    if module ~= "DynamicTrading_V2" then return end

    if command == "SyncPlayerWorkers" then
        DT_LabourWindow.cachedWorkers = args and args.workers or {}
        if DT_LabourWindow.instance and DT_LabourWindow.instance:getIsVisible() then
            DT_LabourWindow.instance:populateWorkerList(DT_LabourWindow.cachedWorkers)
            DT_LabourWindow.instance:updateStatus("Worker list synced.")
        end
    elseif command == "SyncWorkerDetails" then
        if args and args.worker and args.worker.workerID then
            DT_LabourWindow.cachedDetails = DT_LabourWindow.cachedDetails or {}
            DT_LabourWindow.cachedDetails[args.worker.workerID] = args.worker
            if DT_LabourWindow.instance
                and DT_LabourWindow.instance:getIsVisible()
                and DT_LabourWindow.instance.selectedWorkerSummary
                and DT_LabourWindow.instance.selectedWorkerSummary.workerID == args.worker.workerID then
                DT_LabourWindow.instance:updateWorkerDetail(args.worker)
                DT_LabourWindow.instance:updateStatus("Worker details synced.")
            end
        end
    elseif command == "LabourNotice" then
        if DT_LabourWindow.instance and DT_LabourWindow.instance:getIsVisible() then
            DT_LabourWindow.instance:updateStatus(args and args.message or "Labour update received.")
        end
    end
end

if not DT_LabourWindow.EventsAdded then
    Events.OnServerCommand.Add(onServerCommand)
    Events.OnReceiveGlobalModData.Add(function(key, data)
        if not DT_LabourWindow.instance or not DT_LabourWindow.instance:getIsVisible() then return end
        if key == (Config.MOD_DATA_KEY or "DynamicTrading_Labour") then
            DT_LabourWindow.instance:populateWorkerList(resolveWorkerSummaries())
            DT_LabourWindow.instance:updateStatus("Labour data refreshed from ModData.")
        end
    end)
    DT_LabourWindow.EventsAdded = true
end

function DT_LabourWindow.ToggleWindow()
    if DT_LabourWindow.instance then
        if DT_LabourWindow.instance:getIsVisible() then
            DT_LabourWindow.instance:close()
        else
            DT_LabourWindow.instance:setVisible(true)
            DT_LabourWindow.instance:addToUIManager()
            DT_LabourWindow.instance:bringToTop()
            DT_LabourWindow.instance:populateWorkerList(DT_LabourWindow.cachedWorkers or {})
            DT_LabourWindow.instance:updateStatus("Labour Management opened.")
        end
        return
    end

    DT_LabourWindow.Open()
end

function DT_LabourWindow.Open()
    if DT_LabourWindow.instance then
        DT_LabourWindow.instance:setVisible(true)
        DT_LabourWindow.instance:addToUIManager()
        DT_LabourWindow.instance:bringToTop()
        DT_LabourWindow.instance:populateWorkerList(DT_LabourWindow.cachedWorkers or {})
        DT_LabourWindow.instance:updateStatus("Labour Management opened.")
        return
    end

    local width = 920
    local height = 600
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    local window = DT_LabourWindow:new(x, y, width, height)
    window:initialise()
    window:instantiate()
    window:setVisible(true)
    window:addToUIManager()
    window:bringToTop()
    DT_LabourWindow.instance = window
end

function DT_LabourWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_LabourWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Labour Management"
    o.resizable = true
    return o
end

return DT_LabourWindow
