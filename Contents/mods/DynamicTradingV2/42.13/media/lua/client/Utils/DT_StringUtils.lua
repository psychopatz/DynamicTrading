-- =============================================================================
-- DYNAMIC TRADING: STRING UTILITIES
-- =============================================================================
-- Centralized text manipulation for UI elements.
-- Usage: require "Utils/DT_StringUtils"
-- Access: DynamicTrading.Utils.WrapText(...)

DynamicTrading = DynamicTrading or {}
DynamicTrading.Utils = {}

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