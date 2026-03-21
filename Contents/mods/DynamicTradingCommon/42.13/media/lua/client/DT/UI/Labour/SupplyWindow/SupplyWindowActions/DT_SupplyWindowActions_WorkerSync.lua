DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

function DT_SupplyWindow:onRefresh()
    self:startInventoryScan()
    if self.workerID then
        self:sendLabourCommand("RequestWorkerDetails", {
            workerID = self.workerID
        })
    end
end

function DT_SupplyWindow:requestWorkerDetails()
    if not self.workerID then
        return
    end

    self:sendLabourCommand("RequestWorkerDetails", {
        workerID = self.workerID
    })
end
