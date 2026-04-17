-- =============================================================================
-- DYNAMIC TRADING V1: SIGNAL PANEL - CHILDREN
-- =============================================================================

V1_SignalPanel_Children_logic = {}

function DT_SignalPanel:createChildren()
    ISPanel.createChildren(self)

    self.btnScan = ISButton:new(0, 0, 100, 25, "SCAN FREQUENCIES", self, self.onScanClick)
    self.btnScan:initialise()
    self.btnScan.backgroundColor = { r = 0.1, g = 0.3, b = 0.1, a = 1.0 }
    self.btnScan.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self:addChild(self.btnScan)

    self.btnInfo = ISButton:new(0, 0, 100, 25, "VIEW MARKET INFO", self, self.onInfoClick)
    self.btnInfo:initialise()
    self.btnInfo.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self.btnInfo.backgroundColor = { r = 0.2, g = 0.2, b = 0.4, a = 1.0 }
    self:addChild(self.btnInfo)

    self.btnContacts = ISButton:new(0, 0, 100, 25, "CONTACTS", self, self.onContactsClick)
    self.btnContacts:initialise()
    self.btnContacts.borderColor = { r = 1, g = 1, b = 1, a = 0.5 }
    self.btnContacts.backgroundColor = { r = 0.12, g = 0.24, b = 0.45, a = 1.0 }
    self:addChild(self.btnContacts)

    local btnSize = 18
    self.btnOptions = ISButton:new(0, 0, btnSize, btnSize, "", self, self.onOptionsClick)
    self.btnOptions:initialise()
    self.btnOptions.borderColor = { r = 1, g = 1, b = 1, a = 0.2 }
    self.btnOptions.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.btnOptions:setImage(getTexture("media/ui/inventoryPanes/Button_Settings.png"))
    self:addChild(self.btnOptions)

    self:onResize()
end
