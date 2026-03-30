local Utils = require "DT/Common/Faction/TradingSys/Factions/PlayerOwnership/PlayerOwnership_Utils"

return function(Public, Internal)
    local getFactionData = Utils.getFactionData
    local getOwnerUsername = Utils.getOwnerUsername
    local findWorkerByID = Utils.findWorkerByID
    local isWorkerLiving = Utils.isWorkerLiving
    local removeValue = Utils.removeValue
    local containsValue = Utils.containsValue
    local copyArray = Utils.copyArray
    local ensureUniqueUsernames = Utils.ensureUniqueUsernames
    local getFactionRole = Utils.getFactionRole
    local trimName = Utils.trimName
    local sanitizeID = Utils.sanitizeID
    local getWorkersForOwner = Utils.getWorkersForOwner
    local buildFactionHome = Utils.buildFactionHome
    local appendUnique = Utils.appendUnique
    local getWorkerSummary = Utils.getWorkerSummary
    local isWorkerRegistryAvailable = Utils.isWorkerRegistryAvailable

    local function normalizeMembershipState(faction)
        if not faction then
            return
        end

        faction.memberUsernames = ensureUniqueUsernames(faction.memberUsernames)
        faction.inviteUsernames = ensureUniqueUsernames(faction.inviteUsernames)

        local leader = getOwnerUsername(faction.leaderUsername)
        faction.leaderUsername = leader
        removeValue(faction.memberUsernames, leader)
        removeValue(faction.inviteUsernames, leader)
    end

    local function buildPermissions(faction, username)
        local role = getFactionRole(faction, username)
        local isLeader = role == "leader"
        local isMember = role == "member"
        return {
            role = role,
            canViewFaction = isLeader or isMember,
            canManageColony = isLeader or isMember,
            canManageWorkers = isLeader or isMember,
            canManageBuildings = isLeader or isMember,
            canManageTrade = isLeader or isMember,
            canInviteMembers = isLeader,
            canRemoveMembers = isLeader,
            canRenameFaction = isLeader,
            canDisbandFaction = isLeader
        }
    end

    local function syncLinkedWorkersFromOwner(faction, owner)
        if not faction or not isWorkerRegistryAvailable() then return false end
        faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
        local ownerWorkers = getWorkersForOwner(owner)
        for _, worker in ipairs(ownerWorkers) do
            if worker and worker.workerID and isWorkerLiving(worker) then
                appendUnique(faction.linkedWorkerIDs, worker.workerID)
            end
        end
        return true
    end
    Internal.syncLinkedWorkersFromOwner = syncLinkedWorkersFromOwner

    local function buildFactionWorkerSummaries(faction)
        local summaries = {}
        if not faction or not faction.playerOwned then return summaries end
        local owner = getOwnerUsername(faction.leaderUsername)
        faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
        faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
        for _, workerID in ipairs(faction.linkedWorkerIDs) do
            local worker = findWorkerByID(owner, workerID)
            if worker then
                local summary = getWorkerSummary(worker)
                local tradeSoulUUID = faction.tradeWorkerSouls[workerID]
                local tradeSoul = tradeSoulUUID and DynamicTrading_Roster.GetSoulRegistry(tradeSoulUUID) or nil
                local tradeActive = faction.activeTradeWorkerIDs[workerID] == true
                if tradeSoul then
                    tradeActive = tradeSoul.status == "Away" or tradeSoul.status == "Trading"
                end
                summary.tradeEligible = faction.tradeEligibleWorkerIDs[workerID] == true
                summary.tradeActive = tradeActive
                summary.tradeStatus = tradeSoul and tradeSoul.status or nil
                summary.tradeSoulUUID = tradeSoulUUID
                summary.isLinkedFactionMember = true
                summaries[#summaries + 1] = summary
            end
        end
        table.sort(summaries, function(a, b)
            return tostring(a.name or a.workerID) < tostring(b.name or b.workerID)
        end)
        return summaries
    end
    Internal.buildFactionWorkerSummaries = buildFactionWorkerSummaries

    local function collapseFaction(factionID, reason)
        local data = getFactionData()
        local faction = data[factionID]
        if not faction then return false end
        if DynamicTrading_Roster and DynamicTrading_Roster.ClearSouls then
            DynamicTrading_Roster.ClearSouls(factionID)
        end
        data[factionID] = nil
        ModData.transmit(Utils.MOD_DATA_KEY)
        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Collapsed player faction [" .. tostring(factionID) .. "] reason=" .. tostring(reason or "unknown"))
        return true
    end
    Internal.collapseFaction = collapseFaction

    function Public.IsPlayerFaction(faction)
        return type(faction) == "table" and faction.playerOwned == true
    end

    function Public.GetPlayerFactionID(ownerUsername)
        local owner = getOwnerUsername(ownerUsername)
        local data = getFactionData()
        for factionID, faction in pairs(data) do
            if faction.playerOwned then
                normalizeMembershipState(faction)
            end
            if faction.playerOwned and (
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
        if not factionID then return nil end
        return getFactionData()[factionID]
    end

    function Public.ValidateFactionName(rawName, ignoreFactionID)
        local name = trimName(rawName)
        if name == "" then return false, "Faction name cannot be empty." end
        if #name > 32 then return false, "Faction name must be 32 characters or less." end
        local lowerName = string.lower(name)
        for factionID, faction in pairs(getFactionData()) do
            if factionID ~= ignoreFactionID and string.lower(tostring(faction.name or "")) == lowerName then
                return false, "That faction name is already in use."
            end
        end
        return true, name
    end

    function Public.RefreshPlayerFaction(factionID)
        local data = getFactionData()
        local faction = data[factionID]
        if not Public.IsPlayerFaction(faction) then return faction end
        normalizeMembershipState(faction)
        local owner = getOwnerUsername(faction.leaderUsername)
        faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
        faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
        faction.controlMode = faction.controlMode or "HybridManual"
        faction.leadershipState = faction.leadershipState or "Active"
        if not syncLinkedWorkersFromOwner(faction, owner) then
            faction.memberCount = math.max(tonumber(faction.memberCount) or 0, #(faction.linkedWorkerIDs or {}))
            return faction
        end
        local livingCount = 0
        local staleIDs = {}
        for _, workerID in ipairs(faction.linkedWorkerIDs) do
            local worker = findWorkerByID(owner, workerID)
            if not worker then
                staleIDs[#staleIDs + 1] = workerID
            elseif isWorkerLiving(worker) then
                livingCount = livingCount + 1
                local tradeUUID = faction.tradeWorkerSouls[workerID]
                if tradeUUID then
                    local soul = DynamicTrading_Roster.GetSoulRegistry(tradeUUID)
                    if soul then
                        Internal.updateSoulFromWorker(tradeUUID, worker, faction)
                        if soul.status == "Away" or soul.status == "Trading" then
                            faction.activeTradeWorkerIDs[workerID] = true
                        else
                            faction.activeTradeWorkerIDs[workerID] = nil
                        end
                    else
                        faction.tradeWorkerSouls[workerID] = nil
                        faction.activeTradeWorkerIDs[workerID] = nil
                    end
                else
                    faction.activeTradeWorkerIDs[workerID] = nil
                end
            else
                faction.activeTradeWorkerIDs[workerID] = nil
            end
        end
        for _, workerID in ipairs(staleIDs) do
            removeValue(faction.linkedWorkerIDs, workerID)
            Internal.clearWorkerTradeLink(faction, workerID, true)
        end
        faction.memberCount = livingCount
        if livingCount <= 0 then
            collapseFaction(factionID, "no_linked_workers")
            return nil
        end
        ModData.transmit(Utils.MOD_DATA_KEY)
        return faction
    end

    function Public.RefreshAllPlayerFactions()
        local data = getFactionData()
        local ids = {}
        for factionID, faction in pairs(data) do
            if faction.playerOwned then ids[#ids + 1] = factionID end
        end
        for _, factionID in ipairs(ids) do Public.RefreshPlayerFaction(factionID) end
    end

    function Public.BuildOwnedFactionStatus(ownerUsername)
        local owner = getOwnerUsername(ownerUsername)
        local registryReady = isWorkerRegistryAvailable()
        local workers = registryReady and getWorkersForOwner(owner) or {}
        local livingWorkers = {}
        for _, worker in ipairs(workers) do
            if isWorkerLiving(worker) then livingWorkers[#livingWorkers + 1] = worker end
        end
        local faction = Public.GetPlayerFaction(owner)
        if faction then faction = Public.RefreshPlayerFaction(faction.id) or nil end
        local role = getFactionRole(faction, owner)
        local permissions = buildPermissions(faction, owner)
        local authorityOwner = faction and getOwnerUsername(faction.leaderUsername) or owner
        local linkedWorkers = faction and buildFactionWorkerSummaries(faction) or {}
        local buildingsSummary = DT_Buildings and DT_Buildings.GetOwnerSummary and DT_Buildings.GetOwnerSummary(authorityOwner) or nil
        local workerCount = registryReady and #livingWorkers or (faction and math.max(tonumber(faction.memberCount) or 0, #(faction.linkedWorkerIDs or {})) or 0)
        return {
            ownerUsername = authorityOwner,
            memberUsername = owner,
            canCreate = faction == nil and registryReady and #livingWorkers >= 1,
            workerCount = workerCount,
            faction = faction,
            buildings = buildingsSummary,
            linkedWorkers = linkedWorkers,
            role = role,
            isLeader = role == "leader",
            isMember = role == "member",
            permissions = permissions,
            memberUsernames = faction and copyArray(faction.memberUsernames) or {},
            inviteUsernames = faction and copyArray(faction.inviteUsernames) or {},
            createBlockedReason = faction and "already_has_faction" or ((not registryReady) and "syncing" or (#livingWorkers < 1 and "needs_recruit" or nil))
        }
    end

    function Public.CreatePlayerFaction(player, rawName)
        local owner = getOwnerUsername(player)
        if Public.GetPlayerFaction(owner) then return false, "You already control a faction.", nil end
        local isValid, nameOrReason = Public.ValidateFactionName(rawName)
        if not isValid then return false, nameOrReason, nil end
        local workers = getWorkersForOwner(owner)
        local linkedWorkerIDs = {}
        for _, worker in ipairs(workers) do
            if isWorkerLiving(worker) then linkedWorkerIDs[#linkedWorkerIDs + 1] = worker.workerID end
        end
        if #linkedWorkerIDs < 1 then return false, "You need at least one living recruit before founding a faction.", nil end
        local factionID = "player_" .. sanitizeID(owner)
        local homeCoords = buildFactionHome(player, workers)
        DynamicTrading_Factions.CreateFaction(factionID, {
            playerOwned = true,
            leaderUsername = owner,
            leadershipState = "Active",
            regencyReason = nil,
            controlMode = "HybridManual",
            name = nameOrReason,
            town = homeCoords.town,
            homeCoords = homeCoords,
            memberCount = #linkedWorkerIDs,
            memberUsernames = {},
            inviteUsernames = {},
            linkedWorkerIDs = linkedWorkerIDs,
            tradeEligibleWorkerIDs = {},
            activeTradeWorkerIDs = {},
            tradeWorkerSouls = {},
            createdDay = getGameTime() and getGameTime():getDaysSurvived() or 0
        })
        local faction = Public.RefreshPlayerFaction(factionID)
        return faction ~= nil, faction and "Faction founded." or "Faction creation failed.", faction
    end

    function Public.InvitePlayerToFaction(player, targetUsername)
        local owner = getOwnerUsername(player)
        if trimName(targetUsername) == "" then
            return false, "A target username is required.", nil
        end
        local invitee = getOwnerUsername(targetUsername)
        local faction = Public.GetPlayerFaction(owner)
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end

        if getFactionRole(faction, owner) ~= "leader" then
            return false, "Only the faction leader can invite members.", faction
        end

        if invitee == owner then
            return false, "You already lead this faction.", faction
        end

        if Public.GetPlayerFaction(invitee) then
            return false, "That player already belongs to a faction.", faction
        end

        normalizeMembershipState(faction)
        if containsValue(faction.inviteUsernames, invitee) then
            return false, "That player already has a pending invite.", faction
        end

        faction.inviteUsernames[#faction.inviteUsernames + 1] = invitee
        normalizeMembershipState(faction)
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Invitation sent.", faction
    end

    function Public.AcceptFactionInvite(player, factionID)
        local owner = getOwnerUsername(player)
        local faction = factionID and getFactionData()[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return false, "Faction not found.", nil
        end

        if Public.GetPlayerFaction(owner) then
            return false, "You already belong to a faction.", faction
        end

        normalizeMembershipState(faction)
        if not containsValue(faction.inviteUsernames, owner) then
            return false, "No pending invite found.", faction
        end

        removeValue(faction.inviteUsernames, owner)
        faction.memberUsernames[#faction.memberUsernames + 1] = owner
        normalizeMembershipState(faction)
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Faction joined.", faction
    end

    function Public.DeclineFactionInvite(player, factionID)
        local owner = getOwnerUsername(player)
        local faction = factionID and getFactionData()[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return false, "Faction not found.", nil
        end

        normalizeMembershipState(faction)
        if not containsValue(faction.inviteUsernames, owner) then
            return false, "No pending invite found.", faction
        end

        removeValue(faction.inviteUsernames, owner)
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Invitation declined.", faction
    end

    function Public.LeavePlayerFaction(player)
        local owner = getOwnerUsername(player)
        local faction = Public.GetPlayerFaction(owner)
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end

        local role = getFactionRole(faction, owner)
        if role == "leader" then
            return false, "The faction leader cannot leave without disbanding the faction.", faction
        end

        if role ~= "member" then
            return false, "You are not a member of this faction.", faction
        end

        removeValue(faction.memberUsernames, owner)
        removeValue(faction.inviteUsernames, owner)
        normalizeMembershipState(faction)
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "You left the faction.", faction
    end

    function Public.KickFactionMember(player, targetUsername)
        local owner = getOwnerUsername(player)
        if trimName(targetUsername) == "" then
            return false, "A target username is required.", nil
        end
        local target = getOwnerUsername(targetUsername)
        local faction = Public.GetPlayerFaction(owner)
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end

        if getFactionRole(faction, owner) ~= "leader" then
            return false, "Only the faction leader can remove members.", faction
        end

        if target == getOwnerUsername(faction.leaderUsername) then
            return false, "The faction leader cannot be removed.", faction
        end

        normalizeMembershipState(faction)
        local removedMember = removeValue(faction.memberUsernames, target)
        local removedInvite = removeValue(faction.inviteUsernames, target)
        if not removedMember and not removedInvite then
            return false, "That player is not part of this faction.", faction
        end

        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, removedMember and "Member removed." or "Invitation revoked.", faction
    end
end
