-- =============================================================================
-- DT_OptionsUI (Common)
-- Options/Configuration Window for Dynamic Trading
-- Data-Agnostic: Configured via initialize parameters.
-- =============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTickBox"
require "ISUI/ISTabPanel"
require "ISSliderPanel"
require "Utils/ConfigManager/DT_ConfigManager"
require "DT/Common/Utils/DT_AudioManager"
require "DT/Common/UI/ManualUI/ManualUI"
require "DT/Common/UI/Pricing/PricingOptionsTab/DT_PricingOptionsTab"
require "DT/Common/Faction/DT_FactionDiscoveryBannerEditor"

DT_OptionsUI = ISCollapsableWindow:derive("DT_OptionsUI")
DT_OptionsUI.instance = nil

-- Configuration Holder (Registries)
DT_OptionsUI.config = {
    title = "Dynamic Trading Settings",
    audioCategories = {}, -- { {label="Radio", configKey="Radio", exampleSound="DT_RadioRandom"} }
    generalSettings = {}  -- { {label="Show Sidebar", configKey="showSidebar", callback:func} }
}

-- Registry Lookup to prevent duplicates
local _audioKeys = {}
local _generalKeys = {}

function DT_OptionsUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle(DT_OptionsUI.config.title)
    self:setResizable(true)
end

function DT_OptionsUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    
    -- 1. Create the Tab Panel Container
    self.tabs = ISTabPanel:new(0, th, self.width, self.height - th)
    self.tabs:initialise()
    self.tabs.borderColor = { r=0, g=0, b=0, a=0 }
    self.tabs:setAnchorBottom(true)
    self.tabs:setAnchorRight(true)
    self:addChild(self.tabs)

    -- 2. Create the Sub-Panels
    self.panelGeneral = ISPanel:new(0, 0, self.tabs.width, self.tabs.height)
    self.panelGeneral:initialise()
    self.panelGeneral.backgroundColor = {r=0,g=0,b=0,a=1.0}
    self.panelGeneral:setAnchorRight(true)
    self.panelGeneral:setAnchorBottom(true)
    
    self.panelAudio = ISPanel:new(0, 0, self.tabs.width, self.tabs.height)
    self.panelAudio:initialise()
    self.panelAudio.backgroundColor = {r=0,g=0,b=0,a=1.0}
    self.panelAudio:setAnchorRight(true)
    self.panelAudio:setAnchorBottom(true)

    self.panelManuals = ISPanel:new(0, 0, self.tabs.width, self.tabs.height)
    self.panelManuals:initialise()
    self.panelManuals.backgroundColor = {r=0,g=0,b=0,a=1.0}
    self.panelManuals:setAnchorRight(true)
    self.panelManuals:setAnchorBottom(true)

    self.panelPricing = nil
    self.canEditPricing = DynamicTrading
        and DynamicTrading.PriceConfig
        and DynamicTrading.PriceConfig.CanEditLocalPlayer
        and DynamicTrading.PriceConfig.CanEditLocalPlayer()

    if self.canEditPricing then
        self.panelPricing = ISPanel:new(0, 0, self.tabs.width, self.tabs.height)
        self.panelPricing:initialise()
        self.panelPricing.backgroundColor = {r=0,g=0,b=0,a=1.0}
        self.panelPricing:setAnchorRight(true)
        self.panelPricing:setAnchorBottom(true)
    end

    -- 3. Populate Tabs
    self:createGeneralChildren(self.panelGeneral)
    self:createAudioChildren(self.panelAudio)
    self:createManualChildren(self.panelManuals)
    if self.panelPricing then
        DT_PricingOptionsTab.Create(self, self.panelPricing)
    end

    -- 4. Add Panels to Tabs
    self.tabs:addView("General", self.panelGeneral)
    self.tabs:addView("Audio", self.panelAudio)
    self.tabs:addView("Manuals", self.panelManuals)
    if self.panelPricing then
        self.tabs:addView("Pricing", self.panelPricing)
    end
    
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

    if #DT_OptionsUI.config.generalSettings > 0 then
        self.tickGeneral = ISTickBox:new(pad, y, 20, 20, "", self, self.onGeneralTick)
        self.tickGeneral:initialise()
        
        for i, setting in ipairs(DT_OptionsUI.config.generalSettings) do
            self.tickGeneral:addOption(setting.label, i)
            -- If configKey is present, use ConfigManager to set initial state
            if setting.configKey then
                local val = DT_ConfigManager.settings[setting.configKey]
                if val ~= nil then
                    self.tickGeneral:setSelected(i, val)
                end
            end
        end
        panel:addChild(self.tickGeneral)
        y = y + math.max(34, (#DT_OptionsUI.config.generalSettings * 28) + 8)
    else
        local noSettings = ISLabel:new(pad, y, 20, "No general settings registered.", 1, 0.5, 0.5, 0.5, UIFont.Small, true)
        panel:addChild(noSettings)
        y = y + 34
    end

    local opacityTitle = ISLabel:new(pad, y + 4, 20, "Conversation Background", 1, 1, 1, 1, UIFont.Small, true)
    panel:addChild(opacityTitle)

    local currentOpacity = math.floor((DT_ConfigManager.getConversationOverlayOpacity() or 1.0) * 100 + 0.5)
    local opacityValue = ISLabel:new(pad + 250, y + 6, 20, currentOpacity .. "%", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    panel:addChild(opacityValue)

    self.sliderConversationOpacity = ISSliderPanel:new(pad + 120, y + 2, 120, 20, self, function(target, val)
        local snappedVal = math.floor((val / 5) + 0.5) * 5
        DT_ConfigManager.setConversationOverlayOpacity(snappedVal / 100)
        opacityValue:setName(snappedVal .. "%")
    end)
    self.sliderConversationOpacity:initialise()
    self.sliderConversationOpacity.currentValue = currentOpacity
    self.sliderConversationOpacity:setValues(0, 100, 5, 5)
    panel:addChild(self.sliderConversationOpacity)

    local opacityHint = ISLabel:new(pad, y + 28, 20, "0% is fully transparent unless Disable Transparency is enabled. 100% is the strongest backdrop.", 0.72, 0.72, 0.72, 1, UIFont.Small, true)
    panel:addChild(opacityHint)
    y = y + 64

    local bannerTitle = ISLabel:new(pad, y, 20, "Faction Discovery Banner", 1, 1, 1, 1, UIFont.Small, true)
    panel:addChild(bannerTitle)

    local bannerHint = ISLabel:new(
        pad,
        y + 22,
        20,
        "Edit the on-screen RPG-style discovery banner position used for entering, leaving, and discovering faction bases.",
        0.72,
        0.72,
        0.72,
        1,
        UIFont.Small,
        true
    )
    panel:addChild(bannerHint)

    self.btnEditFactionBanner = ISButton:new(pad, y + 44, 180, 24, "Edit Banner Position", self, function()
        if DynamicTrading and DynamicTrading.FactionDiscoveryBannerEditor and DynamicTrading.FactionDiscoveryBannerEditor.Open then
            DynamicTrading.FactionDiscoveryBannerEditor.Open()
        end
    end)
    self.btnEditFactionBanner:initialise()
    panel:addChild(self.btnEditFactionBanner)
end

function DT_OptionsUI:onGeneralTick(index, selected)
    -- Map index back to setting
    local setting = DT_OptionsUI.config.generalSettings[index]
    if setting then
        -- Update Config Manager if key provided
        if setting.configKey then
            DT_ConfigManager.settings[setting.configKey] = selected
            DT_ConfigManager.save()
        end
        
        -- Execute callback if provided
        if setting.callback then
            setting.callback(selected)
        end
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

    local function AddSlider(label, categoryKey, exampleSound)
        -- 1. Label
        local lblObj = ISLabel:new(pad, y, 20, label, 1, 1, 1, 1, UIFont.Small, true)
        panel:addChild(lblObj)
        
        -- 2. Percent Label
        local currentRaw = DT_ConfigManager.getVolume(categoryKey)
        local currentVol = math.floor(currentRaw * 100)
        local valLabel = ISLabel:new(pad + 240, y + 2, 20, currentVol .. "%", 1, 1, 1, 1, UIFont.Small, true)
        panel:addChild(valLabel)
        
        -- 3. Slider
        local sliderX = pad + 80
        local slider = ISSliderPanel:new(sliderX, y, 150, 20, self, function(target, val)
             local snappedVal = math.floor((val / 10) + 0.5) * 10
             DT_ConfigManager.setVolume(categoryKey, snappedVal / 100)
             valLabel:setName(snappedVal .. "%")
        end)
        slider:initialise()
        slider.currentValue = currentVol
        slider:setValues(0, 100, 10, 10)
        panel:addChild(slider)

        -- 4. Test Button
        if exampleSound then
            local btnPlay = ISButton:new(sliderX + 160 + 40, y - 2, 30, 24, " > ", self, function(self)
                DT_AudioManager.PlaySound(exampleSound, false, 1.0)
            end)
            btnPlay:initialise()
            btnPlay.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
            panel:addChild(btnPlay)
        end
        
        y = y + 40
    end

    -- Always show master
    AddSlider("Master:", "Master", nil)

    -- Show registered categories
    for _, cat in ipairs(DT_OptionsUI.config.audioCategories) do
        AddSlider(cat.label, cat.configKey, cat.exampleSound)
    end
end

function DT_OptionsUI:createManualChildren(panel)
    local pad = 20
    local y = 20
    local manuals = DynamicTrading and DynamicTrading.Manuals and DynamicTrading.Manuals.GetOrderedLibraryManuals and DynamicTrading.Manuals.GetOrderedLibraryManuals() or {}
    local whatsNew = DynamicTrading and DynamicTrading.Manuals and DynamicTrading.Manuals.GetLatestWhatsNewManual and DynamicTrading.Manuals.GetLatestWhatsNewManual() or nil

    local lbl = ISLabel:new(pad, y, 20, "Game Manuals", 1, 1, 1, 1, UIFont.Medium, true)
    panel:addChild(lbl)
    y = y + 35

    local description = ISLabel:new(pad, y, 20, "Open the manual browser, jump to the latest update notes, or browse the manuals that match your active DT modules.", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    panel:addChild(description)
    y = y + 30

    if whatsNew then
        local openWhatsNew = ISButton:new(pad, y, 180, 28, "Open What's New", self, function()
            DynamicTrading.Manuals.OpenUpdates({ manualId = whatsNew.id, pageId = whatsNew.startPageId })
        end)
        openWhatsNew:initialise()
        panel:addChild(openWhatsNew)
        y = y + 40
    end

    local openLibrary = ISButton:new(pad, y, 180, 28, "Open Manual Library", self, function()
        DynamicTrading.Manuals.Open({ library = true })
    end)
    openLibrary:initialise()
    panel:addChild(openLibrary)
    y = y + 40

    local hasManuals = false
    for _, manual in ipairs(manuals) do
        if manual and manual.isWhatsNew ~= true then
            hasManuals = true
            local manualData = manual
            local btn = ISButton:new(pad, y, math.min(self.width - (pad * 3), 320), 26, manualData.title or manualData.id, self, function()
                DynamicTrading.Manuals.Open({ manualId = manualData.id })
            end)
            btn:initialise()
            panel:addChild(btn)
            y = y + 32
        end
    end

    if not hasManuals then
        local emptyLabel = ISLabel:new(pad, y, 20, "No manuals registered yet.", 0.7, 0.7, 0.7, 1, UIFont.Small, true)
        panel:addChild(emptyLabel)
    end
end

-- =============================================================================
-- WINDOW LOGIC
-- =============================================================================

function DT_OptionsUI:onResize()
    ISCollapsableWindow.onResize(self)
    local th = self:titleBarHeight()
    local w = self:getWidth()
    local h = self:getHeight()
    
    if self.tabs then
        self.tabs:setX(0)
        self.tabs:setY(th)
        self.tabs:setWidth(w)
        self.tabs:setHeight(h - th)
    end

    if self.pricingState then
        local tabsWidth = self.tabs and self.tabs.getWidth and self.tabs:getWidth() or (self.tabs and self.tabs.width) or w
        local tabsHeight = self.tabs and self.tabs.getHeight and self.tabs:getHeight() or (self.tabs and self.tabs.height) or (h - th)
        self.pricingState.panel:setWidth(tabsWidth)
        self.pricingState.panel:setHeight(tabsHeight)
        DT_PricingOptionsTab.OnResize(self)
    end
end

function DT_OptionsUI:close()
    if self.pricingState then
        DT_PricingOptionsTab.Destroy(self)
    end
    self:setVisible(false)
    self:removeFromUIManager()
    DT_OptionsUI.instance = nil
end

-- =============================================================================
-- REGISTRY METHODS
-- =============================================================================

function DT_OptionsUI.RegisterAudioCategory(label, configKey, exampleSound)
    if _audioKeys[configKey] then return end -- Skip duplicates
    table.insert(DT_OptionsUI.config.audioCategories, {
        label = label,
        configKey = configKey,
        exampleSound = exampleSound
    })
    _audioKeys[configKey] = true
end

function DT_OptionsUI.RegisterGeneralSetting(label, configKey, callback)
    if _generalKeys[configKey] then return end -- Skip duplicates
    table.insert(DT_OptionsUI.config.generalSettings, {
        label = label,
        configKey = configKey,
        callback = callback
    })
    _generalKeys[configKey] = true
end

function DT_OptionsUI.ToggleWindow()
    if DT_OptionsUI.instance then
        DT_OptionsUI.instance:close()
        return
    end

    local width = 980
    local height = 680
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
