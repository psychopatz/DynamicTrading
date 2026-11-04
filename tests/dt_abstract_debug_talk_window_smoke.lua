local T = require "tests/support/test"
T.addPackagePaths()

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
function ISPanel:addChild(child)
    self.children[#self.children + 1] = child
end
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
    }
    setmetatable(button, { __index = self })
    return button
end
function ISButton:initialise() end
function ISButton:instantiate() end

ISTextEntryBox = {}
function ISTextEntryBox:new(text, x, y, width, height)
    local entry = {
        text = text,
        x = x, y = y, width = width, height = height,
    }
    setmetatable(entry, { __index = self })
    return entry
end
function ISTextEntryBox:initialise() end
function ISTextEntryBox:instantiate() end
function ISTextEntryBox:getText() return self.text end
function ISTextEntryBox:setText(value) self.text = value end

package.preload["ISUI/ISPanel"] = function() return ISPanel end
package.preload["ISUI/ISButton"] = function() return ISButton end
package.preload["ISUI/ISTextEntryBox"] =
    function() return ISTextEntryBox end

local serverHandlers = {}
Events = {
    OnServerCommand = {
        Add = function(callback)
            serverHandlers[#serverHandlers + 1] = callback
        end,
    },
}

getCore = function()
    return {
        getScreenWidth = function() return 1280 end,
        getScreenHeight = function() return 720 end,
    }
end

local submitCall
local closeCall
DTCommon = {
    MOD_ID = "DynamicTrading",
    Client = {
        SubmitTalk = function(traderID, sessionID, text, mode)
            submitCall = {
                traderID = traderID,
                sessionID = sessionID,
                text = text,
                mode = mode,
            }
            return true, "request:1"
        end,
        CloseTalk = function(traderID, sessionID, mode)
            closeCall = {
                traderID = traderID,
                sessionID = sessionID,
                mode = mode,
            }
            return true
        end,
    },
}
DTAbstract = {}

local Manager = T.load(
    "DTAbstract",
    "client",
    "DTAbstract/UI/DTAbstract_DebugTalkWindow.lua"
)
local window = Manager.Open("trader:debug", "Debug Mara")
T.truthy(window, "debug Talk window opened")
T.equal(window.traderID, "trader:debug",
    "debug Talk window trader identity")
T.equal(window.displayName, "Debug Mara",
    "debug Talk display name")

for _, handler in ipairs(serverHandlers) do
    handler("DynamicTrading", "TalkResult", {
        accepted = true,
        traderID = "trader:debug",
        sessionID = "session:debug",
        mode = "radio",
        debugAccess = true,
        state = { turnCount = 0 },
    })
end
T.equal(window.sessionID, "session:debug",
    "debug Talk session result bound")
T.truthy(window.debugAccess,
    "debug Talk window records simulated access")

window.input:setText("hello from far away")
T.truthy(window:onButton(window.sendButton),
    "debug Talk send action rejected")
T.truthy(submitCall, "debug Talk did not use DTCommon SubmitTalk")
T.equal(submitCall.traderID, "trader:debug",
    "debug Talk submit trader")
T.equal(submitCall.sessionID, "session:debug",
    "debug Talk submit session")
T.equal(submitCall.text, "hello from far away",
    "debug Talk submit text")
T.equal(submitCall.mode, "radio",
    "debug Talk submit mode")
T.contains(window.history[#window.history],
    "hello from far away",
    "debug Talk did not show player utterance")

for _, handler in ipairs(serverHandlers) do
    handler("DynamicTrading", "TalkResult", {
        accepted = true,
        traderID = "trader:debug",
        sessionID = "session:debug",
        mode = "radio",
        debugAccess = true,
        state = { turnCount = 1 },
        result = {
            responses = {
                { text = "I can hear you from the debug harness." },
            },
        },
    })
end
T.contains(window.history[#window.history],
    "I can hear you",
    "debug Talk did not show trader response")

window:close()
T.truthy(closeCall, "debug Talk did not close server session")
T.equal(closeCall.traderID, "trader:debug",
    "debug Talk close trader")
T.falsy(Manager.instance,
    "debug Talk manager retained closed window")

T.finish("dt_abstract_debug_talk_window_smoke")
