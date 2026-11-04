local T = require "tests/support/test"
T.addPackagePaths()

local sent = {}
local player = { id = "player:one" }
getSpecificPlayer = function() return player end
sendClientCommand = function(current, module, command, payload)
    sent[#sent + 1] = {
        current = current,
        module = module,
        command = command,
        payload = payload,
    }
end
Events = { OnServerCommand = { Add = function() end } }

DTCommon = {
    MOD_ID = "DynamicTrading",
    TradePresentations = {},
}

local Client = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_Client.lua"
)

T.truthy(Client.RequestSnapshot("trader:transport", {
    mode = "physical",
    npcID = "npc:guard",
    actorID = "actor:guard",
}), "snapshot request was accepted")
T.equal(sent[1].payload.mode, "physical",
    "snapshot transport keeps the conversation access mode")
T.equal(sent[1].payload.npcID, "npc:guard",
    "snapshot transport keeps the contacted NPC")
T.equal(sent[1].payload.actorID, "actor:guard",
    "snapshot transport keeps the canonical actor")

print("dt_trade_transport_access_smoke: PASS")
