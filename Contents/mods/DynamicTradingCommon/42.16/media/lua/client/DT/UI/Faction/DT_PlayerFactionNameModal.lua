require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTextEntryBox"

DT_PlayerFactionNameModal = ISCollapsableWindow:derive("DT_PlayerFactionNameModal")
DT_PlayerFactionNameModal.instance = nil

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function trimName(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

function DT_PlayerFactionNameModal:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
end

function DT_PlayerFactionNameModal:createChildren()
    ISCollapsableWindow.createChildren(self)

    local pad = 10
    local th = self:titleBarHeight()
    local contentY = th + pad
    local contentWidth = self.width - (pad * 2)

    self.promptLabel = ISLabel:new(pad, contentY, 20, tostring(self.promptText or T("DTCommon_UI_Faction_NamePrompt", nil, "Enter a faction name.")), 1, 1, 1, 1, UIFont.Small, true)
    self.promptLabel:initialise()
    self.promptLabel:instantiate()
    self:addChild(self.promptLabel)

    self.nameEntry = ISTextEntryBox:new(tostring(self.defaultValue or ""), pad, contentY + 28, contentWidth, 24)
    self.nameEntry:initialise()
    self.nameEntry:instantiate()
    self:addChild(self.nameEntry)

    self.hintLabel = ISLabel:new(pad, contentY + 60, 20, T("DTCommon_UI_Faction_NameHint", nil, "1-32 characters. Unique display name."), 0.75, 0.75, 0.75, 1, UIFont.Small, true)
    self.hintLabel:initialise()
    self.hintLabel:instantiate()
    self:addChild(self.hintLabel)

    self.btnConfirm = ISButton:new(pad, self.height - 38, 100, 24, tostring(self.confirmLabel or T("DTCommon_UI_Faction_Create", nil, "Create")), self, self.onConfirm)
    self.btnConfirm:initialise()
    self.btnConfirm:instantiate()
    self:addChild(self.btnConfirm)

    self.btnCancel = ISButton:new(self.width - 110, self.height - 38, 100, 24, T("DTCommon_UI_Faction_Cancel", nil, "Cancel"), self, self.onCancel)
    self.btnCancel:initialise()
    self.btnCancel:instantiate()
    self:addChild(self.btnCancel)
end

function DT_PlayerFactionNameModal:onConfirm()
    local name = trimName(self.nameEntry and self.nameEntry:getText() or "")
    if self.onConfirmCallback then
        self.onConfirmCallback(name)
    end
    self:close()
end

function DT_PlayerFactionNameModal:onCancel()
    self:close()
end

function DT_PlayerFactionNameModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_PlayerFactionNameModal.Open(args)
    args = args or {}

    local modal = DT_PlayerFactionNameModal.instance
    if not modal then
        local width = 360
        local height = 150
        local x = (getCore():getScreenWidth() - width) / 2
        local y = (getCore():getScreenHeight() - height) / 2
        modal = DT_PlayerFactionNameModal:new(x, y, width, height)
        modal:initialise()
        modal:instantiate()
        DT_PlayerFactionNameModal.instance = modal
    end

    modal.title = tostring(args.title or T("DTCommon_UI_Faction_NameTitle", nil, "Faction Name"))
    modal.promptText = tostring(args.promptText or T("DTCommon_UI_Faction_NamePrompt", nil, "Enter a faction name."))
    modal.defaultValue = trimName(args.defaultValue or "")
    modal.confirmLabel = tostring(args.confirmLabel or T("DTCommon_UI_Faction_Create", nil, "Create"))
    modal.onConfirmCallback = args.onConfirm

    if modal.promptLabel then
        modal.promptLabel:setName(modal.promptText)
    end
    if modal.nameEntry then
        modal.nameEntry:setText(modal.defaultValue)
    end
    if modal.btnConfirm and modal.btnConfirm.setTitle then
        modal.btnConfirm:setTitle(modal.confirmLabel)
    end

    modal:setVisible(true)
    modal:addToUIManager()
    modal:bringToTop()
    if modal.nameEntry and modal.nameEntry.focus then
        modal.nameEntry:focus()
    end

    return modal
end

function DT_PlayerFactionNameModal:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = T("DTCommon_UI_Faction_NameTitle", nil, "Faction Name")
    o.resizable = false
    o.promptText = T("DTCommon_UI_Faction_NamePrompt", nil, "Enter a faction name.")
    o.defaultValue = ""
    o.confirmLabel = T("DTCommon_UI_Faction_Create", nil, "Create")
    o.onConfirmCallback = nil
    return o
end

return DT_PlayerFactionNameModal
