-- =============================================================================
-- DYNAMIC TRADING: SHARED PORTRAIT UI
-- =============================================================================
-- Entry point for shared portrait modules used by Trading, Conversation, and
-- portrait debug tools.
-- =============================================================================

require "DT/Common/UI/Portrait/DT_NPCPortraitRenderers"
require "DT/Common/UI/Portrait/DT_NPCPortraitDescriptor"
require "DT/Common/UI/Portrait/DT_NPCPortraitResolver"
require "DT/Common/UI/Portrait/NPCPortraitPanel/DT_NPCPortraitPanel"

return DT_NPCPortraitPanel
