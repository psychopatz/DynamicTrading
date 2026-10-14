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
    drawScreenHeader = function()
        return { metrics = { x = 0, width = 240, lineHeight = 12 },
            contentY = 20 }
    end,
    headerLayout = function()
        return { metrics = { x = 0, width = 240, lineHeight = 12 },
            contentY = 20 }
    end,
    screenListLayout = function(_, count, _, selected, header)
        return { first = selected or 1, visible = math.min(count, 2),
            rowHeight = 13, x = 0, y = header.contentY, width = 240,
            metrics = { scale = 1 } }
    end,
    screenRowRect = function(_, layout, offset)
        return { x = layout.x, y = layout.y + offset * layout.rowHeight,
            w = layout.width, h = 12 }
    end,
    isInside = function(_, rect, x, y)
        return x >= rect.x and x <= rect.x + rect.w
            and y >= rect.y and y <= rect.y + rect.h
    end,
    drawSprite = function() end,
    drawTextClipped = function() end,
    drawRect = function() end,
}
local context = { active = true }
T.equal(app.open(context, window), "custom", "scanner opens a custom Core page")
T.equal(#window.customState.traderRows, 2,
    "scanner combines only namespaced trader providers")
app.render(context, window, { x = 0, y = 0, w = 256, h = 160 })
local hit = app.hitTest(context, window, 12, 21)
T.truthy(hit and hit.index, "scanner row is directly clickable")
T.truthy(app.onScreenClick(context, window, hit),
    "scanner delegates a clicked trade row")
T.equal(invoked.providerID, "dynamictrading:physical_traders",
    "selected row keeps its owning provider")
T.equal(invoked.actionID, "dynamictrading:trade",
    "selected row keeps its provider action")

T.finish("dt_radio_os_app_smoke")
