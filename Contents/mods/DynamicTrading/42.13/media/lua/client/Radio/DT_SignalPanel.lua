require "ISUI/ISPanel"
require "ISUI/ISButton"
require "DynamicTrading_Manager"

DT_SignalPanel = ISPanel:derive("DT_SignalPanel")

function DT_SignalPanel:initialise()
    ISPanel.initialise(self)
    self.signalState = "search"
    self.signalFrame = 1
    self.signalAnimTimer = 0
    self.signalFrameDuration = 200
    self.signalFoundPersist = false
    self.clickAnimTimer = 0 -- [NEW] Timer for click feedback overrides
    
    self.signalFrameCounts = { search = 5, found = 3, none = 3 }
    self.signalTextures = { search = {}, found = {}, none = {} }
    
    for i = 1, 5 do self.signalTextures.search[i] = getTexture("media/ui/Radio/Signal_search/" .. i .. ".png") end
    for i = 1, 3 do
        self.signalTextures.found[i] = getTexture("media/ui/Radio/Signal_found/" .. i .. ".png")
        self.signalTextures.none[i] = getTexture("media/ui/Radio/Signal_none/" .. i .. ".png")
    end
end

function DT_SignalPanel:createChildren()
    ISPanel.createChildren(self)
    
    local width = self.width
    local btnWidth = 180
    
    -- Layout: Animation (Left) | Buttons (Right)
    -- AnimSize ~150 + Padding ~20 = 170 Left Offset
    -- Remaining Width = width - 170
    -- Center of Right Side = 170 + (Remaining / 2)
    -- Button X = Center - (btnWidth / 2)
    
    local animSpace = 170
    local remWidth = width - animSpace
    local btnX = animSpace + (remWidth - btnWidth) / 2
    
    -- Vertical Centering for Buttons considering height ~170
    -- Total Height 170. Buttons take ~60 height (25 + 10 gap + 25)
    -- StartY = (170 - 60) / 2 = 55
    
    local startY = 55
    
    -- Scan Button
    self.btnScan = ISButton:new(btnX, startY, btnWidth, 25, "SCAN FREQUENCIES", self, self.onScanClick)
    self.btnScan:initialise()
    self.btnScan.backgroundColor = {r=0.1, g=0.3, b=0.1, a=1.0}
    self.btnScan.borderColor = {r=1, g=1, b=1, a=0.5}
    self:addChild(self.btnScan)
    
    -- Market Info Button
    self.btnInfo = ISButton:new(btnX, startY + 35, btnWidth, 25, "VIEW MARKET INFO", self, self.onInfoClick)
    self.btnInfo:initialise()
    self.btnInfo.borderColor = {r=1, g=1, b=1, a=0.5}
    self.btnInfo.backgroundColor = {r=0.2, g=0.2, b=0.4, a=1.0}
    self:addChild(self.btnInfo)
end

function DT_SignalPanel:prerender()
    ISPanel.prerender(self)
    self:updateSignalLogic()
    self:updateButtonState()
end

function DT_SignalPanel:render()
    ISPanel.render(self)
    -- Draw Animation
    -- Draw Animation
    local tex = self.signalTextures[self.signalState] and self.signalTextures[self.signalState][self.signalFrame]
    
    -- [NEW] Click Feedback Override
    if self.clickAnimTimer > 0 and self.signalTextures.none and self.signalTextures.none[2] then
        tex = self.signalTextures.none[2]
    end
    
    if tex then
        local size = 150 
        local x = 10 -- Left side padding
        local y = (self.height - size) / 2 -- Vertically center
        self:drawTextureScaled(tex, x, y, size, size, 1, 1, 1, 1)
    end
end

function DT_SignalPanel:updateButtonState()
    local player = getSpecificPlayer(0)
    local canScan, timeRem = DynamicTrading.Manager.CanScan(player)
    
    if canScan then
        self.btnScan:setEnable(true)
        self.btnScan:setTitle("SCAN FREQUENCIES")
        self.btnScan.textColor = {r=1, g=1, b=1, a=1}
    else
        self.btnScan:setEnable(false)
        self.btnScan:setTitle("COOLDOWN (" .. math.ceil(timeRem) .. "m)")
        self.btnScan.textColor = {r=1, g=0.5, b=0.5, a=1}
    end
end

function DT_SignalPanel:updateSignalLogic()
    local player = getSpecificPlayer(0)
    local currentFound, dailyLimit = DynamicTrading.Manager.GetDailyStatus()
    local isPublic = SandboxVars.DynamicTrading.PublicNetwork
    local signalAvailable = true
    
    -- [NEW] Update Click Timer
    local deltaTime = UIManager.getMillisSinceLastRender()
    if self.clickAnimTimer > 0 then
        self.clickAnimTimer = self.clickAnimTimer - deltaTime
    end
    
    if isPublic then
        if currentFound >= dailyLimit then signalAvailable = false end
    else
        local canGenNew = (currentFound < dailyLimit)
        local undiscovered = DynamicTrading.Manager.GetUndiscoveredTraders(player)
        if not canGenNew and #undiscovered == 0 then signalAvailable = false end
    end
    
    if self.signalFoundPersist then
        self.signalState = "found"
    elseif not signalAvailable then
        self.signalState = "none"
    else
        self.signalState = "search"
    end
    
    -- Animate
    local deltaTime = UIManager.getMillisSinceLastRender()
    self.signalAnimTimer = self.signalAnimTimer + deltaTime
    if self.signalAnimTimer >= self.signalFrameDuration then
        self.signalAnimTimer = self.signalAnimTimer - self.signalFrameDuration
        self.signalFrame = self.signalFrame + 1
        local max = self.signalFrameCounts[self.signalState] or 3
        if self.signalFrame > max then self.signalFrame = 1 end
    end
end

function DT_SignalPanel:onScanClick()
    local player = getSpecificPlayer(0)
    if self.parent and self.parent.CheckConnectionValidity and not self.parent:CheckConnectionValidity() then 
        self.parent:close() 
        return 
    end
    
    self.signalFoundPersist = false
    self.clickAnimTimer = 300 -- [NEW] Show override for 300ms
    sendClientCommand(player, "DynamicTrading", "RequestFullState", {})

    if DT_RadioInteraction and DT_RadioInteraction.PerformScan then
        DT_RadioInteraction.PerformScan(player, self.parent.radioObj, self.parent.isHam)
    end
end

function DT_SignalPanel:onInfoClick()
    if DynamicTradingInfoUI then
        if DynamicTradingInfoUI.instance and DynamicTradingInfoUI.instance:isVisible() then
            DynamicTradingInfoUI.instance:addToUIManager()
        else
            DynamicTradingInfoUI.ToggleWindow()
        end
    end
end

function DT_SignalPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0} -- transparent
    return o
end
