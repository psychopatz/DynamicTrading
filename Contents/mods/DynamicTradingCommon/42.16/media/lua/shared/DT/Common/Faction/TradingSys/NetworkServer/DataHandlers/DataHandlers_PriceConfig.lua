-- ==============================================================================
-- NetworkServer/DataHandlers/DataHandlers_PriceConfig.lua
-- Logic: Price configuration handlers
-- Build 42 Compatible.
-- ==============================================================================

return function(context)
    local Handlers = context.Handlers
    local Helpers = context.Helpers

    Handlers.RequestPriceConfig = function(player, args)
        if not DynamicTrading.PriceConfig.CanEdit(player) then
            Helpers.SendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
            return
        end

        Helpers.SendPriceConfigToPlayer(player)
    end

    Handlers.ApplyPriceTagMultiplier = function(player, args)
        if not DynamicTrading.PriceConfig.CanEdit(player) then
            Helpers.SendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
            return
        end

        local success, reason = DynamicTrading.PriceConfig.SetTagMultiplier(args and args.tag, args and args.multiplier)
        if success then
            Helpers.SendPriceConfigToPlayer(player)
            Helpers.SendPriceConfigActionResult(player, true, "Tag multiplier updated.")
        else
            Helpers.SendPriceConfigActionResult(player, false, reason or "Failed to update tag multiplier.")
        end
    end

    Handlers.ResetPriceTagMultiplier = function(player, args)
        if not DynamicTrading.PriceConfig.CanEdit(player) then
            Helpers.SendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
            return
        end

        local success, reason = DynamicTrading.PriceConfig.ResetTagMultiplier(args and args.tag)
        if success then
            Helpers.SendPriceConfigToPlayer(player)
            Helpers.SendPriceConfigActionResult(player, true, "Tag multiplier reset.")
        else
            Helpers.SendPriceConfigActionResult(player, false, reason or "Failed to reset tag multiplier.")
        end
    end

    Handlers.ApplyItemBasePriceOverride = function(player, args)
        if not DynamicTrading.PriceConfig.CanEdit(player) then
            Helpers.SendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
            return
        end

        local success, reason = DynamicTrading.PriceConfig.SetItemOverride(args and args.itemKey, args and args.basePrice)
        if success then
            Helpers.SendPriceConfigToPlayer(player)
            Helpers.SendPriceConfigActionResult(player, true, "Item base price updated.")
        else
            Helpers.SendPriceConfigActionResult(player, false, reason or "Failed to update item override.")
        end
    end

    Handlers.ResetItemBasePriceOverride = function(player, args)
        if not DynamicTrading.PriceConfig.CanEdit(player) then
            Helpers.SendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
            return
        end

        local success, reason = DynamicTrading.PriceConfig.ResetItemOverride(args and args.itemKey)
        if success then
            Helpers.SendPriceConfigToPlayer(player)
            Helpers.SendPriceConfigActionResult(player, true, "Item override reset.")
        else
            Helpers.SendPriceConfigActionResult(player, false, reason or "Failed to reset item override.")
        end
    end

    Handlers.ResetAllPriceOverrides = function(player, args)
        if not DynamicTrading.PriceConfig.CanEdit(player) then
            Helpers.SendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
            return
        end

        DynamicTrading.PriceConfig.ResetAllOverrides()
        Helpers.SendPriceConfigToPlayer(player)
        Helpers.SendPriceConfigActionResult(player, true, "All price overrides reset.")
    end

    Handlers.ImportPricePreset = function(player, args)
        if not DynamicTrading.PriceConfig.CanEdit(player) then
            Helpers.SendPriceConfigActionResult(player, false, "You do not have permission to edit pricing.")
            return
        end

        if type(args) ~= "table" then
            Helpers.SendPriceConfigActionResult(player, false, "Invalid preset payload.")
            return
        end

        local payload = {
            tagMultipliers = type(args.tagMultipliers) == "table" and args.tagMultipliers or {},
            itemOverrides = type(args.itemOverrides) == "table" and args.itemOverrides or {}
        }

        local success, warnings = DynamicTrading.PriceConfig.ReplaceFromPreset(payload)
        if success then
            Helpers.SendPriceConfigToPlayer(player)
            Helpers.SendPriceConfigActionResult(player, true, "Preset imported.", warnings)
        else
            Helpers.SendPriceConfigActionResult(player, false, "Preset import failed.")
        end
    end
end
