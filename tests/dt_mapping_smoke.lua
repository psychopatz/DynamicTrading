local T = require "tests/support/test"

local registered
DTCommon = {
    T = function(_, fallback) return fallback end,
    TraderService = {
        ForEach = function(callback)
            callback("dt_caravan_one", {
                p = "merchant_one",
                l = "merchant_one",
                m = { "merchant_one", "guard_one", "guard_two" },
            })
            callback("dt_caravan_two", {
                p = "merchant_two",
                l = "merchant_two",
                m = { "merchant_two", "guard_three", "guard_four" },
            })
        end,
    },
}
PNC = {
    ContextHub = {
        RegisterProvider = function(provider)
            registered = provider
        end,
    },
}

T.load("DTHoomans", "client", "DTHoomans/DTHoomans_Context.lua")

local Client = DTHoomans.Client
Client.RefreshTraderMap()
T.equal(Client.GetTraderID("merchant_one"), "dt_caravan_one",
    "merchant maps to its trader")
T.equal(Client.GetTraderID("guard_one"), nil,
    "guard has no context-menu trade mapping")
T.equal(Client.GetConversationTraderID("guard_one"), "dt_caravan_one",
    "guard maps to its caravan for conversation handoff")
T.equal(Client.GetTraderLeaderID("dt_caravan_one"), "merchant_one",
    "conversation map resolves the merchant leader")
T.truthy(registered and registered.isEnabled({ id = "merchant_one" }),
    "context provider enables the merchant")
T.falsy(registered.isEnabled({ id = "guard_one" }),
    "context provider stays disabled for guards")

local options = {}
local menu = {
    addOption = function(_, label, _, callback)
        options[#options + 1] = { label = label, callback = callback }
    end,
}
registered.addOptions(menu, { id = "merchant_one" })
T.equal(#options, 1, "merchant gets one context action")
options = {}
registered.addOptions(menu, { id = "guard_one" })
T.equal(#options, 0, "guard gets no Dynamic Trading context action")

Client.BindTrader("dt_caravan_three", "merchant_three", {
    "merchant_three", "guard_five", "guard_six",
})
T.equal(Client.GetConversationTraderID("guard_five"), "dt_caravan_three",
    "a repeated spawn binds a separate guard group")
T.equal(Client.GetTraderID("merchant_two"), "dt_caravan_two",
    "repeated spawns preserve prior merchant records")

T.finish("dt_mapping_smoke")
