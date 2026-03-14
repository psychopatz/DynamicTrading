-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/DT_FactionInfoTab_Reputation.lua
-- Tab: Reputation
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "Utils/DT_ReputationManager"

DT_FactionInfoTab_Reputation = ISPanel:derive("DT_FactionInfoTab_Reputation")

function DT_FactionInfoTab_Reputation:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionInfoTab_Reputation:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionInfoTab_Reputation:createChildren()
    self.richText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.richText:initialise()
    self.richText.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.richText.borderColor = {r=0, g=0, b=0, a=0.0}
    self.richText:addScrollBars()
    self.richText:setAnchorRight(true)
    self.richText:setAnchorBottom(true)
    self:addChild(self.richText)
end

function DT_FactionInfoTab_Reputation:onResize()
    ISPanel.onResize(self)
    if self.richText then
        self.richText:paginate()
    end
end

function DT_FactionInfoTab_Reputation:updateData(f)
    self.currentFaction = f
    if not f then 
        self.richText:setText("")
        return 
    end

    local scale = "Medium"
    if self.parent and self.parent.parent and self.parent.parent.fontScale then
        scale = self.parent.parent.fontScale
    end

    local titleTag = "Medium"
    local bodyTag = "Small"
    
    if scale == "Large" then
        titleTag = "Large"
        bodyTag = "Medium"
    elseif scale == "Medium" then
        titleTag = "Medium"
        bodyTag = "Small"
    else
        titleTag = "Small"
        bodyTag = "Small"
    end

    local text = " <RGB:0.4,0.8,1> <SIZE:" .. titleTag .. "> REPUTATION STATUS <SIZE:" .. bodyTag .. "> <LINE> <LINE> "

    if not DT_ReputationManager then
        text = text .. " <RGB:0.6,0.6,0.6> Reputation manager unavailable. <LINE> "
        self.richText:setText(text)
        self.richText:paginate()
        return
    end

    local factionRep = DT_ReputationManager.GetFactionRep(f.id)
    local stageData = DT_ReputationManager.GetStageData(factionRep)
    text = text ..
        " <RGB:0.8,0.8,0.8> Overall faction standing: " ..
        " <RGB:" .. tostring(stageData.color.r) .. "," .. tostring(stageData.color.g) .. "," .. tostring(stageData.color.b) .. "> " ..
        tostring(factionRep) .. " (" .. stageData.label .. ") <LINE> " ..
        " <RGB:0.6,0.6,0.6> Combined buy + sell volume grants +2 personal reputation every $" ..
        tostring(DT_ReputationManager.TRADE_THRESHOLD) .. ". <LINE> <LINE> "

    local rosterData = ModData.get("DynamicTrading_Roster") or {}
    local members = rosterData.FactionMembers and rosterData.FactionMembers[f.id] or {}
    local souls = rosterData.Souls or {}

    if members and #members > 0 then
        text = text .. " <RGB:0.7,0.9,1> Member reactions <LINE> "
        for _, uuid in ipairs(members) do
            local soul = souls[uuid]
            local name = soul and soul.name or uuid
            local effectiveRep = DT_ReputationManager.GetEffectiveRep(uuid, f.id)
            local effectiveStage = DT_ReputationManager.GetStageData(effectiveRep)
            local personalRep = DT_ReputationManager.GetPersonalRep(uuid)
            local totalBought = DT_ReputationManager.GetTotalBought(uuid)
            local totalSold = DT_ReputationManager.GetTotalSold(uuid)
            local tradeProgress = DT_ReputationManager.GetTradeProgress(uuid)

            text = text ..
                " <RGB:0.8,0.8,0.8> " .. tostring(name) .. ": " ..
                " <RGB:" .. tostring(effectiveStage.color.r) .. "," .. tostring(effectiveStage.color.g) .. "," .. tostring(effectiveStage.color.b) .. "> " ..
                tostring(effectiveRep) .. " (" .. effectiveStage.label .. ") " ..
                " <RGB:0.6,0.6,0.6> personal " .. tostring(personalRep) ..
                " | bought $" .. tostring(totalBought) ..
                " | sold $" .. tostring(totalSold) ..
                " | next +2 in $" .. tostring(math.max(0, DT_ReputationManager.TRADE_THRESHOLD - tradeProgress)) ..
                " <LINE> "
        end
    else
        text = text .. " <RGB:0.6,0.6,0.6> No faction roster available yet. <LINE> "
    end
    
    self.richText:setText(text)
    self.richText:paginate()
end
