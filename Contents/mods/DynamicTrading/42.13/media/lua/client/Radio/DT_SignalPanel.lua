require "ISUI/ISPanel"
require "ISUI/ISButton"
require "DynamicTrading_Manager"
require "client/DT_RadioInteraction" -- Required for GetDeviceType

DT_SignalPanel = ISPanel:derive("DT_SignalPanel")

function DT_SignalPanel:initialise()
    ISPanel.initialise(self)
    self.signalState = "search"
    self.signalFrame = 1
    self.signalAnimTimer = 0
    self.signalFrameDuration = 200
    self.signalFoundPersist = false
    self.clickAnimTimer = 0 
    
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
    
    -- Layout Calculation
    local animSpace = 170
    local remWidth = width - animSpace
    local btnX = animSpace + (remWidth - btnWidth) / 2
    local startY = 55
    
    -- Store button coordinates for dynamic text rendering
    self.btnX = btnX
    self.btnY = startY
    self.btnWidth = btnWidth
    
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
    
    -- Options Button
    self.btnOptions = ISButton:new(btnX, startY + 70, btnWidth, 25, "OPTIONS", self, self.onOptionsClick)
    self.btnOptions:initialise()
    self.btnOptions.borderColor = {r=1, g=1, b=1, a=0.5}
    self.btnOptions.backgroundColor = {r=0.4, g=0.4, b=0.4, a=1.0}
    self:addChild(self.btnOptions)
end

function DT_SignalPanel:prerender()
    ISPanel.prerender(self)
    self:updateSignalLogic()
    self:updateButtonState()
end

function DT_SignalPanel:render()
    ISPanel.render(self)
    
    -- 1. Draw Signal Animation
    local tex = self.signalTextures[self.signalState] and self.signalTextures[self.signalState][self.signalFrame]
    
    if self.clickAnimTimer > 0 and self.signalTextures.none and self.signalTextures.none[2] then
        tex = self.signalTextures.none[2]
    end
    
    if tex then
        local size = 150 
        local x = 10 
        local y = (self.height - size) / 2 
        self:drawTextureScaled(tex, x, y, size, size, 1, 1, 1, 1)
    end

    -- 2. Draw Signal Power (Bonus) above Scan Button
    if self.parent and self.parent.radioObj then
        -- Calculate Power
        local typeID = DT_RadioInteraction.GetDeviceType(self.parent.radioObj)
        local radioData = DynamicTrading.Config.GetRadioData(typeID)
        local power = radioData.power or 0.5
        
        if self.parent.isHam then
            power = power * (SandboxVars.DynamicTrading.HamRadioBonus or 2.0)
        end
        
        -- Determine Color
        local r, g, b = 1, 1, 1 -- Default White
        if power < 1.0 then
            r, g, b = 1.0, 0.4, 0.4 -- Red (Weak)
        elseif power < 1.5 then
            r, g, b = 1.0, 0.9, 0.4 -- Yellow (Average)
        else
            r, g, b = 0.4, 1.0, 0.4 -- Green (Strong)
        end
        
        -- Draw Text
        local label = "Broadcast Power: x" .. string.format("%.1f", power)
        local font = UIFont.Small
        local textWidth = getTextManager():MeasureStringX(font, label)
        local iconSize = 20
        local spacing = 8
        
        local totalWidth = textWidth + spacing + iconSize
        local startX = self.btnX + (self.btnWidth - totalWidth) / 2
        local textY = self.btnY - 18
        
        -- Draw Icon
        local itemScript = ScriptManager.instance:getItem(typeID)
        local iconName = itemScript and itemScript:getIcon()
        local iconTex = iconName and getTexture("Item_" .. iconName)
        
        if iconTex then
            self:drawTextureScaled(iconTex, startX, textY - 2, iconSize, iconSize, 1, 1, 1, 1)
        end
        
        -- Draw Label
        self:drawText(label, startX + iconSize + spacing, textY, r, g, b, 1.0, font)
    end
end

function DT_SignalPanel:updateButtonState()
    local player = getSpecificPlayer(0)
    local canScan, timeRem = DynamicTrading.CooldownManager.CanScan(player)
    
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
    self.clickAnimTimer = 300 
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

function DT_SignalPanel:onOptionsClick()
    if not DT_OptionsUI then 
        pcall(require, "UI/DT_OptionsUI")
        if not DT_OptionsUI then pcall(require, "client/UI/DT_OptionsUI") end
    end
    
    if DT_OptionsUI then
        DT_OptionsUI.ToggleWindow()
    else
        print("[DT_SignalPanel] ERROR: DT_OptionsUI failed to load.")
    end
end

function DT_SignalPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0} 
    return o
end     