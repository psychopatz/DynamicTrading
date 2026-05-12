-- ==============================================================================
-- DTNPC_ProtectShared_Config.lua
-- Shared protect configuration and defaults.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

DTNPCProtect.CONFIG = DTNPCProtect.CONFIG or {
    ScanRadius = 12,
    FloorTolerance = 1,
    StickyRadiusBonus = 1.75,
    StickyTargetScoreBias = 0.45,
    NoticeCooldownMs = 12000,
    DiagnosticCooldownMs = 15000,
    DebugCooldownMs = 15000,
    DebugLogging = false,
    ConsoleLogging = false,
    CombatIssueLogging = false,
    AggressivePlayerRepThreshold = -10,
    HostilePlayerRepThreshold = -40,
    StationaryPostResetDistance = 4,
    StationaryCombatLeashRadius = 10,
    CombatUnreachableTimeoutMs = 6000,
    CombatProgressDistance = 0.35,
    MeleeCrowdRadius = 1.8,
    MeleeCrowdPenalty = 0.8,
    MeleeCrowdClosestPenalty = 0.7,
    MeleeCrowdDangerRadius = 2.4,
    OverwhelmAdjacentThreshold = 3,
    MeleeCrowdDangerThreshold = 3,
    MeleeCrowdSevereThreshold = 4,
    MeleeRecentZombieDamageWindowMs = 4500,
    MeleeLowHealthRetreatRatio = 0.58,
    MeleeImmediateThreatRadius = 2.2,
    MeleeImmediateThreatStickyBreak = 0.65,
    HostileLostSightSearchMinMs = 60000,
    HostileLostSightSearchMaxMs = 90000,
    HostileLastSeenChaseMs = 4500,
    HostileOffscreenDespawnRadius = 70,
    PlayerHitReactionCooldownMs = 1600,
    HostileChaseGiveUpMinMs = 30000,
    HostileChaseGiveUpMaxMs = 55000,
    HostileChaseGiveUpMinDistance = 8,
    BanditChasePauseMs = 120000,
}

DTNPCProtect.CONFIG.DiagnosticCooldownMs = tonumber(DTNPCProtect.CONFIG.DiagnosticCooldownMs) or 15000
DTNPCProtect.CONFIG.DebugCooldownMs = tonumber(DTNPCProtect.CONFIG.DebugCooldownMs) or 15000
DTNPCProtect.CONFIG.DebugLogging = DTNPCProtect.CONFIG.DebugLogging == true
DTNPCProtect.CONFIG.ConsoleLogging = DTNPCProtect.CONFIG.ConsoleLogging == true
DTNPCProtect.CONFIG.CombatIssueLogging = DTNPCProtect.CONFIG.CombatIssueLogging == true
DTNPCProtect.CONFIG.HostileChaseGiveUpMinMs = tonumber(DTNPCProtect.CONFIG.HostileChaseGiveUpMinMs) or 30000
DTNPCProtect.CONFIG.HostileChaseGiveUpMaxMs = tonumber(DTNPCProtect.CONFIG.HostileChaseGiveUpMaxMs) or 55000
DTNPCProtect.CONFIG.HostileChaseGiveUpMinDistance = tonumber(DTNPCProtect.CONFIG.HostileChaseGiveUpMinDistance) or 8
DTNPCProtect.CONFIG.BanditChasePauseMs = tonumber(DTNPCProtect.CONFIG.BanditChasePauseMs) or 120000

DTNPCProtect.LOADOUT_WEIGHTS = DTNPCProtect.LOADOUT_WEIGHTS or {
    melee = 45,
    ranged = 45,
    hybrid = 10,
}

DTNPCProtect.LOADOUT_PRESETS = DTNPCProtect.LOADOUT_PRESETS or {
    melee = {
        rangedWeapon = nil,
        rangedAmmoType = nil,
        ammoCount = 0,
        meleeWeapon = "Base.BaseballBat",
        bag = nil,
    },
    ranged = {
        rangedWeapon = "Base.Pistol",
        rangedAmmoType = "Base.Bullets9mm",
        ammoCount = 24,
        meleeWeapon = nil,
        bag = nil,
    },
    hybrid = {
        rangedWeapon = "Base.Pistol",
        rangedAmmoType = "Base.Bullets9mm",
        ammoCount = 24,
        meleeWeapon = "Base.BaseballBat",
        bag = nil,
    },
}

DTNPCProtect.SKILL_XP_PER_LEVEL = DTNPCProtect.SKILL_XP_PER_LEVEL or {
    Melee = 80,
    Shooting = 100,
}

DTNPCProtect.COMBAT_SKILL_XP = DTNPCProtect.COMBAT_SKILL_XP or {
    MeleeHit = 4,
    MeleeKillBonus = 18,
    ShootingHit = 4,
    ShootingKillBonus = 16,
}
