local MOD_DATA_KEY = DynamicTrading_Roster.MOD_DATA_KEY

function DynamicTrading_Roster.RemoveSoul(factionID, count)
    local data = ModData.get(MOD_DATA_KEY)
    local members = data.FactionMembers[factionID]
    if not members or #members == 0 then return end

    count = count or 1
    for _ = 1, count do
        if #members > 0 then
            local idx = ZombRand(#members) + 1
            local uuid = table.remove(members, idx)
            local soul = data.Souls[uuid]
            data.Souls[uuid] = nil
            if ModData.remove then ModData.remove("DTSOUL_" .. uuid) end
        end
    end
end

function DynamicTrading_Roster.RemoveSpecificSoul(uuid)
    if not uuid then return false end

    local data = ModData.get(MOD_DATA_KEY)
    if not data or not data.Souls or not data.Souls[uuid] then
        return false
    end

    local factionID = data.Souls[uuid].factionID
    if factionID and data.FactionMembers and data.FactionMembers[factionID] then
        for index = #data.FactionMembers[factionID], 1, -1 do
            if data.FactionMembers[factionID][index] == uuid then
                table.remove(data.FactionMembers[factionID], index)
            end
        end
    end

    data.Souls[uuid] = nil
    if ModData.remove then ModData.remove("DTSOUL_" .. uuid) end
    return true
end

function DynamicTrading_Roster.ClearSouls(factionID)
    local data = ModData.get(MOD_DATA_KEY)
    local members = data.FactionMembers[factionID]
    if members then
        for _, uuid in ipairs(members) do
            data.Souls[uuid] = nil
            if ModData.remove then ModData.remove("DTSOUL_" .. uuid) end
        end
        data.FactionMembers[factionID] = nil
    end
end
