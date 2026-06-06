-- ==============================================================================
-- DT_FactionBaseLedgerWindow.lua
-- Dedicated admin/debug UI for active and abandoned NPC faction bases.
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISScrollingListBox"

require "DT/Common/UI/Debug/DT_DebugPaneUtils"
require "DT/Common/UI/Debug/Factions/BaseLedger/DT_FactionBaseLedgerData"
require "DT/Common/UI/Debug/Factions/BaseLedger/DT_FactionBaseLedgerActions"
require "DT/Common/UI/Debug/Factions/BaseLedger/DT_FactionBaseLedgerRenderers"

DT_FactionBaseLedgerWindow = ISCollapsableWindow:derive("DT_FactionBaseLedgerWindow")

local PAD = 10
local GAP = 8
local FOOTER_H = 34
local MIN_W = 540
local MIN_H = 360

local function relayoutScrollbars(widget)
    local paneUtils = DynamicTrading and DynamicTrading.DebugUI and DynamicTrading.DebugUI.PaneUtils or nil
    if paneUtils and paneUtils.RelayoutEmbeddedScrollbars then
        paneUtils.RelayoutEmbeddedScrollbars(widget)
        return
    end

    if widget and widget.vscroll then
        local widgetWidth = widget.getWidth and widget:getWidth() or widget.width or 0
        local widgetHeight = widget.getHeight and widget:getHeight() or widget.height or 0
        local scrollWidth = widget.vscroll.getWidth and widget.vscroll:getWidth() or widget.vscroll.width or 13
        widget.vscroll:setX(math.max(0, widgetWidth - scrollWidth))
        widget.vscroll:setY(0)
        widget.vscroll:setHeight(widgetHeight)
        widget.vscroll:bringToTop()
    end
end

local function setBounds(widget, x, y, width, height)
    if not widget then
        return
    end

    widget:setX(x)
    widget:setY(y)
    widget:setWidth(width)
    widget:setHeight(height)
    widget.width = width
    widget.height = height
    relayoutScrollbars(widget)
end

local function refreshRichText(widget)
    if not widget then
        return
    end
    if widget.onResize then
        pcall(function()
            widget:onResize()
        end)
    end
    widget:paginate()
    relayoutScrollbars(widget)
end

local function formatRowDetails(row, ledger)
    if type(row) ~= "table" then
        return " <RGB:0.7,0.7,0.7> Select a base location."
    end

    local text = " <RGB:1,1,0> BASE LOCATION <LINE> "
    text = text .. " <RGB:0.7,0.7,0.7> Name: <RGB:1,1,1> " .. tostring(row.currentName or "Unknown") .. " <LINE> "
    if tostring(row.formerName or "") ~= "" and tostring(row.formerName) ~= tostring(row.currentName) then
        text = text .. " <RGB:0.7,0.7,0.7> Former Name: <RGB:1,1,1> " .. tostring(row.formerName) .. " <LINE> "
    elseif tostring(row.formerName or "") ~= "" then
        text = text .. " <RGB:0.7,0.7,0.7> Former Name: <RGB:1,1,1> " .. tostring(row.formerName) .. " <LINE> "
    end

    local statusColor = row.active and "0.35,1,0.45" or "1,0.6,0.25"
    if tostring(row.state or "") == "Collapsed" then
        statusColor = "1,0.25,0.2"
    end

    local factionName = tostring(row.currentFactionName or "")
    if factionName == "" then
        factionName = "None"
    end
    local factionID = tostring(row.currentFactionID or "")
    if factionID == "" then
        factionID = "None"
    end

    text = text .. " <RGB:0.7,0.7,0.7> Status: <RGB:" .. statusColor .. "> " .. tostring(row.status or "Inactive") .. " <LINE> "
    text = text .. " <RGB:0.7,0.7,0.7> State: <RGB:1,1,1> " .. tostring(row.state or "Unknown") .. " <LINE> "
    text = text .. " <RGB:0.7,0.7,0.7> Occupying Faction: <RGB:1,1,1> " .. factionName .. " <LINE> "
    text = text .. " <RGB:0.7,0.7,0.7> Occupying Faction ID: <RGB:1,1,1> " .. factionID .. " <LINE> "
    text = text .. " <RGB:0.7,0.7,0.7> Former Faction ID: <RGB:1,1,1> " .. tostring(row.formerFactionID or "None") .. " <LINE> "
    text = text .. " <RGB:0.7,0.7,0.7> Town: <RGB:1,1,1> " .. tostring(row.town or "Unknown") .. " <LINE> "
    text = text .. " <RGB:0.7,0.7,0.7> Coords: <RGB:1,1,1> " .. tostring(row.x) .. "," .. tostring(row.y) .. "," .. tostring(row.z) .. " <LINE> "
    text = text .. " <RGB:0.7,0.7,0.7> Release Reason: <RGB:1,1,1> " .. tostring(row.reason or "N/A") .. " <LINE> "
    if row.ageDays ~= nil then
        text = text .. " <RGB:0.7,0.7,0.7> Released: <RGB:1,1,1> " .. tostring(row.ageDays) .. " days ago <LINE> "
    end
    if ledger then
        text = text .. " <LINE> <RGB:0.6,0.8,1> LEDGER RULES <LINE> "
        text = text .. " <RGB:0.7,0.7,0.7> Avoid Days: <RGB:1,1,1> " .. tostring(ledger.avoidDays or "N/A") .. " <LINE> "
        text = text .. " <RGB:0.7,0.7,0.7> Reuse Chance: <RGB:1,1,1> " .. tostring(ledger.reuseChance or 0) .. "% <LINE> "
    end

    return text
end

function DT_FactionBaseLedgerWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Faction Base Ledger")
    self:setResizable(true)
    self.minimumWidth = MIN_W
    self.minimumHeight = MIN_H
    self:createChildren()
end

function DT_FactionBaseLedgerWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    if self._dtChildrenCreated then
        return
    end
    self._dtChildrenCreated = true

    self.list = ISScrollingListBox:new(0, 0, 100, 100)
    self.list:initialise()
    self.list:instantiate()
    self.list.itemheight = 72
    self.list.doDrawItem = DT_FactionBaseLedgerRenderers.DrawBaseItem
    self.list.backgroundColor = { r = 0, g = 0, b = 0, a = 0.82 }
    self.list.onMouseDown = function(target, x, y)
        local rowIndex = target:rowAt(x, y)
        if type(rowIndex) ~= "number" or rowIndex <= 0 then
            return false
        end
        local entry = target.items and target.items[rowIndex] or nil
        if not entry or not entry.item then
            return false
        end
        target.selected = rowIndex
        if DT_FactionBaseLedgerWindow.instance then
            DT_FactionBaseLedgerWindow.instance:onBaseSelected(entry.item)
        end
        return true
    end
    self:addChild(self.list)

    self.details = ISRichTextPanel:new(0, 0, 100, 100)
    self.details:initialise()
    self.details.backgroundColor = { r = 0, g = 0, b = 0, a = 0.82 }
    self.details:addScrollBars()
    self.details:setText(" <RGB:0.7,0.7,0.7> Select a base location.")
    self:addChild(self.details)

    self.btnRefresh = ISButton:new(0, 0, 100, 25, "REFRESH", self, DT_FactionBaseLedgerWindow.onRefreshClick)
    self.btnRefresh:initialise()
    self.btnRefresh.backgroundColor = { r = 0.2, g = 0.45, b = 0.22, a = 1 }
    self:addChild(self.btnRefresh)

    self.btnTeleport = ISButton:new(0, 0, 120, 25, "TELEPORT", self, DT_FactionBaseLedgerWindow.onTeleportClick)
    self.btnTeleport:initialise()
    self.btnTeleport.backgroundColor = { r = 0.22, g = 0.28, b = 0.62, a = 1 }
    self.btnTeleport.enable = false
    self:addChild(self.btnTeleport)

    self.btnDump = ISButton:new(0, 0, 120, 25, "DUMP LOG", self, DT_FactionBaseLedgerWindow.onDumpClick)
    self.btnDump:initialise()
    self.btnDump.backgroundColor = { r = 0.45, g = 0.32, b = 0.12, a = 1 }
    self:addChild(self.btnDump)

    self.btnClose = ISButton:new(0, 0, 100, 25, "CLOSE", self, DT_FactionBaseLedgerWindow.close)
    self.btnClose:initialise()
    self:addChild(self.btnClose)

    self:layoutChildren()
    self:refreshList()
end

function DT_FactionBaseLedgerWindow:layoutChildren()
    local titleH = self:titleBarHeight()
    local top = titleH + PAD
    local footerY = self.height - PAD - FOOTER_H
    local contentH = math.max(120, footerY - top - GAP)
    local innerW = math.max(100, self.width - (PAD * 2))
    local stacked = innerW < 620
    local listW = stacked and innerW or math.max(230, math.min(360, math.floor(innerW * 0.38)))
    local detailsW = stacked and innerW or math.max(230, innerW - GAP - listW)
    local detailsX = stacked and PAD or (PAD + listW + GAP)
    local detailsY = stacked and (top + math.floor(contentH * 0.44) + GAP) or top
    local listH = stacked and math.max(90, math.floor(contentH * 0.44)) or contentH
    local detailsH = stacked and math.max(90, footerY - detailsY - GAP) or contentH

    setBounds(self.list, PAD, top, listW, listH)
    setBounds(self.details, detailsX, detailsY, detailsW, detailsH)

    refreshRichText(self.details)

    local buttonY = footerY + math.floor((FOOTER_H - 25) / 2)
    local closeW = math.min(110, math.max(78, math.floor(innerW * 0.16)))
    local actionW = math.max(92, math.min(120, math.floor((innerW - closeW - (GAP * 4)) / 3)))
    self.btnRefresh:setX(PAD)
    self.btnRefresh:setY(buttonY)
    self.btnRefresh:setWidth(actionW)
    self.btnRefresh:setHeight(25)

    self.btnTeleport:setX(PAD + actionW + GAP)
    self.btnTeleport:setY(buttonY)
    self.btnTeleport:setWidth(actionW)
    self.btnTeleport:setHeight(25)

    self.btnDump:setX(PAD + ((actionW + GAP) * 2))
    self.btnDump:setY(buttonY)
    self.btnDump:setWidth(actionW)
    self.btnDump:setHeight(25)

    self.btnClose:setX(self.width - PAD - closeW)
    self.btnClose:setY(buttonY)
    self.btnClose:setWidth(closeW)
    self.btnClose:setHeight(25)
end

function DT_FactionBaseLedgerWindow:onResize()
    ISCollapsableWindow.onResize(self)
    self:layoutChildren()
end

function DT_FactionBaseLedgerWindow:setRows(rows, ledger)
    self.rows = rows or {}
    self.ledger = ledger or {}
    self.list:clear()
    for _, row in ipairs(self.rows) do
        self.list:addItem(tostring(row.currentName or row.id or "Base"), row)
    end
    self.selectedBase = nil
    self.btnTeleport.enable = false
    self.details:setText(" <RGB:0.7,0.7,0.7> Select a base location.")
    refreshRichText(self.details)
end

function DT_FactionBaseLedgerWindow:refreshList()
    DT_FactionBaseLedgerData.Refresh(function(rows, ledger)
        if DT_FactionBaseLedgerWindow.instance and DT_FactionBaseLedgerWindow.instance:getIsVisible() then
            DT_FactionBaseLedgerWindow.instance:setRows(rows, ledger)
        end
    end)
end

function DT_FactionBaseLedgerWindow:onBaseSelected(row)
    self.selectedBase = row
    self.btnTeleport.enable = type(row) == "table" and tonumber(row.x) ~= nil and tonumber(row.y) ~= nil
    self.details:setText(formatRowDetails(row, self.ledger))
    refreshRichText(self.details)
end

function DT_FactionBaseLedgerWindow:onRefreshClick()
    self:refreshList()
end

function DT_FactionBaseLedgerWindow:onTeleportClick()
    if DT_FactionBaseLedgerActions.TeleportToBase(self.selectedBase) and getPlayer() then
        getPlayer():Say("Teleport requested: " .. tostring(self.selectedBase.currentName or "Faction Base"))
    end
end

function DT_FactionBaseLedgerWindow:onDumpClick()
    DT_FactionBaseLedgerActions.DumpLedger()
    if getPlayer() then
        getPlayer():Say("Faction base ledger dumped to logs")
    end
end

function DT_FactionBaseLedgerWindow.Open()
    if DT_FactionBaseLedgerWindow.instance then
        DT_FactionBaseLedgerWindow.instance:setVisible(true)
        DT_FactionBaseLedgerWindow.instance:addToUIManager()
        DT_FactionBaseLedgerWindow.instance:bringToTop()
        DT_FactionBaseLedgerWindow.instance:layoutChildren()
        DT_FactionBaseLedgerWindow.instance:refreshList()
        return
    end

    local core = getCore()
    local screenW = core:getScreenWidth()
    local screenH = core:getScreenHeight()
    local width = math.min(math.max(MIN_W, math.floor(screenW * 0.82)), screenW - 40)
    local height = math.min(math.max(MIN_H, math.floor(screenH * 0.72)), screenH - 60)
    local x = math.floor((core:getScreenWidth() - width) / 2)
    local y = math.floor((core:getScreenHeight() - height) / 2)
    local window = DT_FactionBaseLedgerWindow:new(x, y, width, height)
    window:initialise()
    window:addToUIManager()
    DT_FactionBaseLedgerWindow.instance = window
    window:refreshList()
end

function DT_FactionBaseLedgerWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0.02, g = 0.02, b = 0.02, a = 0.96 }
    o.borderColor = { r = 1, g = 1, b = 1, a = 1 }
    o.moveWithMouse = true
    o.resizable = true
    o.rows = {}
    o.ledger = {}
    o.selectedBase = nil
    return o
end

function DT_FactionBaseLedgerWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DT_FactionBaseLedgerWindow.instance = nil
end

return DT_FactionBaseLedgerWindow
