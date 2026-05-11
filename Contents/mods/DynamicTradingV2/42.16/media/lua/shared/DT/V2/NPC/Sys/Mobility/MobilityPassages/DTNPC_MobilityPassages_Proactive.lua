-- ==============================================================================
-- DTNPC_MobilityPassages_Proactive.lua
-- Proactive door and window interactions (collision handles and proximity).
-- ==============================================================================

DTNPCMobility = DTNPCMobility or {}

local Mobility = DTNPCMobility
local Internal = Mobility.Internal or {}

Mobility.Internal = Internal

--- Proactivaly handles door/window interactions based on collision and proximity.
function Mobility.UpdateProactiveInteractions(zombie, npcData)
    if not zombie or zombie:isDead() or type(npcData) ~= "table" then
        return
    end

    -- 1. Collision-based interaction (Physical response to running into obstacles)
    local collided = zombie:isCollidedWithDoor() or zombie:isCollidedThisFrame() or zombie:isCollided()
    if collided then
        local square = zombie:getSquare()
        local forward = zombie:getForwardDirection()
        -- Predictive square in front of the NPC
        local fx, fy = math.floor(zombie:getX() + forward:getX() * 0.8 + 0.5), math.floor(zombie:getY() + forward:getY() * 0.8 + 0.5)
        local targetSquare = getCell():getGridSquare(fx, fy, zombie:getZ())
        
        local squares = { square, targetSquare }
        for _, sq in ipairs(squares) do
            if sq then
                local objects = sq:getObjects()
                for i = 0, objects:size() - 1 do
                    local object = objects:get(i)
                    if object then
                        if Internal.isDoorLike(object) then
                            local isOpen = Internal.objectBool(object, { "IsOpen", "isOpen" }, false)
                            if not isOpen and not Internal.isObstacleLocked(object) then
                                -- Active door opening on collision
                                Internal.trySetDoorOpenState(object, true)
                                -- If we're following a path, we might need a small nudge or wait
                                return
                            end
                        elseif Internal.isWindowLike(object) then
                             local isOpen = Internal.objectBool(object, { "IsOpen", "isOpen" }, false)
                             if not isOpen and not Internal.objectBool(object, { "isDestroyed", "IsDestroyed" }, false) then
                                 -- Windows use the existing TryUse helper which handles ToggleWindow
                                 Internal.tryUsePassageObject(zombie, object)
                                 return
                             end
                        end
                    end
                end
            end
        end
    end

    -- 2. Proactive Closing (Immersion/Security)
    -- NPC closes nearby doors when stationary and safe.
    local isMoving = zombie:isMoving()
    if not isMoving and (npcData.state == "Guard" or npcData.state == "Idle") then
        local lastCloseCheck = npcData._dtLastProactiveInteractAt or 0
        local currentTime = (Internal.getTimeMs and Internal.getTimeMs()) or 0
        if currentTime - lastCloseCheck >= 3000 then -- Check every 3s
            npcData._dtLastProactiveInteractAt = currentTime
            
            local square = zombie:getSquare()
            if square then
                for dx = -1, 1 do
                    for dy = -1, 1 do
                         local testSq = getCell():getGridSquare(square:getX() + dx, square:getY() + dy, square:getZ())
                         if testSq then
                             local objects = testSq:getObjects()
                             for i = 0, objects:size() - 1 do
                                 local object = objects:get(i)
                                 if Internal.isDoorLike(object) then
                                     local isOpen = Internal.objectBool(object, { "IsOpen", "isOpen" }, false)
                                     if isOpen then
                                         -- Only close if no threats or players are within 3 tiles
                                         if not Internal.isDangerNearPoint(testSq:getX(), testSq:getY(), testSq:getZ(), 3.0) then
                                             Internal.trySetDoorOpenState(object, false)
                                         end
                                     end
                                 end
                             end
                         end
                    end
                end
            end
        end
    end
end
