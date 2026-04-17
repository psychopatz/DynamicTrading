-- =============================================================================
-- DYNAMIC TRADING: CONVERSATION UI FACTION
-- =============================================================================
-- Faction lookups and reputation display helpers.
-- =============================================================================

require "DT/Common/UI/ConversationUI/DT_ConversationUI_Core"

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

    if traderObj.factionID == "Independent" then
        return "Independent Traders"
    end

    return "Unknown Faction"
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
end
