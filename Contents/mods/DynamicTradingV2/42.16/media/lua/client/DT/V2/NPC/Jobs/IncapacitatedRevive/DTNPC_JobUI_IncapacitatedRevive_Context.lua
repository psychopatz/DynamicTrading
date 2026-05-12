-- ==============================================================================
-- DTNPC_JobUI_IncapacitatedRevive_Context.lua
-- Runtime data and helper accessors for revive conversations.
-- ==============================================================================

DTNPC_JobUI_IncapacitatedRevive = DTNPC_JobUI_IncapacitatedRevive or {}

local ReviveUI = DTNPC_JobUI_IncapacitatedRevive
local modules = ReviveUI.Modules or {}

ReviveUI.Modules = modules

if modules.Context then
    return
end

modules.Context = true

function ReviveUI.GetNPCData(npc)
    return npc and DTNPC and DTNPC.GetData and DTNPC.GetData(npc) or nil
end

function ReviveUI.GetReviveInfo(playerObj, npcData, ignoreItems)
    if DTNPCHealth and DTNPCHealth.CanPlayerRevive then
        local _, info = DTNPCHealth.CanPlayerRevive(playerObj, npcData, {
            ignoreItems = ignoreItems == true,
        })
        return info or {}
    end

    return {}
end

function ReviveUI.GetRequiredCount(npcData)
    if DTNPCHealth and DTNPCHealth.GetReviveRequirement then
        return DTNPCHealth.GetReviveRequirement(npcData)
    end
    return nil
end

function ReviveUI.CountSupplies(playerObj)
    if DTNPCHealth and DTNPCHealth.CountReviveItems then
        return DTNPCHealth.CountReviveItems(playerObj)
    end
    return 0
end

function ReviveUI.RememberPending(ui, npc, playerObj, npcData)
    ReviveUI.pendingRequest = {
        ui = ui,
        npc = npc,
        player = playerObj,
        uuid = npcData and npcData.uuid or nil,
    }
end

function ReviveUI.FormatSupplyText(requiredCount, availableCount)
    if requiredCount and requiredCount > 0 then
        return tostring(availableCount or 0) .. "/" .. tostring(requiredCount) .. " supplies"
    end
    return tostring(availableCount or 0) .. " supplies"
end
