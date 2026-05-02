DynamicTrading = DynamicTrading or {}
DynamicTrading.Abstract = DynamicTrading.Abstract or {}
DynamicTrading.Abstract.Normalization = DynamicTrading.Abstract.Normalization or {}

local Buckets = DynamicTrading.Abstract.Normalization.Buckets or {}
DynamicTrading.Abstract.Normalization.Buckets = Buckets

Buckets.ORDER = {
    "food_raw_fresh",
    "food_raw_preserved",
    "meals",
    "water_clean",
    "medical_supplies",
    "tools",
    "weapon_parts",
    "ammo_ready",
    "ammo_components",
    "fuel",
    "wood",
    "metal",
    "hardware",
    "textiles",
    "leather",
    "electronics",
    "chemicals",
    "bindings",
}

Buckets.DEFS = {
    food_raw_fresh = { label = "Food: Fresh", shortLabel = "Fresh Food", description = "Raw or lightly processed perishables that still need cooking, storage, or fast use.", color = { r = 0.53, g = 0.86, b = 0.47 } },
    food_raw_preserved = { label = "Food: Preserved", shortLabel = "Preserved Food", description = "Shelf-stable food stocks like canned, dried, jarred, or dry goods.", color = { r = 0.78, g = 0.82, b = 0.48 } },
    meals = { label = "Meals", shortLabel = "Meals", description = "Ready-to-eat prepared food that colonists can consume directly.", color = { r = 0.95, g = 0.73, b = 0.38 } },
    water_clean = { label = "Water", shortLabel = "Water", description = "Clean drinkable water or water-bearing items treated as safe hydration stock.", color = { r = 0.42, g = 0.76, b = 1.0 } },
    medical_supplies = { label = "Medical Supplies", shortLabel = "Medical", description = "Medical consumables and treatment materials used for healing, sanitation, and recovery.", color = { r = 1.0, g = 0.48, b = 0.48 } },
    tools = { label = "Tools", shortLabel = "Tools", description = "General-purpose implements and utility gear useful for work, repair, and crafting tasks.", color = { r = 0.86, g = 0.86, b = 0.86 } },
    weapon_parts = { label = "Weapon Parts", shortLabel = "Weapon Parts", description = "Weapon components, attachments, or salvage suitable for assembling and repairing arms.", color = { r = 0.96, g = 0.54, b = 0.33 } },
    ammo_ready = { label = "Ammo: Ready", shortLabel = "Ready Ammo", description = "Finished ammunition that is already usable without extra assembly.", color = { r = 0.96, g = 0.82, b = 0.39 } },
    ammo_components = { label = "Ammo Components", shortLabel = "Ammo Parts", description = "Powder, casings, magazines, pellets, and similar parts used to produce usable ammo.", color = { r = 0.86, g = 0.72, b = 0.42 } },
    fuel = { label = "Fuel", shortLabel = "Fuel", description = "Burnable energy stocks such as gasoline, charcoal, propane, or similar combustible inputs.", color = { r = 0.96, g = 0.63, b = 0.29 } },
    wood = { label = "Wood", shortLabel = "Wood", description = "Timber, sticks, branches, planks, and other wood-based construction stock.", color = { r = 0.74, g = 0.54, b = 0.32 } },
    metal = { label = "Metal", shortLabel = "Metal", description = "Metal bars, sheets, scrap, and structural metal stock for heavy crafting and construction.", color = { r = 0.73, g = 0.77, b = 0.82 } },
    hardware = { label = "Hardware", shortLabel = "Hardware", description = "General repair parts like nails, screws, hinges, wire, chains, and small salvage hardware.", color = { r = 0.76, g = 0.8, b = 0.65 } },
    textiles = { label = "Textiles", shortLabel = "Textiles", description = "Cloth, fabric, denim, wool, and other flexible woven material stocks.", color = { r = 0.77, g = 0.65, b = 0.95 } },
    leather = { label = "Leather", shortLabel = "Leather", description = "Leather, hides, pelts, and similar durable animal-based material stock.", color = { r = 0.67, g = 0.49, b = 0.33 } },
    electronics = { label = "Electronics", shortLabel = "Electronics", description = "Electronic salvage, powered components, batteries, and circuitry-based materials.", color = { r = 0.47, g = 0.88, b = 0.88 } },
    chemicals = { label = "Chemicals", shortLabel = "Chemicals", description = "Chemical agents, solvents, cleaners, glues, and reactive crafting substances.", color = { r = 0.84, g = 0.56, b = 0.95 } },
    bindings = { label = "Bindings", shortLabel = "Bindings", description = "Ropes, threads, strips, and fastening fibers used to bind or tie other materials together.", color = { r = 0.95, g = 0.84, b = 0.55 } },
}

function Buckets.Get(bucketID)
    return Buckets.DEFS[tostring(bucketID or "")]
end

function Buckets.IsValid(bucketID)
    return Buckets.Get(bucketID) ~= nil
end

function Buckets.GetOrderedIDs()
    local ids = {}
    for i = 1, #Buckets.ORDER do
        ids[i] = Buckets.ORDER[i]
    end
    return ids
end

function Buckets.GetFilterOptions()
    local options = {
        { id = "", label = "All Buckets" }
    }
    for _, bucketID in ipairs(Buckets.ORDER) do
        local def = Buckets.DEFS[bucketID]
        options[#options + 1] = {
            id = bucketID,
            label = def and def.label or bucketID
        }
    end
    return options
end

return Buckets
