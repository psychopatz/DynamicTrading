require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISLabel"
require "Utils/DT_StringUtils"

DT_RadioScannerConversationPanel = ISPanel:derive("DT_RadioScannerConversationPanel")

function DT_RadioScannerConversationPanel:initialise()
    ISPanel.initialise(self)
    self.headingText = self.headingText or "Tracked Channel:"
    self.localLogs = self.localLogs or {}
    self.isTypingVisible = false
    self.typingTick = 0
end

function DT_RadioScannerConversationPanel:createChildren()
    ISPanel.createChildren(self)

    self.lblHeading = ISLabel:new(10, 0, 16, self.headingText, 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(self.lblHeading)

    self.chatList = ISScrollingListBox:new(10, 20, self.width - 20, self.height - 25)
    self.chatList:initialise()
    self.chatList:setAnchorRight(true)
    self.chatList.font = UIFont.NewSmall
    self.chatList.itemheight = 18
    self.chatList.drawBorder = true
    self.chatList.borderColor = { r = 0.3, g = 0.3, b = 0.3, a = 1 }
    self.chatList.backgroundColor = { r = 0.0, g = 0.0, b = 0.0, a = 0.9 }
    self.chatList.doDrawItem = DT_RadioScannerConversationPanel.drawLogItem
    self.chatList.onMouseWheel = function()
        return true
    end
    self:addChild(self.chatList)
end

function DT_RadioScannerConversationPanel:onResize()
    ISPanel.onResize(self)

    if not self.chatList then
        return
    end

    local width = self:getWidth() - 20
    local height = self:getHeight() - 25
    self.chatList:setWidth(width)
    self.chatList:setHeight(height)

    if self.chatList.vscroll then
        self.chatList.vscroll:setHeight(height)
        self.chatList.vscroll:setX(width - 13)
    end

    self:rebuildLogList()
end

function DT_RadioScannerConversationPanel:setHeadingText(text)
    self.headingText = tostring(text or "Tracked Channel:")
    if self.lblHeading then
        self.lblHeading:setName(self.headingText)
    end
end

function DT_RadioScannerConversationPanel:setTypingVisible(isVisible)
    self.isTypingVisible = isVisible == true
    if not self.isTypingVisible then
        self.typingTick = 0
    end
end

function DT_RadioScannerConversationPanel:clearMessages()
    self.localLogs = {}
    self:setTypingVisible(false)
    if self.chatList then
        self.chatList:clear()
    end
end

function DT_RadioScannerConversationPanel:rebuildLogList()
    if not self.chatList then
        return
    end

    local padding = 13
    local fullWidth = self.chatList:getWidth() - padding
    if fullWidth <= 50 then
        fullWidth = 200
    end

    local bubbleWidth = fullWidth * 0.85
    local font = self.chatList.font
    local lineHeight = self.chatList.itemheight or 18

    self.chatList:clear()
    for _, entry in ipairs(self.localLogs or {}) do
        local lines = DynamicTrading.Utils.WrapText(entry.text, bubbleWidth, font)
        local totalHeight = (#lines * lineHeight) + 4
        if totalHeight < lineHeight then
            totalHeight = lineHeight
        end

        entry.lines = lines
        entry.height = totalHeight

        local addedItem = self.chatList:addItem(entry.text, entry)
        addedItem.height = totalHeight + 2
    end

    if #self.chatList.items > 0 then
        self.chatList:ensureVisible(#self.chatList.items)
    end
end

function DT_RadioScannerConversationPanel:addMessage(text, isPlayer, isError)
    table.insert(self.localLogs, {
        text = tostring(text or "..."),
        isPlayer = isPlayer == true,
        error = isError == true,
    })
    self:rebuildLogList()
end

function DT_RadioScannerConversationPanel:render()
    ISPanel.render(self)

    if self.isTypingVisible then
        self.typingTick = self.typingTick + 1
        local frame = math.floor(self.typingTick / 10) % 4
        local dots = ""
        if frame == 1 then
            dots = "."
        elseif frame == 2 then
            dots = ".."
        elseif frame == 3 then
            dots = "..."
        end

        local bubbleX = self.chatList:getX() + 5
        local bubbleY = self.chatList:getY() + self.chatList:getHeight() - 25
        self:drawRect(bubbleX, bubbleY, 40, 20, 0.9, 0.2, 0.2, 0.2)
        self:drawRectBorder(bubbleX, bubbleY, 40, 20, 0.5, 0.5, 0.5, 0.5)
        self:drawText(dots, bubbleX + 12, bubbleY + 2, 0.8, 0.8, 0.8, 1, self.chatList.font)
    elseif #self.localLogs == 0 then
        self:drawTextCentre("Follow a signal to open the channel.", self.width / 2, self.height / 2 - 8, 0.5, 0.5, 0.5, 1, UIFont.Small)
    end
end

function DT_RadioScannerConversationPanel.drawLogItem(listbox, y, item, alt)
    local data = item.item
    local height = data.height or listbox.itemheight
    local width = listbox:getWidth()
    local lineHeight = listbox.itemheight
    local tm = getTextManager()
    local padding = 13
    local bubbleWidth = (width - padding) * 0.85

    if data.isPlayer then
        local xPos = (width - padding) - bubbleWidth
        listbox:drawRect(xPos, y, bubbleWidth, height, 0.1, 0.2, 0.35, 0.7)
        listbox:drawRectBorder(xPos, y, bubbleWidth, height, 0.2, 0.4, 0.6, 0.3)
    elseif data.error then
        listbox:drawRect(0, y, bubbleWidth, height, 0.3, 0.1, 0.1, 0.7)
        listbox:drawRectBorder(0, y, bubbleWidth, height, 0.5, 0.2, 0.2, 0.5)
    else
        listbox:drawRect(0, y, bubbleWidth, height, 0.15, 0.15, 0.15, 0.7)
        listbox:drawRectBorder(0, y, bubbleWidth, height, 0.3, 0.3, 0.3, 0.3)
    end

    local r, g, b = 0.9, 0.9, 0.9
    if data.isPlayer then
        r, g, b = 0.6, 0.9, 1.0
    elseif data.error then
        r, g, b = 1.0, 0.5, 0.5
    end

    local currentY = y + 2
    for _, lineStr in ipairs(data.lines or { data.text }) do
        local xPos = 5
        if data.isPlayer then
            local textWidth = tm:MeasureStringX(listbox.font, lineStr)
            xPos = (width - padding) - textWidth - 5
        end

        listbox:drawText(lineStr, xPos, currentY, r, g, b, 1, listbox.font)
        currentY = currentY + lineHeight
    end

    return y + height
end

function DT_RadioScannerConversationPanel:new(x, y, width, height, headingText)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self

    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.headingText = headingText
    o.localLogs = {}

    return o
end