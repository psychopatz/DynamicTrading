-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/DT_FactionEventLogPanel.lua
-- Component: Reusable Event Log Panel for Factions
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "ISUI/ISButton"

DT_FactionEventLogPanel = ISPanel:derive("DT_FactionEventLogPanel")

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function isBanditFaction(faction)
    return type(faction) == "table"
        and (tostring(faction.id or "") == "Bandits"
            or tostring(faction.factionType or "") == "bandit")
end

local function resolveEntryTextForFaction(faction, entry)
    local textStr, catStr = entry.text, entry.cat
    if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.ResolveText then
        textStr, catStr = DynamicTrading.GameplayLogs.ResolveText(entry)
    end

    if isBanditFaction(faction)
        and DynamicTrading
        and DynamicTrading.GameplayEvents
        and tonumber(entry and entry.e) == tonumber(DynamicTrading.GameplayEvents.TRADE_STARTED) then
        local data = entry and (entry.tokens or entry.p or entry.d) or {}
        textStr = tostring(data[1] or "A raider") .. " started a raiding run"
    end

    return textStr, catStr
end

function DT_FactionEventLogPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0.2}
    o.borderColor = {r=0.3, g=0.3, b=0.3, a=0.5}
    o.lastNewsHash = ""
    o.lastFactionID = ""
    o.currentFaction = nil
    return o
end

function DT_FactionEventLogPanel:initialise()
    ISPanel.initialise(self)
end

function DT_FactionEventLogPanel:createChildren()
    -- Title for the log section
    self.lblTitle = ISLabel:new(0, 0, 20, " RECENT EVENTS ", 0.4, 0.8, 1, 1, UIFont.Small, true)
    self:addChild(self.lblTitle)

    self.btnRefresh = ISButton:new(self.width - 84, 0, 84, 20, "Refresh", self, self.onRefreshClick)
    self.btnRefresh:initialise()
    self.btnRefresh:setAnchorLeft(false)
    self.btnRefresh:setAnchorRight(true)
    self:addChild(self.btnRefresh)

    self.richText = ISRichTextPanel:new(0, 22, self.width, self.height - 22)
    self.richText:initialise()
    self.richText.backgroundColor = {r=0, g=0, b=0, a=0.4}
    self.richText.borderColor = {r=0, g=0, b=0, a=0}
    self.richText:addScrollBars()
    self.richText:setAnchorRight(true)
    self.richText:setAnchorBottom(true)
    self:addChild(self.richText)
end

function DT_FactionEventLogPanel:onResize()
    ISPanel.onResize(self)
    if self.btnRefresh then
        self.btnRefresh:setX(self.width - self.btnRefresh:getWidth())
    end
    if self.richText then
        self.richText:setWidth(self.width)
        self.richText:setHeight(self.height - 22)
        -- Delayed paginate to ensure width is applied
        self.richText:paginate()
    end
end

function DT_FactionEventLogPanel:forceRefresh()
    self.lastFactionID = ""
    self.lastNewsHash = ""

    local logKey = DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.GetStorageKey and DynamicTrading.GameplayLogs.GetStorageKey("Factions") or "DynamicTrading_GameplayLogs_Factions"
    if ModData and ModData.request then
        ModData.request(logKey)
    end

    self:updateData(self.currentFaction)
end

function DT_FactionEventLogPanel:onRefreshClick()
    self:forceRefresh()
end

function DT_FactionEventLogPanel:updateData(f)
    self.currentFaction = f
    if not f then 
        self.richText:setText("")
        self.lastFactionID = ""
        self.lastNewsHash = ""
        return 
    end

    local logKey = DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.GetStorageKey and DynamicTrading.GameplayLogs.GetStorageKey("Factions") or "DynamicTrading_GameplayLogs_Factions"
    local newsData = ModData.getOrCreate(logKey)
    local factionID = tostring(f.id or "")
    local news = newsData[factionID] or newsData[f.id] or {}
    local newsCount = #news

    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTLogs", "Gameplay", "UI", "Faction log lookup | Faction: " .. tostring(f.id) .. " | Normalized: " .. factionID .. " | Entries: " .. tostring(newsCount))
    end
    
    local topEntry = news[1]
    local topNewsHash = tostring(newsCount) .. (newsCount > 0 and ((topEntry.time or topEntry.t or "") .. (topEntry.text or tostring(topEntry.e))) or "")
    
    -- Optimization: Only update if faction changed or new entries arrived
    if factionID == self.lastFactionID and topNewsHash == self.lastNewsHash then
        return
    end

    self.lastFactionID = factionID
    self.lastNewsHash = topNewsHash

    if newsCount == 0 then
        self.richText:setText(" <RGB:0.5,0.5,0.5> No recent records for this faction.")
        self.richText:paginate()
        return
    end

    local text = ""
    for i = 1, #news do
        local entry = news[i]
        
        -- Serialize text using template resolver
        local textStr, catStr = resolveEntryTextForFaction(f, entry)
        
        local color = "<RGB:0.8,0.8,0.8> "
        if catStr == "good" then
            color = "<RGB:0.4,1.0,0.4> "
        elseif catStr == "bad" then
            color = "<RGB:1.0,0.4,0.4> "
        elseif catStr == "event" then
            color = "<RGB:1.0,1.0,0.4> "
        end
        local timeStr = entry.time or entry.t or ""
        text = text .. "<RGB:0.5,0.5,0.5> [" .. timeStr .. "] " .. color .. (textStr or T("DTCommon_UI_Faction_UnknownEvent", nil, "Unknown event")) .. " <LINE> "
    end

    self.richText:setText(text)
    self.richText:paginate()
end
