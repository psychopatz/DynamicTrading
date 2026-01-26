require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISLabel"
require "Utils/DT_StringUtils"

DT_LogPanel = ISPanel:derive("DT_LogPanel")

function DT_LogPanel:initialise()
    ISPanel.initialise(self)
    self.lastLogCount = -1
    self.lastTopLogID = ""
end

function DT_LogPanel:createChildren()
    ISPanel.createChildren(self)
    
    self.lblLogs = ISLabel:new(10, 0, 16, "System Logs (Last 12):", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
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
end

function DT_LogPanel:prerender()
    ISPanel.prerender(self)
    
    local data = DynamicTrading.Manager.GetData()
    local currentLogCount = data.NetworkLogs and #data.NetworkLogs or 0
    local currentTopLog = ""
    
    if data.NetworkLogs and data.NetworkLogs[1] then
        currentTopLog = data.NetworkLogs[1].time .. data.NetworkLogs[1].text
    end
    
    if currentLogCount ~= self.lastLogCount or currentTopLog ~= self.lastTopLogID then
        self:populateLogs()
        self.lastLogCount = currentLogCount
        self.lastTopLogID = currentTopLog
    end
end

function DT_LogPanel:populateLogs()
    self.logList:clear()
    local data = DynamicTrading.Manager.GetData()
    
    local listWidth = self.logList:getWidth() - 25
    local tm = getTextManager()
    local font = self.logList.font
    
    if data.NetworkLogs then
        local limit = math.min(#data.NetworkLogs, 12)
        for i=1, limit do
            local log = data.NetworkLogs[i]
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
    local lineHeight = this.itemheight
    
    if alt then this:drawRect(0, y, width, height, 0.05, 0.05, 0.05, 0.5) end
    
    local r, g, b = 0.8, 0.8, 0.8
    if log.cat == "good" then r, g, b = 0.4, 1.0, 0.4 
    elseif log.cat == "bad" then r, g, b = 1.0, 0.4, 0.4
    elseif log.cat == "event" then r, g, b = 1.0, 1.0, 0.4 end
    
    this:drawText(log.time, 5, y + 2, 0.5, 0.5, 0.5, 1, this.font)
    
    local textX = 5 + data.timeWidth + 8
    local currentY = y
    
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

function DT_LogPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    return o
end
