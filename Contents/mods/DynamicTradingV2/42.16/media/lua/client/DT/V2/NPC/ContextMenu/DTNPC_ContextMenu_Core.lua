-- ==============================================================================
-- DTNPC_ContextMenu_Core.lua
-- Shared helpers for production NPC context menus.
-- ==============================================================================

DTNPCContextMenu = DTNPCContextMenu or {}
DTNPCContextMenu.Internal = DTNPCContextMenu.Internal or {}

local Internal = DTNPCContextMenu.Internal

if Internal.CoreLoaded then
    return
end

Internal.CoreLoaded = true

function DTNPCContextMenu.GetNPCData(zombie)
    if not zombie then
        return nil
    end
    if DTNPC and DTNPC.GetData then
        return DTNPC.GetData(zombie)
    end

    local modData = zombie.getModData and zombie:getModData() or nil
    return modData and (modData.DTNPC_Data or modData.DTNPCBrain) or nil
end

function DTNPCContextMenu.CalculateDistance(obj1, obj2)
    if not obj1 or not obj2 then
        return 9999
    end

    local dx = obj1:getX() - obj2:getX()
    local dy = obj1:getY() - obj2:getY()
    return math.sqrt((dx * dx) + (dy * dy))
end

function DTNPCContextMenu.CollectNearbyNPCs(player, worldObjects, radius)
    radius = tonumber(radius) or 3.0
    if not player or type(worldObjects) ~= "table" then
        return {}
    end

    local square = nil
    for i = 1, #worldObjects do
        local obj = worldObjects[i]
        if obj and obj.getSquare and obj:getSquare() then
            square = obj:getSquare()
            break
        end
    end
    if not square then
        return {}
    end

    local npcList = {}
    local processedIDs = {}

    local function scanSquare(scanTarget)
        if not scanTarget then
            return
        end

        local movingObjects = scanTarget:getMovingObjects()
        for index = 0, movingObjects:size() - 1 do
            local obj = movingObjects:get(index)
            if instanceof(obj, "IsoZombie") then
                local npcData = DTNPCContextMenu.GetNPCData(obj)
                if npcData then
                    local id = obj:getPersistentOutfitID() or obj:getID()
                    if not processedIDs[id] and DTNPCContextMenu.CalculateDistance(player, obj) < radius then
                        npcList[#npcList + 1] = obj
                        processedIDs[id] = true
                    end
                end
            end
        end
    end

    scanSquare(square)

    local sx = square:getX()
    local sy = square:getY()
    local sz = square:getZ()
    for offsetX = -1, 1 do
        for offsetY = -1, 1 do
            if not (offsetX == 0 and offsetY == 0) then
                scanSquare(getCell():getGridSquare(sx + offsetX, sy + offsetY, sz))
            end
        end
    end

    table.sort(npcList, function(left, right)
        return DTNPCContextMenu.CalculateDistance(player, left) < DTNPCContextMenu.CalculateDistance(player, right)
    end)

    return npcList
end
