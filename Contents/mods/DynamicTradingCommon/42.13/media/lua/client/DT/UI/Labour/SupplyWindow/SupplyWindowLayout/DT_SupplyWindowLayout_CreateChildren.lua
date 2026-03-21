DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal

function DT_SupplyWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    local layout = Internal.getSupplyWindowLayoutMetrics(self)

    self.playerSearch = ISTextEntryBox:new("", layout.leftX, layout.searchY, layout.leftWidth, layout.searchH)
    self.playerSearch:initialise()
    self:addChild(self.playerSearch)

    self.workerSearch = ISTextEntryBox:new("", layout.rightX, layout.searchY, layout.rightWidth, layout.searchH)
    self.workerSearch:initialise()
    self:addChild(self.workerSearch)

    self.btnTabProvisions = ISButton:new(layout.rightX, layout.tabsY, 80, layout.tabH, "Provisions", self, self.onSelectProvisionsTab)
    self.btnTabProvisions:initialise()
    self:addChild(self.btnTabProvisions)

    self.btnTabOutput = ISButton:new(layout.rightX, layout.tabsY, 80, layout.tabH, "Merchandise", self, self.onSelectOutputTab)
    self.btnTabOutput:initialise()
    self:addChild(self.btnTabOutput)

    self.btnTabEquipment = ISButton:new(layout.rightX, layout.tabsY, 80, layout.tabH, "Equipment", self, self.onSelectEquipmentTab)
    self.btnTabEquipment:initialise()
    self:addChild(self.btnTabEquipment)

    self.btnRefresh = ISButton:new(layout.controlX, layout.searchY, layout.controlWidth, layout.searchH, "Sync", self, self.onRefresh)
    self.btnRefresh:initialise()
    self:addChild(self.btnRefresh)

    self.btnDepositSelected = ISButton:new(layout.controlX, layout.centerButtonsY, layout.controlWidth, 32, ">", self, self.onDepositSelected)
    self.btnDepositSelected:initialise()
    self:addChild(self.btnDepositSelected)

    self.btnDepositVisible = ISButton:new(layout.controlX, layout.centerButtonsY + 40, layout.controlWidth, 32, ">>", self, self.onDepositVisible)
    self.btnDepositVisible:initialise()
    self:addChild(self.btnDepositVisible)

    self.playerList = Internal.LabourSupplyList:new(layout.leftX, layout.contentY, layout.leftWidth, layout.listH, "player")
    self.playerList:initialise()
    self.playerList:instantiate()
    self.playerList.target = self
    self.playerList.onmousedown = DT_SupplyWindow.onPlayerListMouseDown
    self.playerList.drawBorder = true
    self:addChild(self.playerList)

    self.workerList = Internal.LabourSupplyList:new(layout.rightX, layout.contentY, layout.rightWidth, layout.listH, "worker")
    self.workerList:initialise()
    self.workerList:instantiate()
    self.workerList.target = self
    self.workerList.onmousedown = DT_SupplyWindow.onWorkerListMouseDown
    self.workerList.drawBorder = true
    self:addChild(self.workerList)

    self.detailText = ISRichTextPanel:new(layout.pad, layout.detailY, self.width - (layout.pad * 2), layout.detailH)
    self.detailText:initialise()
    self.detailText.backgroundColor = { r = 0, g = 0, b = 0, a = 0.26 }
    self.detailText.borderColor = { r = 1, g = 1, b = 1, a = 0.12 }
    self.detailText:addScrollBars()
    self:addChild(self.detailText)

    self:relayout()
    self:refreshTabButtons()
    self:updateTransferControls()
    self:updateItemDetail(nil, nil)
end
