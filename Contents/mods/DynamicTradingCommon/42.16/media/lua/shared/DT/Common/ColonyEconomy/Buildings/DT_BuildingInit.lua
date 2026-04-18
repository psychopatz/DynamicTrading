-- ==============================================================================
-- ColonyEconomy/Buildings/DT_BuildingInit.lua
-- Logic: Auto-assign starter buildings based on initial NPC composition.
-- ==============================================================================

local BuildingDefs = require "DT/Common/ColonyEconomy/Buildings/DT_BuildingDefs"

local BuildingInit = {}

--- Auto-builds the infrastructure for a newly generated faction
-- @param faction table The new faction data model
function BuildingInit.InitializeStarterBuildings(faction)
    if not faction or not faction.buildings then return end

    -- Fetch the initial roster
    local souls = {}
    if DynamicTrading_Roster and DynamicTrading_Roster.GetSouls then
        local uuids = DynamicTrading_Roster.GetSouls(faction.id)
        for _, uuid in ipairs(uuids or {}) do
            local soul = DynamicTrading_Roster.GetSoulRegistry(uuid)
            if soul then
                table.insert(souls, soul)
            end
        end
    end

    -- Identify available archetypes
    local archetypeMap = {}
    for _, soul in ipairs(souls) do
        local arch = soul.archetypeID or "General"
        archetypeMap[arch] = archetypeMap[arch] or {}
        table.insert(archetypeMap[arch], soul.uuid)
    end

    -- Headquarters is always provided
    faction.buildings["Headquarters"] = {
        level = 1,
        constructionDaysLeft = 0,
        hp = BuildingDefs.Headquarters.baseHp,
        maxHp = BuildingDefs.Headquarters.baseHp,
        workers = {}
    }
    
    -- Assign up to `capacity` workers from the available pool for a given archetype
    local function assignWorkers(buildingClass, bDef)
        local archType = bDef.archetype
        if not archType then return {} end
        
        local assigned = {}
        if archetypeMap[archType] and #archetypeMap[archType] > 0 then
            local limit = bDef.capacity or 1
            for i = 1, math.min(limit, #archetypeMap[archType]) do
                table.insert(assigned, archetypeMap[archType][i])
            end
        end
        return assigned
    end

    -- Build structures corresponding to available assigned archetypes
    for bName, bDef in pairs(BuildingDefs) do
        if bName ~= "Headquarters" then
            if bDef.archetype and archetypeMap[bDef.archetype] and #archetypeMap[bDef.archetype] > 0 then
                -- Pre-build to level 1 since they have the required personnel
                local assigned = assignWorkers(bName, bDef)
                faction.buildings[bName] = {
                    level = 1,
                    constructionDaysLeft = 0,
                    hp = bDef.baseHp,
                    maxHp = bDef.baseHp,
                    workers = assigned
                }
            end
        end
    end
end

return BuildingInit
