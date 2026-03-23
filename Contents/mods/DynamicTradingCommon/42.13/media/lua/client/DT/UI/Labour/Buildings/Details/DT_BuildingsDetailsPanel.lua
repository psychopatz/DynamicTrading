require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"
require "DT/UI/Labour/Buildings/Details/DT_BuildingsDetailsFormatter"

DT_BuildingsDetailsPanel = ISPanel:derive("DT_BuildingsDetailsPanel")

function DT_BuildingsDetailsPanel:initialise()
    ISPanel.initialise(self)
end

function DT_BuildingsDetailsPanel:createChildren()
    ISPanel.createChildren(self)

    self.textPanel = ISRichTextPanel:new(8, 8, self.width - 16, self.height - 50)
    self.textPanel:initialise()
    self.textPanel.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.textPanel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.textPanel.clip = true
    self.textPanel.autosetheight = false
    self.textPanel:addScrollBars()
    self:addChild(self.textPanel)

    self.btnUpgrade = ISButton:new(8, self.height - 34, 100, 24, "Upgrade", self, self.onUpgradeClicked)
    self.btnUpgrade:initialise()
    self.btnUpgrade:setAnchorBottom(true)
    self:addChild(self.btnUpgrade)
end

function DT_BuildingsDetailsPanel:setPlot(plot)
    self.plot = plot
    if self.textPanel then
        self.textPanel:setText(DT_BuildingsDetailsFormatter.BuildPlotText(plot))
        self.textPanel:paginate()
    end
    if self.btnUpgrade then
        local canUpgrade = plot and plot.building and plot.building.upgradePreview and plot.building.upgradePreview.available == true
        self.btnUpgrade:setEnable(canUpgrade == true)
    end
end

function DT_BuildingsDetailsPanel:onUpgradeClicked()
    if self.onUpgradeCallback and self.plot and self.plot.building then
        self.onUpgradeCallback(self.plot)
    end
end

function DT_BuildingsDetailsPanel:new(x, y, width, height, onUpgradeCallback)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0.2 }
    o.borderColor = { r = 1, g = 1, b = 1, a = 0.08 }
    o.onUpgradeCallback = onUpgradeCallback
    return o
end

return DT_BuildingsDetailsPanel
