local Internal = DT_TraderContacts.Internal

function Internal.SanitizeKeyPart(value)
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

function Internal.GetLocalPlayer()
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

function Internal.GetWorldAgeHours()
    local gt = getGameTime and getGameTime() or nil
    return tonumber(gt and gt:getWorldAgeHours() or 0) or 0
end

function Internal.CloneContact(contact)
    if type(contact) ~= "table" then
        return nil
    end

    local copy = {}
    for key, value in pairs(contact) do
        copy[key] = value
    end
    return copy
end

function Internal.CloneContactsTable(store)
    local copy = {}
    for key, value in pairs(store or {}) do
        if type(value) == "table" then
            copy[tostring(key)] = Internal.CloneContact(value)
        end
    end
    return copy
end

function Internal.HasTableEntries(value)
    if type(value) ~= "table" then
        return false
    end

    for _ in pairs(value) do
        return true
    end

    return false
end

function Internal.IsLegacyContactsStore(value)
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

    return Internal.HasTableEntries(value)
end

function Internal.GenerateCharacterKey(player)
    local desc = player and player:getDescriptor() or nil
    local first = desc and desc:getForename() or "Survivor"
    local last = desc and desc:getSurname() or "Unknown"
    local username = player and player.getUsername and player:getUsername() or "local"
    local steamID = player and player.getSteamID and player:getSteamID() or "nosteam"
    local mode = (isClient() and not isServer()) and "MP" or "SP"

    return table.concat({
        Internal.SanitizeKeyPart(mode),
        Internal.SanitizeKeyPart(username),
        Internal.SanitizeKeyPart(steamID),
        Internal.SanitizeKeyPart(first),
        Internal.SanitizeKeyPart(last),
    }, "_")
end

function Internal.TransmitPlayerModData(player)
    if isClient() and player and player.transmitModData then
        player:transmitModData()
    end
end

function DT_TraderContacts.GetRequiredReputation()
    return DT_TraderContacts.CONTACT_REPUTATION_REQUIRED
end

function DT_TraderContacts.GetVisitRequiredReputation()
    return DT_TraderContacts.VISIT_REPUTATION_REQUIRED
end

function DT_TraderContacts.GetVisitCost()
    return DT_TraderContacts.VISIT_REPUTATION_COST
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
    return DT_TraderContacts.GetEffectiveReputation(trader) >= DT_TraderContacts.CONTACT_REPUTATION_REQUIRED
end