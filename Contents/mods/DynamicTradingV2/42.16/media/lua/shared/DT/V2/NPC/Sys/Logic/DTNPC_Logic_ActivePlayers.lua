-- ==============================================================================
-- DTNPC_Logic_ActivePlayers.lua
-- Active player snapshot helpers for NPC logic.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.ActivePlayersSnapshot = DTNPCLogic.ActivePlayersSnapshot or {}

function DTNPCLogic.RefreshActivePlayers()
    local players = {}

    if DTNPCManager and DTNPCManager.GetActivePlayers then
        local activePlayers = DTNPCManager.GetActivePlayers()
        if activePlayers then
            for i = 1, #activePlayers do
                local player = activePlayers[i]
                if player then
                    players[#players + 1] = player
                end
            end
        end
    else
        local onlinePlayers = getOnlinePlayers()
        if onlinePlayers then
            for i = 0, onlinePlayers:size() - 1 do
                local player = onlinePlayers:get(i)
                if player then
                    players[#players + 1] = player
                end
            end
        end
    end

    if #players == 0 then
        local player = nil
        if getSpecificPlayer then
            player = getSpecificPlayer(0)
        end
        if not player and getPlayer then
            player = getPlayer()
        end
        if player then
            players[1] = player
        end
    end

    DTNPCLogic.ActivePlayersSnapshot = players
end

function DTNPCLogic.GetActivePlayers()
    return DTNPCLogic.ActivePlayersSnapshot or {}
end
