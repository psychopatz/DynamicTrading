-- ==============================================================================
-- DTNPC_JobUI_Bandit.lua
-- Keeps bandits out of normal trader menus and redirects interaction to demands.
-- ==============================================================================

local function isBanditDemandEncounter(npcData)
    return npcData
        and npcData.banditGroupID ~= nil
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
            return isCurrencyExpandedActive() and isBanditDemandEncounter(npcData)
        end,

        getTalkLabel = function(ui, npc, player, npcData)
            return "Answer Demand"
        end,

        getTraderProxyPatch = function(ui, npc, player, npcData)
            return {
                archetype = "Bandit",
                role = "Bandit",
                factionID = npcData and npcData.factionID or "Bandits",
                isBanditDemand = true,
            }
        end,

        generateOptions = function(ui, npc, player, npcData)
            if DTNPCBanditClient and DTNPCBanditClient.RequestDemandForUI then
                return DTNPCBanditClient.RequestDemandForUI(ui, npc, player, npcData) == true
            end

            local helpers = DTNPCBanditClient and DTNPCBanditClient.Internal and DTNPCBanditClient.Internal.Helpers or nil
            ui:speak(helpers and helpers.pickDialogueLine and helpers.pickDialogueLine("Approach") or "That's close enough.")
            ui:updateOptions({
                {
                    text = "Leave",
                    message = "I'm leaving.",
                    onSelect = function(nextUI)
                        nextUI:close()
                    end
                }
            })
            return true
        end,

        addContextMenuOptions = function()
            return false
        end,
    })
end
