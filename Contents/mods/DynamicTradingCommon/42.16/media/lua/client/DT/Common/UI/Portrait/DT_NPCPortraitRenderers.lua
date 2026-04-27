-- =============================================================================
-- DYNAMIC TRADING: SHARED PORTRAIT RENDERERS
-- =============================================================================
-- Shared helpers for portrait backgrounds, CRT overlays, and legacy PNG
-- texture resolution.
-- =============================================================================

DT_NPCPortraitRenderers = DT_NPCPortraitRenderers or {}

local function getConfigValue(key, defaultValue)
    if DT_ConfigManager and DT_ConfigManager.settings and DT_ConfigManager.settings[key] ~= nil then
        return DT_ConfigManager.settings[key]
    end

    return defaultValue
end

function DT_NPCPortraitRenderers.Use3DPortraits()
    return getConfigValue("use3DPortraits", true) ~= false
end

function DT_NPCPortraitRenderers.GetBackgroundTexture()
    local hour = GameTime:getInstance():getHour()
    local filename = "twilight"

    if hour >= 4 and hour < 6 then
        filename = "dawn"
    elseif hour >= 6 and hour < 9 then
        filename = "sunrise"
    elseif hour >= 9 and hour < 17 then
        local dayTex = getTexture("media/ui/Backgrounds/day.png")
        if dayTex then
            return dayTex
        end
        filename = "sunrise"
    elseif hour >= 17 and hour < 19 then
        filename = "sunset"
    elseif hour >= 19 and hour < 21 then
        filename = "dusk"
    elseif hour >= 21 or hour < 4 then
        filename = "twilight"
    end

    local path = "media/ui/Backgrounds/" .. filename .. ".png"
    local tex = getTexture(path)
    return tex or getTexture("media/ui/Backgrounds/twilight.png")
end

function DT_NPCPortraitRenderers.GetOverlayTexture()
    return getTexture("media/ui/Effects/crt.png")
end

function DT_NPCPortraitRenderers.GetRadialFadeTexture()
    return getTexture("media/ui/Effects/conversation_radial.png")
end

function DT_NPCPortraitRenderers.GetOverlayAlpha(style, targetData)
    if style == "radio" then
        local alpha = 0.15 + ZombRandFloat(0.0, 0.05)
        if ZombRand(100) < 5 then
            alpha = alpha + ZombRandFloat(0.1, 0.25)
        end
        return math.min(alpha, 0.9)
    end

    if style == "trading" or style == "debug" then
        local chaosFactor = 1.0
        if targetData and targetData.returnTime then
            local timeLeft = targetData.returnTime - GameTime:getInstance():getWorldAgeHours()
            if timeLeft > 24 then
                chaosFactor = 0.0
            elseif timeLeft <= 0 then
                chaosFactor = 1.0
            else
                chaosFactor = 1.0 - (timeLeft / 24.0)
            end
        end

        local alpha = (0.15 + (chaosFactor * 0.3)) + ZombRandFloat(0.0, 0.05 + (chaosFactor * 0.4))
        return math.min(alpha, 0.9)
    end

    return nil
end

function DT_NPCPortraitRenderers.GetLegacyTexture(targetData, provider)
    if not targetData then
        return nil
    end

    if targetData.texture then
        return targetData.texture
    end

    local archetype = targetData.archetype or targetData.archetypeID or targetData.role or "General"
    local isFemale = targetData.isFemale == true or targetData.gender == "Female"
    local gender = isFemale and "Female" or "Male"
    local seed = targetData.identitySeed or 1

    local mappedID = 1
    if provider and provider.getPortraitID then
        mappedID = provider:getPortraitID(archetype, gender, seed)
    elseif DynamicTrading and DynamicTrading.Portraits and DynamicTrading.Portraits.GetMappedID then
        mappedID = DynamicTrading.Portraits.GetMappedID(archetype, gender, seed)
    end

    local pathFolder = "media/ui/Portraits/" .. archetype .. "/" .. gender .. "/"
    if provider and provider.getPortraitPath then
        pathFolder = provider:getPortraitPath(archetype, gender)
    elseif DynamicTrading and DynamicTrading.Portraits and DynamicTrading.Portraits.GetPathFolder then
        pathFolder = DynamicTrading.Portraits.GetPathFolder(archetype, gender)
    end

    local tex = getTexture(pathFolder .. tostring(mappedID) .. ".png")
    if tex then
        return tex
    end

    return getTexture("media/ui/Portraits/General/" .. gender .. "/1.png")
end

return DT_NPCPortraitRenderers
