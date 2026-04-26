-- ==============================================================================
-- DTNPC_Bandits_Client_Events.lua
-- Client-side event registration and command routing for bandits.
-- ==============================================================================

if isServer() and not isClient() then return end

local BanditClient = DTNPCBanditClient
BanditClient.Internal = BanditClient.Internal or {}
BanditClient.Internal.Helpers = BanditClient.Internal.Helpers or {}
local Helpers = BanditClient.Internal.Helpers

local function isBanditClientActive()
    return type(Helpers.isCurrencyExpandedActive) == "function"
        and Helpers.isCurrencyExpandedActive() == true
end

local function onTick()
    if not BanditClient then return end
    BanditClient.TickCounter = (BanditClient.TickCounter or 0) + 1
    if BanditClient.TickCounter % 15 ~= 0 then return end
    if not isBanditClientActive() then return end

    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if not player or player:isDead() then return end
    if not DTNPCClient or not DTNPCClient.NPCCache then return end

    for uuid, cacheEntry in pairs(DTNPCClient.NPCCache) do
        local npcData = cacheEntry and (cacheEntry.npcData or cacheEntry) or nil
        local groupID = Helpers.normalize(npcData and npcData.banditGroupID)
        if npcData
            and npcData.isBandit == true
            and groupID
            and npcData.banditDemandResolved ~= true
            and npcData.isHostile ~= true
            and not BanditClient.OpenedGroups[groupID]
            and not BanditClient.ResolvedGroups[groupID]
            and Helpers.isTargetingLocalPlayer(npcData, player) then
            local npc = DTNPCClient.FindZombieByUUID and DTNPCClient.FindZombieByUUID(uuid) or nil
            local dist, dz = Helpers.getDistance(player, npc)
            if npc and dist <= Helpers.AUTO_OPEN_DISTANCE and dz <= 0.5 then
                BanditClient.OpenDemand(npc, player, npcData)
                return
            end
        end
    end
end

local function onServerCommand(module, command, args)
    if module ~= "DTNPC" then return end
    args = type(args) == "table" and args or {}

    if command == "BanditDebugNotice" then
        local player = getSpecificPlayer and getSpecificPlayer(0) or nil
        if player and player.Say then
            player:Say(tostring(args.message or "Bandit debug event."))
        end
        return
    end

    if command == "BanditRaidForecast" then
        BanditClient.ShowRaidForecast(args)
        return
    end

    if not isBanditClientActive() then return end

    if command == "BanditDemand" then
        local groupID = tostring(args.groupID or "")
        local pending = BanditClient.PendingGroups[groupID]
        local ui = Helpers.getCurrentBanditUI(groupID) or (pending and pending.ui) or nil
        local player = pending and pending.player or (getSpecificPlayer and getSpecificPlayer(0) or nil)
        if ui and player then
            BanditClient.ShowDemand(ui, player, args)
        end
        return
    end

    if command == "BanditDemandResolved" then
        local groupID = tostring(args.groupID or "")
        local ui = Helpers.getCurrentBanditUI(groupID)
        Helpers.markResolved(groupID)

        if not ui then return end

        ui.banditResolved = true
        ui.keepOpenOnInvalidInteraction = args.result ~= "hostile"
        if args.result == "hostile" then
            ui:speak(Helpers.pickDialogueLine("Hostile"))
            Helpers.closeBanditUI(ui)
            return
        end

        if args.result == "empty" then
            ui:speak(Helpers.pickDialogueLine("Empty"))
        else
            ui:speak(Helpers.pickDialogueLine("Accept"))
        end

        ui:updateOptions({
            {
                text = "Leave",
                message = "I'm leaving.",
                onSelect = function(nextUI)
                    Helpers.closeBanditUI(nextUI)
                end
            }
        })
    end
end

if not BanditClient.EventsRegistered then
    Events.OnTick.Add(onTick)
    Events.OnServerCommand.Add(onServerCommand)
    BanditClient.EventsRegistered = true
end

DynamicTrading.Log("DTV2", "Init", "Bandits", "Bandit ambush client subsystem loaded")
