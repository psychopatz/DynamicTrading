-- DT_V2_RadarPatch.lua
-- Hooks into ISRadioWindow to add the Trader Radar functionality.
-- Version [V3.6] - Native Signal Layout + Vanilla Distance Row Cover Fix
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRadioWindow"
require "DT/Common/UI/RadioScanner/DT_RadioScannerWindow"
require "DT/V2/Radio/RadarManager/DT_V2_RadarManager"

local original_createChildren = ISRadioWindow.createChildren
local original_close = ISRadioWindow.close
local original_readFromObject = ISRadioWindow.readFromObject

local function getWidgetX(widget)
    if widget and widget.getX then
        return widget:getX()
    end
    return tonumber(widget and widget.x) or 0
end

local function getWidgetY(widget)
    if widget and widget.getY then
        return widget:getY()
    end
    return tonumber(widget and widget.y) or 0
end

local function getWidgetWidth(widget)
    if widget and widget.getWidth then
        return widget:getWidth()
    end
    return tonumber(widget and widget.width) or 0
end

local function getWidgetHeight(widget)
    if widget and widget.getHeight then
        return widget:getHeight()
    end
    return tonumber(widget and widget.height) or 0
end

local function setWidgetWidth(widget, width)
    if not widget then
        return
    end

    if widget.setWidth then
        widget:setWidth(width)
    else
        widget.width = width
    end
end

local function setWidgetHeight(widget, height)
    if not widget then
        return
    end

    if widget.setHeight then
        widget:setHeight(height)
    else
        widget.height = height
    end
end

local function setWidgetSize(widget, width, height)
    setWidgetWidth(widget, width)
    setWidgetHeight(widget, height)
end

local function setWidgetVisible(widget, visible)
    if not widget then
        return
    end

    if widget.setVisible then
        widget:setVisible(visible == true)
    else
        widget.visible = visible == true
    end
end

local function isWidgetVisible(widget)
    if not widget then
        return false
    end

    if type(widget.getIsVisible) == "function" then
        local ok, result = pcall(widget.getIsVisible, widget)
        if ok then
            return result == true
        end
    end

    if type(widget.isVisible) == "function" then
        local ok, result = pcall(widget.isVisible, widget)
        if ok then
            return result == true
        end
    end

    if type(widget.visible) == "boolean" then
        return widget.visible == true
    end

    return true
end

local function readBooleanField(widget, field)
    if not widget then
        return nil
    end

    local value = widget[field]

    if type(value) == "function" then
        local ok, result = pcall(value, widget)
        if ok and type(result) == "boolean" then
            return result
        end
        return nil
    end

    if type(value) == "boolean" then
        return value
    end

    return nil
end

local function isRadioOperationalFromWindow(window)
    if not window then
        return false
    end

    local data = window.deviceData
    if not data and window.device and window.device.getDeviceData then
        data = window.device:getDeviceData()
    end

    return data ~= nil
        and data:getIsTurnedOn()
        and data:getPower() > 0
end

local function textLooksLikeBaseSignalDetail(value)
    local text = string.lower(tostring(value or ""))
    if text == "" then
        return false
    end

    return string.find(text, "distance", 1, true) ~= nil
        or string.find(text, "meter", 1, true) ~= nil
        or string.find(text, "category", 1, true) ~= nil
end

local function clearBaseSignalDetailText(widget)
    if type(widget) ~= "table" then
        return
    end

    local textFields = {
        "name",
        "text",
        "title",
        "titleText",
        "label",
        "description",
    }

    for _, field in ipairs(textFields) do
        if type(widget[field]) == "string" and textLooksLikeBaseSignalDetail(widget[field]) then
            widget[field] = ""
        end
    end
end

local function clearBaseSignalDetailsRecursive(widget, depth, visited)
    if type(widget) ~= "table" then
        return
    end

    if depth and depth > 5 then
        return
    end

    visited = visited or {}
    if visited[widget] then
        return
    end
    visited[widget] = true

    clearBaseSignalDetailText(widget)

    local children = widget.children
    if type(children) == "table" then
        for _, child in pairs(children) do
            clearBaseSignalDetailsRecursive(child, (depth or 0) + 1, visited)
        end
    end
end

local function findSignalModule(window)
    if not window or not window.modules then
        return nil, nil, nil
    end

    for _, module in ipairs(window.modules) do
        local element = module.element
        local subpanel = element and element.subpanel
        local title = element and element.titleText

        local isSignal = false
        if title == "Signal" then
            isSignal = true
        elseif subpanel and subpanel.sineWaveDisplay then
            isSignal = true
        end

        if isSignal then
            return module, element, subpanel or element
        end
    end

    return nil, nil, nil
end

local function getAbsolutePositionRelativeToWindow(widget, window)
    local x = 0
    local y = 0
    local current = widget

    while current and current ~= window do
        x = x + getWidgetX(current)
        y = y + getWidgetY(current)
        current = current.parent
    end

    return x, y
end

local function getSignalHeaderHeight(signalElement, signalPanel)
    if not signalElement then
        return 18
    end

    if signalElement.dt_signalHeaderHeight then
        return signalElement.dt_signalHeaderHeight
    end

    local headerHeight = getWidgetY(signalPanel)
    if headerHeight <= 0 then
        headerHeight = getWidgetHeight(signalElement) - getWidgetHeight(signalPanel)
    end

    if headerHeight < 16 or headerHeight > 40 then
        headerHeight = 18
    end

    signalElement.dt_signalHeaderHeight = headerHeight
    return headerHeight
end

local function isSignalPanelExpanded(signalElement, signalPanel, waveDisplay)
    if not signalElement or not signalPanel then
        return false
    end

    if readBooleanField(signalElement, "collapsed") == true then
        return false
    end

    if readBooleanField(signalElement, "isCollapsed") == true then
        return false
    end

    if readBooleanField(signalElement, "expanded") == false then
        return false
    end

    if readBooleanField(signalElement, "isExpanded") == false then
        return false
    end

    if not isWidgetVisible(signalPanel) then
        return false
    end

    if waveDisplay and not isWidgetVisible(waveDisplay) then
        return false
    end

    if waveDisplay and isWidgetVisible(waveDisplay) then
        return true
    end

    local headerHeight = getSignalHeaderHeight(signalElement, signalPanel)
    return getWidgetHeight(signalElement) > headerHeight + 2
end

local function addChildIfNeeded(parent, child)
    if not parent or not child or type(parent.addChild) ~= "function" then
        return
    end

    if child.parent and child.parent ~= parent and child.parent.removeChild then
        child.parent:removeChild(child)
    end

    if child.parent ~= parent then
        parent:addChild(child)
    end
end

local function bringChildToFront(parent, child)
    if not parent or not child or type(parent.addChild) ~= "function" then
        return
    end

    if child.parent and child.parent.removeChild then
        child.parent:removeChild(child)
    end

    parent:addChild(child)
end

local function setSignalControlsVisible(window, visible)
    if not window then
        return
    end

    setWidgetVisible(window.dt_signalButtonBacker, visible)
    setWidgetVisible(window.btnTraderScan, visible)
    setWidgetVisible(window.btnTraderList, visible)
end

local function ensureSignalControls(window)
    if not window then
        return
    end

    if not window.dt_signalButtonBacker then
        window.dt_signalButtonBacker = ISPanel:new(0, 0, 100, 24)
        window.dt_signalButtonBacker:initialise()
        window.dt_signalButtonBacker.backgroundColor = { r = 0, g = 0, b = 0, a = 1 }
        window.dt_signalButtonBacker.borderColor = { r = 0, g = 0, b = 0, a = 0 }
        window.dt_signalButtonBacker:setVisible(false)
    end

    if not window.btnTraderScan then
        window.btnTraderScan = ISButton:new(0, 0, 110, 22, "Scan", window, function(radioWindow)
            if not isRadioOperationalFromWindow(radioWindow) then
                return
            end

            if DT_V2_RadarManager and DT_V2_RadarManager.CanScan then
                local canScan = DT_V2_RadarManager.CanScan(getSpecificPlayer(0), radioWindow.device)
                if not canScan then
                    return
                end
            end

            local now = getTimeInMillis()
            if radioWindow.dt_lastScanClick and now - radioWindow.dt_lastScanClick < 3000 then
                return
            end
            radioWindow.dt_lastScanClick = now

            if DT_V2_RadarManager and DT_V2_RadarManager.Scan then
                DT_V2_RadarManager.Scan(getSpecificPlayer(0), radioWindow.device)
            end
        end)

        window.btnTraderScan:initialise()
        window.btnTraderScan.dt_icon = getTexture("media/ui/Icon_MarketInfo.png")
        window.btnTraderScan.render = function(btn)
            ISButton.render(btn)
            if btn.dt_icon then
                btn:drawTextureScaled(btn.dt_icon, 4, (btn.height - 16) / 2, 16, 16, 1, 1, 1, 1)
            end
        end
        window.btnTraderScan.backgroundColor = { r = 0.2, g = 0.5, b = 0.2, a = 0.8 }
        window.btnTraderScan:setVisible(false)
    end

    if not window.btnTraderList then
        window.btnTraderList = ISButton:new(0, 0, 110, 22, "Access Radio", window, function(radioWindow)
            if DT_RadioScannerWindow then
                DT_RadioScannerWindow.ToggleWindow(radioWindow.device)
            end
        end)

        window.btnTraderList:initialise()
        window.btnTraderList.dt_icon = getTexture("media/ui/Icon_MarketInfo.png")
        window.btnTraderList.render = function(btn)
            ISButton.render(btn)
            if btn.dt_icon then
                btn:drawTextureScaled(btn.dt_icon, 4, (btn.height - 16) / 2, 16, 16, 1, 1, 1, 1)
            end
        end
        window.btnTraderList.backgroundColor = { r = 0.2, g = 0.2, b = 0.5, a = 0.8 }
        window.btnTraderList:setVisible(false)
    end

    addChildIfNeeded(window, window.dt_signalButtonBacker)
    addChildIfNeeded(window, window.btnTraderScan)
    addChildIfNeeded(window, window.btnTraderList)

    if window.dt_signalControlsOrdered ~= true then
        bringChildToFront(window, window.dt_signalButtonBacker)
        bringChildToFront(window, window.btnTraderScan)
        bringChildToFront(window, window.btnTraderList)
        window.dt_signalControlsOrdered = true
    end
end

local function keepSignalControlsInFront(window)
    if not window then
        return
    end

    bringChildToFront(window, window.dt_signalButtonBacker)
    bringChildToFront(window, window.btnTraderScan)
    bringChildToFront(window, window.btnTraderList)
end

local function layoutSignalControls(window, isValid)
    ensureSignalControls(window)

    local _, signalElement, signalPanel = findSignalModule(window)
    if not signalElement or not signalPanel then
        setSignalControlsVisible(window, false)
        return
    end

    local waveDisplay = signalPanel.sineWaveDisplay
    local isExpanded = isSignalPanelExpanded(signalElement, signalPanel, waveDisplay)

    clearBaseSignalDetailsRecursive(signalPanel, 0, {})

    if not isValid or not isExpanded then
        setSignalControlsVisible(window, false)
        return
    end

    local panelWidth = getWidgetWidth(signalPanel)
    if panelWidth <= 0 then
        panelWidth = getWidgetWidth(signalElement)
    end
    if panelWidth <= 0 then
        panelWidth = window.width
    end

    local panelHeight = getWidgetHeight(signalPanel)
    local btnHeight = 22
    local gap = 10
    local sidePadding = 10

    local btnWidth = math.floor((panelWidth - (sidePadding * 2) - gap) / 2)
    if btnWidth < 90 then
        btnWidth = 90
    end
    if btnWidth > 125 then
        btnWidth = 125
    end

    local waveBottom = 26
    if waveDisplay then
        waveBottom = getWidgetY(waveDisplay) + getWidgetHeight(waveDisplay)
    end

    local buttonYInPanel = waveBottom + 6

    -- Keep the controls inside the existing Signal subpanel without expanding it.
    if panelHeight > 0 then
        local maxButtonY = panelHeight - btnHeight - 4
        if maxButtonY >= 4 and buttonYInPanel > maxButtonY then
            buttonYInPanel = maxButtonY
        end
    end

    local coverYInPanel = math.max(0, buttonYInPanel - 2)
    local coverHeight = btnHeight + 4

    if panelHeight > 0 then
        coverHeight = math.min(coverHeight, math.max(0, panelHeight - coverYInPanel))
    end

    local panelAbsX, panelAbsY = getAbsolutePositionRelativeToWindow(signalPanel, window)
    local totalWidth = (btnWidth * 2) + gap
    local startX = math.floor(panelAbsX + ((panelWidth - totalWidth) / 2))
    local buttonY = panelAbsY + buttonYInPanel

    -- Parent these to the radio window, not the Signal subpanel. The vanilla
    -- Signal panel can draw its distance/category row during its own render,
    -- so this overlay must render after the module to hide that base text.
    window.dt_signalButtonBacker:setX(panelAbsX)
    window.dt_signalButtonBacker:setY(panelAbsY + coverYInPanel)
    setWidgetSize(window.dt_signalButtonBacker, panelWidth, coverHeight)

    window.btnTraderScan:setX(startX)
    window.btnTraderScan:setY(buttonY)
    setWidgetSize(window.btnTraderScan, btnWidth, btnHeight)

    window.btnTraderList:setX(startX + btnWidth + gap)
    window.btnTraderList:setY(buttonY)
    setWidgetSize(window.btnTraderList, btnWidth, btnHeight)

    setWidgetVisible(window.dt_signalButtonBacker, true)
    setWidgetVisible(window.btnTraderScan, true)
    setWidgetVisible(window.btnTraderList, true)

    keepSignalControlsInFront(window)
end

function ISRadioWindow:close()
    if DT_RadioScannerWindow and DT_RadioScannerWindow.instance then
        DT_RadioScannerWindow.instance:close()
    end

    original_close(self)
end

function ISRadioWindow:readFromObject(_player, _deviceObject)
    if self.device ~= _deviceObject then
        if DT_RadioScannerWindow and DT_RadioScannerWindow.instance then
            DT_RadioScannerWindow.instance:close()
        end
    end

    original_readFromObject(self, _player, _deviceObject)
end

function ISRadioWindow:createChildren()
    original_createChildren(self)
    ensureSignalControls(self)
    layoutSignalControls(self, false)
end

local original_prerender = ISRadioWindow.prerender

function ISRadioWindow:prerender()
    original_prerender(self)

    ensureSignalControls(self)

    local isValid = false
    if self.deviceData and not self.deviceData:isTelevision() and self.deviceData:getIsTwoWay() then
        isValid = true
    end

    layoutSignalControls(self, isValid)

    if not isValid then
        return
    end

    if self.btnTraderScan and self.btnTraderList then
        local operational = isRadioOperationalFromWindow(self)
        local canScan = true
        local remainingMinutes = 0

        if operational and DT_V2_RadarManager and DT_V2_RadarManager.CanScan then
            local player = getSpecificPlayer(0)
            canScan, remainingMinutes = DT_V2_RadarManager.CanScan(player, self.device)
        end

        local now = getTimeInMillis()
        local isCooldownBlocked = operational and canScan ~= true
        local isClickGraceBlocked = operational and self.dt_lastScanClick and now - self.dt_lastScanClick < 3000
        local isEffectivelyDisabled = not operational or isCooldownBlocked or isClickGraceBlocked

        self.btnTraderScan.enable = true
        self.btnTraderList.enable = operational

        if not isEffectivelyDisabled then
            self.btnTraderScan:setTitle("Scan")
            self.btnTraderScan.textColor = { r = 1, g = 1, b = 1, a = 1 }
            self.btnTraderScan.backgroundColor = { r = 0.2, g = 0.5, b = 0.2, a = 0.8 }
        else
            if isCooldownBlocked then
                self.btnTraderScan:setTitle("Wait (" .. tostring(math.max(1, math.ceil(remainingMinutes or 0))) .. "m)")
            else
                self.btnTraderScan:setTitle("Scan")
            end

            self.btnTraderScan.textColor = { r = 1, g = 1, b = 1, a = 1 }
            self.btnTraderScan.backgroundColor = { r = 0.5, g = 0.2, b = 0.2, a = 0.8 }
        end

        if not operational and DT_RadioScannerWindow and DT_RadioScannerWindow.instance then
            DT_RadioScannerWindow.instance:close()
        end
    end
end

-- ==============================================================================
-- CONTEXT MENU SUPPORT (V2)
-- ==============================================================================

local function OnFillRadioContextMenu(playerNum, context, items, isWorld)
    local player = getSpecificPlayer(playerNum)
    local radioDevice = nil

    if isWorld then
        for _, obj in ipairs(items) do
            if instanceof(obj, "IsoWaveSignal") then
                if DT_V2_RadarManager and DT_V2_RadarManager.GetDeviceTypeID then
                    if DT_V2_RadarManager.GetDeviceTypeID(obj) then
                        radioDevice = obj
                        break
                    end
                end
            end
        end
    else
        for _, v in ipairs(items) do
            local item = v
            if not instanceof(v, "InventoryItem") then
                item = v.items[1]
            end

            if DT_V2_RadarManager and DT_V2_RadarManager.GetDeviceTypeID then
                if DT_V2_RadarManager.GetDeviceTypeID(item) then
                    radioDevice = item
                    break
                end
            end
        end
    end

    if radioDevice then
        local option = context:addOption(
            "Open Trader Radar",
            radioDevice,
            function(device)
                if DT_RadioScannerWindow then
                    DT_RadioScannerWindow.ToggleWindow(device)
                end
            end
        )

        local icon = getTexture("media/ui/Icon_MarketInfo.png")
        if icon then
            option.iconTexture = icon
        end

        local data = radioDevice.getDeviceData and radioDevice:getDeviceData() or nil
        if not data or not data:getIsTurnedOn() or data:getPower() <= 0 then
            option.notAvailable = true
            option.toolTip = ISWorldObjectContextMenu.addToolTip()
            option.toolTip.description = "Radio must be ON and have Power."
        end
    end
end

local function OnFillInventoryObjectContextMenu(playerNum, context, items)
    OnFillRadioContextMenu(playerNum, context, items, false)
end

local function OnFillWorldObjectContextMenu(playerNum, context, worldObjects, test)
    OnFillRadioContextMenu(playerNum, context, worldObjects, true)
end

Events.OnFillInventoryObjectContextMenu.Add(OnFillInventoryObjectContextMenu)
Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)