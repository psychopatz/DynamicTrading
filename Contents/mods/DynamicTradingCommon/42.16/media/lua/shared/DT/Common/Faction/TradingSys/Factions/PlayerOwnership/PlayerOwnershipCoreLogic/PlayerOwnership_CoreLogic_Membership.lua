return function(context)
    local Public = context.Public
    local Utils = context.Utils

    local getFactionData = context.getFactionData
    local getOwnerUsername = context.getOwnerUsername
    local isWorkerLiving = context.isWorkerLiving
    local removeValue = context.removeValue
    local containsValue = context.containsValue
    local getFactionRole = context.getFactionRole
    local trimName = context.trimName
    local sanitizeID = context.sanitizeID
    local getWorkersForOwner = context.getWorkersForOwner
    local buildFactionHome = context.buildFactionHome
    local appendUnique = context.appendUnique
    local isAdminReview = context.isAdminReview
    local getOwnerBuildingsSummary = context.getOwnerBuildingsSummary
    local hasCompletedHeadquarters = context.hasCompletedHeadquarters
    local getOnlinePlayerByUsername = context.getOnlinePlayerByUsername
    local getCharacterName = context.getCharacterName
    local isAuthority = context.isAuthority

    local function buildLivingWorkerIDs(workers)
        local linkedWorkerIDs = {}
        for _, worker in ipairs(workers or {}) do
            if isWorkerLiving(worker) then
                linkedWorkerIDs[#linkedWorkerIDs + 1] = worker.workerID
            end
        end
        return linkedWorkerIDs
    end

    local function createOwnedFaction(owner, desiredName, workers, player, needsNamingConfirmation)
        local linkedWorkerIDs = buildLivingWorkerIDs(workers)
        if #linkedWorkerIDs < 1 then
            return false, "You need at least one living recruit before founding a faction.", nil
        end

        local factionID = "player_" .. sanitizeID(owner)
        local homeCoords = buildFactionHome(player or owner, workers, owner)
        DynamicTrading_Factions.CreateFaction(factionID, {
            playerOwned = true,
            leaderUsername = owner,
            leadershipState = "Active",
            regencyReason = nil,
            controlMode = "HybridManual",
            name = desiredName,
            town = homeCoords.town,
            homeCoords = homeCoords,
            baseConfigured = homeCoords.baseConfigured == true,
            memberCount = #linkedWorkerIDs,
            memberUsernames = {},
            memberReputation = {
                [owner] = 100,
            },
            inviteUsernames = {},
            linkedWorkerIDs = linkedWorkerIDs,
            tradeEligibleWorkerIDs = {},
            activeTradeWorkerIDs = {},
            tradeWorkerSouls = {},
            needsNamingConfirmation = needsNamingConfirmation == true,
            createdDay = getGameTime() and getGameTime():getDaysSurvived() or 0
        })

        local faction = Public.RefreshPlayerFaction(factionID)
        return faction ~= nil, faction and "Faction founded." or "Faction creation failed.", faction
    end

    local function tryCandidateName(rawName)
        local ok, nameOrReason = Public.ValidateFactionName(rawName)
        if ok then
            return nameOrReason
        end
        return nil, nameOrReason
    end

    local function buildSuffixedName(baseName, suffixIndex)
        local suffix = " " .. tostring(suffixIndex)
        local maxBaseLength = math.max(1, 32 - #suffix)
        local truncated = trimName(string.sub(trimName(baseName), 1, maxBaseLength))
        if truncated == "" then
            truncated = "Faction"
        end
        return truncated .. suffix
    end

    local function resolveAutoFactionName(owner, player)
        local candidates = {}
        local characterName = getCharacterName(player)
        if characterName and characterName ~= "" then
            candidates[#candidates + 1] = characterName
        end
        if owner ~= "" and owner ~= characterName then
            candidates[#candidates + 1] = owner
        end
        candidates[#candidates + 1] = "Player Colony"

        for _, baseName in ipairs(candidates) do
            local normalizedBase = trimName(baseName)
            if normalizedBase ~= "" then
                local resolvedName, failureReason = tryCandidateName(normalizedBase)
                if resolvedName then
                    return resolvedName
                end

                if failureReason == "That faction name is already in use." or failureReason == "Faction name must be 32 characters or less." then
                    for index = 2, 99 do
                        resolvedName = tryCandidateName(buildSuffixedName(normalizedBase, index))
                        if resolvedName then
                            return resolvedName
                        end
                    end
                end
            end
        end

        return nil
    end

    function Public.CreatePlayerFaction(player, rawName)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

        local owner = getOwnerUsername(player)
        if Public.GetPlayerFaction(owner) then
            return false, "You already control a faction.", nil
        end

        local buildingsSummary = getOwnerBuildingsSummary(owner)
        if not hasCompletedHeadquarters(buildingsSummary) then
            return false, "Finish your headquarters before founding a faction.", nil
        end

        local desiredName = trimName(rawName)
        if desiredName == "" then
            desiredName = owner
        end

        local isValid, nameOrReason = Public.ValidateFactionName(desiredName)
        if not isValid then
            return false, nameOrReason, nil
        end

        local workers = getWorkersForOwner(owner)
        return createOwnedFaction(owner, nameOrReason, workers, player, false)
    end

    function Public.EnsurePlayerFaction(ownerOrPlayer, options)
        options = options or {}
        if not isAuthority() then
            local existingOwner = getOwnerUsername(ownerOrPlayer)
            return false, "Faction creation is authority-only.", Public.GetPlayerFaction(existingOwner), {
                ownerUsername = existingOwner,
                created = false,
                needsNamingPrompt = false
            }
        end

        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil, {
                ownerUsername = getOwnerUsername(ownerOrPlayer),
                created = false,
                needsNamingPrompt = false
            }
        end

        local owner = getOwnerUsername(ownerOrPlayer)
        local existingFaction = Public.GetPlayerFaction(owner)
        if existingFaction then
            existingFaction = Public.RefreshPlayerFaction(existingFaction.id) or existingFaction
            return true, "Faction already exists.", existingFaction, {
                ownerUsername = owner,
                created = false,
                needsNamingPrompt = existingFaction.needsNamingConfirmation == true,
                defaultName = existingFaction.name,
                leaderUsername = existingFaction.leaderUsername
            }
        end

        local buildingsSummary = getOwnerBuildingsSummary(owner)
        if not hasCompletedHeadquarters(buildingsSummary) then
            return false, "Finish your headquarters before founding a faction.", nil, {
                ownerUsername = owner,
                created = false,
                needsNamingPrompt = false
            }
        end

        local workers = getWorkersForOwner(owner)
        local livingWorkerIDs = buildLivingWorkerIDs(workers)
        if #livingWorkerIDs < 1 then
            return false, "You need at least one living recruit before founding a faction.", nil, {
                ownerUsername = owner,
                created = false,
                needsNamingPrompt = false
            }
        end

        local player = nil
        if type(ownerOrPlayer) == "table" and ownerOrPlayer.getUsername then
            player = ownerOrPlayer
        else
            player = getOnlinePlayerByUsername(owner)
        end

        local desiredName = resolveAutoFactionName(owner, player)
        if not desiredName then
            return false, "Unable to determine a valid temporary faction name.", nil, {
                ownerUsername = owner,
                created = false,
                needsNamingPrompt = false
            }
        end

        local ok, message, faction = createOwnedFaction(owner, desiredName, workers, player, true)
        return ok, message, faction, {
            ownerUsername = owner,
            created = ok == true,
            needsNamingPrompt = ok == true,
            defaultName = desiredName,
            leaderUsername = faction and faction.leaderUsername or owner
        }
    end

    function Public.RenamePlayerFaction(player, rawName)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

        local owner = getOwnerUsername(player)
        local faction = Public.GetPlayerFaction(owner)
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end
        if getFactionRole(faction, owner) ~= "leader" then
            return false, "Only the faction leader can rename this faction.", faction
        end
        if isAdminReview(faction) then
            return false, "This faction is waiting for admin review.", faction
        end

        local desiredName = trimName(rawName)
        if desiredName == "" then
            desiredName = owner
        end

        local isValid, nameOrReason = Public.ValidateFactionName(desiredName, faction.id)
        if not isValid then
            return false, nameOrReason, faction
        end

        faction.name = nameOrReason
        faction.needsNamingConfirmation = nil
        context.syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Faction renamed.", faction, {
            leaderUsername = faction.leaderUsername
        }
    end

    function Public.InvitePlayerToFaction(player, targetUsername)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

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

        context.normalizeMembershipState(faction)
        if containsValue(faction.inviteUsernames, invitee) then
            return false, "That player already has a pending invite.", faction
        end

        faction.inviteUsernames[#faction.inviteUsernames + 1] = invitee
        context.normalizeMembershipState(faction)
        context.syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Invitation sent.", faction, { targetUsername = invitee }
    end

    function Public.AcceptFactionInvite(player, factionID)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

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

        context.normalizeMembershipState(faction)
        if not containsValue(faction.inviteUsernames, owner) then
            return false, "No pending invite found.", faction
        end

        context.ensureStarterWorkersForJoin(player, owner)
        local transfer = context.getWorkerTransfer()
        if transfer and transfer.AddOwnerWorkersToFaction then
            transfer.AddOwnerWorkersToFaction(faction, owner)
        end

        removeValue(faction.inviteUsernames, owner)
        faction.memberUsernames[#faction.memberUsernames + 1] = owner
        context.normalizeMembershipState(faction)
        if transfer and transfer.CountLivingLinkedWorkers then
            faction.memberCount = transfer.CountLivingLinkedWorkers(faction)
        end
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(faction.id, DynamicTrading.GameplayEvents.MEMBER_JOINED, {owner})
        end
        context.syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Faction joined.", faction, { targetUsername = owner, leaderUsername = faction.leaderUsername }
    end

    function Public.DeclineFactionInvite(player, factionID)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

        local owner = getOwnerUsername(player)
        local faction = factionID and getFactionData()[factionID] or nil
        if not Public.IsPlayerFaction(faction) then
            return false, "Faction not found.", nil
        end

        context.normalizeMembershipState(faction)
        if not containsValue(faction.inviteUsernames, owner) then
            return false, "No pending invite found.", faction
        end

        removeValue(faction.inviteUsernames, owner)
        context.syncFactionToColony(faction, { createIfMissing = false })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Invitation declined.", faction, { targetUsername = owner, leaderUsername = faction.leaderUsername }
    end

    function Public.LeavePlayerFaction(player)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

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
        context.removeColonyUsernameMapping(owner)
        local transfer = context.getWorkerTransfer()
        if transfer and transfer.ReturnContributorWorkers then
            transfer.ReturnContributorWorkers(faction, owner)
        end
        context.normalizeMembershipState(faction)
        if transfer and transfer.CountLivingLinkedWorkers then
            faction.memberCount = transfer.CountLivingLinkedWorkers(faction)
        end
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(faction.id, DynamicTrading.GameplayEvents.MEMBER_LEFT, {owner})
        end
        context.syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "You left the faction.", faction, { targetUsername = owner, leaderUsername = faction.leaderUsername }
    end

    function Public.KickFactionMember(player, targetUsername, workerTransferAction)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

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

        context.normalizeMembershipState(faction)
        local removedMember = removeValue(faction.memberUsernames, target)
        local removedInvite = removeValue(faction.inviteUsernames, target)
        if not removedMember and not removedInvite then
            return false, "That player is not part of this faction.", faction
        end

        if removedMember then
            local transfer = context.getWorkerTransfer()
            local action = tostring(workerTransferAction or "return")
            context.removeColonyUsernameMapping(target)
            if action == "retain" then
                if transfer and transfer.RetainContributorWorkers then
                    transfer.RetainContributorWorkers(faction, target)
                end
            elseif transfer and transfer.ReturnContributorWorkers then
                transfer.ReturnContributorWorkers(faction, target)
            end
            if transfer and transfer.CountLivingLinkedWorkers then
                faction.memberCount = transfer.CountLivingLinkedWorkers(faction)
            end
        end

        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(faction.id, DynamicTrading.GameplayEvents.MEMBER_KICKED, {target, owner})
        end
        context.syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, removedMember and "Member removed." or "Invitation revoked.", faction, { targetUsername = target }
    end

    function Public.TransferFactionLeadership(player, targetUsername)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

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

        context.normalizeMembershipState(faction)
        if not containsValue(faction.memberUsernames, target) then
            return false, "Leadership can only be transferred to a faction member.", faction
        end

        removeValue(faction.memberUsernames, target)
        appendUnique(faction.memberUsernames, owner)
        faction.previousLeaderUsername = owner
        faction.leaderUsername = target
        faction.leadershipState = "Active"
        faction.regencyReason = nil
        context.normalizeMembershipState(faction)
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(faction.id, DynamicTrading.GameplayEvents.LEADERSHIP_TRANSFER, {owner, target})
        end
        context.syncFactionToColony(faction, { createIfMissing = true })
        ModData.transmit(Utils.MOD_DATA_KEY)
        return true, "Leadership transferred to " .. tostring(target) .. ".", faction, {
            targetUsername = target,
            previousLeaderUsername = owner,
            leaderUsername = target
        }
    end

    function Public.AbandonLeadership(player)
        local coloniesOk, coloniesMessage = context.requireDynamicColonies()
        if not coloniesOk then
            return false, coloniesMessage, nil
        end

        local owner = getOwnerUsername(player)
        local faction = Public.GetPlayerFaction(owner)
        if not Public.IsPlayerFaction(faction) then
            return false, "Player faction not found.", nil
        end
        if getFactionRole(faction, owner) ~= "leader" then
            return false, "Only the faction leader can abandon leadership.", faction
        end

        context.normalizeMembershipState(faction)
        if #(faction.memberUsernames or {}) > 0 then
            return false, "Transfer leadership before leaving this faction.", faction
        end

        context.markAdminReview(faction, "leader_abandoned")
        return true, "Colony moved to admin review. You can now join another colony.", faction, {
            targetUsername = owner,
            previousLeaderUsername = owner
        }
    end
end
