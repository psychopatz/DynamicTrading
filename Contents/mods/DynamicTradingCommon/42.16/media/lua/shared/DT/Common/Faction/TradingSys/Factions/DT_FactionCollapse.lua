-- ==============================================================================
-- DT_FactionCollapse.lua
-- Roster-aware faction extinction and collapse broadcast helpers.
-- ==============================================================================

require "DT/Common/Faction/TradingSys/RosterLogic/DT_RosterLogic"
require "DT/Common/Logging/GameplayLogs/DT_GameplayLogs"
require "DT/Common/Logging/DT_GameplayLogRegistry"
require "DT/Common/Logging/DT_GameplayEvents"
require "DT/Common/Faction/TradingSys/Factions/DT_FactionRespawnState"

if DynamicTrading and DynamicTrading.LoadGameplayLogRegistry then
    DynamicTrading.LoadGameplayLogRegistry()
end

local Collapse = {}
local FACTIONS_KEY = "DynamicTrading_Factions"
local ROSTER_KEY = "DynamicTrading_Roster"
local BANNER_COMMAND = "FactionCollapseBanner"

local function trim(text)
    text = tostring(text or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function isPureClient()
    return isClient() and not isServer()
end

local function getWorldAgeHours()
    return getGameTime and getGameTime():getWorldAgeHours() or 0
end

local function isSystemOrNomadFaction(factionID, faction)
    local key = tostring(factionID or "")
    local factionType = tostring(faction and faction.factionType or "")
    local homeName = tostring(faction and faction.homeCoords and faction.homeCoords.name or "")

    return key == "" or key == "Independent"
        or factionType == "independent"
        or faction.isNomadic == true
        or homeName == "Nomadic"
        or homeName == "Nomadic Route"
end

function Collapse.IsCollapsed(faction)
    if type(faction) ~= "table" then
        return false
    end
    return tostring(faction.state or "") == "Collapsed" or faction.collapsed == true or faction.collapsedAt ~= nil
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

function Collapse.GetRosterCounts(factionID)
    local roster = ModData.get(ROSTER_KEY)
    local members = roster and roster.FactionMembers and roster.FactionMembers[factionID] or nil
    local souls = roster and roster.Souls or nil
    local total = 0
    local living = 0
    local dead = 0

    if type(members) ~= "table" or type(souls) ~= "table" then
        return total, living, dead
    end

    for _, uuid in ipairs(members) do
        local soul = souls[uuid]
        if type(soul) == "table" then
            total = total + 1
            if isLivingSoul(soul) then
                living = living + 1
            else
                dead = dead + 1
            end
        end
    end

    return total, living, dead
end

local function resolveEntryText(entry)
    if not entry then
        return nil
    end
    if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.ResolveText then
        local text = DynamicTrading.GameplayLogs.ResolveText(entry)
        if trim(text) ~= "" then
            return text
        end
    end
    return entry.text
end

function Collapse.GetLatestFactionEventText(factionID)
    local logKey = DynamicTrading
        and DynamicTrading.GameplayLogs
        and DynamicTrading.GameplayLogs.GetStorageKey
        and DynamicTrading.GameplayLogs.GetStorageKey("Factions")
        or "DynamicTrading_GameplayLogs_Factions"
    local logData = ModData.get(logKey)
    local events = logData and (logData[tostring(factionID)] or logData[factionID]) or nil
    if type(events) ~= "table" then
        return nil
    end

    local collapseEvent = DynamicTrading and DynamicTrading.GameplayEvents and DynamicTrading.GameplayEvents.FACTION_EXTINCT or nil
    for i = 1, #events do
        local entry = events[i]
        if entry and tonumber(entry.e) ~= tonumber(collapseEvent) then
            local text = trim(resolveEntryText(entry))
            if text ~= "" then
                return text
            end
        end
    end

    return nil
end

local function broadcastCollapseBanner(factionID, factionName, reasonText)
    local title = tostring(factionName or factionID or "Colony") .. " Collapsed"
    local subtitle = trim(reasonText)
    if subtitle == "" then
        subtitle = "No survivors remain."
    end

    local payload = {
        factionID = tostring(factionID or ""),
        title = title,
        subtitle = subtitle,
        duration = 4.5,
        variant = "collapse",
        sound = "DT_HordeWarning",
    }

    if DynamicTrading
        and DynamicTrading.ServerHelpers
        and DynamicTrading.ServerHelpers.BroadcastResponse then
        DynamicTrading.ServerHelpers.BroadcastResponse("DynamicTrading", BANNER_COMMAND, payload)
    elseif isServer() and sendServerCommand then
        sendServerCommand("DynamicTrading", BANNER_COMMAND, payload)
    elseif triggerEvent then
        triggerEvent("OnServerCommand", "DynamicTrading", BANNER_COMMAND, payload)
    end
end

function Collapse.CollapseFaction(factionID, faction, context)
    if isPureClient() then
        return false
    end

    local data = ModData.get(FACTIONS_KEY)
    local key = tostring(factionID or "")
    local target = faction or (data and data[key]) or nil
    if key == "" or type(target) ~= "table" then
        return false
    end
    if isSystemOrNomadFaction(key, target) or Collapse.IsCollapsed(target) then
        return false
    end

    context = type(context) == "table" and context or {}
    local factionName = tostring(target.name or key)
    local reasonText = trim(context.latestEventText or Collapse.GetLatestFactionEventText(key) or context.reasonText)
    if reasonText == "" then
        reasonText = "No survivors remain."
    end

    if DT_FactionRespawnState and DT_FactionRespawnState.RecordAbandonedHome then
        DT_FactionRespawnState.RecordAbandonedHome(key, target, tostring(context.reason or "faction_collapsed"))
    end

    target.state = "Collapsed"
    target.memberCount = 0
    target.collapsed = true
    target.collapsedAt = getWorldAgeHours()
    target.collapseReason = tostring(context.reason or "extinction")
    target.collapseLastEvent = reasonText
    target.active = false
    target.excludeFromPopulationPool = true
    target.excludeFromFactionCap = true
    target.refreshPending = nil
    target.CollapseDays = nil

    if DynamicTrading and DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
        local eventID = DynamicTrading.GameplayEvents and DynamicTrading.GameplayEvents.FACTION_EXTINCT or nil
        if eventID then
            DynamicTrading.GameplayLogs.AddFactionEvent(key, eventID, { factionName, reasonText })
        end
        if DynamicTrading.GameplayLogs.AddRadioEvent
            and DynamicTrading.GameplayEvents
            and DynamicTrading.GameplayEvents.FACTION_COLLAPSED then
            DynamicTrading.GameplayLogs.AddRadioEvent(DynamicTrading.GameplayEvents.FACTION_COLLAPSED, { factionName })
        end
        if DynamicTrading.GameplayLogs.FlushChannel then
            DynamicTrading.GameplayLogs.FlushChannel("Factions")
            DynamicTrading.GameplayLogs.FlushChannel("Radio")
        end
    end

    if ModData and ModData.transmit then
        ModData.transmit(FACTIONS_KEY)
        ModData.transmit(ROSTER_KEY)
    end

    broadcastCollapseBanner(key, factionName, reasonText)
    return true
end

function Collapse.AuditFactionExtinction(factionID, context)
    if isPureClient() then
        return false
    end

    local key = tostring(factionID or "")
    local data = ModData.get(FACTIONS_KEY)
    local faction = data and data[key] or nil
    if key == "" or type(faction) ~= "table" then
        return false
    end
    if isSystemOrNomadFaction(key, faction) or Collapse.IsCollapsed(faction) then
        return false
    end

    local total, living, dead = Collapse.GetRosterCounts(key)
    local virtualCount = math.max(0, tonumber(faction.memberCount) or 0)
    if living <= 0 and ((total > 0 and dead > 0) or virtualCount <= 0) then
        return Collapse.CollapseFaction(key, faction, context)
    end

    return false
end

return Collapse
