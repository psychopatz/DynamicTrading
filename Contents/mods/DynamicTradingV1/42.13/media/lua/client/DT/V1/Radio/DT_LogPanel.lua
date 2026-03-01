require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISLabel"
require "Utils/DT_StringUtils"

DT_LogPanel = ISPanel:derive("DT_LogPanel")

function DT_LogPanel:initialise()
    ISPanel.initialise(self)
    self.lastLogCount = -1
    self.lastTopLogID = ""
    -- Default key if none provided
    if not self.logKey then self.logKey = "DynamicTrading_Logs_v1.0" end
end

function DT_LogPanel:createChildren()
    ISPanel.createChildren(self)
    
    self.lblLogs = ISLabel:new(10, 0, 16, "Network Log:", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(self.lblLogs)
    
    self.logList = ISScrollingListBox:new(10, 20, self.width - 20, self.height - 25)
    self.logList:initialise()
    self.logList:setAnchorRight(true)
    self.logList.font = UIFont.NewSmall
    self.logList.itemheight = 20
    self.logList.drawBorder = true
    self.logList.borderColor = {r=0.3, g=0.3, b=0.3, a=1}
    self.logList.backgroundColor = {r=0.0, g=0.0, b=0.0, a=0.9}
    self.logList.doDrawItem = self.drawLogItem
    self.logList.onMouseWheel = function(self, del) return true end
    self:addChild(self.logList)
    
    -- Dummy element to clear stencil AFTER children are rendered
    self.stencilClearer = ISUIElement:new(0, 0, 0, 0)
    self.stencilClearer.prerender = function(self)
        if self.parent then self.parent:clearStencilRect() end
    end
    self:addChild(self.stencilClearer)
end

-- [FIXED] Removed invalid 'recalcStencil' call and fixed Scrollbar logic
function DT_LogPanel:onResize()
    ISPanel.onResize(self)
    if self.logList then
        local w = self:getWidth() - 20
        local h = self:getHeight() - 25
        
        self.logList:setWidth(w)
        self.logList:setHeight(h)
        
        -- Manually update scrollbar if it exists
        if self.logList.vscroll then
            self.logList.vscroll:setHeight(h)
            -- Stick to the right edge (Width - ScrollWidth)
            -- Standard scroll width is usually ~13-16px
            self.logList.vscroll:setX(w - 13) 
        end
        
        -- Re-populate to re-wrap text to new width
        self:populateLogs()
    end
end

function DT_LogPanel:prerender()
    ISPanel.prerender(self)
    
    local data = ModData.getOrCreate(self.logKey)
    local currentLogCount = data.list and #data.list or 0
    local currentTopLog = ""
    
    if data.list and data.list[1] then
        currentTopLog = data.list[1].time .. data.list[1].text
    end
    
    if currentLogCount ~= self.lastLogCount or currentTopLog ~= self.lastTopLogID then
        self:populateLogs()
        self.lastLogCount = currentLogCount
        self.lastTopLogID = currentTopLog
    end
    
    -- Enable Stencil for this panel
    self:setStencilRect(0, 0, self:getWidth(), self:getHeight())
end

-- Stencil is cleared by self.stencilClearer child to ensure children are clipped

function DT_LogPanel:populateLogs()
    self.logList:clear()
    local data = ModData.getOrCreate(self.logKey)
-- ... rest of file ...
    
    -- Calculate text width: ListWidth - Scrollbar(13) - Padding(12)
    local listWidth = self.logList:getWidth() - 25
    if listWidth < 50 then listWidth = 50 end 
    local tm = getTextManager()
    local font = self.logList.font
    
    if data.list then
        -- No limit on display, show all available logs
        for i=1, #data.list do
            local log = data.list[i]
            local timeWid = tm:MeasureStringX(font, log.time)
            
            local textSpace = listWidth - timeWid - 15
            if textSpace < 50 then textSpace = 50 end
            
            local lines = DynamicTrading.Utils.WrapText(log.text, textSpace, font)
            local lineHeight = self.logList.itemheight
            local totalHeight = #lines * lineHeight
            if totalHeight < lineHeight then totalHeight = lineHeight end
            
            local addedItem = self.logList:addItem(log.time, {
                log = log, lines = lines, timeWidth = timeWid, height = totalHeight
            })
            addedItem.height = totalHeight
        end
    end
end

function DT_LogPanel.drawLogItem(this, y, item, alt)
    local data = item.item
    local log = data.log
    local height = data.height
    local width = this:getWidth()
    
    if alt then this:drawRect(0, y, width, height, 0.05, 0.05, 0.05, 0.5) end
    
    local r, g, b = 0.8, 0.8, 0.8
    if log.cat == "good" then r, g, b = 0.4, 1.0, 0.4 
    elseif log.cat == "bad" then r, g, b = 1.0, 0.4, 0.4
    elseif log.cat == "event" then r, g, b = 1.0, 1.0, 0.4 end
    
    this:drawText(log.time, 5, y + 2, 0.5, 0.5, 0.5, 1, this.font)
    
    local textX = 5 + data.timeWidth + 8
    local currentY = y
    local lineHeight = this.itemheight
    
    if data.lines and #data.lines > 0 then
        for _, line in ipairs(data.lines) do
            this:drawText(line, textX, currentY + 2, r, g, b, 1, this.font)
            currentY = currentY + lineHeight
        end
    else
        this:drawText(log.text, textX, y + 2, r, g, b, 1, this.font)
    end
    
    return y + height
end

function DT_LogPanel:new(x, y, width, height, logKey)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.logKey = logKey 
    return o
end
