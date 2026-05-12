return function(context)
    local Public = context.Public
    local Utils = context.Utils

    local getFactionData = context.getFactionData
    local getOwnerUsername = context.getOwnerUsername
    local removeValue = context.removeValue
    local ensureUniqueUsernames = context.ensureUniqueUsernames
    local trimName = context.trimName
    local isDynamicColoniesActive = context.isDynamicColoniesActive
    local isAdminReview = context.isAdminReview

    function Public.MarkFactionAdminReview(factionID, reason)
        if not isDynamicColoniesActive() then
            return nil
        end

        local faction = factionID and getFactionData()[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return nil
        end

        return context.markAdminReview(faction, reason)
    end

    function Public.AdminRestoreFactionLeader(factionID, targetUsername)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

        local target = getOwnerUsername(targetUsername)
        if trimName(target) == "" then
            return false, "A target username is required.", nil
        end

        local faction = factionID and getFactionData()[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end

        faction.leaderUsername = target
        faction.leadershipState = "Active"
        faction.controlMode = "HybridManual"
        faction.regencyReason = nil
        faction.previousLeaderUsername = nil
        faction.memberUsernames = ensureUniqueUsernames(faction.memberUsernames)
        faction.inviteUsernames = ensureUniqueUsernames(faction.inviteUsernames)
        removeValue(faction.memberUsernames, target)
        removeValue(faction.inviteUsernames, target)
        context.syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Leader restored to " .. tostring(target) .. ".", faction, {
            targetUsername = target,
            leaderUsername = target
        }
    end

    function Public.AdminArchiveFaction(factionID)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

        local faction = factionID and getFactionData()[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end

        context.markAdminReview(faction, "admin_archived")
        faction.leadershipState = "Archived"
        faction.controlMode = "Archived"
        faction.regencyReason = "admin_archived"
        context.syncFactionToColony(faction, { createIfMissing = false })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Colony archive preserved.", faction
    end

    function Public.AdminDeleteFactionArchive(factionID)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

        local data = getFactionData()
        local faction = factionID and data[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end

        local state = tostring(faction.leadershipState or "")
        if state ~= "AdminReview" and state ~= "Archived" then
            return false, "Only Admin Review or Archived colonies can be deleted here.", faction
        end

        context.deleteColonyArchiveData(faction)
        if DynamicTrading_Roster and DynamicTrading_Roster.ClearSouls then
            DynamicTrading_Roster.ClearSouls(factionID)
        end
        data[factionID] = nil
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Colony archive deleted.", nil
    end

    function Public.SyncFactionToColony(factionID)
        local faction = factionID and getFactionData()[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return false
        end

        return context.syncFactionToColony(faction, { createIfMissing = not isAdminReview(faction) })
    end
end
