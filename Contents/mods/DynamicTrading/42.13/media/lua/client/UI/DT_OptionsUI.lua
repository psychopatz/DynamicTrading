-- =============================================================================
-- DT_OptionsUI
-- Options/Configuration Window for Dynamic Trading
-- =============================================================================

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISSliderPanel"
require "Utils/DT_ConfigManager"
require "Utils/DT_AudioManager"

print("[DT_OptionsUI] Defining class...")
DT_OptionsUI = ISPanel:derive("DT_OptionsUI")
DT_OptionsUI.instance = nil

function DT_OptionsUI:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_OptionsUI:createChildren()
    local btnWid = 100
    local btnHgt = 25
    local pad = 10
    local y = 40 -- Start lower to make room for title
    
    -- Title
    local titleLabel = ISLabel:new((self.width - getTextManager():MeasureStringX(UIFont.Medium, "AUDIO CONFIGURATION")) / 2, 10, 25, "AUDIO CONFIGURATION", 1, 1, 1, 1, UIFont.Medium, true)
    self:addChild(titleLabel)

    self.sliders = {}

    -- Helper to create sliders
    local function AddSlider(label, category, exampleSound)
        -- Label
        local lbl = ISLabel:new(pad, y, 20, label, 1, 1, 1, 1, UIFont.Small, true)
        self:addChild(lbl)
        
        -- Slider
        local sliderX = pad + 100
        local slider = ISSliderPanel:new(sliderX, y, 150, 20, self, function(target, val)
             -- Snap to 10s to ensure "tenths digit" logic
             local snappedVal = math.floor((val / 10) + 0.5) * 10
             DT_ConfigManager.setVolume(category, snappedVal / 100)
        end)
        slider:initialise()
        slider.currentValue = DT_ConfigManager.getVolume(category) * 100
        slider:setValues(0, 100, 10, 10)
        self:addChild(slider)
        
        -- Store for rendering text
        table.insert(self.sliders, {
            slider = slider,
            category = category,
            y = y
        })

        -- Play Preview Button
        local btnPlay = ISButton:new(sliderX + 160 + 40, y - 2, 30, 24, " > ", self, function(self)
            DT_AudioManager.PlaySound(exampleSound, false, 1.0)
        end)
        btnPlay:initialise()
        btnPlay.backgroundColor = {r=0.2, g=0.2, b=0.2, a=1.0}
        btnPlay.tooltip = "Test Volume"
        self:addChild(btnPlay)
        
        y = y + 35
    end

    AddSlider("Master:", "Master", "DT_Cashier") -- Use Cashier as master test? Or random.
    AddSlider("Radio:", "Radio", "DT_RadioRandom")
    AddSlider("Wallet:", "Wallet", "DT_CasinoRandom")
    AddSlider("Trade:", "Trade", "DT_Cashier")

    y = y + 10

    -- Buttons (Close)
    local startX = (self.width - btnWid) / 2
    
    self.btnClose = ISButton:new(startX, y, btnWid, btnHgt, "CLOSE", self, self.onClose)
    self.btnClose:initialise()
    self.btnClose.backgroundColor = {r=0.3, g=0.1, b=0.1, a=1.0}
    self:addChild(self.btnClose)
    
    self:setHeight(y + 40)
end

function DT_OptionsUI:prerender()
    -- Draw background and border
    ISPanel.prerender(self)
    self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
    self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

    -- Draw dynamic slider values to avoid ghosting (ISLabel update lag/artifacts)
    if self.sliders then
        for _, s in ipairs(self.sliders) do
            local val = math.floor(s.slider.currentValue)
            local text = val .. "%"
            -- Draw text next to slider (slider is at x=pad+100, width=150 -> right end is ~260)
            -- We put the text at x=270
            self:drawText(text, 270, s.y + 2, 1, 1, 1, 1, UIFont.Small)
        end
    end
end

function DT_OptionsUI:onSave()
    self:close()
end

function DT_OptionsUI:onClose()
    self:close()
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

    local width = 380 -- Slightly wider for play button
    local height = 250 -- Will be auto-adjusted
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    local ui = DT_OptionsUI:new(x, y, width, height)
    ui.backgroundColor = {r=0, g=0, b=0, a=0.95} -- Opaque background
    ui.borderColor = {r=1, g=1, b=1, a=0.5}
    ui:initialise()
    ui:addToUIManager()
    DT_OptionsUI.instance = ui
end

function DT_OptionsUI:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.moveWithMouse = true -- Allow dragging
    return o
end
