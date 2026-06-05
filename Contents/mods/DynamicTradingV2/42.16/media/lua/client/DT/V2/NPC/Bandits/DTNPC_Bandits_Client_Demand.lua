-- ==============================================================================
-- DTNPC_Bandits_Client_Demand.lua
-- Demand UI flow and interaction state for bandit encounters.
-- ==============================================================================

if isServer() and not isClient() then return end

local BanditClient = DTNPCBanditClient
BanditClient.Internal = BanditClient.Internal or {}
BanditClient.Internal.Helpers = BanditClient.Internal.Helpers or {}
local Helpers = BanditClient.Internal.Helpers

local function T(key, params, fallback)
    return DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get
        and DynamicTrading.Text.Get(key, params, fallback)
        or fallback
        or tostring(key or "")
end

local function shouldKeepBanditConversationOpen(ui, invalidReason)
    if not ui or ui.isBanditDemand ~= true then
        return false
    end

    if ui.banditPaymentSent ~= true and ui.banditResolved ~= true then
        return false
    end

    if invalidReason == nil then
        return true
    end

    return invalidReason == "npc_out_of_range"
        or invalidReason == "npc_departure"
        or invalidReason == "invalid_interaction"
end

local function getTributeOptionText(tier)
    local tierName = tostring(tier and tier.tier or "low")
    local amountText = Helpers.formatCurrency(tier and tier.amount or 0)
    if tierName == "high" then
        return "Bribe the whole crew (" .. amountText .. ")"
    end
    if tierName == "medium" then
        return "Bribe the delegate (" .. amountText .. ")"
    end
    return "Pay for a ceasefire (" .. amountText .. ")"
end

local function getTributeSelectMessage(tier)
    local tierName = tostring(tier and tier.tier or "low")
    if tierName == "high" then
        return "Everybody gets a cut. Tell your people to stand down."
    end
    if tierName == "medium" then
        return "This is for you. Tell the others I'm good."
    end
    return "Take it and call this off."
end

function BanditClient.ShowDemand(ui, player, demand)
    if not ui or not demand then return end

    local groupID = tostring(demand.groupID or ui.banditGroupID or "")
    ui.banditGroupID = groupID
    ui.banditLeaderUUID = demand.leaderUUID or ui.banditLeaderUUID
    ui.banditDemandKind = demand.kind

    if demand.kind == "money" then
        local amountText = "$" .. tostring(tonumber(demand.amount) or 0)
        local footerAction = Helpers.buildActiveDemandFooterAction(ui)
        local options = {
            {
                text = T("DTNPC_UI_HandOver", { target = amountText }, "Hand over {target}"),
                message = T("DTNPC_Dialogue_BanditFineTakeIt", nil, "Fine. Take it."),
                onSelect = function(nextUI)
                    Helpers.disarmIdleWarning(nextUI)
                    nextUI.banditPaymentSent = true
                    nextUI.keepOpenOnInvalidInteraction = true
                    nextUI:speak(Helpers.pickDialogueLine("Accept", nil, nextUI))
                    Helpers.setWaitingOptions(nextUI, T("DTNPC_Dialogue_BanditHandingOver", nil, "Handing it over..."), Helpers.buildCompletedDemandFooterAction(nextUI))
                    Helpers.sendBanditCommand(player, "BanditDemandPay", { groupID = groupID })
                end
            },
            {
                text = T("DTNPC_UI_Refuse", nil, "Refuse"),
                message = T("DTNPC_Dialogue_BanditNo", nil, "No."),
                style = { bgColor = { 0.35, 0.12, 0.10, 1.0 }, borderColor = { 0.75, 0.25, 0.18, 1.0 } },
                onSelect = function(nextUI)
                    Helpers.disarmIdleWarning(nextUI)
                    nextUI.banditRefuseSent = true
                    nextUI:speak(Helpers.pickDialogueLine("Refuse", nil, nextUI))
                    Helpers.setWaitingOptions(nextUI, T("DTNPC_Dialogue_BanditTurningHostile", nil, "They are turning hostile..."))
                    Helpers.sendBanditCommand(player, "BanditDemandRefuse", { groupID = groupID, reason = "refused" })
                end
            }
        }
        ui:speak(Helpers.pickDialogueLine("Money", { ["1"] = amountText }, ui))
        Helpers.applyDemandOptions(ui, options, footerAction)
        Helpers.armIdleWarning(ui)
        return
    end

    if demand.kind == "item" then
        local itemName = Helpers.normalize(demand.displayName) or "that item"
        local footerAction = Helpers.buildActiveDemandFooterAction(ui)
        local options = {
            {
                text = T("DTNPC_UI_HandOver", { target = itemName }, "Hand over {target}"),
                message = T("DTNPC_Dialogue_BanditTakeItLeave", nil, "Take it and leave."),
                onSelect = function(nextUI)
                    Helpers.disarmIdleWarning(nextUI)
                    nextUI.banditPaymentSent = true
                    nextUI.keepOpenOnInvalidInteraction = true
                    nextUI:speak(Helpers.pickDialogueLine("Accept", nil, nextUI))
                    Helpers.setWaitingOptions(nextUI, T("DTNPC_Dialogue_BanditHandingOver", nil, "Handing it over..."), Helpers.buildCompletedDemandFooterAction(nextUI))
                    Helpers.sendBanditCommand(player, "BanditDemandPay", { groupID = groupID })
                end
            },
            {
                text = T("DTNPC_UI_Refuse", nil, "Refuse"),
                message = T("DTNPC_Dialogue_BanditNo", nil, "No."),
                style = { bgColor = { 0.35, 0.12, 0.10, 1.0 }, borderColor = { 0.75, 0.25, 0.18, 1.0 } },
                onSelect = function(nextUI)
                    Helpers.disarmIdleWarning(nextUI)
                    nextUI.banditRefuseSent = true
                    nextUI:speak(Helpers.pickDialogueLine("Refuse", nil, nextUI))
                    Helpers.setWaitingOptions(nextUI, T("DTNPC_Dialogue_BanditTurningHostile", nil, "They are turning hostile..."))
                    Helpers.sendBanditCommand(player, "BanditDemandRefuse", { groupID = groupID, reason = "refused" })
                end
            }
        }
        ui:speak(Helpers.pickDialogueLine("Item", { ["1"] = itemName }, ui))
        Helpers.applyDemandOptions(ui, options, footerAction)
        Helpers.armIdleWarning(ui)
        return
    end

    if demand.kind == "tribute" then
        local footerAction = Helpers.buildActiveDemandFooterAction(ui)
        ui:speak(Helpers.pickDialogueLine("Tribute", {
            ["1"] = Helpers.normalize(demand.factionName) or T("DTNPC_Dialogue_BanditTributeFaction", nil, "our faction"),
        }, ui))

        local options = {}
        for _, tier in ipairs(demand.tiers or {}) do
            options[#options + 1] = {
                text = getTributeOptionText(tier),
                message = getTributeSelectMessage(tier),
                onSelect = function(nextUI)
                    Helpers.disarmIdleWarning(nextUI)
                    nextUI.banditPaymentSent = true
                    nextUI.keepOpenOnInvalidInteraction = true
                    nextUI:speak(Helpers.pickDialogueLine("Accept", nil, nextUI))
                    Helpers.setWaitingOptions(nextUI, T("DTNPC_Dialogue_BanditWorkingBribe", nil, "Working the bribe..."), Helpers.buildCompletedDemandFooterAction(nextUI))
                    Helpers.sendBanditCommand(player, "BanditDemandPay", {
                        groupID = groupID,
                        tier = tier.tier,
                    })
                end
            }
        end

        options[#options + 1] = {
            text = T("DTNPC_UI_Refuse", nil, "Refuse"),
            message = T("DTNPC_Dialogue_BanditNoTribute", nil, "No tribute."),
            style = { bgColor = { 0.35, 0.12, 0.10, 1.0 }, borderColor = { 0.75, 0.25, 0.18, 1.0 } },
            onSelect = function(nextUI)
                Helpers.disarmIdleWarning(nextUI)
                nextUI.banditRefuseSent = true
                nextUI:speak(Helpers.pickDialogueLine("Refuse", nil, nextUI))
                Helpers.setWaitingOptions(nextUI, T("DTNPC_Dialogue_BanditTurningHostile", nil, "They are turning hostile..."))
                Helpers.sendBanditCommand(player, "BanditDemandRefuse", { groupID = groupID, reason = "refused" })
            end
        }
        Helpers.applyDemandOptions(ui, options, footerAction)
        Helpers.armIdleWarning(ui)
        return
    end

    Helpers.disarmIdleWarning(ui)
    ui.banditPaymentSent = true
    ui.banditResolved = true
    ui.keepOpenOnInvalidInteraction = true
    Helpers.markResolved(groupID)
    ui:speak(Helpers.pickDialogueLine("Empty", nil, ui))
    local options = {}
    local footerAction = Helpers.buildCompletedDemandFooterAction(ui)
    Helpers.applyDemandOptions(ui, options, footerAction)
    Helpers.sendBanditCommand(player, "BanditDemandPay", { groupID = groupID })
end

function BanditClient.RequestDemandForUI(ui, npc, player, npcData)
    if not Helpers.isCurrencyExpandedActive() then return false end
    if not ui or not player or not npcData then return false end
    local groupID = Helpers.resolveEncounterGroupID and Helpers.resolveEncounterGroupID(npcData) or Helpers.normalize(npcData.banditGroupID)
    local uuid = Helpers.normalize(npcData.uuid)
    local pendingKey = Helpers.buildPendingEncounterKey and Helpers.buildPendingEncounterKey(npcData, player)
        or groupID
        or (uuid and ("TradeCycle_" .. uuid))
        or nil
    local isTradeCycleDemand = Helpers.isTradeCycleDemandEligible and Helpers.isTradeCycleDemandEligible(npcData, player) or false
    local isBanditRoamDemand = Helpers.isBanditHouseRoamEncounterEligible and Helpers.isBanditHouseRoamEncounterEligible(npcData) or false
    local isHostileDemand = Helpers.isNegotiableHostileEncounter and Helpers.isNegotiableHostileEncounter(npcData, player) or false
    if not uuid then return false end
    if not groupID and not isTradeCycleDemand and not isBanditRoamDemand and not isHostileDemand then return false end

    ui.isBanditDemand = true
    ui.banditGroupID = groupID
    ui.banditLeaderUUID = uuid
    ui.banditDialogueCategory = Helpers.getDialogueCategory(npcData)
    ui.banditResolved = false
    ui.banditPaymentSent = false
    ui.banditRefuseSent = false
    ui.banditIdleWarningAt = nil
    ui.banditIdleWarningSent = false
    ui.keepOpenOnInvalidInteraction = false
    ui.shouldKeepOpenOnInvalidInteraction = shouldKeepBanditConversationOpen
    ui.onConversationUpdate = function(activeUI, currentTime)
        Helpers.maybeShowIdleWarning(activeUI, currentTime)
    end

    if pendingKey then
        BanditClient.OpenedGroups[pendingKey] = true
    end
    if groupID then
        BanditClient.OpenedGroups[groupID] = true
    end
    BanditClient.PendingGroups[pendingKey or uuid] = {
        ui = ui,
        player = player,
        npc = npc,
        npcData = npcData,
        pendingKey = pendingKey or uuid,
        leaderUUID = uuid,
    }

    Helpers.applyInteractionPose(npc, player)
    ui.onCloseCallback = function(closedUI)
        Helpers.disarmIdleWarning(closedUI)
        Helpers.clearInteractionPose(npc)
        local activeGroupID = Helpers.normalize(closedUI.banditGroupID)
        local activeKey = activeGroupID or pendingKey or uuid
        BanditClient.PendingGroups[activeKey] = nil
        if activeGroupID then
            BanditClient.OpenedGroups[activeGroupID] = nil
        end
        if pendingKey then
            BanditClient.PendingGroups[pendingKey] = nil
            BanditClient.OpenedGroups[pendingKey] = nil
        end
        if closedUI.banditResolved ~= true
            and closedUI.banditPaymentSent ~= true
            and closedUI.banditRefuseSent ~= true then
            closedUI.banditRefuseSent = true
            Helpers.sendBanditCommand(player, "BanditDemandRefuse", {
                groupID = activeGroupID,
                uuid = uuid,
                reason = closedUI.closeReason or "closed",
            })
        end
    end

    ui:speak(Helpers.pickDialogueLine("Approach", nil, ui))
    Helpers.setWaitingOptions(ui, Helpers.pickDialogueLine("Waiting", nil, ui), Helpers.buildActiveDemandFooterAction(ui))
    Helpers.sendBanditCommand(player, "BanditDemandStarted", {
        groupID = groupID,
        uuid = uuid,
    })

    return true
end

function BanditClient.OpenDemand(npc, player, npcData)
    if not Helpers.isCurrencyExpandedActive() then return false end
    if not npc or not player or not npcData then return false end
    local groupID = Helpers.resolveEncounterGroupID and Helpers.resolveEncounterGroupID(npcData) or Helpers.normalize(npcData.banditGroupID)
    local uuid = Helpers.normalize(npcData.uuid)
    local pendingKey = Helpers.buildPendingEncounterKey and Helpers.buildPendingEncounterKey(npcData, player)
        or groupID
        or (uuid and ("TradeCycle_" .. uuid))
        or nil
    local isTradeCycleDemand = Helpers.isTradeCycleDemandEligible and Helpers.isTradeCycleDemandEligible(npcData, player) or false
    local isBanditRoamDemand = Helpers.isBanditHouseRoamEncounterEligible and Helpers.isBanditHouseRoamEncounterEligible(npcData) or false
    local isHostileDemand = Helpers.isNegotiableHostileEncounter and Helpers.isNegotiableHostileEncounter(npcData, player) or false
    if not groupID and not isTradeCycleDemand and not isBanditRoamDemand and not isHostileDemand then
        return false
    end
    if groupID and BanditClient.ResolvedGroups[groupID] then return false end

    local current = groupID and Helpers.getCurrentBanditUI(groupID) or nil
    if not current and uuid and Helpers.getCurrentBanditUIForLeaderUUID then
        current = Helpers.getCurrentBanditUIForLeaderUUID(uuid)
    end
    if current then return true end
    if pendingKey and BanditClient.OpenedGroups[pendingKey] then return true end

    local ui = DT_ConversationUI.Open(Helpers.buildBanditProxy(npcData), nil, nil, false, npc)
    if not ui then return false end
    return BanditClient.RequestDemandForUI(ui, npc, player, npcData)
end
