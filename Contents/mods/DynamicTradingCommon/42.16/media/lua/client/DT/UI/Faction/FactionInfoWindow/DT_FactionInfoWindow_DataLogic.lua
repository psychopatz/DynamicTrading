pcall(require, "DT/Common/GeolocatorSystem/DT_GeolocatorSystem")

local function trimText(value)
    local text = tostring(value or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function normalizeLocationKey(value)
    if DT_GeolocatorSystem and DT_GeolocatorSystem.NormalizeLocationKey then
        return DT_GeolocatorSystem.NormalizeLocationKey(value)
    end

    local key = string.lower(trimText(value))
    key = key:gsub(",%s*ky$", "")
    key = key:gsub("%s+ky$", "")
    key = key:gsub("[^%w]", "")
    if key == "" then
        return nil
    end
    return key
end

local function isCollapsedFaction(faction)
    return type(faction) == "table"
        and (faction.collapsed == true
            or faction.collapsedAt ~= nil
            or tostring(faction.state or "") == "Collapsed")
end

local function isNomadicFaction(factionID, faction)
    local id = tostring(factionID or (faction and faction.id) or "")
    local factionType = tostring(faction and faction.factionType or "")
    local homeName = tostring(faction and faction.homeCoords and faction.homeCoords.name or "")
    return id == "Independent"
        or id == "Bandits"
        or factionType == "independent"
        or factionType == "bandit"
        or (faction and faction.isNomadic == true)
        or homeName == "Nomadic"
        or homeName == "Nomadic Route"
end

local function isLivingSoul(soul)
    if type(soul) ~= "table" then
        return false
    end

    local status = tostring(soul.status or "")
    local state = tostring(soul.state or "")
    if status == "Dead" or state == "Dead" or soul.deathFinalizedAt ~= nil then
        return false
    end

    local combatHealth = tonumber(soul.combatHealthCurrent)
    if combatHealth ~= nil and combatHealth <= 0 and status ~= "Away" and status ~= "Trading" then
        return false
    end

    local health = tonumber(soul.health)
    if health ~= nil and health <= 0 and status ~= "Away" and status ~= "Trading" then
        return false
    end

    return true
end

local function getKnownRosterCounts(factionID, rosterData)
    local members = rosterData and rosterData.FactionMembers and rosterData.FactionMembers[factionID] or nil
    local souls = rosterData and rosterData.Souls or nil
    if type(members) ~= "table" or type(souls) ~= "table" then
        return nil, nil
    end

    local known = 0
    local living = 0
    for _, uuid in ipairs(members) do
        local soul = souls[uuid]
        if type(soul) == "table" then
            known = known + 1
            if isLivingSoul(soul) then
                living = living + 1
            end
        end
    end

    if known <= 0 then
        return nil, nil
    end
    return living, known
end

local function getDisplayMemberCount(factionID, faction, rosterData)
    if not faction then
        return 0
    end
    if faction.isV1 then
        if DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetDiscoveredCount then
            return DynamicTrading.Manager.GetDiscoveredCount(getSpecificPlayer(0))
        end
        return tonumber(faction.memberCount) or 0
    end
    if isCollapsedFaction(faction) then
        return 0
    end

    local living, known = getKnownRosterCounts(factionID, rosterData)
    local memberCount = math.max(0, math.floor(tonumber(faction.memberCount) or 0))
    if living ~= nil and known ~= nil and known >= memberCount then
        return living
    end
    return memberCount
end

local function shouldShowFaction(factionID, faction, rosterData)
    if type(faction) ~= "table" then
        return false
    end
    if faction.playerOwned and tostring(faction.leadershipState or "") == "AdminReview" then
        return false
    end
    if faction.isV1 then
        return true
    end
    if isCollapsedFaction(faction) then
        return false
    end

    local count = getDisplayMemberCount(factionID, faction, rosterData)
    if count > 0 then
        return true
    end
    return faction.playerOwned == true or isNomadicFaction(factionID, faction)
end

local function getPlayerSortContext()
    local player = getSpecificPlayer and getSpecificPlayer(0) or getPlayer and getPlayer() or nil
    local x = player and player.getX and player:getX() or nil
    local y = player and player.getY and player:getY() or nil
    local town = nil
    if x and y and DT_GeolocatorSystem and DT_GeolocatorSystem.GetTownName then
        town = DT_GeolocatorSystem.GetTownName(math.floor(x), math.floor(y))
    elseif x and y and DTM and DTM.GetTownName then
        town = DTM.GetTownName(math.floor(x), math.floor(y))
    end

    return {
        x = tonumber(x),
        y = tonumber(y),
        townKey = normalizeLocationKey(town),
    }
end

local function getFactionDistanceSq(faction, sortContext)
    local home = faction and faction.homeCoords or nil
    local fx = tonumber(home and home.x)
    local fy = tonumber(home and home.y)
    local px = sortContext and sortContext.x or nil
    local py = sortContext and sortContext.y or nil
    if not fx or not fy or not px or not py then
        return 999999999
    end

    local dx = fx - px
    local dy = fy - py
    return (dx * dx) + (dy * dy)
end

local function getFactionTownKey(faction)
    local home = faction and faction.homeCoords or nil
    return normalizeLocationKey(faction and faction.town)
        or normalizeLocationKey(home and home.town)
        or normalizeLocationKey(home and home.county)
end

local function getSortBucket(factionID, faction, ownedFactionID, sortContext)
    if ownedFactionID and tostring(factionID or "") == tostring(ownedFactionID) then
        return 0
    end
    if faction and faction.playerOwned == true then
        return 0
    end
    if isNomadicFaction(factionID, faction) then
        return 1
    end

    local playerTownKey = sortContext and sortContext.townKey or nil
    local factionTownKey = getFactionTownKey(faction)
    if playerTownKey and factionTownKey and playerTownKey == factionTownKey then
        return 2
    end
    return 3
end

local function buildFactionListRows(factionData, rosterData, ownedFactionID)
    local rows = {}
    local sortContext = getPlayerSortContext()

    for id, faction in pairs(factionData or {}) do
        if shouldShowFaction(id, faction, rosterData) then
            local displayFaction = DT_FactionInfoWindow.shallowCopy(faction)
            displayFaction.id = displayFaction.id or id
            displayFaction.memberCount = getDisplayMemberCount(id, faction, rosterData)
            rows[#rows + 1] = {
                id = id,
                faction = displayFaction,
                bucket = getSortBucket(id, faction, ownedFactionID, sortContext),
                distanceSq = getFactionDistanceSq(faction, sortContext),
                townKey = getFactionTownKey(faction) or "",
                nameKey = string.lower(tostring(faction.name or id)),
            }
        end
    end

    table.sort(rows, function(a, b)
        if a.bucket ~= b.bucket then
            return a.bucket < b.bucket
        end
        if a.bucket >= 2 and a.distanceSq ~= b.distanceSq then
            return a.distanceSq < b.distanceSq
        end
        if a.townKey ~= b.townKey then
            return a.townKey < b.townKey
        end
        if a.nameKey ~= b.nameKey then
            return a.nameKey < b.nameKey
        end
        return tostring(a.id or "") < tostring(b.id or "")
    end)

    return rows
end

function DT_FactionInfoWindow:refreshList()
    local player = getSpecificPlayer(0)
    if not player then return end

    local isV1 = (DynamicTrading and DynamicTrading.Manager and DynamicTrading.Manager.GetData) ~= nil

    -- Request Data
    if isClient() and not isServer() then
        if DT_FactionInfoWindow.cachedFactionData then
            self:populateList(DT_FactionInfoWindow.cachedFactionData, DT_FactionInfoWindow.cachedRosterData)
        end
        if self.updateOwnedFactionStatus then
            self:updateOwnedFactionStatus(DT_FactionInfoWindow.cachedOwnedFactionStatus, DT_FactionInfoWindow.selectedFaction)
        end
        sendClientCommand(player, "DynamicTrading_V2", "RequestFactionData", {})
        return
    end
    
    -- Singleplayer Direct Access
    local factionData = DT_FactionInfoWindow.resolveFactionData()
    local rosterData = DT_FactionInfoWindow.resolveRosterData()
    if DynamicTrading_Factions and DynamicTrading_Factions.GetOwnedFactionStatus then
        DT_FactionInfoWindow.cachedOwnedFactionStatus = DynamicTrading_Factions.GetOwnedFactionStatus(player)
    end
    
    self:populateList(factionData, rosterData)
end

function DT_FactionInfoWindow:populateList(factionData, rosterData)
    factionData = DT_FactionInfoWindow.InjectV1VirtualFaction(factionData)

    if not factionData then return end
    if not self.listbox then return end
    self.listbox:clear()
    
    -- If rosterData wasn't passed (e.g. from network callback old sig), try to get cached
    if not rosterData then
        rosterData = DT_FactionInfoWindow.cachedRosterData or {}
    end

    local ownedFactionID = DT_FactionInfoWindow.GetOwnedFactionID and DT_FactionInfoWindow.GetOwnedFactionID() or nil
    local preferredFactionID = (DT_FactionInfoWindow.selectedFaction and DT_FactionInfoWindow.selectedFaction.id) or ownedFactionID
    local selectedIndex = nil
    local rows = buildFactionListRows(factionData, rosterData, ownedFactionID)

    for _, row in ipairs(rows) do
        self.listbox:addItem(row.faction.name or row.id, row.faction)
        if preferredFactionID and tostring(preferredFactionID) == tostring(row.id) then
            selectedIndex = #self.listbox.items
        end
    end
    
    -- Preserve existing selection when possible, otherwise select the first row.
    if self.listbox.items and #self.listbox.items > 0 then
        local targetIndex = selectedIndex or 1
        self.listbox.selected = targetIndex
        self:applyFactionSelection(self.listbox.items[targetIndex].item, false)
    else
        DT_FactionInfoWindow.selectedFaction = nil
    end
end
