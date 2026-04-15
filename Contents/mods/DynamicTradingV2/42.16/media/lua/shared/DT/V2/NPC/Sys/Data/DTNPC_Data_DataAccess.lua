-- ==============================================================================
-- DTNPC_Data_DataAccess.lua
-- Data attachment, retrieval, and backward-compatible accessors.
-- ==============================================================================

DTNPC = DTNPC or {}

function DTNPC.GetData(zombie)
    if not zombie then return nil end

    local modData = zombie:getModData()
    if not modData then return nil end

    -- Backward Compatibility: Migrate old "DTNPCBrain" to "DTNPC_Data"
    if modData.DTNPCBrain and not modData.DTNPC_Data then
        modData.DTNPC_Data = modData.DTNPCBrain
        modData.DTNPCBrain = nil
    end

    if modData.DTNPC_Data and DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(modData.DTNPC_Data)
    end

    return modData.DTNPC_Data
end

-- Deprecated: Use DTNPC.GetData
function DTNPC.GetBrain(zombie)
    return DTNPC.GetData(zombie)
end

function DTNPC.AttachData(zombie, npcData)
    if not zombie or not npcData then return end

    local modData = zombie:getModData()
    if not modData then return end

    if DTNPCProtect and DTNPCProtect.EnsureDataDefaults then
        DTNPCProtect.EnsureDataDefaults(npcData)
    end
    if DTNPCProtect and DTNPCProtect.AssignRandomWorldLoadout then
        DTNPCProtect.AssignRandomWorldLoadout(npcData)
    end

    modData.DTNPC_Data = npcData
    modData.IsDTNPC = true
end

-- Deprecated: Use DTNPC.AttachData
function DTNPC.AttachBrain(zombie, npcData)
    DTNPC.AttachData(zombie, npcData)
end

function DTNPC.IsNPC(zombie)
    if not zombie then return false end

    local modData = zombie:getModData()
    return modData and modData.IsDTNPC == true
end
