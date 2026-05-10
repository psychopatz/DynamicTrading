if isServer() then return end

DT_CentralDebugHubWindow = ISCollapsableWindow:derive("DT_CentralDebugHubWindow")
local DT_CentralDebugHubCard = ISPanel:derive("DT_CentralDebugHubCard")

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
        if rawLine == "" then
            lines[#lines + 1] = ""
        end
    end

    return lines
end

local function launcherIsAvailable(def)
    local ok, available = pcall(def.available)
    return ok and not not available
end

function DT_CentralDebugHubCard:initialise()
    ISPanel.initialise(self)
end

function DT_CentralDebugHubCard:createChildren()
    if self._childrenCreated then
        return
    end
    self._childrenCreated = true

    self.button = ISButton:new(10, 10, self.width - 20, 26, self.definition.title, self, DT_CentralDebugHubCard.onLaunch)
    self.button:initialise()
    self.button.internal = self.definition.id
    self:addChild(self.button)
end

function DT_CentralDebugHubCard:setAvailability(available)
    self.available = available == true
    if self.button then
        if self.button.setEnable then
            self.button:setEnable(self.available)
        end
        self.button.enable = self.available
        self.button.backgroundColor = self.available
            and { r = 0.2, g = 0.34, b = 0.22, a = 1 }
            or { r = 0.16, g = 0.16, b = 0.16, a = 1 }
    end
end

function DT_CentralDebugHubCard:onLaunch()
    if self.parentWindow and self.parentWindow.onLauncherClick then
        self.parentWindow:onLauncherClick(self.definition.id)
    end
end

function DT_CentralDebugHubCard:prerender()
    ISPanel.prerender(self)
    self:drawRectBorder(0, 0, self.width, self.height, 0.8, 0.35, 0.35, 0.38)
    self:drawRect(0, 0, self.width, self.height, 0.12, 0.02, 0.02, 0.02)
end

function DT_CentralDebugHubCard:render()
    ISPanel.render(self)

    local descLines = splitWrappedLines(UIFont.Small, self.definition.description, self.width - 20)
    local textY = 44
    for _, line in ipairs(descLines) do
        self:drawText(line, 10, textY, 0.8, 0.8, 0.8, 1, UIFont.Small)
        textY = textY + 14
    end

    local statusText = self.available and "Available" or "Unavailable in current session"
    local r, g, b = self.available and 0.5 or 0.78, self.available and 0.92 or 0.58, self.available and 0.5 or 0.58
    self:drawText(statusText, 10, self.height - 20, r, g, b, 1, UIFont.Small)
end

function DT_CentralDebugHubCard:new(x, y, width, height, definition, parentWindow)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.definition = definition
    o.parentWindow = parentWindow
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.borderColor = { r = 0, g = 0, b = 0, a = 0 }
    o.available = false
    return o
end

local HUB_BUTTONS = {
    {
        id = "faction",
        title = "Faction Manager",
        description = "Open the faction roster, debug actions, and contact test tools.",
        available = function()
            local ok = pcall(require, "DT/Common/UI/Debug/Factions/AdminManager/DT_FactionDebugWindow")
            return ok and DT_FactionDebugWindow and DT_FactionDebugWindow.Open
        end,
        action = function()
            DT_FactionDebugWindow.Open()
        end,
    },
    {
        id = "colonyArchive",
        title = "Colony Archive",
        description = "Open the colony archive manager when Dynamic Colonies is active.",
        available = function()
            local activated = getActivatedMods and getActivatedMods() or nil
            local coloniesActive = activated and activated.contains and activated:contains("DynamicColonies") or rawget(_G, "DC_Colony") ~= nil
            if not coloniesActive then
                return false
            end
            local ok = pcall(require, "DT/Common/UI/Debug/Factions/AdminManager/DT_ColonyArchiveDebugWindow")
            return ok and DT_ColonyArchiveDebugWindow and DT_ColonyArchiveDebugWindow.Open
        end,
        action = function()
            DT_ColonyArchiveDebugWindow.Open()
        end,
    },
    {
        id = "merchant",
        title = "Merchant Stock",
        description = "Inspect merchant inventories, stock generation, and trade data.",
        available = function()
            local ok = pcall(require, "DT/Common/UI/Debug/Merchants/StockManager/DT_MerchantDebugWindow")
            return ok and DT_MerchantDebugWindow and DT_MerchantDebugWindow.Open
        end,
        action = function()
            DT_MerchantDebugWindow.Open()
        end,
    },
    {
        id = "playerModData",
        title = "Player ModData",
        description = "Browse the current player's full mod-data payload.",
        available = function()
            local ok = pcall(require, "DT/Common/UI/Debug/DT_PlayerModDataDebugWindow")
            return ok and DT_PlayerModDataDebugWindow and DT_PlayerModDataDebugWindow.Open
        end,
        action = function()
            DT_PlayerModDataDebugWindow.Open()
        end,
    },
    {
        id = "npcManager",
        title = "NPC Manager",
        description = "Open the DTNPC global debugger when the V2 NPC debug stack is available.",
        available = function()
            local ok = pcall(require, "DT/V2/NPC/Debug/DTNPC_Debugger")
            return ok and DTNPC_Debugger and DTNPC_Debugger.OnOpenWindow
        end,
        action = function()
            DTNPC_Debugger.OnOpenWindow()
        end,
    },
    {
        id = "lootVision",
        title = "Loot Vision",
        description = "Open the loot vision inspector. You can refresh it later with a specific NPC.",
        available = function()
            local ok = pcall(require, "DT/V2/NPC/Debug/DTNPC_LootVisionWindow")
            return ok and DTNPC_LootVisionWindow and DTNPC_LootVisionWindow.Open
        end,
        action = function()
            local player = getPlayer and getPlayer() or nil
            local playerNum = player and player.getPlayerNum and player:getPlayerNum() or 0
            DTNPC_LootVisionWindow.Open(playerNum, nil)
        end,
    },
    {
        id = "modDataManagement",
        title = "Mod Data Management",
        description = "Open the dedicated wipe and maintenance window for Dynamic Trading mod data.",
        available = function()
            local ok = pcall(require, "Debug/DT_DataWipe_Client")
            if not (ok and DT_ModDataManagement and DT_ModDataManagement.Open) then
                return false
            end
            if isDebugEnabled() or _G.DT_PRIVATE_DEBUG_BYPASS then return true end
            local player = getPlayer()
            local accessLevel = player and player.getAccessLevel and player:getAccessLevel() or "None"
            return string.lower(tostring(accessLevel)) == "admin"
        end,
        action = function()
            DT_ModDataManagement.Open()
        end,
    },
    {
        id = "virtualStore",
        title = "Virtual Store",
        description = "Monitor exactly what the abstracted faction economy is buying/selling and correct the prices directly.",
        available = function()
            local ok = pcall(require, "DT/Common/UI/Debug/Factions/VirtualStore/DT_VirtualStoreDebugWindow")
            return ok and DT_VirtualStoreDebugWindow and DT_VirtualStoreDebugWindow.Open
        end,
        action = function()
            DT_VirtualStoreDebugWindow.Open()
        end,
    },
}

function DT_CentralDebugHubWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self.title = "Dynamic Trading Debug Hub"
    self:setResizable(false)
end

function DT_CentralDebugHubWindow:createChildren()
    ISCollapsableWindow.createChildren(self)
    if self._hubChildrenCreated then
        return
    end
    self._hubChildrenCreated = true

    self.cards = {}

    local padX = 14
    local topY = self:titleBarHeight() + 10
    local columns = 2
    local columnGap = 14
    local rowHeight = 112
    local usableWidth = self:getWidth() - (padX * 2) - columnGap
    local columnWidth = math.floor(usableWidth / columns)

    self.introLabel = ISLabel:new(padX, topY, 20, "Central launcher for Dynamic Trading debug tools.", 0.9, 0.9, 0.9, 1, UIFont.Small, true)
    self.introLabel:initialise()
    self:addChild(self.introLabel)

    for index, def in ipairs(HUB_BUTTONS) do
        local column = (index - 1) % columns
        local row = math.floor((index - 1) / columns)
        local x = padX + (columnWidth + columnGap) * column
        local y = topY + 24 + rowHeight * row

        local card = DT_CentralDebugHubCard:new(x, y, columnWidth, rowHeight - 12, def, self)
        card:initialise()
        card:createChildren()
        self:addChild(card)
        self.cards[def.id] = card
    end

    local closeY = topY + 24 + rowHeight * math.ceil(#HUB_BUTTONS / columns) + 4
    self.closeButton = ISButton:new(self:getWidth() - 124, closeY, 110, 25, "Close", self, DT_CentralDebugHubWindow.onCloseClick)
    self.closeButton:initialise()
    self:addChild(self.closeButton)

    self:setHeight(closeY + 38)
    self:refreshAvailability()
end

function DT_CentralDebugHubWindow:refreshAvailability()
    for _, def in ipairs(HUB_BUTTONS) do
        local available = launcherIsAvailable(def)
        local card = self.cards[def.id]
        if card then
            card:setAvailability(available)
        end
    end
end

function DT_CentralDebugHubWindow:onLauncherClick(button)
    local launcherID = type(button) == "string" and button or (button and button.internal or nil)
    if not launcherID then
        return
    end

    for _, def in ipairs(HUB_BUTTONS) do
        if def.id == launcherID then
            local available = launcherIsAvailable(def)
            if not available then
                local player = getPlayer and getPlayer() or nil
                if player then
                    player:Say(def.title .. " unavailable in this session.")
                end
                return
            end
            local ok, err = pcall(def.action)
            if not ok then
                local player = getPlayer and getPlayer() or nil
                if player then
                    player:Say(def.title .. " failed to open.")
                end
                if DynamicTrading and DynamicTrading.Log then
                    DynamicTrading.Log("DTCommons", "Error", "DebugHub", tostring(err))
                end
            end
            return
        end
    end
end

function DT_CentralDebugHubWindow:onCloseClick()
    self:close()
end

function DT_CentralDebugHubWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DT_CentralDebugHubWindow.instance = nil
end

function DT_CentralDebugHubWindow.Open()
    if DT_CentralDebugHubWindow.instance then
        DT_CentralDebugHubWindow.instance:bringToTop()
        DT_CentralDebugHubWindow.instance:setVisible(true)
        DT_CentralDebugHubWindow.instance:refreshAvailability()
        return DT_CentralDebugHubWindow.instance
    end

    local width = 520
    local height = 360
    local x = math.floor((getCore():getScreenWidth() - width) / 2)
    local y = math.floor((getCore():getScreenHeight() - height) / 2)
    local window = DT_CentralDebugHubWindow:new(x, y, width, height)
    window:initialise()
    window:addToUIManager()
    DT_CentralDebugHubWindow.instance = window
    return window
end

function DT_CentralDebugHubWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0.03, g = 0.03, b = 0.03, a = 0.92 }
    o.borderColor = { r = 0.85, g = 0.85, b = 0.85, a = 0.85 }
    o.resizable = false
    return o
end

return DT_CentralDebugHubWindow
