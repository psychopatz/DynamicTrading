-- ==============================================================================
-- DTNPC_ManagerTick_RestingRegen.lua
-- Passive regen processing for resting NPCs that are not currently loaded.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

DTNPCManager.TickInternal = DTNPCManager.TickInternal or {}

local tickInternal = DTNPCManager.TickInternal

function tickInternal.ProcessOfflineRestingRegen()
    if not DTNPCHealth or not DTNPCHealth.ProcessPassiveRestRegen then
        return
    end
    if not DynamicTrading_Roster or not DynamicTrading_Roster.MOD_DATA_KEY or not ModData then
        return
    end

    local rosterData = ModData.get(DynamicTrading_Roster.MOD_DATA_KEY)
    local souls = rosterData and rosterData.Souls or nil
    if not souls then
        return
    end

    for uuid, registry in pairs(souls) do
        if registry
            and registry.status == "Resting"
            and not DTNPCManager.Data[uuid] then
            local currentHp = tonumber(registry.combatHealthCurrent) or tonumber(registry.health) or 0
            local maxHp = tonumber(registry.combatHealthMax) or 0
            if currentHp > 0 and (maxHp <= 0 or currentHp < maxHp) then
                local npcData = DynamicTrading_Roster.GetSoul(uuid)
                if npcData then
                    DTNPCHealth.ProcessPassiveRestRegen(nil, npcData, {
                        forceManagerSave = false,
                    })
                end
            end
        end
    end
end
