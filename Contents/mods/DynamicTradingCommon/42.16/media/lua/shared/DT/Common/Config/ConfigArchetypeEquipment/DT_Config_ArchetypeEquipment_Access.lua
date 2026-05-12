-- =============================================================================
-- ARCHETYPE EQUIPMENT: ACCESS
-- =============================================================================

DynamicTrading = DynamicTrading or {}
DynamicTrading.ArchetypeEquipment = DynamicTrading.ArchetypeEquipment or {}
DynamicTrading.ArchetypeEquipmentInternal = DynamicTrading.ArchetypeEquipmentInternal or {}

local internal = DynamicTrading.ArchetypeEquipmentInternal

function DynamicTrading.RegisterArchetypeEquipment(id, data)
    if not id then
        if DynamicTrading.Log then
            DynamicTrading.Log("DTCommons", "Core", "Error", "Archetype equipment registered without ID.")
        end
        return
    end

    local profile = DynamicTrading.BuildArchetypeEquipmentProfile(id, data)
    DynamicTrading.ArchetypeEquipment[id] = internal.deepCopy(profile)

    if DynamicTrading.Log then
        DynamicTrading.Log("DTCommons", "Core", "Info", "Registered Archetype Equipment: " .. tostring(id))
    end
end

function DynamicTrading.GetArchetypeEquipmentProfile(archetypeID)
    local id = tostring(archetypeID or "General")
    local registry = DynamicTrading.ArchetypeEquipment or {}
    local profile = registry[id]
    if profile then
        return internal.deepCopy(profile)
    end

    if id == "General" and registry.General then
        return internal.deepCopy(registry.General)
    end

    return DynamicTrading.BuildArchetypeEquipmentProfile(id, nil)
end
