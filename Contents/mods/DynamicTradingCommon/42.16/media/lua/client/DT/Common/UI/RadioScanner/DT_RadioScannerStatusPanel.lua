require "ISUI/ISPanel"

DT_RadioScannerStatusPanel = ISPanel:derive("DT_RadioScannerStatusPanel")

local function clamp(value, minValue, maxValue)
    if value < minValue then
        return minValue
    end
    if value > maxValue then
        return maxValue
    end
    return value
end

function DT_RadioScannerStatusPanel:initialise()
    ISPanel.initialise(self)
    self.status = self.status or {}
end

function DT_RadioScannerStatusPanel:setStatus(status)
    self.status = status or {}
end

function DT_RadioScannerStatusPanel:prerender()
    ISPanel.prerender(self)

    if self.parent and self.parent.device and DT_RadioScannerManager and DT_RadioScannerManager.GetScanStatus then
        local player = getSpecificPlayer(0)
        self.status = DT_RadioScannerManager.GetScanStatus(self.parent.device, player)
    end
end

function DT_RadioScannerStatusPanel:render()
    ISPanel.render(self)

    local status = self.status or {}
    local padding = 12
    local headerY = 4
    local barX = padding
    local barY = 20
    local barW = math.max(120, self.width - (padding * 2))
    local barH = 16
    local progress = clamp(tonumber(status.cooldownProgress) or 0, 0, 1)
    local canScan = status.canScan == true
    local remainingMs = math.max(0, tonumber(status.remainingMs) or 0)
    local cooldownMinutes = math.max(1, tonumber(status.cooldownMinutes) or 1)
    local foundCount = math.max(0, tonumber(status.foundCount) or 0)
    local capacity = math.max(1, tonumber(status.capacity) or 1)
    local lockedCount = math.max(0, tonumber(status.lockedCount) or 0)
    local availableSlots = math.max(0, tonumber(status.availableSlots) or 0)
    local deviceDesc = tostring(status.deviceDesc or "Unknown Receiver")

    self:drawRect(0, 0, self.width, self.height, 0.35, 0.02, 0.02, 0.02)
    self:drawRectBorder(0, 0, self.width, self.height, 0.65, 0.28, 0.28, 0.28)

    self:drawText("SCAN COOLDOWN", barX, headerY, 0.82, 0.82, 0.82, 1, UIFont.Small)
    self:drawRect(barX, barY, barW, barH, 0.85, 0.05, 0.05, 0.05)
    self:drawRectBorder(barX, barY, barW, barH, 0.9, 0.3, 0.3, 0.3)

    local fillColor = canScan and { r = 0.18, g = 0.68, b = 0.22 } or { r = 0.84, g = 0.54, b = 0.16 }
    local fillW = math.max(0, math.floor((barW - 2) * progress))
    if fillW > 0 then
        self:drawRect(barX + 1, barY + 1, fillW, barH - 2, 0.95, fillColor.r, fillColor.g, fillColor.b)
    end

    local cooldownText = "READY"
    if not canScan then
        local totalSeconds = math.max(0, math.ceil(remainingMs / 1000))
        local minutes = math.floor(totalSeconds / 60)
        local seconds = totalSeconds % 60
        cooldownText = string.format("%02d:%02d / %dm", minutes, seconds, cooldownMinutes)
    end
    self:drawTextRight(cooldownText, self.width - padding, headerY, 1, 1, 1, 1, UIFont.Small)

    local detailY = barY + barH + 10
    self:drawText("Channels: " .. tostring(foundCount) .. "/" .. tostring(capacity), padding, detailY, 0.88, 0.88, 0.88, 1, UIFont.Small)
    self:drawText(string.format("Locked: %d   Free: %d", lockedCount, availableSlots), math.floor(self.width * 0.37), detailY, 0.72, 0.86, 1.0, 1, UIFont.Small)
    self:drawTextRight(deviceDesc, self.width - padding, detailY, 0.65, 0.65, 0.65, 1, UIFont.Small)
end

function DT_RadioScannerStatusPanel:new(x, y, width, height)
    local o = ISPanel:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
    o.status = {}
    return o
end