-- ==============================================================================
-- DTNPC_Bandits_Client_State.lua
-- Client helpers and shared state for bandit encounter UI.
-- ==============================================================================

if isServer() and not isClient() then return end

require "DT/Common/UI/ConversationUI/ConversationUI"
require "DT/Common/FlavorText/DT_FlavorText"
require "DT/Common/FlavorText/DT_FlavorText_Bandits"
pcall(require, "DT/V2/NPC/DTNPC_InteractionPose")
require "ISUI/ISCollapsableWindow"
require "ISUI/ISButton"

DTNPCBanditClient = DTNPCBanditClient or {}
DTNPCBanditClient.Internal = DTNPCBanditClient.Internal or {}

local BanditClient = DTNPCBanditClient
local Internal = BanditClient.Internal

BanditClient.OpenedGroups = BanditClient.OpenedGroups or {}
BanditClient.ResolvedGroups = BanditClient.ResolvedGroups or {}
BanditClient.PendingGroups = BanditClient.PendingGroups or {}
BanditClient.TickCounter = BanditClient.TickCounter or 0

Internal.Helpers = Internal.Helpers or {}

local Helpers = Internal.Helpers

Helpers.AUTO_OPEN_DISTANCE = Helpers.AUTO_OPEN_DISTANCE or 4.0
Helpers.IDLE_WARNING_DELAY_MS = Helpers.IDLE_WARNING_DELAY_MS or 30000
Helpers.DEFAULT_HOSTILE_REP_THRESHOLD = Helpers.DEFAULT_HOSTILE_REP_THRESHOLD or -40

function Helpers.nowMillis()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end
    return math.floor((os.time() or 0) * 1000)
end

function Helpers.isCurrencyExpandedActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("CurrencyExpanded") or false
end

function Helpers.getForecastText(key, ...)
    return DynamicTrading.FlavorText.GetValue("Bandits", "Forecast", key, ...)
end

function Helpers.getDialogueCategory(source)
    local npcData = source
    if source and source.npcData then
        npcData = source.npcData
    elseif source and source.banditDialogueCategory then
        return tostring(source.banditDialogueCategory)
    end

    if npcData and (npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits") then
        return "Bandits"
    end

    if npcData and npcData.isHostile == true then
        return "HostileRaiders"
    end

    if npcData and tostring(npcData.tradeCycleMode or "") == "hostile_bribe" then
        return "HostileRaiders"
    end

    if npcData and npcData.raidHostileFaction == true then
        return "HostileRaiders"
    end

    return "Bandits"
end

function Helpers.getDialogueLine(kind, source)
    local category = Helpers.getDialogueCategory(source)
    return DynamicTrading.FlavorText.GetRandom(category, kind) or ""
end

function Helpers.formatLine(line, replacements)
    local text = tostring(line or "")
    for token, value in pairs(replacements or {}) do
        text = string.gsub(text, "%%" .. tostring(token), function()
            return tostring(value or "")
        end)
    end
    return text
end

function Helpers.pickDialogueLine(kind, replacements, source)
    local line = Helpers.getDialogueLine(kind, source)
    return Helpers.formatLine(line, replacements)
end

function Helpers.normalize(value)
    value = value and tostring(value) or ""
    return value ~= "" and value or nil
end

function Helpers.getUsername(player)
    return Helpers.normalize(player and player.getUsername and player:getUsername() or nil)
end

function Helpers.getOnlineID(player)
    return player and player.getOnlineID and player:getOnlineID() or nil
end

function Helpers.getLocalPlayer()
    return getSpecificPlayer and getSpecificPlayer(0) or nil
end

local function resolveFactionSnapshot(factionID)
    if not factionID then
        return nil
    end

    local snapshots = {
        DynamicTrading_Client and DynamicTrading_Client.Cache and DynamicTrading_Client.Cache.Factions or nil,
        DT_V2_RadarManager and DT_V2_RadarManager.ClientFactions or nil,
        DT_FactionInfoWindow and DT_FactionInfoWindow.cachedFactionData or nil,
        ModData.get("DynamicTrading_Factions") or nil,
    }

    for _, source in ipairs(snapshots) do
        if type(source) == "table" and type(source[factionID]) == "table" then
            return source[factionID]
        end
    end

    return nil
end

function Helpers.isFactionHostileToLocalPlayer(factionID)
    local faction = resolveFactionSnapshot(factionID)
    if type(faction) ~= "table" then
        return false
    end

    if faction.hostileToPlayers == true or faction.alwaysHostile == true then
        return true
    end

    local player = Helpers.getLocalPlayer()
    local username = Helpers.getUsername(player)
    if not username then
        return false
    end

    local disposition = type(faction.playerDisposition) == "table" and faction.playerDisposition or nil
    local rep = 0
    if disposition and disposition[username] ~= nil then
        rep = tonumber(disposition[username]) or 0
    elseif faction.playerDispositionDefault ~= nil then
        rep = tonumber(faction.playerDispositionDefault) or 0
    end

    local threshold = DTNPCProtect
        and DTNPCProtect.CONFIG
        and tonumber(DTNPCProtect.CONFIG.HostilePlayerRepThreshold)
        or Helpers.DEFAULT_HOSTILE_REP_THRESHOLD
    return rep <= threshold
end

function Helpers.isTradeCycleDemandEligible(npcData, player)
    if not npcData then
        return false
    end

    local mode = tostring(npcData.tradeCycleMode or "")
    if mode == "" and npcData.tradeCycleDemandEligible ~= true then
        return false
    end

    if mode == "robbery" or mode == "hostile_bribe" then
        return true
    end

    if tostring(npcData.factionID or "") == "Bandits" then
        return npcData.banditRoamActive == true or npcData.banditGroupID ~= nil
    end

    player = player or Helpers.getLocalPlayer()
    if not player then
        return false
    end

    return Helpers.isFactionHostileToLocalPlayer(npcData.factionID)
end

function Helpers.isBanditHouseRoamEncounterEligible(npcData)
    return npcData
        and npcData.banditRoamActive == true
        and tostring(npcData.banditRoamEncounterMode or "") == "bribe_only"
        and npcData.banditLeaving ~= true
        or false
end

function Helpers.sendBanditCommand(player, command, args)
    if not player then return end
    sendClientCommand(player, "DTNPC", command, args or {})
end

function Helpers.formatCurrency(amount)
    return "$" .. tostring(math.max(0, math.floor(tonumber(amount) or 0)))
end

function Helpers.isTargetingLocalPlayer(npcData, player)
    if not npcData or not player then return false end

    local playerID = Helpers.getOnlineID(player)
    local username = Helpers.getUsername(player)

    if playerID ~= nil then
        if npcData.banditTargetOnlineID ~= nil and tonumber(npcData.banditTargetOnlineID) == tonumber(playerID) then
            return true
        end
        if npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
            return true
        end
    end

    if username then
        if Helpers.normalize(npcData.banditTargetUsername) == username then return true end
        if Helpers.normalize(npcData.master) == username then return true end
        if Helpers.normalize(npcData.lastPlayerAttackerUsername) == username then return true end
    end

    if playerID ~= nil and npcData.lastPlayerAttackerOnlineID ~= nil and tonumber(npcData.lastPlayerAttackerOnlineID) == tonumber(playerID) then
        return true
    end

    return false
end

function Helpers.isNegotiableHostileEncounter(npcData, player)
    if not npcData or npcData.isHostile ~= true then
        return false
    end

    if npcData.banditLeaving == true then
        return false
    end

    return Helpers.isTargetingLocalPlayer(npcData, player)
end

function Helpers.resolveEncounterGroupID(npcData)
    if not npcData then
        return nil
    end

    return Helpers.normalize(npcData.banditGroupID)
        or Helpers.normalize(npcData.hostileNegotiationGroupID)
end

function Helpers.buildPendingEncounterKey(npcData, player)
    if not npcData then
        return nil
    end

    local groupID = Helpers.resolveEncounterGroupID(npcData)
    if groupID then
        return groupID
    end

    local uuid = Helpers.normalize(npcData.uuid)
    if not uuid then
        return nil
    end

    if Helpers.isTradeCycleDemandEligible and Helpers.isTradeCycleDemandEligible(npcData, player) then
        if Helpers.isBanditHouseRoamEncounterEligible and Helpers.isBanditHouseRoamEncounterEligible(npcData) then
            return "BanditRoam_" .. uuid
        end
        return "TradeCycle_" .. uuid
    end

    if Helpers.isNegotiableHostileEncounter(npcData, player) then
        return "Hostile_" .. uuid
    end

    return nil
end

function Helpers.getDistance(player, npc)
    if not player or not npc then return 999999, 999999 end
    local dx = (tonumber(player:getX()) or 0) - (tonumber(npc:getX()) or 0)
    local dy = (tonumber(player:getY()) or 0) - (tonumber(npc:getY()) or 0)
    local dz = math.abs((tonumber(player:getZ()) or 0) - (tonumber(npc:getZ()) or 0))
    return math.sqrt((dx * dx) + (dy * dy)), dz
end

function Helpers.buildBanditProxy(npcData)
    local uuid = npcData and npcData.uuid or nil
    local isTrueBandit = npcData and (npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits") or false
    local isHostileFactionRaider = npcData
        and ((npcData.raidHostileFaction == true) or tostring(npcData.tradeCycleMode or "") == "hostile_bribe")
        and not isTrueBandit
        or false
    return {
        id = uuid,
        uuid = uuid,
        traderID = uuid,
        name = npcData and npcData.name or "Bandit",
        archetype = isTrueBandit and "Bandit" or (npcData and (npcData.archetypeID or npcData.occupation) or "General"),
        role = isTrueBandit and "Bandit" or "Raider",
        factionID = npcData and npcData.factionID or "Bandits",
        isBanditDemand = true,
        isTrueBandit = isTrueBandit,
        isHostileFactionRaider = isHostileFactionRaider,
        banditDialogueCategory = Helpers.getDialogueCategory(npcData),
    }
end

function Helpers.applyInteractionPose(npc, player)
    if DTNPC_InteractionPose and DTNPC_InteractionPose.Activate then
        DTNPC_InteractionPose.Activate(
            npc,
            DTNPCLogic and DTNPCLogic.Stationary and DTNPCLogic.Stationary.INTERACTION_IDLE_STATE or "3",
            player
        )
    end
end

function Helpers.clearInteractionPose(npc)
    if DTNPC_InteractionPose and DTNPC_InteractionPose.Deactivate then
        DTNPC_InteractionPose.Deactivate(npc)
    end
end

function Helpers.setWaitingOptions(ui, text, footerAction)
    if not ui or not ui.updateOptions then return end
    local resolvedFooterAction = type(footerAction) == "table" and footerAction or Helpers.buildActiveDemandFooterAction(ui)
    local options = {
        {
            text = text or "Wait",
            message = "...",
            onSelect = function() end
        }
    }
    Helpers.applyDemandOptions(ui, options, resolvedFooterAction)
end

function Helpers.buildActiveDemandFooterAction(source)
    local category = Helpers.getDialogueCategory(source)
    local isHostileRaider = category == "HostileRaiders"

    local spec = {
        title = "Leave",
        silent = true,
        suppressDefaultMessage = true,
        suppressExitEmote = not isHostileRaider,
        exitEmote = isHostileRaider and "insult" or nil,
    }

    if DT_ConversationUI and DT_ConversationUI.BuildLeaveFooterAction then
        return DT_ConversationUI.BuildLeaveFooterAction(spec)
    end

    spec.kind = "leave"
    return spec
end

function Helpers.buildCompletedDemandFooterAction(source)
    local category = Helpers.getDialogueCategory(source)
    local isHostileRaider = category == "HostileRaiders"

    local spec = {
        title = "Exit",
        silent = true,
        suppressDefaultMessage = true,
        suppressExitEmote = not isHostileRaider,
        exitEmote = isHostileRaider and "insult" or nil,
    }

    if DT_ConversationUI and DT_ConversationUI.BuildExitFooterAction then
        return DT_ConversationUI.BuildExitFooterAction(spec)
    end

    spec.kind = "leave"
    return spec
end

function Helpers.buildDemandNavigationBlock(footerAction)
    if DT_ConversationUI and DT_ConversationUI.BuildNavigationBlock then
        return DT_ConversationUI.BuildNavigationBlock(footerAction, {
            resetHistory = true,
        })
    end

    return {
        explicitFooter = true,
        resetHistory = true,
        footerAction = footerAction,
        defaultFooterAction = footerAction,
    }
end

function Helpers.applyDemandOptions(ui, options, footerAction)
    if not ui or not ui.updateOptions then return end
    options = type(options) == "table" and options or {}
    local resolvedFooterAction = type(footerAction) == "table" and footerAction or Helpers.buildActiveDemandFooterAction(ui)
    local navBlock = Helpers.buildDemandNavigationBlock(resolvedFooterAction)

    options._dtFooterAction = resolvedFooterAction
    options._dtNavigationBlock = navBlock

    ui:updateOptions(options, navBlock)
    if ui.setNavigationBlock then
        ui:setNavigationBlock(navBlock)
    elseif ui.setFooterAction then
        ui:setFooterAction(resolvedFooterAction)
    end
end

function Helpers.disarmIdleWarning(ui)
    if not ui then return end
    ui.banditIdleWarningAt = nil
    ui.banditIdleWarningSent = nil
end

function Helpers.armIdleWarning(ui)
    if not ui then return end
    ui.banditIdleWarningAt = Helpers.nowMillis() + Helpers.IDLE_WARNING_DELAY_MS
    ui.banditIdleWarningSent = false
end

function Helpers.maybeShowIdleWarning(ui, currentTime)
    if not ui
        or ui.isBanditDemand ~= true
        or ui.banditResolved == true
        or ui.banditPaymentSent == true
        or ui.banditRefuseSent == true
        or ui.banditIdleWarningSent == true
        or not ui.banditIdleWarningAt then
        return
    end

    currentTime = math.floor(tonumber(currentTime) or Helpers.nowMillis())
    if currentTime < ui.banditIdleWarningAt then
        return
    end

    ui.banditIdleWarningSent = true
    ui:speak(Helpers.pickDialogueLine("Warning", nil, ui))
end

function Helpers.markResolved(groupID)
    if not groupID then return end
    groupID = tostring(groupID)
    BanditClient.ResolvedGroups[groupID] = true
    BanditClient.PendingGroups[groupID] = nil
end

function Helpers.getCurrentBanditUI(groupID)
    local ui = DT_ConversationUI and DT_ConversationUI.instance or nil
    if ui and ui.isBanditDemand == true and tostring(ui.banditGroupID or "") == tostring(groupID or "") then
        return ui
    end
    return nil
end

function Helpers.getCurrentBanditUIForLeaderUUID(uuid)
    uuid = Helpers.normalize(uuid)
    if not uuid then
        return nil
    end

    local ui = DT_ConversationUI and DT_ConversationUI.instance or nil
    if not ui or ui.isBanditDemand ~= true then
        return nil
    end

    if Helpers.normalize(ui.banditLeaderUUID) == uuid then
        return ui
    end

    local target = ui.target or nil
    if Helpers.normalize(target and (target.uuid or target.traderID or target.id)) == uuid then
        return ui
    end

    return nil
end

function Helpers.closeBanditUI(ui)
    if not ui then return end
    ui.banditResolved = true
    ui.closeReason = ui.closeReason or "bandit_demand_resolved"
    ui:close()
end
