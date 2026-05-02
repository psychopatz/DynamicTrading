DynamicTrading = DynamicTrading or {}
DynamicTrading.DebugUI = DynamicTrading.DebugUI or {}

local PaneUtils = DynamicTrading.DebugUI.PaneUtils or {}
DynamicTrading.DebugUI.PaneUtils = PaneUtils

function PaneUtils.RelayoutEmbeddedScrollbars(widget)
    if not widget then
        return
    end

    if widget.vscroll then
        local widgetWidth = widget.getWidth and widget:getWidth() or widget.width or 0
        local widgetHeight = widget.getHeight and widget:getHeight() or widget.height or 0
        local vscrollWidth = widget.vscroll.getWidth and widget.vscroll:getWidth() or widget.vscroll.width or 12
        local vscrollHeight = widgetHeight
        if widget.hscroll and (widget.hscroll.isVisible and widget.hscroll:isVisible() or widget.hscroll.visible) then
            local hscrollHeight = widget.hscroll.getHeight and widget.hscroll:getHeight() or widget.hscroll.height or 12
            vscrollHeight = math.max(0, vscrollHeight - hscrollHeight)
        end
        widget.vscroll:setX(math.max(0, widgetWidth - vscrollWidth))
        widget.vscroll:setY(0)
        widget.vscroll:setHeight(vscrollHeight)
        widget.vscroll:bringToTop()
    end

    if widget.hscroll then
        local widgetWidth = widget.getWidth and widget:getWidth() or widget.width or 0
        local widgetHeight = widget.getHeight and widget:getHeight() or widget.height or 0
        local hscrollHeight = widget.hscroll.getHeight and widget.hscroll:getHeight() or widget.hscroll.height or 12
        local hscrollWidth = widgetWidth
        if widget.vscroll and (widget.vscroll.isVisible and widget.vscroll:isVisible() or widget.vscroll.visible) then
            local vscrollWidth = widget.vscroll.getWidth and widget.vscroll:getWidth() or widget.vscroll.width or 12
            hscrollWidth = math.max(0, hscrollWidth - vscrollWidth)
        end
        widget.hscroll:setX(0)
        widget.hscroll:setY(math.max(0, widgetHeight - hscrollHeight))
        widget.hscroll:setWidth(hscrollWidth)
        widget.hscroll:bringToTop()
    end
end

function PaneUtils.RefreshRichText(widget, text, resetScroll)
    if not widget then
        return
    end

    if text ~= nil and widget.setText then
        widget:setText(text)
    end

    if widget.onResize then
        pcall(function()
            widget:onResize()
        end)
    end

    if widget.paginate then
        widget:paginate()
    end

    PaneUtils.RelayoutEmbeddedScrollbars(widget)

    if resetScroll ~= false and widget.setYScroll then
        widget:setYScroll(0)
    end
end

return PaneUtils
