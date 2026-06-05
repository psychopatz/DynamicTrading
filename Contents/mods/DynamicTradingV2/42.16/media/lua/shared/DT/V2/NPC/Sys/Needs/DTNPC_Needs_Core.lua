-- ==============================================================================
-- DTNPC_Needs_Core.lua
-- Evaluator registry and dispatch for autonomous DT NPC maintenance states.
-- ==============================================================================

DTNPCNeeds = DTNPCNeeds or {}
DTNPCNeeds.Internal = DTNPCNeeds.Internal or {}

local Internal = DTNPCNeeds.Internal

Internal.Evaluators = Internal.Evaluators or {}
Internal.EvaluatorOrder = Internal.EvaluatorOrder or {}

function DTNPCNeeds.RegisterEvaluator(needKey, fn)
    local key = tostring(needKey or "")
    if key == "" or type(fn) ~= "function" then
        return false
    end

    if Internal.Evaluators[key] == nil then
        Internal.EvaluatorOrder[#Internal.EvaluatorOrder + 1] = key
    end

    Internal.Evaluators[key] = fn
    return true
end

function DTNPCNeeds.Evaluate(zombie, npcData, currentState)
    for i = 1, #Internal.EvaluatorOrder do
        local key = Internal.EvaluatorOrder[i]
        local fn = Internal.Evaluators[key]
        if type(fn) == "function" then
            local nextState = fn(zombie, npcData, currentState)
            if tostring(nextState or "") ~= "" then
                npcData.state = tostring(nextState)
                npcData.activeNeedKey = key
                return npcData.state
            end
        end
    end

    if type(npcData) == "table" then
        npcData.activeNeedKey = nil
    end
    return nil
end
