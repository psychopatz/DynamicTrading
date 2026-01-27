require "01_DynamicTrading_Config"

DynamicTrading = DynamicTrading or {}
DynamicTrading.CooldownManager = {}

local COOLDOWN_KEY = "DynamicTrading_Cooldowns_v1.0"

-- [CLIENT] Cache for my own cooldown
DynamicTrading.CooldownManager.ClientCache = 0

-- =============================================================================
-- COOLDOWN MANAGER
-- =============================================================================

function DynamicTrading.CooldownManager.CanScan(player)
    if not player then return false, 0 end
    
    -- A: SERVER SIDE CHECK (Authoritative)
    if isServer() or not isClient() then
        local data = ModData.getOrCreate(COOLDOWN_KEY)
        if not data.timers then data.timers = {} end
        
        local username = player:getUsername()
        local lastTime = data.timers[username] or 0
        local currentTime = GameTime:getInstance():getWorldAgeHours()
        local cooldownHours = (SandboxVars.DynamicTrading.ScanCooldown or 30) / 60.0
        
        if currentTime >= lastTime + cooldownHours then
            return true, 0
        else
            return false, (lastTime + cooldownHours - currentTime) * 60
        end

    -- B: CLIENT SIDE CHECK (Visual/Feedback)
    else
        local lastTime = DynamicTrading.CooldownManager.ClientCache or 0
        local currentTime = GameTime:getInstance():getWorldAgeHours()
        local cooldownHours = (SandboxVars.DynamicTrading.ScanCooldown or 30) / 60.0
        
        if currentTime >= lastTime + cooldownHours then
            return true, 0
        else
            return false, (lastTime + cooldownHours - currentTime) * 60
        end
    end
end

function DynamicTrading.CooldownManager.SetScanTimestamp(player)
    if not player then return end
    
    -- ONLY SERVER WRITES TO THIS
    if isServer() or not isClient() then
        local data = ModData.getOrCreate(COOLDOWN_KEY)
        if not data.timers then data.timers = {} end
        
        local currentTime = GameTime:getInstance():getWorldAgeHours()
        data.timers[player:getUsername()] = currentTime
        
        -- Targeted Sync: Send ONLY to this player
        DynamicTrading.CooldownManager.UpdateClient(player, currentTime)
    end
end

-- =============================================================================
-- SYNC LOGIC (Server -> Specific Client)
-- =============================================================================

function DynamicTrading.CooldownManager.UpdateClient(player, timestamp)
    if isServer() and player then
        sendServerCommand(player, "DynamicTrading", "UpdateCooldown", { time = timestamp })
    end
end

-- =============================================================================
-- EVENT COOLDOWN MANAGER (SERVER ONLY)
-- =============================================================================

function DynamicTrading.CooldownManager.GetEventCooldown(eventID)
    if isClient() then return 0 end -- Client doesn't need to know
    
    local data = ModData.getOrCreate(COOLDOWN_KEY)
    if not data.eventTimers then data.eventTimers = {} end
    
    return data.eventTimers[eventID] or 0
end

function DynamicTrading.CooldownManager.SetEventCooldown(eventID, unlockDay)
    if isClient() then return end
    
    local data = ModData.getOrCreate(COOLDOWN_KEY)
    if not data.eventTimers then data.eventTimers = {} end
    
    data.eventTimers[eventID] = unlockDay
    -- No sync needed; server logic only.
end

-- =============================================================================
-- INITIALIZATION (Load legacy data if exists? Optional)
-- =============================================================================
function DynamicTrading.CooldownManager.Init()
    -- Only loaded on server start
    local data = ModData.getOrCreate(COOLDOWN_KEY)
    if not data.timers then data.timers = {} end
    if not data.eventTimers then data.eventTimers = {} end
end
