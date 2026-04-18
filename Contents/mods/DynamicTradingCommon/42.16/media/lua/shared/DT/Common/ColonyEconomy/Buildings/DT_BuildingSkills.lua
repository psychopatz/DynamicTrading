-- ==============================================================================
-- ColonyEconomy/Buildings/DT_BuildingSkills.lua
-- Logic: Deterministic skill derivation from identitySeed for NPCs.
-- ==============================================================================

local BuildingSkills = {}

--- Derives a deterministic proficiency rating from an NPC's identitySeed
function BuildingSkills.GetSkillProficiency(identitySeed, skillName)
    if not identitySeed then return 0.5 end
    
    local nameHash = 0
    if skillName then
        for i = 1, #skillName do
            nameHash = nameHash + string.byte(skillName, i)
        end
    end
    
    -- Deterministic hash combining seed and skill name string bytes
    local hash = (identitySeed * 31 + nameHash) % 100
    
    -- Normalize between 0.3 (terrible) and 1.2 (expert), yielding an average around 0.75
    local normalized = 0.3 + (hash / 100) * 0.9
    return normalized
end

function BuildingSkills.GetWorkerListProficiency(workerUUIDs, targetSkill)
    local totalProficiency = 0
    for _, uuid in ipairs(workerUUIDs or {}) do
        -- Try fetching from DT_Roster
        local soul = nil
        if DynamicTrading_Roster and DynamicTrading_Roster.GetSoulRegistry then
            soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
        end
        if soul then
            totalProficiency = totalProficiency + BuildingSkills.GetSkillProficiency(soul.identitySeed, targetSkill)
        else
            -- If unavailable, assume average baseline
            totalProficiency = totalProficiency + 0.75
        end
    end
    return totalProficiency
end

return BuildingSkills
