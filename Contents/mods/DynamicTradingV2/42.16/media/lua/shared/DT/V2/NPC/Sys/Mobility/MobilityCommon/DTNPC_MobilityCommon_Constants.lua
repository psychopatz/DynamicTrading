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
