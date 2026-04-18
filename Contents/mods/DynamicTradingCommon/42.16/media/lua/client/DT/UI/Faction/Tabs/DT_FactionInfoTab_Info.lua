-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/DT_FactionInfoTab_Info.lua
-- Tab: General Information & Economy
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "DT/UI/Faction/Tabs/DT_FactionEventLogPanel"

DT_FactionInfoTab_Info = ISPanel:derive("DT_FactionInfoTab_Info")

function DT_FactionInfoTab_Info:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionInfoTab_Info:initialise()
    ISPanel.initialise(self)
end

function DT_FactionInfoTab_Info:createChildren()
    self.richText = ISRichTextPanel:new(0, 0, self.width, self.height)
    self.richText:initialise()
    self.richText.backgroundColor = {r=0, g=0, b=0, a=0.0}
    self.richText.borderColor = {r=0, g=0, b=0, a=0.0}
    self.richText:addScrollBars()
    self.richText:setAnchorRight(true)
    self.richText:setAnchorBottom(false)
    self:addChild(self.richText)

    -- Event Log Section
    self.logPanel = DT_FactionEventLogPanel:new(0, self.height * 0.6, self.width, self.height * 0.4)
    self.logPanel:initialise()
    self.logPanel:setAnchorRight(true)
    self.logPanel:setAnchorBottom(true)
    self:addChild(self.logPanel)
end

function DT_FactionInfoTab_Info:onResize()
    ISPanel.onResize(self)
    if self.richText then
        self.richText:setWidth(self.width)
        self.richText:setHeight(self.height * 0.6)
        self.richText:paginate()
    end
    if self.logPanel then
        self.logPanel:setY(self.height * 0.6)
        self.logPanel:setWidth(self.width)
        self.logPanel:setHeight(self.height * 0.4)
        self.logPanel:onResize()
    end
end

function DT_FactionInfoTab_Info:updateData(f)
    self.currentFaction = f
    if not f then 
        self.richText:setText(" <RGB:0.6,0.6,0.6> No faction selected.")
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

    local text = " <RGB:1,0.8,0> <SIZE:" .. titleTag .. "> " .. f.name .. " <SIZE:" .. bodyTag .. "> <LINE> "
    text = text .. " <RGB:0.6,0.6,0.6> ID: " .. f.id .. " <LINE> <LINE> "
    
    -- V1 Specific Description
    if f.isV1 then
        text = text .. " <RGB:0.8,0.8,0.8> The broad frequency network used by independent survivors and merchants across the exclusion zone. <LINE> <LINE> "
        text = text .. " <RGB:0.4,0.8,1> NETWORK DATA: <LINE> "
        text = text .. " <RGB:0.8,0.8,0.8> Type: Decentralized Radio Mesh <LINE> "
        text = text .. " Reach: Global (Exclusion Zone) <LINE> "
    else
        -- Location (V2)
        text = text .. " <RGB:0.4,0.8,1> LOCATION DATA: <LINE> "
        text = text .. " <RGB:0.8,0.8,0.8> Town: " .. tostring(f.town or "N/A") .. " <LINE> "
        if f.homeCoords then
            text = text .. " Base: " .. f.homeCoords.name .. " (" .. f.homeCoords.x .. "," .. f.homeCoords.y .. "," .. f.homeCoords.z .. ") <LINE> "
        else
            text = text .. " Base: NOMADIC (Roaming) <LINE> "
        end

        if f.playerOwned then
            local ownedStatus = DT_FactionInfoWindow and DT_FactionInfoWindow.cachedOwnedFactionStatus or nil
            local buildingSummary = ownedStatus and ownedStatus.buildings or nil
            text = text .. " <LINE> <RGB:0.4,0.8,1> PLAYER CONTROL: <LINE> "
            text = text .. " <RGB:0.8,0.8,0.8> Leader: " .. tostring(f.leaderUsername or "Unknown") .. " <LINE> "
            text = text .. " Control Mode: " .. tostring(f.controlMode or "HybridManual") .. " <LINE> "
            text = text .. " Leadership State: " .. tostring(f.leadershipState or "Active") .. " <LINE> "
            text = text .. " Linked Recruits: " .. tostring(f.memberCount or 0) .. " <LINE> "
            if ownedStatus then
                text = text .. " Your Role: " .. tostring(ownedStatus.role or "Observer") .. " <LINE> "
            end
            text = text .. " Player Members: " .. tostring(#(f.memberUsernames or {})) .. " <LINE> "
            text = text .. " Pending Invites: " .. tostring(#(f.inviteUsernames or {})) .. " <LINE> "
            if tostring(f.leadershipState or "") == "AdminReview" then
                text = text .. " <RGB:1,0.55,0.25> Admin Review: This colony is preserved but hidden from normal player management until reassigned. <LINE> "
            end
            if buildingSummary and buildingSummary.housing then
                text = text .. " <LINE> <RGB:0.4,0.8,1> BUILDINGS: <LINE> "
                text = text .. " <RGB:0.8,0.8,0.8> Active Projects: " .. tostring(buildingSummary.activeProjectCount or 0) .. " <LINE> "
                text = text .. " Housing: "
                    .. tostring(buildingSummary.housing.housedCount or 0)
                    .. " / "
                    .. tostring(buildingSummary.housing.capacity or 0)
                    .. " housed <LINE> "
                text = text .. " Unhoused Recruits: " .. tostring(buildingSummary.housing.unhousedCount or 0) .. " <LINE> "
                text = text .. " Barracks: " .. tostring((buildingSummary.buildingCounts and buildingSummary.buildingCounts.Barracks) or 0) .. " <LINE> "
            end
        end
    end
    
    -- Economy
    text = text .. " <LINE> <RGB:0.4,0.8,1> ECONOMIC DATA: <LINE> "
    text = text .. " <RGB:0.2,1,0.2> Colony Wealth: $" .. tostring(f.ColonyWealth or 0) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> Value Trend: " .. (f.valueTrend or "Stable") .. " <LINE> " 
    
    self.richText:setText(text)
    self.richText:paginate()

    if self.logPanel then
        self.logPanel:updateData(f)
    end
end
