-- =============================================================================
-- DT_FirearmUtils.lua (V2 VERSION)
-- Utility functions for firearm logic and visual effects.
-- =============================================================================

DT_FirearmUtils = DT_FirearmUtils or {}
DT_FirearmUtils.MuzzleOffsetCache = DT_FirearmUtils.MuzzleOffsetCache or {}

local SHOTGUN_RELOAD_TYPES = {}
if WeaponReloadType then
    SHOTGUN_RELOAD_TYPES[WeaponReloadType.SHOTGUN] = true
    SHOTGUN_RELOAD_TYPES[WeaponReloadType.DOUBLE_BARREL_SHOTGUN] = true
    SHOTGUN_RELOAD_TYPES[WeaponReloadType.DOUBLE_BARREL_SHOTGUN_SAWN] = true
end

--- Calculates the precise world position of a firearm's muzzle tip.
--- Leverages B42 model attachments if available, with robust fallbacks.
--- @param character IsoGameCharacter
--- @return number, number, number (x, y, z)
function DT_FirearmUtils.GetMuzzlePosition(character)
    if not character then return nil end
    
    local x, y, z = character:getX(), character:getY(), character:getZ()
    local weapon = character:getPrimaryHandItem()
    
    -- Fallback for non-weapon items or empty hands
    if not weapon or not instanceof(weapon, "HandWeapon") then 
        return x, y, z + 1.1
    end

    local angle = character:getAnimAngleRadians() 
    
    -- Unit vectors for character orientation
    local fX = math.sin(angle)
    local fY = -math.cos(angle)
    local rX = math.cos(angle)
    local rY = math.sin(angle)

    -- Default offsets (Fallbacks)
    local offsetForward = 0.45
    local offsetRight = 0.05
    local offsetUp = 1.1
    
    if weapon:isTwoHandWeapon() then
        offsetForward = 0.75
    end

    -- B42 Model Attachment Lookup (with caching)
    local staticModel = weapon:getStaticModel()
    if staticModel then
        local cached = DT_FirearmUtils.MuzzleOffsetCache[staticModel]
        
        if cached then
            offsetForward = cached.f
            offsetRight = cached.r
            offsetUp = 1.1 + cached.u
        else
            local modelScript = getScriptManager():getModelScript(staticModel)
            if modelScript then
                local attachment = modelScript:getAttachmentById("muzzle")
                if attachment then
                    local offset = attachment:getOffset()
                    offsetForward = offset:y()
                    offsetRight = offset:x()
                    offsetUp = 1.1 + offset:z()
                    
                    -- Store in cache
                    DT_FirearmUtils.MuzzleOffsetCache[staticModel] = {
                        f = offsetForward,
                        r = offsetRight,
                        u = offset:z()
                    }
                end
            end
        end
    end
    
    local finalX = x + (fX * offsetForward) + (rX * offsetRight)
    local finalY = y + (fY * offsetForward) + (rY * offsetRight)
    local finalZ = z + offsetUp

    return finalX, finalY, finalZ
end

local function radiansToDegrees(radians)
    return radians * 57.29577951308232
end

function DT_FirearmUtils.GetShotDirectionDegrees(character)
    if not character then
        return 0
    end

    if character.getDirectionAngle then
        local direction = tonumber(character:getDirectionAngle())
        if direction then
            return direction
        end
    end

    if character.getAnimAngleRadians then
        local radians = tonumber(character:getAnimAngleRadians())
        if radians then
            return radiansToDegrees(radians)
        end
    end

    return 0
end

function DT_FirearmUtils.GetProjectileCount(weaponItem)
    if not weaponItem or not weaponItem.getWeaponReloadType then
        return 1
    end

    local reloadType = weaponItem:getWeaponReloadType()
    if SHOTGUN_RELOAD_TYPES[reloadType] then
        return 5
    end

    return 1
end

return DT_FirearmUtils
