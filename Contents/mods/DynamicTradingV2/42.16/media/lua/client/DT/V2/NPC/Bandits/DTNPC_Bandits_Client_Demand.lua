-- ==============================================================================
-- DTNPC_Bandits_Client_Demand.lua
-- Demand UI flow and interaction state for bandit encounters.
-- ==============================================================================

if isServer() and not isClient() then return end

local BanditClient = DTNPCBanditClient
BanditClient.Internal = BanditClient.Internal or {}
BanditClient.Internal.Helpers = BanditClient.Internal.Helpers or {}
local Helpers = BanditClient.Internal.Helpers

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
        return "Offer a high gift (" .. amountText .. ")"
    end
    if tierName == "medium" then
        return "Offer a medium gift (" .. amountText .. ")"
    end
    return "Offer a low gift (" .. amountText .. ")"
end

local function getTributeSelectMessage(tier)
    local tierName = tostring(tier and tier.tier or "low")
    if tierName == "high" then
        return "This should smooth things over."
    end
    if tierName == "medium" then
        return "Take this and let it end here."
    end
    return "Take this and back off."
end

function BanditClient.ShowDemand(ui, player, demand)
    if not ui or not demand then return end

    local groupID = tostring(demand.groupID or ui.banditGroupID or "")
    ui.banditGroupID = groupID
    ui.banditLeaderUUID = demand.leaderUUID or ui.banditLeaderUUID
    ui.banditDemandKind = demand.kind

    if demand.kind == "money" then
        local amountText = "$" .. tostring(tonumber(demand.amount) or 0)
        ui:speak(Helpers.pickDialogueLine("Money", { ["1"] = amountText }))
        ui:updateOptions({
            {
                text = "Hand over " .. amountText,
                message = "Fine. Take it.",
                onSelect = function(nextUI)
                    nextUI.banditPaymentSent = true
                    nextUI.keepOpenOnInvalidInteraction = true
                    nextUI:speak(Helpers.pickDialogueLine("Accept"))
                    Helpers.setWaitingOptions(nextUI, "Handing it over...")
                    Helpers.sendBanditCommand(player, "BanditDemandPay", { groupID = groupID })
                end
            },
            {
                text = "Refuse",
                message = "No.",
                style = { bgColor = { 0.35, 0.12, 0.10, 1.0 }, borderColor = { 0.75, 0.25, 0.18, 1.0 } },
                onSelect = function(nextUI)
                    nextUI.banditRefuseSent = true
                    nextUI:speak(Helpers.pickDialogueLine("Refuse"))
                    Helpers.setWaitingOptions(nextUI, "They are turning hostile...")
                    Helpers.sendBanditCommand(player, "BanditDemandRefuse", { groupID = groupID, reason = "refused" })
                end
            }
        })
        return
    end

    if demand.kind == "item" then
        local itemName = Helpers.normalize(demand.displayName) or "that item"
        ui:speak(Helpers.pickDialogueLine("Item", { ["1"] = itemName }))
        ui:updateOptions({
            {
                text = "Hand over " .. itemName,
                message = "Take it and leave.",
                onSelect = function(nextUI)
                    nextUI.banditPaymentSent = true
                    nextUI.keepOpenOnInvalidInteraction = true
                    nextUI:speak(Helpers.pickDialogueLine("Accept"))
                    Helpers.setWaitingOptions(nextUI, "Handing it over...")
                    Helpers.sendBanditCommand(player, "BanditDemandPay", { groupID = groupID })
                end
            },
            {
                text = "Refuse",
                message = "No.",
                style = { bgColor = { 0.35, 0.12, 0.10, 1.0 }, borderColor = { 0.75, 0.25, 0.18, 1.0 } },
                onSelect = function(nextUI)
                    nextUI.banditRefuseSent = true
                    nextUI:speak(Helpers.pickDialogueLine("Refuse"))
                    Helpers.setWaitingOptions(nextUI, "They are turning hostile...")
                    Helpers.sendBanditCommand(player, "BanditDemandRefuse", { groupID = groupID, reason = "refused" })
                end
            }
        })
        return
    end

    if demand.kind == "tribute" then
        ui:speak(Helpers.pickDialogueLine("Tribute", {
            ["1"] = Helpers.normalize(demand.factionName) or "our faction",
        }))

        local options = {}
        for _, tier in ipairs(demand.tiers or {}) do
            options[#options + 1] = {
                text = getTributeOptionText(tier),
                message = getTributeSelectMessage(tier),
                onSelect = function(nextUI)
                    nextUI.banditPaymentSent = true
                    nextUI.keepOpenOnInvalidInteraction = true
                    nextUI:speak(Helpers.pickDialogueLine("Accept"))
                    Helpers.setWaitingOptions(nextUI, "Offering the gift...")
                    Helpers.sendBanditCommand(player, "BanditDemandPay", {
                        groupID = groupID,
                        tier = tier.tier,
                    })
                end
            }
        end

        options[#options + 1] = {
            text = "Refuse",
            message = "No tribute.",
            style = { bgColor = { 0.35, 0.12, 0.10, 1.0 }, borderColor = { 0.75, 0.25, 0.18, 1.0 } },
            onSelect = function(nextUI)
                nextUI.banditRefuseSent = true
                nextUI:speak(Helpers.pickDialogueLine("Refuse"))
                Helpers.setWaitingOptions(nextUI, "They are turning hostile...")
                Helpers.sendBanditCommand(player, "BanditDemandRefuse", { groupID = groupID, reason = "refused" })
            end
        }

        ui:updateOptions(options)
        return
    end

    ui.banditPaymentSent = true
    ui.banditResolved = true
    ui.keepOpenOnInvalidInteraction = true
    Helpers.markResolved(groupID)
    ui:speak(Helpers.pickDialogueLine("Empty"))
    ui:updateOptions({
        {
            text = "Leave",
            message = "I'm leaving.",
            onSelect = function(nextUI)
                Helpers.closeBanditUI(nextUI)
            end
        }
    })
    Helpers.sendBanditCommand(player, "BanditDemandPay", { groupID = groupID })
end

function BanditClient.RequestDemandForUI(ui, npc, player, npcData)
    if not Helpers.isCurrencyExpandedActive() then return false end
    if not ui or not player or not npcData then return false end
    local groupID = Helpers.normalize(npcData.banditGroupID)
    local uuid = Helpers.normalize(npcData.uuid)
    if not groupID or not uuid then return false end

    ui.isBanditDemand = true
    ui.banditGroupID = groupID
    ui.banditLeaderUUID = uuid
    ui.banditResolved = false
    ui.banditPaymentSent = false
    ui.banditRefuseSent = false
    ui.keepOpenOnInvalidInteraction = false
    ui.shouldKeepOpenOnInvalidInteraction = shouldKeepBanditConversationOpen

    BanditClient.OpenedGroups[groupID] = true
    BanditClient.PendingGroups[groupID] = {
        ui = ui,
        player = player,
        npc = npc,
        npcData = npcData,
    }

    Helpers.applyInteractionPose(npc, player)
    ui.onCloseCallback = function(closedUI)
        Helpers.clearInteractionPose(npc)
        BanditClient.PendingGroups[groupID] = nil
        if closedUI.banditResolved ~= true
            and closedUI.banditPaymentSent ~= true
            and closedUI.banditRefuseSent ~= true then
            closedUI.banditRefuseSent = true
            Helpers.sendBanditCommand(player, "BanditDemandRefuse", {
                groupID = groupID,
                uuid = uuid,
                reason = closedUI.closeReason or "closed",
            })
        end
    end

    ui:speak(Helpers.pickDialogueLine("Approach"))
    Helpers.setWaitingOptions(ui, Helpers.pickDialogueLine("Waiting"))
    Helpers.sendBanditCommand(player, "BanditDemandStarted", {
        groupID = groupID,
        uuid = uuid,
    })

    return true
end

function BanditClient.OpenDemand(npc, player, npcData)
    if not Helpers.isCurrencyExpandedActive() then return false end
    if not npc or not player or not npcData then return false end
    local groupID = Helpers.normalize(npcData.banditGroupID)
    if not groupID then return false end
    if BanditClient.ResolvedGroups[groupID] then return false end

    local current = Helpers.getCurrentBanditUI(groupID)
    if current then return true end

    local ui = DT_ConversationUI.Open(Helpers.buildBanditProxy(npcData), nil, nil, false, npc)
    if not ui then return false end
    return BanditClient.RequestDemandForUI(ui, npc, player, npcData)
end
