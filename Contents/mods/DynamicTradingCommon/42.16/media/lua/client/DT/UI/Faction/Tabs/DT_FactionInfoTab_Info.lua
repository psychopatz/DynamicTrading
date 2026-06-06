-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/DT_FactionInfoTab_Info.lua
-- Tab: General Information & Economy
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISRichTextPanel"
require "DT/UI/Faction/Tabs/DT_FactionEventLogPanel"
require "DT/Common/Faction/DT_FactionBasePresentation"

DT_FactionInfoTab_Info = ISPanel:derive("DT_FactionInfoTab_Info")

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function isNomadicFaction(faction)
    local home = type(faction) == "table" and type(faction.homeCoords) == "table" and faction.homeCoords or nil
    local homeName = tostring(home and home.name or "")
    return type(faction) == "table"
        and (faction.isNomadic == true
            or tostring(faction.id or "") == "Independent"
            or tostring(faction.id or "") == "Bandits"
            or tostring(faction.factionType or "") == "independent"
            or tostring(faction.factionType or "") == "bandit"
            or (faction.playerOwned == true and faction.baseConfigured == false)
            or tostring(faction.town or "") == "Nomad"
            or homeName == "Nomadic"
            or homeName == "Nomadic Route")
end

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
        self.richText:setText(" <RGB:0.6,0.6,0.6> " .. T("DTCommon_UI_Faction_NoFactionSelected", nil, "No faction selected."))
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
    text = text .. " <RGB:0.6,0.6,0.6> " .. T("DTCommon_UI_Faction_IdLabel", { id = tostring(f.id) }, "ID: " .. tostring(f.id)) .. " <LINE> <LINE> "
    
    -- V1 Specific Description
    if f.isV1 then
        text = text .. " <RGB:0.8,0.8,0.8> " .. T("DTCommon_UI_Faction_V1Description", nil, "The broad frequency network used by independent survivors and merchants across the exclusion zone.") .. " <LINE> <LINE> "
        text = text .. " <RGB:0.4,0.8,1> " .. T("DTCommon_UI_Faction_NetworkData", nil, "NETWORK DATA:") .. " <LINE> "
        text = text .. " <RGB:0.8,0.8,0.8> " .. T("DTCommon_UI_Faction_NetworkType", nil, "Type: Decentralized Radio Mesh") .. " <LINE> "
        text = text .. " " .. T("DTCommon_UI_Faction_NetworkReach", nil, "Reach: Global (Exclusion Zone)") .. " <LINE> "
    else
        -- Location (V2)
        text = text .. " <RGB:0.4,0.8,1> " .. T("DTCommon_UI_Faction_LocationData", nil, "LOCATION DATA:") .. " <LINE> "
        text = text .. " <RGB:0.8,0.8,0.8> " .. T("DTCommon_UI_Faction_TownLabel", { town = tostring(f.town or T("DTCommon_UI_Faction_NotAvailable", nil, "N/A")) }, "Town: " .. tostring(f.town or "N/A")) .. " <LINE> "
        if isNomadicFaction(f) then
            text = text .. " " .. T("DTCommon_UI_Faction_MobilityNomadic", nil, "Mobility: Nomadic / No fixed base") .. " <LINE> "
            if f.homeCoords
                and f.homeCoords.name
                and tostring(f.homeCoords.name) ~= ""
                and tostring(f.homeCoords.name) ~= "Nomadic"
                and tostring(f.homeCoords.name) ~= "Nomadic Route" then
                text = text .. " " .. T("DTCommon_UI_Faction_RouteAnchor", { anchor = tostring(f.homeCoords.name) }, "Route Anchor: " .. tostring(f.homeCoords.name)) .. " <LINE> "
            end
        elseif f.homeCoords then
            local presentation = DynamicTrading
                and DynamicTrading.FactionBasePresentation
                and DynamicTrading.FactionBasePresentation.GetProfile
                and DynamicTrading.FactionBasePresentation.GetProfile(f)
                or nil
            local baseLabel = presentation and presentation.label or tostring(f.homeCoords.name or T("DTCommon_UI_Faction_UnknownBase", nil, "Unknown Base"))
            local structureName = presentation and presentation.structureName or tostring(f.homeCoords.name or T("DTCommon_UI_Faction_UnknownStructure", nil, "Unknown Structure"))
            local flavor = presentation and presentation.flavor or T("DTCommon_UI_Faction_DefaultFlavor", nil, "An improvised foothold reclaimed from the dead.")

            text = text .. " " .. T("DTCommon_UI_Faction_BaseCoords", {
                base = tostring(baseLabel),
                x = tostring(f.homeCoords.x),
                y = tostring(f.homeCoords.y),
                z = tostring(f.homeCoords.z)
            }, "Base: " .. tostring(baseLabel) .. " (" .. tostring(f.homeCoords.x) .. "," .. tostring(f.homeCoords.y) .. "," .. tostring(f.homeCoords.z) .. ")") .. " <LINE> "
            text = text .. " " .. T("DTCommon_UI_Faction_StructureLabel", { structure = tostring(structureName) }, "Structure: " .. tostring(structureName)) .. " <LINE> "
            text = text .. " <RGB:0.65,0.65,0.65> " .. tostring(flavor) .. " <LINE> "
        else
            text = text .. " " .. T("DTCommon_UI_Faction_BaseNomadic", nil, "Base: NOMADIC (Roaming)") .. " <LINE> "
        end

        if f.playerOwned then
            local ownedStatus = DT_FactionInfoWindow and DT_FactionInfoWindow.cachedOwnedFactionStatus or nil
            local buildingSummary = ownedStatus and ownedStatus.buildings or nil
            text = text .. " <LINE> <RGB:0.4,0.8,1> " .. T("DTCommon_UI_Faction_PlayerControl", nil, "PLAYER CONTROL:") .. " <LINE> "
            text = text .. " <RGB:0.8,0.8,0.8> " .. T("DTCommon_UI_Faction_LeaderRow", { name = tostring(f.leaderUsername or T("DTCommon_UI_Faction_DefaultLeader", nil, "Unknown")) }, "Leader: " .. tostring(f.leaderUsername or "Unknown")) .. " <LINE> "
            text = text .. " " .. T("DTCommon_UI_Faction_ControlMode", { mode = tostring(f.controlMode or "HybridManual") }, "Control Mode: " .. tostring(f.controlMode or "HybridManual")) .. " <LINE> "
            text = text .. " " .. T("DTCommon_UI_Faction_LeadershipState", { state = tostring(f.leadershipState or "Active") }, "Leadership State: " .. tostring(f.leadershipState or "Active")) .. " <LINE> "
            text = text .. " " .. T("DTCommon_UI_Faction_LinkedRecruits", { count = tostring(f.memberCount or 0) }, "Linked Recruits: " .. tostring(f.memberCount or 0)) .. " <LINE> "
            if ownedStatus then
                text = text .. " " .. T("DTCommon_UI_Faction_YourRole", { role = tostring(ownedStatus.role or "Observer") }, "Your Role: " .. tostring(ownedStatus.role or "Observer")) .. " <LINE> "
            end
            text = text .. " " .. T("DTCommon_UI_Faction_PlayerMembers", { count = tostring(#(f.memberUsernames or {})) }, "Player Members: " .. tostring(#(f.memberUsernames or {}))) .. " <LINE> "
            text = text .. " " .. T("DTCommon_UI_Faction_PendingInvites", { count = tostring(#(f.inviteUsernames or {})) }, "Pending Invites: " .. tostring(#(f.inviteUsernames or {}))) .. " <LINE> "
            if tostring(f.leadershipState or "") == "AdminReview" then
                text = text .. " <RGB:1,0.55,0.25> " .. T("DTCommon_UI_Faction_AdminReviewNote", nil, "Admin Review: This colony is preserved but hidden from normal player management until reassigned.") .. " <LINE> "
            end
            if buildingSummary and buildingSummary.housing then
                text = text .. " <LINE> <RGB:0.4,0.8,1> " .. T("DTCommon_UI_Faction_BuildingsHeader", nil, "BUILDINGS:") .. " <LINE> "
                text = text .. " <RGB:0.8,0.8,0.8> " .. T("DTCommon_UI_Faction_ActiveProjects", { count = tostring(buildingSummary.activeProjectCount or 0) }, "Active Projects: " .. tostring(buildingSummary.activeProjectCount or 0)) .. " <LINE> "
                text = text .. " " .. T("DTCommon_UI_Faction_HousingSummary", {
                    housed = tostring(buildingSummary.housing.housedCount or 0),
                    capacity = tostring(buildingSummary.housing.capacity or 0)
                }, "Housing: " .. tostring(buildingSummary.housing.housedCount or 0) .. " / " .. tostring(buildingSummary.housing.capacity or 0) .. " housed") .. " <LINE> "
                text = text .. " " .. T("DTCommon_UI_Faction_UnhousedRecruits", { count = tostring(buildingSummary.housing.unhousedCount or 0) }, "Unhoused Recruits: " .. tostring(buildingSummary.housing.unhousedCount or 0)) .. " <LINE> "
                text = text .. " " .. T("DTCommon_UI_Faction_BarracksCount", { count = tostring((buildingSummary.buildingCounts and buildingSummary.buildingCounts.Barracks) or 0) }, "Barracks: " .. tostring((buildingSummary.buildingCounts and buildingSummary.buildingCounts.Barracks) or 0)) .. " <LINE> "
            end
        end
    end
    
    -- Economy
    text = text .. " <LINE> <RGB:0.4,0.8,1> " .. T("DTCommon_UI_Faction_EconomicData", nil, "ECONOMIC DATA:") .. " <LINE> "
    text = text .. " <RGB:0.2,1,0.2> " .. T("DTCommon_UI_Faction_ColonyWealth", { amount = tostring(f.ColonyWealth or 0) }, "Colony Wealth: $" .. tostring(f.ColonyWealth or 0)) .. " <LINE> "
    text = text .. " <RGB:0.8,0.8,0.8> " .. T("DTCommon_UI_Faction_ValueTrend", { trend = tostring(f.valueTrend or "Stable") }, "Value Trend: " .. tostring(f.valueTrend or "Stable")) .. " <LINE> " 
    
    self.richText:setText(text)
    self.richText:paginate()

    if self.logPanel then
        self.logPanel:updateData(f)
    end
end
