-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI CORE
-- =============================================================================
-- Class declaration, constants, and layout construction.
-- =============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "Utils/DT_StringUtils"
require "Utils/DT_CoreUtils"
require "DT/Common/Reputation/DT_Reputation"

DT_ConversationUI = DT_ConversationUI or ISCollapsableWindow:derive("DT_ConversationUI")
DT_ConversationUI.instance = nil

DT_ConversationUI.TEXT_DELAY = 30
DT_ConversationUI.MIN_BUBBLE_WIDTH = 100

function DT_ConversationUI:initialise()
    ISCollapsableWindow.initialise(self)

    self:setResizable(false)

    self.history = {}
    self.target = nil
    self.isRadio = true
    self.msgQueue = {}
    self.typingTick = 0
    self.interactionObj = nil
end

function DT_ConversationUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local leftColW = 200
    local pad = 10

    local rightX = leftColW + (pad * 2)
    local rightW = self.width - rightX - pad

    self.closeButton = ISButton:new(self.width - 18, 2, 13, 13, "X", self, self.close)
    self.closeButton:initialise()
    self.closeButton.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    self.closeButton.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.closeButton.textColor = { r = 1, g = 1, b = 1, a = 1 }
    self:addChild(self.closeButton)

    self.imageY = th + pad
    self.imageSize = leftColW

    self.lblName = ISLabel:new(leftColW / 2 + pad, self.imageY + self.imageSize + 10, 25, "Unknown", 1, 1, 1, 1, UIFont.Medium, true)
    self.lblName.center = true
    self:addChild(self.lblName)

    self.lblDesc = ISLabel:new(leftColW / 2 + pad, self.lblName:getY() + 25, 18, "Survivor", 1.0, 1.0, 0.8, 1, UIFont.Small, true)
    self.lblDesc.center = true
    self:addChild(self.lblDesc)

    local factionY = self.lblDesc:getY() + 35
    self.lblFactionTitle = ISLabel:new(leftColW / 2 + pad, factionY, 18, "FACTION", 0.7, 0.7, 0.8, 1, UIFont.Small, true)
    self.lblFactionTitle.center = true
    self.lblFactionTitle:setVisible(false)
    self:addChild(self.lblFactionTitle)

    self.lblFactionName = ISLabel:new(leftColW / 2 + pad, factionY + 15, 18, "Independent", 1, 1, 1, 1, UIFont.Small, true)
    self.lblFactionName.center = true
    self.lblFactionName:setVisible(false)
    self:addChild(self.lblFactionName)

    self.lblReputation = ISLabel:new(leftColW / 2 + pad, self.lblFactionName:getY() + 20, 18, "Reputation: 0 (Neutral)", 1, 1, 1, 1, UIFont.Small, true)
    self.lblReputation.center = true
    self.lblReputation:setVisible(false)
    self:addChild(self.lblReputation)

    self.lblWealth = ISLabel:new(leftColW / 2 + pad, self.lblReputation:getY() + 20, 18, "Wealth: 0$", 0.8, 1, 0.8, 1, UIFont.Small, true)
    self.lblWealth.center = true
    self.lblWealth:setVisible(false)
    self:addChild(self.lblWealth)

    self.lblState = ISLabel:new(leftColW / 2 + pad, self.lblWealth:getY() + 20, 18, "Status: Stable", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    self.lblState.center = true
    self.lblState:setVisible(false)
    self:addChild(self.lblState)

    local optionHeight = 180
    local chatH = self.height - th - pad - optionHeight - 15
    local optionY = th + pad + chatH + 10

    self.optionList = ISScrollingListBox:new(rightX, optionY, rightW, optionHeight)
    self.optionList:initialise()
    self.optionList.font = UIFont.NewSmall
    self.optionList.itemheight = 30
    self.optionList.drawBorder = false
    self.optionList.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    self.optionList.doDrawItem = self.drawOptionItem
    self.optionList.onMouseDown = self.onOptionListMouseDown
    self:addChild(self.optionList)

    self.chatList = ISScrollingListBox:new(rightX, th + pad, rightW, chatH)
    self.chatList:initialise()
    self.chatList.font = UIFont.NewSmall
    self.chatList.itemheight = 20
    self.chatList.drawBorder = true
    self.chatList.borderColor = { r = 0.4, g = 0.4, b = 0.4, a = 1 }
    self.chatList.backgroundColor = { r = 0.0, g = 0.0, b = 0.0, a = 0.9 }
    self.chatList.doDrawItem = self.drawLogItem
    self:addChild(self.chatList)
end
