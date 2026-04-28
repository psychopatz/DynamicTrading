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

if DTNPCJobUI and DTNPCJobUI.Register then
    DTNPCJobUI.Register({
        id = "BanditDemand",
        priority = 1000,

        matches = function(ui, npc, player, npcData)
            return isCurrencyExpandedActive() and isBanditDemandEncounter(npcData, player)
        end,

        getTalkLabel = function(ui, npc, player, npcData)
            if tostring(npcData and npcData.tradeCycleMode or "") == "hostile_bribe" then
                return "Negotiate"
            end
            return "Answer Demand"
        end,

        getTraderProxyPatch = function(ui, npc, player, npcData)
            local isTrueBandit = npcData
                and (npcData.isBandit == true or tostring(npcData.factionID or "") == "Bandits")
                or false
            local isHostileFactionRaider = npcData
                and ((npcData.raidHostileFaction == true) or tostring(npcData.tradeCycleMode or "") == "hostile_bribe")
                and not isTrueBandit
                or false
            return {
                archetype = isTrueBandit and "Bandit" or (npcData and (npcData.archetypeID or npcData.occupation) or "General"),
                role = isTrueBandit and "Bandit" or "Raider",
                factionID = npcData and npcData.factionID or "Bandits",
                isBanditDemand = true,
                isTrueBandit = isTrueBandit,
                isHostileFactionRaider = isHostileFactionRaider,
                banditDialogueCategory = isTrueBandit and "Bandits" or "HostileRaiders",
            }
        end,

        generateOptions = function(ui, npc, player, npcData)
            if DTNPCBanditClient and DTNPCBanditClient.RequestDemandForUI then
                return DTNPCBanditClient.RequestDemandForUI(ui, npc, player, npcData) == true
            end

            local helpers = getHelpers()
            ui:speak(helpers and helpers.pickDialogueLine and helpers.pickDialogueLine("Approach", nil, npcData) or "That's close enough.")
            ui:updateOptions({}, {
                resetHistory = true,
            })
            return true
        end,

        addContextMenuOptions = function()
            return false
        end,
    })
end
