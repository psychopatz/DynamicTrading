require "ISUI/ISCollapsableWindow"
require "DT/UI/Labour/DT_LabourSkillPanel"
require "DT/Common/Labour/LabourConfig/DT_LabourConfig"

DT_LabourCharacterWindow = ISCollapsableWindow:derive("DT_LabourCharacterWindow")
DT_LabourCharacterWindow.instance = nil

local function sendLabourCommand(command, args)
    local player = DT_Labour.Config.GetPlayerObject and DT_Labour.Config.GetPlayerObject() or nil
    if not player then
        return false
    end

    if isClient() and not isServer() then
        sendClientCommand(player, "DynamicTrading_V2", command, args or {})
        return true
    end

    if DT_Labour and DT_Labour.Network and DT_Labour.Network.HandleCommand then
        DT_Labour.Network.HandleCommand(player, command, args or {})
        return true
    end

    return false
end

function DT_LabourCharacterWindow.OpenWorker(worker)
    if not worker or not worker.workerID then
        return
    end

    local window = DT_LabourCharacterWindow.instance
    if not window then
        local width = 760
        local height = 700
        local x = (getCore():getScreenWidth() - width) / 2
        local y = (getCore():getScreenHeight() - height) / 2
        window = DT_LabourCharacterWindow:new(x, y, width, height)
        window:initialise()
        window:instantiate()
        DT_LabourCharacterWindow.instance = window
    end

    window.workerID = worker.workerID
    window.title = "Character - " .. tostring(worker.name or worker.workerID)
    window:setVisible(true)
    window:addToUIManager()
    window:bringToTop()
    window:setWorkerData(worker)
    window:requestWorkerDetails()
end

function DT_LabourCharacterWindow:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.resizable = true
    o.workerID = nil
    return o
end

function DT_LabourCharacterWindow:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(true)
end

function DT_LabourCharacterWindow:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    self.skillPanel = DT_LabourSkillPanel:new(10, th + 10, self.width - 20, self.height - th - 20)
    self.skillPanel:initialise()
    self.skillPanel:setAnchorRight(true)
    self.skillPanel:setAnchorBottom(true)
    self:addChild(self.skillPanel)
end

function DT_LabourCharacterWindow:setWorkerData(worker)
    if worker then
        self.title = "Character - " .. tostring(worker.name or worker.workerID)
    end
    if self.skillPanel then
        self.skillPanel:setWorkerData(worker)
    end
end

function DT_LabourCharacterWindow:requestWorkerDetails()
    if not self.workerID then
        return
    end

    sendLabourCommand("RequestWorkerDetails", {
        workerID = self.workerID,
        includeWarehouseLedgers = false
    })
end

function DT_LabourCharacterWindow:close()
    self:setVisible(false)
    self:removeFromUIManager()
end
