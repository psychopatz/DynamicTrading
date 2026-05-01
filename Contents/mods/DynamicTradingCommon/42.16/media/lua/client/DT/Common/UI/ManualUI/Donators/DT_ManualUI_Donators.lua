DT_ManualUI_Donators = DT_ManualUI_Donators or {}

local function donorGetMillis()
    if getTimeInMillis then
        return tonumber(getTimeInMillis()) or 0
    end

    local gt = getGameTime and getGameTime() or nil
    if gt and gt.getWorldAgeHours then
        return math.floor((tonumber(gt:getWorldAgeHours()) or 0) * 3600000)
    end

    return 0
end

local function donorNormalizeEntry(entry)
    entry = entry or {}
    return {
        id = tostring(entry.id or ""),
        name = tostring(entry.name or ""),
        totalDonation = tonumber(entry.totalDonation or entry.total_donation) or 0,
        imagePath = tostring(entry.imagePath or entry.image_path or ""),
        supportMessage = tostring(entry.supportMessage or entry.support_message or entry.message or ""),
        active = entry.active ~= false,
    }
end

function DT_ManualUI_Donators.GetCurrentMillis()
    return donorGetMillis()
end

function DT_ManualUI_Donators.FormatDonation(totalDonation, currencySymbol)
    local amount = tonumber(totalDonation) or 0
    local symbol = tostring(currencySymbol or "$")
    if math.floor(amount) == amount then
        return symbol .. tostring(math.floor(amount))
    end
    return symbol .. string.format("%.2f", amount)
end

function DT_ManualUI_Donators.GetActiveSupportersFromBlock(block)
    -- If the block declares a reference to another manual's carousel, pull from there instead.
    local ref = block and (block.supportersRef or block.supporters_ref)
    if ref and ref ~= "" then
        local registry = DynamicTrading and DynamicTrading.Manuals and DynamicTrading.Manuals.Registry or {}
        local refManual = registry[tostring(ref)]
        if refManual then
            local refBlock = DT_ManualUI_Donators.GetPrimaryCarouselBlock(refManual)
            if refBlock then
                block = refBlock
            end
        end
    end

    local supporters = {}
    for _, entry in ipairs((block and block.supporters) or {}) do
        local normalized = donorNormalizeEntry(entry)
        if normalized.active ~= false then
            table.insert(supporters, normalized)
        end
    end

    table.sort(supporters, function(left, right)
        if left.totalDonation == right.totalDonation then
            return string.lower(left.name or "") < string.lower(right.name or "")
        end
        return left.totalDonation > right.totalDonation
    end)

    return supporters
end

function DT_ManualUI_Donators.GetPrimaryCarouselBlock(manual)
    local content = DynamicTrading
        and DynamicTrading.Manuals
        and DynamicTrading.Manuals.EnsureManualContent
        and DynamicTrading.Manuals.EnsureManualContent(manual)
        or nil

    for _, page in ipairs((content and content.pages) or (manual and manual.pages) or {}) do
        for _, block in ipairs(page.blocks or {}) do
            if tostring(block.type or "") == "supporter_carousel" then
                return block
            end
        end
    end
    return nil
end

function DT_ManualUI_Donators.GetCarouselFrame(supporters, autoplayMs, transitionMs)
    local count = supporters and #supporters or 0
    if count <= 0 then
        return 0, 0, 0
    end
    if count == 1 then
        return 1, 1, 0
    end

    local duration = math.max(1000, tonumber(autoplayMs) or 4000)
    local blendDuration = math.max(0, tonumber(transitionMs) or 300)
    local now = donorGetMillis()
    local cycle = now % duration
    local baseIndex = math.floor(now / duration) % count
    local currentIndex = baseIndex + 1
    local nextIndex = (baseIndex + 1) % count + 1

    if blendDuration <= 0 or cycle < (duration - blendDuration) then
        return currentIndex, nextIndex, 0
    end

    local progress = (cycle - (duration - blendDuration)) / blendDuration
    if progress < 0 then progress = 0 end
    if progress > 1 then progress = 1 end
    return currentIndex, nextIndex, progress
end
