-- =============================================================================
-- DYNAMIC TRADING: SHARED PORTRAIT RESOLVER
-- =============================================================================
-- Chooses the best portrait source for a target: live NPC, deterministic
-- descriptor, or legacy PNG texture.
-- =============================================================================

DT_NPCPortraitResolver = DT_NPCPortraitResolver or {}

local function isRenderableCharacter(character)
    if not character then
        return false
    end

    if type(character) ~= "userdata" then
        return false
    end

    if instanceof then
        local isCharacter = instanceof(character, "IsoGameCharacter")
            or instanceof(character, "IsoPlayer")
            or instanceof(character, "IsoZombie")
            or instanceof(character, "IsoSurvivor")
        if not isCharacter then
            return false
        end
    end

    local visual = character:getHumanVisual()
    return visual ~= nil
end

function DT_NPCPortraitResolver.Resolve(targetData, character, options)
    options = options or {}

    local provider = options.provider
    local forceLegacy = options.forceLegacy == true
    local liveCharacter = character or (targetData and targetData.npcRef) or nil

    if forceLegacy then
        return {
            mode = "legacy",
            texture = DT_NPCPortraitRenderers.GetLegacyTexture(targetData, provider)
        }
    end

    if isRenderableCharacter(liveCharacter) then
        return {
            mode = "3d",
            character = liveCharacter
        }
    end

    local desc = DT_NPCPortraitDescriptor.Build(targetData)
    if desc then
        return {
            mode = "3d",
            survivorDesc = desc
        }
    end

    return {
        mode = "legacy",
        texture = DT_NPCPortraitRenderers.GetLegacyTexture(targetData, provider)
    }
end

return DT_NPCPortraitResolver
