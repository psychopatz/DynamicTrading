-- =============================================================================
-- DYNAMIC TRADING COMMON: SERVER HELPERS - WORLD LOGIC
-- =============================================================================
local Helpers = DynamicTrading.ServerHelpers

-- =============================================================================
-- 3. WORLD INTERACTION (UNPACK TO GROUND)
-- =============================================================================

--- Drops all items from a container to the ground at the player's feet.
-- Used for "Unpack Bag" type actions.
-- @param player IsoPlayer The player.
-- @param bag InventoryContainer The bag item to unpack.
function Helpers.DropContainerToGround(player, bag)
    if not player or not bag then return end
    if not instanceof(bag, "InventoryContainer") then return end
    
    local container = bag:getItemContainer()
    local items = container:getItems()
    local square = player:getSquare()
    
    if not square or not items or items:isEmpty() then return end
    
    -- Iterate backwards because we are removing items
    for i = items:size() - 1, 0, -1 do
        local item = items:get(i)
        if item then
            -- 1. Remove from bag
            container:DoRemoveItem(item)
            
            -- Sync Removal (MP)
            if Helpers.ShouldSendNetworkPackets() then
                sendRemoveItemFromContainer(container, item)
            end
            
            -- 2. Add to world (at player's location with slight offset)
            local offX = (ZombRand(100) / 100) * 0.4 - 0.2
            local offY = (ZombRand(100) / 100) * 0.4 - 0.2
            
            square:AddWorldInventoryItem(item, 0.5 + offX, 0.5 + offY, 0)
        end
    end
end
