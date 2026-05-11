-- ==============================================================================
-- DTNPC_ServerCoreArrival_Targeting.lua
-- Target and square resolution helpers for DTNPC server arrival modules.
-- ==============================================================================

DTNPCServerCore = DTNPCServerCore or {}
DTNPCServerCoreArrival = DTNPCServerCoreArrival or {}
DTNPCServerCoreArrival.Internal = DTNPCServerCoreArrival.Internal or {}

if isClient() and not isServer() then return end

local Internal = DTNPCServerCoreArrival.Internal

function Internal.GetActivePlayers()
    if DTNPCManager and DTNPCManager.GetActivePlayers then
        return DTNPCManager.GetActivePlayers()
    end
    return {}
end

function Internal.FindPlayerByIdentity(username, onlineID)
    local players = Internal.GetActivePlayers()
    local wantedName = username and tostring(username) or nil
    local wantedID = onlineID ~= nil and tonumber(onlineID) or nil
    local index = 1
    while index <= #players do
        local player = players[index]
        if player then
            local playerID = player.getOnlineID and player:getOnlineID() or nil
            local playerName = player.getUsername and player:getUsername() or nil
            if wantedID ~= nil and playerID ~= nil and tonumber(playerID) == wantedID then
                return player
            end
            if wantedName and wantedName ~= "" and playerName and tostring(playerName) == wantedName then
                return player
            end
        end
        index = index + 1
    end
    return nil
end

function Internal.ResolveArrivalTarget(options, npcData)
    options = type(options) == "table" and options or {}

    local player = nil
    if options.targetPlayer and options.targetPlayer.getUsername then
        player = options.targetPlayer
    end

    local targetUsername = tostring(options.targetUsername or "")
    local targetOnlineID = options.targetOnlineID ~= nil and tonumber(options.targetOnlineID) or nil

    if not player and options.controller and DTNPCServerCore.ResolveControllerIdentity then
        local controllerName, controllerID = DTNPCServerCore.ResolveControllerIdentity(options.controller)
        if targetUsername == "" then
            targetUsername = controllerName or targetUsername
        end
        if targetOnlineID == nil then
            targetOnlineID = controllerID
        end
        if options.controller.getUsername then
            player = options.controller
        end
    end

    if not player and targetUsername ~= "" then
        player = Internal.FindPlayerByIdentity(targetUsername, targetOnlineID)
    elseif not player and targetOnlineID ~= nil then
        player = Internal.FindPlayerByIdentity(nil, targetOnlineID)
    end

    if not player and npcData then
        local mode = tostring(options.activationMode or "")
        if mode == "contact_follow" or mode == "contact_trading" then
            player = Internal.FindPlayerByIdentity(npcData.contactVisitRequestedBy, npcData.contactVisitRequestedByID)
            if player then
                targetUsername = player.getUsername and player:getUsername() or targetUsername
                targetOnlineID = player.getOnlineID and player:getOnlineID() or targetOnlineID
            end
        elseif mode == "companion_follow" then
            player = Internal.FindPlayerByIdentity(npcData.master or npcData.dcCommanderUsername, npcData.masterID or npcData.dcCommanderOnlineID)
            if player then
                targetUsername = player.getUsername and player:getUsername() or targetUsername
                targetOnlineID = player.getOnlineID and player:getOnlineID() or targetOnlineID
            end
        end
    end

    local targetX = tonumber(options.targetX)
    local targetY = tonumber(options.targetY)
    local targetZ = tonumber(options.targetZ)

    if player then
        if targetUsername == "" then
            targetUsername = player.getUsername and player:getUsername() or ""
        end
        if targetOnlineID == nil then
            targetOnlineID = player.getOnlineID and player:getOnlineID() or nil
        end
        if targetX == nil then
            targetX = player:getX()
        end
        if targetY == nil then
            targetY = player:getY()
        end
        if targetZ == nil then
            targetZ = player:getZ()
        end
    end

    if targetX == nil and npcData then
        targetX = tonumber(npcData.contactVisitTargetX or npcData.departureTargetX or nil)
    end
    if targetY == nil and npcData then
        targetY = tonumber(npcData.contactVisitTargetY or npcData.departureTargetY or nil)
    end
    if targetZ == nil and npcData then
        targetZ = tonumber(npcData.contactVisitTargetZ or npcData.departureTargetZ or npcData.lastZ or 0)
    end

    if targetX == nil or targetY == nil then
        return nil
    end

    return {
        player = player,
        username = targetUsername ~= "" and targetUsername or nil,
        onlineID = targetOnlineID,
        x = targetX,
        y = targetY,
        z = tonumber(targetZ) or 0,
    }
end

function Internal.ChooseArrivalSquare(target, npcData, options)
    if not target then
        return nil, "target_missing"
    end

    options = type(options) == "table" and options or {}
    local policy = tostring(options.spawnPolicy or "nearby_follow")

    if policy == "offscreen_follow" and target.player and DTNPCServerCore.FindOffscreenArrivalSquare then
        local square = DTNPCServerCore.FindOffscreenArrivalSquare(target.player, npcData)
        if square then
            return square
        end
    elseif policy == "nearby_follow" and target.player and DTNPCServerCore.FindNearbyArrivalSquare then
        local square = DTNPCServerCore.FindNearbyArrivalSquare(
            target.player,
            tonumber(options.minRadius) or 2,
            tonumber(options.maxRadius) or 5
        )
        if square then
            return square
        end
    elseif (policy == "ambush" or policy == "site_anchor") and DTNPCServerCore.FindArrivalSquareNearCoords then
        local square = DTNPCServerCore.FindArrivalSquareNearCoords(
            target.x,
            target.y,
            target.z,
            tonumber(options.searchRadius) or 2
        )
        if square then
            return square
        end
    end

    if DTNPCServerCore.FindArrivalSquareNearCoords then
        local fallback = DTNPCServerCore.FindArrivalSquareNearCoords(
            target.x,
            target.y,
            target.z,
            tonumber(options.searchRadius) or 4
        )
        if fallback then
            return fallback
        end
    end

    if target.player and DTNPCServerCore.FindNearbyArrivalSquare then
        return DTNPCServerCore.FindNearbyArrivalSquare(target.player, 1, 6), "no_square"
    end

    return nil, "no_square"
end
