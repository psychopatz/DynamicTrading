require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "DT/Common/Faction/DT_FactionDiscoveryBanner"

DynamicTrading = DynamicTrading or {}
DynamicTrading.FactionDiscoveryBannerEditor = DynamicTrading.FactionDiscoveryBannerEditor or {}

local Editor = DynamicTrading.FactionDiscoveryBannerEditor
local Banner = DynamicTrading.FactionDiscoveryBanner

local EditorWindow = ISCollapsableWindow:derive("DT_FactionDiscoveryBannerEditorWindow")

function EditorWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
end

function EditorWindow:createChildren()
    local pad = 14
    local btnY

    ISCollapsableWindow.createChildren(self)

    self.infoLabel = ISLabel:new(
        pad,
        self:titleBarHeight() + 16,
        20,
        "Drag the preview banner to reposition it.",
        0.92,
        0.92,
        0.92,
        1.0,
        UIFont.Small,
        true
    )
    self:addChild(self.infoLabel)

    self.hintLabel = ISLabel:new(
        pad,
        self:titleBarHeight() + 38,
        20,
        "Save keeps the new position. Reset moves it back to top-center.",
        0.72,
        0.72,
        0.72,
        1.0,
        UIFont.Small,
        true
    )
    self:addChild(self.hintLabel)

    btnY = self.height - 36

    self.btnSave = ISButton:new(14, btnY, 90, 24, "Save", self, self.onSave)
    self.btnSave:initialise()
    self:addChild(self.btnSave)

    self.btnReset = ISButton:new(112, btnY, 120, 24, "Reset to Default", self, self.onReset)
    self.btnReset:initialise()
    self:addChild(self.btnReset)

    self.btnCancel = ISButton:new(self.width - 104, btnY, 90, 24, "Cancel", self, self.onCancel)
    self.btnCancel:initialise()
    self:addChild(self.btnCancel)
end

function EditorWindow:onSave()
    if self.preview then
        Banner.SaveRect(self.preview:getX(), self.preview:getY(), self.preview:getWidth(), self.preview:getHeight())
        Banner.ApplySavedPosition()
    end
    self:close()
end

function EditorWindow:onReset()
    if self.preview and self.preview.moveToDefault then
        self.preview:moveToDefault()
    end
end

function EditorWindow:onCancel()
    self:close()
end

function EditorWindow:close()
    if self.preview then
        self.preview:setVisible(false)
        self.preview:removeFromUIManager()
        self.preview = nil
    end

    self:setVisible(false)
    self:removeFromUIManager()
    Editor.instance = nil
end

function Editor.Open()
    if Editor.instance and Editor.instance.javaObject then
        Editor.instance:bringToTop()
        if Editor.instance.preview then
            Editor.instance.preview:bringToTop()
        end
        return Editor.instance
    end

    local x, y, w, h = Banner.GetSavedRect()
    local preview = Banner.PanelClass:new(x, y, w, h, {
        editorMode = true,
        draggable = true,
    })
    preview:initialise()
    preview:instantiate()
    preview:setPreviewMessage("You discovered Azure Collective of Knox Hideout", "Reclaimed Living Room")
    preview:addToUIManager()

    local width = 360
    local height = 130
    local winX = math.floor((getCore():getScreenWidth() - width) / 2)
    local winY = math.floor(getCore():getScreenHeight() * 0.72)
    local window = EditorWindow:new(winX, winY, width, height)
    window.title = "Faction Discovery Banner"
    window.preview = preview
    window:initialise()
    window:instantiate()
    window:addToUIManager()

    Editor.instance = window
    preview:bringToTop()
    window:bringToTop()
    return window
end

return Editor
