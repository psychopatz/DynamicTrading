-- =============================================================================
-- 2. ARCHETYPE REGISTRY
-- =============================================================================
DynamicTrading.Archetypes = DynamicTrading.Archetypes or {}
DynamicTrading.ArchetypeLooks = DynamicTrading.ArchetypeLooks or {}

-- The Core Function: Preserves your ID schema
function DynamicTrading.RegisterArchetype(id, data)
    if not id then 
        DynamicTrading.Log("DTCommons", "Core", "Error", "Archetype registered without ID.")
        return 
    end
    if not data then return end
    
    -- Ensure the ID is inside the data table too, just in case, 
    -- but primarily use it as the Table Key for lookups.
    data.id = id 
    DynamicTrading.Archetypes[id] = data
    
    DynamicTrading.Log("DTCommons", "Core", "Info", "Registered Archetype: " .. id)
end
