return function(context)
    local Public = context.Public

    local getOwnerUsername = context.getOwnerUsername
    local copyArray = context.copyArray
    local getFactionRole = context.getFactionRole
    local getWorkersForOwner = context.getWorkersForOwner
    local isWorkerLiving = context.isWorkerLiving
    local isWorkerRegistryAvailable = context.isWorkerRegistryAvailable
    local isDynamicColoniesActive = context.isDynamicColoniesActive
    local getOwnerBuildingsSummary = context.getOwnerBuildingsSummary
    local hasCompletedHeadquarters = context.hasCompletedHeadquarters
    local isAuthority = context.isAuthority

    local function copyReputationMap(source)
        local copied = {}
        for username, reputation in pairs(source or {}) do
            copied[username] = tonumber(reputation) or 100
        end
        return copied
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
                permissions = context.buildPermissions(nil, owner),
                memberUsernames = {},
                inviteUsernames = {},
                pendingInvites = {},
                leadershipState = nil,
                createBlockedReason = "dynamic_colonies_required"
            }
        end

        local registryReady = isWorkerRegistryAvailable()
        local faction = Public.GetPlayerFaction(owner)
        if not faction and registryReady and isAuthority() and Public.EnsurePlayerFaction then
            local _, _, ensuredFaction = Public.EnsurePlayerFaction(owner)
            faction = ensuredFaction or Public.GetPlayerFaction(owner)
        end
        if faction then
            faction = Public.RefreshPlayerFaction(faction.id) or nil
        end
        local authorityOwner = faction and getOwnerUsername(faction.leaderUsername) or owner
        local buildingsSummary = getOwnerBuildingsSummary(authorityOwner)
        local headquartersReady = hasCompletedHeadquarters(buildingsSummary)
        local workers = registryReady and getWorkersForOwner(authorityOwner) or {}
        local livingWorkers = {}
        for _, worker in ipairs(workers) do
            if isWorkerLiving(worker) then
                livingWorkers[#livingWorkers + 1] = worker
            end
        end

        local role = getFactionRole(faction, owner)
        local permissions = context.buildPermissions(faction, owner)
        local linkedWorkers = faction and context.buildFactionWorkerSummaries(faction) or {}
        local workerCount = registryReady and #livingWorkers or (faction and math.max(tonumber(faction.memberCount) or 0, #(faction.linkedWorkerIDs or {})) or 0)
        local canCreate = faction == nil and registryReady and headquartersReady and #livingWorkers >= 1

        local createBlockedReason = nil
        if faction then
            createBlockedReason = "already_has_faction"
        elseif not registryReady then
            createBlockedReason = "syncing"
        elseif not headquartersReady then
            createBlockedReason = "headquarters_required"
        elseif #livingWorkers < 1 then
            createBlockedReason = "needs_recruit"
        end

        return {
            ownerUsername = authorityOwner,
            memberUsername = owner,
            authorityOwner = authorityOwner,
            dynamicColoniesActive = true,
            canCreate = canCreate,
            workerCount = workerCount,
            faction = faction,
            buildings = buildingsSummary,
            headquartersReady = headquartersReady,
            linkedWorkers = linkedWorkers,
            role = role,
            isLeader = role == "leader",
            isMember = role == "member",
            permissions = permissions,
            memberUsernames = faction and copyArray(faction.memberUsernames) or {},
            memberReputation = faction and copyReputationMap(faction.memberReputation) or {},
            inviteUsernames = faction and copyArray(faction.inviteUsernames) or {},
            pendingInvites = Public.GetPendingInvites(owner),
            needsNamingPrompt = faction
                and faction.needsNamingConfirmation == true
                and role == "leader"
                or false,
            leadershipState = faction and tostring(faction.leadershipState or "Active") or nil,
            createBlockedReason = createBlockedReason
        }
    end
end
