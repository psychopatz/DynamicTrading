-- ==============================================================================
-- DTNPC_JobUI_IncapacitatedRevive_Context.lua
-- Runtime data and helper accessors for revive conversations.
-- ==============================================================================

require "DT/Common/Text/DT_Text"

DTNPC_JobUI_IncapacitatedRevive = DTNPC_JobUI_IncapacitatedRevive or {}

local ReviveUI = DTNPC_JobUI_IncapacitatedRevive
local modules = ReviveUI.Modules or {}

ReviveUI.Modules = modules

if modules.Context then
    return
end

modules.Context = true

function ReviveUI.T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end

    if fallback then
        return DynamicTrading.Text and DynamicTrading.Text.Format and DynamicTrading.Text.Format(fallback, params) or fallback
    end

    return tostring(key or "")
end

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

function ReviveUI.GetSupplyEntries(playerObj)
    if DTNPCHealth and DTNPCHealth.GetReviveItemEntries then
        return DTNPCHealth.GetReviveItemEntries(playerObj)
    end
    return {}
end

function ReviveUI.CountSupplyType(playerObj, fullType)
    if DTNPCHealth and DTNPCHealth.CountReviveItems then
        return tonumber(DTNPCHealth.CountReviveItems(playerObj, fullType)) or 0
    end
    return 0
end

function ReviveUI.RememberPending(ui, npc, playerObj, npcData, fullType)
    ReviveUI.pendingRequest = {
        ui = ui,
        npc = npc,
        player = playerObj,
        uuid = npcData and npcData.uuid or nil,
        requiredFullType = fullType,
    }
end

function ReviveUI.GetEntryDisplayName(entry)
    if type(entry) ~= "table" then
        return ReviveUI.T("DTNPC_UI_UseMedicalSupply", nil, "Medical Supply")
    end
    return tostring(entry.displayName or entry.fullType or ReviveUI.T("DTNPC_UI_UseMedicalSupply", nil, "Medical Supply"))
end

function ReviveUI.GetEntryTexture(entry)
    local sampleItem = type(entry) == "table" and entry.sampleItem or nil
    if sampleItem and sampleItem.getTex then
        return sampleItem:getTex()
    end
    return nil
end

function ReviveUI.CanUseEntry(entry, requiredCount)
    local available = tonumber(entry and entry.count) or 0
    local needed = math.max(1, math.floor(tonumber(requiredCount) or 1))
    return available >= needed
end

function ReviveUI.FormatEntryLabel(entry, requiredCount)
    local displayName = ReviveUI.GetEntryDisplayName(entry)
    local available = tonumber(entry and entry.count) or 0
    local needed = math.max(1, math.floor(tonumber(requiredCount) or 1))
    return ReviveUI.T("DTNPC_UI_MedicalSupplyLabel", {
        name = tostring(displayName),
        available = tostring(available),
        required = tostring(needed),
    }, "{name} ({available}/{required})")
end

function ReviveUI.FormatSupplyText(requiredCount, availableCount)
    if requiredCount and requiredCount > 0 then
        return ReviveUI.T("DTNPC_UI_SuppliesCountRequired", {
            count = tostring(availableCount or 0),
            required = tostring(requiredCount),
        }, "{count}/{required} supplies")
    end
    return ReviveUI.T("DTNPC_UI_SuppliesCount", {
        count = tostring(availableCount or 0),
    }, "{count} supplies")
end
