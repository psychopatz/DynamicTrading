-- ==============================================================================
-- DTNPC_MobilityCommon_Constants.lua
-- Shared mobility constants.
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Constants = Mobility.Constants or {}
local Internal = Mobility.Internal or {}

Mobility.Constants = Constants
Mobility.Internal = Internal

Constants.DAMAGE_PRESSURE_WINDOW_MS = Constants.DAMAGE_PRESSURE_WINDOW_MS or 2500
Constants.DAMAGE_RETREAT_LOCK_MS = Constants.DAMAGE_RETREAT_LOCK_MS or 900
Constants.DAMAGE_RETREAT_DISTANCE = Constants.DAMAGE_RETREAT_DISTANCE or 2.2
Constants.DAMAGE_RETREAT_LOW_HEALTH_RATIO = Constants.DAMAGE_RETREAT_LOW_HEALTH_RATIO or 0.60
Constants.DAMAGE_RETREAT_ADJACENT_DIST = Constants.DAMAGE_RETREAT_ADJACENT_DIST or 1.2
Constants.BLOCKED_HEADING_MEMORY_MS = Constants.BLOCKED_HEADING_MEMORY_MS or 850
Constants.DEFAULT_STEERING_ANGLES = Constants.DEFAULT_STEERING_ANGLES or { 0, 30, -30, 60, -60, 90, -90 }
Constants.SPECIAL_ACTION_GRACE_MS = Constants.SPECIAL_ACTION_GRACE_MS or 120
Constants.MOVE_PROGRESS_EPSILON = Constants.MOVE_PROGRESS_EPSILON or 0.025
Constants.MOVE_PROGRESS_GOAL_EPSILON = Constants.MOVE_PROGRESS_GOAL_EPSILON or 0.04
Constants.MOVE_PROGRESS_STALL_TICKS = Constants.MOVE_PROGRESS_STALL_TICKS or 18
Constants.MOVE_PROGRESS_STALL_MS = Constants.MOVE_PROGRESS_STALL_MS or 900
Constants.NAVIGATION_PROFILES = Constants.NAVIGATION_PROFILES or {
    default = {
        profileKey = "default",
        plannerRadius = 20,
        routeTTL = 1300,
        repathTargetShift = 2.0,
        waypointArrivalRadius = 0.35,
        goalSearchRadius = 2,
        blockedRepathCount = 2,
        snapAfterFailures = 4,
        maxRouteSnapDistance = 3.0,
        maxRouteSnapIndexAdvance = 4,
        doorPauseMs = 140,
        allowLeashTeleport = false,
        leashTeleportDistance = 16,
        leashTeleportSearchRadius = 3,
        blockedPenalty = 1.25,
        blockedPenaltyMs = 1100,
        closedDoorCost = 1.8,
        fenceCost = 2.6,
    },
    follow = {
        profileKey = "follow",
        plannerRadius = 34,
        routeTTL = 1000,
        repathTargetShift = 2.0,
        waypointArrivalRadius = 0.42,
        goalSearchRadius = 3,
        blockedRepathCount = 2,
        snapAfterFailures = 3,
        maxRouteSnapDistance = 4.2,
        maxRouteSnapIndexAdvance = 5,
        doorPauseMs = 120,
        allowLeashTeleport = true,
        leashTeleportDistance = 14,
        leashTeleportSearchRadius = 4,
        blockedPenalty = 1.5,
        blockedPenaltyMs = 1300,
        closedDoorCost = 1.5,
        fenceCost = 2.3,
    },
    colony = {
        profileKey = "colony",
        plannerRadius = 32,
        routeTTL = 1600,
        repathTargetShift = 1.5,
        waypointArrivalRadius = 0.32,
        goalSearchRadius = 2,
        blockedRepathCount = 2,
        snapAfterFailures = 5,
        maxRouteSnapDistance = 2.8,
        maxRouteSnapIndexAdvance = 3,
        doorPauseMs = 180,
        allowLeashTeleport = false,
        leashTeleportDistance = 99,
        leashTeleportSearchRadius = 2,
        blockedPenalty = 1.2,
        blockedPenaltyMs = 1200,
        closedDoorCost = 1.9,
        fenceCost = 2.8,
    },
    ["goto"] = {
        profileKey = "goto",
        plannerRadius = 42,
        routeTTL = 1400,
        repathTargetShift = 0.75,
        waypointArrivalRadius = 0.30,
        goalSearchRadius = 2,
        blockedRepathCount = 2,
        snapAfterFailures = 5,
        maxRouteSnapDistance = 3.0,
        maxRouteSnapIndexAdvance = 4,
        doorPauseMs = 140,
        allowLeashTeleport = false,
        leashTeleportDistance = 99,
        leashTeleportSearchRadius = 2,
        blockedPenalty = 1.3,
        blockedPenaltyMs = 1200,
        closedDoorCost = 1.6,
        fenceCost = 2.4,
    },
    combat_short = {
        profileKey = "combat_short",
        plannerRadius = 12,
        routeTTL = 650,
        repathTargetShift = 1.0,
        waypointArrivalRadius = 0.28,
        goalSearchRadius = 1,
        blockedRepathCount = 3,
        snapAfterFailures = 99,
        maxRouteSnapDistance = 1.8,
        maxRouteSnapIndexAdvance = 2,
        doorPauseMs = 100,
        allowLeashTeleport = false,
        leashTeleportDistance = 99,
        leashTeleportSearchRadius = 2,
        blockedPenalty = 1.0,
        blockedPenaltyMs = 700,
        closedDoorCost = 2.2,
        fenceCost = 3.0,
    },
}
