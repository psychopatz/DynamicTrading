-- ==============================================================================
-- DTNPC_Bandits_Server_Events.lua
-- Server-side event registration for the split bandits subsystem.
-- ==============================================================================

if isClient() and not isServer() then return end

local Bandits = DTNPCBandits

local function getRaidOnTick()
    local internal = Bandits and Bandits.Internal or nil
    local raid = internal and internal.Raid or nil
    return raid and raid.onTick or nil
end

local function getDebugCommandHandler()
    local internal = Bandits and Bandits.Internal or nil
    local debug = internal and internal.Debug or nil
    return debug and debug.onClientCommand or nil
end

local function onTick()
    local raidOnTick = getRaidOnTick()
    if raidOnTick then
        raidOnTick()
    end
end

local function onClientCommand(module, command, player, args)
    local debugHandler = getDebugCommandHandler()
    if debugHandler then
        debugHandler(module, command, player, args)
    end
end

if not Bandits.EventsRegistered then
    Events.OnTick.Add(onTick)
    Events.OnClientCommand.Add(onClientCommand)
    Bandits.EventsRegistered = true
end

DynamicTrading.Log("DTV2", "Init", "Bandits", "Bandit ambush server subsystem loaded")
