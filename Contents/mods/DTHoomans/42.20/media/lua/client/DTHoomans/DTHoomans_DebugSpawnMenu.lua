DTHoomans = DTHoomans or {}
DTHoomans.DebugSpawnMenu = DTHoomans.DebugSpawnMenu or {}

local Menu = DTHoomans.DebugSpawnMenu

local function canUseDebug()
    return PNC and PNC.Client and PNC.Client.CanUseDebug
        and PNC.Client.CanUseDebug() == true
end

local function playerForIndex(playerNum)
    if type(playerNum) == "number" and getSpecificPlayer then
        return getSpecificPlayer(playerNum)
    end
    return getSpecificPlayer and getSpecificPlayer(0) or nil
end

local function squareFor(playerNum, worldObjects)
    if PNC and PNC.NPCSelection
        and type(PNC.NPCSelection.GetWorldSquare) == "function"
    then
        local square = PNC.NPCSelection.GetWorldSquare(worldObjects)
        if square then return square end
    end
    local player = playerForIndex(playerNum)
    return player and player.getSquare and player:getSquare() or nil
end

local function resolvePlayer(playerNum)
    -- Context-menu player indices may arrive as Java/Kahlua numeric values.
    -- Calling tonumber() on that value can throw a Java primitive conversion
    -- error on 42.20, so only pass plain Lua numbers through.
    return playerForIndex(playerNum)
end

local function spawn(_, playerNum, square)
    local player = resolvePlayer(playerNum)
    if not player or not square or type(sendClientCommand) ~= "function" then
        return false
    end
    print("[DT][INFO] spawn_request player="
        .. tostring(playerNum) .. " square="
        .. tostring(square:getX()) .. ","
        .. tostring(square:getY()) .. ","
        .. tostring(square:getZ()))
    sendClientCommand(player, DTHoomans.MOD_ID, DTHoomans.SPAWN_COMMAND, {
        x = square:getX(),
        y = square:getY(),
        z = square:getZ(),
    })
    return true
end

function Menu.Add(context, playerNum, worldObjects)
    local spawnOption
    if not canUseDebug() or not context then return nil end
    local square = squareFor(playerNum, worldObjects)
    if square then
        spawnOption = context:addOption(
            DTCommon.T("DTHoomans_Debug_SpawnTrader", "[Debug] Spawn Trader"),
            nil,
            spawn,
            playerNum,
            square
        )
    end
    return spawnOption
end

return Menu
