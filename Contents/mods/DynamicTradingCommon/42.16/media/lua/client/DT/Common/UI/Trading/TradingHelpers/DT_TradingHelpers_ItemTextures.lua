require "DT/Common/Utils/DT_ItemIconUtils"

function DT_TradingWindow.GetItemTexture(fullType, itemObj)
    DT_TradingWindow.TextureCache = DT_TradingWindow.TextureCache or {}
    return DynamicTrading.ItemIconUtils.GetTexture(
        fullType,
        itemObj,
        DT_TradingWindow.TextureCache,
        "media/ui/Effects/crt.png"
    )
end
