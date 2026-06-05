require "DT/Common/UI/Trading/TradingItemUtils/DT_TradingItemUtils"
require "Utils/DT_StringUtils"

local SellScanInternal = DT_TradingItemUtils.Internal

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function copyCategoryOrder(categories, shouldSort)
    local ordered = {}
    for _, category in ipairs(categories or {}) do
        ordered[#ordered + 1] = category
    end

    if shouldSort then
        table.sort(ordered)
    end

    return ordered
end

local function buildLoadingText(session)
    if not session then
        return T("DTCommon_UI_Trading_ScanningInventory", nil, "Scanning inventory...")
    end

    if session.completed then
        return T("DTCommon_UI_Trading_InventoryScanComplete", nil, "Inventory scan complete.")
    end

    return T(
        "DTCommon_UI_Trading_ScanningInventoryProgress",
        { count = tostring(session.processedCount or 0) },
        "Scanning inventory... " .. tostring(session.processedCount or 0) .. " items checked"
    )
end

function DT_TradingWindow.drawItem(listbox, y, item, alt)
    local height = listbox.itemheight
    local d = item.item
    local width = listbox:getWidth()

    if d.isPlaceholder then
        listbox:drawRect(0, y, width, height, 0.25, 0.08, 0.08, 0.12)
        listbox:drawRectBorder(0, y, width, height, 0.15, 0.7, 0.8, 1.0)
        listbox:drawText(d.text or T("DTCommon_UI_Trading_Loading", nil, "Loading..."), 10, y + (height / 2) - 7, 0.78, 0.88, 1.0, 1, UIFont.Small)
        return y + height
    end

    if d.isCategory then
        listbox:drawRect(0, y, width, height, 0.9, 0.1, 0.1, 0.1)
        listbox:drawRectBorder(0, y, width, height, 0.3, 0.5, 0.5, 0.5)

        local ui = DT_TradingWindow.instance
        local isCol = ui and ui.collapsed[d.categoryName]
        local prefix = isCol and "[+] " or "[-] "

        local formattedText = DynamicTrading.Utils.FormatCategoryString(d.text)
        listbox:drawText(prefix .. formattedText, 10, y + (height / 2) - 7, 1, 0.8, 0.3, 1, UIFont.Medium)
        return y + height
    end

    local isLocked = d.isLocked == true

    if listbox.selected == item.index then
        listbox:drawRect(0, y, width, height, 0.3, 0.7, 0.35, 0.2)
    elseif isLocked then
        listbox:drawRect(0, y, width, height, 0.4, 0.1, 0.1, 0.1)
    elseif alt then
        listbox:drawRect(0, y, width, height, 0.1, 0.2, 0.2, 0.2)
    end

    listbox:drawRectBorder(0, y, width, height, 0.1, 1, 1, 1)

    local invItem = d.invItem
    local tex = d.data and DT_TradingWindow.GetItemTexture(d.data.item, invItem) or nil

    if tex then
        local alpha = isLocked and 0.4 or 1.0
        listbox:drawTextureScaled(tex, 6, y + 4, 32, 32, alpha, 1, 1, 1)
    end

    local nameColor = { r = 0.9, g = 0.9, b = 0.9 }
    if isLocked then
        nameColor = { r = 0.5, g = 0.5, b = 0.5 }
    elseif d.isBuy and (tonumber(d.qty) or 0) <= 0 then
        nameColor = { r = 0.5, g = 0.5, b = 0.5 }
    end

    local statusSuffix = d.statusSuffix or ""
    local isRotten = d.isRotten or false
    local itemName = d.displayName or d.name or T("DTCommon_UI_Trading_UnknownItem", nil, "Unknown Item")

    if isRotten then
        nameColor = { r = 0.8, g = 0.3, b = 0.3 }
    end

    local finalName = itemName .. statusSuffix
    local sellQty = (not d.isBuy) and (tonumber(d.qty) or 1) or 0
    local maxNameWidth = width - ((sellQty > 1) and 250 or 210)
    local displayName = DT_TradingWindow.TruncateString(finalName, listbox.font, maxNameWidth)
    listbox:drawText(displayName, 45, y + 12, nameColor.r, nameColor.g, nameColor.b, 1, listbox.font)

    local displayTagsSource = d.effectiveTags or (d.data and d.data.tags) or nil
    if listbox.selected == item.index and displayTagsSource then
        local formattedTags = {}
        for _, tag in ipairs(displayTagsSource) do
            formattedTags[#formattedTags + 1] = DynamicTrading.Utils.FormatTagDialogue(tag)
        end
        local tagsStr = table.concat(formattedTags, ", ")
        local maxTagWidth = width - 180
        local displayTags = DT_TradingWindow.TruncateString(tagsStr, UIFont.Small, maxTagWidth)
        listbox:drawText(displayTags, 45, y + 24, 0.4, 0.7, 0.9, 1, UIFont.Small)
    end

    if isLocked then
        local nameWid = TextManager.instance:MeasureStringX(listbox.font, displayName)
        listbox:drawText(T("DTCommon_UI_Trading_Locked", nil, "(LOCKED)"), 50 + nameWid, y + 12, 1, 0.2, 0.2, 1, listbox.font)
    end

    local priceR, priceG, priceB = DT_TradingItemUtils.getPriceColors(d, isLocked)

    if d.isBuy then
        local qty = tonumber(d.qty) or 0
        if qty <= 0 then
            listbox:drawText(T("DTCommon_UI_Trading_SoldOut", nil, "(SOLD OUT)"), width - 140, y + 12, 1.0, 0.2, 0.2, 1, UIFont.Small)
        else
            listbox:drawText(T("DTCommon_UI_Trading_StockCount", { qty = qty }, "Stock: " .. qty), width - 140, y + 12, 0.7, 0.7, 0.7, 1, listbox.font)
        end
    elseif sellQty > 1 then
        listbox:drawText(T("DTCommon_UI_Trading_SellQuantity", { qty = sellQty }, "x" .. sellQty), width - 120, y + 12, 0.7, 0.7, 0.7, 1, listbox.font)
    end

    listbox:drawText("$" .. tostring(d.price), width - 60, y + 12, priceR, priceG, priceB, 1, listbox.font)

    return y + height
end

function DT_TradingWindow:showPlaceholderRow(text, oldScroll)
    self.listbox:clear()
    local row = self.listbox:addItem(text or "", { isPlaceholder = true, text = text or "" })
    row.item = { isPlaceholder = true, text = text or "" }
    row.height = self.listbox.itemheight
    self.listbox.selected = -1
    self.selectedItemID = -1
    self.btnAction:setEnable(false)
    self.btnAction:setTitle(self:getDefaultActionTitle())
    if self.btnLock then
        self.btnLock:setTitle(T("DTCommon_UI_Trading_LockItem", nil, "LOCK ITEM"))
        self.btnLock:setEnable(false)
        self.btnLock:setVisible(false)
    end
    self.listbox:setYScroll(oldScroll or 0)
end

function DT_TradingWindow:restoreSelectionAndButtons()
    local foundValidSelection = false

    if self.selectedKey then
        local targetIndex = -1
        for i = 1, #self.listbox.items do
            local listItem = self.listbox.items[i]
            local selectionKey = listItem.item and (listItem.item.selectionKey or listItem.item.key)
            if listItem.item
                and not listItem.item.isCategory
                and not listItem.item.isPlaceholder
                and selectionKey == self.selectedKey then
                targetIndex = i
                break
            end
        end

        if targetIndex ~= -1 then
            local checkItem = self.listbox.items[targetIndex].item
            local isLocked = checkItem.isLocked == true

            if not isLocked then
                self.listbox.selected = targetIndex
                self.selectedKey = checkItem.selectionKey or checkItem.key
                self.selectedItemID = checkItem.isGrouped and -1 or (checkItem.itemID or -1)
                foundValidSelection = true
            else
                for i = targetIndex + 1, #self.listbox.items do
                    local nextItem = self.listbox.items[i].item
                    if nextItem and not nextItem.isCategory and not nextItem.isPlaceholder and not nextItem.isLocked then
                        self.listbox.selected = i
                        self.selectedKey = nextItem.selectionKey or nextItem.key
                        self.selectedItemID = nextItem.isGrouped and -1 or (nextItem.itemID or -1)
                        foundValidSelection = true
                        break
                    end
                end
            end
        end
    end

    if not foundValidSelection then
        for i = 1, #self.listbox.items do
            local listItem = self.listbox.items[i]
            local data = listItem and listItem.item or nil
            if data and not data.isCategory and not data.isPlaceholder then
                self.listbox.selected = i
                self.selectedKey = data.selectionKey or data.key
                self.selectedItemID = data.isGrouped and -1 or (data.itemID or -1)
                foundValidSelection = true
                break
            end
        end
    end

    if foundValidSelection then
        local sel = self.listbox.items[self.listbox.selected].item
        self.btnAction:setTitle(self:getActionButtonTitle(sel))

        if self.isBuying then
            self.btnAction:setEnable((tonumber(sel.qty) or 0) > 0)
            if self.btnLock then
                self.btnLock:setVisible(false)
            end
        else
            local isCurrentlyLocked = sel.isLocked == true
            local sellQty = tonumber(sel.qty) or 1

            if sellQty > 1 then
                self.btnAction:setEnable(true)
                if self.btnLock then
                    self.btnLock:setTitle(T("DTCommon_UI_Trading_LockItem", nil, "LOCK ITEM"))
                    self.btnLock:setEnable(false)
                    self.btnLock:setVisible(false)
                end
            elseif isCurrentlyLocked then
                if self.btnLock then
                    self.btnLock:setTitle(T("DTCommon_UI_Trading_UnlockItem", nil, "UNLOCK ITEM"))
                    self.btnLock:setVisible(true)
                    self.btnLock:setEnable(true)
                end
                self.btnAction:setEnable(false)
            else
                if self.btnLock then
                    self.btnLock:setTitle(T("DTCommon_UI_Trading_LockItem", nil, "LOCK ITEM"))
                    self.btnLock:setVisible(true)
                    self.btnLock:setEnable(true)
                end
                self.btnAction:setEnable(true)
            end
        end

        if self.tradeRequestPending and self.btnAction then
            self.btnAction:setEnable(false)
            self.btnAction:setTitle(T("DTCommon_UI_Trading_Processing", nil, "PROCESSING..."))
        end
    else
        self.listbox.selected = -1
        self.selectedKey = nil
        self.selectedItemID = -1
        self.btnAction:setEnable(false)
        self.btnAction:setTitle(self:getDefaultActionTitle())
        if self.btnLock then
            self.btnLock:setTitle(T("DTCommon_UI_Trading_LockItem", nil, "LOCK ITEM"))
            self.btnLock:setEnable(false)
            self.btnLock:setVisible(false)
        end
    end
end

function DT_TradingWindow:rebuildCategorizedList(categorized, categories, options)
    options = options or {}
    local oldScroll = tonumber(options.oldScroll) or self.listbox:getYScroll()

    self.listbox:clear()

    if options.loadingText then
        local loadingItem = self.listbox:addItem(options.loadingText, {
            isPlaceholder = true,
            text = options.loadingText
        })
        loadingItem.item = {
            isPlaceholder = true,
            text = options.loadingText
        }
        loadingItem.height = self.listbox.itemheight
    end

    local orderedCategories = copyCategoryOrder(categories, options.sortCategories == true)
    for _, catName in ipairs(orderedCategories) do
        local itemsInCat = categorized[catName]
        if itemsInCat and #itemsInCat > 0 then
            local header = self.listbox:addItem(string.upper(catName), { isCategory = true })
            header.item = { isCategory = true, categoryName = catName, text = string.upper(catName) }
            header.height = 32

            if not self.collapsed[catName] then
                if options.sortItems == true then
                    table.sort(itemsInCat, function(a, b)
                        return tostring(a.name or "") < tostring(b.name or "")
                    end)
                end

                for _, prod in ipairs(itemsInCat) do
                    self.listbox:addItem(prod.name, prod)
                end
            end
        end
    end

    if #self.listbox.items <= 0 then
        self:showPlaceholderRow(options.emptyText or T("DTCommon_UI_Trading_NoItemsAvailable", nil, "No items available."), oldScroll)
        return
    end

    self:restoreSelectionAndButtons()
    self.listbox:setYScroll(oldScroll)
end

function DT_TradingWindow:refreshSellScanProgress(forceRefresh, oldScroll)
    local session = self.sellScanSession
    if not session then
        self:showPlaceholderRow(T("DTCommon_UI_Trading_ScanningInventory", nil, "Scanning inventory..."), oldScroll)
        return
    end

    if (not forceRefresh) and (not session.needsListRefresh) and (not self.sellScanListDirty) then
        return
    end

    local loadingText = nil
    local emptyText = T("DTCommon_UI_Trading_NoSellableItemsAvailable", nil, "No sellable items available.")
    if not session.completed then
        loadingText = buildLoadingText(session)
        emptyText = loadingText
    elseif session.reusedCachedResults then
        emptyText = T("DTCommon_UI_Trading_NoSellableItemsAvailable", nil, "No sellable items available.")
    end

    self:rebuildCategorizedList(session.categorized, session.categories, {
        oldScroll = oldScroll,
        sortCategories = session.completed == true,
        sortItems = session.completed == true,
        loadingText = loadingText,
        emptyText = emptyText,
    })

    session.needsListRefresh = false
    self.sellScanListDirty = false
    self.sellScanLastListRefreshAt = self:GetNowMs()
end

function DT_TradingWindow:populateList()
    local startedAt = self:GetNowMs()
    local oldScroll = self.listbox:getYScroll()

    self.scanRejections = {}

    local dataProvider = self.dataProvider
    if not dataProvider or not self.traderID then
        return
    end

    local trader = dataProvider:getTrader(self.traderID, self.archetype)
    if not trader then
        return
    end

    self:coerceTradeMode(trader)
    if self.relayout then
        self:relayout()
    end

    if self.btnAsk then
        local config = dataProvider:getAskButtonConfig(self.isBuying)
        if config then
            self.btnAsk:setTitle(config.title or T("DTCommon_UI_Trading_Talk", nil, "Talk"))
            self.btnAsk:setVisible(config.visible ~= false)
            self.btnAsk:setEnable(true)
        else
            self.btnAsk:setVisible(false)
        end
    end

    if self.btnLock then
        self.btnLock:setVisible(dataProvider:getLockButtonVisible(self.isBuying))
    end

    self:updateIdentityDisplay(trader)
    self:updateWallet()

    local categorized = {}
    local categories = {}

    if self.isBuying then
        self.sellScanSession = nil
        DT_TradingItemUtils.scanBuyableItems(trader, dataProvider, categorized, categories, self.scanRejections)
        self:rebuildCategorizedList(categorized, categories, {
            oldScroll = oldScroll,
            sortCategories = true,
            sortItems = true,
            emptyText = T("DTCommon_UI_Trading_NoItemsAvailable", nil, "No items available."),
        })
    else
        local player = getSpecificPlayer(0)
        local activeRadioID = -1
        if self.radioObj and instanceof(self.radioObj, "InventoryItem") then
            activeRadioID = self.radioObj:getID()
        end

        self.sellScanSession = SellScanInternal.createSellScanSession(player, trader, dataProvider, activeRadioID, self.scanRejections)
        self.sellScanListDirty = true
        self:refreshSellScanProgress(true, oldScroll)
    end

    self.inventoryDirty = false
    self.lastOpenPopulateAt = self:GetNowMs()
    self:logPerf("PopulateList", "mode=" .. tostring(self.isBuying and "buy" or "sell") .. " durationMs=" .. tostring(self.lastOpenPopulateAt - startedAt))
end
