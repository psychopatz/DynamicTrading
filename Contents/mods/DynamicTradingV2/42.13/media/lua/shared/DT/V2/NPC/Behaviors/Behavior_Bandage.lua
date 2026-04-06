-- ==============================================================================
-- Behavior_Bandage.lua
-- Non-combat self-treatment state for wounded NPCs.
-- ==============================================================================

DTNPCLogic = DTNPCLogic or {}
DTNPCLogic.Behaviors = DTNPCLogic.Behaviors or {}

local function stopMoveAnim(zombie)
    zombie:setVariable("bMoving", false)
    zombie:setVariable("isMoving", false)
    zombie:setVariable("Speed", 0.0)
    zombie:setRunning(false)
end

local function ensureManualControl(zombie)
    if not zombie:isUseless() then
        zombie:setUseless(true)
    end
    zombie:setPath2(nil)
    zombie:setTarget(nil)
end

DTNPCLogic.Behaviors["Bandage"] = function(zombie, npcData)
    if not zombie or not npcData or npcData.state ~= "Bandage" then
        return
    end

    ensureManualControl(zombie)
    stopMoveAnim(zombie)
    if DTNPCHealth and DTNPCHealth.ApplyBandageVisualState then
        DTNPCHealth.ApplyBandageVisualState(zombie, npcData)
    else
        zombie:setVariable("DTIdleState", tostring(DTNPCHealth and DTNPCHealth.BANDAGE_IDLE_STATE or "11"))
    end

    if not DTNPCHealth or not DTNPCHealth.ProcessSelfBandageAction then
        return
    end

    local result = DTNPCHealth.ProcessSelfBandageAction(zombie, npcData)
    if result == "applied" or result == "blocked" then
        DTNPCHealth.ExitSelfBandage(zombie, npcData)
    end
end
