return function(context)
    local Lifecycle = context.Lifecycle
    local MOD_DATA_KEY = context.MOD_DATA_KEY

    function context.hasValidHomeCoords(homeCoords)
        return type(homeCoords) == "table"
            and tonumber(homeCoords.x) ~= nil
            and tonumber(homeCoords.y) ~= nil
    end

    function context.buildSpatialFallbackHome(factionID, faction)
        if not DT_GeolocatorSystem or not DT_GeolocatorSystem.CreateSpatialHome then
            return nil
        end

        local label = nil
        if type(faction) == "table" then
            label = faction.name
        end
        if not label or label == "" then
            if factionID == "Independent" or (type(faction) == "table" and faction.factionType == "independent") then
                label = "Independent Route"
            else
                label = tostring(factionID or "Nomadic Route") .. " Route"
            end
        end

        return DT_GeolocatorSystem.CreateSpatialHome(label, {
            town = faction and faction.town or nil,
            factionID = factionID,
            preferUsableRange = true,
        })
    end

    function context.countTownFactions(data)
        local count = 0
        for id, _ in pairs(data or {}) do
            if id ~= "Independent" then
                count = count + 1
            end
        end
        return count
    end

    function context.repairMissingFactionHomes(data)
        local repairedCount = 0

        if not context.IS_SERVER_RUNTIME then
            return repairedCount
        end

        for id, faction in pairs(data or {}) do
            if not faction.playerOwned and not context.hasValidHomeCoords(faction.homeCoords) then
                local repairedHome = nil

                if id == "Independent" or faction.factionType == "independent" then
                    repairedHome = context.buildSpatialFallbackHome(id, faction)
                elseif DT_FactionLocationManager and DT_FactionLocationManager.AssignHome then
                    repairedHome = DT_FactionLocationManager.AssignHome(id, faction.town)
                    if not repairedHome then
                        repairedHome = context.buildSpatialFallbackHome(id, faction)
                    end
                else
                    repairedHome = context.buildSpatialFallbackHome(id, faction)
                end

                if repairedHome then
                    faction.homeCoords = repairedHome
                    faction.town = repairedHome.town or faction.town
                    repairedCount = repairedCount + 1
                end
            end
        end

        return repairedCount
    end

    function context.tryFinalizeFactionBootstrap(reason)
        if not context.ensureGeolocatorReady() then
            context.deferredBootstrapPending = true
            return false
        end

        if DT_FactionLocationManager and DT_FactionLocationManager.RegisterDynamicTowns then
            DT_FactionLocationManager.RegisterDynamicTowns()
        end

        local data = ModData.get(MOD_DATA_KEY) or {}
        local queuedCount, priorityCount = context.scheduleMissingTownPopulation(data)
        local repairedCount = context.repairMissingFactionHomes(data)
        if repairedCount > 0 then
            DynamicTrading.Log("DTCommons", "Faction", "Logic", "Repaired " .. tostring(repairedCount) .. " faction homes during " .. tostring(reason or "bootstrap"))
            ModData.transmit(MOD_DATA_KEY)
        end

        if context.deferredBootstrapPending and queuedCount > 0 then
            context.deferredBootstrapPending = false
            DynamicTrading.Log("DTCommons", "Faction", "Logic", "Completing deferred town population during " .. tostring(reason or "bootstrap"))
            context.processDeferredTownQueue(reason or "bootstrap", math.max(priorityCount, 1), false)
            return true
        end

        context.deferredBootstrapPending = false
        return repairedCount > 0 or queuedCount > 0
    end

    function Lifecycle.Init()
        if not context.IS_SERVER_RUNTIME then
            return
        end

        context.ensureExplorationData()

        if DT_FactionLocationManager and DT_FactionLocationManager.RegisterDynamicTowns then
            DT_FactionLocationManager.RegisterDynamicTowns()
        end

        if not ModData.exists(MOD_DATA_KEY) then
            ModData.add(MOD_DATA_KEY, {})
        end

        local data = ModData.get(MOD_DATA_KEY)

        if not data["Independent"] then
            DynamicTrading_Factions.CreateFaction("Independent", {
                memberCount = 10,
                isNomadic = true
            })
        end

        local townFactionCount = context.countTownFactions(data)
        local geolocatorReady = context.ensureGeolocatorReady()

        if geolocatorReady then
            context.scheduleMissingTownPopulation(data)
        end

        if townFactionCount == 0 then
            if geolocatorReady then
                DynamicTrading.Log("DTCommons", "Init", "Faction", "No town factions found, triggering initial population")
                DynamicTrading_Factions.RepopulateTowns()
                townFactionCount = context.countTownFactions(data)
            else
                context.deferredBootstrapPending = true
                DynamicTrading.Log("DTCommons", "Init", "Faction", "No town factions found, but geolocator is not ready yet. Deferring initial population.")
            end
        end

        local needsHomeRepair = false
        for id, f in pairs(data) do
            if tostring(f.factionType or "") == "bandit" then
                if type(f.playerDisposition) ~= "table" then
                    f.playerDisposition = {}
                end
                if f.playerDispositionDefault == nil then
                    f.playerDispositionDefault = -100
                end
            end

            if type(f.wealth) == "number" and not f.ColonyWealth then
                f.ColonyWealth = f.wealth
                f.wealth = nil
            end
            f.ColonyWealth = context.getConfiguredColonyWealth()

            if not f.CollapseDays then
                f.CollapseDays = 0
            end

            if not f.factionType then
                if f.playerOwned then
                    f.factionType = "player"
                elseif id == "Independent" or f.isNomadic then
                    f.factionType = "independent"
                else
                    f.factionType = "town"
                end
            end

            if type(f.ActiveFlashEvents) ~= "table" then
                f.ActiveFlashEvents = {}
            end

            if f.ActiveFlashEvent and f.ActiveFlashEvent.id and #f.ActiveFlashEvents == 0 then
                table.insert(f.ActiveFlashEvents, {
                    id = f.ActiveFlashEvent.id,
                    expires = f.ActiveFlashEvent.expires or 0,
                    targetCasualties = f.ActiveFlashEvent.targetCasualties or 0
                })
            end

            local first = f.ActiveFlashEvents[1]
            f.ActiveFlashEvent = {
                id = first and first.id or nil,
                expires = first and (first.expires or 0) or 0,
                targetCasualties = first and (first.targetCasualties or 0) or 0
            }

            if not f.consecutiveStableDays then
                f.consecutiveStableDays = 0
            end

            if DT_GeolocatorSystem and DT_GeolocatorSystem.ResolveLocationName and type(f.town) == "string" and f.town ~= "" then
                f.town = DT_GeolocatorSystem.ResolveLocationName(f.town)
            end

            if context.IS_SERVER_RUNTIME
                and not f.playerOwned
                and not context.hasValidHomeCoords(f.homeCoords) then
                needsHomeRepair = true
            end

            if f.playerOwned then
                f.leadershipState = f.leadershipState or "Active"
                local existingLeader = tostring(f.leaderUsername or "")
                if existingLeader == "" then
                    f.leaderUsername = ""
                    f.leadershipState = "AdminReview"
                else
                    f.leaderUsername = existingLeader
                end
                f.regencyReason = f.regencyReason or nil
                f.controlMode = f.controlMode or "HybridManual"
                if f.leadershipState == "AdminReview" then
                    f.controlMode = "AdminReview"
                end
                f.previousLeaderUsername = f.previousLeaderUsername or nil
                f.memberUsernames = type(f.memberUsernames) == "table" and f.memberUsernames or {}
                f.memberReputation = type(f.memberReputation) == "table" and f.memberReputation or {}
                f.inviteUsernames = type(f.inviteUsernames) == "table" and f.inviteUsernames or {}
                f.linkedWorkerIDs = type(f.linkedWorkerIDs) == "table" and f.linkedWorkerIDs or {}
                f.tradeEligibleWorkerIDs = type(f.tradeEligibleWorkerIDs) == "table" and f.tradeEligibleWorkerIDs or {}
                f.activeTradeWorkerIDs = type(f.activeTradeWorkerIDs) == "table" and f.activeTradeWorkerIDs or {}
                f.tradeWorkerSouls = type(f.tradeWorkerSouls) == "table" and f.tradeWorkerSouls or {}
                f.createdDay = tonumber(f.createdDay) or 0
            end
        end

        if DynamicTrading_Factions and DynamicTrading_Factions.RefreshAllPlayerFactions then
            DynamicTrading_Factions.RefreshAllPlayerFactions()
        end

        context.ensureRosterPoolMinimums(data)

        if needsHomeRepair and not context.tryFinalizeFactionBootstrap("init") then
            DynamicTrading.Log("DTCommons", "Faction", "Warn", "Deferred faction home repair until geolocator data becomes available.")
        end

        ModData.transmit(MOD_DATA_KEY)
    end

    function Lifecycle.RepopulateTowns()
        if not context.IS_SERVER_RUNTIME then
            return
        end

        DynamicTrading.Log("DTCommons", "Faction", "Logic", "Starting Town Repopulation...")

        local hasLocations = false
        if type(DT_FactionLocations) == "table" then
            for _ in pairs(DT_FactionLocations) do
                hasLocations = true
                break
            end
        end

        if not hasLocations then
            DynamicTrading.Log("DTCommons", "Faction", "Warn", "RepopulateTowns: No town locations available! Faction spawning aborted.")
            return
        end

        local data = ModData.get(MOD_DATA_KEY) or {}
        local queuedCount, priorityCount = context.scheduleMissingTownPopulation(data)
        if queuedCount == 0 then
            DynamicTrading.Log("DTCommons", "Faction", "Logic", "Town population already satisfies configured limits.")
            return
        end

        local immediateBudget = math.max(priorityCount, 1)
        DynamicTrading.Log(
            "DTCommons",
            "Faction",
            "Logic",
            "Queued " .. tostring(queuedCount) .. " missing town faction spawns; processing " .. tostring(immediateBudget) .. " immediately."
        )
        context.processDeferredTownQueue("startup", immediateBudget, false)
    end
end
