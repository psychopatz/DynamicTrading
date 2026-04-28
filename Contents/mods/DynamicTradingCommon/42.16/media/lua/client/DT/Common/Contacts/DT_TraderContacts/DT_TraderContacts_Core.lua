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

function Internal.GetFactionData(factionID)
    if not factionID or factionID == "" then
        return nil
    end

    if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
        local faction = DynamicTrading_Factions.GetFaction(factionID)
        if faction then
            return faction
        end
    end

    local factionData = ModData.get and ModData.get("DynamicTrading_Factions") or nil
    return factionData and factionData[factionID] or nil
end

function Internal.ToDisplayWords(value)
    local text = tostring(value or "")
    if text == "" then
        return ""
    end

    text = string.gsub(text, "[_%-]+", " ")
    text = string.gsub(text, "(%l)(%u)", "%1 %2")
    text = string.gsub(text, "%s+", " ")
    text = string.gsub(text, "^%s+", "")
    text = string.gsub(text, "%s+$", "")

    local words = {}
    for word in string.gmatch(text, "%S+") do
        if string.match(word, "^%u+$") then
            words[#words + 1] = word
        else
            words[#words + 1] = string.upper(string.sub(word, 1, 1)) .. string.lower(string.sub(word, 2))
        end
    end

    return table.concat(words, " ")
end

function Internal.FormatFactionIDDisplayName(factionID)
    local text = tostring(factionID or "")
    if text == "" then
        return "Independent"
    end
    if text == "Independent" then
        return "Independent Traders"
    end

    local townID = string.match(text, "^(.-)_%d+$")
    if townID and townID ~= "" then
        return Internal.ToDisplayWords(townID)
    end

    local playerFaction = string.match(text, "^player_(.+)$")
    if playerFaction and playerFaction ~= "" then
        return Internal.ToDisplayWords(playerFaction)
    end

    return Internal.ToDisplayWords(text)
end

function Internal.IsFactionMissing(factionID)
    if not factionID or factionID == "" or factionID == "Independent" then
        return false
    end

    return Internal.GetFactionData(factionID) == nil
end

function Internal.GetRosterData()
    if DT_V2_RadarManager and type(DT_V2_RadarManager.ClientRoster) == "table" then
        return DT_V2_RadarManager.ClientRoster
    end

    return ModData.get and ModData.get("DynamicTrading_Roster") or nil
end

function Internal.IsTraderListedInFaction(traderID, factionID)
    if not traderID or not factionID or factionID == "" then
        return false
    end

    local rosterData = Internal.GetRosterData()
    local members = rosterData and rosterData.FactionMembers and rosterData.FactionMembers[factionID] or nil
    if type(members) ~= "table" then
        return false
    end

    local targetID = tostring(traderID)
    for _, memberID in pairs(members) do
        if tostring(memberID) == targetID then
            return true
        end
    end

    return false
end

function Internal.GetFactionDisplayName(factionID)
    if not factionID or factionID == "" then
        return "Independent"
    end

    local repInternal = DT_Reputation and DT_Reputation.Internal or nil
    if repInternal and repInternal.GetFactionDisplayName then
        local name = repInternal.GetFactionDisplayName(factionID)
        if name and name ~= "" and tostring(name) ~= tostring(factionID) then
            return tostring(name)
        end
    end

    local faction = Internal.GetFactionData(factionID)
    if faction and faction.name and faction.name ~= "" then
        return tostring(faction.name)
    end

    return Internal.FormatFactionIDDisplayName(factionID)
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

function DT_TraderContacts.GetFactionDisplayName(traderOrFaction)
    local factionID = traderOrFaction
    local savedFactionName = nil
    if type(traderOrFaction) == "table" then
        factionID = traderOrFaction.factionID
        savedFactionName = traderOrFaction.factionName
        if traderOrFaction.factionMissing == true then
            return "Wiped Out"
        end
        if savedFactionName and savedFactionName ~= "" and savedFactionName ~= factionID then
            if factionID == nil or factionID == "" or Internal.IsFactionMissing(factionID) then
                return tostring(savedFactionName)
            end
        end
    end

    return Internal.GetFactionDisplayName(factionID)
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
        factionName = trader.factionName,
        occupation = trader.occupation,
        returnTime = trader.returnTime,
        returnStatus = trader.returnStatus,
        status = trader.status,
        state = trader.state,
        lastX = trader.lastX,
        lastY = trader.lastY,
        lastZ = trader.lastZ,
        contactVisitActive = trader.contactVisitActive,
        contactVisitMode = trader.contactVisitMode,
        contactVisitBackend = trader.contactVisitBackend,
        contactVisitRequestedBy = trader.contactVisitRequestedBy,
        contactVisitRequestedByID = trader.contactVisitRequestedByID,
        contactVisitTargetX = trader.contactVisitTargetX,
        contactVisitTargetY = trader.contactVisitTargetY,
        contactVisitTargetZ = trader.contactVisitTargetZ,
        contactVisitStartedAt = trader.contactVisitStartedAt,
        contactVisitReturnStatus = trader.contactVisitReturnStatus,
        canRecruit = trader.canRecruit,
        allowRecruit = trader.allowRecruit,
        neverRecruitable = trader.neverRecruitable,
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

function DT_TraderContacts.GetRequiredReputationForTrader(trader)
    if DynamicTrading and DynamicTrading.GetArchetypeContactRequiredReputation then
        return DynamicTrading.GetArchetypeContactRequiredReputation(trader, DT_TraderContacts.CONTACT_REPUTATION_REQUIRED)
    end

    return DT_TraderContacts.CONTACT_REPUTATION_REQUIRED
end

function DT_TraderContacts.CanUnlock(trader)
    return DT_TraderContacts.GetEffectiveReputation(trader) >= DT_TraderContacts.GetRequiredReputationForTrader(trader)
end
