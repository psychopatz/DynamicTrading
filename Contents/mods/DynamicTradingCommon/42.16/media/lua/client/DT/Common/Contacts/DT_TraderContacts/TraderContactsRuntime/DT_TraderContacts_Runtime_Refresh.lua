local Internal = DT_TraderContacts.Internal

local function applySoulFields(normalized, soul)
    if soul.name ~= nil then normalized.name = soul.name end
    if soul.factionID ~= nil then normalized.factionID = soul.factionID end
    if soul.factionName ~= nil then normalized.factionName = soul.factionName end
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
    if soul.contactVisitActive ~= nil then normalized.contactVisitActive = soul.contactVisitActive end
    if soul.contactVisitMode ~= nil then normalized.contactVisitMode = soul.contactVisitMode end
    if soul.contactVisitBackend ~= nil then normalized.contactVisitBackend = soul.contactVisitBackend end
    if soul.contactVisitRequestedBy ~= nil then normalized.contactVisitRequestedBy = soul.contactVisitRequestedBy end
    if soul.contactVisitRequestedByID ~= nil then normalized.contactVisitRequestedByID = soul.contactVisitRequestedByID end
    if soul.contactVisitTargetX ~= nil then normalized.contactVisitTargetX = soul.contactVisitTargetX end
    if soul.contactVisitTargetY ~= nil then normalized.contactVisitTargetY = soul.contactVisitTargetY end
    if soul.contactVisitTargetZ ~= nil then normalized.contactVisitTargetZ = soul.contactVisitTargetZ end
    if soul.contactVisitStartedAt ~= nil then normalized.contactVisitStartedAt = soul.contactVisitStartedAt end
    if soul.contactVisitReturnStatus ~= nil then normalized.contactVisitReturnStatus = soul.contactVisitReturnStatus end
end

function DT_TraderContacts.RefreshContactData(contact)
    local normalized = DT_TraderContacts.NormalizeTrader(contact)
    local soul
    local factionData
    local factionState
    local listedInFaction
    local deathReason

    if not normalized then
        return nil
    end

    soul = DT_TraderContacts.GetRosterSoul(normalized.id, {
        requestBackend = normalized.contactVisitBackend
    })
    normalized.missingFromRoster = soul == nil
    normalized.factionMissing = DT_TraderContacts.Internal.IsFactionMissing and DT_TraderContacts.Internal.IsFactionMissing(normalized.factionID) or false
    normalized.deathReason = normalized.deathReason
    normalized.deathFlavorText = normalized.deathFlavorText

    factionData = DT_TraderContacts.Internal.GetFactionData and DT_TraderContacts.Internal.GetFactionData(normalized.factionID) or nil
    factionState = tostring(factionData and factionData.state or "")

    if soul then
        applySoulFields(normalized, soul)
        normalized.missingFromRoster = false
        normalized.factionMissing = DT_TraderContacts.Internal.IsFactionMissing and DT_TraderContacts.Internal.IsFactionMissing(normalized.factionID) or false
    end

    if normalized.missingFromRoster and normalized.factionMissing then
        Internal.MarkTraderDead(normalized, "WipedOut", "faction wiped out")
    elseif normalized.missingFromRoster and factionState == "Starving" then
        Internal.MarkTraderDead(normalized, "Starvation", "lost to starvation")
    elseif normalized.missingFromRoster then
        listedInFaction = DT_TraderContacts.Internal.IsTraderListedInFaction
            and DT_TraderContacts.Internal.IsTraderListedInFaction(normalized.id, normalized.factionID)
            or false
        deathReason = listedInFaction and "MissingFromRoster" or "MissingFromFaction"
        Internal.MarkTraderDead(normalized, deathReason, Internal.CloneDeathFlavor(normalized))
    end

    if tostring(normalized.status or "") == "Dead" then
        normalized.state = "Dead"
        Internal.ClearTransientVisitState(normalized)
        if not normalized.deathFlavorText or normalized.deathFlavorText == "" then
            if tostring(normalized.deathReason or "") == "Starvation" then
                normalized.deathFlavorText = "lost to starvation"
            elseif tostring(normalized.deathReason or "") == "WipedOut" then
                normalized.deathFlavorText = "faction wiped out"
            else
                normalized.deathFlavorText = Internal.CloneDeathFlavor(normalized)
            end
        end
    end

    normalized.factionName = DT_TraderContacts.GetFactionDisplayName(normalized)
    normalized.reputation = DT_TraderContacts.GetEffectiveReputation(normalized)
    return normalized
end
