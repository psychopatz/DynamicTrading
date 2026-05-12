require "ISUI/ISPanel"
require "ISUI/ISButton"
require "DT/Common/UI/Contacts/ContactsWindow/DT_ContactsWindow"
pcall(require, "DT/Common/UI/ConversationUI/DT_ConversationQuestOffer")

DT_RadioScannerActionPanel = ISPanel:derive("DT_RadioScannerActionPanel")

local BUTTON_WIDTH = 94
local BUTTON_HEIGHT = 25
local BUTTON_SPACING = 10
local BUTTON_ROW_SPACING = 6

local function focusObjectiveQuest(data)
    if type(data) ~= "table" or tostring(data.entryKind or "") ~= "activeQuest" then
        return false
    end

    local questID = data.questID and tostring(data.questID) or ""
    if questID == "" or not (DynamicObjectives and DynamicObjectives.Quests) then
        return false
    end

    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if not player then
        return false
    end

    if DynamicObjectives.Quests.FocusQuest then
        return DynamicObjectives.Quests.FocusQuest(player, questID, true) == true
    end

    local tracked = DynamicObjectives.Quests.SetTrackedQuest and DynamicObjectives.Quests.SetTrackedQuest(player, questID) == true
    local located = DynamicObjectives.Quests.SetLocatedQuest and DynamicObjectives.Quests.SetLocatedQuest(player, questID) == true
    return tracked == true and located == true
end

local function layoutButtons(panel)
    if not panel.parent then
        return
    end

    local panelWidth = panel:getWidth()
    local dynamicButtonWidth = math.floor((panelWidth - BUTTON_SPACING) / 2)
    local startX = 0
    local panelHeight = panel:getHeight()
    local totalHeight = (BUTTON_HEIGHT * 2) + BUTTON_ROW_SPACING
    local startY = math.max(0, math.floor((panelHeight - totalHeight) / 2))

    local function place(button, col, row)
        if not button then
            return
        end

        button:setX(startX + ((col - 1) * (dynamicButtonWidth + BUTTON_SPACING)))
        button:setY(startY + ((row - 1) * (BUTTON_HEIGHT + BUTTON_ROW_SPACING)))
        button:setWidth(dynamicButtonWidth)
        button:setHeight(BUTTON_HEIGHT)
    end

    place(panel.btnLock, 1, 1)
    place(panel.btnLocate, 2, 1)
    place(panel.btnRefresh, 1, 2)
    place(panel.btnContacts, 2, 2)
end

local function openRadioQuestConversation(data)
    if type(data) ~= "table" or tostring(data.entryKind or "") ~= "availableQuest" then
        return false
    end
    if not (DT_ConversationQuestOffer and DT_ConversationQuestOffer.OpenDebugConversation) then
        return false
    end

    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if not player then
        return false
    end

    local traderContext = type(data.traderContext) == "table" and data.traderContext or {
        traderID = data.uuid,
        id = data.uuid,
        displayName = data.name or "Radio Contact",
        name = data.name or "Radio Contact",
        archetype = data.archetype or "General",
        currentState = "Trading",
        status = "Trading",
    }

    DT_ConversationQuestOffer.OpenDebugConversation(player, {
        overrideTraderContext = traderContext,
        preselectedBlueprintId = data.offerBlueprintId,
        traderProxy = {
            id = traderContext.traderID or traderContext.id or data.uuid,
            traderID = traderContext.traderID or traderContext.id or data.uuid,
            uuid = traderContext.traderID or traderContext.id or data.uuid,
            name = traderContext.displayName or traderContext.name or data.name or "Radio Contact",
            archetype = traderContext.archetype or data.archetype or "General",
            gender = data.gender or "Unknown",
            identitySeed = tonumber(data.identitySeed) or 1,
            factionID = traderContext.factionID or data.faction,
        },
        initialGreeting = "Radio link established.",
    })
    return true
end

function DT_RadioScannerActionPanel:initialise()
    ISPanel.initialise(self)
end

function DT_RadioScannerActionPanel:createChildren()
    ISPanel.createChildren(self)

    self.btnRefresh = ISButton:new(BUTTON_SPACING, 0, BUTTON_WIDTH, BUTTON_HEIGHT, "REFRESH", self, self.onRefresh)
    self.btnRefresh:initialise()
    self.btnRefresh:setAnchorLeft(true)
    self.btnRefresh:setAnchorTop(false)
    self.btnRefresh:setAnchorBottom(true)
    self:addChild(self.btnRefresh)

    self.btnContacts = ISButton:new(math.floor((self.width - BUTTON_WIDTH) / 2), 0, BUTTON_WIDTH, BUTTON_HEIGHT, "CONTACTS", self, self.onContacts)
    self.btnContacts:initialise()
    self.btnContacts.backgroundColor = { r = 0.12, g = 0.24, b = 0.45, a = 1 }
    self.btnContacts:setAnchorLeft(false)
    self.btnContacts:setAnchorRight(false)
    self.btnContacts:setAnchorTop(false)
    self.btnContacts:setAnchorBottom(true)
    self:addChild(self.btnContacts)

    self.btnLock = ISButton:new(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT, "LOCK", self, self.onLock)
    self.btnLock:initialise()
    self.btnLock.backgroundColor = { r = 0.45, g = 0.3, b = 0.1, a = 1 }
    self.btnLock.enable = false
    self.btnLock:setAnchorTop(false)
    self.btnLock:setAnchorBottom(true)
    self:addChild(self.btnLock)

    self.btnLocate = ISButton:new(self.width - BUTTON_WIDTH - BUTTON_SPACING, 0, BUTTON_WIDTH, BUTTON_HEIGHT, "LOCATE", self, self.onLocate)
    self.btnLocate:initialise()
    self.btnLocate.backgroundColor = { r = 0, g = 0.5, b = 0, a = 1 }
    self.btnLocate.enable = false
    self.btnLocate:setAnchorLeft(false)
    self.btnLocate:setAnchorRight(true)
    self.btnLocate:setAnchorTop(false)
    self.btnLocate:setAnchorBottom(true)
    self:addChild(self.btnLocate)

    layoutButtons(self)
end

function DT_RadioScannerActionPanel:updateButtonState(selectedUUID, selectedData)
    if not self.parent then
        return
    end

    if self.parent.trackingUUID and self.parent.trackingUUID == selectedUUID then
        self.btnLocate.title = "STOP"
        self.btnLocate.backgroundColor = { r = 0.6, g = 0.1, b = 0.1, a = 1 }
    else
        self.btnLocate.title = "FOLLOW"
        self.btnLocate.backgroundColor = { r = 0, g = 0.5, b = 0, a = 1 }
    end

    if self.btnLock then
        local canLock = selectedData and selectedData.canLock == true
        local isLocked = selectedData and selectedData.locked == true
        self.btnLock.enable = canLock == true
        self.btnLock.title = isLocked and "UNLOCK" or "LOCK"
        self.btnLock.backgroundColor = isLocked
            and { r = 0.62, g = 0.26, b = 0.12, a = 1 }
            or { r = 0.45, g = 0.3, b = 0.1, a = 1 }
    end

    if self.btnContacts then
        local isQuestOffer = selectedData and tostring(selectedData.entryKind or "") == "availableQuest"
        self.btnContacts.title = isQuestOffer and "TALK" or "CONTACTS"
        self.btnContacts.backgroundColor = isQuestOffer
            and { r = 0.12, g = 0.36, b = 0.26, a = 1 }
            or { r = 0.12, g = 0.24, b = 0.45, a = 1 }
    end
end

function DT_RadioScannerActionPanel:updateSelectionState(selectedData)
    local selectedUUID = selectedData and selectedData.uuid or nil
    self.btnLocate.enable = selectedUUID ~= nil
    self:updateButtonState(selectedUUID, selectedData)
end

function DT_RadioScannerActionPanel:onRefresh()
    if self.parent and self.parent.refresh then
        self.parent:refresh()
    end
end

function DT_RadioScannerActionPanel:onLocate()
    if not self.parent or not self.parent.listPanel then
        return
    end

    local listbox = self.parent.listPanel.listbox
    local item = listbox.items[listbox.selected]
    if not item or not item.item then
        return
    end

    local data = item.item
    if focusObjectiveQuest(data) then
        if self.parent.stopTracking then
            self.parent:stopTracking()
        end
        if self.parent.refresh then
            self.parent:refresh()
        end
        self:updateButtonState(data.uuid, data)
        return
    end

    local uuid = data.uuid
    if self.parent.trackingUUID == uuid then
        self.parent:stopTracking()
    else
        self.parent:startTracking(uuid, data.name, data)
    end

    self:updateButtonState(uuid, data)
end

function DT_RadioScannerActionPanel:onLock()
    if not self.parent or not self.parent.listPanel or not DT_RadioScannerManager or not DT_RadioScannerManager.ToggleLock then
        return
    end

    local listbox = self.parent.listPanel.listbox
    local item = listbox.items[listbox.selected]
    if not item or not item.item or item.item.canLock ~= true then
        return
    end

    DT_RadioScannerManager.ToggleLock(item.item.uuid)
    if self.parent.refresh then
        self.parent:refresh()
    end
end

function DT_RadioScannerActionPanel:onContacts()
    local selectedUUID = nil
    local selectedData = nil
    if self.parent and self.parent.listPanel and self.parent.listPanel.listbox then
        local listbox = self.parent.listPanel.listbox
        local item = listbox.items[listbox.selected]
        if item and item.item then
            selectedUUID = item.item.uuid
            selectedData = item.item
        end
    end

    if openRadioQuestConversation(selectedData) then
        return
    end

    DT_ContactsWindow.Open({ selectTraderID = selectedUUID })
end

function DT_RadioScannerActionPanel:onResize()
    ISPanel.onResize(self)
    layoutButtons(self)
end

function DT_RadioScannerActionPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    return o
end
