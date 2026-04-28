local Internal = DT_TraderContacts.Internal

function Internal.NormalizeStoredContactEntry(entry)
    if type(entry) ~= "table" then
        return false
    end

    local changed = false

    if entry.requestBackend ~= nil then
        entry.requestBackend = nil
        changed = true
    end

    if entry.contactVisitBackend == "" then
        entry.contactVisitBackend = nil
        changed = true
    end

    if entry.contactVisitActive ~= true then
        local transientKeys = {
            "contactVisitMode",
            "contactVisitBackend",
            "contactVisitRequestedBy",
            "contactVisitRequestedByID",
            "contactVisitTargetX",
            "contactVisitTargetY",
            "contactVisitTargetZ",
            "contactVisitStartedAt",
            "contactVisitReturnStatus",
        }

        for _, key in ipairs(transientKeys) do
            if entry[key] ~= nil then
                entry[key] = nil
                changed = true
            end
        end
    end

    return changed
end

function Internal.NormalizeContactsContainer(container)
    if type(container) ~= "table" then
        return false
    end

    local changed = false
    local characters = type(container.characters) == "table" and container.characters or nil
    if not characters then
        return false
    end

    for _, store in pairs(characters) do
        if type(store) == "table" then
            for _, entry in pairs(store) do
                if Internal.NormalizeStoredContactEntry(entry) then
                    changed = true
                end
            end
        end
    end

    if (tonumber(container.version) or 0) < DT_TraderContacts.VERSION then
        container.version = DT_TraderContacts.VERSION
        changed = true
    end

    return changed
end

function Internal.NormalizeContactStore(store)
    if type(store) ~= "table" then
        return false
    end

    local changed = false
    for _, entry in pairs(store) do
        if Internal.NormalizeStoredContactEntry(entry) then
            changed = true
        end
    end

    return changed
end

function Internal.EnsureCharacterKey(player, modData)
    if not player or not modData then
        return nil
    end

    local stableKey = Internal.GenerateCharacterKey(player)
    local existingKey = modData[DT_TraderContacts.CHARACTER_KEY_MODDATA]
    if existingKey ~= stableKey then
        modData[DT_TraderContacts.CHARACTER_KEY_MODDATA] = stableKey
        Internal.TransmitPlayerModData(player)
    end

    return modData[DT_TraderContacts.CHARACTER_KEY_MODDATA]
end

function Internal.EnsureContainer(modData)
    local raw = modData and modData[DT_TraderContacts.MODDATA_KEY] or nil
    if type(raw) ~= "table" then
        raw = {
            version = DT_TraderContacts.VERSION,
            characters = {},
        }
        modData[DT_TraderContacts.MODDATA_KEY] = raw
        return raw
    end

    if Internal.IsLegacyContactsStore(raw) then
        raw = {
            version = DT_TraderContacts.VERSION,
            characters = {
                legacy = Internal.CloneContactsTable(raw),
            },
        }
        modData[DT_TraderContacts.MODDATA_KEY] = raw
        return raw
    end

    if type(raw.characters) ~= "table" then
        raw.characters = {}
    end
    if raw.version == nil then
        raw.version = DT_TraderContacts.VERSION
    end

    return raw
end

function Internal.EnsureStore(player)
    local modData = player and player:getModData() or nil
    if not modData then
        return nil
    end

    local container = Internal.EnsureContainer(modData)
    local characterKey = Internal.EnsureCharacterKey(player, modData)
    if not container or not characterKey then
        return nil
    end

    local normalizedContainer = Internal.NormalizeContactsContainer(container)

    local characters = container.characters
    if type(characters[characterKey]) ~= "table" then
        if type(characters.legacy) == "table" and Internal.HasTableEntries(characters.legacy) then
            characters[characterKey] = Internal.CloneContactsTable(characters.legacy)
            characters.legacy = nil
            Internal.TransmitPlayerModData(player)
        else
            characters[characterKey] = {}
        end
    end

    if Internal.NormalizeContactStore(characters[characterKey]) then
        normalizedContainer = true
    end

    if normalizedContainer then
        Internal.TransmitPlayerModData(player)
    end

    return characters[characterKey]
end

function DT_TraderContacts.HasContact(traderOrID, player)
    local traderID = traderOrID
    if type(traderOrID) == "table" then
        traderID = DT_TraderContacts.GetTraderID(traderOrID)
    end

    if not traderID then
        return false
    end

    player = player or Internal.GetLocalPlayer()
    local store = Internal.EnsureStore(player)
    if not store then
        return false
    end

    return type(store[tostring(traderID)]) == "table"
end

function DT_TraderContacts.SaveContact(trader, options)
    local player = (options and options.player) or Internal.GetLocalPlayer()
    local store = Internal.EnsureStore(player)
    local normalized = DT_TraderContacts.NormalizeTrader(trader)
    if not store or not normalized then
        return false, nil
    end

    local id = normalized.id
    local existing = type(store[id]) == "table" and store[id] or {}
    local live = DT_TraderContacts.GetRosterSoul and DT_TraderContacts.GetRosterSoul(id) or nil

    existing.id = id
    existing.uuid = id
    existing.traderID = id
    existing.name = normalized.name or (live and live.name) or existing.name
    existing.archetype = normalized.archetype or (live and (live.archetype or live.archetypeID)) or existing.archetype
    existing.gender = normalized.gender or (live and (live.isFemale and "Female" or "Male")) or existing.gender
    existing.identitySeed = normalized.identitySeed or (live and live.identitySeed) or existing.identitySeed
    existing.factionID = (live and live.factionID) or normalized.factionID or existing.factionID
    existing.factionName = (live and live.factionName)
        or normalized.factionName
        or existing.factionName
        or DT_TraderContacts.GetFactionDisplayName((live and live.factionID) or normalized)
    existing.occupation = normalized.occupation or existing.occupation
    existing.canRecruit = (live and live.canRecruit)
        or normalized.canRecruit
        or existing.canRecruit
    existing.allowRecruit = (live and live.allowRecruit)
        or normalized.allowRecruit
        or existing.allowRecruit
    existing.neverRecruitable = (live and live.neverRecruitable)
        or normalized.neverRecruitable
        or existing.neverRecruitable
    existing.returnTime = (live and live.returnTime)
        or normalized.returnTime
        or existing.returnTime
    existing.returnStatus = (live and live.returnStatus)
        or normalized.returnStatus
        or existing.returnStatus
    existing.status = (live and live.status)
        or normalized.status
        or existing.status
    existing.state = (live and live.state)
        or normalized.state
        or existing.state
    existing.lastX = (live and live.lastX)
        or normalized.lastX
        or existing.lastX
    existing.lastY = (live and live.lastY)
        or normalized.lastY
        or existing.lastY
    existing.lastZ = (live and live.lastZ)
        or normalized.lastZ
        or existing.lastZ
    existing.contactVisitActive = (live and live.contactVisitActive)
        or normalized.contactVisitActive
        or existing.contactVisitActive
    existing.contactVisitMode = (live and live.contactVisitMode)
        or normalized.contactVisitMode
        or existing.contactVisitMode
    existing.contactVisitBackend = (live and live.contactVisitBackend)
        or normalized.contactVisitBackend
        or existing.contactVisitBackend
    existing.contactVisitRequestedBy = (live and live.contactVisitRequestedBy)
        or normalized.contactVisitRequestedBy
        or existing.contactVisitRequestedBy
    existing.contactVisitRequestedByID = (live and live.contactVisitRequestedByID)
        or normalized.contactVisitRequestedByID
        or existing.contactVisitRequestedByID
    existing.contactVisitTargetX = (live and live.contactVisitTargetX)
        or normalized.contactVisitTargetX
        or existing.contactVisitTargetX
    existing.contactVisitTargetY = (live and live.contactVisitTargetY)
        or normalized.contactVisitTargetY
        or existing.contactVisitTargetY
    existing.contactVisitTargetZ = (live and live.contactVisitTargetZ)
        or normalized.contactVisitTargetZ
        or existing.contactVisitTargetZ
    existing.contactVisitStartedAt = (live and live.contactVisitStartedAt)
        or normalized.contactVisitStartedAt
        or existing.contactVisitStartedAt
    existing.contactVisitReturnStatus = (live and live.contactVisitReturnStatus)
        or normalized.contactVisitReturnStatus
        or existing.contactVisitReturnStatus
    existing.requestBackend = nil

    Internal.NormalizeStoredContactEntry(existing)
    existing.lastSeenWorldHours = Internal.GetWorldAgeHours()
    existing.rep = DT_TraderContacts.GetEffectiveReputation(live or normalized)
    existing.unlockedAt = existing.unlockedAt or Internal.GetWorldAgeHours()
    existing.debugGranted = options and options.debugGranted == true or existing.debugGranted == true

    store[id] = existing
    Internal.TransmitPlayerModData(player)

    return true, Internal.CloneContact(existing)
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

    player = player or Internal.GetLocalPlayer()
    local store = Internal.EnsureStore(player)
    if not store then
        return nil
    end

    return Internal.CloneContact(store[tostring(traderID)])
end

function DT_TraderContacts.DeleteContact(traderOrID, player)
    local traderID = traderOrID
    if type(traderOrID) == "table" then
        traderID = DT_TraderContacts.GetTraderID(traderOrID)
    end

    if not traderID then
        return false
    end

    player = player or Internal.GetLocalPlayer()
    local store = Internal.EnsureStore(player)
    if not store or type(store[tostring(traderID)]) ~= "table" then
        return false
    end

    store[tostring(traderID)] = nil
    Internal.TransmitPlayerModData(player)
    return true
end

function DT_TraderContacts.GetAllContacts(player)
    player = player or Internal.GetLocalPlayer()
    local store = Internal.EnsureStore(player)
    local contacts = {}
    if not store then
        return contacts
    end

    for _, contact in pairs(store) do
        if type(contact) == "table" then
            contacts[#contacts + 1] = Internal.CloneContact(contact)
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
    player = player or Internal.GetLocalPlayer()
    if not player then
        return false
    end

    return Internal.EnsureStore(player) ~= nil
end
