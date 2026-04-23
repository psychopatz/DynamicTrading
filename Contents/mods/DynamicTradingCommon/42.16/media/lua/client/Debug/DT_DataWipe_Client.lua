-- =============================================================================
-- DYNAMIC TRADING COMMON: DATA WIPE CLIENT (REMOTE CONTROL)
-- =============================================================================
-- Labeled [Admin] for clarity.
-- restricted to Admins with precise categorization and tooltips.
-- =============================================================================

DT_ModDataManagement = DT_ModDataManagement or {}
DT_ModDataManagementWindow = DT_ModDataManagementWindow or ISCollapsableWindow:derive("DT_ModDataManagementWindow")
local DT_ModDataManagementCard = ISPanel:derive("DT_ModDataManagementCard")

local function measureText(font, text)
    return getTextManager():MeasureStringX(font, tostring(text or ""))
end

local function splitWrappedLines(font, text, maxWidth)
    local lines = {}
    local content = tostring(text or "")
    if content == "" then
        return lines
    end

    for rawLine in string.gmatch(content, "[^\n]+") do
        local current = ""
        for word in string.gmatch(rawLine, "%S+") do
            local candidate = current == "" and word or (current .. " " .. word)
            if current ~= "" and measureText(font, candidate) > maxWidth then
                lines[#lines + 1] = current
                current = word
            else
                current = candidate
            end
        end
        if current ~= "" then
            lines[#lines + 1] = current
        end
    end

    return lines
end

local WIPE_OPTIONS = {
    { target = "REFRESH", label = "TOTAL REFRESH", title = "Refresh All Data", description = "Deletes every Dynamic Trading key found in the save and requests a clean rebuild." },
    { target = "CURRENT", label = "ACTIVE DATA", title = "Wipe Current Mods", description = "Deletes active engine, roster, faction, stock, and soul data." },
    { target = "LEGACY", label = "OLD VERSIONS", title = "Wipe Legacy Data", description = "Cleans out old compatibility keys and stale legacy data." },
    { target = "ENGINE", label = "ECONOMY ENGINE", title = "Wipe Engine Only", description = "Resets simulation clock, daily recruit data, and economic engine state." },
    { target = "STOCKS", label = "MERCHANT STOCKS", title = "Wipe Stocks Only", description = "Resets merchant inventories, balances, and local price modifiers." },
    { target = "FACTIONS", label = "FACTIONS/ALLIANCES", title = "Wipe Factions Only", description = "Clears faction state, wealth, territory, and rep-related faction data." },
    { target = "ROSTER", label = "NPC IDENTITIES", title = "Wipe Roster / Souls", description = "Deletes the roster registry and all saved trader identities." },
    { target = "BUILDINGS", label = "SYSTEM LOGS", title = "Wipe Buildings & Logs", description = "Clears building scan data and system debug logs." },
}

local function hasModDataManagementContextAccess(playerObj)
    if not playerObj then
        return false
    end
    if isDebugEnabled() or _G.DT_PRIVATE_DEBUG_BYPASS then
        return true
    end
    
    local accessLevel = playerObj.getAccessLevel and playerObj:getAccessLevel() or "None"
    return accessLevel and string.lower(tostring(accessLevel)) == "admin"
end

local function RequestServerWipe(playerObj, target, label)
    if not playerObj then return end
    
    local targetLabel = label or target or "ALL DATA"
    local warningText = "ARE YOU SURE YOU WANT TO WIPE " .. targetLabel .. "?\n\nThis action is PERMANENT and cannot be undone.\nA server restart is highly recommended afterwards."
    
    local function doWipe(this, button)
        if button.internal == "YES" then
            sendClientCommand(playerObj, "DynamicTrading", "WipeSystem", { target = target })
            playerObj:Say("Requesting System Wipe (" .. targetLabel .. ")...")
        end
    end

    local modal = ISModalDialog:new(0, 0, 350, 150, warningText, true, nil, doWipe, nil)
    modal:initialise()
    modal:addToUIManager()
end

function DT_ModDataManagementCard:initialise()
    ISPanel.initialise(self)
end

function DT_ModDataManagementCard:createChildren()
    if self._childrenCreated then
        return
    end
    self._childrenCreated = true

    self.button = ISButton:new(10, 10, self.width - 20, 24, self.definition.title, self, DT_ModDataManagementCard.onRun)
    self.button:initialise()
    self.button.backgroundColor = self.definition.target == "REFRESH"
        and { r = 0.55, g = 0.18, b = 0.18, a = 1 }
        or { r = 0.2, g = 0.2, b = 0.24, a = 1 }
    self:addChild(self.button)
end

function DT_ModDataManagementCard:onRun()
    if self.parentWindow and self.parentWindow.onWipeOptionSelected then
        self.parentWindow:onWipeOptionSelected(self.definition)
    end
end

function DT_ModDataManagementCard:prerender()
    ISPanel.prerender(self)
    self:drawRect(0, 0, self.width, self.height, 0.12, 0.03, 0.03, 0.03)
    self:drawRectBorder(0, 0, self.width, self.height, 0.7, 0.32, 0.32, 0.36)
end

function DT_ModDataManagementCard:render()
    ISPanel.render(self)
    local lines = splitWrappedLines(UIFont.Small, self.definition.description, self.width - 20)
    local y = 40
    for _, line in ipairs(lines) do
        self:drawText(line, 10, y, 0.8, 0.8, 0.8, 1, UIFont.Small)
        y = y + 14
    end
end

function DT_ModDataManagementCard:new(x, y, width, height, definition, parentWindow)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.definition = definition
    o.parentWindow = parentWindow
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    return o
end

function DT_ModDataManagementWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self.title = "Dynamic Trading Mod Data Management"
    self:setResizable(false)
end

function DT_ModDataManagementWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    if self._dtChildrenCreated then
        return
    end
    self._dtChildrenCreated = true

    local pad = 12
    local titleBar = self:titleBarHeight()
    local headerY = titleBar + 8

    self.infoLabel = ISLabel:new(pad, headerY, 18, "High-risk maintenance tools for Dynamic Trading save data.", 0.92, 0.92, 0.92, 1, UIFont.Small, true)
    self.infoLabel:initialise()
    self:addChild(self.infoLabel)

    self.cards = {}
    local columns = 2
    local columnGap = 12
    local rowHeight = 102
    local usableWidth = self.width - (pad * 2) - columnGap
    local columnWidth = math.floor(usableWidth / columns)

    for index, def in ipairs(WIPE_OPTIONS) do
        local column = (index - 1) % columns
        local row = math.floor((index - 1) / columns)
        local x = pad + column * (columnWidth + columnGap)
        local y = headerY + 24 + row * rowHeight

        local card = DT_ModDataManagementCard:new(x, y, columnWidth, rowHeight - 10, def, self)
        card:initialise()
        card:createChildren()
        self:addChild(card)
        self.cards[index] = card
    end

    local closeY = headerY + 24 + rowHeight * math.ceil(#WIPE_OPTIONS / columns) + 2
    self.closeButton = ISButton:new(self.width - 122, closeY, 100, 24, "Close", self, DT_ModDataManagementWindow.onClose)
    self.closeButton:initialise()
    self:addChild(self.closeButton)
    self:setHeight(closeY + 36)
end

function DT_ModDataManagementWindow:onWipeOptionSelected(option)
    local playerObj = getPlayer and getPlayer() or nil
    RequestServerWipe(playerObj, option.target, option.label)
end

function DT_ModDataManagementWindow:onClose()
    self:close()
end

function DT_ModDataManagementWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DT_ModDataManagementWindow.instance = nil
end

function DT_ModDataManagement.Open()
    if DT_ModDataManagementWindow.instance then
        DT_ModDataManagementWindow.instance:bringToTop()
        DT_ModDataManagementWindow.instance:setVisible(true)
        return DT_ModDataManagementWindow.instance
    end

    local width = 560
    local height = 390
    local x = math.floor((getCore():getScreenWidth() - width) / 2)
    local y = math.floor((getCore():getScreenHeight() - height) / 2)
    local window = DT_ModDataManagementWindow:new(x, y, width, height)
    window:initialise()
    window:addToUIManager()
    DT_ModDataManagementWindow.instance = window
    return window
end

-- =============================================================================
-- SERVER RESPONSE HANDLER
-- =============================================================================
local function OnServerCommand(module, command, args)
    if module ~= "DynamicTrading" then return end

    if command == "WipeResult" then
        local player = getSpecificPlayer(0)
        if not player then return end

        if args.success then
            player:playSound("AdminAction")
            player:Say("WIPE SUCCESS: " .. (args.count or 0) .. " entries cleared.")
            
            if HaloTextHelper then
                HaloTextHelper.addTextWithArrow(player, "SERVER DATA WIPED", true, HaloTextHelper.getColorGreen())
            end
            
            local modal = ISModalDialog:new(0, 0, 350, 150, 
                (args.msg or "Wipe Complete") .. "\n\nIt is HIGHLY RECOMMENDED to restart the server/session now to clear memory cache.", 
                true, nil, nil, nil)
            modal:initialise()
            modal:addToUIManager()
        else
            player:playSound("AccessDenied")
            player:Say("WIPE FAILED: " .. (args.msg or "Unknown Error"))
            
            if HaloTextHelper then
                HaloTextHelper.addTextWithArrow(player, "ACCESS DENIED", true, HaloTextHelper.getColorRed())
            end
        end
    end
end

Events.OnServerCommand.Add(OnServerCommand)

-- =============================================================================
-- CONTEXT MENU INTEGRATION
-- =============================================================================
local function OnFillWorldObjectContextMenu(player, context, worldObjects, test)
    local playerObj = getSpecificPlayer(player)
    if not playerObj then return end

    if not hasModDataManagementContextAccess(playerObj) then
        return
    end

    context:addOption("[Admin] DynamicTrading Mod Data Management", nil, function()
        DT_ModDataManagement.Open()
    end)
end

Events.OnFillWorldObjectContextMenu.Add(OnFillWorldObjectContextMenu)
