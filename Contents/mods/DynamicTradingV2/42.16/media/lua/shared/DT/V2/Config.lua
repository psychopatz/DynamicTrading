require "DT/Common/Config"
DynamicTrading = DynamicTrading or {}
DynamicTrading.V2 = {}
DynamicTrading.V2.Config = {}

if DynamicTrading.Manuals and DynamicTrading.Manuals.MarkAudienceActive then
    DynamicTrading.Manuals.MarkAudienceActive("v2", true)
end


-- =============================================================================
-- FACTION SYSTEM CONFIGURATION (LEGACY ALIAS)
-- =============================================================================
-- Move to Common/Config.lua for V1/V2 parity.
DynamicTrading.V2.Config = DynamicTrading.Config
DynamicTrading.V2.Config.Events = DynamicTrading.Config.FactionEvents

-- Ensure common events are reachable
require "DT/Common/Events/DT_EventManager"
require "DT/Common/Events/Seasonal/Negative/Winter"
-- future: add other base seasonal/flash events here if not auto-loaded

-- V1 -> V2 transition hygiene: remove V1-only radio metadata.
local function cleanupV1RadioMetadata()
	if isClient() and not isServer() then return end

	local key = "DynamicTrading_V1_Radio"
	local data = ModData.get(key)
	if type(data) ~= "table" then return end

	data.RadioTraders = {}
	data.tradersVersion = (data.tradersVersion or 0) + 1

	if isServer() or not isClient() then
		ModData.transmit(key)
	end

	if DynamicTrading.Debug then
		DynamicTrading.Log("DTV2", "Config", "System", "V2 cleanup applied: cleared DynamicTrading_V1_Radio metadata.")
	end
end

Events.OnInitGlobalModData.Add(cleanupV1RadioMetadata)

DynamicTrading.Log("DTV2", "Init", "System", "V2 Config Initialized.")
