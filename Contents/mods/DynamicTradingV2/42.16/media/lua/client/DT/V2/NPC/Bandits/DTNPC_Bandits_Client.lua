-- ==============================================================================
-- DTNPC_Bandits_Client.lua
-- Auto-open robbery demands for synced bandit ambush NPCs.
-- ==============================================================================

if isServer() and not isClient() then return end

require "DT/Common/UI/ConversationUI/ConversationUI"
pcall(require, "DT/V2/NPC/DTNPC_InteractionPose")

DTNPCBanditClient = DTNPCBanditClient or {}

local BanditClient = DTNPCBanditClient

BanditClient.OpenedGroups = BanditClient.OpenedGroups or {}
BanditClient.ResolvedGroups = BanditClient.ResolvedGroups or {}
BanditClient.PendingGroups = BanditClient.PendingGroups or {}
BanditClient.TickCounter = BanditClient.TickCounter or 0

local AUTO_OPEN_DISTANCE = 4.0

local function normalize(value)
    value = value and tostring(value) or ""
    return value ~= "" and value or nil
end

local function getUsername(player)
    return normalize(player and player.getUsername and player:getUsername() or nil)
end

local function getOnlineID(player)
    return player and player.getOnlineID and player:getOnlineID() or nil
end

local function sendBanditCommand(player, command, args)
    if not player then return end
    sendClientCommand(player, "DTNPC", command, args or {})
end

local function isTargetingLocalPlayer(npcData, player)
    if not npcData or not player then return false end

    local playerID = getOnlineID(player)
    local username = getUsername(player)

    if playerID ~= nil then
        if npcData.banditTargetOnlineID ~= nil and tonumber(npcData.banditTargetOnlineID) == tonumber(playerID) then
            return true
        end
        if npcData.masterID ~= nil and tonumber(npcData.masterID) == tonumber(playerID) then
            return true
        end
    end

    if username then
        if normalize(npcData.banditTargetUsername) == username then return true end
        if normalize(npcData.master) == username then return true end
    end

    return false
end

local function getDistance(player, npc)
    if not player or not npc then return 999999, 999999 end
    local dx = (tonumber(player:getX()) or 0) - (tonumber(npc:getX()) or 0)
    local dy = (tonumber(player:getY()) or 0) - (tonumber(npc:getY()) or 0)
    local dz = math.abs((tonumber(player:getZ()) or 0) - (tonumber(npc:getZ()) or 0))
    return math.sqrt((dx * dx) + (dy * dy)), dz
end

local function buildBanditProxy(npcData)
    local uuid = npcData and npcData.uuid or nil
    return {
        id = uuid,
        uuid = uuid,
        traderID = uuid,
        name = npcData and npcData.name or "Bandit",
        archetype = "Bandit",
        role = "Bandit",
        factionID = npcData and npcData.factionID or "Bandits",
        isBanditDemand = true,
    }
end

local function applyInteractionPose(npc, player)
    if DTNPC_InteractionPose and DTNPC_InteractionPose.Activate then
        DTNPC_InteractionPose.Activate(
            npc,
            DTNPCLogic and DTNPCLogic.Stationary and DTNPCLogic.Stationary.INTERACTION_IDLE_STATE or "3",
            player
        )
    end
end

local function clearInteractionPose(npc)
    if DTNPC_InteractionPose and DTNPC_InteractionPose.Deactivate then
        DTNPC_InteractionPose.Deactivate(npc)
    end
end

local function setWaitingOptions(ui, text)
    if not ui or not ui.updateOptions then return end
    ui:updateOptions({
        {
            text = text or "Wait",
            message = "...",
            onSelect = function() end
        }
    })
end

local function markResolved(groupID)
    if not groupID then return end
    groupID = tostring(groupID)
    BanditClient.ResolvedGroups[groupID] = true
    BanditClient.PendingGroups[groupID] = nil
end

local function getCurrentBanditUI(groupID)
    local ui = DT_ConversationUI and DT_ConversationUI.instance or nil
    if ui and ui.isBanditDemand == true and tostring(ui.banditGroupID or "") == tostring(groupID or "") then
        return ui
    end
    return nil
end

local function closeBanditUI(ui)
    if not ui then return end
    ui.banditResolved = true
    ui.closeReason = ui.closeReason or "bandit_demand_resolved"
    ui:close()
end

function BanditClient.ShowDemand(ui, player, demand)
    if not ui or not demand then return end

    local groupID = tostring(demand.groupID or ui.banditGroupID or "")
    ui.banditGroupID = groupID
    ui.banditLeaderUUID = demand.leaderUUID or ui.banditLeaderUUID
    ui.banditDemandKind = demand.kind

    if demand.kind == "money" then
        local amountText = "$" .. tostring(tonumber(demand.amount) or 0)
        ui:speak("Let's keep this simple. Hand over " .. amountText .. ".")
        ui:updateOptions({
            {
                text = "Hand over " .. amountText,
                message = "Fine. Take it.",
                onSelect = function(nextUI)
                    nextUI.banditPaymentSent = true
                    nextUI:speak("Smart choice.")
                    setWaitingOptions(nextUI, "Handing it over...")
                    sendBanditCommand(player, "BanditDemandPay", { groupID = groupID })
                end
            },
            {
                text = "Refuse",
                message = "No.",
                style = { bgColor = { 0.35, 0.12, 0.10, 1.0 }, borderColor = { 0.75, 0.25, 0.18, 1.0 } },
                onSelect = function(nextUI)
                    nextUI.banditRefuseSent = true
                    nextUI:speak("Wrong answer.")
                    setWaitingOptions(nextUI, "They are turning hostile...")
                    sendBanditCommand(player, "BanditDemandRefuse", { groupID = groupID, reason = "refused" })
                end
            }
        })
        return
    end

    if demand.kind == "item" then
        local itemName = normalize(demand.displayName) or "that item"
        ui:speak("That " .. itemName .. ". Hand it over.")
        ui:updateOptions({
            {
                text = "Hand over " .. itemName,
                message = "Take it and leave.",
                onSelect = function(nextUI)
                    nextUI.banditPaymentSent = true
                    nextUI:speak("That will do.")
                    setWaitingOptions(nextUI, "Handing it over...")
                    sendBanditCommand(player, "BanditDemandPay", { groupID = groupID })
                end
            },
            {
                text = "Refuse",
                message = "No.",
                style = { bgColor = { 0.35, 0.12, 0.10, 1.0 }, borderColor = { 0.75, 0.25, 0.18, 1.0 } },
                onSelect = function(nextUI)
                    nextUI.banditRefuseSent = true
                    nextUI:speak("Then we do this the hard way.")
                    setWaitingOptions(nextUI, "They are turning hostile...")
                    sendBanditCommand(player, "BanditDemandRefuse", { groupID = groupID, reason = "refused" })
                end
            }
        })
        return
    end

    ui.banditPaymentSent = true
    ui.banditResolved = true
    markResolved(groupID)
    ui:speak("You've got nothing worth the trouble. Get out of here.")
    ui:updateOptions({
        {
            text = "Leave",
            message = "I'm leaving.",
            onSelect = function(nextUI)
                closeBanditUI(nextUI)
            end
        }
    })
    sendBanditCommand(player, "BanditDemandPay", { groupID = groupID })
end

function BanditClient.RequestDemandForUI(ui, npc, player, npcData)
    if not ui or not player or not npcData then return false end
    local groupID = normalize(npcData.banditGroupID)
    local uuid = normalize(npcData.uuid)
    if not groupID or not uuid then return false end

    ui.isBanditDemand = true
    ui.banditGroupID = groupID
    ui.banditLeaderUUID = uuid
    ui.banditResolved = false
    ui.banditPaymentSent = false
    ui.banditRefuseSent = false

    BanditClient.OpenedGroups[groupID] = true
    BanditClient.PendingGroups[groupID] = {
        ui = ui,
        player = player,
        npc = npc,
        npcData = npcData,
    }

    applyInteractionPose(npc, player)
    ui.onCloseCallback = function(closedUI)
        clearInteractionPose(npc)
        BanditClient.PendingGroups[groupID] = nil
        if closedUI.banditResolved ~= true
            and closedUI.banditPaymentSent ~= true
            and closedUI.banditRefuseSent ~= true then
            closedUI.banditRefuseSent = true
            sendBanditCommand(player, "BanditDemandRefuse", {
                groupID = groupID,
                uuid = uuid,
                reason = closedUI.closeReason or "closed",
            })
        end
    end

    ui:speak("Stop right there. You're paying a road fee.")
    setWaitingOptions(ui, "Waiting for demand...")
    sendBanditCommand(player, "BanditDemandStarted", {
        groupID = groupID,
        uuid = uuid,
    })

    return true
end

function BanditClient.OpenDemand(npc, player, npcData)
    if not npc or not player or not npcData then return false end
    local groupID = normalize(npcData.banditGroupID)
    if not groupID then return false end
    if BanditClient.ResolvedGroups[groupID] then return false end

    local current = getCurrentBanditUI(groupID)
    if current then return true end

    local ui = DT_ConversationUI.Open(buildBanditProxy(npcData), nil, nil, false, npc)
    if not ui then return false end
    return BanditClient.RequestDemandForUI(ui, npc, player, npcData)
end

local function onTick()
    BanditClient.TickCounter = (BanditClient.TickCounter or 0) + 1
    if BanditClient.TickCounter % 15 ~= 0 then return end

    local player = getSpecificPlayer and getSpecificPlayer(0) or nil
    if not player or player:isDead() then return end
    if not DTNPCClient or not DTNPCClient.NPCCache then return end

    for uuid, cacheEntry in pairs(DTNPCClient.NPCCache) do
        local npcData = cacheEntry and (cacheEntry.npcData or cacheEntry) or nil
        local groupID = normalize(npcData and npcData.banditGroupID)
        if npcData
            and npcData.isBandit == true
            and groupID
            and npcData.banditDemandResolved ~= true
            and npcData.isHostile ~= true
            and not BanditClient.OpenedGroups[groupID]
            and not BanditClient.ResolvedGroups[groupID]
            and isTargetingLocalPlayer(npcData, player) then
            local npc = DTNPCClient.FindZombieByUUID and DTNPCClient.FindZombieByUUID(uuid) or nil
            local dist, dz = getDistance(player, npc)
            if npc and dist <= AUTO_OPEN_DISTANCE and dz <= 0.5 then
                BanditClient.OpenDemand(npc, player, npcData)
                return
            end
        end
    end
end

local function onServerCommand(module, command, args)
    if module ~= "DTNPC" then return end
    args = type(args) == "table" and args or {}

    if command == "BanditDemand" then
        local groupID = tostring(args.groupID or "")
        local pending = BanditClient.PendingGroups[groupID]
        local ui = getCurrentBanditUI(groupID) or (pending and pending.ui) or nil
        local player = pending and pending.player or (getSpecificPlayer and getSpecificPlayer(0) or nil)
        if ui and player then
            BanditClient.ShowDemand(ui, player, args)
        end
        return
    end

    if command == "BanditDemandResolved" then
        local groupID = tostring(args.groupID or "")
        local ui = getCurrentBanditUI(groupID)
        markResolved(groupID)

        if not ui then return end

        ui.banditResolved = true
        if args.result == "hostile" then
            ui:speak("That's it. Get them.")
            closeBanditUI(ui)
            return
        end

        if args.result == "empty" then
            ui:speak("You've got nothing worth the trouble. Get out of here.")
        else
            ui:speak("Pleasure doing business. Keep walking.")
        end

        ui:updateOptions({
            {
                text = "Leave",
                message = "I'm leaving.",
                onSelect = function(nextUI)
                    closeBanditUI(nextUI)
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
