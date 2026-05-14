-- ==============================================================================
-- DTNPC_ManagerRegistration.lua
-- Main entry point for NPC registration, removal, status, and lifecycle hooks.
-- ==============================================================================

DTNPCManager = DTNPCManager or {}

if isClient() and not isServer() then return end

require "DT/V2/NPC/Sys/Lifecycle/DTNPC_Lifecycle"
require "DT/V2/NPC/Sys/Data/DTNPC_Data"

require "DT/V2/NPC/Manager/DTNPC_ManagerRegistration/DTNPC_ManagerRegistration_Register"
require "DT/V2/NPC/Manager/DTNPC_ManagerRegistration/DTNPC_ManagerRegistration_Reclaim"
require "DT/V2/NPC/Manager/DTNPC_ManagerRegistration/DTNPC_ManagerRegistration_Removal"
require "DT/V2/NPC/Manager/DTNPC_ManagerRegistration/DTNPC_ManagerRegistration_Status"
require "DT/V2/NPC/Manager/DTNPC_ManagerRegistration/DTNPC_ManagerRegistration_Lifecycle"
