DTCommon = DTCommon or {}
local Service = DTCommon.TraderService
local TraderWorld = DTCommon.TraderWorld
    or require "DTCommon/DTCommon_TraderWorld"
local Providers = DTCommon.TraderProviders
    or require "DTCommon/DTCommon_TraderProviderRegistry"

local function log(level, message)
    print("[DT][" .. tostring(level) .. "] " .. tostring(message))
end

local function isLocalPlayer(player)
    local localPlayer = getSpecificPlayer and getSpecificPlayer(0) or nil
    if localPlayer ~= nil and player == localPlayer then return true end
    if player and type(player.isLocalPlayer) == "function" then
        local ok, value = pcall(player.isLocalPlayer, player)
        return ok and value == true
    end
    return false
end

local function canUseDebug(player)
    if not player then return true end
    if PsychopatzCore and PsychopatzCore.Debug
        and type(PsychopatzCore.Debug.CanUse) == "function"
    then
        return PsychopatzCore.Debug.CanUse(player) == true
    end
    if isServer and isServer()
        and type(player.getAccessLevel) == "function"
    then
        local access = player:getAccessLevel()
        return access ~= nil and access ~= "" and access ~= "None"
    end
    return true
end

local function send(player, command, payload)
    payload = payload or {}
    if isLocalPlayer(player) and type(triggerEvent) == "function" then
        triggerEvent("OnServerCommand", DTCommon.MOD_ID, command, payload)
        return true
    end
    if player and type(sendServerCommand) == "function" then
        sendServerCommand(player, DTCommon.MOD_ID, command, payload)
        return true
    end
    if type(triggerEvent) == "function"
        and (not isServer or not isServer())
    then
        triggerEvent("OnServerCommand", DTCommon.MOD_ID, command, payload)
        return true
    end
    return false
end

local function debugSpawnTrader(player, args)
    if not canUseDebug(player) then
        send(player, "TraderDebugSpawnResult", {
            accepted = false,
            reason = "not_authorized",
        })
        return
    end
    local x = tonumber(args and args.x)
    local y = tonumber(args and args.y)
    local z = tonumber(args and args.z) or 0
    if x == nil or y == nil
        or x ~= x or y ~= y
        or x == math.huge or x == -math.huge
        or y == math.huge or y == -math.huge
    then
        send(player, "TraderDebugSpawnResult", {
            accepted = false,
            reason = "invalid_position",
        })
        return
    end
    local provider = Providers.Select("spawnTrader", {
        debug = true,
        position = { x = x, y = y, z = z },
    })
    if not provider then
        send(player, "TraderDebugSpawnResult", {
            accepted = false,
            reason = "spawn_provider_unavailable",
        })
        return
    end
    local spawned, reason = TraderWorld.SpawnTrader(
        provider.id,
        {
            debug = true,
            position = { x = x, y = y, z = z },
            worldRole = "roaming",
        }
    )
    if not spawned then
        send(player, "TraderDebugSpawnResult", {
            accepted = false,
            provider = provider.id,
            reason = reason or "spawn_failed",
        })
        return
    end
    send(player, "TraderDebugSpawnResult", {
        accepted = true,
        provider = provider.id,
        traderID = spawned.traderID,
        actorID = spawned.actorID,
        position = spawned.position,
        reason = "spawned",
    })
end

local function onClientCommand(module, command, player, args)
    if module ~= DTCommon.MOD_ID then return end
    args = type(args) == "table" and args or {}
    if command == "DebugSpawnTrader" then
        debugSpawnTrader(player, args)
    elseif command == "RequestTrader" then
        log("INFO", "snapshot_request trader=" .. tostring(args.traderID))
        local snapshot, reason = Service.Snapshot(args.traderID, player)
        log("INFO", "snapshot_response trader=" .. tostring(args.traderID)
            .. " items=" .. tostring(snapshot and #(snapshot.items or {}) or 0)
            .. " reason=" .. tostring(reason))
        send(player, "TraderSnapshot", snapshot or {
            traderID = args.traderID,
            reason = reason,
        })
    elseif command == "TradeRequest" then
        log("INFO", "trade_request trader=" .. tostring(args.traderID)
            .. " request=" .. tostring(args.requestID))
        local result = Service.ExecuteTrade(player, args)
        log("INFO", "trade_response trader=" .. tostring(args.traderID)
            .. " accepted=" .. tostring(result and result.accepted)
            .. " reason=" .. tostring(result and result.reason))
        send(player, "TradeResult", result)
    elseif command == "TradeBasketRequest" then
        log("INFO", "trade_basket_request trader=" .. tostring(args.traderID)
            .. " request=" .. tostring(args.requestID))
        local result = Service.ExecuteTradeBasket(player, args)
        log("INFO", "trade_basket_response trader=" .. tostring(args.traderID)
            .. " accepted=" .. tostring(result and result.accepted)
            .. " reason=" .. tostring(result and result.reason))
        send(player, "TradeResult", result)
    end
end

if Events and Events.OnClientCommand
    and type(Events.OnClientCommand.Add) == "function"
then
    Events.OnClientCommand.Add(onClientCommand)
end

return DTCommon
