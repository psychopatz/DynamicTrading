return function(context)
    local Public = context.Public

    local getFactionData = context.getFactionData
    local getOwnerUsername = context.getOwnerUsername
    local containsValue = context.containsValue
    local trimName = context.trimName
    local isDynamicColoniesActive = context.isDynamicColoniesActive
    local isAdminReview = context.isAdminReview

    function Public.IsPlayerFaction(faction)
        return type(faction) == "table" and faction.playerOwned == true
    end

    function Public.IsDynamicColoniesEnabled()
        return isDynamicColoniesActive()
    end

    function Public.GetPlayerFactionID(ownerUsername)
        local owner = getOwnerUsername(ownerUsername)
        local data = getFactionData()
        for factionID, faction in pairs(data) do
            if faction.playerOwned then
                context.normalizeMembershipState(faction)
            end
            if faction.playerOwned and not isAdminReview(faction) and (
                getOwnerUsername(faction.leaderUsername) == owner
                or containsValue(faction.memberUsernames, owner)
            ) then
                return factionID
            end
        end
        return nil
    end

    function Public.GetPlayerFaction(ownerUsername)
        local factionID = Public.GetPlayerFactionID(ownerUsername)
        if not factionID then
            return nil
        end
        return getFactionData()[factionID]
    end

    function Public.ValidateFactionName(rawName, ignoreFactionID)
        local name = trimName(rawName)
        if name == "" then
            return false, "Faction name cannot be empty."
        end
        if #name > 32 then
            return false, "Faction name must be 32 characters or less."
        end

        local lowerName = string.lower(name)
        for factionID, faction in pairs(getFactionData()) do
            if factionID ~= ignoreFactionID and string.lower(tostring(faction.name or "")) == lowerName then
                return false, "That faction name is already in use."
            end
        end
        return true, name
    end

    function Public.GetPendingInvites(ownerUsername)
        local owner = getOwnerUsername(ownerUsername)
        local invites = {}
        if not isDynamicColoniesActive() then
            return invites
        end

        for factionID, faction in pairs(getFactionData()) do
            if Public.IsPlayerFaction(faction) and not isAdminReview(faction) then
                context.normalizeMembershipState(faction)
                if containsValue(faction.inviteUsernames, owner) and not Public.GetPlayerFaction(owner) then
                    invites[#invites + 1] = {
                        factionID = factionID,
                        name = faction.name,
                        leaderUsername = faction.leaderUsername,
                        memberCount = faction.memberCount or 0,
                        leadershipState = faction.leadershipState or "Active"
                    }
                end
            end
        end

        table.sort(invites, function(a, b)
            return tostring(a.name or a.factionID) < tostring(b.name or b.factionID)
        end)
        return invites
    end
end
