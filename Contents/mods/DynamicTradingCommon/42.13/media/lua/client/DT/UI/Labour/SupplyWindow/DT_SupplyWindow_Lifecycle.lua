DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

function DT_SupplyWindow.Open(worker)
    if not worker or not worker.workerID then
        return
    end

    local window = DT_SupplyWindow.instance
    if not window then
        local width = 980
        local height = 620
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
    window:setWorkerData(DT_SupplyWindow.Internal.resolveWorkerDetail(worker.workerID) or worker)
    window:startInventoryScan()
    window:requestWorkerDetails()
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
    o.playerEntries = {}
    o.playerEntriesByID = {}
    o.workerEntries = {}
    o.selectedPlayerEntry = nil
    o.selectedWorkerEntry = nil
    o.activeSelectionSide = "player"
    o.workerID = nil
    o.workerName = nil
    o.lastPlayerFilter = ""
    o.lastWorkerFilter = ""
    return o
end
