local Internal = DT_ContactsWindowInternal

Internal.AUTO_REFRESH_TICKS = 180
Internal.HeaderPanelClass = Internal.HeaderPanelClass or ISPanel:derive("DT_ContactsHeaderPanel")
Internal.StatusPanelClass = Internal.StatusPanelClass or ISPanel:derive("DT_ContactsStatusPanel")
Internal.DeleteModalClass = Internal.DeleteModalClass or ISCollapsableWindow:derive("DT_ContactsDeleteModal")

function Internal.ResolveSelectedContact(list, itemOrContact)
    local selectedIndex
    local selectedItem

    if type(itemOrContact) == "table" then
        if type(itemOrContact.item) == "table" then
            return itemOrContact.item
        end
        if itemOrContact.id or itemOrContact.uuid or itemOrContact.traderID then
            return itemOrContact
        end
    end

    selectedIndex = list and list.selected or 0
    if list and list.items and selectedIndex and selectedIndex > 0 then
        selectedItem = list.items[selectedIndex]
        if selectedItem and type(selectedItem.item) == "table" then
            return selectedItem.item
        end
    end

    return nil
end

function Internal.WrapUIText(text, maxWidth, font)
    if DynamicTrading and DynamicTrading.Utils and DynamicTrading.Utils.WrapText then
        return DynamicTrading.Utils.WrapText(tostring(text or ""), maxWidth, font or UIFont.Small)
    end

    return { tostring(text or "") }
end

function Internal.GetContactsAPI()
    local api = DT_TraderContacts

    if type(api) == "table" then
        return api
    end

    pcall(require, "DT/Common/Contacts/DT_TraderContacts")
    api = DT_TraderContacts
    if type(api) == "table" then
        return api
    end

    return nil
end
