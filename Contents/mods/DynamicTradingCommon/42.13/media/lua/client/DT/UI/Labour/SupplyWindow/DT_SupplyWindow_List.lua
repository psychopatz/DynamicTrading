DT_SupplyWindow = DT_SupplyWindow or {}
DT_SupplyWindow.Internal = DT_SupplyWindow.Internal or {}

local Internal = DT_SupplyWindow.Internal
local LabourSupplyList = ISScrollingListBox:derive("LabourSupplyList")

function LabourSupplyList:new(x, y, width, height, mode)
    local o = ISScrollingListBox:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.itemheight = 46
    o.selected = -1
    o.font = UIFont.Small
    o.mode = mode or "player"
    return o
end

function LabourSupplyList:doDrawItem(y, item, alt)
    local entry = item.item
    if not entry then
        return y + self.itemheight
    end

    local width = self:getWidth()
    local isSelected = self.selected == item.index
    if isSelected then
        self:drawRect(0, y, width, self.itemheight, 0.25, 0.18, 0.38, 0.62)
    elseif self.mode == "player" and not entry.canDeposit then
        self:drawRect(0, y, width, self.itemheight, 0.15, 0.15, 0.08, 0.08)
    elseif alt then
        self:drawRect(0, y, width, self.itemheight, 0.08, 1, 1, 1)
    end

    self:drawRectBorder(0, y, width, self.itemheight, 0.08, 1, 1, 1)

    if entry.texture then
        local alpha = 1
        if self.mode == "player" and not entry.canDeposit then
            alpha = 0.35
        end
        self:drawTextureScaled(entry.texture, 6, y + 7, 28, 28, alpha, 1, 1, 1)
    end

    local textR, textG, textB = 0.9, 0.9, 0.9
    if self.mode == "player" and not entry.canDeposit then
        textR, textG, textB = 0.45, 0.45, 0.45
    end

    self:drawText(Internal.formatEntryLabel(entry), 42, y + 5, textR, textG, textB, 1, UIFont.Small)

    local statText
    if self.mode == "worker" then
        statText = string.format("%.0f cal left | %.0f hyd left", entry.calories or 0, entry.hydration or 0)
    elseif entry.canDeposit then
        statText = string.format("+%.0f cal | +%.0f hyd", entry.calories or 0, entry.hydration or 0)
    else
        statText = "No calories or hydration"
    end
    self:drawText(statText, 42, y + 23, 0.65, 0.8, 0.95, 1, UIFont.Small)

    local badgeText = self.mode == "worker" and (entry.pending and "Pending" or "Stored")
        or (entry.canDeposit and "Ready" or "Preview")
    local badgeR, badgeG, badgeB = 0.72, 0.72, 0.72
    if badgeText == "Ready" then
        badgeR, badgeG, badgeB = 0.52, 0.9, 0.62
    elseif badgeText == "Preview" then
        badgeR, badgeG, badgeB = 0.86, 0.74, 0.52
    elseif badgeText == "Pending" then
        badgeR, badgeG, badgeB = 0.96, 0.82, 0.42
    else
        badgeR, badgeG, badgeB = 0.55, 0.76, 0.98
    end

    self:drawTextRight(badgeText, width - 8, y + 5, badgeR, badgeG, badgeB, 1, UIFont.Small)

    return y + self.itemheight
end

Internal.LabourSupplyList = LabourSupplyList
