local T = require "tests/support/test"
T.addPackagePaths()

local requested
local shown
local leaderView = {
    traderID = "trader:notice:1",
    actorID = "actor:notice:leader",
    name = "Northstar Trader",
    tradeAvailable = true,
    factionPresentation = {
        factionID = "faction:notice:1",
        badge = { glyph = "N", color = { r = 0.2, g = 0.8, b = 1 } },
    },
    portraitSpec = { actorID = "actor:notice:leader", faceOnly = true },
}
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
        ListTraderViews = function()
            return { leaderView, guardView }
        end,
        GetTraderView = function() return guardView end,
        GetTraderViewForActor = function(actorID)
            if actorID == leaderView.actorID then return leaderView end
            if actorID == guardView.actorID then return guardView end
            return nil
        end,
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
        actorID = leaderView.actorID,
        includeNext = true,
        persistent = true,
        id = "dt_nearby:trader:notice:1",
    }
)
T.equal(definition.actorID, leaderView.actorID,
    "shared notification lost the selected roster actor")
T.equal(definition.name, leaderView.name,
    "shared notification lost the selected actor name")
T.equal(definition.factionBadge.glyph, "N",
    "shared notification lost the faction badge")
T.equal(definition.portraitSpec.actorID, leaderView.actorID,
    "shared notification lost the circular portrait target")
T.truthy(definition.persistent,
    "proximity notification is not persistent")
T.truthy(definition.actions and definition.actions[1],
    "shared notification did not expose Talk")
definition.actions[1].callback()
T.equal(requested.args.actorID, leaderView.actorID,
    "notification Talk action lost the selected actor")
T.equal(definition.actions[2].id, "next",
    "nearby trader notification did not expose roster switching")
T.truthy(definition.actions[2].callback(),
    "nearby trader roster switch did not refresh the notification")
T.equal(shown.id, "dt_nearby:trader:notice:1",
    "roster switch changed the persistent nearby notification identity")
T.equal(shown.actorID, guardView.actorID,
    "roster switch did not select the next nearby actor")

T.truthy(Notification.Show(
    "trader:notice:1",
    "Trader arrived.",
    { id = "dt_spawn:trader:notice:1" }
), "shared notification did not publish through Core")
T.equal(shown.id, "dt_spawn:trader:notice:1",
    "shared notification changed the caller notification identity")

print("dt_shared_trader_notification_parity_smoke: PASS")
