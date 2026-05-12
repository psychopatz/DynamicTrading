-- =============================================================================
-- DYNAMIC TRADING: TRADER CONTACTS
-- =============================================================================

if isServer() then return end

require "DT/Common/Reputation/DT_Reputation"

DT_TraderContacts = DT_TraderContacts or {}
DT_TraderContacts.Internal = DT_TraderContacts.Internal or {}

DT_TraderContacts.VERSION = 3
DT_TraderContacts.MODDATA_KEY = "DT_TraderContacts"
DT_TraderContacts.CHARACTER_KEY_MODDATA = "DT_TraderContactsCharacterKey"
DT_TraderContacts.CONTACT_REPUTATION_REQUIRED = 20
DT_TraderContacts.VISIT_REPUTATION_REQUIRED = 10
DT_TraderContacts.VISIT_REPUTATION_COST = 2

require "DT/Common/Contacts/DT_TraderContacts/DT_TraderContacts_Core"
require "DT/Common/Contacts/DT_TraderContacts/DT_TraderContacts_Persistence"
require "DT/Common/Contacts/DT_TraderContacts/TraderContactsRuntime/DT_TraderContacts_Runtime"
require "DT/Common/Contacts/DT_TraderContacts/DT_TraderContacts_Events"

return DT_TraderContacts
