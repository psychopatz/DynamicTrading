local T = require "tests/support/test"
T.addPackagePaths()

local registered
local opened
local talked
package.preload["PsychopatzCore/UI/Radio/OS/PsychopatzRadioOS"] = function()
    return {
        RegisterContactProvider = function(provider) registered = provider end,
        UnregisterContactProvider = function() end,
    }
end

DTCommon = {
    STATUS_READY = "READY",
    T = function(_, fallback) return fallback end,
    TraderService = {
        ForEach = function(callback)
            callback("trader:remote", {
                n = "Remote Mara", s = "READY", a = 1, p = "npc:mara",
            })
        end,
    },
    Client = {
        OpenTrader = function(id, options)
            opened = { id = id, options = options }
            return true
        end,
        RequestTalk = function(id, mode, options)
            talked = { id = id, mode = mode, options = options }
            return true
        end,
    },
}
DTAbstract = { Enabled = true }

local provider = dofile(T.repository
    .. "/Contents/mods/DTAbstract/42.20/media/lua/client/DTAbstract/"
    .. "DTAbstract_RadioOS.lua")
T.truthy(provider, "abstract provider registers")
local page = provider.list(provider, { offset = 0, limit = 12 })
T.equal(page.total, 1, "one authenticated abstract trader is listed")
T.truthy(page.contacts[1].capabilities.talk,
    "abstract contact advertises Talk")
T.equal(#page.contacts[1].actions, 2,
    "trade and Talk remain separate provider actions")

local accepted = provider.invoke(provider, "trader:remote",
    "dynamictrading:talk", page.contacts[1])
T.truthy(accepted, "abstract Talk delegates to DTCommon")
T.equal(talked.id, "trader:remote", "Talk keeps remote trader identity")
T.equal(talked.mode, "radio", "Talk identifies radio authority")

accepted = provider.invoke(provider, "trader:remote", "dynamictrading:trade")
T.truthy(accepted, "existing abstract trade remains available")
T.equal(opened.id, "trader:remote", "trade keeps trader identity")

T.finish("dt_radio_os_abstract_provider_smoke")
