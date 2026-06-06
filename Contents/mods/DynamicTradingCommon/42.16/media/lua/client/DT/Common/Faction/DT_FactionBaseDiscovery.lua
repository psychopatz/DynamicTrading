require "DT/Common/Map/DT_MapDisplaySystem"
require "DT/Common/Faction/DT_FactionBasePresentation"
require "DT/Common/Faction/DT_FactionDiscoveryBanner"
require "DT/Common/Utils/DT_AudioManager"

DynamicTrading = DynamicTrading or {}
DynamicTrading.FactionBaseDiscovery = DynamicTrading.FactionBaseDiscovery or {}

local Discovery = DynamicTrading.FactionBaseDiscovery
local Presentation = DynamicTrading.FactionBasePresentation
local MapDisplay = DynamicTrading.MapDisplay
local DiscoveryBanner = DynamicTrading.FactionDiscoveryBanner
local AudioManager = DT_AudioManager

local PLAYER_DATA_KEY = "DTFactionBaseDiscovery"
local PROVIDER_ID = "dt_faction_base_discovery"
local CHECK_INTERVAL_TICKS = 15
local ENTER_RADIUS = 32
local EXIT_RADIUS = 38
local BANNER_HOLD_DURATION = 1.0
local MAP_TEXT_LAYER = "text-building"
local DISCOVERY_DATA_VERSION = 2

Discovery.tickCounter = Discovery.tickCounter or 0
Discovery.runtime = Discovery.runtime or {
    currentFactionID = nil,
}

local DiscoveryProvider = {
    updateIntervalTicks = 30,
    requiresLiveMapAPI = true,
}

local function getLocalPlayer()
    if getSpecificPlayer then
        return getSpecificPlayer(0)
    end
    return getPlayer and getPlayer() or nil
end

local function getFactionData()
    local data = ModData.get("DynamicTrading_Factions")
    return type(data) == "table" and data or {}
end

local function hasHomeCoords(homeCoords)
    return type(homeCoords) == "table"
        and tonumber(homeCoords.x) ~= nil
        and tonumber(homeCoords.y) ~= nil
end

local function trim(text)
    text = tostring(text or "")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")
    return text
end

local function hasArrayEntries(values)
    return type(values) == "table" and #values > 0
end

local function getFactionKey(faction)
    local factionID = type(faction) == "table" and faction.id or nil
    if factionID == nil then
        return nil
    end
    return tostring(factionID)
end

local function isPlayerFactionArchived(faction)
    if type(faction) ~= "table" then
        return false
    end

    local leadershipState = tostring(faction.leadershipState or "")
    return leadershipState == "AdminReview" or leadershipState == "Archived"
end

local function hasLivePlayerOwnership(faction)
    if type(faction) ~= "table" then
        return false
    end

    if trim(faction.leaderUsername) ~= "" then
        return true
    end

    if hasArrayEntries(faction.memberUsernames) or hasArrayEntries(faction.inviteUsernames) then
        return true
    end

    return math.max(0, tonumber(faction.memberCount) or 0) > 0
end

local function isNomadicFaction(faction)
    if type(faction) ~= "table" then
        return false
    end

    local factionID = tostring(faction.id or "")
    local factionType = tostring(faction.factionType or "")
    local homeName = tostring(faction.homeCoords and faction.homeCoords.name or "")

    return faction.isNomadic == true
        or factionID == "Independent"
        or factionType == "independent"
        or homeName == "Nomadic"
        or homeName == "Nomadic Route"
end

local function isActiveFactionBase(faction)
    if type(faction) ~= "table" then
        return false
    end

    if faction.isV1 then
        return false
    end

    if isNomadicFaction(faction) or not hasHomeCoords(faction.homeCoords) then
        return false
    end

    if faction.playerOwned == true then
        return not isPlayerFactionArchived(faction) and hasLivePlayerOwnership(faction)
    end

    return math.max(0, tonumber(faction.memberCount) or 0) > 0
end

local function getDistanceSq(playerObj, homeCoords)
    local dx = (tonumber(playerObj:getX()) or 0) - (tonumber(homeCoords.x) or 0)
    local dy = (tonumber(playerObj:getY()) or 0) - (tonumber(homeCoords.y) or 0)
    return (dx * dx) + (dy * dy)
end

local function ensurePlayerDiscoveryData(playerObj)
    if not playerObj then
        return nil
    end

    local modData = playerObj:getModData()
    modData[PLAYER_DATA_KEY] = type(modData[PLAYER_DATA_KEY]) == "table" and modData[PLAYER_DATA_KEY] or {}

    local data = modData[PLAYER_DATA_KEY]
    data.version = math.max(tonumber(data.version) or 0, DISCOVERY_DATA_VERSION)
    data.discovered = type(data.discovered) == "table" and data.discovered or {}
    return data
end

local function savePlayerDiscoveryData(playerObj)
    if playerObj and playerObj.transmitModData then
        playerObj:transmitModData()
    end
end

local function notifyPlayer(playerObj, title, subtitle)
    if not playerObj or not title or title == "" then
        return
    end

    if DiscoveryBanner and DiscoveryBanner.ShowMessage then
        DiscoveryBanner.ShowMessage(title, subtitle or "", BANNER_HOLD_DURATION)
    elseif HaloTextHelper and HaloTextHelper.addText then
        HaloTextHelper.addText(playerObj, title)
    elseif playerObj.Say then
        playerObj:Say(title)
    end
end

local function playCue(soundName)
    if not soundName or soundName == "" then
        return
    end

    if AudioManager and AudioManager.PlayUISound then
        AudioManager.PlayUISound(soundName, 1.0)
    elseif getSoundManager then
        getSoundManager():PlaySound(soundName, false, 1.0)
    end
end

local function onServerCommand(module, command, args)
    if tostring(module or "") ~= "DynamicTrading" or tostring(command or "") ~= "FactionCollapseBanner" then
        return
    end

    args = type(args) == "table" and args or {}
    local title = trim(args.title or "")
    if title == "" then
        return
    end

    if DiscoveryBanner and DiscoveryBanner.ShowMessage then
        DiscoveryBanner.ShowMessage(
            title,
            trim(args.subtitle or ""),
            tonumber(args.duration) or 4.5,
            { variant = tostring(args.variant or "collapse") }
        )
    else
        local playerObj = getLocalPlayer()
        if HaloTextHelper and playerObj then
            HaloTextHelper.addText(playerObj, title)
        end
    end

    playCue(tostring(args.sound or "DT_HordeWarning"))
end

local function forceMarkerRefresh()
    if MapDisplay and MapDisplay.GetProviderState then
        local state = MapDisplay.GetProviderState(PROVIDER_ID)
        if state then
            state.updateCounter = DiscoveryProvider.updateIntervalTicks
        end
    end
end

local function buildDiscoverySnapshot(faction, discoveredAt)
    local homeCoords = faction and faction.homeCoords or {}
    local presentation = Presentation.GetProfile(faction)

    return {
        version = DISCOVERY_DATA_VERSION,
        factionID = getFactionKey(faction),
        factionName = tostring(faction and faction.name or ""),
        playerOwned = faction and faction.playerOwned == true or false,
        discoveredAt = tonumber(discoveredAt) or (getGameTime and getGameTime():getWorldAgeHours() or 0),
        x = tonumber(homeCoords.x) or 0,
        y = tonumber(homeCoords.y) or 0,
        z = tonumber(homeCoords.z) or 0,
        rawName = tostring(homeCoords.name or ""),
        label = tostring(presentation and presentation.label or "Unknown Base"),
        structureName = tostring(presentation and presentation.structureName or "Unknown Structure"),
        siteType = tostring(presentation and presentation.siteType or "Holdout"),
        flavor = tostring(presentation and presentation.flavor or ""),
    }
end

local function normalizeDiscoveryRecord(record, factionID, activeFaction)
    local normalized = type(record) == "table" and record or {}
    local dirty = false

    if activeFaction and isActiveFactionBase(activeFaction) then
        local snapshot = buildDiscoverySnapshot(activeFaction, normalized.discoveredAt)
        for key, value in pairs(snapshot) do
            if normalized[key] ~= value then
                normalized[key] = value
                dirty = true
            end
        end
        return normalized, dirty
    end

    local targetFactionID = tostring(normalized.factionID or factionID or "")
    if normalized.version ~= DISCOVERY_DATA_VERSION then
        normalized.version = DISCOVERY_DATA_VERSION
        dirty = true
    end
    if normalized.factionID ~= targetFactionID then
        normalized.factionID = targetFactionID
        dirty = true
    end
    if normalized.discoveredAt == nil then
        normalized.discoveredAt = getGameTime and getGameTime():getWorldAgeHours() or 0
        dirty = true
    end
    if normalized.x ~= nil then
        local numericX = tonumber(normalized.x) or 0
        if normalized.x ~= numericX then
            normalized.x = numericX
            dirty = true
        end
    end
    if normalized.y ~= nil then
        local numericY = tonumber(normalized.y) or 0
        if normalized.y ~= numericY then
            normalized.y = numericY
            dirty = true
        end
    end
    if normalized.z ~= nil then
        local numericZ = tonumber(normalized.z) or 0
        if normalized.z ~= numericZ then
            normalized.z = numericZ
            dirty = true
        end
    end

    local fallbackLabel = trim(normalized.label or normalized.factionName or targetFactionID or "Known Base")
    if fallbackLabel == "" then
        fallbackLabel = "Known Base"
    end

    local fallbackStructure = trim(normalized.structureName or normalized.baseName or normalized.rawName or "")
    if fallbackStructure == "" then
        fallbackStructure = "Known Structure"
    end

    if trim(normalized.label) ~= fallbackLabel then
        normalized.label = fallbackLabel
        dirty = true
    end
    if trim(normalized.structureName) ~= fallbackStructure then
        normalized.structureName = fallbackStructure
        dirty = true
    end
    if normalized.siteType == nil then
        normalized.siteType = "Holdout"
        dirty = true
    end
    if normalized.flavor == nil then
        normalized.flavor = ""
        dirty = true
    end

    return normalized, dirty
end

local function syncDiscoveryRecords(playerObj)
    local discoveryData = ensurePlayerDiscoveryData(playerObj)
    if not discoveryData then
        return {}
    end

    local discovered = discoveryData.discovered or {}
    local factions = getFactionData()
    local dirty = false

    for factionID, record in pairs(discovered) do
        local normalizedRecord, recordDirty = normalizeDiscoveryRecord(record, factionID, factions[tostring(factionID)])
        if normalizedRecord ~= record then
            discovered[factionID] = normalizedRecord
            dirty = true
        end
        if recordDirty then
            discovered[factionID] = normalizedRecord
            dirty = true
        end
    end

    if dirty then
        savePlayerDiscoveryData(playerObj)
    end

    return discovered
end

local function markFactionDiscovered(playerObj, faction)
    local data = ensurePlayerDiscoveryData(playerObj)
    local factionID = getFactionKey(faction)
    if not data or not factionID then
        return false
    end

    local existing = data.discovered[factionID]
    local snapshot = buildDiscoverySnapshot(faction)

    if existing then
        local normalized, dirty = normalizeDiscoveryRecord(existing, factionID, faction)
        if normalized ~= existing or dirty then
            data.discovered[factionID] = normalized
            savePlayerDiscoveryData(playerObj)
            forceMarkerRefresh()
        end
        return false
    end

    data.discovered[factionID] = snapshot

    savePlayerDiscoveryData(playerObj)
    forceMarkerRefresh()
    return true
end

local function getFactionByID(factionID)
    if not factionID then
        return nil
    end

    local faction = getFactionData()[tostring(factionID)]
    if isActiveFactionBase(faction) then
        return faction
    end

    return nil
end

local function findNearestFactionInRadius(playerObj, radius)
    if not playerObj then
        return nil
    end

    local nearestFaction = nil
    local nearestDistSq = nil
    local maxDistSq = radius * radius

    for _, faction in pairs(getFactionData()) do
        if isActiveFactionBase(faction) then
            local distSq = getDistanceSq(playerObj, faction.homeCoords)
            if distSq <= maxDistSq and (nearestDistSq == nil or distSq < nearestDistSq) then
                nearestFaction = faction
                nearestDistSq = distSq
            end
        end
    end

    return nearestFaction, nearestDistSq
end

local function leaveCurrentFaction(playerObj, currentFaction)
    local presentation = currentFaction and Presentation.GetProfile(currentFaction) or nil
    if presentation then
        notifyPlayer(playerObj, "Leaving " .. presentation.label, presentation.structureName)
        playCue("DC_FactionOut")
    end
    Discovery.runtime.currentFactionID = nil
end

local function enterFaction(playerObj, faction)
    if not faction then
        return
    end

    local presentation = Presentation.GetProfile(faction)
    local discoveredNow = markFactionDiscovered(playerObj, faction)

    if discoveredNow then
        notifyPlayer(playerObj, "You discovered " .. presentation.label, presentation.structureName)
    else
        notifyPlayer(playerObj, "Entering " .. presentation.label, presentation.structureName)
    end
    playCue("DC_FactionIn")

    Discovery.runtime.currentFactionID = tostring(faction.id)
end

function Discovery.Update()
    local playerObj = getLocalPlayer()
    if not playerObj or playerObj:isDead() then
        Discovery.runtime.currentFactionID = nil
        return
    end

    local currentFaction = getFactionByID(Discovery.runtime.currentFactionID)
    if currentFaction then
        local currentDistSq = getDistanceSq(playerObj, currentFaction.homeCoords)
        if currentDistSq <= (EXIT_RADIUS * EXIT_RADIUS) then
            return
        end

        leaveCurrentFaction(playerObj, currentFaction)
    else
        Discovery.runtime.currentFactionID = nil
    end

    local enteredFaction = findNearestFactionInRadius(playerObj, ENTER_RADIUS)
    if enteredFaction then
        enterFaction(playerObj, enteredFaction)
    end
end

function DiscoveryProvider.isEnabled(playerObj)
    return playerObj ~= nil
end

function DiscoveryProvider.getMarkers(playerObj)
    local markers = {}
    local discovered = syncDiscoveryRecords(playerObj)

    for _, record in pairs(discovered) do
        local worldX = tonumber(record and record.x) or 0
        local worldY = tonumber(record and record.y) or 0
        local label = trim(record and record.label or "")
        local structureName = trim(record and record.structureName or "")

        if worldX ~= 0 or worldY ~= 0 then
            markers[#markers + 1] = {
                symbolID = "House",
                x = worldX,
                y = worldY,
                r = 0.93,
                g = 0.78,
                b = 0.28,
                a = 0.95,
                scale = 0.70,
                anchorX = 0.5,
                anchorY = 0.75,
                minZoom = 9.5,
            }

            if label ~= "" then
                markers[#markers + 1] = {
                    type = "text",
                    text = label,
                    layerID = MAP_TEXT_LAYER,
                    x = worldX,
                    y = worldY + 6,
                    r = 0.96,
                    g = 0.90,
                    b = 0.74,
                    a = 0.98,
                    scale = 0.82,
                    anchorX = 0.5,
                    anchorY = 0.0,
                    minZoom = 0.0,
                    applyZoom = false,
                    matchPerspective = false,
                }
            end

            if structureName ~= "" then
                markers[#markers + 1] = {
                    type = "text",
                    text = structureName,
                    layerID = MAP_TEXT_LAYER,
                    x = worldX,
                    y = worldY + 11,
                    r = 0.82,
                    g = 0.82,
                    b = 0.82,
                    a = 0.96,
                    scale = 0.68,
                    anchorX = 0.5,
                    anchorY = 0.0,
                    minZoom = 0.0,
                    applyZoom = false,
                    matchPerspective = false,
                }
            end
        end
    end

    return markers
end

function Discovery.OnCreatePlayer(playerIndex, playerObj)
    if playerIndex ~= 0 then
        return
    end

    ensurePlayerDiscoveryData(playerObj)
    forceMarkerRefresh()
end

function Discovery.OnGameStart()
    forceMarkerRefresh()
end

function Discovery.OnTick()
    Discovery.tickCounter = (Discovery.tickCounter or 0) + 1
    if Discovery.tickCounter < CHECK_INTERVAL_TICKS then
        return
    end

    Discovery.tickCounter = 0
    Discovery.Update()
end

if MapDisplay and MapDisplay.RegisterProvider then
    MapDisplay.RegisterProvider(PROVIDER_ID, DiscoveryProvider)
end

if not Discovery.eventsAdded then
    Events.OnTick.Add(Discovery.OnTick)
    Events.OnCreatePlayer.Add(Discovery.OnCreatePlayer)
    Events.OnGameStart.Add(Discovery.OnGameStart)
    Events.OnServerCommand.Add(onServerCommand)
    Discovery.eventsAdded = true
end

return Discovery
