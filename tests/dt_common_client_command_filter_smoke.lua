local T = require "tests/support/test"
T.addPackagePaths()

local handlers = {}
Events = {
    OnServerCommand = {
        Add = function(callback)
            handlers[#handlers + 1] = callback
        end,
    },
}

local previousPrint = print
local logs = {}
print = function(...)
    logs[#logs + 1] = table.concat({ ... }, " ")
end

DTCommon = {
    MOD_ID = "DTCommon",
    TradePresentations = {
        Open = function() return false end,
        UpdateSnapshot = function() return false end,
        HandleResult = function() return false end,
    },
}

local Client = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_Client.lua"
)
T.truthy(Client, "DTCommon client module failed to load")

for _, callback in ipairs(handlers) do
    callback("DTCommon", "TraderDebugSpawnResult", {
        accepted = true,
        pending = true,
        requestID = "dt_debug_spawn:1",
        position = { x = 10724, y = 10619, z = 0 },
        reason = "queued",
    })
end

print = previousPrint
for _, line in ipairs(logs) do
    T.falsy(
        string.find(line, "server_command_missing_trader", 1, true),
        "debug spawn response was misclassified as a missing trader"
    )
end

T.finish("dt_common_client_command_filter_smoke")
