return function(context)
    local Lifecycle = context.Lifecycle
    local BuildingInit = context.BuildingInit
    local MOD_DATA_KEY = context.MOD_DATA_KEY

    function Lifecycle.GenerateRoster(factionID)
        local data = ModData.get(MOD_DATA_KEY)
        local faction = data[factionID]
        if not faction then
            return
        end

        DynamicTrading_Roster.ClearSouls(factionID)

        local archetypes = {}
        for id, _ in pairs(DynamicTrading.Archetypes) do
            if not DynamicTrading.IsArchetypeAllowedForFaction
                or DynamicTrading.IsArchetypeAllowedForFaction(id, factionID) then
                table.insert(archetypes, id)
            end
        end

        if #archetypes == 0 then
            table.insert(archetypes, "General")
        end

        local requiredArchetypes = {}
        if DynamicTrading.GetRosterPoolEntriesForFaction then
            local rosterEntries = DynamicTrading.GetRosterPoolEntriesForFaction(factionID)
            for _, entry in ipairs(rosterEntries) do
                if DynamicTrading.Archetypes and DynamicTrading.Archetypes[entry.archetypeID] then
                    for _ = 1, entry.minCount do
                        table.insert(requiredArchetypes, entry.archetypeID)
                    end
                end
            end
        end

        if faction.factionType == "town" then
            for _ = 1, 2 do
                table.insert(requiredArchetypes, "Farmer")
            end
            for _ = 1, 2 do
                table.insert(requiredArchetypes, "Carpenter")
            end
        end

        local totalMembers = math.max(tonumber(faction.memberCount) or 0, #requiredArchetypes)
        if totalMembers < 1 then
            totalMembers = 1
        end
        faction.memberCount = totalMembers

        local home = faction.homeCoords
        local scatterRange = 10

        for i = 1, totalMembers do
            local randomArch = requiredArchetypes[i] or archetypes[ZombRand(#archetypes) + 1]
            local scatteredHome = nil
            if home and home.x then
                scatteredHome = {
                    x = home.x + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                    y = home.y + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                    z = home.z or 0
                }
            end

            DynamicTrading_Roster.AddSoul(factionID, randomArch, scatteredHome, { suppressRecruitLog = true })
        end

        BuildingInit.InitializeStarterBuildings(faction)
        ModData.transmit(MOD_DATA_KEY)
    end
end
