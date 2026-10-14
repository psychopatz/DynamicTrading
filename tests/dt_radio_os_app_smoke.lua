local T = require "tests/support/test"

local app
local invoked
local providers = {
    { id = "dynamictrading:remote_traders" },
    { id = "dynamictrading:physical_traders" },
    { id = "projecthoomans:contacts" },
}

local OS = {
    RegisterApp = function(definition) app = definition end,
    UnregisterApp = function() end,
    ListContactProviders = function() return providers end,
    GetRegistryRevision = function() return 3 end,
    ListContacts = function(providerID)
        if providerID == "projecthoomans:contacts" then
            return true, { contacts = {
                { id = "npc:guard", title = "Guard", providerID = providerID,
                    actions = {} },
            } }
        end
        return true, { contacts = {
            { id = providerID .. ":one", title = "Trader One",
                providerID = providerID,
                actions = { { id = "dynamictrading:trade", label = "Trade" } } },
        } }
    end,
    InvokeContact = function(providerID, _, contactID, actionID)
        invoked = {
            providerID = providerID,
            contactID = contactID,
            actionID = actionID,
        }
        return true
    end,
}
package.preload["PsychopatzCore/UI/Radio/OS/PsychopatzRadioOS"] =
    function() return OS end

DTCommon = {
    T = function(_, fallback) return fallback end,
}

T.load("DTCommon", "client", "DTCommon/DTCommon_RadioOS.lua")
T.truthy(app, "DTCommon registers its Core app")
T.truthy(app.isAvailable({ active = true }),
    "scanner requires an active radio context")
T.falsy(app.isAvailable({ active = false }),
    "scanner is unavailable without an active radio")

local window = {
    customState = {},
    scale = 1,
    screenColors = function() return { r = 1, g = 1, b = 1, a = 1 } end,
    drawScreenHeader = function() end,
    drawTextClipped = function() end,
    drawRect = function() end,
}
local context = { active = true }
T.equal(app.open(context, window), "custom", "scanner opens a custom Core page")
T.equal(#window.customState.traderRows, 2,
    "scanner combines only namespaced trader providers")
app.render(context, window, { x = 0, y = 0, w = 256, h = 160 })
T.truthy(app.onSelect(context, window), "scanner delegates the selected trade")
T.equal(invoked.providerID, "dynamictrading:physical_traders",
    "selected row keeps its owning provider")
T.equal(invoked.actionID, "dynamictrading:trade",
    "selected row keeps its provider action")

T.finish("dt_radio_os_app_smoke")
