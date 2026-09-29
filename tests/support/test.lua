local Test = {}

local repository = os.getenv("PZ_TEST_REPOSITORY") or "."
local config = dofile(repository .. "/tests/test_config.lua")
local dynamicRuntime = os.getenv("PZ_TEST_DYNAMIC_RUNTIME")
    or config.dynamicTradingRuntime
local hoomansRuntime = os.getenv("PZ_TEST_HOOMANS_RUNTIME")
    or config.projectHoomansRuntime
local coreRuntime = os.getenv("PZ_TEST_CORE_RUNTIME")
    or config.psychopatzCoreRuntime
local hoomansRepository = os.getenv("PZ_TEST_HOOMANS_REPOSITORY")
    or config.projectHoomansRepository
local coreRepository = os.getenv("PZ_TEST_CORE_REPOSITORY")
    or config.psychopatzCoreRepository

local roots = {
    DTCommon = repository .. "/Contents/mods/DTCommon/"
        .. dynamicRuntime .. "/media/lua/",
    DTHoomans = repository .. "/Contents/mods/DTHoomans/"
        .. dynamicRuntime .. "/media/lua/",
    ProjectHoomans = hoomansRepository .. "/Contents/mods/ProjectHoomans/"
        .. hoomansRuntime .. "/media/lua/",
    PsychopatzCore = coreRepository .. "/Contents/mods/PsychopatzCore/"
        .. coreRuntime .. "/media/lua/",
}

local function cleanRelative(path)
    path = tostring(path or "")
    assert(string.sub(path, 1, 1) ~= "/", "test path must be relative")
    assert(not string.find(path, "..", 1, true),
        "test path cannot traverse parents")
    return path
end

function Test.path(mod, layer, relative)
    relative = cleanRelative(relative)
    if mod == "DTCommon" or mod == "DTHoomans" then
        return roots[mod] .. tostring(layer or "shared") .. "/" .. relative
    end
    if mod == "ProjectHoomans" or mod == "PsychopatzCore" then
        return roots[mod] .. tostring(layer or "shared") .. "/" .. relative
    end
    error("unknown test mod: " .. tostring(mod))
end

function Test.addPackagePaths(specifications)
    specifications = specifications or {
        { "DTHoomans", "client" },
        { "DTHoomans", "server" },
        { "DTHoomans", "shared" },
        { "DTCommon", "client" },
        { "DTCommon", "server" },
        { "DTCommon", "shared" },
    }
    local paths = {
        repository .. "/?.lua",
        repository .. "/?/init.lua",
    }
    for _, specification in ipairs(specifications) do
        paths[#paths + 1] = Test.path(
            specification[1], specification[2], "?.lua")
    end
    paths[#paths + 1] = package.path
    package.path = table.concat(paths, ";")
    return package.path
end

function Test.load(mod, layer, relative)
    Test.addPackagePaths()
    if relative == nil then return dofile(mod) end
    return dofile(Test.path(mod, layer, relative))
end

function Test.read(mod, layer, relative)
    local path = relative == nil and mod or Test.path(mod, layer, relative)
    local handle = assert(io.open(path, "rb"), "cannot open test source: " .. path)
    local source = handle:read("*a")
    handle:close()
    return source
end

function Test.equal(actual, expected, label)
    if actual ~= expected then
        error((label or "equal") .. ": expected=" .. tostring(expected)
            .. " actual=" .. tostring(actual), 2)
    end
end

function Test.truthy(value, label)
    if not value then
        error((label or "truthy") .. ": expected truthy value", 2)
    end
    return value
end

function Test.falsy(value, label)
    if value then
        error((label or "falsy") .. ": expected falsy value", 2)
    end
end

function Test.contains(value, fragment, label)
    if not string.find(tostring(value or ""), tostring(fragment or ""), 1, true) then
        error((label or "contains") .. ": missing=" .. tostring(fragment), 2)
    end
end

function Test.finish(name)
    if os.getenv("PZ_TEST_VERBOSE") == "1" then
        print(tostring(name or "test") .. ": ok")
    end
    return true
end

Test.repository = repository
Test.runtime = {
    DynamicTrading = dynamicRuntime,
    ProjectHoomans = hoomansRuntime,
    PsychopatzCore = coreRuntime,
}

return Test
