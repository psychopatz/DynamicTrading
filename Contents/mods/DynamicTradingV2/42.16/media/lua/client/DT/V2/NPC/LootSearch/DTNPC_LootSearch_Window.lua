-- ==============================================================================
-- DTNPC_LootSearch_Window.lua
-- Manual search-and-collect UI for companion loot discovery.
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISModalDialog"
require "ISUI/ISRichTextPanel"
require "DT/V2/NPC/LootSearch/DTNPC_LootSearch_Client"
pcall(require, "DT/V2/NPC/UI/DTNPC_CommandEmotes")

DTNPCLootSearchWindow = ISCollapsableWindow:derive("DTNPCLootSearchWindow")

local LootSearchList = ISScrollingListBox:derive("LootSearchList")

local function T(key, params, fallback)
    return DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get
        and DynamicTrading.Text.Get(key, params, fallback)
        or fallback
        or tostring(key or "")
end

local function formatWeightValue(value)
    local numeric = tonumber(value)
    if not numeric then
        return "0.0"
    end
    return string.format("%.1f", math.max(0, numeric))
end

local function getWorkerCarryState(npcData)
    if not npcData then
        return nil
    end

    if not DTNPCLootSearch or not DTNPCLootSearch.GetWorkerCarryState then
        pcall(require, "DT/V2/NPC/LootSearch/LootSearchShared/DTNPC_LootSearchShared")
    end
    if DTNPCLootSearch and DTNPCLootSearch.GetWorkerCarryState then
        return DTNPCLootSearch.GetWorkerCarryState(npcData)
    end
    return nil
end

local function buildLocalScanCache(playerObj, npcData)
    if not playerObj or type(npcData) ~= "table" then
        return nil
    end

    if not DTNPCLootDebug or not DTNPCLootDebug.ScanNearbySources then
        pcall(require, "DT/V2/NPC/Behaviors/BehaviorLootNearby/Behavior_LootNearby")
    end
    if not DTNPCLootDebug or not DTNPCLootDebug.ScanNearbySources then
        return nil
    end

    local scan = DTNPCLootDebug.ScanNearbySources(
        playerObj,
        npcData,
        npcData.dcLootRadius or (npcData.dcLootConfig and npcData.dcLootConfig.radius) or nil
    )

    return {
        uuid = npcData.uuid,
        npcName = npcData.name,
        state = npcData.state,
        status = npcData.dcLootStatus,
        currentSourceKey = nil,
        sources = type(scan and scan.sources) == "table" and scan.sources or {},
        workerCarry = getWorkerCarryState(npcData),
        autoOpen = false,
        dynamicColoniesExclusive = true,
        localFallback = true,
    }
end

local function fitTextToWidth(font, text, maxWidth)
    local value = tostring(text or "")
    if value == "" or maxWidth <= 0 then
        return ""
    end

    local textManager = getTextManager()
    if textManager:MeasureStringX(font, value) <= maxWidth then
        return value
    end

    local ellipsis = "..."
    local ellipsisWidth = textManager:MeasureStringX(font, ellipsis)
    if ellipsisWidth >= maxWidth then
        return ellipsis
    end

    local trimmedLength = #value
    while trimmedLength > 0 do
        local candidate = string.sub(value, 1, trimmedLength) .. ellipsis
        if textManager:MeasureStringX(font, candidate) <= maxWidth then
            return candidate
        end
        trimmedLength = trimmedLength - 1
    end

    return ellipsis
end

function LootSearchList:new(x, y, width, height, mode)
    local o = ISScrollingListBox:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.mode = tostring(mode or "items")
    o.itemheight = o.mode == "sources" and 42 or 34
    o.font = UIFont.Small
    o.backgroundColor = { r = 0.05, g = 0.05, b = 0.05, a = 0.92 }
    o.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
    return o
end

function LootSearchList:doDrawItem(y, item, alt)
    local entry = item and item.item or nil
    if not entry then
        return y + self.itemheight
    end

    local width = self:getWidth()
    local selected = self.selected == item.index
    if selected then
        self:drawRect(0, y, width, self.itemheight, 0.25, 0.18, 0.38, 0.62)
    elseif alt then
        self:drawRect(0, y, width, self.itemheight, 0.08, 1, 1, 1)
    end
    self:drawRectBorder(0, y, width, self.itemheight, 0.08, 1, 1, 1)

    local label = tostring(item.text or "")
    local color = item.color or { r = 0.9, g = 0.9, b = 0.9, a = 1 }

    if self.mode == "sources" then
        local title = fitTextToWidth(UIFont.Small, tostring(entry.label or label), width - 80)
        local meta = string.format("%s | %d items | %d,%d,%d", tostring(entry.kind or "?"), #(entry.items or {}), tonumber(entry.x) or 0, tonumber(entry.y) or 0, tonumber(entry.z) or 0)
        meta = fitTextToWidth(UIFont.Small, meta, width - 12)
        self:drawText(title, 8, y + 5, color.r, color.g, color.b, color.a or 1, UIFont.Small)
        self:drawText(meta, 8, y + 22, 0.62, 0.78, 0.95, 1, UIFont.Small)
    else
        local text = fitTextToWidth(UIFont.Small, label, width - 12)
        self:drawText(text, 8, y + 8, color.r, color.g, color.b, color.a or 1, UIFont.Small)
    end

    return y + self.itemheight
end

function DTNPCLootSearchWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self.backgroundColor = { r = 0, g = 0, b = 0, a = 0.38 }
    self.borderColor = { r = 1, g = 1, b = 1, a = 0.16 }
end

function DTNPCLootSearchWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local pad = 10
    local headerY = 30
    local subHeaderY = 48
    local topY = 72
    local buttonH = 22
    local buttonW = 100
    local gap = 8
    local contentY = topY + buttonH + 12
    local bottomH = 146
    local contentH = self.height - contentY - bottomH - pad
    local controlW = 130
    local listW = math.floor((self.width - pad * 2 - gap - controlW) / 2)
    local controlX = pad + listW + gap
    local itemX = controlX + controlW + gap

    self.refreshButton = ISButton:new(pad, topY, buttonW, buttonH, T("DTNPC_UI_Refresh", nil, "Refresh"), self, self.onRefresh)
    self.refreshButton:initialise()
    self.refreshButton:instantiate()
    self:addChild(self.refreshButton)

    self.collectButton = ISButton:new(pad + buttonW + gap, topY, buttonW + 20, buttonH, T("DTNPC_UI_Collect", nil, "Collect"), self, self.onCollect)
    self.collectButton:initialise()
    self.collectButton:instantiate()
    self:addChild(self.collectButton)

    self.blacklistButton = ISButton:new(pad + (buttonW * 2) + 28, topY, 130, buttonH, T("DTNPC_UI_ToggleBlacklist", nil, "Toggle Blacklist"), self, self.onToggleBlacklist)
    self.blacklistButton:initialise()
    self.blacklistButton:instantiate()
    self:addChild(self.blacklistButton)

    self.modeButton = ISButton:new(pad + (buttonW * 2) + 166, topY, 130, buttonH, T("DTNPC_UI_FollowMe", nil, "Follow Me"), self, self.onToggleMode)
    self.modeButton:initialise()
    self.modeButton:instantiate()
    self:addChild(self.modeButton)

    self.sourceList = LootSearchList:new(pad, contentY, listW, contentH, "sources")
    self.sourceList:initialise()
    self.sourceList:instantiate()
    self.sourceList.onmousedown = function(list, x, y)
        self:onSourceSelected()
    end
    self.sourceList.drawBorder = true
    self:addChild(self.sourceList)

    self.itemList = LootSearchList:new(itemX, contentY, listW, contentH, "items")
    self.itemList:initialise()
    self.itemList:instantiate()
    self.itemList.onmousedown = function(list, x, y)
        self:onItemClicked()
    end
    self.itemList.drawBorder = true
    self:addChild(self.itemList)

    self.collectButton:setX(controlX)
    self.collectButton:setWidth(controlW)
    self.blacklistButton:setX(controlX)
    self.blacklistButton:setY(contentY + 64)
    self.blacklistButton:setWidth(controlW)
    self.modeButton:setX(controlX)
    self.modeButton:setY(contentY + 128)
    self.modeButton:setWidth(controlW)

    self.detailText = ISRichTextPanel:new(pad, contentY + contentH + gap, self.width - (pad * 2), bottomH - gap)
    self.detailText:initialise()
    self.detailText.backgroundColor = { r = 0.04, g = 0.04, b = 0.04, a = 0.92 }
    self.detailText.borderColor = { r = 1, g = 1, b = 1, a = 0.18 }
    self.detailText:addScrollBars()
    self:addChild(self.detailText)

    self.selectedItemsBySource = self.selectedItemsBySource or {}
    self.layout = {
        pad = pad,
        headerY = headerY,
        subHeaderY = subHeaderY,
        topY = topY,
        contentY = contentY,
        contentH = contentH,
        bottomY = contentY + contentH + gap,
        bottomH = bottomH - gap,
        sourceX = pad,
        sourceW = listW,
        controlX = controlX,
        controlW = controlW,
        itemX = itemX,
        itemW = listW,
    }
    self:refreshData()
end

function DTNPCLootSearchWindow:addLine(list, text, color, item)
    list:addItem(tostring(text or ""), item or false)
    local entry = list.items[#list.items]
    if entry then
        entry.color = color
    end
end

function DTNPCLootSearchWindow:getPlayerObj()
    return getSpecificPlayer(self.playerNum or 0)
end

function DTNPCLootSearchWindow:getSelectedSource()
    local selected = self.sourceList.items[self.sourceList.selected]
    return selected and selected.item or nil
end

function DTNPCLootSearchWindow:getSelectedItem()
    local selected = self.itemList.items[self.itemList.selected]
    return selected and selected.item or nil
end

function DTNPCLootSearchWindow:getSourceSelection(sourceKey)
    local normalized = tostring(sourceKey or "")
    self.selectedItemsBySource = self.selectedItemsBySource or {}
    self.selectedItemsBySource[normalized] = type(self.selectedItemsBySource[normalized]) == "table"
        and self.selectedItemsBySource[normalized]
        or {}
    return self.selectedItemsBySource[normalized]
end

function DTNPCLootSearchWindow:isItemSelected(sourceKey, itemKey)
    return self:getSourceSelection(sourceKey)[tostring(itemKey or "")] == true
end

function DTNPCLootSearchWindow:setItemSelected(sourceKey, itemKey, selected)
    self:getSourceSelection(sourceKey)[tostring(itemKey or "")] = selected == true or nil
end

function DTNPCLootSearchWindow:onSourceSelected()
    self:populateItems(self:getSelectedSource())
end

function DTNPCLootSearchWindow:onItemClicked()
    local source = self:getSelectedSource()
    local item = self:getSelectedItem()
    if not source or not item then
        return
    end

    self:setItemSelected(source.key, item.key, not self:isItemSelected(source.key, item.key))
    self:populateItems(source)
    self:populateSources(self:getCache())
end

function DTNPCLootSearchWindow:populateSources(cache)
    self.sourceList:clear()
    local selectedIndex = nil
    for _, source in ipairs(cache and cache.sources or {}) do
        local itemCount = #(source.items or {})
        local selectedCount = 0
        for _, item in ipairs(source.items or {}) do
            if self:isItemSelected(source.key, item.key) then
                selectedCount = selectedCount + 1
            end
        end
        local label = string.format("[%s] %s @ %d,%d,%d items=%d selected=%d", tostring(source.kind or "?"), tostring(source.label or "Source"), tonumber(source.x) or 0, tonumber(source.y) or 0, tonumber(source.z) or 0, itemCount, selectedCount)
        self:addLine(self.sourceList, label, { r = 1, g = 0.85, b = 0.4, a = 1 }, source)
        if cache and cache.currentSourceKey and source.key == cache.currentSourceKey then
            selectedIndex = #self.sourceList.items
        end
    end
    if self.sourceList.items[1] then
        local maxIndex = #self.sourceList.items
        local currentIndex = tonumber(selectedIndex or self.sourceList.selected) or 1
        self.sourceList.selected = math.max(1, math.min(maxIndex, currentIndex))
    else
        self.sourceList.selected = 0
    end
end

function DTNPCLootSearchWindow:populateItems(source)
    self.itemList:clear()
    local playerObj = self:getPlayerObj()
    for _, item in ipairs(source and source.items or {}) do
        local isBlacklisted = DTNPCLootSearchClient.IsBlacklisted(playerObj, item.fullType)
        local marker = self:isItemSelected(source and source.key or nil, item.key) and "[x] " or "[ ] "
        local label = marker .. tostring(item.displayName or item.fullType or "Unknown")
        if tonumber(item.quantity or 1) > 1 then
            label = label .. " x" .. tostring(item.quantity)
        end
        if item.fullType and item.fullType ~= "" then
            label = label .. " [" .. tostring(item.fullType) .. "]"
        end
        if isBlacklisted then
            label = label .. " [" .. T("DTNPC_UI_Blacklisted", nil, "BLACKLISTED") .. "]"
        end
        self:addLine(
            self.itemList,
            label,
            isBlacklisted and { r = 0.95, g = 0.45, b = 0.45, a = 1 } or { r = 0.9, g = 0.9, b = 0.9, a = 1 },
            item
        )
    end
    if self.itemList.items[1] then
        local maxIndex = #self.itemList.items
        local currentIndex = tonumber(self.itemList.selected) or 1
        self.itemList.selected = math.max(1, math.min(maxIndex, currentIndex))
    else
        self.itemList.selected = 0
    end
end

function DTNPCLootSearchWindow:populateStatus(cache)
    if not self.detailText then
        return
    end

    local selectedSource = self:getSelectedSource()
    local selectedItem = self:getSelectedItem()
    local workerCarry = cache and cache.workerCarry or nil
    local detail = table.concat({
        " <RGB:0.95,0.95,0.95> " .. T("DTNPC_UI_FieldNotes", nil, "Field Notes") .. " <LINE> ",
        " <RGB:0.70,0.90,1.00> State: " .. tostring(cache and cache.state or "?")
            .. " | Loot Status: " .. tostring(cache and cache.status or "?")
            .. " | Sources: " .. tostring(cache and #(cache.sources or {}) or 0) .. " <LINE> ",
        workerCarry
            and (" <RGB:0.88,0.88,0.72> Carry: " .. formatWeightValue(workerCarry.usedWeight)
                .. " / " .. formatWeightValue(workerCarry.maxWeight)
                .. " | Free: " .. formatWeightValue(workerCarry.remainingWeight) .. " <LINE> ")
            or " <RGB:0.72,0.72,0.72> Carry: unknown <LINE> ",
        " <RGB:0.82,0.82,0.82> Source: " .. tostring(selectedSource and selectedSource.label or "None selected") .. " <LINE> ",
        selectedItem
            and (" <RGB:0.72,0.84,0.98> Item: " .. tostring(selectedItem.displayName or selectedItem.fullType or "Unknown")
                .. " x" .. tostring(selectedItem.quantity or 1) .. " <LINE> ")
            or " <RGB:0.72,0.72,0.72> Item: Select an item on the right to inspect it here. <LINE> ",
        " <RGB:0.72,0.72,0.72> Left side shows all nearby loot sources around you. Right side shows the items currently visible in that source. <LINE> ",
        " <RGB:0.72,0.72,0.72> Click items on the right to toggle selection, then use Collect to queue pickup. <LINE> ",
        " <RGB:0.72,0.72,0.72> Toggle Blacklist stores junk exclusions in your player modData. " .. tostring(cache and cache.localFallback and "Using local nearby scan fallback." or "Using synced loot scan.") .. " <LINE> ",
    }, "")
    self.detailText.text = detail
    self.detailText:paginate()
    self.detailText:setVisible(true)
end

function DTNPCLootSearchWindow:updateModeButton(cache)
    local isSearching = tostring(cache and cache.state or self.npcData and self.npcData.state or "") == "LootNearby"
    if self.modeButton then
        self.modeButton:setTitle(isSearching
            and T("DTNPC_UI_FollowMe", nil, "Follow Me")
            or T("DTNPC_UI_StartSearch", nil, "Start Search"))
    end
end

function DTNPCLootSearchWindow:getCache()
    local cache = DTNPCLootSearchClient.GetCache(self.npcData and self.npcData.uuid or nil)
        or DTNPCLootSearchClient.FindCache(self.npcData)
    if cache then
        return cache
    end

    local localFallback = buildLocalScanCache(self:getPlayerObj(), self.npcData)
    if localFallback then
        return localFallback
    end

    return {
        uuid = self.npcData and self.npcData.uuid or nil,
        npcName = self.npcData and self.npcData.name or T("DTNPC_UI_CompanionOrdersForName", { name = "Companion" }, "Companion"),
        state = self.npcData and self.npcData.state or nil,
        status = self.npcData and self.npcData.dcLootStatus or nil,
        workerCarry = getWorkerCarryState(self.npcData),
        sources = {},
    }
end

function DTNPCLootSearchWindow:refreshFromCache(cache)
    if not cache then
        return
    end
    if self.npcData and cache.uuid and self.npcData.uuid and cache.uuid ~= self.npcData.uuid then
        return
    end
    if self.npcData then
        self.npcData.state = cache.state or self.npcData.state
        self.npcData.dcLootStatus = cache.status or self.npcData.dcLootStatus
    end
    self.title = T("DTNPC_UI_LootSearchTitleNpc", {
        name = tostring(cache.npcName or self.npcData and self.npcData.name or "Companion"),
    }, "Loot Search - {name}")
    self:populateSources(cache)
    self:populateItems(self:getSelectedSource())
    self:populateStatus(cache)
    self:updateModeButton(cache)
end

function DTNPCLootSearchWindow:refreshData()
    self:refreshFromCache(self:getCache())
end

function DTNPCLootSearchWindow:promptFullInventoryReturnHome(cache)
    if self.fullInventoryPromptOpen then
        return
    end

    local playerObj = self:getPlayerObj()
    if not playerObj or not self.npcData then
        return
    end

    local carryState = type(cache and cache.collectEvent and cache.collectEvent.carryState) == "table"
        and cache.collectEvent.carryState
        or (cache and cache.workerCarry)
        or nil
    local npcName = tostring((cache and cache.npcName) or (self.npcData and self.npcData.name) or "Companion")
    local usedWeight = formatWeightValue(carryState and carryState.usedWeight or 0)
    local maxWeight = formatWeightValue(carryState and carryState.maxWeight or 0)
    local text = npcName .. " is carrying " .. usedWeight .. " / " .. maxWeight .. ".\n\n"
        .. "Their inventory is full. Send them home now to deposit their loot into the warehouse using the standard return-home protocol?"

    self.fullInventoryPromptOpen = true
    local function onConfirm(_, button)
        self.fullInventoryPromptOpen = false
        if button and button.internal == "YES" then
            DTNPCLootSearchClient.RequestReturnHomeForDeposit(playerObj, self.npcData)
            playerObj:Say(T("DTNPC_Dialogue_LootReturnHomeUnload", nil, "Head home and unload at the warehouse."))
        end
    end

    local modal = ISModalDialog:new(0, 0, 420, 180, text, true, nil, onConfirm, nil)
    modal:initialise()
    modal:addToUIManager()
end

function DTNPCLootSearchWindow:onRefresh()
    local playerObj = self:getPlayerObj()
    if playerObj and self.npcData then
        DTNPCLootSearchClient.RequestSync(playerObj, self.npcData)
    end
    self:refreshData()
end

function DTNPCLootSearchWindow:onCollect()
    local playerObj = self:getPlayerObj()
    local source = self:getSelectedSource()
    if not playerObj or not source or not self.npcData then
        return
    end

    local selectedKeys = {}
    for _, item in ipairs(source.items or {}) do
        if self:isItemSelected(source.key, item.key) and not DTNPCLootSearchClient.IsBlacklisted(playerObj, item.fullType) then
            selectedKeys[#selectedKeys + 1] = item.key
        end
    end

    if #selectedKeys <= 0 then
        local item = self:getSelectedItem()
        if item and not DTNPCLootSearchClient.IsBlacklisted(playerObj, item.fullType) then
            selectedKeys[#selectedKeys + 1] = item.key
        end
    end

    if #selectedKeys <= 0 then
        playerObj:Say(T("DTNPC_UI_SelectAtLeastOneNonBlacklisted", nil, "Select at least one non-blacklisted item."))
        return
    end

    DTNPCLootSearchClient.RequestCollect(playerObj, self.npcData, source.key, selectedKeys)
end

function DTNPCLootSearchWindow:onToggleBlacklist()
    local playerObj = self:getPlayerObj()
    local item = self:getSelectedItem()
    if not playerObj or not item or not item.fullType then
        return
    end
    local enabled = DTNPCLootSearchClient.ToggleBlacklist(playerObj, item.fullType)
    playerObj:Say(enabled
        and T("DTNPC_UI_BlacklistedItem", { name = tostring(item.displayName or item.fullType) }, "Blacklisted {name}")
        or T("DTNPC_UI_RemovedBlacklist", { name = tostring(item.displayName or item.fullType) }, "Removed blacklist for {name}"))
    self:populateItems(self:getSelectedSource())
    self:populateSources(self:getCache())
end

function DTNPCLootSearchWindow:onToggleMode()
    local playerObj = self:getPlayerObj()
    if not playerObj or not self.npcData then
        return
    end

    if DTNPCLootSearchClient.RequestModeToggle(playerObj, self.npcData) then
        if tostring(self.npcData.state or "") == "LootNearby" then
            self.npcData.state = "Follow"
            if DTNPC_CommandEmotes and DTNPC_CommandEmotes.Play then
                DTNPC_CommandEmotes.Play(playerObj, "Follow")
            end
            playerObj:Say(T("DTNPC_UI_ReturningToFollowMode", nil, "Returning to follow mode."))
        else
            self.npcData.state = "LootNearby"
            if DTNPC_CommandEmotes and DTNPC_CommandEmotes.Play then
                DTNPC_CommandEmotes.Play(playerObj, "LootNearby")
            end
            playerObj:Say(T("DTNPC_UI_StartingLootSearch", nil, "Starting loot search."))
        end
        self:updateModeButton(self:getCache())
    end
end

function DTNPCLootSearchWindow:update()
    ISCollapsableWindow.update(self)
end

function DTNPCLootSearchWindow:render()
    ISCollapsableWindow.render(self)

    local layout = self.layout or {}
    local headerY = layout.headerY or 30
    local subHeaderY = layout.subHeaderY or (headerY + 18)
    self:drawRectBorder(layout.sourceX or 10, layout.contentY or 0, layout.sourceW or 0, layout.contentH or 0, 0.25, 1, 1, 1)
    self:drawRectBorder(layout.itemX or 10, layout.contentY or 0, layout.itemW or 0, layout.contentH or 0, 0.25, 1, 1, 1)
    self:drawRectBorder(layout.pad or 10, layout.bottomY or 0, self.width - ((layout.pad or 10) * 2), layout.bottomH or 0, 0.22, 1, 1, 1)

    self:drawText(T("DTNPC_UI_NearbyLootSources", nil, "Nearby Loot Sources"), layout.sourceX or 10, headerY, 0.94, 0.96, 1, 1, UIFont.Medium)
    self:drawText(
        T("DTNPC_UI_SourceCount", { count = tostring(#(self:getCache().sources or {})) }, "{count} sources in current search session"),
        layout.sourceX or 10,
        subHeaderY,
        0.7,
        0.7,
        0.7,
        1,
        UIFont.Small
    )

    self:drawText(T("DTNPC_UI_SelectableLoot", nil, "Selectable Loot"), layout.itemX or 10, headerY, 0.94, 0.96, 1, 1, UIFont.Medium)
    self:drawText(
        T("DTNPC_UI_ClickRowsToMarkItems", nil, "Click rows to mark items for collection"),
        layout.itemX or 10,
        subHeaderY,
        0.7,
        0.7,
        0.7,
        1,
        UIFont.Small
    )

    self:drawText(T("DTNPC_UI_Actions", nil, "Actions"), (layout.controlX or 0) + 28, headerY + 6, 0.9, 0.9, 0.9, 1, UIFont.Small)
    self:drawText(T("DTNPC_UI_FieldNotes", nil, "Field Notes"), layout.pad or 10, (layout.bottomY or 0) - 20, 0.94, 0.96, 1, 1, UIFont.Medium)
end

function DTNPCLootSearchWindow:new(x, y, width, height, playerNum, npcData)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.playerNum = tonumber(playerNum) or 0
    o.npcData = type(npcData) == "table" and npcData or nil
    o.resizable = true
    o.pin = true
    o.title = T("DTNPC_UI_LootSearchTitle", nil, "Loot Search")
    o.selectedItemsBySource = {}
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.38 }
    o.borderColor = { r = 1, g = 1, b = 1, a = 0.16 }
    return o
end

function DTNPCLootSearchWindow.Open(playerNum, npcData)
    if DTNPCLootSearchWindow.instance and DTNPCLootSearchWindow.instance:getIsVisible() then
        DTNPCLootSearchWindow.instance.npcData = type(npcData) == "table" and npcData or DTNPCLootSearchWindow.instance.npcData
        DTNPCLootSearchWindow.instance:bringToTop()
        DTNPCLootSearchWindow.instance:refreshData()
        return DTNPCLootSearchWindow.instance
    end

    local window = DTNPCLootSearchWindow:new(180, 100, 980, 620, playerNum or 0, npcData)
    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    DTNPCLootSearchWindow.instance = window
    return window
end
