DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

function DT_SupplyWindow.Open(worker)
    if not worker or not worker.workerID then
        return
    end

    local window = DT_SupplyWindow.instance
    if not window then
        local width = 820
        local height = 520
        local x = (getCore():getScreenWidth() - width) / 2
        local y = (getCore():getScreenHeight() - height) / 2

        window = DT_SupplyWindow:new(x, y, width, height)
        window:initialise()
        window:instantiate()
        DT_SupplyWindow.instance = window
    end

    window.workerID = worker.workerID
    window.workerName = worker.name or worker.workerID
    window.title = "Labour Supplies - " .. tostring(window.workerName)
    window:setVisible(true)
    window:addToUIManager()
    window:bringToTop()
    window:startInventoryScan()
    window:updateStatus("Supplying " .. tostring(window.workerName) .. ".")
end

function DT_SupplyWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_SupplyWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.title = "Labour Supplies"
    o.resizable = true
    o.entries = {}
    o.selectedEntry = nil
    o.workerID = nil
    o.workerName = nil
    return o
end
