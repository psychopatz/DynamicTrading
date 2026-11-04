local T = require "tests/support/test"
T.addPackagePaths()

local commands = {}
local player = {}
getSpecificPlayer = function() return player end
sendClientCommand = function(current, module, command, args)
    commands[#commands + 1] = {
        player = current, module = module, command = command, args = args,
    }
end

local rows = {
    {
        traderID = "trader:manager:one",
        actorID = "actor:manager:one",
        provider = "DTAbstract",
        displayName = "Abstract Trader",
        position = { x = 10, y = 20, z = 0 },
    },
    {
        traderID = "trader:manager:two",
        actorID = "actor:manager:two",
        provider = "DTHoomans",
        displayName = "Physical Trader",
        position = { x = 30, y = 40, z = 0 },
    },
    {
        traderID = "trader:manager:one",
        actorID = "actor:manager:guard",
        provider = "DTAbstract",
        displayName = "Abstract Guard",
        talkAvailable = true,
        tradeAvailable = false,
        position = { x = 11, y = 21, z = 0 },
    },
}

DTCommon = {
    TraderPresentation = {
        ListTraderViews = function() return rows end,
    },
}
local tools = {}
PsychopatzCore = {
    Debug = { CanUse = function() return true end },
    DebugHub = {
        RegisterTool = function(definition)
            tools[definition.id] = definition
            return true
        end,
    },
}

local calls = {}
local Manager = T.load(
    "DTCommon",
    "client",
    "DTCommon/DTCommon_TraderManager.lua"
)
T.truthy(Manager, "shared trader manager did not load")
T.truthy(tools["dtcommon.traderManager"],
    "shared trader manager did not register one Core Debug Hub tool")
T.equal(#Manager.ListTraders(true), 3,
    "shared trader manager did not use one model for both providers")

Manager.RegisterProvider("DTAbstract", {
    action = function(action, row)
        calls[#calls + 1] = { action = action, row = row }
        return true
    end,
})
Manager.RegisterProvider("DTHoomans", {
    action = function(action, row)
        calls[#calls + 1] = { action = action, row = row }
        return true
    end,
})

T.truthy(Manager.Action("talk", "trader:manager:one"),
    "shared manager did not dispatch abstract Talk")
T.truthy(Manager.Action("talk", "trader:manager:two"),
    "shared manager did not dispatch physical Talk")
T.equal(calls[1].row.actorID, "actor:manager:one",
    "abstract manager action lost actor identity")
T.equal(calls[2].row.actorID, "actor:manager:two",
    "physical manager action lost actor identity")

T.truthy(Manager.Request("talk", "trader:manager:one", {
    actorID = "actor:manager:guard",
}), "shared manager did not dispatch guard Talk")
T.equal(calls[3].row.actorID, "actor:manager:guard",
    "shared manager Talk collapsed a guard onto the trader leader")

print("dt_shared_trader_manager_smoke: PASS")
