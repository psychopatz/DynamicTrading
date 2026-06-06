-- ==============================================================================
-- DTNPC_Health.lua
-- Entry point for DT NPC health modules.
-- Loads submodules in explicit order.
-- ==============================================================================

DTNPCHealth = DTNPCHealth or {}
DTNPCHealth.Internal = DTNPCHealth.Internal or {}

if DTNPCHealth.EntryLoaded then
    return
end

DTNPCHealth.EntryLoaded = true

local function T(key, params, fallback)
    if DynamicTrading and DynamicTrading.Text and DynamicTrading.Text.Get then
        return DynamicTrading.Text.Get(key, params, fallback)
    end
    return fallback or tostring(key or "")
end

DTNPCHealth.BASE_HP_BY_ARCHETYPE = DTNPCHealth.BASE_HP_BY_ARCHETYPE or {
    General = 120,
    Teacher = 110,
    Librarian = 110,
    Tailor = 115,
    Bartender = 120,
    Chef = 125,
    Doctor = 125,
    Angler = 130,
    Burglar = 130,
    Welder = 130,
    Mechanic = 135,
    Hiker = 135,
    Foreman = 140,
    Athlete = 145,
    Bandit = 150,
    Sheriff = 160,
    Survivalist = 170,
}

DTNPCHealth.DEFAULT_ENGINE_BUFFER = DTNPCHealth.DEFAULT_ENGINE_BUFFER or 1000
DTNPCHealth.INCAP_ENGINE_HEALTH = DTNPCHealth.INCAP_ENGINE_HEALTH or 2
DTNPCHealth.INCAP_CUSTOM_HP = DTNPCHealth.INCAP_CUSTOM_HP or 1
DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER = DTNPCHealth.INCAP_GRACE_ENGINE_BUFFER or 1000
DTNPCHealth.INCAP_GRACE_WINDOW_MS = DTNPCHealth.INCAP_GRACE_WINDOW_MS or 1200
DTNPCHealth.MIN_DAMAGE = DTNPCHealth.MIN_DAMAGE or 0.01
DTNPCHealth.FALLBACK_IGNORE_WINDOW_MS = DTNPCHealth.FALLBACK_IGNORE_WINDOW_MS or 250
DTNPCHealth.NETWORK_SAFE_SPAWN_ENGINE_HEALTH = math.max(
    DTNPCHealth.DEFAULT_ENGINE_BUFFER,
    tonumber(DTNPCHealth.NETWORK_SAFE_SPAWN_ENGINE_HEALTH) or DTNPCHealth.DEFAULT_ENGINE_BUFFER
)
DTNPCHealth.NETWORK_SAFE_SPAWN_DELAY_MS = DTNPCHealth.NETWORK_SAFE_SPAWN_DELAY_MS or 250
DTNPCHealth.SPAWN_FALLBACK_GUARD_MS = DTNPCHealth.SPAWN_FALLBACK_GUARD_MS or 12000
DTNPCHealth.PLAYER_REP_DAMAGE_THRESHOLD_RATIO = DTNPCHealth.PLAYER_REP_DAMAGE_THRESHOLD_RATIO or 0.25
DTNPCHealth.PLAYER_REP_DAMAGE_PENALTY = DTNPCHealth.PLAYER_REP_DAMAGE_PENALTY or -10
DTNPCHealth.SELF_BANDAGE_THRESHOLD_RATIO = DTNPCHealth.SELF_BANDAGE_THRESHOLD_RATIO or 0.66
DTNPCHealth.SELF_BANDAGE_APPLY_DURATION_MS = DTNPCHealth.SELF_BANDAGE_APPLY_DURATION_MS or 4000
DTNPCHealth.SELF_BANDAGE_ANIM_FALLBACK_GRACE_MS = DTNPCHealth.SELF_BANDAGE_ANIM_FALLBACK_GRACE_MS or 1500
DTNPCHealth.SELF_BANDAGE_MANUAL_INTERRUPT_RETRY_MS = DTNPCHealth.SELF_BANDAGE_MANUAL_INTERRUPT_RETRY_MS or 5000
DTNPCHealth.PLAYER_OWNED_DEFAULT_BANDAGE_CHARGES = DTNPCHealth.PLAYER_OWNED_DEFAULT_BANDAGE_CHARGES or 2
DTNPCHealth.SELF_BANDAGE_RETRY_DELAY_MS = DTNPCHealth.SELF_BANDAGE_RETRY_DELAY_MS or 15000
DTNPCHealth.SELF_BANDAGE_VISIBLE_RADIUS = DTNPCHealth.SELF_BANDAGE_VISIBLE_RADIUS or 18
DTNPCHealth.BANDAGE_IDLE_STATE = DTNPCHealth.BANDAGE_IDLE_STATE or "11"
DTNPCHealth.BANDAGE_SOUND = DTNPCHealth.BANDAGE_SOUND or "Character/Survival/FirstAid/CleanRag"
DTNPCHealth.REVIVE_SUCCESS_SOUND = DTNPCHealth.REVIVE_SUCCESS_SOUND or "DT_Healed"
DTNPCHealth.BANDAGE_ANIM_VARIANTS = DTNPCHealth.BANDAGE_ANIM_VARIANTS or {
    { id = "UpperBody", weight = 3 },
    { id = "LeftArm", weight = 2 },
    { id = "RightArm", weight = 2 },
    { id = "LowerBody", weight = 1 },
    { id = "LeftLeg", weight = 1 },
    { id = "RightLeg", weight = 1 },
    { id = "Head", weight = 1 },
}
DTNPCHealth.HEALTH_PERSIST_INTERVAL_MS = DTNPCHealth.HEALTH_PERSIST_INTERVAL_MS or 2000
DTNPCHealth.DEFAULT_BANDAGE_TIER = DTNPCHealth.DEFAULT_BANDAGE_TIER or "clean_rag"
DTNPCHealth.BANDAGE_TIERS = DTNPCHealth.BANDAGE_TIERS or {
    clean_rag = {
        label = T("DTNPC_UI_CleanRag", nil, "Clean Rag"),
        iconFullType = "Base.RippedSheets",
        totalHeal = 20,
        applyHeal = 2,
        regenPerTick = 1,
        regenIntervalMs = 2000,
    },
    sterilized_rag = {
        label = T("DTNPC_UI_SterilizedRag", nil, "Sterilized Rag"),
        iconFullType = "Base.AlcoholRippedSheets",
        totalHeal = 28,
        applyHeal = 3,
        regenPerTick = 1.5,
        regenIntervalMs = 2000,
    },
    bandage = {
        label = T("DTNPC_UI_BandageLabel", nil, "Bandage"),
        iconFullType = "Base.Bandage",
        totalHeal = 36,
        applyHeal = 4,
        regenPerTick = 2,
        regenIntervalMs = 2000,
    },
}
DTNPCHealth.SELF_BANDAGE_TUNING_VERSION = DTNPCHealth.SELF_BANDAGE_TUNING_VERSION or 3
DTNPCHealth.RESTING_REGEN_INTERVAL_MS = DTNPCHealth.RESTING_REGEN_INTERVAL_MS or 20000
DTNPCHealth.RESTING_REGEN_PER_TICK = DTNPCHealth.RESTING_REGEN_PER_TICK or 0.5
DTNPCHealth.DEFAULT_RESTING_REGEN_MULTIPLIER = DTNPCHealth.DEFAULT_RESTING_REGEN_MULTIPLIER or 1.0

require "DT/V2/NPC/Sys/Roles/DTNPC_Roles"
require "DT/V2/NPC/Sys/Health/HealthShared/DTNPC_HealthShared"
require "DT/V2/NPC/Sys/Health/DTNPC_Health_Defaults"
require "DT/V2/NPC/Sys/Health/HealthRevive/DTNPC_HealthRevive"
require "DT/V2/NPC/Sys/Health/HealthBandage/DTNPC_HealthBandage"
require "DT/V2/NPC/Sys/Health/DTNPC_Health_Spawn"
require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle"
require "DT/V2/NPC/Sys/Health/DTNPC_Health_Damage"
require "DT/V2/NPC/Sys/Health/DTNPC_Health_Events"
