-- =============================================================================
-- DYNAMIC TRADING: STRING UTILITIES
-- =============================================================================
-- Centralized text manipulation for UI elements.
-- Usage: require "Utils/DT_StringUtils"
-- Access: DynamicTrading.Utils.WrapText(...)

DynamicTrading = DynamicTrading or {}
DynamicTrading.Utils = DynamicTrading.Utils or {}

-- =============================================================================
-- 1. TEXT WRAPPING
-- =============================================================================
--- Splits a single string into a table of lines that fit within a specific pixel width.
--- Useful for chat boxes, descriptions, and logs.
--- @param text string: The raw text to wrap.
--- @param maxWidth number: The maximum width in pixels allowed per line.
--- @param font any: The font enum (e.g., UIFont.Small) used to measure width.
--- @return table: A list of strings, each representing one line.
function DynamicTrading.Utils.WrapText(text, maxWidth, font)
    local tm = getTextManager()
    local result = {}
    
    if not text then return {""} end
    text = tostring(text)

    -- Step A: Handle existing newlines (paragraphs)
    -- We split the text by "\n" first so we preserve the original formatting.
    local paragraphs = {}
    for s in string.gmatch(text, "[^\r\n]+") do
        table.insert(paragraphs, s)
    end
    if #paragraphs == 0 then table.insert(paragraphs, text) end

    -- Step B: Wrap each paragraph based on visual width
    for _, para in ipairs(paragraphs) do
        local currentLine = ""
        
        -- Iterate through words
        for word in string.gmatch(para, "%S+") do
            local testLine = (currentLine == "") and word or (currentLine .. " " .. word)
            
            -- Check if adding the next word exceeds width
            if tm:MeasureStringX(font, testLine) <= maxWidth then
                currentLine = testLine
            else
                -- If line is full, push it to results
                if currentLine ~= "" then table.insert(result, currentLine) end
                -- Start new line with the current word
                currentLine = word
            end
        end
        
        -- Push the final line of the paragraph
        if currentLine ~= "" then table.insert(result, currentLine) end
    end
    
    -- Safety: Ensure we always return at least one line to prevent UI crashes
    if #result == 0 then return {""} end
    
    return result
end

-- =============================================================================
-- 2. STRING TRUNCATION
-- =============================================================================
--- Cuts off text that is too long and adds "..." at the end.
--- Useful for list items like "Very Long Item Na..."
--- @param text string: The text to shorten.
--- @param font any: The font used for measurement.
--- @param maxWidth number: The maximum pixel width allowed.
--- @return string: The truncated string.
function DynamicTrading.Utils.TruncateString(text, font, maxWidth)
    local tm = getTextManager()
    
    -- If it fits, return immediately (Performance optimization)
    if tm:MeasureStringX(font, text) <= maxWidth then return text end

    local len = #text
    while len > 0 do
        -- Create substring and append ellipsis
        local truncated = string.sub(text, 1, len - 1) .. "..."
        
        -- Check if it fits now
        if tm:MeasureStringX(font, truncated) <= maxWidth then
            return truncated
        end
        len = len - 1
    end
    
    return "..."
end
-- =============================================================================
-- 3. TAG FORMATTING
-- =============================================================================
--- Formats a tag string like "Misc.Decor" or "Resource.Material.Wood"
--- to a more human-readable format like "Misc Decor" or "Resource Material Wood".
--- @param tag string: The raw tag string.
--- @return string: The formatted tag string.
function DynamicTrading.Utils.FormatTag(tag)
    if not tag or type(tag) ~= "string" then return tostring(tag) end
    local result = string.gsub(tag, "%.", " ")
    return result
end

--- Formats a tag string for Category UI, replacing dots with slashes
--- "Electronics.Component.Light" -> "Electronics/Component/Light"
function DynamicTrading.Utils.FormatCategoryString(tag)
    if not tag or type(tag) ~= "string" then return tostring(tag) end
    local result = string.gsub(tag, "%.", "/")
    return result
end

--- Basic English pluralizer helper
function DynamicTrading.Utils.Pluralize(word)
    if not word or word == "" then return "" end
    local lower = string.lower(word)
    
    -- Special/Non-Count Words
    if lower == "general" then return "General items" end
    if lower == "food" then return "Food" end
    if lower == "meat" then return "Meat" end
    if lower == "water" then return "Water" end
    if lower == "medical" then return "Medical supplies" end
    if lower == "armor" then return "Armor" end
    if lower == "clothing" then return "Clothing" end
    if lower == "jewelry" then return "Jewelry" end
    if lower == "cash" then return "Cash" end
    if lower == "ammo" then return "Ammo" end

    local lastChar = string.sub(word, -1):lower()
    local lastTwo = string.sub(word, -2):lower()
    
    if lastChar == "y" and not (lastTwo == "oy" or lastTwo == "ay" or lastTwo == "ey") then
        return string.sub(word, 1, -2) .. "ies"
    elseif lastChar == "s" or lastTwo == "sh" or lastTwo == "ch" or lastChar == "x" then
        return word .. "es"
    else
        return word .. "s"
    end
end

--- Formats a tag specifically for conversational dialogue
--- Omits root, swaps sub & detail, and pluralizes the subcategory.
--- "Electronics.Component.Light" -> "Light Components"
function DynamicTrading.Utils.FormatTagDialogue(tag)
    if not tag or type(tag) ~= "string" then return tostring(tag) end
    
    local parts = {}
    for p in string.gmatch(tag, "[^%.]+") do
        table.insert(parts, p)
    end
    
    if #parts == 3 then
        local subCat = parts[2]
        local details = parts[3]
        return details .. " " .. DynamicTrading.Utils.Pluralize(subCat)
    elseif #parts == 2 then
        return DynamicTrading.Utils.Pluralize(parts[2])
    elseif #parts == 1 then
        return DynamicTrading.Utils.Pluralize(parts[1])
    else
        local result = string.gsub(tag, "%.", " ")
        return result
    end
end

DynamicTrading.Log("DTCommons", "Init", "Utils", "Registered string utilities")