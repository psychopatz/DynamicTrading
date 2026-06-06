-- ==============================================================================
-- media/lua/client/DT/UI/Faction/Tabs/DT_FactionInfoTab_Infrastructure.lua
-- Tab: Infrastructure, Buildings, and Horde Status
-- ==============================================================================

require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"

local BuildingDefs = require "DT/Common/ColonyEconomy/Buildings/DT_BuildingDefs"

DT_FactionInfoTab_Infrastructure = ISPanel:derive("DT_FactionInfoTab_Infrastructure")

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

local function isNomadicFaction(faction)
    return type(faction) == "table"
        and (faction.isNomadic == true
            or tostring(faction.id or "") == "Independent"
            or tostring(faction.id or "") == "Bandits"
            or tostring(faction.factionType or "") == "independent"
            or tostring(faction.factionType or "") == "bandit")
end

function DT_FactionInfoTab_Infrastructure:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = {r=0, g=0, b=0, a=0}
    o.borderColor = {r=0, g=0, b=0, a=0}
    return o
end

function DT_FactionInfoTab_Infrastructure:initialise()
    ISPanel.initialise(self)
    self:createChildren()
end

function DT_FactionInfoTab_Infrastructure:createChildren()
    self.listContainer = ISPanel:new(0, 0, self.width, self.height)
    self.listContainer:initialise()
    self.listContainer:instantiate()
    self.listContainer.clip = true
    self.listContainer.backgroundColor = {r=0, g=0, b=0, a=0.5}
    self.listContainer.borderColor = {r=0.4, g=0.4, b=0.4, a=0.5}
    self:addChild(self.listContainer)

    self.listbox = ISScrollingListBox:new(0, 0, self.listContainer.width, self.listContainer.height)
    self.listbox:initialise()
    self.listbox:instantiate()
    self.listbox.itemheight = 100
    self.listbox.drawBorder = false
    self.listbox.backgroundColor = {r=0, g=0, b=0, a=0}
    self.listbox.doDrawItem = function(listbox, y, item, alt)
        return self:doDrawItem(y, item, alt)
    end
    self.listContainer:addChild(self.listbox)
end

function DT_FactionInfoTab_Infrastructure:onResize()
    ISPanel.onResize(self)
    if self.listContainer then
        self.listContainer:setWidth(self.width)
        self.listContainer:setHeight(self.height)
    end
    if self.listbox then
        self.listbox:setWidth(self.width)
        self.listbox:setHeight(self.height)
    end
end

function DT_FactionInfoTab_Infrastructure:doDrawItem(y, item, alt)
    local f = self.currentFaction
    local data = item.item
    local lb = self.listbox
    local width = lb:getWidth()
    local height = item.height

    if data.isHeader then
        lb:drawText(data.text, 10, y + 10, 1, 1, 1, 1, UIFont.Medium)
        lb:drawRect(10, y + 32, width - 20, 1, 0.3, 1, 1, 1)
        return y + height
    end

    if data.isSubHeader then
        lb:drawText(data.text, 10, y + 5, 0.8, 0.8, 0.8, 1, UIFont.Small)
        return y + height
    end

    if data.isBuilding then
        local b = data.building
        local def = data.def
        local iconSize = 64
        local padding = 10
        local textX = padding + iconSize + 15

        -- Draw Icon
        if def and def.icon then
            local tex = getTexture("media/" .. def.icon)
            if tex then
                lb:drawTextureScaled(tex, padding, y + padding, iconSize, iconSize, 1, 1, 1, 1)
            else
                lb:drawRect(padding, y + padding, iconSize, iconSize, 0.2, 0.5, 0.5, 0.5)
            end
        end

        -- Draw Title
        local statusColor = {r=0.2, g=0.8, b=0.2, a=1}
        local statusText = T("DTCommon_UI_Faction_Infrastructure_Operational", nil, "Operational")

        if b.level == 0 then
            statusText = T("DTCommon_UI_Faction_Infrastructure_Constructing", nil, "Constructing")
            statusColor = {r=1, g=0.6, b=0, a=1}
        elseif b.hp and b.maxHp and b.hp < b.maxHp then
            statusText = T("DTCommon_UI_Faction_Infrastructure_Damaged", nil, "Damaged")
            statusColor = {r=1, g=0.4, b=0, a=1}
            if b.hp <= 0 then
                statusText = T("DTCommon_UI_Faction_Infrastructure_Destroyed", nil, "DESTROYED")
                statusColor = {r=1, g=0, b=0, a=1}
            end
        end

        local title = T("DTCommon_UI_Faction_Infrastructure_Level", {
            name = tostring(data.name),
            level = tostring(b.level)
        }, tostring(data.name) .. " (Lvl " .. tostring(b.level) .. ")")
        lb:drawText(title, textX, y + 10, 1, 1, 1, 1, UIFont.Medium)
        
        -- Draw Status
        lb:drawText(statusText, textX + 2, y + 32, statusColor.r, statusColor.g, statusColor.b, statusColor.a, UIFont.Small)
        
        -- Draw Workers info
        local workers = b.workers and #b.workers or 0
        lb:drawText(T("DTCommon_UI_Faction_Infrastructure_Workers", { count = tostring(workers) }, "| Workers: " .. tostring(workers)), textX + 100, y + 32, 0.6, 0.6, 0.6, 1, UIFont.Small)

        -- Draw Effect
        if data.effect and data.effect ~= "" then
            lb:drawText(T("DTCommon_UI_Faction_Infrastructure_Effect", { effect = tostring(data.effect) }, "Effect: " .. tostring(data.effect)), textX, y + 52, 0.5, 0.5, 0.5, 1, UIFont.Small)
        end
        
        -- Separator line
        lb:drawRect(textX, y + height - 1, width - textX - 10, 1, 0.1, 1, 1, 1)

        return y + height
    end

    return y + height
end

function DT_FactionInfoTab_Infrastructure:updateData(f)
    self.currentFaction = f
    self.listbox:clear()
    
    if not f then return end

    if isNomadicFaction(f) then
        local isBandit = tostring(f.id or "") == "Bandits" or tostring(f.factionType or "") == "bandit"
        self.listbox:addItem("Nomadic Info", {
            isHeader = true,
            text = isBandit
                and T("DTCommon_UI_Faction_Infrastructure_NomadicRaiders", nil, "NOMADIC RAIDERS")
                or T("DTCommon_UI_Faction_Infrastructure_NomadicNetwork", nil, "NOMADIC NETWORK")
        })
        self.listbox:addItem("Nomadic Text", {
            isSubHeader = true,
            text = isBandit
                and T("DTCommon_UI_Faction_Infrastructure_BanditNomadicDesc", nil, "This faction survives through moving raider cells, temporary camps, and occupied houses.")
                or T("DTCommon_UI_Faction_Infrastructure_NomadicDesc", nil, "This faction operates as a nomadic trading network.")
        })
        self.listbox:addItem("Nomadic Text 2", {
            isSubHeader = true,
            text = T("DTCommon_UI_Faction_Infrastructure_NoFixedBase", nil, "They do not maintain permanent settlements or fixed infrastructure.")
        })
        return
    end

    -- Header
    self.listbox:addItem("Header", { isHeader = true, text = T("DTCommon_UI_Faction_Infrastructure_Header", nil, "COLONY INFRASTRUCTURE") })
    
    -- Status Tag
    local statusText = T("DTCommon_UI_Faction_Infrastructure_StatusNominal", nil, "Operational Status: NOMINAL")
    if f.penalties and (f.penalties.dehydrated or f.penalties.sick or f.penalties.vulnerable) then
        statusText = T("DTCommon_UI_Faction_Infrastructure_StatusCompromised", nil, "Operational Status: COMPROMISED")
    end
    self.listbox:addItem("Status", { isSubHeader = true, text = statusText, height = 25 })

    -- Buildings
    if f.buildings then
        local bKeys = {}
        for k in pairs(f.buildings) do if k ~= "Headquarters" then table.insert(bKeys, k) end end
        table.sort(bKeys)
        table.insert(bKeys, 1, "Headquarters")

        for _, bName in ipairs(bKeys) do
            local b = f.buildings[bName]
            local def = BuildingDefs[bName]
            local effect = ""
            if bName == "Greenhouse" then effect = T("DTCommon_UI_Faction_Infrastructure_Effect_Greenhouse", nil, "10 Water -> 1 Food per worker daily.")
            elseif bName == "WaterGenerator" then effect = T("DTCommon_UI_Faction_Infrastructure_Effect_WaterGenerator", nil, "Produces Fresh Water daily.")
            elseif bName == "ElectricityGenerator" then effect = T("DTCommon_UI_Faction_Infrastructure_Effect_ElectricityGenerator", nil, "Generates Fuel and Power.")
            elseif bName == "Workshop" then effect = T("DTCommon_UI_Faction_Infrastructure_Effect_Workshop", nil, "Produces Ammo and +20% Production.")
            elseif bName == "Laboratory" then effect = T("DTCommon_UI_Faction_Infrastructure_Effect_Laboratory", nil, "Synthesizes Medical Supplies.")
            elseif bName == "Infirmary" then effect = T("DTCommon_UI_Faction_Infrastructure_Effect_Infirmary", nil, "Provides passive Health Regeneration.")
            elseif bName == "Barracks" then effect = T("DTCommon_UI_Faction_Infrastructure_Effect_Barracks", nil, "+2 Population and Recruitment ×2.")
            elseif bName == "Barricade" then effect = T("DTCommon_UI_Faction_Infrastructure_Effect_Barricade", nil, "Defensive barrier against hordes.")
            end

            self.listbox:addItem(bName, {
                isBuilding = true,
                name = bName,
                building = b,
                def = def,
                effect = effect,
                height = 85
            })
        end
    else
        self.listbox:addItem("Empty", { isSubHeader = true, text = T("DTCommon_UI_Faction_Infrastructure_NoData", nil, "No infrastructure data found.") })
    end

    -- Security
    self.listbox:addItem("SecurityHeader", { isHeader = true, text = T("DTCommon_UI_Faction_Infrastructure_SecurityHeader", nil, "SECURITY STATUS") })
    local days = f.daysSinceLastHorde or 0
    self.listbox:addItem("HordeDays", { isSubHeader = true, text = T("DTCommon_UI_Faction_Infrastructure_DaysSinceHorde", { days = tostring(days) }, "Days since last horde: " .. tostring(days)), height = 25 })
    
    local barricade = f.buildings and f.buildings.Barricade
    if barricade then
        local pct = math.floor((barricade.hp / (barricade.maxHp or 1)) * 100)
        self.listbox:addItem("Integrity", { isSubHeader = true, text = T("DTCommon_UI_Faction_Infrastructure_PerimeterIntegrity", { percent = tostring(pct) }, "Perimeter Integrity: " .. tostring(pct) .. "%"), height = 25 })
    end
end
