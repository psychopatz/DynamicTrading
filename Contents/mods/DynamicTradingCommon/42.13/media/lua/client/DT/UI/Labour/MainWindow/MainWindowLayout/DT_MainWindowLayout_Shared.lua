DT_MainWindow = DT_MainWindow or {}
DT_MainWindow.Internal = DT_MainWindow.Internal or {}

local Internal = DT_MainWindow.Internal
Internal.MainWindowLayout = Internal.MainWindowLayout or {}

local MainWindowLayout = Internal.MainWindowLayout

MainWindowLayout.AUTO_REFRESH_FRAMES = 60
MainWindowLayout.DETAIL_PANEL_MIN_HEIGHT = 120
MainWindowLayout.ACTIVITY_PANEL_MIN_HEIGHT = 150
MainWindowLayout.PANEL_INNER_PAD = 6
MainWindowLayout.PANEL_HEADER_HEIGHT = 24

function MainWindowLayout.refreshRichTextPanel(panel)
    if not panel then
        return
    end

    panel:paginate()
    if panel.vscroll then
        panel.vscroll:setHeight(panel:getHeight())
    end
end

function MainWindowLayout.getRichTextContentHeight(panel)
    if not panel then
        return 0
    end

    local directHeight = tonumber(panel.textHeight) or tonumber(panel.contentHeight)
    if directHeight and directHeight > 0 then
        return directHeight
    end

    local getter = panel.getScrollHeight or panel.getTextHeight
    if getter then
        local ok, value = pcall(getter, panel)
        if ok and tonumber(value) and tonumber(value) > 0 then
            return tonumber(value)
        end
    end

    return 0
end

