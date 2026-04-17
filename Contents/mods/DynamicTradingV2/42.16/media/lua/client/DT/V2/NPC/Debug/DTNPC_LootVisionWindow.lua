-- ==============================================================================
-- DTNPC_LootVisionWindow.lua
-- Debug-only modal that shows nearby loot sources/items around the player.
-- ==============================================================================

if not ((isDebugEnabled and isDebugEnabled()) or rawget(_G, "DT_PRIVATE_DEBUG_BYPASS") == true) then return end

require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"

DTNPC_LootVisionWindow = ISCollapsableWindow:derive("DTNPC_LootVisionWindow")

function DTNPC_LootVisionWindow:initialise()
    ISCollapsableWindow.initialise(self)
end

function DTNPC_LootVisionWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local pad = 10
    local buttonY = 24
    local buttonH = 22
    local buttonW = 80

    self.refreshButton = ISButton:new(pad, buttonY, buttonW, buttonH, "Refresh", self, self.onRefresh)
    self.refreshButton:initialise()
    self.refreshButton:instantiate()
    self:addChild(self.refreshButton)

    self.radiusMinusButton = ISButton:new(pad + buttonW + 6, buttonY, 28, buttonH, "-", self, self.onRadiusMinus)
    self.radiusMinusButton:initialise()
    self.radiusMinusButton:instantiate()
    self:addChild(self.radiusMinusButton)

    self.radiusPlusButton = ISButton:new(pad + buttonW + 40, buttonY, 28, buttonH, "+", self, self.onRadiusPlus)
    self.radiusPlusButton:initialise()
    self.radiusPlusButton:instantiate()
    self:addChild(self.radiusPlusButton)

    self.listbox = ISScrollingListBox:new(pad, buttonY + buttonH + 8, self.width - (pad * 2), self.height - (buttonY + buttonH + 18))
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.drawBorder = true
    self:addChild(self.listbox)

    self:refreshData()
end

function DTNPC_LootVisionWindow:onRefresh()
    self:refreshData()
end

function DTNPC_LootVisionWindow:onRadiusMinus()
    self.scanRadius = math.max(1, tonumber(self.scanRadius or 6) - 1)
    self:refreshData()
end

function DTNPC_LootVisionWindow:onRadiusPlus()
    self.scanRadius = math.min(25, tonumber(self.scanRadius or 6) + 1)
    self:refreshData()
end

function DTNPC_LootVisionWindow:addColoredLine(text, color, payload)
    self.listbox:addItem(tostring(text or ""), payload or false)
    local entry = self.listbox.items[#self.listbox.items]
    if entry then
        entry.color = color
    end
end

function DTNPC_LootVisionWindow:getLootStatusText(item)
    if not item then
        return "unknown"
    end

    local reason = tostring(item.lootReason or "unknown")
    if item.lootable then
        if reason == "lootable" and tonumber(item.fitQty or 0) > 0 and tonumber(item.requestedQty or 0) > tonumber(item.fitQty or 0) then
            return "lootable-partial " .. tostring(item.fitQty) .. "/" .. tostring(item.requestedQty)
        end
        return reason
    end

    return reason
end

function DTNPC_LootVisionWindow:getLootStatusColor(item)
    if not item then
        return { r = 0.8, g = 0.8, b = 0.8, a = 1 }
    end

    local reason = tostring(item.lootReason or "")
    if item.lootable then
        return { r = 0.55, g = 1, b = 0.55, a = 1 }
    end
    if reason == "no-capacity" then
        return { r = 1, g = 0.45, b = 0.45, a = 1 }
    end
    return { r = 0.82, g = 0.82, b = 0.82, a = 1 }
end

function DTNPC_LootVisionWindow:refreshData()
    self.listbox:clear()

    local player = getSpecificPlayer(self.playerNum or 0)
    if not player then
        self:addColoredLine("No local player found.", { r = 1, g = 0.4, b = 0.4, a = 1 })
        return
    end

    if not DTNPCLootDebug or not DTNPCLootDebug.ScanNearbySources then
        self:addColoredLine("Loot debug scanner unavailable.", { r = 1, g = 0.4, b = 0.4, a = 1 })
        return
    end

    local scan = DTNPCLootDebug.ScanNearbySources(player, self.npcData, self.scanRadius)
    local npcLabel = self.npcData and tostring(self.npcData.name or self.npcData.uuid or "Unknown") or "World View"
    self.title = "Loot Vision Inspector - " .. npcLabel .. " [r=" .. tostring(scan.radius or self.scanRadius) .. "]"

    self:addColoredLine(
        "Center: " .. tostring(scan.center and scan.center.x or 0) .. ", " .. tostring(scan.center and scan.center.y or 0) .. ", " .. tostring(scan.center and scan.center.z or 0)
            .. " | Sources: " .. tostring(scan.totalSources or 0)
            .. " | Items: " .. tostring(scan.totalItems or 0)
            .. " | Capacity Check: " .. tostring(scan.workerID and "on" or "off")
            .. " | Worker: " .. tostring(scan.workerName or scan.workerID or "n/a"),
        { r = 0.7, g = 0.9, b = 1, a = 1 }
    )

    if not scan.sources or #scan.sources <= 0 then
        self:addColoredLine("No loot sources found in range.", { r = 0.9, g = 0.9, b = 0.7, a = 1 })
        return
    end

    for _, source in ipairs(scan.sources) do
        local sourceText = string.format(
            "[%s] %s @ %d,%d,%d [%.1f] items=%d",
            tostring(source.kind or "?"),
            tostring(source.label or "Source"),
            tonumber(source.x) or 0,
            tonumber(source.y) or 0,
            tonumber(source.z) or 0,
            tonumber(source.distance) or 0,
            source.items and #source.items or 0
        )
        self:addColoredLine(sourceText, { r = 1, g = 0.85, b = 0.35, a = 1 }, source)

        for _, item in ipairs(source.items or {}) do
            local qtyText = tonumber(item.quantity or 1) > 1 and (" x" .. tostring(item.quantity)) or ""
            local statusText = self:getLootStatusText(item)
            local itemText = "  - " .. tostring(item.displayName or item.fullType or "Unknown") .. qtyText .. " [" .. tostring(statusText) .. "]"
            if item.fullType and item.fullType ~= "" then
                itemText = itemText .. " [" .. tostring(item.fullType) .. "]"
            end
            self:addColoredLine(itemText, self:getLootStatusColor(item), item)
        end
    end
end

function DTNPC_LootVisionWindow:update()
    ISCollapsableWindow.update(self)
    if self.listbox then
        self.listbox:setWidth(self.width - 20)
        self.listbox:setHeight(self.height - 64)
    end
end

function DTNPC_LootVisionWindow:new(x, y, width, height, playerNum, npcData)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.playerNum = tonumber(playerNum) or 0
    o.npcData = type(npcData) == "table" and npcData or nil
    o.scanRadius = 6
    o.resizable = true
    o.pin = true
    o.title = "Loot Vision Inspector"
    return o
end

function DTNPC_LootVisionWindow.Open(playerNum, npcData)
    if DTNPC_LootVisionWindow.instance and DTNPC_LootVisionWindow.instance:getIsVisible() then
        DTNPC_LootVisionWindow.instance.npcData = type(npcData) == "table" and npcData or nil
        DTNPC_LootVisionWindow.instance:bringToTop()
        DTNPC_LootVisionWindow.instance:refreshData()
        return DTNPC_LootVisionWindow.instance
    end

    local window = DTNPC_LootVisionWindow:new(260, 140, 620, 520, playerNum or 0, npcData)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    DTNPC_LootVisionWindow.instance = window
    return window
end
