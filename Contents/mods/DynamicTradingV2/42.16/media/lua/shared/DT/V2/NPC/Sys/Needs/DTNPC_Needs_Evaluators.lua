-- ==============================================================================
-- DTNPC_Needs_Evaluators.lua
-- Built-in autonomous maintenance evaluators for DT NPCs.
-- ==============================================================================

DTNPCNeeds = DTNPCNeeds or {}

local function nowMillis()
    if getTimeInMillis then
        local value = tonumber(getTimeInMillis())
        if value and value > 0 then
            return math.floor(value)
        end
    end

    local gt = getGameTime and getGameTime() or nil
    if gt and gt.getWorldAgeHours then
        return math.floor((tonumber(gt:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

local function isBlockedState(npcData, state)
    local currentState = tostring(state or npcData and npcData.state or "")
    if currentState == "Attack"
        or currentState == "AttackRange"
        or currentState == "Flee"
        or currentState == "Bandage"
        or currentState == "ReviveAlly"
        or currentState == "Incapacitated"
        or currentState == "Departure"
        or currentState == "Trading"
        or currentState == "TradingDefenseRanged"
        or currentState == "TradingDefenseMelee"
        or currentState == "Follow"
        or currentState == "ProtectRanged"
        or currentState == "ProtectMelee"
        or currentState == "ProtectAuto"
        or currentState == "Guard"
        or currentState == "Stay" then
        return true
    end

    if type(npcData) ~= "table" then
        return true
    end

    return tostring(npcData.contactVisitMode or "") ~= ""
        or tostring(npcData.doObjectiveHookId or "") ~= ""
        or npcData.doObjectiveEscortActive == true
end

local function evaluateReturnHome(zombie, npcData, currentState)
    if type(npcData) ~= "table" or not DTNPCRoles then
        return nil
    end

    if DTNPCRoles.ShouldAutoReturnHome == nil or DTNPCRoles.ShouldAutoReturnHome(npcData) ~= true then
        npcData.returnHomeEligibleSince = nil
        npcData.returnHomeResumeState = nil
        return nil
    end

    local home = DTNPCRoles.ResolveHomeTarget and DTNPCRoles.ResolveHomeTarget(npcData) or nil
    if type(home) ~= "table" or home.x == nil or home.y == nil then
        npcData.returnHomeEligibleSince = nil
        npcData.returnHomeResumeState = nil
        return nil
    end

    local dx = (zombie and zombie.getX and zombie:getX() or 0) - tonumber(home.x)
    local dy = (zombie and zombie.getY and zombie:getY() or 0) - tonumber(home.y)
    local radius = math.max(1, tonumber(home.radius) or 30)
    if ((dx * dx) + (dy * dy)) <= (radius * radius) then
        npcData.returnHomeEligibleSince = nil
        npcData.returnHomeResumeState = nil
        return nil
    end

    if isBlockedState(npcData, currentState) then
        npcData.returnHomeEligibleSince = nil
        return nil
    end

    local now = nowMillis()
    if tonumber(npcData.returnHomeEligibleSince) == nil then
        npcData.returnHomeEligibleSince = now
        return nil
    end

    if (now - tonumber(npcData.returnHomeEligibleSince)) < 10000 then
        return nil
    end

    if tostring(npcData.returnHomeResumeState or "") == "" and DTNPCRoles.ResolveDefaultState then
        npcData.returnHomeResumeState = DTNPCRoles.ResolveDefaultState(npcData)
    end

    return "ReturnHome"
end

local function evaluateCorpseCleanup(zombie, npcData, currentState)
    if type(npcData) ~= "table" or currentState ~= "Idle" then
        return nil
    end

    if isBlockedState(npcData, currentState) then
        return nil
    end

    if not DTNPCCorpseCleanup or DTNPCCorpseCleanup.CanAutonomousCleanup == nil then
        return nil
    end

    if DTNPCCorpseCleanup.CanAutonomousCleanup(npcData) ~= true then
        return nil
    end

    if DTNPCCorpseCleanup.HasAvailableTask and DTNPCCorpseCleanup.HasAvailableTask(npcData, {
        mode = "ai",
    }) == true then
        return "CorpseCleanup"
    end

    return nil
end

DTNPCNeeds.RegisterEvaluator("corpse_cleanup", evaluateCorpseCleanup)
DTNPCNeeds.RegisterEvaluator("return_home", evaluateReturnHome)
DTNPCNeeds.RegisterEvaluator("clean_clothes", function()
    return nil
end)
