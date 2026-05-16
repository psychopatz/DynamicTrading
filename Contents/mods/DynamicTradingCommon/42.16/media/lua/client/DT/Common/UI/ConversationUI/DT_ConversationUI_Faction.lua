-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI FACTION
-- =============================================================================
-- Faction lookups and reputation display helpers.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

local function containsStatusToken(value, token)
    local text = tostring(value or ""):lower()
    return text ~= "" and string.find(text, token, 1, true) ~= nil
end

local function clamp01(value)
    if value < 0 then
        return 0
    end
    if value > 1 then
        return 1
    end
    return value
end

local function makeColor(r, g, b, a)
    return {
        r = clamp01(r or 0),
        g = clamp01(g or 0),
        b = clamp01(b or 0),
        a = clamp01(a or 1)
    }
end

local function brighten(color, amount, alpha)
    local lift = amount or 0
    return makeColor(
        (color.r or 0) + lift,
        (color.g or 0) + lift,
        (color.b or 0) + lift,
        alpha or color.a or 1
    )
end

local function soften(color, amount, alpha)
    local blend = clamp01(amount or 0.18)
    return makeColor(
        (color.r or 0) + ((1 - (color.r or 0)) * blend),
        (color.g or 0) + ((1 - (color.g or 0)) * blend),
        (color.b or 0) + ((1 - (color.b or 0)) * blend),
        alpha or color.a or 1
    )
end

local function resolveStateKey(traderObj, faction, statusText)
    local stateBlob = table.concat({
        tostring(traderObj and traderObj.currentState or ""),
        tostring(traderObj and traderObj.status or ""),
        tostring(traderObj and traderObj.archetype or ""),
        tostring(traderObj and traderObj.role or ""),
        tostring(faction and faction.state or ""),
        tostring(statusText or "")
    }, " "):lower()

    if containsStatusToken(stateBlob, "hostile")
        or containsStatusToken(stateBlob, "attack")
        or containsStatusToken(stateBlob, "flee")
        or containsStatusToken(stateBlob, "bandit") then
        return "hostile"
    end

    if containsStatusToken(stateBlob, "rest")
        or containsStatusToken(stateBlob, "resting")
        or containsStatusToken(stateBlob, "sleep")
        or containsStatusToken(stateBlob, "idle") then
        return "resting"
    end

    if containsStatusToken(stateBlob, "trade")
        or containsStatusToken(stateBlob, "trader")
        or containsStatusToken(stateBlob, "merchant")
        or containsStatusToken(stateBlob, "vendor")
        or containsStatusToken(stateBlob, "shop") then
        return "trader"
    end

    if containsStatusToken(stateBlob, "guard")
        or containsStatusToken(stateBlob, "patrol")
        or containsStatusToken(stateBlob, "watch") then
        return "guard"
    end

    return "reputation"
end

local function isHostileTarget(traderObj, faction, statusText)
    if not traderObj then
        return false
    end

    if traderObj.isBanditDemand == true or traderObj.isTrueBandit == true or traderObj.isHostileFactionRaider == true then
        return true
    end

    if tostring(traderObj.factionID or "") == "Bandits" then
        return true
    end

    if containsStatusToken(traderObj.status, "hostile")
        or containsStatusToken(traderObj.currentState, "hostile")
        or containsStatusToken(traderObj.currentState, "attack")
        or containsStatusToken(traderObj.currentState, "flee")
        or containsStatusToken(statusText, "hostile")
        or containsStatusToken(faction and faction.state, "hostile") then
        return true
    end

    return false
end

function DT_ConversationUI:refreshVisualTone(stageData, statusText, faction)
    local target = self.target or {}
    local hostile = isHostileTarget(target, faction, statusText)
    local stateKey = hostile and "hostile" or resolveStateKey(target, faction, statusText)
    self.visualIsHostile = hostile

    local baseColor
    if stateKey == "hostile" then
        baseColor = makeColor(0.92, 0.24, 0.20, 0.95)
    elseif stateKey == "resting" then
        baseColor = makeColor(0.92, 0.72, 0.26, 0.95)
    elseif stateKey == "trader" then
        baseColor = makeColor(0.44, 0.92, 0.58, 0.95)
    elseif stateKey == "guard" then
        baseColor = makeColor(0.46, 0.70, 0.96, 0.95)
    else
        local color = stageData and stageData.color or { r = 0.78, g = 0.82, b = 0.76 }
        baseColor = makeColor(color.r or 0.78, color.g or 0.82, color.b or 0.76, 0.95)
    end

    self.visualAccentColor = brighten(baseColor, 0.06, 0.95)
    self.visualBorderColor = makeColor(baseColor.r, baseColor.g, baseColor.b, hostile and 0.86 or 0.76)
    self.visualNameColor = brighten(baseColor, hostile and 0.18 or 0.24, 1.0)
    self.visualFactionColor = soften(baseColor, hostile and 0.08 or 0.16, 1.0)
    self.visualRoleColor = soften(baseColor, 0.22, 1.0)
end

function DT_ConversationUI:getFactionData(factionID)
    if not factionID then
        return nil
    end

    local sources = {
        DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions,
        DT_V2_RadarManager and DT_V2_RadarManager.ClientFactions,
        ModData.get("DynamicTrading_Factions")
    }

    for _, factionData in ipairs(sources) do
        if type(factionData) == "table" and factionData[factionID] then
            return factionData[factionID]
        end
    end

    return nil
end

function DT_ConversationUI:getFactionName(traderObj, faction)
    if not traderObj or not traderObj.factionID then
        return nil
    end

    if traderObj.factionName and traderObj.factionName ~= "" then
        return traderObj.factionName
    end

    if faction and faction.name and faction.name ~= "" then
        return faction.name
    end

    if DT_TraderContacts and DT_TraderContacts.GetFactionDisplayName then
        local displayName = DT_TraderContacts.GetFactionDisplayName(traderObj)
        if displayName and displayName ~= "" then
            return tostring(displayName)
        end
    end

    if traderObj.factionID == "Independent" then
        return "Independent Traders"
    end

    return tostring(traderObj.factionID)
end

function DT_ConversationUI:refreshFactionInfo()
    local traderObj = self.target
    if not traderObj or not traderObj.factionID then
        return
    end

    if self.isContactConversation and DT_TraderContacts and DT_TraderContacts.RefreshContactData then
        local refreshed = DT_TraderContacts.RefreshContactData(traderObj)
        if refreshed then
            self.target = refreshed
            traderObj = refreshed
        end
    end

    local faction = self:getFactionData(traderObj.factionID)
    local traderUUID = traderObj.uuid or traderObj.traderID or traderObj.id

    self.lblFactionTitle:setVisible(true)
    self.lblFactionName:setName(self:getFactionName(traderObj, faction))
    self.lblFactionName:setVisible(true)

    local rep = 0
    local stageData = { label = "Neutral", color = { r = 0.8, g = 0.8, b = 0.8 } }
    if DT_Reputation and traderUUID then
        rep = DT_Reputation.GetEffectiveRep(traderUUID, traderObj.factionID)
        stageData = DT_Reputation.GetStageData(rep)
        if DT_Reputation.AUTO_DEBUG then
            DT_Reputation.DebugDump(traderUUID, traderObj.factionID, "conversation_open")
        end
    end

    self.lblReputation:setName(string.format("Reputation: %d (%s)", rep, stageData.label))
    self.lblReputation:setColor(stageData.color.r, stageData.color.g, stageData.color.b)
    self.lblReputation:setVisible(true)

    if faction and faction.wealth ~= nil then
        self.lblWealth:setName(string.format("Wealth: %d$", faction.wealth))
        self.lblWealth:setVisible(true)
    else
        self.lblWealth:setVisible(false)
    end

    local statusText = nil
    if self.isContactConversation and DT_TraderContacts and DT_TraderContacts.GetStatusText then
        statusText = DT_TraderContacts.GetStatusText(traderObj)
    elseif faction and faction.state then
        statusText = string.format("Status: %s", faction.state)
    end

    if statusText then
        self.lblState:setName(tostring(statusText))
        self.lblState:setVisible(true)
    else
        self.lblState:setVisible(false)
    end

    self:refreshVisualTone(stageData, statusText, faction)
    if self.lblFactionTitle then
        self.lblFactionTitle:setColor(self.visualRoleColor.r, self.visualRoleColor.g, self.visualRoleColor.b)
    end
    if self.lblFactionName then
        self.lblFactionName:setColor(self.visualFactionColor.r, self.visualFactionColor.g, self.visualFactionColor.b)
    end
end
