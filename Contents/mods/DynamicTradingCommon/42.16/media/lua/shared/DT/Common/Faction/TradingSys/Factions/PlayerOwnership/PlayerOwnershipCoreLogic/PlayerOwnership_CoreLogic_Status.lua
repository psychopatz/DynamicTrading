return function(context)
    local Public = context.Public

    local getOwnerUsername = context.getOwnerUsername
    local copyArray = context.copyArray
    local getFactionRole = context.getFactionRole
    local getWorkersForOwner = context.getWorkersForOwner
    local isWorkerLiving = context.isWorkerLiving
    local isWorkerRegistryAvailable = context.isWorkerRegistryAvailable
    local isDynamicColoniesActive = context.isDynamicColoniesActive

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
        if faction then
            faction = Public.RefreshPlayerFaction(faction.id) or nil
        end
        local authorityOwner = faction and getOwnerUsername(faction.leaderUsername) or owner
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
end
