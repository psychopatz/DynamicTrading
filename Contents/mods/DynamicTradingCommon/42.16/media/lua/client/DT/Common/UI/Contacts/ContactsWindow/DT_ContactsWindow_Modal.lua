local Internal = DT_ContactsWindowInternal
local DT_ContactsDeleteModal = Internal.DeleteModalClass

local function buildDeleteModalText(contact)
    local name = tostring(contact and contact.name or "this contact")
    local reason = tostring(contact and contact.deathReason or "")
    local flavor = tostring(contact and contact.deathFlavorText or "")

    if reason == "Starvation" then
        return string.format(
            "Delete saved contact for %s?\n\nThis trader was lost to starvation. Removing this entry only clears the saved frequency from your contacts list.",
            name
        )
    end

    if reason == "WipedOut" then
        return string.format(
            "Delete saved contact for %s?\n\nThis trader's faction was wiped out. Removing this entry only clears the saved frequency from your contacts list.",
            name
        )
    end

    if tostring(contact and contact.status or "") == "Dead" then
        if flavor ~= "" then
            return string.format(
                "Delete saved contact for %s?\n\nRecorded cause of death: %s. Removing this entry only clears the saved frequency from your contacts list.",
                name,
                flavor
            )
        end
        return string.format(
            "Delete saved contact for %s?\n\nThis trader is deceased. Removing this entry only clears the saved frequency from your contacts list.",
            name
        )
    end

    return string.format(
        "Delete saved contact for %s?\n\nThis only removes the saved number. If you still qualify, you can unlock it again through Chat.",
        name
    )
end

function DT_ContactsDeleteModal:initialise()
    ISCollapsableWindow.initialise(self)
    self:setResizable(false)
end

function DT_ContactsDeleteModal:createChildren()
    local btnW = 100
    local btnH = 24
    local btnGap = 12
    local btnY
    local btnX

    ISCollapsableWindow.createChildren(self)

    btnY = self.height - 34
    btnX = math.floor((self.width - ((btnW * 2) + btnGap)) / 2)

    self.btnYes = ISButton:new(btnX, btnY, btnW, btnH, "Yes", self, self.onConfirm)
    self.btnYes:initialise()
    self.btnYes.backgroundColor = { r = 0.15, g = 0.45, b = 0.15, a = 1.0 }
    self.btnYes.borderColor = { r = 1, g = 1, b = 1, a = 0.35 }
    self:addChild(self.btnYes)

    self.btnNo = ISButton:new(btnX + btnW + btnGap, btnY, btnW, btnH, "No", self, self.onCancel)
    self.btnNo:initialise()
    self.btnNo.backgroundColor = { r = 0.45, g = 0.1, b = 0.1, a = 1.0 }
    self.btnNo.borderColor = { r = 1, g = 1, b = 1, a = 0.35 }
    self:addChild(self.btnNo)
end

function DT_ContactsDeleteModal:render()
    local text = tostring(self.modalText or "")
    local lines
    local startY
    local lineH
    local index
    local line

    ISCollapsableWindow.render(self)

    lines = Internal.WrapUIText(text, self.width - 36, UIFont.Small)
    startY = self:titleBarHeight() + 24
    lineH = getTextManager():getFontHeight(UIFont.Small)

    for index, line in ipairs(lines) do
        self:drawTextCentre(tostring(line), self.width / 2, startY + ((index - 1) * lineH), 0.94, 0.94, 0.94, 1, UIFont.Small)
    end
end

function DT_ContactsDeleteModal:onConfirm()
    if self.owner and self.owner.onDeleteContactConfirmed then
        self.owner:onDeleteContactConfirmed(nil, { internal = "YES" })
    end
    self:close()
end

function DT_ContactsDeleteModal:onCancel()
    self:close()
end

function DT_ContactsDeleteModal:close()
    self:setVisible(false)
    self:removeFromUIManager()
end

function DT_ContactsDeleteModal.Show(owner, contact)
    local width = 420
    local height = 170
    local x
    local y
    local modal

    if not owner then
        return nil
    end

    x = owner:getX() + math.max(20, math.floor((owner:getWidth() - width) / 2))
    y = owner:getY() + math.max(30, math.floor((owner:getHeight() - height) / 2))

    modal = DT_ContactsDeleteModal:new(x, y, width, height)
    modal:initialise()
    modal.title = "Confirm Contact Removal"
    modal.owner = owner
    modal.contact = contact
    modal.modalText = buildDeleteModalText(contact)
    modal:addToUIManager()
    return modal
end
