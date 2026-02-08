-- =============================================================================
-- DT_OptionsUI
-- Options/Configuration Window for Dynamic Trading
-- Redesigned: Resizeable Window + Tabbed Interface
-- =============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTickBox"
require "ISUI/ISTabPanel"
require "ISUI/UserInterface/ISSliderPanel"
require "Utils/DT_ConfigManager"
require "DT/V1/Utils/DT_AudioManager"
require "DT/V1/UI/DT_SidebarButton"

DT_OptionsUI = ISCollapsableWindow:derive("DT_OptionsUI")
DT_OptionsUI.instance = nil

function DT_OptionsUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Dynamic Trading Settings")
    self:setResizable(true)
end

function DT_OptionsUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    
    -- 1. Create the Tab Panel Container
    -- We set height to self.height - th to fill the window body
    self.tabs = ISTabPanel:new(0, th, self.width, self.height - th)
    self.tabs:initialise()
    self.tabs.borderColor = { r=0, g=0, b=0, a=0 }
    self.tabs:setAnchorBottom(true)
    self.tabs:setAnchorRight(true)
    -- [FIX] Removed the erroneous onMouseDown override here
    self:addChild(self.tabs)

    -- 2. Create the Sub-Panels (The pages inside the tabs)
    -- Important: We create them, but ISTabPanel will manage their size/position
    self.panelGeneral = ISPanel:new(0, 0, self.tabs.width, self.tabs.height)
    self.panelGeneral:initialise()
    self.panelGeneral.backgroundColor = {r=0,g=0,b=0,a=1.0} -- Solid black for better visibility
    self.panelGeneral:setAnchorRight(true)
    self.panelGeneral:setAnchorBottom(true)
    
    self.panelAudio = ISPanel:new(0, 0, self.tabs.width, self.tabs.height)
    self.panelAudio:initialise()
    self.panelAudio.backgroundColor = {r=0,g=0,b=0,a=1.0}
    self.panelAudio:setAnchorRight(true)
    self.panelAudio:setAnchorBottom(true)

    -- 3. Populate Tabs
    self:createGeneralChildren(self.panelGeneral)
    self:createAudioChildren(self.panelAudio)

    -- 4. Add Panels to Tabs
    self.tabs:addView("General", self.panelGeneral)
    self.tabs:addView("Audio", self.panelAudio)
    
    -- [FIX] Force activate the first tab so it isn't empty
    self.tabs:activateView("General")
end

-- =============================================================================
-- TAB 1: GENERAL SETTINGS
-- =============================================================================
function DT_OptionsUI:createGeneralChildren(panel)
    local pad = 20
    local y = 20
    
    local lbl = ISLabel:new(pad, y, 20, "Interface Settings", 1, 1, 1, 1, UIFont.Medium, true)
    panel:addChild(lbl)
    y = y + 35

    -- TickBox: Sidebar
    self.tickGeneral = ISTickBox:new(pad, y, 20, 20, "", self, self.onGeneralTick)
    self.tickGeneral:initialise()
    
    self.tickGeneral:addOption("Show Sidebar Button", "sidebar")
    self.tickGeneral:addOption("Enable Sounds", "sound")
    
    -- Set Initial States
    self.tickGeneral:setSelected(1, DT_ConfigManager.settings.showSidebar)
    self.tickGeneral:setSelected(2, DT_ConfigManager.settings.enableSound)
    
    panel:addChild(self.tickGeneral)
end

function DT_OptionsUI:onGeneralTick(index, selected)
    if index == 1 then
        DT_ConfigManager.setShowSidebar(selected)
        if DT_SidebarButton and DT_SidebarButton.UpdateVisibility then
            DT_SidebarButton.UpdateVisibility()
        end
    elseif index == 2 then
        DT_ConfigManager.settings.enableSound = selected
        DT_ConfigManager.save()
    end
end

-- =============================================================================
-- TAB 2: AUDIO SETTINGS
-- =============================================================================
function DT_OptionsUI:createAudioChildren(panel)
    local pad = 20
    local y = 20
    
    local lbl = ISLabel:new(pad, y, 20, "Volume Mixer", 1, 1, 1, 1, UIFont.Medium, true)
    panel:addChild(lbl)
    y = y + 35

    local function AddSlider(label, category, exampleSound)
        -- 1. Label
        local lblObj = ISLabel:new(pad, y, 20, label, 1, 1, 1, 1, UIFont.Small, true)
        panel:addChild(lblObj)
        
        -- 2. Percent Label (The number next to the slider)
        -- We create this FIRST so the slider callback can reference it
        local currentVol = math.floor(DT_ConfigManager.getVolume(category) * 100)
        local valLabel = ISLabel:new(pad + 240, y + 2, 20, currentVol .. "%", 1, 1, 1, 1, UIFont.Small, true)
        panel:addChild(valLabel)
        
        -- 3. Slider
        local sliderX = pad + 80
        local slider = ISSliderPanel:new(sliderX, y, 150, 20, self, function(target, val)
             -- Snap logic
             local snappedVal = math.floor((val / 10) + 0.5) * 10
             DT_ConfigManager.setVolume(category, snappedVal / 100)
             
             -- [FIX] Update the label text immediately
             valLabel:setName(snappedVal .. "%")
        end)
        slider:initialise()
        slider.currentValue = currentVol
        slider:setValues(0, 100, 10, 10)
        panel:addChild(slider)

        -- 4. Test Button
        local btnPlay = ISButton:new(sliderX + 160 + 40, y - 2, 30, 24, " > ", self, function(self)
            DT_AudioManager.PlaySound(exampleSound, false, 1.0)
        end)
        btnPlay:initialise()
        btnPlay.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
        panel:addChild(btnPlay)
        
        y = y + 40
    end

    AddSlider("Master:", "Master", "DT_Cashier")
    AddSlider("Radio:", "Radio", "DT_RadioRandom")
    AddSlider("Wallet:", "Wallet", "DT_CasinoRandom")
    AddSlider("Trade:", "Trade", "DT_Cashier")
end

-- =============================================================================
-- WINDOW LOGIC
-- =============================================================================

function DT_OptionsUI:onResize()
    ISCollapsableWindow.onResize(self)
    local th = self:titleBarHeight()
    local w = self:getWidth()
    local h = self:getHeight()
    
    -- Ensure Tab Panel fills the window
    if self.tabs then
        self.tabs:setX(0)
        self.tabs:setY(th)
        self.tabs:setWidth(w)
        self.tabs:setHeight(h - th)
    end
end

function DT_OptionsUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DT_OptionsUI.instance = nil
end

function DT_OptionsUI.ToggleWindow()
    if DT_OptionsUI.instance then
        DT_OptionsUI.instance:close()
        return
    end

    local width = 400
    local height = 300
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    local ui = DT_OptionsUI:new(x, y, width, height)
    ui:initialise()
    ui:addToUIManager()
    DT_OptionsUI.instance = ui
end

function DT_OptionsUI:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end
