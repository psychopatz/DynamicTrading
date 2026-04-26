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

function Helpers.isCurrencyExpandedActive()
    local activated = getActivatedMods and getActivatedMods() or nil
    return activated and activated.contains and activated:contains("CurrencyExpanded") or false
end

function Helpers.getForecastText(key, ...)
    return DynamicTrading.FlavorText.GetValue("Bandits", "Forecast", key, ...)
end

function Helpers.getDialogueLine(kind, ...)
    return DynamicTrading.FlavorText.GetRandom("Bandits", kind) or ""
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

function Helpers.pickDialogueLine(kind, replacements)
    local line = Helpers.getDialogueLine(kind)
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

function Helpers.sendBanditCommand(player, command, args)
    if not player then return end
    sendClientCommand(player, "DTNPC", command, args or {})
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
    end

    return false
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

function Helpers.setWaitingOptions(ui, text)
    if not ui or not ui.updateOptions then return end
    ui:updateOptions({
        {
            text = text or "Wait",
            message = "...",
            onSelect = function() end
        }
    })
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

function Helpers.closeBanditUI(ui)
    if not ui then return end
    ui.banditResolved = true
    ui.closeReason = ui.closeReason or "bandit_demand_resolved"
    ui:close()
end
