-- ==============================================================================
-- DTNPC_SpatialHash.lua
-- Server-side spatial hashing grid for efficient NPC proximity queries.
-- Reduces O(n²) checks to O(n) with dirty flag optimization.
-- ==============================================================================

DTNPC_SpatialHash = DTNPC_SpatialHash or {}

-- Configuration
DTNPC_SpatialHash.CELL_SIZE = 100              -- Tile size per grid cell
DTNPC_SpatialHash.CLEANUP_INTERVAL = 300       -- Cleanup every 300 ticks (~5 minutes game time)
DTNPC_SpatialHash.MAX_NPC_LIMIT = 120          -- Max NPCs before warnings

-- Internal state
DTNPC_SpatialHash.Grid = {}                    -- Hash table: "gridX_gridY" -> { npcUUID -> soul }
DTNPC_SpatialHash.NPCToCell = {}               -- Index: npcUUID -> "gridX_gridY"
DTNPC_SpatialHash.DirtyFlags = {}              -- Track modified cells for lazy updates
DTNPC_SpatialHash.NextCleanup = 0              -- Game time for next cleanup
DTNPC_SpatialHash.IsInitialized = false        -- Flag to track if grid has been built

-- ==============================================================================
-- 1. GRID MANAGEMENT
-- ==============================================================================

local function getGridKey(x, y)
    local gridX = math.floor(x / DTNPC_SpatialHash.CELL_SIZE)
    local gridY = math.floor(y / DTNPC_SpatialHash.CELL_SIZE)
    return gridX .. "_" .. gridY
end

local function getCellsInRadius(x, y, radius)
    local cellRadius = math.ceil(radius / DTNPC_SpatialHash.CELL_SIZE)
    local centerGridX = math.floor(x / DTNPC_SpatialHash.CELL_SIZE)
    local centerGridY = math.floor(y / DTNPC_SpatialHash.CELL_SIZE)
    
    local cells = {}
    for gx = centerGridX - cellRadius, centerGridX + cellRadius do
        for gy = centerGridY - cellRadius, centerGridY + cellRadius do
            table.insert(cells, gx .. "_" .. gy)
        end
    end
    return cells
end

local function isTable(value)
    return type(value) == "table"
end

local function logCorruptCell(context, gridKey, value)
    print("[DTNPC_SpatialHash] Corrupt cell detected in " .. context .. " at " .. tostring(gridKey) .. " (type=" .. type(value) .. "), removing")
end

-- ==============================================================================
-- 2. INSERT / UPDATE / REMOVE
-- ==============================================================================

function DTNPC_SpatialHash.InsertNPC(uuid, x, y, z, soul)
    if not uuid or not x or not y then return end
    
    local gridKey = getGridKey(x, y)
    
    -- Remove from old cell if it exists
    local oldKey = DTNPC_SpatialHash.NPCToCell[uuid]
    if oldKey and oldKey ~= gridKey then
        local oldCell = DTNPC_SpatialHash.Grid[oldKey]
        if oldCell ~= nil then
            if not isTable(oldCell) then
                logCorruptCell("InsertNPC(old)", oldKey, oldCell)
                DTNPC_SpatialHash.Grid[oldKey] = nil
                DTNPC_SpatialHash.DirtyFlags[oldKey] = nil
            else
                oldCell[uuid] = nil
                DTNPC_SpatialHash.DirtyFlags[oldKey] = true
            end
        end
    end
    
    -- Insert into new cell
    local targetCell = DTNPC_SpatialHash.Grid[gridKey]
    if targetCell ~= nil and not isTable(targetCell) then
        logCorruptCell("InsertNPC(new)", gridKey, targetCell)
        targetCell = nil
    end

    if not targetCell then
        DTNPC_SpatialHash.Grid[gridKey] = {}
        targetCell = DTNPC_SpatialHash.Grid[gridKey]
    end
    
    targetCell[uuid] = {
        x = x,
        y = y,
        z = z,
        soul = soul
    }
    
    DTNPC_SpatialHash.NPCToCell[uuid] = gridKey
    DTNPC_SpatialHash.DirtyFlags[gridKey] = true
end

function DTNPC_SpatialHash.RemoveNPC(uuid)
    if not uuid then return end
    
    local gridKey = DTNPC_SpatialHash.NPCToCell[uuid]
    if gridKey then
        local cell = DTNPC_SpatialHash.Grid[gridKey]
        if cell ~= nil then
            if not isTable(cell) then
                logCorruptCell("RemoveNPC", gridKey, cell)
                DTNPC_SpatialHash.Grid[gridKey] = nil
                DTNPC_SpatialHash.DirtyFlags[gridKey] = nil
            else
                cell[uuid] = nil
                DTNPC_SpatialHash.DirtyFlags[gridKey] = true
            end
        end
    end
    
    DTNPC_SpatialHash.NPCToCell[uuid] = nil
end

-- ==============================================================================
-- 3. QUERY FUNCTIONS
-- ==============================================================================

function DTNPC_SpatialHash.GetNPCsInRadius(x, y, radius)
    local cells = getCellsInRadius(x, y, radius)
    local result = {}
    
    for _, gridKey in ipairs(cells) do
        local cell = DTNPC_SpatialHash.Grid[gridKey]
        if cell ~= nil then
            if not isTable(cell) then
                logCorruptCell("GetNPCsInRadius", gridKey, cell)
                DTNPC_SpatialHash.Grid[gridKey] = nil
                DTNPC_SpatialHash.DirtyFlags[gridKey] = nil
            else
                for uuid, npcData in pairs(cell) do
                    if not isTable(npcData) or type(npcData.x) ~= "number" or type(npcData.y) ~= "number" then
                        print("[DTNPC_SpatialHash] Invalid NPC payload in " .. tostring(gridKey) .. " for " .. tostring(uuid) .. ", skipping")
                    else
                        -- Double-check distance (cells are square, but we need circular)
                        local dx = npcData.x - x
                        local dy = npcData.y - y
                        local dist = math.sqrt(dx * dx + dy * dy)
                        
                        if dist <= radius then
                            result[uuid] = npcData
                        end
                    end
                end
            end
        end
    end
    
    return result
end

function DTNPC_SpatialHash.GetNearestNPCs(x, y, radius, maxResults)
    local npcs = DTNPC_SpatialHash.GetNPCsInRadius(x, y, radius)
    
    if not maxResults or maxResults >= #npcs then
        return npcs
    end
    
    -- Sort by distance and return top N
    local sorted = {}
    for uuid, npcData in pairs(npcs) do
        local dx = npcData.x - x
        local dy = npcData.y - y
        local dist = math.sqrt(dx * dx + dy * dy)
        table.insert(sorted, { uuid = uuid, data = npcData, dist = dist })
    end
    
    table.sort(sorted, function(a, b) return a.dist < b.dist end)
    
    local limited = {}
    for i = 1, math.min(maxResults, #sorted) do
        limited[sorted[i].uuid] = sorted[i].data
    end
    
    return limited
end

function DTNPC_SpatialHash.GetGridStats()
    local cellCount = 0
    local totalNPCs = 0
    local toRemove = {}
    
    for gridKey, cell in pairs(DTNPC_SpatialHash.Grid) do
        if type(cell) ~= "table" then
            print("[SpatialHash] Corrupt cell in GetGridStats at " .. gridKey)
            table.insert(toRemove, gridKey)
        else
            -- Check if cell has any entries
            local hasEntries = false
            for _ in pairs(cell) do
                hasEntries = true
                totalNPCs = totalNPCs + 1
            end
            
            if hasEntries then
                cellCount = cellCount + 1
            end
        end
    end

    for _, gridKey in ipairs(toRemove) do
        DTNPC_SpatialHash.Grid[gridKey] = nil
        DTNPC_SpatialHash.DirtyFlags[gridKey] = nil
    end
    
    return {
        cellCount = cellCount,
        totalNPCs = totalNPCs,
        gridSize = DTNPC_SpatialHash.CELL_SIZE
    }
end

-- ==============================================================================
-- 4. CLEANUP (Dirty Flags & Timed)
-- ==============================================================================

function DTNPC_SpatialHash.CleanupEmptyCells()
    local currentTime = getGameTime():getWorldAgeHours()
    
    -- Only run cleanup every CLEANUP_INTERVAL ticks
    if currentTime < DTNPC_SpatialHash.NextCleanup then
        return
    end
    
    local cleaned = 0
    local toRemove = {}
    
    for gridKey, cell in pairs(DTNPC_SpatialHash.Grid) do
        -- Check if cell is not a table (corrupt data)
        if type(cell) ~= "table" then
            print("[SpatialHash] Corrupt cell detected at " .. gridKey .. ", type: " .. type(cell))
            table.insert(toRemove, gridKey)
            cleaned = cleaned + 1
        else
            -- Check if cell is empty by counting entries
            local isEmpty = true
            for _ in pairs(cell) do
                isEmpty = false
                break
            end
            
            if isEmpty then
                table.insert(toRemove, gridKey)
                cleaned = cleaned + 1
            end
        end
    end
    
    for _, gridKey in ipairs(toRemove) do
        DTNPC_SpatialHash.Grid[gridKey] = nil
        DTNPC_SpatialHash.DirtyFlags[gridKey] = nil
    end
    
    DTNPC_SpatialHash.NextCleanup = currentTime + DTNPC_SpatialHash.CLEANUP_INTERVAL
    
    if cleaned > 0 then
        print("[DTNPC_SpatialHash] Cleaned up " .. cleaned .. " empty cells")
    end
end
        if corruptCleaned > 0 then
            print("[DTNPC_SpatialHash] Cleaned up " .. cleaned .. " cells (" .. corruptCleaned .. " corrupt)")
        else
            print("[DTNPC_SpatialHash] Cleaned up " .. cleaned .. " empty cells")
        end
    end
end

function DTNPC_SpatialHash.ClearDirtyFlags()
    DTNPC_SpatialHash.DirtyFlags = {}
end

function DTNPC_SpatialHash.GetDirtyCells()
    local result = {}
    for gridKey, _ in pairs(DTNPC_SpatialHash.DirtyFlags) do
        table.insert(result, gridKey)
    end
    return result
end

-- ==============================================================================
-- 5. REBUILD / RESET
-- ==============================================================================

function DTNPC_SpatialHash.RebuildFromRoster(rosterData)
    print("[SpatialHash] RebuildFromRoster called")
    if not rosterData or not rosterData.Souls then 
        print("[SpatialHash] No roster data available")
        return 
    end
    
    DTNPC_SpatialHash.Grid = {}
    DTNPC_SpatialHash.NPCToCell = {}
    DTNPC_SpatialHash.DirtyFlags = {}
    print("[SpatialHash] Cleared existing grid")
    
    local inserted = 0
    for uuid, soul in pairs(rosterData.Souls) do
        local x = soul.lastX or (soul.homeCoords and soul.homeCoords.x) or 0
        local y = soul.lastY or (soul.homeCoords and soul.homeCoords.y) or 0
        local z = soul.lastZ or (soul.homeCoords and soul.homeCoords.z) or 0
        
        if x > 0 and y > 0 then
            DTNPC_SpatialHash.InsertNPC(uuid, x, y, z, soul)
            inserted = inserted + 1
        end
    end
    
    DTNPC_SpatialHash.IsInitialized = true
    print("[DTNPC_SpatialHash] Rebuilt grid with " .. inserted .. " NPCs")
end

function DTNPC_SpatialHash.Clear()
    print("[SpatialHash] Clear called")
    DTNPC_SpatialHash.Grid = {}
    DTNPC_SpatialHash.NPCToCell = {}
    DTNPC_SpatialHash.DirtyFlags = {}
    DTNPC_SpatialHash.NextCleanup = 0
    DTNPC_SpatialHash.IsInitialized = false
end

-- ==============================================================================
-- 6. DEBUG
-- ==============================================================================

function DTNPC_SpatialHash.DebugCell(x, y)
    local gridKey = getGridKey(x, y)
    local cell = DTNPC_SpatialHash.Grid[gridKey]
    
    print("[DTNPC_SpatialHash] Cell at (" .. x .. ", " .. y .. ") = " .. gridKey)
    
    -- Check if cell is empty
    if not cell or type(cell) ~= "table" then
        print("  (empty or invalid)")
        return
    end
    
    local isEmpty = true
    for uuid, npcData in pairs(cell) do
        isEmpty = false
        print("  - " .. uuid .. " at (" .. npcData.x .. ", " .. npcData.y .. ")")
    end
    
    if isEmpty then
        print("  (empty)")
    end
end

function DTNPC_SpatialHash.DebugRadius(x, y, radius)
    local npcs = DTNPC_SpatialHash.GetNPCsInRadius(x, y, radius)
    
    print("[DTNPC_SpatialHash] NPCs within " .. radius .. " tiles of (" .. x .. ", " .. y .. "):")
    
    -- Check if npcs table is empty
    local isEmpty = true
    for uuid, npcData in pairs(npcs) do
        isEmpty = false
        local dx = npcData.x - x
        local dy = npcData.y - y
        local dist = math.sqrt(dx * dx + dy * dy)
        print("  - " .. uuid .. " at (" .. npcData.x .. ", " .. npcData.y .. "), dist=" .. string.format("%.1f", dist))
    end
    
    if isEmpty then
        print("  (none)")
    end
end
        local dist = math.sqrt(dx * dx + dy * dy)
        print("  - " .. uuid .. " at distance " .. string.format("%.1f", dist))
    end
end
