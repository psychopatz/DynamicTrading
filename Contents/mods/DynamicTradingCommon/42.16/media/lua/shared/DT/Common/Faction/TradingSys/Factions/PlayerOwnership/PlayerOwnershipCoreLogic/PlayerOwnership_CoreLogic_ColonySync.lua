return function(context)
    local Public = context.Public
    local Internal = context.Internal
    local Utils = context.Utils

    local getOwnerUsername = context.getOwnerUsername
    local removeValue = context.removeValue
    local containsValue = context.containsValue
    local copyArray = context.copyArray
    local ensureUniqueUsernames = context.ensureUniqueUsernames
    local getFactionRole = context.getFactionRole
    local isDynamicColoniesActive = context.isDynamicColoniesActive
    local isAdminReview = context.isAdminReview
    local getColonyRegistry = context.getColonyRegistry

    function context.getWorkerTransfer()
        if DC_Colony and DC_Colony.WorkerTransfer then
            return DC_Colony.WorkerTransfer
        end

        local ok = pcall(require, "DC/Common/Colony/WorkerTransfer/DC_WorkerTransfer")
        if ok and DC_Colony and DC_Colony.WorkerTransfer then
            return DC_Colony.WorkerTransfer
        end

        return nil
    end

    function context.getStarterWorkers()
        if DC_Colony and DC_Colony.StarterWorkers then
            return DC_Colony.StarterWorkers
        end

        local ok = pcall(require, "DC/Common/Colony/StarterWorkers/DC_StarterWorkers")
        if ok and DC_Colony and DC_Colony.StarterWorkers then
            return DC_Colony.StarterWorkers
        end

        return nil
    end

    function context.ensureStarterWorkersForJoin(player, owner)
        local starters = context.getStarterWorkers()
        if starters and starters.EnsureForOwner then
            return starters.EnsureForOwner(owner, player)
        end
        return nil
    end

    function context.normalizeMembershipState(faction)
        if not faction then
            return
        end

        faction.memberUsernames = ensureUniqueUsernames(faction.memberUsernames)
        faction.inviteUsernames = ensureUniqueUsernames(faction.inviteUsernames)
        faction.memberReputation = type(faction.memberReputation) == "table" and faction.memberReputation or {}

        local leader = getOwnerUsername(faction.leaderUsername)
        faction.leaderUsername = leader
        removeValue(faction.memberUsernames, leader)
        removeValue(faction.inviteUsernames, leader)

        local activeMembers = {}
        if leader ~= "" then
            activeMembers[leader] = true
            faction.memberReputation[leader] = tonumber(faction.memberReputation[leader]) or 100
        end

        for _, username in ipairs(faction.memberUsernames) do
            local member = getOwnerUsername(username)
            if member ~= "" then
                activeMembers[member] = true
                faction.memberReputation[member] = tonumber(faction.memberReputation[member]) or 100
            end
        end

        for username, _ in pairs(faction.memberReputation) do
            local normalized = getOwnerUsername(username)
            if normalized == "" or activeMembers[normalized] ~= true then
                faction.memberReputation[username] = nil
            elseif normalized ~= username then
                faction.memberReputation[normalized] = tonumber(faction.memberReputation[username]) or 100
                faction.memberReputation[username] = nil
            end
        end
    end

    function context.buildPermissions(faction, username)
        local role = getFactionRole(faction, username)
        local isLeader = role == "leader"
        local isMember = role == "member"
        local active = Public.IsPlayerFaction(faction)
            and not isAdminReview(faction)
            and isDynamicColoniesActive()

        return {
            role = role,
            canViewFaction = active and (isLeader or isMember),
            canManageColony = active and (isLeader or isMember),
            canManageWorkers = active and (isLeader or isMember),
            canManageBuildings = active and (isLeader or isMember),
            canManageTrade = active and (isLeader or isMember),
            canInviteMembers = active and isLeader,
            canRemoveMembers = active and isLeader,
            canTransferLeadership = active and isLeader,
            canLeaveFaction = active and isMember,
            canAbandonLeadership = active and isLeader and #(faction.memberUsernames or {}) == 0,
            canRenameFaction = active and isLeader,
            canDisbandFaction = active and isLeader
        }
    end

    function context.buildColonyPermissions(faction)
        local permissions = {}
        if not faction or isAdminReview(faction) then
            return permissions
        end

        local leader = getOwnerUsername(faction.leaderUsername)
        permissions[leader] = context.buildPermissions(faction, leader)
        for _, username in ipairs(faction.memberUsernames or {}) do
            permissions[username] = context.buildPermissions(faction, username)
        end
        return permissions
    end

    function context.getColonyIDForFaction(faction, createIfMissing)
        if not faction or not isDynamicColoniesActive() then
            return nil
        end

        local registry = getColonyRegistry()
        if not registry or not registry.GetColonyIDForOwner then
            return nil
        end

        local lookupOwners = {}
        if isAdminReview(faction) then
            lookupOwners[#lookupOwners + 1] = "AdminReview_" .. tostring(faction.id or "")
        end
        if faction.previousLeaderUsername and faction.previousLeaderUsername ~= "" then
            lookupOwners[#lookupOwners + 1] = faction.previousLeaderUsername
        end
        if faction.leaderUsername and faction.leaderUsername ~= "" then
            lookupOwners[#lookupOwners + 1] = faction.leaderUsername
        end
        for _, username in ipairs(faction.memberUsernames or {}) do
            lookupOwners[#lookupOwners + 1] = username
        end

        for _, username in ipairs(lookupOwners) do
            local colonyID = registry.GetColonyIDForOwner(username, false)
            if colonyID then
                return tostring(colonyID)
            end
        end

        if createIfMissing and faction.leaderUsername and faction.leaderUsername ~= "" then
            local colonyID = registry.GetColonyIDForOwner(faction.leaderUsername, true)
            return colonyID and tostring(colonyID) or nil
        end

        return nil
    end

    function context.syncFactionToColony(faction, options)
        options = options or {}
        if not faction or not isDynamicColoniesActive() then
            return false
        end

        local registry = getColonyRegistry()
        if not registry or not registry.GetColonyData then
            return false
        end

        local colonyID = context.getColonyIDForFaction(faction, options.createIfMissing ~= false)
        if not colonyID then
            return false
        end

        local colonyData = registry.GetColonyData(colonyID, true)
        if type(colonyData) ~= "table" then
            return false
        end

        local leader = getOwnerUsername(faction.leaderUsername)
        local adminReviewOwner = "AdminReview_" .. tostring(faction.id or colonyID)
        local colonyOwner = isAdminReview(faction) and adminReviewOwner or leader
        colonyData.colonyName = tostring(faction.name or colonyData.colonyName or faction.id or "Player Colony")
        colonyData.ownerUsername = colonyOwner ~= "" and colonyOwner or colonyData.ownerUsername
        colonyData.leaderUsername = leader
        colonyData.memberUsernames = copyArray(faction.memberUsernames)
        colonyData.memberReputation = {}
        for username, reputation in pairs(faction.memberReputation or {}) do
            colonyData.memberReputation[username] = tonumber(reputation) or 100
        end
        colonyData.inviteUsernames = copyArray(faction.inviteUsernames)
        colonyData.dynamicTradingFactionID = faction.id
        colonyData.leadershipState = tostring(faction.leadershipState or "Active")
        colonyData.permissions = context.buildColonyPermissions(faction)
        colonyData.versions = colonyData.versions or {}
        colonyData.versions.colony = math.max(1, math.floor(tonumber(colonyData.versions.colony) or 1)) + 1

        local index = registry.GetData and registry.GetData() or nil
        if type(index) == "table" then
            index.playerToColonyID = index.playerToColonyID or {}
            if isAdminReview(faction) then
                if faction.previousLeaderUsername and faction.previousLeaderUsername ~= "" then
                    index.playerToColonyID[faction.previousLeaderUsername] = nil
                end
                for _, username in ipairs(faction.memberUsernames or {}) do
                    index.playerToColonyID[username] = nil
                end
                index.playerToColonyID[adminReviewOwner] = colonyID
            elseif leader ~= "" then
                index.playerToColonyID[leader] = colonyID
                if faction.previousLeaderUsername
                    and faction.previousLeaderUsername ~= ""
                    and (faction.previousLeaderUsername == leader or containsValue(faction.memberUsernames, faction.previousLeaderUsername)) then
                    index.playerToColonyID[faction.previousLeaderUsername] = colonyID
                end
                for _, username in ipairs(faction.memberUsernames or {}) do
                    index.playerToColonyID[username] = colonyID
                end
            end

            index.colonies = index.colonies or {}
            local summary = index.colonies[colonyID] or {}
            index.colonies[colonyID] = summary
            summary.colonyID = colonyID
            summary.colonyName = colonyData.colonyName
            summary.ownerUsername = colonyData.ownerUsername
            summary.leaderUsername = colonyData.leaderUsername
            summary.memberUsernames = copyArray(colonyData.memberUsernames)
            summary.memberReputation = {}
            for username, reputation in pairs(colonyData.memberReputation or {}) do
                summary.memberReputation[username] = tonumber(reputation) or 100
            end
            summary.leadershipState = colonyData.leadershipState
            summary.dynamicTradingFactionID = faction.id
        end

        if registry.Save then
            registry.Save()
        end
        return true
    end
    Internal.syncFactionToColony = context.syncFactionToColony

    function context.requireDynamicColonies()
        if not isDynamicColoniesActive() then
            return false, context.DYNAMIC_COLONIES_REQUIRED
        end
        return true, nil
    end

    function context.removeColonyUsernameMapping(username)
        local registry = getColonyRegistry()
        local index = registry and registry.GetData and registry.GetData() or nil
        local owner = getOwnerUsername(username)
        if type(index) == "table" and type(index.playerToColonyID) == "table" and owner ~= "" then
            index.playerToColonyID[owner] = nil
            if registry.Save then
                registry.Save()
            end
        end
    end

    function context.markAdminReview(faction, reason)
        if not faction then
            return nil
        end

        local oldLeader = getOwnerUsername(faction.leaderUsername)
        local oldMembers = copyArray(faction.memberUsernames)
        faction.previousLeaderUsername = oldLeader ~= "" and oldLeader or faction.previousLeaderUsername
        faction.leaderUsername = ""
        faction.memberUsernames = {}
        faction.inviteUsernames = {}
        faction.leadershipState = "AdminReview"
        faction.regencyReason = tostring(reason or "leaderless")
        faction.controlMode = "AdminReview"
        faction.activeTradeWorkerIDs = {}
        if DynamicTrading_Roster and DynamicTrading_Roster.ClearSouls and faction.id then
            DynamicTrading_Roster.ClearSouls(faction.id)
        end
        context.syncFactionToColony(faction, { createIfMissing = false })
        context.removeColonyUsernameMapping(oldLeader)
        for _, username in ipairs(oldMembers) do
            context.removeColonyUsernameMapping(username)
        end
        ModData.transmit(Utils.MOD_DATA_KEY)
        return faction
    end
    Internal.markAdminReview = context.markAdminReview

    function context.deleteColonyArchiveData(faction)
        if not faction or not isDynamicColoniesActive() then
            return false
        end

        local registry = getColonyRegistry()
        local colonyID = context.getColonyIDForFaction(faction, false)
        if not colonyID then
            return false
        end

        local workersData = registry and registry.GetWorkersData and registry.GetWorkersData(colonyID, false) or nil
        local workerIDs = copyArray(workersData and workersData.workerIDs or {})

        local config = DC_Colony and DC_Colony.Config or {}
        local keys = {
            tostring(config.MOD_DATA_COLONY_PREFIX or "DColony_Colony_") .. colonyID,
            tostring(config.MOD_DATA_WORKERS_PREFIX or "DColony_Workers_") .. colonyID,
            tostring(config.MOD_DATA_SITES_PREFIX or "DColony_Sites_") .. colonyID,
            tostring(config.MOD_DATA_WAREHOUSE_PREFIX or "DColony_Warehouse_") .. colonyID,
            tostring(config.MOD_DATA_WAREHOUSE_ITEMS_PREFIX or "DColony_WarehouseItems_") .. colonyID,
            tostring(config.MOD_DATA_RESOURCES_PREFIX or "DColony_Resources_") .. colonyID,
            "DColony_Buildings_" .. colonyID
        }

        for _, workerID in ipairs(workerIDs) do
            keys[#keys + 1] = tostring(config.MOD_DATA_WORKER_PREFIX or "DColony_Worker_") .. colonyID .. "_" .. tostring(workerID)
        end

        for _, key in ipairs(keys) do
            if ModData.exists and ModData.exists(key) and ModData.remove then
                ModData.remove(key)
            end
        end

        local index = registry and registry.GetData and registry.GetData() or nil
        if type(index) == "table" then
            if type(index.colonies) == "table" then
                index.colonies[colonyID] = nil
            end
            if type(index.playerToColonyID) == "table" then
                for username, mappedColonyID in pairs(index.playerToColonyID) do
                    if tostring(mappedColonyID) == tostring(colonyID) then
                        index.playerToColonyID[username] = nil
                    end
                end
            end
        end

        if registry and registry.Save then
            registry.Save()
        end
        return true
    end
    Internal.deleteColonyArchiveData = context.deleteColonyArchiveData
end
