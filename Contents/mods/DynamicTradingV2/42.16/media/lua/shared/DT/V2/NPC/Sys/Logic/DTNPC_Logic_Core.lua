-- ==============================================================================
-- DTNPC_Logic_Core.lua
-- Shared constants and helpers for NPC logic modules.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Internal = DTNPCLogic.Internal or {}

local Internal = DTNPCLogic.Internal

Internal.ANCHOR_DRIFT_TOLERANCE = 1.5
Internal.ANCHOR_SNAP_COOLDOWN_HOURS = 2 / 3600
Internal.IDLE_STATE_COUNT = 10
Internal.IDLE_CYCLE_TICKS = 240

function Internal.CalculateDistance(obj1, obj2)
    if not obj1 or not obj2 then
        return 9999
    end

    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt(dx * dx + dy * dy)
end
