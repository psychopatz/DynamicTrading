-- =============================================================================
-- ICON & TEXTURE ENGINE (V2 ROBUST)
-- =============================================================================

local function split(str, sep)
    local result = {}
    for s in string.gmatch(str, "([^" .. sep .. "]+)") do
        table.insert(result, s)
    end
    return result
end

local function isValidItemTexture(tex)
    return tex and tex.getName and tex:getName() ~= "Question_Highlight"
end

local function safeCall(target, methodName, ...)
    if not target or not target[methodName] then return nil end
    local ok, result = pcall(target[methodName], target, ...)
    if ok then
        return result
    end
    return nil
end

local function tryTexture(textureName)
    if not textureName or textureName == "" then return nil end
    local tex = getTexture(textureName)
    if isValidItemTexture(tex) then
        return tex
    end
    return nil
end

local function normalizeIconVariants(rawVariants)
    if not rawVariants then
        return nil
    end

    if type(rawVariants) == "string" then
        local variants = {}
        for entry in string.gmatch(rawVariants, "([^;]+)") do
            entry = entry:gsub("^%s+", ""):gsub("%s+$", "")
            if entry ~= "" then
                table.insert(variants, entry)
            end
        end
        return #variants > 0 and variants or nil
    end

    if type(rawVariants) == "table" then
        return #rawVariants > 0 and rawVariants or nil
    end

    if rawVariants.size and rawVariants.get then
        local variants = {}
        for i = 0, rawVariants:size() - 1 do
            local entry = rawVariants:get(i)
            if entry and tostring(entry) ~= "" then
                table.insert(variants, tostring(entry))
            end
        end
        return #variants > 0 and variants or nil
    end

    return nil
end

local function getScriptIconVariants(script)
    if not script then
        return nil
    end

    local candidates = {
        safeCall(script, "getIconsForTexture"),
        safeCall(script, "getIconsForTextures"),
        safeCall(script, "getIconsForTextureString"),
        safeCall(script, "getIconsForTextureChoices"),
    }

    for _, candidate in ipairs(candidates) do
        local variants = normalizeIconVariants(candidate)
        if variants then
            return variants
        end
    end

    return nil
end

local function resolveScriptVariantTexture(script)
    local variants = getScriptIconVariants(script)
    if not variants then
        return nil
    end

    for _, variant in ipairs(variants) do
        local tex = tryTexture("Item_" .. variant) or tryTexture(variant) or tryTexture("media/textures/Item_" .. variant .. ".png")
        if tex then
            return tex
        end
    end

    return nil
end

local function resolveMoveableSpriteTexture(script, itemObj)
    local worldSprite = safeCall(itemObj, "getWorldSprite")
    if (not worldSprite or worldSprite == "") and script then
        worldSprite = safeCall(script, "getWorldObjectSprite")
    end
    if not worldSprite or worldSprite == "" then
        return nil
    end

    local tex = tryTexture(worldSprite)
    if tex then
        return tex
    end

    local sprite = nil
    if getSprite then
        local ok, result = pcall(getSprite, worldSprite)
        if ok then
            sprite = result
        end
    end

    if not sprite and IsoSpriteManager and IsoSpriteManager.instance and IsoSpriteManager.instance.getSprite then
        local ok, result = pcall(IsoSpriteManager.instance.getSprite, IsoSpriteManager.instance, worldSprite)
        if ok then
            sprite = result
        end
    end

    if not sprite then
        return nil
    end

    tex = safeCall(sprite, "getTextureForCurrentFrame", 0)
    if isValidItemTexture(tex) then
        return tex
    end

    tex = safeCall(sprite, "getTexture")
    if isValidItemTexture(tex) then
        return tex
    end

    return nil
end

local function resolveInventoryItemTexture(itemObj)
    if not itemObj then
        return nil
    end

    if instanceof(itemObj, "Clothing") and itemObj.getTex then
        local tex = itemObj:getTex()
        if isValidItemTexture(tex) then
            return tex
        end
    end

    if itemObj.getIcon then
        local icon = itemObj:getIcon()
        if icon and type(icon) ~= "string" and isValidItemTexture(icon) then
            return icon
        end
    end

    local tex = safeCall(itemObj, "getTexture")
    if isValidItemTexture(tex) then
        return tex
    end

    return nil
end

local function resolveGeneratedItemTexture(fullType)
    if not fullType or not InventoryItemFactory or not InventoryItemFactory.CreateItem then
        return nil
    end

    local ok, tempItem = pcall(InventoryItemFactory.CreateItem, fullType)
    if not ok or not tempItem then
        return nil
    end

    return resolveInventoryItemTexture(tempItem)
end

function DT_TradingWindow.GetItemTexture(fullType, itemObj)
    DT_TradingWindow.TextureCache = DT_TradingWindow.TextureCache or {}
    if not itemObj and fullType and DT_TradingWindow.TextureCache[fullType] then
        return DT_TradingWindow.TextureCache[fullType]
    end

    local script = fullType and getScriptManager():getItem(fullType) or nil
    local iconStr = script and safeCall(script, "getIcon") or nil
    local isDefaultMoveableIcon = iconStr and string.lower(iconStr) == "default"

    if isDefaultMoveableIcon then
        local moveableTex = resolveMoveableSpriteTexture(script, itemObj)
        if moveableTex then
            if not itemObj and fullType then
                DT_TradingWindow.TextureCache[fullType] = moveableTex
            end
            return moveableTex
        end
    end

    -- 1. ELEGANT Build 42 APPROACH (Item Instance)
    if itemObj then
        local tex = resolveInventoryItemTexture(itemObj)
        if isValidItemTexture(tex) then
            return tex
        end
    end

    if script then
        local variantTex = resolveScriptVariantTexture(script)
        if variantTex then
            if not itemObj and fullType then
                DT_TradingWindow.TextureCache[fullType] = variantTex
            end
            return variantTex
        end
    end

    -- 2. DYNAMIC LOOKUP (Script/Trader Items where itemObj is nil)
    if script then
        -- If the script has a specific icon string defined
        if iconStr and iconStr ~= "" and not isDefaultMoveableIcon then
            -- Try standard "Item_" prefix first
            local tex = getTexture("Item_" .. iconStr) or getTexture(iconStr)
            if isValidItemTexture(tex) then return tex end

            -- B42 Apparel Path Fallback (common for newer items)
            tex = getTexture("media/textures/Item_" .. iconStr .. ".png")
            if isValidItemTexture(tex) then return tex end
        end

        -- guess: ClothingItem name lookup
        -- Many B42 clothes use their 'ClothingItem' name as the icon key
        if script:getClothingItem() then
            local ciName = script:getClothingItem()
            local tex = getTexture("Item_" .. ciName) or getTexture(ciName)
            if isValidItemTexture(tex) then return tex end
        end

        -- Guess based on fullType (last resort)
        local parts = split(fullType, "%.")
        local shortName = parts[#parts]
        if shortName then
            local guesses = { shortName, "Bag_" .. shortName, "Item_" .. shortName, "Clothing_" .. shortName }
            for _, g in ipairs(guesses) do
                local tex = getTexture("Item_" .. g) or getTexture(g)
                if isValidItemTexture(tex) then
                    if not itemObj and fullType then
                        DT_TradingWindow.TextureCache[fullType] = tex
                    end
                    return tex
                end
            end
        end
    end

    local generatedTex = resolveGeneratedItemTexture(fullType)
    if isValidItemTexture(generatedTex) then
        if not itemObj and fullType then
            DT_TradingWindow.TextureCache[fullType] = generatedTex
        end
        return generatedTex
    end

    -- Final fallback to a generic icon if everything else fails
    return getTexture("media/ui/Effects/crt.png")
end
