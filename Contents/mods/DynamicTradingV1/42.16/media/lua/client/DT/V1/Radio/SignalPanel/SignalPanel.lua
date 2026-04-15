-- =============================================================================
-- DYNAMIC TRADING V1: SIGNAL PANEL
-- =============================================================================
-- Entry point for the modular Signal Panel.
-- Loads submodules in the same order the original monolithic file defined them.
-- =============================================================================

require "ISUI/ISPanel"
require "ISUI/ISButton"
require "DT/V1/Manager"
require "DT/Common/Config"
require "DT/V1/Utils/DT_OptionsManager"
require "DT/UI/Faction/FactionInfoWindow/DT_FactionInfoWindow"
require "DT/Common/Utils/DT_AudioManager"

DT_SignalPanel = ISPanel:derive("DT_SignalPanel")

require "DT/V1/Radio/SignalPanel/SignalPanel_Core"
require "DT/V1/Radio/SignalPanel/SignalPanel_Children"
require "DT/V1/Radio/SignalPanel/SignalPanel_Layout"
require "DT/V1/Radio/SignalPanel/SignalPanel_State"
require "DT/V1/Radio/SignalPanel/SignalPanel_Render"
require "DT/V1/Radio/SignalPanel/SignalPanel_Actions"
