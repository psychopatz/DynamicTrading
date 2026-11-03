local T = require "tests/support/test"
T.addPackagePaths()

-- ---------------------------------------------------------------------------
-- 1. Fail-First check: DTAbstract DebugHub module
-- ---------------------------------------------------------------------------
local ok, err = pcall(function()
    return T.load("DTAbstract", "client", "DTAbstract/UI/DTAbstract_DebugHub.lua")
end)
if not ok then
    error("P0/P5 Fail-First: DTAbstract DebugHub module not implemented: " .. tostring(err), 2)
end

local DebugHub = DTAbstract.DebugHub
T.truthy(DebugHub, "DTAbstract DebugHub loaded")

T.finish("dt_abstract_debug_hub_smoke")
