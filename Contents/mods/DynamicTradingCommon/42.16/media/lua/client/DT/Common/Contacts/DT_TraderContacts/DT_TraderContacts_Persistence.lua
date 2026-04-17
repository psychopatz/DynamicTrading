local Internal = DT_TraderContacts.Internal

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

    existing.id = id
    existing.uuid = id
    existing.traderID = id
    existing.name = normalized.name
    existing.archetype = normalized.archetype
    existing.gender = normalized.gender
    existing.identitySeed = normalized.identitySeed
    existing.factionID = normalized.factionID
    existing.factionName = normalized.factionName or DT_TraderContacts.GetFactionDisplayName(normalized)
    existing.occupation = normalized.occupation
    existing.returnTime = normalized.returnTime
    existing.returnStatus = normalized.returnStatus
    existing.status = normalized.status
    existing.state = normalized.state
    existing.lastX = normalized.lastX
    existing.lastY = normalized.lastY
    existing.lastZ = normalized.lastZ
    existing.contactVisitActive = normalized.contactVisitActive
    existing.contactVisitMode = normalized.contactVisitMode
    existing.contactVisitRequestedBy = normalized.contactVisitRequestedBy
    existing.contactVisitRequestedByID = normalized.contactVisitRequestedByID
    existing.contactVisitTargetX = normalized.contactVisitTargetX
    existing.contactVisitTargetY = normalized.contactVisitTargetY
    existing.contactVisitTargetZ = normalized.contactVisitTargetZ
    existing.contactVisitStartedAt = normalized.contactVisitStartedAt
    existing.contactVisitReturnStatus = normalized.contactVisitReturnStatus
    existing.lastSeenWorldHours = Internal.GetWorldAgeHours()
    existing.rep = DT_TraderContacts.GetEffectiveReputation(trader)
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