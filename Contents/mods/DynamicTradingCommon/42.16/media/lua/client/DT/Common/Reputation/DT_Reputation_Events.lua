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

if not Internal.EventsRegistered then
    Events.OnCreatePlayer.Add(onCreatePlayer)
    Events.OnGameStart.Add(onGameStart)
    Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData)
    Events.OnTick.Add(onTick)
    Internal.EventsRegistered = true
end
