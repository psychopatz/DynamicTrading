DT_Buildings = DT_Buildings or {}
DT_Buildings.Internal = DT_Buildings.Internal or {}

local Config = DT_Buildings.Config
local Buildings = DT_Buildings
local Internal = Buildings.Internal

local function copyDeep(value)
    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for key, entry in pairs(value) do
        copy[key] = copyDeep(entry)
    end
    return copy
end

local function ensureArray(value)
    return type(value) == "table" and value or {}
end

Internal.CopyDeep = copyDeep
Internal.EnsureArray = ensureArray

function Buildings.Init()
    if not ModData.exists(Config.MOD_DATA_KEY) then
        ModData.add(Config.MOD_DATA_KEY, {
            Owners = {},
            Counters = { building = 0, project = 0 }
        })
    end

    local data = ModData.get(Config.MOD_DATA_KEY)
    data.Owners = data.Owners or {}
    data.Counters = data.Counters or { building = 0, project = 0 }
end

Events.OnInitGlobalModData.Add(Buildings.Init)

function Buildings.GetData()
    if not ModData.exists(Config.MOD_DATA_KEY) then
        Buildings.Init()
    end
    return ModData.get(Config.MOD_DATA_KEY)
end

function Buildings.Save()
    if GlobalModData and GlobalModData.save then
        GlobalModData.save()
    end
end

function Buildings.NextID(kind)
    local data = Buildings.GetData()
    local key = kind == "building" and "building" or "project"
    data.Counters[key] = (data.Counters[key] or 0) + 1
    return data.Counters[key]
end

function Buildings.EnsureOwner(ownerUsername)
    local owner = DT_Labour and DT_Labour.Config and DT_Labour.Config.GetOwnerUsername
        and DT_Labour.Config.GetOwnerUsername(ownerUsername)
        or tostring(ownerUsername or "local")
    local data = Buildings.GetData()
    if not data.Owners[owner] then
        data.Owners[owner] = {
            buildings = {},
            projects = {}
        }
    end

    local ownerData = data.Owners[owner]
    ownerData.buildings = ensureArray(ownerData.buildings)
    ownerData.projects = type(ownerData.projects) == "table" and ownerData.projects or {}
    return ownerData
end

function Buildings.GetBuildingsForOwner(ownerUsername)
    return Buildings.EnsureOwner(ownerUsername).buildings
end

function Buildings.GetProjectsForOwner(ownerUsername)
    return Buildings.EnsureOwner(ownerUsername).projects
end

function Buildings.CreateBuildingInstance(ownerUsername, buildingType, level)
    local ownerData = Buildings.EnsureOwner(ownerUsername)
    local instance = {
        buildingID = "building_" .. tostring(Buildings.NextID("building")),
        buildingType = tostring(buildingType or ""),
        level = math.max(0, math.floor(tonumber(level) or 0))
    }
    ownerData.buildings[#ownerData.buildings + 1] = instance
    return instance
end

function Buildings.FindBuildingForOwner(ownerUsername, buildingID)
    for _, instance in ipairs(Buildings.GetBuildingsForOwner(ownerUsername)) do
        if instance.buildingID == buildingID then
            return instance
        end
    end
    return nil
end

function Buildings.CopyOwnerData(ownerUsername)
    return copyDeep(Buildings.EnsureOwner(ownerUsername))
end

return Buildings
