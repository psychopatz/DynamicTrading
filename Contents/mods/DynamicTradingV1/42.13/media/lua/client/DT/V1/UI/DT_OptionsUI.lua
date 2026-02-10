-- =============================================================================
-- DT_OptionsUI (V1 Bridge)
-- Configures the Common Options UI for V1
-- =============================================================================

require "DT/Common/UI/DT_OptionsUI"
require "DT/V1/UI/DT_SidebarButton"
require "DT/V1/Utils/DT_AudioManager"

-- Configure Common UI for V1
local v1Config = {
    title = "Dynamic Trading Settings",
    audioCategories = {
        { label = "Radio:", configKey = "Radio", exampleSound = "DT_RadioRandom" },
        { label = "Wallet:", configKey = "Wallet", exampleSound = "DT_CasinoRandom" },
        { label = "Trade:", configKey = "Trade", exampleSound = "DT_Cashier" }
    },
    generalSettings = {
         { 
            label = "Show Sidebar Button", 
            configKey = "showSidebar", 
            callback = function(val) 
                if DT_SidebarButton and DT_SidebarButton.UpdateVisibility then 
                    DT_SidebarButton.UpdateVisibility() 
                end 
            end 
         },
         { 
            label = "Enable Sounds", 
            configKey = "enableSound",
            callback = nil
         }
    }
}

DT_OptionsUI.SetConfig(v1Config)
