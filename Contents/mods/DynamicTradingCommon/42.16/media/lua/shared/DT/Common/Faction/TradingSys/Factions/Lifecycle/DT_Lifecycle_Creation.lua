return function(context)
    local Lifecycle = context.Lifecycle
    local MOD_DATA_KEY = context.MOD_DATA_KEY

    function Lifecycle.CreateFaction(factionID, initialData)
        if not ModData.exists(MOD_DATA_KEY) then
            ModData.add(MOD_DATA_KEY, {})
        end

        local data = ModData.get(MOD_DATA_KEY)
        initialData = initialData or {}

        if not data[factionID] then
            local displayName = ""
            local assignedHome = nil
            local resolvedTown = initialData.town

            if DT_GeolocatorSystem and DT_GeolocatorSystem.ResolveLocationName and resolvedTown then
                resolvedTown = DT_GeolocatorSystem.ResolveLocationName(resolvedTown)
            end

            if initialData.playerOwned then
                displayName = tostring(initialData.name or factionID)
                assignedHome = initialData.homeCoords
            elseif factionID == "Independent" or initialData.isNomadic then
                displayName = "Independent Traders"
                assignedHome = context.buildSpatialFallbackHome(factionID, {
                    name = displayName,
                    town = resolvedTown,
                    factionType = "independent"
                })
            else
                if DT_FactionNames and DT_FactionNames.Generate then
                    displayName = DT_FactionNames.Generate()
                else
                    displayName = tostring(initialData.name or factionID)
                end

                if DT_FactionLocationManager and DT_FactionLocationManager.AssignHome then
                    assignedHome = DT_FactionLocationManager.AssignHome(factionID, resolvedTown)
                end
                if not assignedHome then
                    assignedHome = context.buildSpatialFallbackHome(factionID, {
                        name = displayName,
                        town = resolvedTown,
                        factionType = initialData.playerOwned and "player" or "town"
                    })
                end
            end

            if (not resolvedTown or resolvedTown == "" or resolvedTown == "Wilderness") and assignedHome and assignedHome.town then
                resolvedTown = assignedHome.town
            end

            data[factionID] = {
                id = factionID,
                name = displayName,
                town = resolvedTown,
                homeCoords = assignedHome,
                stockpile = initialData.stockpile or { food = 200, ammo = 100, meds = 50, fuel = 25, water = 150, materials = 30 },
                state = initialData.state or "Stable",
                memberCount = initialData.memberCount or math.max(8, SandboxVars.DynamicTrading.FactionStartPop or 10),
                ColonyWealth = context.getConfiguredColonyWealth(),
                CollapseDays = 0,
                factionType = initialData.playerOwned and "player" or (factionID == "Independent" or initialData.isNomadic) and "independent" or "town",
                reputation = initialData.reputation or {},
                starvationDays = 0,
                shortageDays = { water = 0, meds = 0, ammo = 0, fuel = 0, materials = 0 },
                penalties = { dehydrated = false, sick = false, vulnerable = false, isolated = false, decaying = false },
                buildings = {},
                consecutiveStableDays = 0,
                ActiveFlashEvents = {},
                ActiveFlashEvent = { id = nil, expires = 0, targetCasualties = 0 },
                playerOwned = initialData.playerOwned == true,
                leaderUsername = initialData.leaderUsername,
                leadershipState = initialData.leadershipState or "Active",
                regencyReason = initialData.regencyReason,
                previousLeaderUsername = initialData.previousLeaderUsername,
                controlMode = initialData.controlMode or (initialData.playerOwned and "HybridManual" or nil),
                memberUsernames = initialData.memberUsernames or {},
                memberReputation = initialData.memberReputation or {},
                inviteUsernames = initialData.inviteUsernames or {},
                linkedWorkerIDs = initialData.linkedWorkerIDs or {},
                tradeEligibleWorkerIDs = initialData.tradeEligibleWorkerIDs or {},
                activeTradeWorkerIDs = initialData.activeTradeWorkerIDs or {},
                tradeWorkerSouls = initialData.tradeWorkerSouls or {},
                createdDay = tonumber(initialData.createdDay) or 0
            }

            if not initialData.playerOwned then
                DynamicTrading_Factions.GenerateRoster(factionID)
            end

            if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
                DynamicTrading.GameplayLogs.AddFactionEvent(factionID, DynamicTrading.GameplayEvents.FACTION_FOUNDED, {displayName})
            end

            ModData.transmit(MOD_DATA_KEY)

            local homeLog = assignedHome and ("at " .. assignedHome.name) or "Nomadic"
            DynamicTrading.Log("DTCommons", "Faction", "Logic", "Created Faction [" .. factionID .. "] Known as '" .. displayName .. "' " .. homeLog)
        else
            DynamicTrading.Log("DTCommons", "Faction", "Logic", "Faction ID [" .. factionID .. "] already exists in database.")
        end
    end
end
