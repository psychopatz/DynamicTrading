if isServer() then return end

DT_Reputation = DT_Reputation or {}
DT_Reputation.Internal = DT_Reputation.Internal or {}

local Internal = DT_Reputation.Internal

local function onCreatePlayer()
    DT_Reputation.EnsureLoaded()
end

local function onGameStart()
    DT_Reputation.EnsureLoaded()
end

local function onReceiveGlobalModData(key, data)
    if key == "DynamicTrading_Roster" then
        Internal.InvalidateAllFactionCache()
    end
end

local function onTick()
    local state = DT_Reputation.state
    if not state.dirty or not state.saveDueAt then return end
    if getTimeInMillis() >= state.saveDueAt then
        DT_Reputation.Save()
    end
end

local function onServerCommand(module, command, args)
    if module ~= "DynamicTrading" or command ~= "ReputationSync" or type(args) ~= "table" then
        return
    end

    local action = tostring(args.action or "")
    if action == "factionBiasDelta" then
        DT_Reputation.ModifyFactionBias(args.factionID, args.amount, args.reason or "server_sync")
    elseif action == "personalRepDelta" then
        DT_Reputation.ModifyPersonalRep(args.traderUUID, args.factionID, args.amount, args.reason or "server_sync")
    elseif action == "rosterPersonalRepSync" then
        DT_Reputation.ApplyRosterPersonalRepSync(
            args.memberUUIDs,
            args.factionID,
            args.mode,
            args.value,
            args.reason or "server_sync"
        )
    end
end

if not Internal.EventsRegistered then
    Events.OnCreatePlayer.Add(onCreatePlayer)
    Events.OnGameStart.Add(onGameStart)
    Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData)
    Events.OnTick.Add(onTick)
    Events.OnServerCommand.Add(onServerCommand)
    Internal.EventsRegistered = true
end
