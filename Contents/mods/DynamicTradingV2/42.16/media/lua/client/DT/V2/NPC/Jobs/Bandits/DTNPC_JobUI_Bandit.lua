-- ==============================================================================
-- DTNPC_JobUI_Bandit.lua
-- Keeps bandits out of normal trader menus and redirects interaction to demands.
-- ==============================================================================

local function getHelpers()
    return DTNPCBanditClient and DTNPCBanditClient.Internal and DTNPCBanditClient.Internal.Helpers or nil
end

local function isBanditDemandEncounter(npcData, player)
    if not npcData then
        return false
    end

    local helpers = getHelpers()
    if helpers and helpers.isNegotiableHostileEncounter and helpers.isNegotiableHostileEncounter(npcData, player) then
        return true
    end

    if helpers and helpers.isTradeCycleDemandEligible and helpers.isTradeCycleDemandEligible(npcData, player) then
        return npcData.banditDemandResolved ~= true and npcData.banditLeaving ~= true
    end

    return npcData.banditGroupID ~= nil
        and npcData.banditDemandResolved ~= true
        and npcData.isHostile ~= true
end

local function isCurrencyExpandedActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("CurrencyExpanded") or false
end

local function buildFallbackExitNavigation()
    local footerAction = DT_ConversationUI
        and DT_ConversationUI.BuildExitFooterAction
        and DT_ConversationUI.BuildExitFooterAction({
            silent = true,
            suppressDefaultMessage = true,
            suppressExitEmote = true,
        })
        or {
            kind = "leave",
            title = DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get
                and DynamicTrading.Text.Get("DTNPC_UI_Exit", nil, "Exit")
                or "Exit",
            silent = true,
            suppressDefaultMessage = true,
            suppressExitEmote = true,
        }
    local navBlock = DT_ConversationUI
        and DT_ConversationUI.BuildNavigationBlock
        and DT_ConversationUI.BuildNavigationBlock(footerAction, {
            resetHistory = true,
            debugLabel = "BanditDemandFallback",
            requireExplicitNavigation = true,
        })
        or {
            explicitFooter = true,
            resetHistory = true,
            footerAction = footerAction,
            defaultFooterAction = footerAction,
        }
    return footerAction, navBlock
end

if DTNPCJobUI and DTNPCJobUI.Register then
    DTNPCJobUI.Register({
        id = "BanditDemand",
        priority = 1000,

        matches = function(ui, npc, player, npcData)
            return isCurrencyExpandedActive() and isBanditDemandEncounter(npcData, player)
        end,

        getTalkLabel = function(ui, npc, player, npcData)
            local helpers = getHelpers()
            local isTrueBandit = npcData
                and (npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits")
                or false
            if helpers and helpers.isBanditHouseRoamEncounterEligible and helpers.isBanditHouseRoamEncounterEligible(npcData) then
                return isTrueBandit
                    and DynamicTrading.Text.Get("DTNPC_UI_Bribe", nil, "Bribe")
                    or DynamicTrading.Text.Get("DTNPC_UI_Negotiate", nil, "Negotiate")
            end
            if helpers and helpers.isNegotiableHostileEncounter and helpers.isNegotiableHostileEncounter(npcData, player) then
                return isTrueBandit
                    and DynamicTrading.Text.Get("DTNPC_UI_Bribe", nil, "Bribe")
                    or DynamicTrading.Text.Get("DTNPC_UI_Negotiate", nil, "Negotiate")
            end
            if tostring(npcData and npcData.tradeCycleMode or "") == "hostile_bribe" then
                return DynamicTrading.Text.Get("DTNPC_UI_Negotiate", nil, "Negotiate")
            end
            return DynamicTrading.Text.Get("DTNPC_UI_AnswerDemand", nil, "Answer Demand")
        end,

        getTraderProxyPatch = function(ui, npc, player, npcData)
            local isTrueBandit = npcData
                and (npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits")
                or false
            local isHostileFactionRaider = npcData
                and ((npcData.raidHostileFaction == true) or tostring(npcData.tradeCycleMode or "") == "hostile_bribe" or npcData.isHostile == true)
                and not isTrueBandit
                or false
            local helpers = getHelpers()
            return {
                archetype = isTrueBandit and "Bandit" or (npcData and (npcData.archetypeID or npcData.occupation) or "General"),
                role = isTrueBandit and "Bandit" or (npcData and npcData.isHostile == true and "Hostile" or "Raider"),
                factionID = npcData and npcData.factionID or "Bandits",
                isBanditDemand = true,
                isTrueBandit = isTrueBandit,
                isHostileFactionRaider = isHostileFactionRaider,
                banditDialogueCategory = helpers and helpers.getDialogueCategory and helpers.getDialogueCategory(npcData)
                    or (isTrueBandit and "Bandits" or "HostileRaiders"),
            }
        end,

        generateOptions = function(ui, npc, player, npcData)
            if DTNPCBanditClient and DTNPCBanditClient.RequestDemandForUI then
                return DTNPCBanditClient.RequestDemandForUI(ui, npc, player, npcData) == true
            end

            local helpers = getHelpers()
            ui:speak(helpers and helpers.pickDialogueLine and helpers.pickDialogueLine("Approach", nil, npcData)
                or DynamicTrading.Text.Get("DTNPC_Dialogue_BanditApproach", nil, "That's close enough."))
            local options = {}
            local footerAction, navBlock = buildFallbackExitNavigation()
            options._dtFooterAction = footerAction
            options._dtNavigationBlock = navBlock
            ui:updateOptions(options, navBlock)
            return true
        end,

        addContextMenuOptions = function()
            return false
        end,
    })
end
