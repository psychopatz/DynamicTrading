-- ==============================================================================
-- DTNPC_JobUI_Bandit.lua
-- Keeps bandits out of normal trader menus and redirects interaction to demands.
-- ==============================================================================

pcall(require, "DT/V2/NPC/Bandits/DTNPC_Bandits_Client")

local function isBandit(npcData)
    return npcData and npcData.isBandit == true
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
            return isCurrencyExpandedActive() and isBandit(npcData)
        end,

        getTalkLabel = function(ui, npc, player, npcData)
            return "Talk to Bandit"
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

            ui:speak("That's close enough.")
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
