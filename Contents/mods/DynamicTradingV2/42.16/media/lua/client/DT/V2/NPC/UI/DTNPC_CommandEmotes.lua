-- ==============================================================================
-- DTNPC_CommandEmotes.lua
-- Maps Dynamic Colonies / companion commands to vanilla emote animations.
-- ==============================================================================

if isServer() and not isClient() then
    return
end

DTNPC_CommandEmotes = DTNPC_CommandEmotes or {}

local CommandEmotes = DTNPC_CommandEmotes

local EMOTES_BY_COMMAND = {
    ClaimCommand = "signalok",
    TransferCommand = "signalok",
    Follow = "followme",
    Stay = "freeze",
    Guard = "salute",
    GuardAuto = "salute",
    GuardRanged = "signalfire",
    GuardMelee = "comefront",
    ProtectAuto = "signalok",
    ProtectRanged = "signalfire",
    ProtectMelee = "comefront",
    LootNearby = "moveout",
    GoHome = "moveout",
}

function CommandEmotes.Resolve(commandKey)
    local key = commandKey and tostring(commandKey) or nil
    return key and EMOTES_BY_COMMAND[key] or nil
end

function CommandEmotes.Play(player, commandKey)
    if not player or not commandKey or player.isDead and player:isDead() then
        return false
    end

    local emoteID = CommandEmotes.Resolve(commandKey)
    if not emoteID or not player.playEmote then
        return false
    end

    player:playEmote(emoteID)
    return true
end
