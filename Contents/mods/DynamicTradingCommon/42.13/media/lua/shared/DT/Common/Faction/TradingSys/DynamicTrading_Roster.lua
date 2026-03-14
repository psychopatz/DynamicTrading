-- Try to load DTNPCGenerator (V2 only) — graceful fallback if V2 not present
local hasGenerator = pcall(require, "DT/V2/NPC/Sys/DTNPC_Generator")

DynamicTrading_Roster = {}
local MOD_DATA_KEY = "DynamicTrading_Roster"

local function stripMovementSpeed(npcData)
    if type(npcData) ~= "table" then return npcData end
    npcData.walkSpeed = nil
    npcData.runSpeed = nil
    return npcData
end

-- ==========================================================
-- 1. INITIALIZATION
-- ==========================================================
function DynamicTrading_Roster.Init()
    if not ModData.exists(MOD_DATA_KEY) then
        ModData.add(MOD_DATA_KEY, {
            Traders = {},       -- Existing physical traders/radio traders
            Souls = {},        -- Persistent identities: [uuid] = soulData
            FactionMembers = {} -- Index: [factionID] = { uuid1, uuid2, ... }
        })
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
    end
    
    local data = ModData.get(MOD_DATA_KEY)
    if not data.FactionMembers then
        data.FactionMembers = {}
    end
end

-- ==========================================================
-- 2. TRADER MANAGEMENT (Physical/Radio)
-- ==========================================================
function DynamicTrading_Roster.CreateTrader(traderID, config)
    local data = ModData.get(MOD_DATA_KEY)
    if not data.Traders[traderID] then
        data.Traders[traderID] = {
            factionID = config.factionID or "Independent",
            homeCoords = config.homeCoords or { x=0, y=0, z=0, zone="Unknown" },
            returnTime = 0.0, -- Timestamp for return
            isPhysicallySpawned = false,
            visuals = config.visuals or {}, -- model, outfitID, etc
            memory = {} -- [Username] = { trust, lastSeen, tradeVolume }
        }
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
        DynamicTrading.Log("DTCommons", "Roster", "Init", "Registered Trader " .. traderID)
    end
end

function DynamicTrading_Roster.GetTrader(traderID)
    local data = ModData.get(MOD_DATA_KEY)
    return data.Traders[traderID]
end

function DynamicTrading_Roster.SetSpawnStatus(traderID, isSpawned)
    local data = ModData.get(MOD_DATA_KEY)
    if data.Traders[traderID] then
        data.Traders[traderID].isPhysicallySpawned = isSpawned
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
    end
end

function DynamicTrading_Roster.SetReturnTime(traderID, timestamp)
    local data = ModData.get(MOD_DATA_KEY)
    if data.Traders[traderID] then
        data.Traders[traderID].returnTime = timestamp
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
    end
end

function DynamicTrading_Roster.UpdateMemory(traderID, username, tradeValue)
    local data = ModData.get(MOD_DATA_KEY)
    local trader = data.Traders[traderID]
    if trader then
        if not trader.memory[username] then
            trader.memory[username] = { trust = 0, lastSeen = 0, tradeVolume = 0 }
        end
        local mem = trader.memory[username]
        mem.lastSeen = getGameTime():getWorldAgeHours()
        mem.tradeVolume = mem.tradeVolume + tradeValue
        mem.trust = math.min(100, mem.trust + (tradeValue * 0.1))
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
    end
end

-- ==========================================================
-- 3. SOULS MANAGEMENT (Faction Members)
-- ==========================================================

function DynamicTrading_Roster.GetSouls(factionID)
    local data = ModData.get(MOD_DATA_KEY)
    if not data.FactionMembers[factionID] then
        data.FactionMembers[factionID] = {}
    end
    return data.FactionMembers[factionID]
end

-- Lightweight registry check
function DynamicTrading_Roster.GetSoulRegistry(uuid)
    local data = ModData.get(MOD_DATA_KEY)
    return data.Souls[uuid]
end

-- Fetch full npcData data (Lazy Load)
function DynamicTrading_Roster.GetSoul(uuid)
    local soulKey = "DTSOUL_" .. uuid
    if ModData.exists(soulKey) then
        return stripMovementSpeed(ModData.get(soulKey))
    end
    -- Fallback/Migration: check registry in case it's still there
    local registry = DynamicTrading_Roster.GetSoulRegistry(uuid)
    if registry and registry.name then return stripMovementSpeed(registry) end 
    return nil
end

function DynamicTrading_Roster.SaveSoul(uuid, npcData)
    npcData = stripMovementSpeed(npcData)
    local soulKey = "DTSOUL_" .. uuid
    if not ModData.exists(soulKey) then
        ModData.add(soulKey, npcData)
    else
        -- Direct assignment to ModData entry
        local entry = ModData.get(soulKey)
        for k, v in pairs(npcData) do entry[k] = v end
        entry.walkSpeed = nil
        entry.runSpeed = nil
    end
    -- ModData.transmit(soulKey) -- Disabled global broadcast
    
    -- Update Registry with minimal info
    local data = ModData.get(MOD_DATA_KEY)
    data.Souls[uuid] = {
        uuid = uuid,
        name = npcData.name or "Unknown",
        factionID = npcData.factionID,
        archetypeID = npcData.archetypeID,
        homeCoords = npcData.homeCoords,
        workCoords = npcData.workCoords or { x=0, y=0, z=0 },
        lastX = npcData.lastX,
        lastY = npcData.lastY,
        lastZ = npcData.lastZ,
        health = npcData.health or 1.0,
        status = npcData.status or "Resting",
        returnTime = npcData.returnTime,
        returnStatus = npcData.returnStatus,
        master = npcData.master,
        isFemale = npcData.isFemale,
        identitySeed = npcData.identitySeed or 1
    }

    -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
end

function DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    -- Update full npcData
    local npcData = DynamicTrading_Roster.GetSoul(uuid)
    if npcData then
        if npcData.status == "Away" and status ~= "Away" then
            DynamicTrading.Log("DTCommons", "Roster", "Sync", "Resetting state and master for " .. (npcData.name or uuid) .. " on return.")
            if status == "Trading" then
                npcData.state = "Trading"
            elseif status == "Working" then
                npcData.state = "Guard"
            else
                npcData.state = "Idle"
            end
            npcData.master = nil
            npcData.masterID = nil
            npcData.requestedReturnStatus = nil
            npcData.departureTargetX = nil
            npcData.departureTargetY = nil
            npcData.departureTargetZ = nil
            npcData.departureTravelHours = nil
        end

        if status ~= nil then npcData.status = status end
        if returnTime ~= nil then npcData.returnTime = returnTime end
        if returnStatus ~= nil then npcData.returnStatus = returnStatus end
        local soulKey = "DTSOUL_" .. uuid
        -- ModData.transmit(soulKey) -- Disabled global broadcast

        -- [NEW] Trigger Stock Generation if entering Trading state
        if DynamicTrading_Stock and DynamicTrading_Stock.OnSoulStatusChanged then
            DynamicTrading_Stock.OnSoulStatusChanged(uuid, status)
        end
    end
    
    -- Update Registry
    local data = ModData.get(MOD_DATA_KEY)
    if data.Souls[uuid] then
        local registry = data.Souls[uuid]
        -- Registry doesn't store state/master usually, but it stores status/timers
        registry.status = status
        registry.returnTime = returnTime
        registry.returnStatus = returnStatus
        -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
    end
    
    DynamicTrading.Log("DTCommons", "Roster", "Status", "Updated status for " .. uuid .. " to " .. (status or "nil") .. " (Return in: " .. tostring(returnTime) .. " as " .. tostring(returnStatus) .. ")")
end
function DynamicTrading_Roster.AddSoul(factionID, archetypeID, homeCoords)
    local data = ModData.get(MOD_DATA_KEY)
    
    -- [PARITY FIX] Auto-generate scattered homeCoords based on faction if not explicitly provided
    if not homeCoords and factionID and factionID ~= "Independent" then
        if DynamicTrading_Factions and DynamicTrading_Factions.GetFaction then
            local faction = DynamicTrading_Factions.GetFaction(factionID)
            if faction and faction.homeCoords and faction.homeCoords.x then
                local home = faction.homeCoords
                local scatterRange = 10 -- +/- 10 tiles roughly near base
                homeCoords = {
                    x = home.x + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                    y = home.y + (ZombRand(scatterRange * 2 + 1) - scatterRange),
                    z = home.z or 0,
                    zone = home.name or "Unknown"
                }
            end
        end
    end
    
    -- 1. Generate npcData (Visuals/Identity)
    local npcData = nil
    if DTNPCGenerator and DTNPCGenerator.Generate then
        -- V2 path: full NPC generator with MVPs, wardrobe, portraits
        npcData = DTNPCGenerator.Generate({
            occupation = archetypeID or "General"
        })
    else
        -- V1 fallback: minimal npcData (no V2 NPC generator available)
        local isFemale = (ZombRand(2) == 0)
        local name = "Unknown Trader"
        
        if SurvivorFactory then
            local survivor = SurvivorFactory.CreateSurvivor()
            if survivor then
                isFemale = survivor:isFemale()
                name = survivor:getForename() .. " " .. survivor:getSurname()
            end
        end
        
        -- Use deterministic identity seed so all clients derive the same outfit locally.
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
    
    -- 2. Generate UUID using the established name
    local name = npcData.name or "Unknown"
    local uuid = ""
    if DTNPCManager and DTNPCManager.GenerateSoulID then
        uuid = DTNPCManager.GenerateSoulID(name)
    else
        -- Fallback: Manual generation matching V2 standards
        local sanitizedName = name:gsub("%s+", ""):gsub("[^%a%d]", "")
        local suffix = ""
        local hexChars = "0123456789abcdef"
        for i = 1, 4 do
            local rand = ZombRand(1, 17)
            suffix = suffix .. hexChars:sub(rand, rand)
        end
        uuid = sanitizedName .. "_" .. suffix
    end
    
    -- 3. Merge Soul Metadata into npcData
    npcData.uuid = uuid
    npcData.factionID = factionID
    npcData.archetypeID = archetypeID
    npcData.homeCoords = homeCoords or { x=0, y=0, z=0 }
    npcData.workCoords = { x=0, y=0, z=0 }
    npcData.status = "Resting" -- Resting, Away, Trading, Working
    npcData.memory = {}
    
    -- Save full npcData to individual key
    DynamicTrading_Roster.SaveSoul(uuid, npcData)
    
    if not data.FactionMembers[factionID] then
        data.FactionMembers[factionID] = {}
    end
    table.insert(data.FactionMembers[factionID], uuid)
    
    -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
    return uuid
end

function DynamicTrading_Roster.RemoveSoul(factionID, count)
    local data = ModData.get(MOD_DATA_KEY)
    local members = data.FactionMembers[factionID]
    if not members or #members == 0 then return end
    
    count = count or 1
    for i=1, count do
        if #members > 0 then
            local idx = ZombRand(#members) + 1
            local uuid = table.remove(members, idx)
            data.Souls[uuid] = nil -- Registry removal
            -- We don't necessarily delete the DTSOUL_ key immediately to avoid file system thrashing, 
            -- but we could: ModData.remove("DTSOUL_"..uuid)
            if ModData.remove then ModData.remove("DTSOUL_" .. uuid) end
        end
    end
    -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
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
    -- ModData.transmit(MOD_DATA_KEY) -- Disabled global broadcast
end

-- ==========================================================
-- 4. MP SYNC LISTENER
-- ==========================================================
local function OnReceiveGlobalModData(key, data)
    if type(data) ~= "table" then return end
    if key == MOD_DATA_KEY then
        ModData.add(key, data)
    elseif string.find(key, "DTSOUL_") then
        ModData.add(key, data)
    end
end
Events.OnReceiveGlobalModData.Add(OnReceiveGlobalModData)

Events.OnInitGlobalModData.Add(DynamicTrading_Roster.Init)
