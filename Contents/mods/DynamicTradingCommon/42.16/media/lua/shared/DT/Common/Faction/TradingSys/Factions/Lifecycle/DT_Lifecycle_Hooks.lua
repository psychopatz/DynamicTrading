return function(context)
    local deferredTownQueue = context.deferredTownQueue

    local function onLifecycleServerStarted()
        context.tryFinalizeFactionBootstrap("server-start")
    end

    local function onLifecycleTick()
        context.townVisitTickCounter = context.townVisitTickCounter + 1
        if context.townVisitTickCounter >= 60 then
            context.townVisitTickCounter = 0
            context.updateExplorationDrivenTownGeneration()
        end

        if not context.deferredBootstrapPending then
            return
        end

        context.deferredBootstrapTickCounter = context.deferredBootstrapTickCounter + 1
        if context.deferredBootstrapTickCounter < 300 then
            return
        end

        context.deferredBootstrapTickCounter = 0
        context.tryFinalizeFactionBootstrap("deferred-retry")
    end

    local function onLifecycleDailySimulation()
        if #deferredTownQueue == 0 then
            return
        end

        if context.ensureGeolocatorReady() then
            DynamicTrading.Log(
                "DTCommons",
                "Faction",
                "Queue",
                "Daily simulation advancing deferred town queue; pending=" .. tostring(#deferredTownQueue)
            )
            context.processDeferredTownQueue("daily-simulation", 1, false)
        end
    end

    if context.IS_SERVER_RUNTIME then
        Events.OnServerStarted.Add(onLifecycleServerStarted)
        Events.OnTick.Add(onLifecycleTick)
        Events.OnDynamicTradingDailySimulation.Add(onLifecycleDailySimulation)
    end
end
