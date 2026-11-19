DTCommon = DTCommon or {}

local ok, manager = pcall(require,
    "PsychopatzCore/Translation/PsychopatzCustomTranslationManager")
local handle
local convoHandle

if ok and manager and type(manager.registerSystem) == "function" then
    handle = manager.registerSystem({
        modID = "DTCommon",
        systemName = "Trading",
        basePath = "media/translation",
    })
    convoHandle = manager.registerSystem({
        modID = "DTCommon",
        systemName = "Conversation",
        basePath = "media/translation",
        manifestPath = "manifests/Conversation.json",
    })
end

function DTCommon.T(key, fallback)
    if handle and type(handle.get) == "function" then
        return handle:get(key, fallback)
    end
    return fallback or key or ""
end

function DTCommon.TConvo(key, fallback)
    if convoHandle and type(convoHandle.get) == "function" then
        return convoHandle:get(key, fallback)
    end
    return fallback or key or ""
end

return DTCommon
