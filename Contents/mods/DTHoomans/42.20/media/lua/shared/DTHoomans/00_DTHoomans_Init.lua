DTHoomans = DTHoomans or {}
DTHoomans.VERSION = 1
DTHoomans.MOD_ID = "DTHoomans"
DTHoomans.SPAWN_COMMAND = "SpawnTrader"

-- Conversation definitions and the shared eligibility provider are loaded
-- after Project Hoomans so both client menu composition and server authority
-- use the same caravan-role contract.
require "DTHoomans/DTHoomans_Conversation"
require "DTHoomans/DTHoomans_CoreProvider"

if DTCommon and DTCommon.PlacePresentation and type(DTCommon.PlacePresentation.RegisterResolver) == "function" then
    DTCommon.PlacePresentation.RegisterResolver("hoomans_community", function(placeID)
        if not placeID then return nil end
        local Communities = PNC and PNC.Communities
        if Communities and type(Communities.Get) == "function" then
            local community = Communities.Get(placeID)
            if community and type(community.name) == "string" and community.name ~= "" then
                return community.name
            end
        end
        return nil
    end, 100)
end

return DTHoomans
