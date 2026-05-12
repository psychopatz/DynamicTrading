require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanel"
require "ISUI/ISScrollingListBox"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISModalDialog"
require "Utils/DT_StringUtils"
require "DT/Common/Contacts/DT_TraderContacts"
require "DT/Common/UI/Contacts/DT_ContactsConversation"
require "DT/Common/UI/Portrait/Portrait"

DT_ContactsWindow = DT_ContactsWindow or ISCollapsableWindow:derive("DT_ContactsWindow")
DT_ContactsWindow.instance = DT_ContactsWindow.instance or nil
DT_ContactsWindowInternal = DT_ContactsWindowInternal or {}

require "DT/Common/UI/Contacts/ContactsWindow/DT_ContactsWindow_Shared"
require "DT/Common/UI/Contacts/ContactsWindow/DT_ContactsWindow_Modal"
require "DT/Common/UI/Contacts/ContactsWindow/DT_ContactsWindow_Panels"
require "DT/Common/UI/Contacts/ContactsWindow/DT_ContactsWindow_Lifecycle"
require "DT/Common/UI/Contacts/ContactsWindow/DT_ContactsWindow_List"
require "DT/Common/UI/Contacts/ContactsWindow/DT_ContactsWindow_Actions"

return DT_ContactsWindow
