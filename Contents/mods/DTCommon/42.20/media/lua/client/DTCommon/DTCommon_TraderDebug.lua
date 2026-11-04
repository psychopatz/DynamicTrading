-- Shared DynamicTrading debug spawn surface.
-- The UI is provider-neutral; the active trader provider decides whether the
-- spawned trader is abstract or physically materialized.

DTCommon = DTCommon or {}
DTCommon.TraderDebug = DTCommon.TraderDebug or {}

local Debug = DTCommon.TraderDebug

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
    local message = args.accepted == true
        and ("Spawned trader " .. tostring(args.traderID or ""))
        or ("Trader spawn failed: " .. tostring(args.reason or "unknown"))
    if PsychopatzCore and PsychopatzCore.Notifications
        and type(PsychopatzCore.Notifications.Show) == "function"
    then
        PsychopatzCore.Notifications.Show({
            id = "dtcommon:debug_spawn",
            title = "Dynamic Trading Debug",
            message = message,
            text = message,
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
