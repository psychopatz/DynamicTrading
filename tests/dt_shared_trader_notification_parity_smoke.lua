local T = require "tests/support/test"
T.addPackagePaths()

local requested
local shown
local guardView = {
    traderID = "trader:notice:1",
    actorID = "actor:notice:guard",
    name = "Northstar Guard",
    tradeAvailable = false,
    factionPresentation = {
        factionID = "faction:notice:1",
        badge = { glyph = "N", color = { r = 0.2, g = 0.8, b = 1 } },
    },
    portraitSpec = { actorID = "actor:notice:guard", faceOnly = false },
}

DTCommon = {
    TraderPresentation = {
        GetTraderView = function() return guardView end,
        GetTraderViewForActor = function() return guardView end,
    },
    TraderManager = {
        Request = function(action, traderID, args)
            requested = { action = action, traderID = traderID, args = args }
            return true
        end,
    },
}
PsychopatzCore = {
    ActorNotifications = {
        Show = function(definition)
            shown = definition
            return true
        end,
    },
}

local Notification = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderNotification.lua"
)
T.truthy(Notification.Build, "shared trader notification builder is missing")

local definition = Notification.Build(
    "trader:notice:1",
    "Northstar Guard is operating nearby.",
    {
        actorID = guardView.actorID,
        persistent = true,
        id = "dt_nearby:trader:notice:1",
    }
)
T.equal(definition.actorID, guardView.actorID,
    "shared notification lost the selected roster actor")
T.equal(definition.name, guardView.name,
    "shared notification lost the selected actor name")
T.equal(definition.factionBadge.glyph, "N",
    "shared notification lost the faction badge")
T.equal(definition.portraitSpec.actorID, guardView.actorID,
    "shared notification lost the circular portrait target")
T.truthy(definition.persistent,
    "proximity notification is not persistent")
T.truthy(definition.actions and definition.actions[1],
    "shared notification did not expose Talk")
definition.actions[1].callback()
T.equal(requested.args.actorID, guardView.actorID,
    "notification Talk action lost the selected actor")

T.truthy(Notification.Show(
    "trader:notice:1",
    "Trader arrived.",
    { id = "dt_spawn:trader:notice:1" }
), "shared notification did not publish through Core")
T.equal(shown.id, "dt_spawn:trader:notice:1",
    "shared notification changed the caller notification identity")

print("dt_shared_trader_notification_parity_smoke: PASS")
