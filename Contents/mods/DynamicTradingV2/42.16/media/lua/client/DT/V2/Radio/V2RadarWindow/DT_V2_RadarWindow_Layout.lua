-- ==============================================================================
-- DT_V2_RadarWindow_Layout.lua
-- Child panel creation and initial layout for the Trader Radar window.
-- ==============================================================================

function DT_V2_RadarWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local w = self.width

    local headerHeight = 85
    self.headerPanel = DT_V2_RadarHeaderPanel:new(0, th, w, headerHeight)
    self.headerPanel:initialise()
    self.headerPanel:instantiate()
    self.headerPanel:setAnchorRight(true)
    self:addChild(self.headerPanel)

    local listY = th + headerHeight
    local footerHeight = 40
    local listHeight = self.height - listY - footerHeight

    self.listPanel = DT_V2_RadarListPanel:new(10, listY, w - 20, listHeight)
    self.listPanel:initialise()
    self.listPanel:instantiate()
    self.listPanel:setAnchorRight(true)
    self.listPanel:setAnchorBottom(true)
    self:addChild(self.listPanel)

    self.listPanel:setLayoutMode(self.currentCategory == "Location" and "Location" or "Standard")

    self.actionPanel = DT_V2_RadarActionPanel:new(0, self.height - footerHeight, w, 30)
    self.actionPanel:initialise()
    self.actionPanel:instantiate()
    self.actionPanel:setAnchorRight(true)
    self.actionPanel:setAnchorTop(false)
    self.actionPanel:setAnchorBottom(true)
    self:addChild(self.actionPanel)

    self:refresh()

    if isClient() then
        DT_V2_RadarManager.RequestRoster()
    end
end
