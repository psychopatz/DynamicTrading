if isServer() then return end

DT_Reputation = DT_Reputation or {}
DT_Reputation.Internal = DT_Reputation.Internal or {}

local Internal = DT_Reputation.Internal

function Internal.GenerateCharacterKey(player)
    local desc = player and player:getDescriptor()
    local first = desc and desc:getForename() or "Survivor"
    local last = desc and desc:getSurname() or "Unknown"
    local username = (player and player.getUsername and player:getUsername()) or "local"
    local steamID = Internal.GetSafeSteamID(player)
    local mode = (isClient() and not isServer()) and "MP" or "SP"

    return table.concat({
        mode,
        Internal.SanitizeKey(username),
        Internal.SanitizeKey(steamID),
        Internal.SanitizeKey(first),
        Internal.SanitizeKey(last),
    }, "_")
end

function DT_Reputation.EnsureCharacterKey(player)
    if not player then return nil end

    local modData = player:getModData()
    if not modData then return nil end

    local keyName = DT_Reputation.CHARACTER_KEY_MODDATA
    local stableKey = Internal.GenerateCharacterKey(player)
    local oldKey = modData[keyName]

    if oldKey and oldKey ~= "" and oldKey ~= stableKey then
        local store = Internal.GetReputationStore(modData)
        if store and store[oldKey] and not store[stableKey] then
            store[stableKey] = store[oldKey]
            store[oldKey] = nil
            Internal.Log("Init", "Migrated reputation data from legacy key " .. tostring(oldKey) .. " to " .. tostring(stableKey))
        end
    end

    if oldKey ~= stableKey then
        modData[keyName] = stableKey
        Internal.Log("Init", "Assigned stable reputation character key: " .. tostring(modData[keyName]))
        if isClient() and player.transmitModData then
            player:transmitModData()
        end
    end

    return modData[keyName]
end
