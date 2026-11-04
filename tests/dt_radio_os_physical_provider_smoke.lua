local T = require "tests/support/test"

local registered
local opened
local talked
local legacyTalkCalled = false
local player = {
    getX = function() return 100 end,
    getY = function() return 100 end,
}

package.preload["PsychopatzCore/UI/Radio/OS/PsychopatzRadioOS"] = function()
    return {
        UnregisterContactProvider = function() end,
        RegisterContactProvider = function(provider) registered = provider end,
    }
end

DTCommon = {
    STATUS_READY = "READY",
    T = function(_, fallback) return fallback end,
    TraderService = {
        ForEach = function(callback)
            callback("settlement_near", {
                n = "Near Settlement",
                s = "READY",
                a = 0,
                p = "merchant_near",
                g = "faction_near",
            })
            callback("settlement_far", {
                n = "Far Settlement",
                s = "READY",
                a = 0,
                p = "merchant_far",
                g = "faction_far",
            })
            callback("caravan_near", {
                n = "Remote Caravan",
                s = "READY",
                a = 1,
                p = "merchant_caravan",
                g = "faction_caravan",
            })
            callback("guard_binding", {
                n = "Guard Binding",
                s = "READY",
                a = 0,
                p = "guard_near",
                g = "faction_near",
            })
        end,
        GetRecord = function(id)
            if id == "settlement_near" then
                return { s = "READY", a = 0, p = "merchant_near",
                    g = "faction_near" }
            end
            return nil
        end,
    },
    Client = {
        OpenTrader = function(id, options)
            opened = { id = id, options = options }
            return true
        end,
        RequestTalk = function()
            legacyTalkCalled = true
            return false, "legacy_talk_must_not_run"
        end,
    },
}

local bodies = {
    merchant_near = {
        getX = function() return 103 end,
        getY = function() return 104 end,
        isDead = function() return false end,
    },
    merchant_far = {
        getX = function() return 200 end,
        getY = function() return 200 end,
        isDead = function() return false end,
    },
    merchant_caravan = {
        getX = function() return 101 end,
        getY = function() return 101 end,
        isDead = function() return false end,
    },
    guard_near = {
        getX = function() return 101 end,
        getY = function() return 101 end,
        isDead = function() return false end,
    },
}

PNC = {
    NPCSelection = {
        BuildEntry = function(body, record, snapshot)
            return {
                id = record.id,
                zombie = body,
                record = record,
                snapshot = snapshot,
            }
        end,
    },
    Conversation = {
        Open = function(entry, currentPlayer)
            talked = {
                entry = entry,
                player = currentPlayer,
            }
            return { entry = entry }
        end,
    },
    Registry = {
        GetLiveZombie = function(id) return bodies[id] end,
        Get = function(id)
            return {
                id = id,
                identitySeed = 7,
                presenceState = "live",
            }
        end,
    },
    Factions = {
        GetNPCAffiliation = function(id)
            if id == "guard_near" then
                return { role = "guard", factionID = "faction_near" }
            end
            if id == "merchant_caravan" then
                return { role = "trader", factionID = "faction_caravan" }
            end
            return { role = "trader", factionID = "faction_near" }
        end,
    },
    CharacterWindowShared = {
        BuildPortraitSpec = function(id)
            return { id = id, identitySeed = 7, preferDescriptor = true }
        end,
    },
}
DTHoomans = {
    Caravan = {
        ResolveTraderDisplayName = function(record)
            return record.n .. " Canonical"
        end,
    },
}
getSpecificPlayer = function() return player end

T.load("DTHoomans", "client", "DTHoomans/DTHoomans_RadioOS.lua")
T.truthy(registered, "physical provider registers with Core")
local page = registered.list(registered, { offset = 0, limit = 12 })
T.equal(page.total, 1, "only one nearby physical merchant is listed")
T.equal(page.contacts[1].id, "settlement_near",
    "abstract, far and guard bindings are excluded")
T.truthy(page.contacts[1].portraitDescriptor,
    "verified local merchant may provide a portrait descriptor")
T.equal(page.contacts[1].capabilities.npcID, "merchant_near",
    "contact retains the verified merchant target")

local accepted = registered.invoke(registered, "settlement_near",
    "dynamictrading:physical_trade")
T.truthy(accepted, "physical action delegates to V2 OpenTrader")
T.equal(opened.id, "settlement_near", "action keeps trader identity")
T.equal(opened.options.mode, "trade", "action uses existing trade mode")
T.equal(opened.options.npcID, "merchant_near",
    "action carries the verified nearby merchant")
local talkAccepted = registered.invoke(registered, "settlement_near",
    "dynamictrading:physical_talk")
T.truthy(talkAccepted, "physical Talk opens Hoomans conversation")
T.truthy(talked and talked.entry,
    "physical Talk did not reach PNC.Conversation.Open")
T.equal(talked.entry.id, "merchant_near",
    "Talk keeps canonical Hoomans NPC identity")
T.equal(talked.entry.zombie, bodies.merchant_near,
    "Talk carries the verified nearby Hoomans body")
T.equal(talked.player, player,
    "Talk carries the local player")
T.falsy(legacyTalkCalled,
    "physical RadioOS Talk must not invoke legacy DT TalkService")
T.falsy(registered.invoke(registered, "settlement_near", "bad_action"),
    "provider rejects unsupported actions")

T.finish("dt_radio_os_physical_provider_smoke")
