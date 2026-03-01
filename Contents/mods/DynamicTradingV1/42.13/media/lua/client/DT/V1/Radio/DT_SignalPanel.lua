require "ISUI/ISPanel"
require "ISUI/ISButton"
require "DT/V1/Manager"
require "DT/Common/Config"
require "DT/V1/Utils/DT_OptionsManager"
require "DT/UI/Faction/DT_FactionInfoWindow"


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
    
    self.imgSize = 130
    self.imgX = 10
    self.imgY = 10
end

function DT_SignalPanel:createChildren()
    ISPanel.createChildren(self)
    
    self.btnScan = ISButton:new(0, 0, 100, 25, "SCAN FREQUENCIES", self, self.onScanClick)
    self.btnScan:initialise()
    self.btnScan.backgroundColor = {r=0.1, g=0.3, b=0.1, a=1.0}
    self.btnScan.borderColor = {r=1, g=1, b=1, a=0.5}
    self:addChild(self.btnScan)
    
    self.btnInfo = ISButton:new(0, 0, 100, 25, "VIEW MARKET INFO", self, self.onInfoClick)
    self.btnInfo:initialise()
    self.btnInfo.borderColor = {r=1, g=1, b=1, a=0.5}
    self.btnInfo.backgroundColor = {r=0.2, g=0.2, b=0.4, a=1.0}
    self:addChild(self.btnInfo)
    
    -- [UPDATED] Settings Icon Button (V2 Style)
    local btnSize = 18
    self.btnOptions = ISButton:new(0, 0, btnSize, btnSize, "", self, self.onOptionsClick)
    self.btnOptions:initialise()
    self.btnOptions.borderColor = {r=1, g=1, b=1, a=0.2}
    self.btnOptions.backgroundColor = {r=0, g=0, b=0, a=0}
    self.btnOptions:setImage(getTexture("media/ui/inventoryPanes/Button_Settings.png")) 
    self:addChild(self.btnOptions)
    
    self:onResize()
end

function DT_SignalPanel:onResize()
    ISPanel.onResize(self)
    local w = self:getWidth()
    local h = self:getHeight()
    
    -- 1. Image Logic (Square, centered vertically)
    self.imgSize = h - 20
    if self.imgSize > w * 0.45 then self.imgSize = math.floor(w * 0.45) end
    if self.imgSize < 80 then self.imgSize = 80 end
    
    self.imgX = 10
    self.imgY = (h - self.imgSize) / 2
    
    -- 2. Button Layout Logic
    local startX = self.imgX + self.imgSize + 20
    local remWidth = w - startX - 10
    if remWidth < 120 then remWidth = 120 end 
    
    -- Position Settings Button (Top-Right)
    if self.btnOptions then
        local btnSize = 18
        self.btnOptions:setX(w - btnSize - 10)
        self.btnOptions:setY(10)
        self.btnOptions:setWidth(btnSize)
        self.btnOptions:setHeight(btnSize)
    end
    
    -- [FIX] Enforce specific spacing for Text Header
    local headerSpace = 25 -- Space reserved for "Power: x1.0"
    local bottomSpace = 5
    local spacing = 6 -- Gap between buttons
    
    -- Calculate height available strictly for main buttons (Scan/Info)
    local availableH = h - headerSpace - bottomSpace
    
    -- Calculate ideal button height to fit 2 buttons in available space
    local btnH = math.floor((availableH - spacing) / 2)
    
    -- Clamp Button Height
    if btnH < 22 then btnH = 22 end -- Minimum readable height
    if btnH > 35 then btnH = 35 end -- Max height for aesthetics
    
    -- Font Scaling
    local font = UIFont.Small
    if h > 220 then font = UIFont.Medium end
    
    -- Calculate vertical start position (centering within the safe zone)
    local totalBlockH = (btnH * 2) + spacing
    local safeZoneCenterY = headerSpace + (availableH / 2)
    local currentY = safeZoneCenterY - (totalBlockH / 2)
    
    -- Hard safety clamp: Never start higher than headerSpace
    if currentY < headerSpace then currentY = headerSpace end
    
    local btns = {self.btnScan, self.btnInfo}
    for _, btn in ipairs(btns) do
        if btn then
            btn:setX(startX)
            btn:setWidth(remWidth)
            btn:setHeight(btnH)
            btn:setY(currentY)
            btn.font = font
            currentY = currentY + btnH + spacing
        end
    end
    
    -- Save for render
    self.btnX = startX
    self.btnWidth = remWidth
    self.btnY = self.btnScan:getY()
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
        self:drawTextureScaled(tex, self.imgX, self.imgY, self.imgSize, self.imgSize, 1, 1, 1, 1)
        -- Transparent sprite, no border
    end

    -- 2. Draw Signal Power Text
    if self.parent and self.parent.radioObj then
        local typeID = nil
        if DT_RadioInteraction and DT_RadioInteraction.GetDeviceType then
             typeID = DT_RadioInteraction.GetDeviceType(self.parent.radioObj)
        end
        if not typeID and self.parent.radioObj.getFullType then
            typeID = self.parent.radioObj:getFullType()
        end

        local radioData = DynamicTrading.Config.GetRadioData(typeID)
        local power = radioData and radioData.power or 0.5
        if self.parent.isHam then
            power = power * (SandboxVars.DynamicTrading.HamRadioBonus or 2.0)
        end
        
        local r, g, b = 1, 1, 1 
        if power < 1.0 then r, g, b = 1.0, 0.4, 0.4 
        elseif power < 1.5 then r, g, b = 1.0, 0.9, 0.4 
        else r, g, b = 0.4, 1.0, 0.4 end
        
        local label = "Power: x" .. string.format("%.1f", power)
        
        local font = self.btnScan.font
        local textWidth = getTextManager():MeasureStringX(font, label)
        
        local centerX = self.btnX + (self.btnWidth / 2)
        local textX = centerX - (textWidth / 2)
        
        -- Draw text 20px above the first button
        -- Since we clamped btnY to >= 25 in onResize, this textY is guaranteed >= 5
        local textY = self.btnY - 20 
        
        local iconSize = 16
        if font == UIFont.Medium then iconSize = 20 end
        
        if typeID then
            local itemScript = ScriptManager.instance:getItem(typeID)
            local iconName = itemScript and itemScript:getIcon()
            local iconTex = iconName and getTexture("Item_" .. iconName)
            if iconTex then
                self:drawTextureScaled(iconTex, textX - iconSize - 5, textY - 2, iconSize, iconSize, 1, 1, 1, 1)
            end
        end
        
        self:drawText(label, textX, textY, r, g, b, 1.0, font)
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
        self.btnScan:setTitle("WAIT (" .. math.ceil(timeRem) .. "m)")
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
    if DT_FactionInfoWindow then
        DT_FactionInfoWindow.ToggleWindow()
    if DT_FactionInfoWindow then
        DT_FactionInfoWindow.ToggleWindow()
    end
end

function DT_SignalPanel:onOptionsClick()
    if DT_OptionsManager then
        DT_OptionsManager.ToggleWindow()
    else
        print("[DT_SignalPanel] ERROR: DT_OptionsManager failed to load.")
    end
end

function DT_SignalPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0} 
    return o
end     
