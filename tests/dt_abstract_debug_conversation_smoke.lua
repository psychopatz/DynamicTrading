local T = require "tests/support/test"
T.addPackagePaths()

local serverHandlers = {}
Events = {
    OnServerCommand = {
        Add = function(callback)
            serverHandlers[#serverHandlers + 1] = callback
        end,
    },
}

local currentPlayer = {
    getDisplayName = function() return "Tester" end,
}
getSpecificPlayer = function() return currentPlayer end
getPlayer = function() return currentPlayer end

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
            return true, "request:debug"
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
PsychopatzCore = {
    Conversation = {},
}

local capturedSpec
local appended = {}
local queued = {}
local refreshed = 0
local inputPart

PsychopatzConversationLLMInput = {
    new = function(_, x, y, width, height, options)
        local part = {
            x = x, y = y, width = width, height = height,
            options = options,
            refreshControls = function()
                refreshed = refreshed + 1
            end,
        }
        inputPart = part
        return part
    end,
}

package.preload[
    "PsychopatzCore/UI/Conversation/Parts/PsychopatzConversationLLMInput"
] = function()
    return PsychopatzConversationLLMInput
end

PsychopatzCore.Conversation.Open = function(spec)
    capturedSpec = spec
    local view = {
        spec = spec,
        extensionParts = {},
        session = {
            append = function(_, speaker, text, metadata)
                appended[#appended + 1] = {
                    speaker = speaker,
                    text = text,
                    metadata = metadata,
                }
            end,
            queueMessage = function(_, speaker, text, metadata)
                queued[#queued + 1] = {
                    speaker = speaker,
                    text = text,
                    metadata = metadata,
                }
            end,
        },
    }
    local definition = spec.extensionParts[1]
    view.extensionParts.llmInput = definition.factory(
        { x = 10, y = 20, width = 300, height = 100 },
        {
            owner = view,
            partID = definition.partID,
            definition = definition,
            spec = spec,
        }
    )
    function view:close(reason)
        self.closeReason = reason
        if self.spec.lifecycle and self.spec.lifecycle.finish then
            self.spec.lifecycle.finish(self, self.spec, nil, reason)
        end
    end
    return view
end

package.preload[
    "PsychopatzCore/UI/Conversation/PsychopatzConversation"
] = function()
    return PsychopatzCore.Conversation
end

local Manager = T.load(
    "DTAbstract",
    "client",
    "DTAbstract/UI/DTAbstract_DebugConversation.lua"
)

local view, reason = Manager.Open({
    traderID = "trader:abstract:1",
    actorID = "actor:dtabstract:1",
    displayName = "Abstract Trader 1",
    portrait = {
        gender = "female",
        face = {
            hairModel = "Long",
            beardModel = "",
        },
    },
})
T.truthy(view, reason)
T.truthy(capturedSpec, "Core conversation spec was not opened")
T.equal(capturedSpec.namespace, "DTAbstractDebugTalk",
    "debug Talk did not use the Core conversation namespace")
T.equal(capturedSpec.npcID, "actor:dtabstract:1",
    "debug Talk did not bind the Core actor identity")
T.equal(capturedSpec.npcName, "Abstract Trader 1",
    "debug Talk did not bind the trader display name")
T.equal(capturedSpec.choicePartVisible, false,
    "debug Talk should use the standard type-to-talk surface")
T.truthy(capturedSpec.extensionParts[1]
    and capturedSpec.extensionParts[1].partID == "llmInput",
    "debug Talk did not mount the Core LLM input part")
T.truthy(capturedSpec.portrait.isFemale,
    "debug Talk did not project portrait gender")
T.equal(capturedSpec.portrait.appearance.hairModel, "Long",
    "debug Talk did not project portrait appearance")

local state = inputPart.options.getState(view)
T.falsy(state.enabled,
    "input became enabled before the server debug session opened")

for _, callback in ipairs(serverHandlers) do
    callback("DynamicTrading", "TalkResult", {
        accepted = true,
        traderID = "trader:abstract:1",
        sessionID = "session:debug:1",
        mode = "radio",
        debugAccess = true,
    })
end
state = inputPart.options.getState(view)
T.truthy(state.enabled,
    "input did not enable after the debug Talk session opened")
T.contains(state.statusText, "proximity/radio",
    "debug access state was not visible in the standard input")

T.truthy(inputPart.options.submit(view, "hello trader", inputPart),
    "standard conversation input did not submit through DTCommon")
T.truthy(submitCall, "DTCommon SubmitTalk was not invoked")
T.equal(submitCall.traderID, "trader:abstract:1",
    "Talk submit lost trader identity")
T.equal(submitCall.sessionID, "session:debug:1",
    "Talk submit lost session identity")
T.equal(submitCall.text, "hello trader",
    "Talk submit lost player text")
T.equal(appended[#appended].speaker, "player",
    "player message was not appended to Core conversation history")
T.equal(appended[#appended].text, "hello trader",
    "Core conversation history lost player text")

for _, callback in ipairs(serverHandlers) do
    callback("DynamicTrading", "TalkResult", {
        accepted = true,
        traderID = "trader:abstract:1",
        sessionID = "session:debug:1",
        mode = "radio",
        debugAccess = true,
        result = {
            responses = {
                { text = "Hello from the road." },
            },
        },
    })
end
T.equal(queued[#queued].speaker, "npc",
    "trader response was not queued through Core conversation history")
T.equal(queued[#queued].text, "Hello from the road.",
    "Core conversation history lost trader response")
T.truthy(refreshed > 0,
    "standard conversation input state was not refreshed")

view:close("test_close")
T.truthy(closeCall, "closing the Core conversation did not close TalkService")
T.equal(closeCall.traderID, "trader:abstract:1",
    "Talk close lost trader identity")
T.equal(closeCall.sessionID, "session:debug:1",
    "Talk close lost session identity")

T.finish("dt_abstract_debug_conversation_smoke")
