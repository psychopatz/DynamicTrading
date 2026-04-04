-- ==============================================================================
-- DTNPC_Logic_Tick.lua
-- Tick hook registration for shared NPC logic.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}

local Internal = DTNPCLogic.Internal

function DTNPCLogic.OnTick()
    local cell = getCell()
    if not cell then
        return
    end

    DTNPCLogic.RefreshActivePlayers()

    local zombieList = cell:getZombieList()
    if not zombieList then
        return
    end

    for i = zombieList:size() - 1, 0, -1 do
        local zombie = zombieList:get(i)
        if zombie and zombie:isLocal() and zombie:getModData().IsDTNPC then
            local success, err = pcall(function()
                DTNPCLogic.ProcessNPC(zombie)
            end)

            if not success then
                DynamicTrading.Log("DTV2", "NPC", "Error", "Error processing NPC: " .. tostring(err))
            end
        end
    end
end

if not Internal.TickRegistered then
    Events.OnTick.Add(DTNPCLogic.OnTick)
    Internal.TickRegistered = true
end
