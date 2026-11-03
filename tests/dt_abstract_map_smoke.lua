local T = require "tests/support/test"
T.addPackagePaths()

-- ---------------------------------------------------------------------------
-- 1. Fail-First check: DTAbstract WorldMap presentation module
-- ---------------------------------------------------------------------------
local ok, err = pcall(function()
    return T.load("DTAbstract", "client", "DTAbstract/DTAbstract_WorldMap.lua")
end)
if not ok then
    error("P0/P3 Fail-First: DTAbstract WorldMap module not implemented: " .. tostring(err), 2)
end

local WorldMap = DTAbstract.WorldMap
T.truthy(WorldMap, "DTAbstract WorldMap module loaded")
T.truthy(type(WorldMap.GetMapMarkers) == "function", "GetMapMarkers function exists")

T.finish("dt_abstract_map_smoke")
