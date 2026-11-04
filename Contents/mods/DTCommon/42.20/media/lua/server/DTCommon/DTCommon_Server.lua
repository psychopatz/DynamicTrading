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

DTCommon.TraderDebugServer = DTCommon.TraderDebugServer or {}
local DebugServer = DTCommon.TraderDebugServer
DebugServer.Queue = DebugServer.Queue or {}
DebugServer.Serial = tonumber(DebugServer.Serial) or 0
DebugServer.MAX_PENDING = 8
DebugServer.Processing = DebugServer.Processing == true

local function spawnPosition(args)
    local x = tonumber(args and args.x)
    local y = tonumber(args and args.y)
    local z = tonumber(args and args.z) or 0
    if x == nil or y == nil
        or x ~= x or y ~= y
        or x == math.huge or x == -math.huge
        or y == math.huge or y == -math.huge
    then
        return nil
    end
    return { x = x, y = y, z = z }
end

local function queueDebugSpawn(player, args)
    if not canUseDebug(player) then
        send(player, "TraderDebugSpawnResult", {
            accepted = false,
            pending = false,
            reason = "not_authorized",
        })
        return false
    end

    local position = spawnPosition(args)
    if not position then
        send(player, "TraderDebugSpawnResult", {
            accepted = false,
            pending = false,
            reason = "invalid_position",
        })
        return false
    end
    if #DebugServer.Queue >= DebugServer.MAX_PENDING then
        send(player, "TraderDebugSpawnResult", {
            accepted = false,
            pending = false,
            reason = "spawn_queue_full",
        })
        return false
    end

    DebugServer.Serial = DebugServer.Serial + 1
    local requestID = "dt_debug_spawn:" .. tostring(DebugServer.Serial)
    DebugServer.Queue[#DebugServer.Queue + 1] = {
        requestID = requestID,
        player = player,
        position = position,
    }
    log("INFO", "debug_spawn_queued request=" .. requestID
        .. " x=" .. tostring(position.x)
        .. " y=" .. tostring(position.y)
        .. " pending=" .. tostring(#DebugServer.Queue))
    send(player, "TraderDebugSpawnResult", {
        accepted = true,
        pending = true,
        requestID = requestID,
        position = position,
        reason = "queued",
    })
    return true
end

local function processDebugSpawn(job)
    local position = job.position
    log("INFO", "debug_spawn_processing request=" .. tostring(job.requestID))

    local provider = Providers.Select("spawnTrader", {
        debug = true,
        position = position,
    })
    if not provider then
        send(job.player, "TraderDebugSpawnResult", {
            accepted = false,
            pending = false,
            requestID = job.requestID,
            reason = "spawn_provider_unavailable",
        })
        return
    end

    local spawned, reason = TraderWorld.SpawnTrader(
        provider.id,
        {
            debug = true,
            position = position,
            worldRole = "roaming",
        }
    )
    if not spawned then
        send(job.player, "TraderDebugSpawnResult", {
            accepted = false,
            pending = false,
            requestID = job.requestID,
            provider = provider.id,
            reason = reason or "spawn_failed",
        })
        return
    end

    log("INFO", "debug_spawn_completed request=" .. tostring(job.requestID)
        .. " provider=" .. tostring(provider.id)
        .. " trader=" .. tostring(spawned.traderID)
        .. " actor=" .. tostring(spawned.actorID))
    send(job.player, "TraderDebugSpawnResult", {
        accepted = true,
        pending = false,
        requestID = job.requestID,
        provider = provider.id,
        traderID = spawned.traderID,
        actorID = spawned.actorID,
        position = spawned.position or position,
        reason = "spawned",
    })
end

local function processDebugSpawnQueue()
    if DebugServer.Processing or #DebugServer.Queue == 0 then return end
    local job = table.remove(DebugServer.Queue, 1)
    DebugServer.Processing = true
    local ok, err = pcall(processDebugSpawn, job)
    DebugServer.Processing = false
    if not ok then
        log("ERROR", "debug_spawn_failed request="
            .. tostring(job and job.requestID)
            .. " error=" .. tostring(err))
        send(job and job.player or nil, "TraderDebugSpawnResult", {
            accepted = false,
            pending = false,
            requestID = job and job.requestID or nil,
            reason = "spawn_internal_error",
        })
    end
end

local function onClientCommand(module, command, player, args)
    if module ~= DTCommon.MOD_ID then return end
    args = type(args) == "table" and args or {}
    if command == "DebugSpawnTrader" then
        queueDebugSpawn(player, args)
    elseif command == "RequestTrader" then
        log("INFO", "snapshot_request trader=" .. tostring(args.traderID))
        local snapshot, reason = Service.Snapshot(
            args.traderID,
            player,
            args
        )
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

if Events and Events.OnTick
    and type(Events.OnTick.Add) == "function"
    and not DebugServer.TickHookRegistered
then
    DebugServer.TickHookRegistered = true
    Events.OnTick.Add(processDebugSpawnQueue)
end

return DTCommon
