-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI CORE
-- =============================================================================
-- Class declaration, constants, and layout construction.
-- =============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISPanel"
require "Utils/DT_StringUtils"
require "Utils/DT_CoreUtils"
require "DT/Common/Reputation/DT_Reputation"

DT_ConversationUI = DT_ConversationUI or ISCollapsableWindow:derive("DT_ConversationUI")
DT_ConversationUI.instance = nil

DT_ConversationUI.TEXT_DELAY = 30
DT_ConversationUI.MIN_BUBBLE_WIDTH = 100
DT_ConversationUI.MIN_WIDTH = 760
DT_ConversationUI.MIN_HEIGHT = 420
DT_ConversationUI.FOOTER_HEIGHT = 32

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

local function createTransparentPanel(x, y, width, height)
    local panel = ISPanel:new(x, y, width, height)
    panel:initialise()
    panel.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    panel.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    return panel
end

local function hideWindowButton(button)
    if type(button) ~= "table" then
        return
    end

    if button.setVisible then
        button:setVisible(false)
    end
    if button.setEnable then
        button:setEnable(false)
    end
    if button.setWidth then
        button:setWidth(0)
    end
    if button.setHeight then
        button:setHeight(0)
    end
    if button.setX then
        button:setX(-1000)
    end
    if button.setY then
        button:setY(-1000)
    end
end

function DT_ConversationUI:initialise()
    ISCollapsableWindow.initialise(self)

    self:setTitle("")
    self:setResizable(true)
    self.minimumWidth = DT_ConversationUI.MIN_WIDTH
    self.minimumHeight = DT_ConversationUI.MIN_HEIGHT

    self.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.borderColor = { r = 0, g = 0, b = 0, a = 0 }

    self.history = {}
    self.target = nil
    self.isRadio = true
    self.msgQueue = {}
    self.typingTick = 0
    self.interactionObj = nil
    self.rawOptions = {}
    self.baseOptions = {}
    self.currentBackAction = nil
    self.footerActionOverride = nil
    self.footerNavigationOption = nil
    self.pendingCloseAfterQueue = false
    self.pendingCloseDisplayTicks = nil
    self.pendingCloseCallback = nil
    self.pendingCloseFooterAction = nil
    self.headerNameText = "Unknown"
    self.headerRoleText = "Survivor"
    self.headerNameFont = UIFont.Medium
    self.headerRoleFont = UIFont.Small
    self.headerNameHeight = 26
    self.headerRoleHeight = 18
    self.headerInset = 24
    self.headerTopPad = 16
    self.headerRoleGap = 6
    self.visualAccentColor = { r = 0.80, g = 0.88, b = 0.76, a = 0.95 }
    self.visualBorderColor = { r = 0.44, g = 0.52, b = 0.44, a = 0.60 }
    self.visualNameColor = { r = 0.98, g = 0.98, b = 0.96, a = 1.0 }
    self.visualFactionColor = { r = 0.88, g = 0.93, b = 0.82, a = 1.0 }
    self.visualRoleColor = { r = 0.88, g = 0.90, b = 0.84, a = 1.0 }
    self.visualIsHostile = false
end

function DT_ConversationUI:getLayoutMetrics()
    local outerPad = 1
    local columnGap = clamp(math.floor(self.width * 0.012), 10, 20)
    local topPad = 1
    local bottomPad = 1

    local contentX = outerPad
    local contentY = topPad
    local contentW = math.max(100, self.width - (outerPad * 2))
    local contentH = math.max(100, self.height - contentY - bottomPad)

    local portraitW = clamp(math.floor(contentW * 0.37), 270, 520)
    local leftW = contentW - portraitW - columnGap
    if leftW < 340 then
        leftW = 340
        portraitW = math.max(220, contentW - leftW - columnGap)
    end

    local infoH = clamp(math.floor(contentH * 0.26), 156, 208)
    local optionH = clamp(math.floor(contentH * 0.34), 150, 240)
    local messageH = contentH - infoH - optionH - (columnGap * 2)

    if messageH < 120 then
        local deficit = 120 - messageH
        optionH = math.max(130, optionH - deficit)
        messageH = contentH - infoH - optionH - (columnGap * 2)
    end

    if messageH < 110 then
        local deficit = 110 - messageH
        infoH = math.max(102, infoH - deficit)
        messageH = contentH - infoH - optionH - (columnGap * 2)
    end

    return {
        outerPad = outerPad,
        columnGap = columnGap,
        topPad = topPad,
        bottomPad = bottomPad,
        contentX = contentX,
        contentY = contentY,
        contentW = contentW,
        contentH = contentH,
        leftW = leftW,
        portraitW = portraitW,
        infoH = infoH,
        messageH = math.max(110, messageH),
        optionH = optionH,
    }
end

function DT_ConversationUI:getChatBubbleMaxWidth()
    local chatWidth = self.chatList and self.chatList:getWidth() or 220
    return math.max(DT_ConversationUI.MIN_BUBBLE_WIDTH, math.floor((chatWidth - 26) * 0.82))
end

function DT_ConversationUI:updateHeaderMetrics()
    local width = self.infoPanel and self.infoPanel:getWidth() or 260
    local inset = clamp(math.floor(width * 0.06), 20, 36)
    local availableWidth = math.max(120, width - (inset * 2))
    local nameText = tostring(self.headerNameText or "Unknown")
    local roleText = tostring(self.headerRoleText or "Survivor")
    local tm = getTextManager()
    local nameFont = UIFont.Large
    local roleFont = UIFont.Medium

    if tm:MeasureStringX(nameFont, nameText) > availableWidth then
        nameFont = UIFont.Medium
    end
    if tm:MeasureStringX(nameFont, nameText) > availableWidth then
        nameFont = UIFont.Small
    end

    if tm:MeasureStringX(roleFont, roleText) > availableWidth then
        roleFont = UIFont.Small
    end
    if tm:MeasureStringX(roleFont, roleText) > availableWidth then
        roleFont = UIFont.NewSmall
    end

    self.headerNameFont = nameFont
    self.headerRoleFont = roleFont
    self.headerInset = inset
    self.headerTopPad = clamp(math.floor((self.infoPanel and self.infoPanel:getHeight() or 160) * 0.10), 14, 22)
    self.headerRoleGap = 6
    self.headerNameHeight = tm:getFontHeight(nameFont)
    self.headerRoleHeight = tm:getFontHeight(roleFont)
end

function DT_ConversationUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    hideWindowButton(self.closeButton)
    hideWindowButton(self.collapseButton)
    hideWindowButton(self.pinButton)
    hideWindowButton(self.infoButton)

    self.rootContent = createTransparentPanel(0, 0, 100, 100)
    self:addChild(self.rootContent)
    self.rootContent:backMost()

    self.infoPanel = createTransparentPanel(0, 0, 100, 100)
    self.rootContent:addChild(self.infoPanel)

    self.messagePanel = createTransparentPanel(0, 0, 100, 100)
    self.rootContent:addChild(self.messagePanel)

    self.optionPanel = createTransparentPanel(0, 0, 100, 100)
    self.rootContent:addChild(self.optionPanel)

    self.portraitContainer = createTransparentPanel(0, 0, 100, 100)
    self.rootContent:addChild(self.portraitContainer)

    self.portraitPanel = DT_NPCPortraitPanel:new(0, 0, 100, 100, {
        overlayStyle = "none",
        backgroundStyle = "none",
        viewportMode = "fill"
    })
    self.portraitPanel:initialise()
    self.portraitPanel:instantiate()
    self.portraitContainer:addChild(self.portraitPanel)

    self.lblName = ISLabel:new(0, 0, 24, "Unknown", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblName:setVisible(false)
    self.infoPanel:addChild(self.lblName)

    self.lblDesc = ISLabel:new(0, 0, 18, "Survivor", 0.92, 0.95, 0.84, 1, UIFont.Small, true)
    self.lblDesc:setVisible(false)
    self.infoPanel:addChild(self.lblDesc)

    self.lblFactionTitle = ISLabel:new(0, 0, 16, "FACTION", 0.68, 0.72, 0.76, 1, UIFont.Small, true)
    self.lblFactionTitle:setVisible(false)
    self.infoPanel:addChild(self.lblFactionTitle)

    self.lblFactionName = ISLabel:new(0, 0, 18, "Independent", 0.95, 0.95, 0.95, 1, UIFont.Small, true)
    self.lblFactionName:setVisible(false)
    self.infoPanel:addChild(self.lblFactionName)

    self.lblReputation = ISLabel:new(0, 0, 18, "Reputation: 0 (Neutral)", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    self.lblReputation:setVisible(false)
    self.infoPanel:addChild(self.lblReputation)

    self.lblWealth = ISLabel:new(0, 0, 18, "Wealth: 0$", 0.8, 1, 0.8, 1, UIFont.Small, true)
    self.lblWealth:setVisible(false)
    self.infoPanel:addChild(self.lblWealth)

    self.lblState = ISLabel:new(0, 0, 18, "Status: Stable", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    self.lblState:setVisible(false)
    self.infoPanel:addChild(self.lblState)

    self.chatList = ISScrollingListBox:new(0, 0, 100, 100)
    self.chatList:initialise()
    self.chatList.font = UIFont.NewSmall
    self.chatList.itemheight = 20
    self.chatList.drawBorder = false
    self.chatList.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.chatList.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.chatList.doDrawItem = self.drawLogItem
    self.messagePanel:addChild(self.chatList)

    self.optionList = ISScrollingListBox:new(0, 0, 100, 100)
    self.optionList:initialise()
    self.optionList.font = UIFont.NewSmall
    self.optionList.itemheight = 30
    self.optionList.drawBorder = false
    self.optionList.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.optionList.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.optionList.doDrawItem = self.drawOptionItem
    self.optionList.onMouseDown = self.onOptionListMouseDown
    self.optionPanel:addChild(self.optionList)

    self.footerPanel = createTransparentPanel(0, 0, 100, DT_ConversationUI.FOOTER_HEIGHT)
    self.optionPanel:addChild(self.footerPanel)

    self.navigationButton = ISButton:new(0, 0, 110, DT_ConversationUI.FOOTER_HEIGHT, "Leave", self, DT_ConversationUI.onFooterNavigationClick)
    self.navigationButton:initialise()
    self.navigationButton.backgroundColor = { r = 0.24, g = 0.14, b = 0.14, a = 0.92 }
    self.navigationButton.backgroundColorMouseOver = { r = 0.32, g = 0.18, b = 0.18, a = 0.96 }
    self.navigationButton.borderColor = { r = 0.88, g = 0.56, b = 0.44, a = 0.74 }
    self.footerPanel:addChild(self.navigationButton)

    self:updateHeaderMetrics()
    self:relayout()
end

function DT_ConversationUI:relayout()
    if not self.rootContent then
        return
    end

    local metrics = self:getLayoutMetrics()
    self.layoutMetrics = metrics
    self:updateHeaderMetrics()

    local leftX = 0
    local portraitX = metrics.leftW + metrics.columnGap
    local infoInset = self.headerInset or clamp(math.floor(metrics.leftW * 0.06), 20, 36)
    local headerTop = self.headerTopPad or 16
    local headerRoleGap = self.headerRoleGap or 6
    local factionBaseY = headerTop + self.headerNameHeight + headerRoleGap + self.headerRoleHeight + 14

    self.rootContent:setX(metrics.contentX)
    self.rootContent:setY(metrics.contentY)
    self.rootContent:setWidth(metrics.contentW)
    self.rootContent:setHeight(metrics.contentH)

    self.infoPanel:setX(leftX)
    self.infoPanel:setY(0)
    self.infoPanel:setWidth(metrics.leftW)
    self.infoPanel:setHeight(metrics.infoH)

    self.messagePanel:setX(leftX)
    self.messagePanel:setY(metrics.infoH + metrics.columnGap)
    self.messagePanel:setWidth(metrics.leftW)
    self.messagePanel:setHeight(metrics.messageH)

    self.optionPanel:setX(leftX)
    self.optionPanel:setY(metrics.infoH + metrics.messageH + (metrics.columnGap * 2))
    self.optionPanel:setWidth(metrics.leftW)
    self.optionPanel:setHeight(metrics.optionH)

    self.portraitContainer:setX(portraitX)
    self.portraitContainer:setY(0)
    self.portraitContainer:setWidth(metrics.portraitW)
    self.portraitContainer:setHeight(metrics.contentH)

    self.portraitPanel:setPortraitBounds(0, 0, metrics.portraitW, metrics.contentH)

    self.chatList:setX(0)
    self.chatList:setY(0)
    self.chatList:setWidth(metrics.leftW)
    self.chatList:setHeight(metrics.messageH)
    if self.chatList.vscroll then
        self.chatList.vscroll:setHeight(metrics.messageH)
        self.chatList.vscroll:setX(metrics.leftW - 13)
    end

    self.optionList:setX(0)
    self.optionList:setY(0)
    self.optionList:setWidth(metrics.leftW)
    self.optionList:setHeight(math.max(80, metrics.optionH - DT_ConversationUI.FOOTER_HEIGHT - 8))
    if self.optionList.vscroll then
        self.optionList.vscroll:setHeight(self.optionList:getHeight())
        self.optionList.vscroll:setX(metrics.leftW - 13)
    end

    if self.footerPanel then
        local footerY = math.max(0, metrics.optionH - DT_ConversationUI.FOOTER_HEIGHT)
        self.footerPanel:setX(0)
        self.footerPanel:setY(footerY)
        self.footerPanel:setWidth(metrics.leftW)
        self.footerPanel:setHeight(DT_ConversationUI.FOOTER_HEIGHT)

        if self.navigationButton then
            self.navigationButton:setX(0)
            self.navigationButton:setY(0)
            self.navigationButton:setWidth(metrics.leftW)
            self.navigationButton:setHeight(DT_ConversationUI.FOOTER_HEIGHT)
        end
    end

    if self.lblName then
        self.lblName:setX(infoInset)
        self.lblName:setY(headerTop)
    end
    if self.lblDesc then
        self.lblDesc:setX(infoInset)
        self.lblDesc:setY(headerTop + self.headerNameHeight + headerRoleGap)
    end
    if self.lblFactionTitle then
        self.lblFactionTitle:setX(infoInset)
        self.lblFactionTitle:setY(factionBaseY)
    end
    if self.lblFactionName then
        self.lblFactionName:setX(infoInset)
        self.lblFactionName:setY(factionBaseY + 14)
    end
    if self.lblReputation then
        self.lblReputation:setX(infoInset)
        self.lblReputation:setY(factionBaseY + 30)
    end
    if self.lblWealth then
        self.lblWealth:setX(infoInset)
        self.lblWealth:setY(factionBaseY + 46)
    end
    if self.lblState then
        self.lblState:setX(infoInset)
        self.lblState:setY(factionBaseY + 62)
    end

    if self.rebuildChatLayout then
        self:rebuildChatLayout()
    end
    if self.refreshOptionLayout then
        self:refreshOptionLayout()
    end
    if self.resizeWidget then
        self.resizeWidget:setVisible(self.resizable)
        self.resizeWidget:bringToTop()
    end
    if self.resizeWidget2 then
        self.resizeWidget2:setVisible(self.resizable)
        self.resizeWidget2:bringToTop()
    end
    if self.updateNavigationButtons then
        self:updateNavigationButtons()
    end
end

function DT_ConversationUI:onResize()
    ISCollapsableWindow.onResize(self)

    if self.width < self.minimumWidth then
        self:setWidth(self.minimumWidth)
    end
    if self.height < self.minimumHeight then
        self:setHeight(self.minimumHeight)
    end

    self:relayout()
end

function DT_ConversationUI:onFooterNavigationClick()
    if self.activateFooterNavigation then
        self:activateFooterNavigation()
    end
end
