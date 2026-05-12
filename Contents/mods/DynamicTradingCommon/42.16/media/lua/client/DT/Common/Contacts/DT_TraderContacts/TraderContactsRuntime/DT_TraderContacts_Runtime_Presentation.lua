function DT_TraderContacts.BuildConversationTarget(contact)
    local normalized = DT_TraderContacts.RefreshContactData(contact)

    if not normalized then
        return nil
    end

    normalized.factionName = DT_TraderContacts.GetFactionDisplayName(normalized)
    normalized.returnTime = nil
    normalized.reputation = DT_TraderContacts.GetEffectiveReputation(normalized)
    normalized.isContactConversation = true
    return normalized
end

function DT_TraderContacts.FormatContactSummary(contact)
    local current = DT_TraderContacts.RefreshContactData(contact)
    local rep
    local role

    if not current then
        return "Unknown contact"
    end

    rep = DT_TraderContacts.GetEffectiveReputation(current)
    role = tostring(current.archetype or current.role or "Survivor")
    return string.format("%s  |  %s  |  Rep %d", tostring(current.name or "Unknown"), role, rep)
end
