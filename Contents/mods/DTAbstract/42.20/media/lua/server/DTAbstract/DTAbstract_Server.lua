-- Server-authoritative command handler and debug actions for DTAbstract.

if PsychopatzCore and PsychopatzCore.RuntimeRole
    and not PsychopatzCore.RuntimeRole.AllowsServerCode()
then return end

DTAbstract = DTAbstract or {}
DTAbstract.Server = DTAbstract.Server or {}

local Server = DTAbstract.Server
local TraderWorld = DTCommon and DTCommon.TraderWorld
    or require "DTCommon/DTCommon_TraderWorld"
local TraderRuntime = DTCommon and DTCommon.TraderWorldRuntime
local Provider = DTAbstract.TraderWorldProvider
    or require "DTAbstract/DTAbstract_TraderWorldProvider"
local SurvivorRuntime = DTAbstract.SurvivorWorldRuntime
    or require "DTAbstract/DTAbstract_SurvivorWorldRuntime"

local function log(level, message)
    print("[DTAbstract][" .. tostring(level) .. "] " .. tostring(message))
end

local function canUseDebug(player)
    if not player then return true end
    if PsychopatzCore and PsychopatzCore.Debug
        and type(PsychopatzCore.Debug.CanUse) == "function"
    then
        return PsychopatzCore.Debug.CanUse(player) == true
    end
    if isServer and isServer() then
        if type(player.getAccessLevel) == "function" then
            local access = player:getAccessLevel()
            return access ~= nil and access ~= "" and access ~= "None"
        end
    end
    return true
end

local function send(player, command, payload)
    if sendServerCommand then
        sendServerCommand(player, "DTAbstract", command, payload or {})
    elseif triggerEvent then
        triggerEvent("OnServerCommand", "DTAbstract", command, payload or {})
    end
end


local function resolveTeleport()
    if PsychopatzCore and PsychopatzCore.Teleport then
        return PsychopatzCore.Teleport
    end
    local loaded, teleport = pcall(require, "PsychopatzCore/World/PsychopatzTeleport")
    if loaded and type(teleport) == "table" then return teleport end
    return nil
end

function Server.SpawnAbstractTraderNearPlayer(player, args)
    if not canUseDebug(player) then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "spawn_near",
            reason = "not_authorized",
        })
        return nil, "not_authorized"
    end

    args = type(args) == "table" and args or {}
    local px = 10000
    local py = 10000
    local pz = 0

    if player then
        if player.getX then px = tonumber(player:getX()) or px end
        if player.getY then py = tonumber(player:getY()) or py end
        if player.getZ then pz = tonumber(player:getZ()) or pz end
    end

    -- Deterministic nearby offset: 25 tiles away
    local seq = TraderWorld.CountByProvider("DTAbstract")
    local angle = ((seq * 2.399963) % (math.pi * 2))
    local offset = 25
    local spawnX = math.floor(px + math.cos(angle) * offset)
    local spawnY = math.floor(py + math.sin(angle) * offset)
    local spawnZ = math.floor(pz)

    local spawned, reason = TraderWorld.SpawnTrader("DTAbstract", {
        position = { x = spawnX, y = spawnY, z = spawnZ },
        displayName = args.displayName,
        budget = args.budget,
        settlementID = args.settlementID,
    })

    if not spawned then
        log("WARN", "spawn_abstract_near_failed reason=" .. tostring(reason))
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "spawn_near",
            reason = reason or "spawn_failed",
        })
        return nil, reason
    end

    log("INFO", "spawned_abstract_near traderID=" .. tostring(spawned.traderID)
        .. " actorID=" .. tostring(spawned.actorID))


    send(player, "TraderSpawned", {
        accepted = true,
        traderID = spawned.traderID,
        actorID = spawned.actorID,
        position = spawned.position,
        provider = "DTAbstract",
    })

    send(player, "TraderDebugActionResult", {
        accepted = true,
        action = "spawn_near",
        reason = "spawned",
        traderID = spawned.traderID,
        actorID = spawned.actorID,
        position = spawned.position,
        provider = "DTAbstract",
    })

    return spawned
end

function Server.SpawnAbstractTraderAtPosition(player, args)
    if not canUseDebug(player) then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "spawn_at",
            reason = "not_authorized",
        })
        return nil, "not_authorized"
    end
    args = type(args) == "table" and args or {}
    local raw = type(args.position) == "table" and args.position or {}
    local x = tonumber(raw.x)
    local y = tonumber(raw.y)
    local z = tonumber(raw.z) or 0
    if not x or not y or x ~= x or y ~= y then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "spawn_at",
            reason = "invalid_position",
        })
        return nil, "invalid_position"
    end

    local spawned, reason = TraderWorld.SpawnTrader("DTAbstract", {
        position = { x = x, y = y, z = z },
        displayName = args.displayName,
        budget = args.budget,
        settlementID = args.settlementID,
    })
    if not spawned then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "spawn_at",
            reason = reason or "spawn_failed",
        })
        return nil, reason
    end

    send(player, "TraderSpawned", {
        accepted = true,
        traderID = spawned.traderID,
        actorID = spawned.actorID,
        position = spawned.position,
        provider = "DTAbstract",
    })
    send(player, "TraderDebugActionResult", {
        accepted = true,
        action = "spawn_at",
        reason = "spawned",
        traderID = spawned.traderID,
        actorID = spawned.actorID,
        position = spawned.position,
        provider = "DTAbstract",
    })
    return spawned
end

function Server.TeleportPlayerToTrader(player, traderID)
    if not canUseDebug(player) then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "teleport",
            reason = "not_authorized",
        })
        return false, "not_authorized"
    end

    traderID = tostring(traderID or "")
    local record = DTCommon and DTCommon.TraderService and DTCommon.TraderService.GetRecord(traderID)
    if not record or not record.ca then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "teleport",
            reason = "trader_not_found",
        })
        return false, "trader_not_found"
    end

    local pos, positionReason = Provider.getPosition(
        traderID,
        record
    )
    if not pos then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "teleport",
            reason = positionReason or "trader_position_unavailable",
        })
        return false, positionReason or "trader_position_unavailable"
    end

    local teleport = resolveTeleport()
    if not teleport or type(teleport.ToCoordinates) ~= "function" then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = "teleport",
            reason = "teleport_service_unavailable",
        })
        return false, "teleport_service_unavailable"
    end

    local ok, reason = teleport.ToCoordinates(player, pos.x + 1.5, pos.y + 1.5, pos.z)
    send(player, "TraderDebugActionResult", {
        accepted = ok == true,
        action = "teleport",
        reason = ok and "teleported" or (reason or "teleport_failed"),
        traderID = traderID,
    })
    return ok, reason
end

local function onClientCommand(module, command, player, args)
    if module ~= "DTAbstract" then return end
    args = type(args) == "table" and args or {}

    if command == "SpawnAbstractTraderNearPlayer" then
        Server.SpawnAbstractTraderNearPlayer(player, args)
        return
    end
    if command == "SpawnAbstractTraderAtPosition" then
        Server.SpawnAbstractTraderAtPosition(player, args)
        return
    end

    if not canUseDebug(player) then
        send(player, "TraderDebugActionResult", {
            accepted = false,
            action = command,
            reason = "not_authorized",
        })
        return
    end

    if command == "ForceTick" then
        local summary = TraderRuntime
            and type(TraderRuntime.Tick) == "function"
            and TraderRuntime.Tick(true, args.now)
            or TraderWorld.Tick(true, args.now)
            send(player, "TraderDebugActionResult", {
            accepted = summary ~= nil,
            action = "force_tick",
            reason = "ticked",
            summary = summary,
        })
        return
    end

    if command == "ForceArrival" then
        local traderID = args.traderID
        local record = DTCommon.TraderService.GetRecord(traderID)
        if not record or not record.ca then
            send(player, "TraderDebugActionResult", {
                accepted = false,
                action = "force_arrival",
                reason = "trader_not_found",
            })
            return
        end

        local group = SurvivorRuntime.FindGroupForActor(
            record.ca.actorID
        )
        local journey = group and group.journey
        if not journey or journey.state ~= "en_route" then
            send(player, "TraderDebugActionResult", {
                accepted = false,
                action = "force_arrival",
                reason = "journey_not_en_route",
            })
            return
        end

        -- Advance the canonical group journey past its ETA.
        local destTime = (tonumber(journey.eta) or 0) + 1
        local status = TraderWorld.AdvanceTrader(traderID, destTime)
            send(player, "TraderDebugActionResult", {
            accepted = status == "arrived",
            action = "force_arrival",
            reason = status == "arrived" and "arrived" or "arrival_failed",
            traderID = traderID,
        })
        return
    end

    if command == "TeleportToTrader" then
        Server.TeleportPlayerToTrader(player, args.traderID)
        return
    end

    if command == "MaterializeTrader" or command == "DematerializeTrader" then
        local representation =
            DTCommon and DTCommon.TraderRepresentationRuntime or nil
        local action = command == "MaterializeTrader"
            and "materialize" or "dematerialize"
        if not representation then
            send(player, "TraderDebugActionResult", {
                accepted = false,
                action = action,
                reason = "representation_runtime_unavailable",
                traderID = args.traderID,
            })
            return
        end
        local fn = command == "MaterializeTrader"
            and representation.MaterializeTrader
            or representation.DematerializeTrader
        local actor, reason = fn(args.traderID, {
            reason = "dt_debug_" .. action,
        })
        send(player, "TraderDebugActionResult", {
            accepted = actor ~= nil,
            action = action,
            reason = actor and (action .. "d")
                or (reason or (action .. "_failed")),
            traderID = args.traderID,
        })
        return
    end

    if command == "RemoveTrader" then
        local traderID = args.traderID
        local record = DTCommon.TraderService.GetRecord(traderID)
        if not record then
            send(player, "TraderDebugActionResult", {
                accepted = false,
                action = "remove_trader",
                reason = "trader_not_found",
            })
            return
        end

        local released, releaseReason = Provider.releaseTrader(
            traderID,
            record
        )
        if released == false then
            send(player, "TraderDebugActionResult", {
                accepted = false,
                action = "remove_trader",
                reason = releaseReason or "provider_release_failed",
                traderID = traderID,
            })
            return
        end

        DTCommon.TraderService.Remove(traderID)
        send(player, "TraderDebugActionResult", {
            accepted = true,
            action = "remove_trader",
            reason = "commercial_role_removed",
            traderID = traderID,
        })
        return
    end
end

if Events and Events.OnClientCommand
    and type(Events.OnClientCommand.Add) == "function"
    and not Server.CommandHookRegistered
then
    Server.CommandHookRegistered = true
    Events.OnClientCommand.Add(onClientCommand)
end

return Server
