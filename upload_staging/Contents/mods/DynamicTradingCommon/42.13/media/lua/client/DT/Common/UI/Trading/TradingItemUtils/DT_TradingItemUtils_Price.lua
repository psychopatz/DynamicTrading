if not DT_TradingItemUtils then DT_TradingItemUtils = {} end

--- Determines the R, G, B colors for the price text.
function DT_TradingItemUtils.getPriceColors(listItem, isLocked)
    local r, g, b = 0.6, 1.0, 0.6

    if isLocked then
        return 0.4, 0.4, 0.4
    end

    if listItem.isBuy then
        if listItem.priceMod > 1.01 then
            r, g, b = 1.0, 0.4, 0.4
        elseif listItem.priceMod < 0.99 then
            r, g, b = 0.2, 1.0, 1.0
        end
    elseif listItem.priceMod > 1.01 then
        r, g, b = 1.0, 0.8, 0.2
    end

    return r, g, b
end
