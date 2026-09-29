DTCommon = DTCommon or {}

local ok, manager = pcall(require,
    "PsychopatzCore/Translation/PsychopatzCustomTranslationManager")
local handle

if ok and manager and type(manager.registerSystem) == "function" then
    handle = manager.registerSystem({
        modID = "DTCommon",
        systemName = "Trading",
        basePath = "media/translation",
    })
end

function DTCommon.T(key, fallback)
    if handle and type(handle.get) == "function" then
        return handle:get(key, fallback)
    end
    return fallback or key or ""
end

return DTCommon
