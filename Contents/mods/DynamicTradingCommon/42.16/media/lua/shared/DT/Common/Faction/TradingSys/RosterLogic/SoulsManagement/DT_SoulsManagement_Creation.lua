local MOD_DATA_KEY = DynamicTrading_Roster.MOD_DATA_KEY

function DynamicTrading_Roster.AddSoul(factionID, archetypeID, homeCoords, options)
    local data = ModData.get(MOD_DATA_KEY)
    options = type(options) == "table" and options or {}

    if not options.forceFaction
        and DynamicTrading.IsArchetypeAllowedForFaction
        and not DynamicTrading.IsArchetypeAllowedForFaction(archetypeID, factionID) then
        local preferredFactionID = DynamicTrading.GetArchetypePreferredFaction
            and DynamicTrading.GetArchetypePreferredFaction(archetypeID) or nil
        if preferredFactionID then
            factionID = preferredFactionID
        end
    end

    if not homeCoords and factionID and factionID ~= "Independent" then
        if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
            local faction = DynamicTrading_Factions.GetFaction(factionID)
            if faction and faction.homeCoords and faction.homeCoords.x then
                local home = faction.homeCoords
                local scatterRange = 10
                homeCoords = {
                    x = home.x + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                    y = home.y + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                    z = home.z or 0,
                    zone = home.name or "Unknown"
                }
            end
        end
    end

    local npcData = nil
    if DTNPCGenerator and DTNPCGenerator.Generate then
        npcData = DTNPCGenerator.Generate({
            occupation = archetypeID or "General"
        })
    else
        local isFemale = (ZombRand(2) == 0)
        local name = "Unknown Trader"

        if SurvivorFactory then
            local survivor = SurvivorFactory.CreateSurvivor()
            if survivor then
                isFemale = survivor:isFemale()
                name = survivor:getForename() .. " " .. survivor:getSurname()
            end
        end

        local identitySeed = (DT_NPC_Wardrobe and DT_NPC_Wardrobe.RollIdentitySeed)
            and DT_NPC_Wardrobe.RollIdentitySeed() or (ZombRand(1000) + 1)

        npcData = {
            name = name,
            isFemale = isFemale,
            identitySeed = identitySeed,
            state = "Idle",
            tasks = {},
            visualID = ZombRand(1000000),
            archetypeID = archetypeID or "General",
        }
    end

    local name = npcData.name or "Unknown"
    local uuid = ""
    if DTNPCManager and DTNPCManager.GenerateSoulID then
        uuid = DTNPCManager.GenerateSoulID(name)
    else
        local sanitizedName = name:gsub("%s+", ""):gsub("[^%a%d]", "")
        local suffix = ""
        local hexChars = "0123456789abcdef"
        for _ = 1, 4 do
            local rand = ZombRand(1, 17)
            suffix = suffix .. hexChars:sub(rand, rand)
        end
        uuid = sanitizedName .. "_" .. suffix
    end

    npcData.uuid = uuid
    npcData.factionID = factionID
    npcData.archetypeID = archetypeID
    npcData.homeCoords = homeCoords or { x = 0, y = 0, z = 0 }
    npcData.workCoords = { x = 0, y = 0, z = 0 }
    npcData.status = "Resting"
    npcData.abstractResident = DynamicTrading_Roster.IsAbstractNomadFaction
        and DynamicTrading_Roster.IsAbstractNomadFaction(factionID) == true or false
    npcData.memory = {}
    if DynamicTrading and DynamicTrading.IsArchetypeNeverRecruitable and DynamicTrading.IsArchetypeNeverRecruitable(archetypeID or npcData) then
        npcData.canRecruit = false
        npcData.allowRecruit = false
        npcData.neverRecruitable = true
    end

    DynamicTrading_Roster.SaveSoul(uuid, npcData)

    if not data.FactionMembers[factionID] then
        data.FactionMembers[factionID] = {}
    end
    table.insert(data.FactionMembers[factionID], uuid)

    if not options.suppressRecruitLog then
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(factionID, DynamicTrading.GameplayEvents.RECRUITED, {npcData.name, archetypeID})
        end
    end

    return uuid
end
