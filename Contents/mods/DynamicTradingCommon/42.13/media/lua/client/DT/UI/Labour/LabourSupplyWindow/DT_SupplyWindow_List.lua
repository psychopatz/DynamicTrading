DT_LabourSupplyWindow = DT_LabourSupplyWindow or {}
DT_LabourSupplyWindow.Internal = DT_LabourSupplyWindow.Internal or {}

local Internal = DT_LabourSupplyWindow.Internal
local LabourSupplyList = ISScrollingListBox:derive("LabourSupplyList")

function LabourSupplyList:new(x, y, width, height)
    local o = ISScrollingListBox:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    o.itemheight = 44
    o.selected = -1
    o.font = UIFont.Small
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
    elseif not entry.canDeposit then
        self:drawRect(0, y, width, self.itemheight, 0.15, 0.15, 0.08, 0.08)
    elseif alt then
        self:drawRect(0, y, width, self.itemheight, 0.08, 1, 1, 1)
    end

    self:drawRectBorder(0, y, width, self.itemheight, 0.08, 1, 1, 1)

    if entry.texture then
        self:drawTextureScaled(entry.texture, 6, y + 6, 30, 30, entry.canDeposit and 1 or 0.35, 1, 1, 1)
    end

    local textR, textG, textB = 0.9, 0.9, 0.9
    if not entry.canDeposit then
        textR, textG, textB = 0.45, 0.45, 0.45
    end

    self:drawText(Internal.formatEntryLabel(entry), 44, y + 6, textR, textG, textB, 1, UIFont.Small)

    local statText
    if entry.canDeposit then
        statText = string.format("+%.0f cal | +%.0f hyd", entry.calories or 0, entry.hydration or 0)
    else
        statText = "No calories or hydration"
    end
    self:drawText(statText, 44, y + 24, 0.65, 0.8, 0.95, 1, UIFont.Small)

    return y + self.itemheight
end

Internal.LabourSupplyList = LabourSupplyList
