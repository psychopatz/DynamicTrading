-- ==============================================================================
-- DTNPC_JobUI_TravelCompanion_Core.lua
-- Shared state bootstrap for the travel companion job UI.
-- ==============================================================================

DTNPC_JobUI_TravelCompanion = DTNPC_JobUI_TravelCompanion or {}

local CompanionUI = DTNPC_JobUI_TravelCompanion
local modules = CompanionUI.Modules or {}
local Constants = CompanionUI.Constants or {}
local State = CompanionUI.State or {}

CompanionUI.Modules = modules
CompanionUI.Constants = Constants
CompanionUI.State = State

if modules.Core then
    return
end

modules.Core = true

Constants.COMPANION_INVENTORY_PREWARM_TIMEOUT_MS = 1200
Constants.MEDICAL_PROVISION_FULL_TYPES = {
    ["Base.Bandage"] = true,
    ["Base.BandageBox"] = true,
    ["Base.AlcoholBandage"] = true,
    ["Base.RippedSheets"] = true,
    ["Base.AlcoholRippedSheets"] = true,
    ["Base.Bandaid"] = true,
    ["Base.CottonBalls"] = true,
    ["Base.CottonBallsBox"] = true,
    ["Base.AlcoholWipes"] = true,
    ["Base.AlcoholedCottonBalls"] = true,
    ["Base.Disinfectant"] = true,
}

State.medicalTextureCache = State.medicalTextureCache or {}
State.companionInventoryPrewarm = State.companionInventoryPrewarm or {
    pending = {},
    tickHookAdded = false,
}

function CompanionUI.DebugCompanionUI(message)
    local text = "[DTV2 Companion UI] " .. tostring(message or "")
    print(text)
    if DynamicTrading and DynamicTrading.Log then
        DynamicTrading.Log("DTV2", "NPC", "CompanionUI", tostring(message or ""))
    end
end

function CompanionUI.NowMs()
    if getTimeInMillis then
        return math.floor(tonumber(getTimeInMillis()) or 0)
    end

    return math.floor((os.time() or 0) * 1000)
end

function CompanionUI.GetNPCData(npc)
    return npc and DTNPC and DTNPC.GetData and DTNPC.GetData(npc) or nil
end
