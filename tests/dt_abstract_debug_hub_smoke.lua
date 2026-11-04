local T = require "tests/support/test"
T.addPackagePaths()

-- Minimal native UI surface for production Debug Manager construction.
ISPanel = {}
function ISPanel:derive()
    local child = {}
    setmetatable(child, { __index = self })
    child.__index = child
    return child
end
function ISPanel:new(x, y, width, height)
    local panel = {
        x = x, y = y, width = width, height = height,
        children = {}, visible = true,
    }
    setmetatable(panel, { __index = self })
    return panel
end
function ISPanel:initialise() end
function ISPanel:createChildren() end
function ISPanel:instantiate() self:createChildren() end
function ISPanel:addChild(child) self.children[#self.children + 1] = child end
function ISPanel:addToUIManager() end
function ISPanel:removeFromUIManager() end
function ISPanel:bringToTop() end
function ISPanel:setVisible(value) self.visible = value end
function ISPanel:drawRect() end
function ISPanel:drawRectBorder() end
function ISPanel:drawText() end
function ISPanel:prerender() end

ISButton = {}
function ISButton:new(x, y, width, height, title, target, onclick)
    local button = {
        x = x, y = y, width = width, height = height,
        title = title, target = target, onclick = onclick,
        visible = true, enable = true,
    }
    setmetatable(button, { __index = self })
    return button
end
function ISButton:initialise() end
function ISButton:instantiate() end
function ISButton:setY(v) self.y = v end
function ISButton:setVisible(v) self.visible = v end
function ISButton:setTitle(v) self.title = v end
function ISButton:setEnable(v) self.enable = v end

package.preload["ISUI/ISPanel"] = function() return ISPanel end
package.preload["ISUI/ISButton"] = function() return ISButton end

local shownMap = nil
ISWorldMap = {
    ShowWorldMap = function(playerNum, x, y, zoom)
        shownMap = { playerNum = playerNum, x = x, y = y, zoom = zoom }
    end,
}
package.preload["ISUI/Maps/ISWorldMap"] = function() return ISWorldMap end

local debugTalkOpened
package.preload["DTAbstract/UI/DTAbstract_DebugTalkWindow"] = function()
    return {
        Open = function(traderID, displayName)
            debugTalkOpened = {
                traderID = traderID,
                displayName = displayName,
            }
            return { status = "opening" }
        end,
    }
end

local serverHandlers = {}
Events = {
    OnServerCommand = {
        Add = function(callback) serverHandlers[#serverHandlers + 1] = callback end,
    },
    OnGameStart = { Add = function() end },
    OnCreatePlayer = { Add = function() end },
}

local player = {
    getX = function() return 100 end,
    getY = function() return 200 end,
    getZ = function() return 0 end,
}
getSpecificPlayer = function() return player end
getPlayer = function() return player end
getCore = function()
    return {
        getScreenWidth = function() return 1280 end,
        getScreenHeight = function() return 720 end,
    }
end

local commands = {}
sendClientCommand = function(current, module, command, args)
    commands[#commands + 1] = {
        player = current, module = module, command = command, args = args or {},
    }
end

local Actors = require "PsychopatzCore/Actors/PsychopatzActors"
local Projection = Actors.Projection
local authority = Actors.NewRegistry()
local clientStore = Projection.NewStore()
Projection.ClientStore = clientStore

local registeredTools = {}
local notices = {}
PsychopatzCore = PsychopatzCore or {}
PsychopatzCore.Actors = Actors
PsychopatzCore.Debug = { CanUse = function() return true end }
PsychopatzCore.DebugHub = {
    RegisterTool = function(tool)
        registeredTools[tool.id] = tool
        return true
    end,
}
PsychopatzCore.Notifications = {
    Show = function(definition)
        notices[#notices + 1] = definition
        return true
    end,
}
package.preload["PsychopatzCore/00_PsychopatzCore_Init"] =
    function() return PsychopatzCore end

DTCommon = DTCommon or {}
local traderStore = { t = {} }
local Policy = T.load(
    "DTCommon", "shared", "DTCommon/DTCommon_CoreActorPolicy.lua")
DTCommon.TraderService = {
    ForEach = function(callback)
        for id, record in pairs(traderStore.t) do callback(id, record) end
    end,
    GetRecord = function(id) return traderStore.t[id] end,
}

local actor = assert(authority:Create({
    actorId = "actor:debug:1",
    identitySeed = "debug-seed",
    world = { position = { x = 100, y = 200, z = 0 } },
}))
local acquired = assert(Actors.Provider.Acquire(actor, {
    provider = "DTAbstract",
    owner = "test",
    authority = "server",
    now = 0,
}))
assert(authority:Commit(
    actor.actorId, { providerLease = acquired.providerLease }, actor.revision))

local entry = assert(Projection.ProjectActor(
    authority:Get(actor.actorId), 0, {
        sourceID = "DTAbstract",
        provider = "DTAbstract",
        providerState = "abstract",
    }))
assert(clientStore:ApplySnapshot({
    schema = Projection.SCHEMA,
    schemaVersion = Projection.SCHEMA_VERSION,
    sourceID = "DTAbstract",
    snapshotRevision = 1,
    entries = { entry },
}))

traderStore.t["trader:debug:1"] = {
    n = "Inspected Trader",
    s = "READY",
    b = 750,
    v = 2,
    ca = Policy.New({
        actorID = actor.actorId,
        provider = "DTAbstract",
        providerState = "abstract",
        homeSettlementID = "settlement:muldraugh",
        currentSettlementID = "settlement:muldraugh",
    }),
}

DTAbstract = {}
local DebugHub = T.load(
    "DTAbstract", "client", "DTAbstract/UI/DTAbstract_DebugHub.lua")
T.truthy(DebugHub, "DebugHub loaded")

local tool = registeredTools["dtabstract:traders"]
T.truthy(tool, "Abstract Trader Manager registered")
T.truthy(tool.available(), "debug tool unavailable")

-- Registration must open a real production manager window.
local window = tool.action()
T.truthy(window, "Debug Hub action did not return manager window")
T.truthy(DTAbstract.DebugTraderWindow.instance == window,
    "manager instance was not retained")
T.truthy(window.refreshButton and window.spawnNearButton
    and window.spawnAtButton and window.tickButton,
    "manager controls were not constructed")
T.truthy(window.rows and window.rows[1] and window.rows[1].talk,
    "manager row did not construct the debug Talk button")

local list = DebugHub.ListTraders()
T.equal(#list, 1, "one synchronized trader listed")
T.equal(list[1].actorID, "actor:debug:1", "actor ID mismatch")
T.equal(list[1].position.x, 100, "client projection X mismatch")
T.equal(list[1].provider, "DTAbstract", "provider mismatch")

local located, locatedPos = DebugHub.LocateOnMap("trader:debug:1")
T.truthy(located and locatedPos, "Locate on Map failed")
T.truthy(shownMap, "Locate on Map did not open production map API")
T.equal(shownMap.x, 100, "Locate on Map did not center X")
T.equal(shownMap.y, 200, "Locate on Map did not center Y")

commands = {}
T.truthy(DebugHub.SpawnNear({ displayName = "Near" }))
T.equal(commands[1].player, player, "debug command omitted local player")
T.equal(commands[1].module, "DTAbstract", "wrong module")
T.equal(commands[1].command, "SpawnAbstractTraderNearPlayer",
    "wrong spawn-near command")

commands = {}
T.truthy(DebugHub.SpawnAt(321, 654, 0))
T.equal(commands[1].command, "SpawnAbstractTraderAtPosition",
    "SpawnAt still routed through near-player command")
T.equal(commands[1].args.position.x, 321, "SpawnAt X lost")
T.equal(commands[1].args.position.y, 654, "SpawnAt Y lost")

commands = {}
T.truthy(DebugHub.OpenDebugTalk("trader:debug:1"),
    "debug Talk action was rejected")
T.truthy(debugTalkOpened
    and debugTalkOpened.traderID == "trader:debug:1",
    "debug Talk window did not open for the selected trader")
T.equal(debugTalkOpened.displayName, "Inspected Trader",
    "debug Talk window did not receive the trader display name")
T.equal(commands[1].module, "DTAbstract",
    "debug Talk used the wrong command module")
T.equal(commands[1].command, "DebugTalkOpen",
    "debug Talk did not request the server-authorized session")
T.equal(commands[1].args.traderID, "trader:debug:1",
    "debug Talk command lost trader identity")

-- Server result must be received and presented distinctly from gameplay notice.
for _, callback in ipairs(serverHandlers) do
    callback("DTAbstract", "TraderDebugActionResult", {
        accepted = true,
        action = "spawn_at",
        reason = "spawned",
        traderID = "trader:debug:2",
    })
end
T.truthy(DebugHub.LastResult
    and DebugHub.LastResult.action == "spawn_at",
    "debug result receiver did not run")
T.contains(window.notice, "spawn_at", "manager did not show action result")
T.truthy(#notices >= 1
    and notices[#notices].title == "DTAbstract Debug",
    "debug result was not presented through debug feedback")

window:close()
T.falsy(DTAbstract.DebugTraderWindow.instance,
    "manager did not close cleanly")

T.finish("dt_abstract_debug_hub_smoke")
