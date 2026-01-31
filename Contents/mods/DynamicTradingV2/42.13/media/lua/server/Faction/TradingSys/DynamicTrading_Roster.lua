require "NPC/Sys/DTNPC_Generator"

DynamicTrading_Roster = {}
local MOD_DATA_KEY = "DynamicTrading_Roster"

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
        ModData.transmit(MOD_DATA_KEY)
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
        ModData.transmit(MOD_DATA_KEY)
        print("DynamicTrading: Registered Trader " .. traderID)
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
        ModData.transmit(MOD_DATA_KEY)
    end
end

function DynamicTrading_Roster.SetReturnTime(traderID, timestamp)
    local data = ModData.get(MOD_DATA_KEY)
    if data.Traders[traderID] then
        data.Traders[traderID].returnTime = timestamp
        ModData.transmit(MOD_DATA_KEY)
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
        ModData.transmit(MOD_DATA_KEY)
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

-- Fetch full brain data (Lazy Load)
function DynamicTrading_Roster.GetSoul(uuid)
    local soulKey = "DTSOUL_" .. uuid
    if ModData.exists(soulKey) then
        return ModData.get(soulKey)
    end
    -- Fallback/Migration: check registry in case it's still there
    local registry = DynamicTrading_Roster.GetSoulRegistry(uuid)
    if registry and registry.name then return registry end 
    return nil
end

function DynamicTrading_Roster.SaveSoul(uuid, brain)
    local soulKey = "DTSOUL_" .. uuid
    if not ModData.exists(soulKey) then
        ModData.add(soulKey, brain)
    else
        -- Direct assignment to ModData entry
        local entry = ModData.get(soulKey)
        for k, v in pairs(brain) do entry[k] = v end
    end
    ModData.transmit(soulKey)
    
    -- Update Registry with minimal info
    local data = ModData.get(MOD_DATA_KEY)
    data.Souls[uuid] = {
        uuid = uuid,
        name = brain.name or "Unknown",
        factionID = brain.factionID,
        archetypeID = brain.archetypeID,
        homeCoords = brain.homeCoords,
        workCoords = brain.workCoords or { x=0, y=0, z=0 },
        lastX = brain.lastX,
        lastY = brain.lastY,
        lastZ = brain.lastZ,
        health = brain.health or 1.0,
        status = brain.status or "Rest",
        returnTime = brain.returnTime,
        returnStatus = brain.returnStatus,
        master = brain.master,
        isFemale = brain.isFemale,
        portraitID = brain.portraitID
    }

    ModData.transmit(MOD_DATA_KEY)
end

function DynamicTrading_Roster.UpdateSoulStatus(uuid, status, returnTime, returnStatus)
    -- Update full brain
    local brain = DynamicTrading_Roster.GetSoul(uuid)
    if brain then
        -- If we are returning from "Away", reset their state to "Stay" to avoid flee-loop
        if brain.status == "Away" and status ~= "Away" then
            print("[DTNPC-Roster] Resetting state and master for " .. (brain.name or uuid) .. " on return.")
            brain.state = "Stay"
            brain.master = nil
            brain.masterID = nil
        end

        brain.status = status
        brain.returnTime = returnTime
        brain.returnStatus = returnStatus
        local soulKey = "DTSOUL_" .. uuid
        ModData.transmit(soulKey)
    end
    
    -- Update Registry
    local data = ModData.get(MOD_DATA_KEY)
    if data.Souls[uuid] then
        local registry = data.Souls[uuid]
        -- Registry doesn't store state/master usually, but it stores status/timers
        registry.status = status
        registry.returnTime = returnTime
        registry.returnStatus = returnStatus
        ModData.transmit(MOD_DATA_KEY)
    end
    
    print("[DTNPC-Roster] Updated status for " .. uuid .. " to " .. (status or "nil") .. " (Return in: " .. tostring(returnTime) .. " as " .. tostring(returnStatus) .. ")")
end

function DynamicTrading_Roster.AddSoul(factionID, archetypeID, homeCoords)
    local data = ModData.get(MOD_DATA_KEY)
    
    -- Generate UUID
    local uuid = (DTNPCManager and DTNPCManager.GenerateUUID) and DTNPCManager.GenerateUUID() or string.format("soul_%d_%d", ZombRand(1000000), os.time())
    
    -- Generate Brain (Visuals/Identity)
    local brain = DTNPCGenerator.Generate({
        occupation = archetypeID or "General"
    })
    
    -- Merge Soul Metadata into Brain
    brain.uuid = uuid
    brain.factionID = factionID
    brain.archetypeID = archetypeID
    brain.homeCoords = homeCoords or { x=0, y=0, z=0 }
    brain.workCoords = { x=0, y=0, z=0 }
    brain.status = "Rest" -- Rest, Away, Trading, Working
    brain.memory = {}
    
    -- Save full brain to individual key
    DynamicTrading_Roster.SaveSoul(uuid, brain)
    
    if not data.FactionMembers[factionID] then
        data.FactionMembers[factionID] = {}
    end
    table.insert(data.FactionMembers[factionID], uuid)
    
    ModData.transmit(MOD_DATA_KEY)
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
    ModData.transmit(MOD_DATA_KEY)
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
    ModData.transmit(MOD_DATA_KEY)
end

Events.OnInitGlobalModData.Add(DynamicTrading_Roster.Init)
