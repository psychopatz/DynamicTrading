require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISLabel"
require "Utils/DT_StringUtils"

DT_RadioNetworkLogPanel = ISPanel:derive("DT_RadioNetworkLogPanel")

function DT_RadioNetworkLogPanel:initialise()
    ISPanel.initialise(self)
    self.lastLogCount = -1
    self.lastTopLogID = ""

    if not self.logKey then
        self.logKey = DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.GetStorageKey and DynamicTrading.GameplayLogs.GetStorageKey("Radio") or "DynamicTrading_GameplayLogs_Radio"
    end

    if not self.headingText then
        self.headingText = "Network Log:"
    end
end

function DT_RadioNetworkLogPanel:createChildren()
    ISPanel.createChildren(self)

    self.lblLogs = ISLabel:new(10, 0, 16, self.headingText, 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(self.lblLogs)

    self.logList = ISScrollingListBox:new(10, 20, self.width - 20, self.height - 25)
    self.logList:initialise()
    self.logList:setAnchorRight(true)
    self.logList.font = UIFont.NewSmall
    self.logList.itemheight = 20
    self.logList.drawBorder = true
    self.logList.borderColor = { r = 0.3, g = 0.3, b = 0.3, a = 1 }
    self.logList.backgroundColor = { r = 0.0, g = 0.0, b = 0.0, a = 0.9 }
    self.logList.doDrawItem = self.drawLogItem
    self.logList.onMouseWheel = function()
        return true
    end
    self:addChild(self.logList)

    self.stencilClearer = ISUIElement:new(0, 0, 0, 0)
    self.stencilClearer.prerender = function(element)
        if element.parent then
            element.parent:clearStencilRect()
        end
    end
    self:addChild(self.stencilClearer)
end

function DT_RadioNetworkLogPanel:onResize()
    ISPanel.onResize(self)

    if not self.logList then
        return
    end

    local width = self:getWidth() - 20
    local height = self:getHeight() - 25

    self.logList:setWidth(width)
    self.logList:setHeight(height)

    if self.logList.vscroll then
        self.logList.vscroll:setHeight(height)
        self.logList.vscroll:setX(width - 13)
    end

    self:populateLogs()
end

function DT_RadioNetworkLogPanel:prerender()
    ISPanel.prerender(self)

    local globalData = ModData.getOrCreate(self.logKey)
    local player = getSpecificPlayer(0)
    local localLogKey = player and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.GetLocalStorageKey and DynamicTrading.GameplayLogs.GetLocalStorageKey("Radio", player:getUsername()) or nil
    local localData = localLogKey and ModData.getOrCreate(localLogKey) or { list = {} }

    local gCount = globalData.list and #globalData.list or 0
    local lCount = localData.list and #localData.list or 0
    local currentLogCount = gCount + lCount
    
    local topG = globalData.list and globalData.list[1] or nil
    local topL = localData.list and localData.list[1] or nil
    local currentTopLog = ""

    local topLog = topG
    if topL then
        if not topG then
            topLog = topL
        else
            local tG = topG.time or topG.t or ""
            local tL = topL.time or topL.t or ""
            if tL > tG then
                topLog = topL
            end
        end
    end

    if topLog then
        currentTopLog = (topLog.time or topLog.t or "") .. (topLog.text or tostring(topLog.e))
    end

    if currentLogCount ~= self.lastLogCount or currentTopLog ~= self.lastTopLogID then
        self:populateLogs()
        self.lastLogCount = currentLogCount
        self.lastTopLogID = currentTopLog
    end

    self:setStencilRect(0, 0, self:getWidth(), self:getHeight())
end

function DT_RadioNetworkLogPanel:populateLogs()
    self.logList:clear()

    local globalData = ModData.getOrCreate(self.logKey)
    local player = getSpecificPlayer(0)
    local localLogKey = player and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.GetLocalStorageKey and DynamicTrading.GameplayLogs.GetLocalStorageKey("Radio", player:getUsername()) or nil
    local localData = localLogKey and ModData.getOrCreate(localLogKey) or { list = {} }

    local combinedList = {}
    if globalData.list then
        for i=1, #globalData.list do
            table.insert(combinedList, globalData.list[i])
        end
    end
    if localData.list then
        for i=1, #localData.list do
            table.insert(combinedList, localData.list[i])
        end
    end

    table.sort(combinedList, function(a, b)
        local ta = a.time or a.t or ""
        local tb = b.time or b.t or ""
        -- Newest first
        return ta > tb
    end)

    local listWidth = self.logList:getWidth() - 25
    if listWidth < 50 then
        listWidth = 50
    end

    local textManager = getTextManager()
    local font = self.logList.font

    if #combinedList == 0 then
        return
    end

    for i = 1, #combinedList do
        local log = combinedList[i]
        -- Serialize using template resolver
        local timeStr = log.time or log.t or ""
        local textStr, catStr = log.text, log.cat
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.ResolveText then
            textStr, catStr = DynamicTrading.GameplayLogs.ResolveText(log)
        end
        textStr = textStr or "Unknown event"

        local timeWidth = textManager:MeasureStringX(font, timeStr)
        local textSpace = listWidth - timeWidth - 15
        if textSpace < 50 then
            textSpace = 50
        end

        local lines = DynamicTrading.Utils.WrapText(textStr, textSpace, font)
        local lineHeight = self.logList.itemheight
        local totalHeight = #lines * lineHeight
        if totalHeight < lineHeight then
            totalHeight = lineHeight
        end

        local addedItem = self.logList:addItem(timeStr, {
            log = log,
            lines = lines,
            timeWidth = timeWidth,
            height = totalHeight,
            timeStr = timeStr,
            textStr = textStr,
            catStr = catStr
        })
        addedItem.height = totalHeight
    end
end

function DT_RadioNetworkLogPanel.drawLogItem(listbox, y, item, alt)
    local data = item.item
    local log = data.log
    local height = data.height
    local width = listbox:getWidth()

    if alt then
        listbox:drawRect(0, y, width, height, 0.05, 0.05, 0.05, 0.5)
    end

    local r, g, b = 0.8, 0.8, 0.8
    if data.catStr == "good" then
        r, g, b = 0.4, 1.0, 0.4
    elseif data.catStr == "bad" then
        r, g, b = 1.0, 0.4, 0.4
    elseif data.catStr == "event" then
        r, g, b = 1.0, 1.0, 0.4
    end

    listbox:drawText(data.timeStr, 5, y + 2, 0.5, 0.5, 0.5, 1, listbox.font)

    local textX = 5 + data.timeWidth + 8
    local currentY = y
    local lineHeight = listbox.itemheight

    if data.lines and #data.lines > 0 then
        for _, line in ipairs(data.lines) do
            listbox:drawText(line, textX, currentY + 2, r, g, b, 1, listbox.font)
            currentY = currentY + lineHeight
        end
    else
        listbox:drawText(data.textStr, textX, y + 2, r, g, b, 1, listbox.font)
    end

    return y + height
end

function DT_RadioNetworkLogPanel:new(x, y, width, height, logKey, headingText)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.logKey = logKey
    o.headingText = headingText

    return o
end