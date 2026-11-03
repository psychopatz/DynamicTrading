local T = require "tests/support/test"
T.addPackagePaths()

-- ---------------------------------------------------------------------------
-- 1. Fail-First check: DTAbstract Nearby Discovery module
-- ---------------------------------------------------------------------------
local ok, err = pcall(function()
    return T.load("DTAbstract", "client", "DTAbstract/DTAbstract_NearbyDiscovery.lua")
end)
if not ok then
    error("P0/P4 Fail-First: DTAbstract NearbyDiscovery module not implemented: " .. tostring(err), 2)
end

local Discovery = DTAbstract.NearbyDiscovery
T.truthy(Discovery, "DTAbstract NearbyDiscovery module loaded")
T.truthy(type(Discovery.CheckNearbyTraders) == "function", "CheckNearbyTraders function exists")

T.finish("dt_abstract_nearby_discovery_smoke")
