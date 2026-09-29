DTCommon = DTCommon or {}

local Storage = DTCommon.Storage or {}
DTCommon.Storage = Storage

local Inventory = require "PsychopatzCore/Inventory/PsychopatzInventory"
local fallbackData

local function authority()
    local runtime = PsychopatzCore and PsychopatzCore.RuntimeRole
    if runtime and type(runtime.AllowsServerCode) == "function" then
        return runtime.AllowsServerCode() == true
    end
    return not (isClient and isClient() == true)
end

local function normalize(data)
    if type(data) ~= "table" then data = {} end
    data.v = tonumber(data.v) or 1
    data.r = math.max(0, math.floor(tonumber(data.r) or 0))
    data.t = type(data.t) == "table" and data.t or {}
    return data
end

function Storage.IsAuthority()
    return authority()
end

function Storage.GetData()
    local data
    if ModData and type(ModData.getOrCreate) == "function" then
        data = ModData.getOrCreate(DTCommon.MODDATA_KEY)
    else
        fallbackData = fallbackData or {}
        data = fallbackData
    end
    return normalize(data)
end

function Storage.Touch()
    local data = Storage.GetData()
    data.r = data.r + 1
    return data.r
end

function Storage.Transmit()
    if not authority() then return false end
    if ModData and type(ModData.transmit) == "function" then
        ModData.transmit(DTCommon.MODDATA_KEY)
    end
    return true
end

-- Trader stock is persisted through PsychopatzCore's compact virtual-inventory
-- envelope. ModData contains dense numeric item records instead of repeated
-- full type strings, definitions, or live Java-backed inventory objects.
function Storage.LoadInventory(record)
    record = type(record) == "table" and record or {}
    if type(record.i) ~= "table" then
        return Inventory.createVirtualInventory({
            authority = "server",
            maxWeight = 500,
        })
    end
    return Inventory.Serializer.deserialize(record.i, {
        authority = "server",
        maxWeight = 500,
    })
end

function Storage.SaveInventory(record, store)
    if type(record) ~= "table" or not store then
        return false, "inventory_record_required"
    end
    local payload, reason = Inventory.Serializer.serialize(store)
    if not payload then return false, reason end
    record.i = payload
    return true
end

function Storage.Initialize()
    local data = Storage.GetData()
    if authority() then Storage.Transmit() end
    return data
end

if Events and Events.OnInitGlobalModData
    and type(Events.OnInitGlobalModData.Add) == "function"
then
    Events.OnInitGlobalModData.Add(Storage.Initialize)
end

return Storage
