-- ==============================================================================
-- DTNPC_Bandits_Client_Events.lua
-- Client-side event registration and command routing for bandits.
-- ==============================================================================

if isServer() and not isClient() then return end

require "DT/Common/Reputation/DT_Reputation"

local BanditClient = DTNPCBanditClient
BanditClient.Internal = BanditClient.Internal or {}
BanditClient.Internal.Helpers = BanditClient.Internal.Helpers or {}
local Helpers = BanditClient.Internal.Helpers

local function isBanditClientActive()
    return type(Helpers.isCurrencyExpandedActive) == "function"
        and Helpers.isCurrencyExpandedActive() == true
end

local function resolveFactionDataForRefresh(factionID)
    if not factionID then
        return nil
    end

    local sources = {}
    sources[#sources + 1] = DT_FactionInfoWindow and DT_FactionInfoWindow.cachedFactionData or false
    sources[#sources + 1] = DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions or false
    sources[#sources + 1] = DT_V2_RadarManager and DT_V2_RadarManager.ClientFactions or false
    sources[#sources + 1] = ModData.get("DynamicTrading_Factions") or false

    for _, source in ipairs(sources) do
        if type(source) == "table" and source[factionID] then
            return source[factionID]
        end
    end

    return nil
end

local function refreshOpenFactionUI(factionID)
    if not factionID or factionID == "" then
        return
    end

    if DT_ConversationUI and DT_ConversationUI.instance then
        local ui = DT_ConversationUI.instance
        local target = ui.target or nil
        if target and tostring(target.factionID or "") == tostring(factionID) and ui.refreshFactionInfo then
            ui:refreshFactionInfo()
        end
    end

    if DT_FactionInfoWindow
        and DT_FactionInfoWindow.instance
        and DT_FactionInfoWindow.selectedFaction
        and tostring(DT_FactionInfoWindow.selectedFaction.id or "") == tostring(factionID) then
        local factionData = resolveFactionDataForRefresh(factionID)
        if factionData and DT_FactionInfoWindow.instance.applyFactionSelection then
            DT_FactionInfoWindow.selectedFaction = factionData
            DT_FactionInfoWindow.instance.selectedFaction = factionData
            DT_FactionInfoWindow.instance:applyFactionSelection(factionData, false)
        end
    end
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
            and groupID
            and npcData.tradeCycleDemandEligible ~= true
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

    if command == "BanditRepSync" then
        if DT_Reputation and DT_Reputation.ApplyRosterPersonalRepSync then
            local changed = DT_Reputation.ApplyRosterPersonalRepSync(
                args.memberUUIDs,
                args.factionID,
                args.mode,
                args.value,
                args.source or "bandit_sync"
            )
            if changed > 0 then
                refreshOpenFactionUI(args.factionID)
            end
        end
        return
    end

    if not isBanditClientActive() then return end

    if command == "BanditDemand" then
        local groupID = tostring(args.groupID or "")
        local leaderUUID = Helpers.normalize(args.leaderUUID)
        local pending = BanditClient.PendingGroups[groupID]
        if not pending and leaderUUID then
            pending = BanditClient.PendingGroups["TradeCycle_" .. leaderUUID]
                or BanditClient.PendingGroups["BanditRoam_" .. leaderUUID]
                or BanditClient.PendingGroups["Hostile_" .. leaderUUID]
        end
        local ui = Helpers.getCurrentBanditUI(groupID)
            or (leaderUUID and Helpers.getCurrentBanditUIForLeaderUUID and Helpers.getCurrentBanditUIForLeaderUUID(leaderUUID))
            or (pending and pending.ui)
            or nil
        local player = pending and pending.player or (getSpecificPlayer and getSpecificPlayer(0) or nil)
        if pending and groupID ~= "" then
            pending.ui = pending.ui or ui
            pending.pendingKey = pending.pendingKey or (leaderUUID and ("TradeCycle_" .. leaderUUID)) or groupID
            BanditClient.PendingGroups[groupID] = pending
            BanditClient.OpenedGroups[groupID] = true
            if pending.pendingKey and pending.pendingKey ~= groupID then
                BanditClient.PendingGroups[pending.pendingKey] = nil
                BanditClient.OpenedGroups[pending.pendingKey] = nil
            end
        end
        if ui and player then
            BanditClient.ShowDemand(ui, player, args)
        end
        return
    end

    if command == "BanditDemandResolved" then
        local groupID = tostring(args.groupID or "")
        local ui = Helpers.getCurrentBanditUI(groupID)
        if args.result == "hostile" and args.reopenAllowed == true then
            BanditClient.PendingGroups[groupID] = nil
            BanditClient.OpenedGroups[groupID] = nil
            BanditClient.ResolvedGroups[groupID] = nil
        else
            Helpers.markResolved(groupID)
        end

        if not ui then return end

        Helpers.disarmIdleWarning(ui)
        ui.banditResolved = true
        ui.keepOpenOnInvalidInteraction = args.result ~= "hostile"
        if args.result == "hostile" then
            ui:speak(Helpers.pickDialogueLine("Hostile", nil, ui))
            Helpers.closeBanditUI(ui)
            return
        end

        if args.result == "empty" then
            ui:speak(Helpers.pickDialogueLine("Empty", nil, ui))
        elseif args.kind == "tribute" then
            if tostring(args.selectedTier or "") == "high" then
                ui:speak(Helpers.pickDialogueLine("GiftAcceptedHigh", {
                    ["1"] = tostring(math.floor(tonumber(args.repPerMember) or 0)),
                    ["2"] = tostring(math.floor(tonumber(args.repAwardedCount) or 0)),
                }, ui))
            elseif tostring(args.selectedTier or "") == "medium" then
                ui:speak(Helpers.pickDialogueLine("GiftAcceptedMedium", {
                    ["1"] = tostring(math.floor(tonumber(args.repPerMember) or 0)),
                }, ui))
            else
                ui:speak(Helpers.pickDialogueLine("GiftAccepted", nil, ui))
            end
        else
            ui:speak(Helpers.pickDialogueLine("Accept", nil, ui))
        end

        Helpers.applyDemandOptions(ui, {}, Helpers.buildCompletedDemandFooterAction(ui))
    end
end

if not BanditClient.EventsRegistered then
    Events.OnTick.Add(onTick)
    Events.OnServerCommand.Add(onServerCommand)
    BanditClient.EventsRegistered = true
end

DynamicTrading.Log("DTV2", "Init", "Bandits", "Bandit ambush client subsystem loaded")
