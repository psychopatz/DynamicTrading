-- =============================================================================
-- DT_LightSystem.lua
-- Modular light management for bursts (muzzle flashes).
-- =============================================================================

DT_LightSystem = DT_LightSystem or {}

-- SERVER NO-OP WRAPPER
if isServer() then
    function DT_LightSystem.SpawnBurst() end
    function DT_LightSystem.MuzzleFlash() end
    return DT_LightSystem
end

-- Use global table to survive Lua reloads
DT_LightSystem.BurstStorage = DT_LightSystem.BurstStorage or {}
local BurstStorage = DT_LightSystem.BurstStorage

--- Spawns a temporary light burst (e.g., for muzzle flashes)
--- @param x number
--- @param y number
--- @param z number
--- @param r number (Optional, default 1.0)
--- @param g number (Optional, default 0.9)
--- @param b number (Optional, default 0.4)
--- @param radius number (Optional, default 8)
--- @param durationTicks number (Optional, default 2)
function DT_LightSystem.SpawnBurst(x, y, z, r, g, b, radius, durationTicks)
    if not getCell() then return end
    
    local flash = IsoLightSource.new(
        math.floor(x), 
        math.floor(y), 
        math.floor(z), 
        tonumber(r) or 1.0, 
        tonumber(g) or 0.9, 
        tonumber(b) or 0.4, 
        tonumber(radius) or 8
    )
    if not flash then return end
    
    getCell():addLamppost(flash)
    
    table.insert(BurstStorage, {
        light = flash,
        ticksRemaining = math.max(1, tonumber(durationTicks) or 2)
    })
end

function DT_LightSystem.MuzzleFlash(character, options)
    if not character or not getCell() then
        return false
    end

    options = type(options) == "table" and options or {}

    local x = tonumber(options.x)
    local y = tonumber(options.y)
    local z = tonumber(options.z)
    local squareZ = tonumber(options.squareZ)

    if (not x or not y or not z) and DT_FirearmUtils and DT_FirearmUtils.GetMuzzlePosition then
        x, y, z = DT_FirearmUtils.GetMuzzlePosition(character)
    end

    if not x or not y or not z then
        x = character:getX()
        y = character:getY()
        z = character:getZ()
    end

    if not squareZ then
        squareZ = character:getZ()
    end

    DT_LightSystem.SpawnBurst(
        x,
        y,
        squareZ,
        tonumber(options.r) or 1.0,
        tonumber(options.g) or 0.46,
        tonumber(options.b) or 0.14,
        tonumber(options.radius) or 18,
        tonumber(options.durationTicks) or 1
    )

    return true
end

--- Tick handler for light lifecycle
local function updateLights()
    local cell = getCell()
    if not cell then return end
    
    -- 1. Burst Cleanup (Flash Cleanup)
    if #BurstStorage > 0 then
        for i = #BurstStorage, 1, -1 do
            local flashEntry = BurstStorage[i]
            flashEntry.ticksRemaining = flashEntry.ticksRemaining - 1
            if flashEntry.ticksRemaining <= 0 then
                if flashEntry.light then
                    cell:removeLamppost(flashEntry.light)
                end
                table.remove(BurstStorage, i)
            end
        end
    end
end

if not DT_LightSystem.EventsRegistered then
    Events.OnTick.Add(updateLights)
    DT_LightSystem.EventsRegistered = true
    print("DT_LightSystem: Modular Library Loaded (Muzzle Flash Only)")
end

return DT_LightSystem
