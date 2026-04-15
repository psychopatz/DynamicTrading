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
    local isDynamicColoniesActive = Utils.isDynamicColoniesActive
    local isAdminReview = Utils.isAdminReview
    local getColonyRegistry = Utils.getColonyRegistry

    local DYNAMIC_COLONIES_REQUIRED = "Dynamic Colonies is required for player-made colony factions."

    local function getWorkerTransfer()
        if DC_Colony and DC_Colony.WorkerTransfer then
            return DC_Colony.WorkerTransfer
        end
        local ok = pcall(require, "DC/Common/Colony/WorkerTransfer/DC_WorkerTransfer")
        if ok and DC_Colony and DC_Colony.WorkerTransfer then
            return DC_Colony.WorkerTransfer
        end
        return nil
    end

    local function getStarterWorkers()
        if DC_Colony and DC_Colony.StarterWorkers then
            return DC_Colony.StarterWorkers
        end
        local ok = pcall(require, "DC/Common/Colony/StarterWorkers/DC_StarterWorkers")
        if ok and DC_Colony and DC_Colony.StarterWorkers then
            return DC_Colony.StarterWorkers
        end
        return nil
    end

    local function ensureStarterWorkersForJoin(player, owner)
        local starters = getStarterWorkers()
        if starters and starters.EnsureForOwner then
            return starters.EnsureForOwner(owner, player)
        end
        return nil
    end

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

    local function buildColonyPermissions(faction)
        local permissions = {}
        if not faction or isAdminReview(faction) then
            return permissions
        end

        local leader = getOwnerUsername(faction.leaderUsername)
        permissions[leader] = buildPermissions(faction, leader)
        for _, username in ipairs(faction.memberUsernames or {}) do
            permissions[username] = buildPermissions(faction, username)
        end
        return permissions
    end

    local function getColonyIDForFaction(faction, createIfMissing)
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

    local function syncFactionToColony(faction, options)
        options = options or {}
        if not faction or not isDynamicColoniesActive() then
            return false
        end

        local registry = getColonyRegistry()
        if not registry or not registry.GetColonyData then
            return false
        end

        local colonyID = getColonyIDForFaction(faction, options.createIfMissing ~= false)
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
        colonyData.inviteUsernames = copyArray(faction.inviteUsernames)
        colonyData.dynamicTradingFactionID = faction.id
        colonyData.leadershipState = tostring(faction.leadershipState or "Active")
        colonyData.permissions = buildColonyPermissions(faction)
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
            summary.leadershipState = colonyData.leadershipState
            summary.dynamicTradingFactionID = faction.id
        end

        if registry.Save then
            registry.Save()
        end
        return true
    end
    Internal.syncFactionToColony = syncFactionToColony

    local function requireDynamicColonies()
        if not isDynamicColoniesActive() then
            return false, DYNAMIC_COLONIES_REQUIRED
        end
        return true, nil
    end

    local function removeColonyUsernameMapping(username)
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

    local function markAdminReview(faction, reason)
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
        syncFactionToColony(faction, { createIfMissing = false })
        removeColonyUsernameMapping(oldLeader)
        for _, username in ipairs(oldMembers) do
            removeColonyUsernameMapping(username)
        end
        ModData.transmit(Utils.MOD_DATA_KEY)
        return faction
    end
    Internal.markAdminReview = markAdminReview

    local function deleteColonyArchiveData(faction)
        if not faction or not isDynamicColoniesActive() then
            return false
        end

        local registry = getColonyRegistry()
        local colonyID = getColonyIDForFaction(faction, false)
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
    Internal.deleteColonyArchiveData = deleteColonyArchiveData

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

    function Public.IsDynamicColoniesEnabled()
        return isDynamicColoniesActive()
    end

    function Public.GetPlayerFactionID(ownerUsername)
        local owner = getOwnerUsername(ownerUsername)
        local data = getFactionData()
        for factionID, faction in pairs(data) do
            if faction.playerOwned then
                normalizeMembershipState(faction)
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
        if isAdminReview(faction) then
            syncFactionToColony(faction, { createIfMissing = false })
            return faction
        end
        if not isDynamicColoniesActive() then
            return faction
        end
        local owner = getOwnerUsername(faction.leaderUsername)
        faction.linkedWorkerIDs = faction.linkedWorkerIDs or {}
        faction.tradeEligibleWorkerIDs = faction.tradeEligibleWorkerIDs or {}
        faction.activeTradeWorkerIDs = faction.activeTradeWorkerIDs or {}
        faction.tradeWorkerSouls = faction.tradeWorkerSouls or {}
        faction.controlMode = faction.controlMode or "HybridManual"
        faction.leadershipState = faction.leadershipState or "Active"
        if not syncLinkedWorkersFromOwner(faction, owner) then
            faction.memberCount = math.max(tonumber(faction.memberCount) or 0, #(faction.linkedWorkerIDs or {}))
            syncFactionToColony(faction, { createIfMissing = false })
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
            if faction.__dtAllowEmptyCollapse == true then
                markAdminReview(faction, "no_linked_workers")
            else
                faction.memberCount = math.max(tonumber(faction.memberCount) or 0, #(faction.linkedWorkerIDs or {}))
                faction.refreshPending = true
            end
            syncFactionToColony(faction, { createIfMissing = false })
            return faction
        end
        faction.refreshPending = nil
        syncFactionToColony(faction, { createIfMissing = true })
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
        local coloniesActive = isDynamicColoniesActive()
        if not coloniesActive then
            return {
                ownerUsername = owner,
                memberUsername = owner,
                authorityOwner = owner,
                dynamicColoniesActive = false,
                canCreate = false,
                workerCount = 0,
                faction = nil,
                buildings = nil,
                linkedWorkers = {},
                role = nil,
                isLeader = false,
                isMember = false,
                permissions = buildPermissions(nil, owner),
                memberUsernames = {},
                inviteUsernames = {},
                pendingInvites = {},
                leadershipState = nil,
                createBlockedReason = "dynamic_colonies_required"
            }
        end

        local registryReady = isWorkerRegistryAvailable()
        local faction = Public.GetPlayerFaction(owner)
        if faction then faction = Public.RefreshPlayerFaction(faction.id) or nil end
        local authorityOwner = faction and getOwnerUsername(faction.leaderUsername) or owner
        local workers = registryReady and getWorkersForOwner(authorityOwner) or {}
        local livingWorkers = {}
        for _, worker in ipairs(workers) do
            if isWorkerLiving(worker) then livingWorkers[#livingWorkers + 1] = worker end
        end
        local role = getFactionRole(faction, owner)
        local permissions = buildPermissions(faction, owner)
        local linkedWorkers = faction and buildFactionWorkerSummaries(faction) or {}
        local buildingsSummary = DT_Buildings and DT_Buildings.GetOwnerSummary and DT_Buildings.GetOwnerSummary(authorityOwner) or nil
        local workerCount = registryReady and #livingWorkers or (faction and math.max(tonumber(faction.memberCount) or 0, #(faction.linkedWorkerIDs or {})) or 0)
        return {
            ownerUsername = authorityOwner,
            memberUsername = owner,
            authorityOwner = authorityOwner,
            dynamicColoniesActive = true,
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
            pendingInvites = Public.GetPendingInvites(owner),
            leadershipState = faction and tostring(faction.leadershipState or "Active") or nil,
            createBlockedReason = faction and "already_has_faction" or ((not registryReady) and "syncing" or (#livingWorkers < 1 and "needs_recruit" or nil))
        }
    end

    function Public.CreatePlayerFaction(player, rawName)
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
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
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
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
        if isAdminReview(faction) then
            return false, "This faction is waiting for admin review.", faction
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
        syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Invitation sent.", faction, { targetUsername = invitee }
    end

    function Public.AcceptFactionInvite(player, factionID)
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
        local owner = getOwnerUsername(player)
        local faction = factionID and getFactionData()[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return false, "Faction not found.", nil
        end
        if isAdminReview(faction) then
            return false, "This faction is waiting for admin review.", faction
        end

        if Public.GetPlayerFaction(owner) then
            return false, "You already have a colony faction. Disband or abandon it before joining another.", faction
        end

        normalizeMembershipState(faction)
        if not containsValue(faction.inviteUsernames, owner) then
            return false, "No pending invite found.", faction
        end

        ensureStarterWorkersForJoin(player, owner)
        local transfer = getWorkerTransfer()
        if transfer and transfer.AddOwnerWorkersToFaction then
            transfer.AddOwnerWorkersToFaction(faction, owner)
        end

        removeValue(faction.inviteUsernames, owner)
        faction.memberUsernames[#faction.memberUsernames + 1] = owner
        normalizeMembershipState(faction)
        if transfer and transfer.CountLivingLinkedWorkers then
            faction.memberCount = transfer.CountLivingLinkedWorkers(faction)
        end
        syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Faction joined.", faction, { targetUsername = owner, leaderUsername = faction.leaderUsername }
    end

    function Public.DeclineFactionInvite(player, factionID)
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
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
        syncFactionToColony(faction, { createIfMissing = false })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Invitation declined.", faction, { targetUsername = owner, leaderUsername = faction.leaderUsername }
    end

    function Public.LeavePlayerFaction(player)
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
        local owner = getOwnerUsername(player)
        local faction = Public.GetPlayerFaction(owner)
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end

        local role = getFactionRole(faction, owner)
        if role == "leader" then
            return false, "Transfer leadership before leaving. If no members remain, use Abandon Leadership.", faction
        end

        if role ~= "member" then
            return false, "You are not a member of this faction.", faction
        end

        removeValue(faction.memberUsernames, owner)
        removeValue(faction.inviteUsernames, owner)
        removeColonyUsernameMapping(owner)
        local transfer = getWorkerTransfer()
        if transfer and transfer.ReturnContributorWorkers then
            transfer.ReturnContributorWorkers(faction, owner)
        end
        normalizeMembershipState(faction)
        if transfer and transfer.CountLivingLinkedWorkers then
            faction.memberCount = transfer.CountLivingLinkedWorkers(faction)
        end
        syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "You left the faction.", faction, { targetUsername = owner, leaderUsername = faction.leaderUsername }
    end

    function Public.KickFactionMember(player, targetUsername, workerTransferAction)
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
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
        if isAdminReview(faction) then
            return false, "This faction is waiting for admin review.", faction
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

        if removedMember then
            local transfer = getWorkerTransfer()
            local action = tostring(workerTransferAction or "return")
            removeColonyUsernameMapping(target)
            if action == "retain" then
                if transfer and transfer.RetainContributorWorkers then
                    transfer.RetainContributorWorkers(faction, target)
                end
            else
                if transfer and transfer.ReturnContributorWorkers then
                    transfer.ReturnContributorWorkers(faction, target)
                end
            end
            if transfer and transfer.CountLivingLinkedWorkers then
                faction.memberCount = transfer.CountLivingLinkedWorkers(faction)
            end
        end
        syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, removedMember and "Member removed." or "Invitation revoked.", faction, { targetUsername = target }
    end

    function Public.TransferFactionLeadership(player, targetUsername)
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
        local owner = getOwnerUsername(player)
        local target = getOwnerUsername(targetUsername)
        if trimName(target) == "" then
            return false, "A target username is required.", nil
        end

        local faction = Public.GetPlayerFaction(owner)
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end
        if getFactionRole(faction, owner) ~= "leader" then
            return false, "Only the faction leader can transfer leadership.", faction
        end
        if isAdminReview(faction) then
            return false, "This faction is waiting for admin review.", faction
        end
        normalizeMembershipState(faction)
        if not containsValue(faction.memberUsernames, target) then
            return false, "Leadership can only be transferred to a faction member.", faction
        end

        removeValue(faction.memberUsernames, target)
        appendUnique(faction.memberUsernames, owner)
        faction.previousLeaderUsername = owner
        faction.leaderUsername = target
        faction.leadershipState = "Active"
        faction.regencyReason = nil
        normalizeMembershipState(faction)
        syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Leadership transferred to " .. tostring(target) .. ".", faction, {
            targetUsername = target,
            previousLeaderUsername = owner,
            leaderUsername = target
        }
    end

    function Public.AbandonLeadership(player)
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
        local owner = getOwnerUsername(player)
        local faction = Public.GetPlayerFaction(owner)
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end
        if getFactionRole(faction, owner) ~= "leader" then
            return false, "Only the faction leader can abandon leadership.", faction
        end
        normalizeMembershipState(faction)
        if #(faction.memberUsernames or {}) > 0 then
            return false, "Transfer leadership before leaving this faction.", faction
        end

        markAdminReview(faction, "leader_abandoned")
        return true, "Colony moved to admin review. You can now join another colony.", faction, {
            targetUsername = owner,
            previousLeaderUsername = owner
        }
    end

    function Public.GetPendingInvites(ownerUsername)
        local owner = getOwnerUsername(ownerUsername)
        local invites = {}
        if not isDynamicColoniesActive() then
            return invites
        end
        for factionID, faction in pairs(getFactionData()) do
            if Public.IsPlayerFaction(faction) and not isAdminReview(faction) then
                normalizeMembershipState(faction)
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

    function Public.MarkFactionAdminReview(factionID, reason)
        if not isDynamicColoniesActive() then
            return nil
        end
        local faction = factionID and getFactionData()[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return nil
        end
        return markAdminReview(faction, reason)
    end

    function Public.AdminRestoreFactionLeader(factionID, targetUsername)
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
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
        syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Leader restored to " .. tostring(target) .. ".", faction, {
            targetUsername = target,
            leaderUsername = target
        }
    end

    function Public.AdminArchiveFaction(factionID)
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
        local faction = factionID and getFactionData()[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end
        markAdminReview(faction, "admin_archived")
        faction.leadershipState = "Archived"
        faction.controlMode = "Archived"
        faction.regencyReason = "admin_archived"
        syncFactionToColony(faction, { createIfMissing = false })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Colony archive preserved.", faction
    end

    function Public.AdminDeleteFactionArchive(factionID)
        local coloniesOk, coloniesMessage = requireDynamicColonies()
        if not coloniesOk then return false, coloniesMessage, nil end
        local data = getFactionData()
        local faction = factionID and data[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end
        local state = tostring(faction.leadershipState or "")
        if state ~= "AdminReview" and state ~= "Archived" then
            return false, "Only Admin Review or Archived colonies can be deleted here.", faction
        end

        deleteColonyArchiveData(faction)
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
        return syncFactionToColony(faction, { createIfMissing = not isAdminReview(faction) })
    end
end
