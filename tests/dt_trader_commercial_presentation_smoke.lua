local T = require "tests/support/test"
T.addPackagePaths()

package.preload[
    "PsychopatzCore/Actors/PsychopatzActorProjectionClient"
] = function()
    error("commercial presentation must not load actor projection")
end

local data = {
    r = 4,
}
local scans = 0
local records = {
    ["trader:presentation:a"] = {
        n = "Abstract Merchant",
        ca = {
            actorID = "actor:presentation:a",
            provider = "DTAbstract",
        },
    },
    ["trader:presentation:p"] = {
        n = "Physical Merchant",
        ca = {
            actorID = "actor:presentation:p",
            provider = "DTHoomans",
        },
    },
}

DTCommon = {
    Storage = {
        GetData = function()
            return data
        end,
    },
    TraderService = {
        ForEach = function(callback)
            scans = scans + 1
            for traderID, record in pairs(records) do
                callback(traderID, record)
            end
        end,
    },
}

local Presentation = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderPresentation.lua"
)

local rows = Presentation.ListTraderRecords(true, 1)
T.equal(#rows, 2,
    "commercial presentation did not list trader bindings")
T.equal(rows[1].traderID, "trader:presentation:a",
    "commercial rows are not deterministic")
T.equal(rows[1].actorID, "actor:presentation:a",
    "commercial actor binding changed")
T.equal(rows[1].provider, "DTAbstract",
    "commercial provider metadata changed")
T.equal(rows[2].provider, "DTHoomans",
    "physical provider metadata changed")
T.equal(scans, 1,
    "initial commercial presentation scan count changed")

Presentation.ListTraderRecords(false, 1.5)
T.equal(scans, 1,
    "commercial rows rescanned inside cache window")

records["trader:presentation:new"] = {
    n = "New Merchant",
    ca = {
        actorID = "actor:presentation:new",
        provider = "DTAbstract",
    },
}
data.r = data.r + 1
rows = Presentation.ListTraderRecords(false, 1.6)
T.equal(scans, 2,
    "commercial store revision did not invalidate row cache")
T.equal(#rows, 3,
    "revision refresh did not include new trader binding")

Presentation.ListTraderRecords(false, 4)
T.equal(scans, 3,
    "time fallback did not refresh commercial row cache")

T.finish("dt_trader_commercial_presentation_smoke")
