local T = require "tests/support/test"
T.addPackagePaths()

-- ---------------------------------------------------------------------------
-- 1. Fail-First check: DTAbstract Server Lifecycle module
-- ---------------------------------------------------------------------------
local ok, err = pcall(function()
    return T.load("DTAbstract", "server", "DTAbstract/DTAbstract_Server.lua")
end)
if not ok then
    error("P0/P2 Fail-First: DTAbstract Server module not implemented: " .. tostring(err), 2)
end

local Server = DTAbstract.Server
T.truthy(Server, "DTAbstract Server module loaded")

local Lifecycle = DTAbstract.Lifecycle
T.truthy(Lifecycle, "DTAbstract Lifecycle loaded")

-- ---------------------------------------------------------------------------
-- 2. Lifecycle Tick: Spawns and manages abstract traders up to bound
-- ---------------------------------------------------------------------------
T.truthy(type(Lifecycle.Tick) == "function", "Lifecycle.Tick is a function")
local summary = Lifecycle.Tick(true)
T.truthy(summary, "Lifecycle.Tick returns summary")
T.truthy(summary.activeCount ~= nil or summary.spawned ~= nil, "Tick summary has trader counts")

-- ---------------------------------------------------------------------------
-- 3. Debug command: Spawn Abstract Trader Near Player
-- ---------------------------------------------------------------------------
T.truthy(type(Server.SpawnAbstractTraderNearPlayer) == "function",
    "SpawnAbstractTraderNearPlayer server function exists")

T.finish("dt_abstract_lifecycle_smoke")
