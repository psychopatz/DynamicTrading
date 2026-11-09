-- Shared DynamicTrading debug spawn surface.
-- The UI is provider-neutral; the active trader provider decides whether the
-- spawned trader is abstract or physically materialized.

DTCommon = DTCommon or {}
DTCommon.TraderDebug = DTCommon.TraderDebug or {}

local Debug = DTCommon.TraderDebug

local ActorNotifications = PsychopatzCore
    and PsychopatzCore.ActorNotifications
if not ActorNotifications then
    local ok, value = pcall(
        require,
        "PsychopatzCore/UI/PsychopatzActorNotificationToast"
    )
    if ok then ActorNotifications = value end
end

local function canUseDebug()
    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if not player then return true end
    if PsychopatzCore and PsychopatzCore.Debug
        and type(PsychopatzCore.Debug.CanUse) == "function"
    then
        return PsychopatzCore.Debug.CanUse(player) == true
    end
    return false
end

local function setManagerResult(message, args)
    local manager = DTCommon and DTCommon.TraderManager or nil
    if manager and type(manager.SetResult) == "function" then
        manager.SetResult(message, args)
    end
end

local function playerForIndex(playerNum)
    if type(playerNum) == "number" and getSpecificPlayer then
        return getSpecificPlayer(playerNum)
    end
    return getSpecificPlayer and getSpecificPlayer(0) or nil
end

local function objectSquare(value)
    if value and type(value.getSquare) == "function" then
        local ok, square = pcall(value.getSquare, value)
        if ok and square then return square end
    end
    return nil
end

local function squareFromObjects(worldObjects)
    if type(worldObjects) == "table" then
        for _, object in ipairs(worldObjects) do
            local square = objectSquare(object)
            if square then return square end
        end
    elseif worldObjects
        and type(worldObjects.size) == "function"
        and type(worldObjects.get) == "function"
    then
        local okSize, size = pcall(worldObjects.size, worldObjects)
        if okSize then
            for index = 0, (tonumber(size) or 0) - 1 do
                local okGet, object = pcall(
                    worldObjects.get,
                    worldObjects,
                    index
                )
                local square = okGet and objectSquare(object) or nil
                if square then return square end
            end
        end
    end
    return nil
end

local function squareFor(playerNum, worldObjects)
    local square = squareFromObjects(worldObjects)
    if square then return square end
    local player = playerForIndex(playerNum)
    return player and player.getSquare and player:getSquare() or nil
end

function Debug.RequestSpawnAt(playerNum, square)
    local player = playerForIndex(playerNum)
    if not player or not square
        or type(sendClientCommand) ~= "function"
    then
        return false, "debug_spawn_unavailable"
    end
    sendClientCommand(
        player,
        DTCommon.MOD_ID or "DTCommon",
        "DebugSpawnTrader",
        {
            x = square:getX(),
            y = square:getY(),
            z = square:getZ(),
        }
    )
    return true
end

function Debug.SpawnAtPlayer(playerNum)
    if not canUseDebug() then return false, "not_authorized" end
    playerNum = type(playerNum) == "number" and playerNum or 0
    local player = playerForIndex(playerNum)
    local square = player
        and player.getSquare
        and player:getSquare() or nil
    if not square then return false, "player_square_unavailable" end
    return Debug.RequestSpawnAt(playerNum, square)
end

local function spawnFromContext(_, playerNum, square)
    return Debug.RequestSpawnAt(playerNum, square)
end

function Debug.AddContextMenu(context, playerNum, worldObjects)
    if not canUseDebug() or not context then return nil end
    local square = squareFor(playerNum, worldObjects)
    if not square then return nil end
    return context:addOption(
        DTCommon.T(
            "DTCommon_Debug_SpawnTrader",
            "[Debug] Spawn Trader"
        ),
        nil,
        spawnFromContext,
        playerNum,
        square
    )
end

local function onContextMenu(playerNum, context, worldObjects, test)
    if test then return end
    Debug.AddContextMenu(context, playerNum, worldObjects)
end

local function onServerCommand(module, command, args)
    if module ~= (DTCommon.MOD_ID or "DTCommon")
        or command ~= "TraderDebugSpawnResult"
    then
        return
    end
    args = type(args) == "table" and args or {}
    Debug.LastSpawnResult = args

    local position = type(args.position) == "table"
        and args.position or nil
    local positionText = position
        and (" at " .. tostring(math.floor(tonumber(position.x) or 0))
            .. "," .. tostring(math.floor(tonumber(position.y) or 0)))
        or ""
    local message
    if args.pending == true then
        message = "Trader spawn queued" .. positionText .. "."
    elseif args.accepted == true then
        message = "Spawned trader " .. tostring(args.traderID or "")
            .. positionText .. "."
        if tostring(args.provider or "") == "DTAbstract" then
            message = message
                .. " Abstract mode creates no visible world body; check the map dot."
        end
    else
        message = "Trader spawn failed: "
            .. tostring(args.reason or "unknown")
    end

    setManagerResult(message, args)

    -- Actor notifications describe abstract traders. A physical Hoomans
    -- trader is already visible and interactable, so retain the debug result
    -- in the manager/log without opening a redundant actor toast.
    if tostring(args.provider or "") ~= "DTAbstract"
        or args.pending == true
        or args.accepted ~= true
    then
        print("[DT][DEBUG] " .. message)
        return
    end

    local view
    local presentation = DTCommon and DTCommon.TraderPresentation
    if presentation and type(presentation.GetTraderView) == "function"
    then
        view = presentation.GetTraderView(args.traderID, false)
    end
    local portraitSpec = view and view.portraitSpec or nil
    local factionBadge
    if view and type(view.factionPresentation) == "table" then
        local faction = view.factionPresentation
        factionBadge = faction.badge or faction
    end
    if not portraitSpec and args.actorID then
        local ok, Client = pcall(
            require,
            "PsychopatzCore/World/SurvivorWorld/PsychopatzSurvivorWorldClient"
        )
        if ok and Client and type(Client.GetPortraitSpec) == "function" then
            portraitSpec = Client.GetPortraitSpec(args.actorID)
        end
    end

    if ActorNotifications
        and type(ActorNotifications.Show) == "function"
    then
        local requestID = tostring(args.requestID or "unknown")
        local phase = args.pending == true and "queued" or "result"
        local actions = {
            {
                id = "talk",
                label = "Talk",
                callback = function()
                    local manager = DTCommon and DTCommon.TraderManager
                    if not manager then
                        local ok, value = pcall(
                            require,
                            "DTCommon/DTCommon_TraderManager"
                        )
                        if ok then manager = value end
                    end
                    if manager and type(manager.Request) == "function" then
                        local ok, reason = manager.Request(
                            "talk",
                            args.traderID,
                            {
                                mode = "nearby",
                                actorID = args.actorID,
                            }
                        )
                        if not ok and manager.SetNotice then
                            manager.SetNotice(reason)
                        end
                        return ok
                    end
                    return false
                end,
            },
        }
        ActorNotifications.Show({
            id = "dtcommon:debug_spawn:" .. requestID .. ":" .. phase,
            actorID = args.actorID,
            name = view and view.name or args.traderID or "Dynamic Trading",
            message = message,
            portraitSpec = portraitSpec,
            factionBadge = factionBadge,
            actions = actions,
        })
    else
        print("[DT][DEBUG] " .. message)
    end
end

if Events and Events.OnFillWorldObjectContextMenu
    and type(Events.OnFillWorldObjectContextMenu.Add) == "function"
    and not Debug._contextHook
then
    Debug._contextHook = true
    Events.OnFillWorldObjectContextMenu.Add(onContextMenu)
end

if Events and Events.OnServerCommand
    and type(Events.OnServerCommand.Add) == "function"
    and not Debug._serverHook
then
    Debug._serverHook = true
    Events.OnServerCommand.Add(onServerCommand)
end

if not (PsychopatzCore and PsychopatzCore.DebugHub) then
    if PsychopatzCore and PsychopatzCore.Require then
        PsychopatzCore.Require("core.debug_hub", "DTCommon")
    else
        pcall(require, "PsychopatzCore/UI/PsychopatzDebugHubWindow")
    end
end

local CoreDebugHub = PsychopatzCore and PsychopatzCore.DebugHub
if CoreDebugHub
    and type(CoreDebugHub.RegisterTool) == "function"
    and not Debug._hubToolRegistered
then
    Debug._hubToolRegistered = true
    CoreDebugHub.RegisterTool({
        id = "dtcommon.spawnTrader",
        source = "Dynamic Trading",
        order = 210,
        category = "dynamictrading",
        title = DTCommon.T(
            "DTCommon_Debug_SpawnTraderAtPlayer",
            "Spawn Trader at Player"
        ),
        description = DTCommon.T(
            "DTCommon_Debug_SpawnTraderAtPlayer_Description",
            "Spawn a trader using the active Dynamic Trading provider at your current tile."
        ),
        available = canUseDebug,
        action = function()
            return Debug.SpawnAtPlayer(0)
        end,
    })
end

return Debug
