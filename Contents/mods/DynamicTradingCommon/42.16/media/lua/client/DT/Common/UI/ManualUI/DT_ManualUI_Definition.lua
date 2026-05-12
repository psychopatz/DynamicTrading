require "ISUI/ISCollapsableWindow"
require "Utils/ConfigManager/DT_ConfigManager"

DynamicTrading = DynamicTrading or {}
DynamicTrading.Manuals = DynamicTrading.Manuals or {}

DT_ManualUI = DT_ManualUI or ISCollapsableWindow:derive("DT_ManualUI")
DT_ManualUI.instance = DT_ManualUI.instance or nil

local function dtEnsureManualUIModulesLoaded()
    if DT_ManualUI._modulesLoading then
        return
    end

    if DT_ManualUI.loadManualData
        and DT_ManualUI.refreshLayout
        and DT_ManualUI.drawContentItem
        and DT_ManualUI.onSearchButton
        and DT_ManualUI._manualFilterPatched then
        return
    end

    DT_ManualUI._modulesLoading = true

    -- Load the implementation files directly so Open() does not depend on
    -- ManualUI.lua being fully evaluated first.
    require "DT/Common/UI/ManualUI/DT_ManualUI_Utils"
    require "DT/Common/UI/ManualUI/Donators/DT_ManualUI_Donators"
    require "DT/Common/UI/ManualUI/Donators/DT_ManualUI_Donators_Render"
    require "DT/Common/UI/ManualUI/DT_ManualUI_Layout"
    require "DT/Common/UI/ManualUI/DT_ManualUI_Data"
    require "DT/Common/UI/ManualUI/DT_ManualUI_Search"
    require "DT/Common/UI/ManualUI/DT_ManualUI_Render"
    require "DT/Common/UI/ManualUI/DT_ManualUI_Interactions"
    require "DT/Common/UI/ManualUI/DT_ManualUI_ImageModal"
    require "DT/Common/UI/ManualUI/DT_ManualUI_Filters"

    DT_ManualUI._modulesLoading = false
end

function DT_ManualUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Dynamic Trading Manuals")
    self:setResizable(true)
    self.viewMode = self.viewMode or "manuals"
    self.currentManualId = nil
    self.currentPageId = nil
    self.currentReleaseVersion = nil
    self.currentManualType = "manual"
    self.currentPopupVersion = ""
    self.highlightSectionId = nil
    self.results = {}
    self.navRows = {}
    self.manuals = {}
    self.allManuals = {}
    self.pageByManual = {}
    self.pageLookup = {}
    self.blockSectionIndex = {}
    self.expandedManuals = {}
    self.expandedChapters = {}
    self.resultsVisible = false
    self.showUpdateToggle = false
    self._refreshingUpdateToggle = false
    self.showSupportBanner = false
    self.supportBannerManual = nil
    self.supportBannerVersion = ""
    self.hallOfFameManual = nil
    self.hallOfFameSupporters = {}
    self.hallOfFameAutoplayMs = 4000
    self.hallOfFameCurrencySymbol = "$"

    self.manualFilterKey = self.manualFilterKey or nil
    self.manualFilterOptions = self.manualFilterOptions or {}
    self.manualFilterOptionKeys = self.manualFilterOptionKeys or {}
    self.allVisibleManuals = self.allVisibleManuals or {}
end

function DT_ManualUI:close()
    if DT_ConfigManager and DT_ConfigManager.setWindowState then
        DT_ConfigManager.setWindowState("ManualUI", self:getX(), self:getY(), self:getWidth(), self:getHeight())
    end

    if self.viewMode == "manuals" and DT_ConfigManager and DT_ConfigManager.setLastManualLocation then
        DT_ConfigManager.setLastManualLocation(self.currentManualId, self.currentPageId, self.highlightSectionId)
    end

    self:setVisible(false)
    self:removeFromUIManager()
    DT_ManualUI.instance = nil
end

function DT_ManualUI.Open(args)
    args = args or {}
    dtEnsureManualUIModulesLoaded()

    if DT_ManualUI.instance then
        DT_ManualUI.instance:close()
    end

    local width = 940
    local height = 640
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    if DT_ConfigManager and DT_ConfigManager.getWindowState then
        local state = DT_ConfigManager.getWindowState("ManualUI")
        if state then
            x = state.x or x
            y = state.y or y
            width = state.w or width
            height = state.h or height
        end
    end

    local ui = DT_ManualUI:new(x, y, width, height)
    ui.viewMode = args and args.viewMode or "manuals"
    ui.manualFilterKey = args.manualFilterKey or args.filterKey or nil
    ui:initialise()
    ui:addToUIManager()
    ui:loadManualData()
    ui:openLocation(args)
    DT_ManualUI.instance = ui

    return ui
end

function DT_ManualUI:refreshWindowTitle()
    local title = self.viewMode == "updates" and "Dynamic Trading Updates" or "Dynamic Trading Manuals"
    self:setTitle(title)
    self.title = title
end

function DT_ManualUI:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.resizable = true
    o.minimumWidth = 600
    o.minimumHeight = 600
    o.title = "Dynamic Trading Manuals"
    return o
end

DynamicTrading.Manuals.Open = function(args)
    return DT_ManualUI.Open(args or {})
end

DynamicTrading.Manuals.OpenUpdates = function(args)
    args = args or {}
    args.viewMode = "updates"
    return DT_ManualUI.Open(args)
end

DynamicTrading.Manuals.OpenSupport = function(args)
    args = args or {}
    local manual = DynamicTrading.Manuals
        and DynamicTrading.Manuals.GetLatestManualByType
        and DynamicTrading.Manuals.GetLatestManualByType("support")
        or nil

    if manual then
        args.viewMode = "manuals"
        args.manualId = args.manualId or manual.id
        args.pageId = args.pageId or manual.startPageId
    end

    return DT_ManualUI.Open(args)
end

DynamicTrading.Manuals.OpenDonators = function(args)
    args = args or {}
    local manual = DynamicTrading.Manuals
        and DynamicTrading.Manuals.GetLatestManualByType
        and DynamicTrading.Manuals.GetLatestManualByType("donators")
        or nil

    if manual then
        args.viewMode = "manuals"
        args.manualId = args.manualId or manual.id
        args.pageId = args.pageId or manual.startPageId
    end

    return DT_ManualUI.Open(args)
end
