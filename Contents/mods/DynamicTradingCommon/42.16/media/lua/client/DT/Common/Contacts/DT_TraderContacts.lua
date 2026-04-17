-- =============================================================================
-- DYNAMIC TRADING: TRADER CONTACTS
-- =============================================================================
-- Shared client-side helpers for unlocking, persisting, and reading trader
-- contact data from player modData.
-- =============================================================================

require "DT/Common/Reputation/DT_Reputation"

DT_TraderContacts = DT_TraderContacts or {}

local CONTACTS_MODDATA_KEY = "DT_TraderContacts"
local CONTACTS_CHARACTER_KEY_MODDATA = "DT_TraderContactsCharacterKey"
local CONTACT_REPUTATION_REQUIRED = 20
local VISIT_REPUTATION_REQUIRED = 10
local VISIT_REPUTATION_COST = 2

local function sanitizeKeyPart(value)
    local text = tostring(value or "unknown")
    text = string.gsub(text, "[^%w%-_]+", "_")
    text = string.gsub(text, "_+", "_")
    text = string.gsub(text, "^_+", "")
    text = string.gsub(text, "_+$", "")
    if text == "" then
        return "unknown"
    end
    return text
end

local function getLocalPlayer()
    if getSpecificPlayer then
        local player = getSpecificPlayer(0)
        if player then
            return player
        end
    end
    if getPlayer then
        return getPlayer()
    end
    return nil
end

local function getWorldAgeHours()
    local gt = getGameTime and getGameTime() or nil
    return tonumber(gt and gt:getWorldAgeHours() or 0) or 0
end

local function cloneContact(contact)
    if type(contact) ~= "table" then
        return nil
    end

    local copy = {}
    for key, value in pairs(contact) do
        copy[key] = value
    end
    return copy
end

local function cloneContactsTable(store)
    local copy = {}
    for key, value in pairs(store or {}) do
        if type(value) == "table" then
            copy[tostring(key)] = cloneContact(value)
        end
    end
    return copy
end

local function hasTableEntries(value)
    if type(value) ~= "table" then
        return false
    end

    for _ in pairs(value) do
        return true
    end

    return false
end

local function isLegacyContactsStore(value)
    if type(value) ~= "table" then
        return false
    end

    if type(value.characters) == "table" then
        return false
    end

    for key, entry in pairs(value) do
        if type(entry) == "table" and (entry.id or entry.uuid or entry.traderID or entry.name) then
            return true
        end
        if type(key) ~= "string" and type(key) ~= "number" then
            return false
        end
    end

    return hasTableEntries(value)
end

local function generateCharacterKey(player)
    local desc = player and player:getDescriptor() or nil
    local first = desc and desc:getForename() or "Survivor"
    local last = desc and desc:getSurname() or "Unknown"
    local username = player and player.getUsername and player:getUsername() or "local"
    local steamID = player and player.getSteamID and player:getSteamID() or "nosteam"
    local mode = (isClient() and not isServer()) and "MP" or "SP"

    return table.concat({
        sanitizeKeyPart(mode),
        sanitizeKeyPart(username),
        sanitizeKeyPart(steamID),
        sanitizeKeyPart(first),
        sanitizeKeyPart(last),
    }, "_")
end

local function transmitPlayerModData(player)
    if isClient() and player and player.transmitModData then
        player:transmitModData()
    end
end

local function ensureCharacterKey(player, modData)
    if not player or not modData then
        return nil
    end

    local stableKey = generateCharacterKey(player)
    local existingKey = modData[CONTACTS_CHARACTER_KEY_MODDATA]
    if existingKey ~= stableKey then
        modData[CONTACTS_CHARACTER_KEY_MODDATA] = stableKey
        transmitPlayerModData(player)
    end

    return modData[CONTACTS_CHARACTER_KEY_MODDATA]
end

local function ensureContainer(modData)
    local raw = modData and modData[CONTACTS_MODDATA_KEY] or nil
    if type(raw) ~= "table" then
        raw = {
            version = 2,
            characters = {},
        }
        modData[CONTACTS_MODDATA_KEY] = raw
        return raw
    end

    if isLegacyContactsStore(raw) then
        raw = {
            version = 2,
            characters = {
                legacy = cloneContactsTable(raw),
            },
        }
        modData[CONTACTS_MODDATA_KEY] = raw
        return raw
    end

    if type(raw.characters) ~= "table" then
        raw.characters = {}
    end
    if raw.version == nil then
        raw.version = 2
    end

    return raw
end

local function ensureStore(player)
    local modData = player and player:getModData() or nil
    if not modData then
        return nil
    end

    local container = ensureContainer(modData)
    local characterKey = ensureCharacterKey(player, modData)
    if not container or not characterKey then
        return nil
    end

    local characters = container.characters
    if type(characters[characterKey]) ~= "table" then
        if type(characters.legacy) == "table" and hasTableEntries(characters.legacy) then
            characters[characterKey] = cloneContactsTable(characters.legacy)
            characters.legacy = nil
            transmitPlayerModData(player)
        else
            characters[characterKey] = {}
        end
    end

    return characters[characterKey]
end

local function getRosterSource()
    if DT_V2_RadarManager and DT_V2_RadarManager.ClientRoster and type(DT_V2_RadarManager.ClientRoster.Souls) == "table" then
        return DT_V2_RadarManager.ClientRoster.Souls
    end

    local roster = ModData.get and ModData.get("DynamicTrading_Roster") or nil
    if roster and type(roster.Souls) == "table" then
        return roster.Souls
    end

    return nil
end

function DT_TraderContacts.GetRequiredReputation()
    return CONTACT_REPUTATION_REQUIRED
end

function DT_TraderContacts.GetVisitRequiredReputation()
    return VISIT_REPUTATION_REQUIRED
end

function DT_TraderContacts.GetVisitCost()
    return VISIT_REPUTATION_COST
end

function DT_TraderContacts.GetTraderID(trader)
    if type(trader) ~= "table" then
        return nil
    end
    return trader.uuid or trader.traderID or trader.id
end

function DT_TraderContacts.NormalizeTrader(trader)
    local traderID = DT_TraderContacts.GetTraderID(trader)
    if not traderID then
        return nil
    end

    return {
        id = tostring(traderID),
        uuid = tostring(traderID),
        traderID = tostring(traderID),
        name = tostring(trader.name or "Unknown Trader"),
        archetype = tostring(trader.archetype or trader.archetypeID or trader.role or "Survivor"),
        gender = tostring(trader.gender or (trader.isFemale and "Female" or "Male") or "Male"),
        identitySeed = tonumber(trader.identitySeed) or 1,
        factionID = trader.factionID,
        occupation = trader.occupation,
        returnTime = trader.returnTime,
        returnStatus = trader.returnStatus,
        status = trader.status,
        state = trader.state,
        lastX = trader.lastX,
        lastY = trader.lastY,
        lastZ = trader.lastZ,
    }
end

function DT_TraderContacts.GetEffectiveReputation(trader)
    local traderID = DT_TraderContacts.GetTraderID(trader)
    if not traderID then
        return 0
    end

    if DT_Reputation and DT_Reputation.GetEffectiveRep then
        return tonumber(DT_Reputation.GetEffectiveRep(tostring(traderID), trader and trader.factionID) or 0) or 0
    end

    return tonumber(trader and trader.reputation or 0) or 0
end

function DT_TraderContacts.CanUnlock(trader)
    return DT_TraderContacts.GetEffectiveReputation(trader) >= CONTACT_REPUTATION_REQUIRED
end

function DT_TraderContacts.HasContact(traderOrID, player)
    local traderID = traderOrID
    if type(traderOrID) == "table" then
        traderID = DT_TraderContacts.GetTraderID(traderOrID)
    end

    if not traderID then
        return false
    end

    player = player or getLocalPlayer()
    local store = ensureStore(player)
    if not store then
        return false
    end

    return type(store[tostring(traderID)]) == "table"
end

function DT_TraderContacts.SaveContact(trader, options)
    local player = (options and options.player) or getLocalPlayer()
    local store = ensureStore(player)
    local normalized = DT_TraderContacts.NormalizeTrader(trader)
    if not store or not normalized then
        return false, nil
    end

    local id = normalized.id
    local existing = type(store[id]) == "table" and store[id] or {}

    existing.id = id
    existing.uuid = id
    existing.traderID = id
    existing.name = normalized.name
    existing.archetype = normalized.archetype
    existing.gender = normalized.gender
    existing.identitySeed = normalized.identitySeed
    existing.factionID = normalized.factionID
    existing.occupation = normalized.occupation
    existing.returnTime = normalized.returnTime
    existing.returnStatus = normalized.returnStatus
    existing.status = normalized.status
    existing.state = normalized.state
    existing.lastX = normalized.lastX
    existing.lastY = normalized.lastY
    existing.lastZ = normalized.lastZ
    existing.lastSeenWorldHours = getWorldAgeHours()
    existing.rep = DT_TraderContacts.GetEffectiveReputation(trader)
    existing.unlockedAt = existing.unlockedAt or getWorldAgeHours()
    existing.debugGranted = options and options.debugGranted == true or existing.debugGranted == true

    store[id] = existing
    transmitPlayerModData(player)

    return true, cloneContact(existing)
end

function DT_TraderContacts.UnlockContact(trader, options)
    if not trader then
        return false, "invalid"
    end

    if DT_TraderContacts.HasContact(trader, options and options.player) then
        local _, saved = DT_TraderContacts.SaveContact(trader, options)
        return true, saved, "existing"
    end

    if not (options and options.ignoreReputation == true) and not DT_TraderContacts.CanUnlock(trader) then
        return false, "rep"
    end

    local ok, saved = DT_TraderContacts.SaveContact(trader, options)
    if not ok then
        return false, "save"
    end

    return true, saved, "new"
end

function DT_TraderContacts.GetContact(traderOrID, player)
    local traderID = traderOrID
    if type(traderOrID) == "table" then
        traderID = DT_TraderContacts.GetTraderID(traderOrID)
    end

    if not traderID then
        return nil
    end

    player = player or getLocalPlayer()
    local store = ensureStore(player)
    if not store then
        return nil
    end

    local contact = store[tostring(traderID)]
    return cloneContact(contact)
end

function DT_TraderContacts.GetAllContacts(player)
    player = player or getLocalPlayer()
    local store = ensureStore(player)
    local contacts = {}
    if not store then
        return contacts
    end

    for _, contact in pairs(store) do
        if type(contact) == "table" then
            contacts[#contacts + 1] = cloneContact(contact)
        end
    end

    table.sort(contacts, function(a, b)
        local nameA = string.lower(tostring(a and a.name or ""))
        local nameB = string.lower(tostring(b and b.name or ""))
        if nameA == nameB then
            return tostring(a and a.id or "") < tostring(b and b.id or "")
        end
        return nameA < nameB
    end)

    return contacts
end

function DT_TraderContacts.EnsureLoaded(player)
    player = player or getLocalPlayer()
    if not player then
        return false
    end

    return ensureStore(player) ~= nil
end

function DT_TraderContacts.GetRosterSoul(traderOrID)
    local traderID = traderOrID
    if type(traderOrID) == "table" then
        traderID = DT_TraderContacts.GetTraderID(traderOrID)
    end

    if not traderID then
        return nil
    end

    local souls = getRosterSource()
    local soul = souls and souls[tostring(traderID)] or nil
    if type(soul) ~= "table" then
        return nil
    end

    return cloneContact(soul)
end

function DT_TraderContacts.RefreshContactData(contact)
    local normalized = DT_TraderContacts.NormalizeTrader(contact)
    if not normalized then
        return nil
    end

    local soul = DT_TraderContacts.GetRosterSoul(normalized.id)
    if soul then
        if soul.name ~= nil then normalized.name = soul.name end
        if soul.factionID ~= nil then normalized.factionID = soul.factionID end
        if soul.archetypeID ~= nil then normalized.archetype = soul.archetypeID end
        if soul.isFemale ~= nil then normalized.gender = soul.isFemale and "Female" or "Male" end
        if soul.identitySeed ~= nil then normalized.identitySeed = soul.identitySeed end
        if soul.status ~= nil then normalized.status = soul.status end
        if soul.state ~= nil then normalized.state = soul.state end
        if soul.returnTime ~= nil then normalized.returnTime = soul.returnTime end
        if soul.returnStatus ~= nil then normalized.returnStatus = soul.returnStatus end
        if soul.lastX ~= nil then normalized.lastX = soul.lastX end
        if soul.lastY ~= nil then normalized.lastY = soul.lastY end
        if soul.lastZ ~= nil then normalized.lastZ = soul.lastZ end
    end

    normalized.reputation = DT_TraderContacts.GetEffectiveReputation(normalized)
    return normalized
end

function DT_TraderContacts.GetStatusText(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    if not current then
        return "Status unknown"
    end

    local status = tostring(current.status or "Unknown")
    local state = tostring(current.state or "")
    local returnStatus = tostring(current.returnStatus or "")
    local visitMode = tostring(current.contactVisitMode or "")
    local visitActive = current.contactVisitActive == true

    if status == "Resting" then
        return "Status: Resting at base"
    end
    if status == "Trading" and visitActive and (visitMode == "Follow" or state == "Follow") then
        return "Status: Called in and following your lead"
    end
    if status == "Trading" and visitActive and (visitMode == "Guard" or state == "Guard") then
        return "Status: Called in and guarding nearby"
    end
    if status == "Trading" then
        return "Status: Trading in the field"
    end
    if status == "Away" and visitActive and returnStatus == "Trading" then
        return "Status: Moving toward your area"
    end
    if status == "Away" and returnStatus == "Trading" then
        return "Status: En route to trade"
    end
    if status == "Away" and returnStatus == "Resting" then
        return "Status: Returning home"
    end
    if state ~= "" then
        return "Status: " .. state
    end

    return "Status: " .. status
end

function DT_TraderContacts.CanRequestVisit(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    if not current then
        return false, "unknown", nil
    end

    if DT_TraderContacts.GetEffectiveReputation(current) < VISIT_REPUTATION_REQUIRED then
        return false, "rep", current
    end

    local soul = DT_TraderContacts.GetRosterSoul(current.id)
    if not soul then
        return false, "unsupported", current
    end

    if tostring(current.status or "") ~= "Resting" then
        return false, "state", current
    end

    return true, nil, current
end

function DT_TraderContacts.RequestVisit(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    local allowed, reason, hydrated = DT_TraderContacts.CanRequestVisit(current)
    if not allowed then
        return false, reason, hydrated
    end

    local player = getLocalPlayer()
    if not player then
        return false, "player", hydrated
    end

    sendClientCommand(player, "DTNPC", "RequestTraderVisit", {
        uuid = hydrated.id,
        x = math.floor(player:getX()),
        y = math.floor(player:getY()),
        z = math.floor(player:getZ()),
    })

    if DT_Reputation and DT_Reputation.ModifyPersonalRep then
        DT_Reputation.ModifyPersonalRep(hydrated.id, hydrated.factionID, -VISIT_REPUTATION_COST, "contact_visit_request")
    end

    local stayHours = SandboxVars and SandboxVars.DynamicTrading and SandboxVars.DynamicTrading.NPCTradingStayHours or 4.0
    hydrated.status = "Trading"
    hydrated.state = "Follow"
    hydrated.returnStatus = "Away"
    hydrated.returnTime = getWorldAgeHours() + stayHours
    hydrated.contactVisitActive = true
    hydrated.contactVisitMode = "Follow"
    hydrated.contactVisitRequestedBy = player.getUsername and player:getUsername() or nil
    hydrated.contactVisitRequestedByID = player.getOnlineID and player:getOnlineID() or nil
    hydrated.contactVisitTargetX = math.floor(player:getX())
    hydrated.contactVisitTargetY = math.floor(player:getY())
    hydrated.contactVisitTargetZ = math.floor(player:getZ())
    hydrated.contactVisitStartedAt = getWorldAgeHours()
    hydrated.contactVisitReturnStatus = "Resting"
    hydrated.reputation = DT_TraderContacts.GetEffectiveReputation(hydrated)

    DT_TraderContacts.SaveContact(hydrated)
    if DT_V2_RadarManager and DT_V2_RadarManager.RequestRoster then
        DT_V2_RadarManager.RequestRoster()
    end

    return true, hydrated, stayHours
end

function DT_TraderContacts.BuildConversationTarget(contact)
    local normalized = DT_TraderContacts.RefreshContactData(contact)
    if not normalized then
        return nil
    end

    normalized.reputation = DT_TraderContacts.GetEffectiveReputation(normalized)
    normalized.isContactConversation = true
    return normalized
end

function DT_TraderContacts.FormatContactSummary(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    if not current then
        return "Unknown contact"
    end

    local rep = DT_TraderContacts.GetEffectiveReputation(current)
    local role = tostring(current.archetype or current.role or "Survivor")
    return string.format("%s  |  %s  |  Rep %d", tostring(current.name or "Unknown"), role, rep)
end

local function onCreatePlayer()
    DT_TraderContacts.EnsureLoaded()
end

local function onGameStart()
    DT_TraderContacts.EnsureLoaded()
end

if not DT_TraderContacts.EventsRegistered then
    Events.OnCreatePlayer.Add(onCreatePlayer)
    Events.OnGameStart.Add(onGameStart)
    DT_TraderContacts.EventsRegistered = true
end

return DT_TraderContacts