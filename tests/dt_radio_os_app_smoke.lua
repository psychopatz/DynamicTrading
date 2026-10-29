local T = require "tests/support/test"

local app
local invoked
local remoteCalls = 0
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
    ListContacts = function(providerID, _, page)
        if providerID == "projecthoomans:contacts" then
            return true, { contacts = {
                { id = "npc:guard", title = "Guard", providerID = providerID,
                    actions = {} },
            } }
        end
        if providerID == "dynamictrading:remote_traders" then
            remoteCalls = remoteCalls + 1
            if page and page.offset == 1 then
                return true, { contacts = {
                    { id = "remote:two", title = "Trader Two",
                        providerID = providerID,
                        actions = { { id = "dynamictrading:trade",
                            label = "Trade" } } },
                } }
            end
            return true, { contacts = {
                { id = "remote:one", title = "Trader One",
                    providerID = providerID,
                    marketEvents = {},
                    actions = { { id = "dynamictrading:trade",
                        label = "Trade" } } },
            }, nextOffset = 1 }
        end
        return true, { contacts = {
            { id = providerID .. ":one", title = "Trader One",
                providerID = providerID,
                marketEvents = providerID
                    == "dynamictrading:physical_traders" and {
                        {
                            eventType = "food_shortage",
                            headlineKey =
                                "DTCommon_MarketEvent_FoodShortage_Headline",
                        },
                    } or {},
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
    T = function(key, fallback)
        if key == "DTCommon_MarketEvent_FoodShortage_Headline" then
            return "FOOD SHORTAGE"
        end
        return fallback
    end,
}

T.load("DTCommon", "client", "DTCommon/DTCommon_RadioOS.lua")
T.truthy(app, "DTCommon registers its Core app")
T.truthy(app.isAvailable({ active = true }),
    "scanner requires an active radio context")
T.falsy(app.isAvailable({ active = false }),
    "scanner is unavailable without an active radio")

local windowHeader
local window = {
    customState = {},
    scale = 1,
    screenColors = function() return { r = 1, g = 1, b = 1, a = 1 } end,
    drawScreenHeader = function(_, title, status)
        windowHeader = { title = title, status = status }
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
T.equal(#window.customState.traderRows, 3,
    "scanner combines only namespaced trader providers")
T.equal(remoteCalls, 2, "scanner follows bounded provider pagination")
app.render(context, window, { x = 0, y = 0, w = 256, h = 160 })
T.contains(windowHeader.status, "MARKET NEWS: FOOD SHORTAGE",
    "Radio OS exposes grounded active market news")
window.customState.traderIndex = 3
app.render(context, window, { x = 0, y = 0, w = 256, h = 160 })
T.equal(windowHeader.status, "NO MARKET NEWS",
    "Radio OS reports truthful no-news for an unaffected trader")
window.customState.traderIndex = 1
local hit = app.hitTest(context, window, 12, 21)
T.truthy(hit and hit.index, "scanner row is directly clickable")
T.truthy(app.onScreenClick(context, window, hit),
    "scanner delegates a clicked trade row")
T.equal(invoked.providerID, "dynamictrading:physical_traders",
    "selected row keeps its owning provider")
T.equal(invoked.actionID, "dynamictrading:trade",
    "selected row keeps its provider action")

T.finish("dt_radio_os_app_smoke")
