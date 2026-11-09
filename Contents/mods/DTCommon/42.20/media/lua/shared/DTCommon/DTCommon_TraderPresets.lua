-- Dynamic Trading's provider-neutral trader and guard creation presets.
--
-- These are authored Dynamic Trading presets, not copies of Project Hoomans
-- archetype loadouts.  They are deliberately expressed as serializable
-- identity, appearance, and item data so Core can keep an abstract actor and
-- Project Hoomans can materialize the same member without rerolling it.

DTCommon = DTCommon or {}
DTCommon.TraderPresets = DTCommon.TraderPresets or {}

local Presets = DTCommon.TraderPresets

local ACTOR_IDENTITY_EXTENSION = "PsychopatzCore.ActorIdentity"

Presets.SCHEMA_VERSION = 1
Presets.MIN_MEMBER_COUNT = 1
Presets.MAX_MEMBER_COUNT = 24
Presets.DEFAULT_MEMBER_COUNT = 3

local function copy(value, seen)
    if type(value) ~= "table" then return value end
    seen = seen or {}
    if seen[value] then return seen[value] end
    local output = {}
    seen[value] = output
    for key, item in pairs(value) do
        output[copy(key, seen)] = copy(item, seen)
    end
    return output
end

local function item(fullType, wornSlot, options)
    options = type(options) == "table" and options or {}
    local output = {
        type = fullType,
        fullType = fullType,
        quantity = tonumber(options.quantity) or 1,
        stack = tonumber(options.stack) or tonumber(options.quantity) or 1,
        wornSlot = wornSlot,
        equippedSlot = options.equippedSlot,
        equipSlot = options.equipSlot,
        attachedSlot = options.attachedSlot,
        container = options.container or "root",
    }
    if options.itemState then output.itemState = copy(options.itemState) end
    return output
end

local function appearanceFor(definition)
    local slots = {}
    local outfitItems = {}
    local outfitItemSpecs = {}
    local index
    local clothing = definition.clothing or {}
    for index = 1, #clothing do
        local clothingItem = clothing[index]
        local slot = tostring(clothingItem.wornSlot)
        local slotSpec = {
            mode = "item",
            type = clothingItem.type,
            wornSlot = slot,
            itemState = copy(clothingItem.itemState),
        }
        slots[slot] = slotSpec
        outfitItems[#outfitItems + 1] = clothingItem.type
        outfitItemSpecs[#outfitItemSpecs + 1] = copy(slotSpec)
    end

    local policy = {
        schemaVersion = 2,
        mode = "authored",
        authority = "authored",
        outfit = { mode = "none" },
        slots = slots,
        skinTone = definition.skinTone,
        skinTexture = definition.skinTexture,
        skinColor = copy(definition.skinColor),
        hairModel = definition.hairModel,
        hairColor = copy(definition.hairColor),
        beardModel = definition.beardModel,
    }
    return {
        schemaVersion = 2,
        mode = "authored",
        outfit = { mode = "none" },
        slots = copy(slots),
        skinTone = definition.skinTone,
        skinTexture = definition.skinTexture,
        skinColor = copy(definition.skinColor),
        hairModel = definition.hairModel,
        hairColor = copy(definition.hairColor),
        beardModel = definition.beardModel,
        resolved = {
            outfit = { mode = "none" },
            outfitMode = "none",
            outfitItems = outfitItems,
            outfitItemSpecs = outfitItemSpecs,
            skinTone = definition.skinTone,
            skinTexture = definition.skinTexture,
            skinColor = copy(definition.skinColor),
            hairModel = definition.hairModel,
            hairColor = copy(definition.hairColor),
            beardModel = definition.beardModel,
            gender = definition.gender,
        },
        policy = policy,
    }
end

local DEFINITIONS = {
    ["dt.trader.caravan"] = {
        role = "trader",
        archetypeID = "General",
        visualProfile = "dt_trader_caravan",
        gender = "female",
        identities = {
            { forename = "Mara", surname = "Voss", displayName = "Mara Voss" },
            { forename = "Elias", surname = "Voss", displayName = "Elias Voss", gender = "male" },
        },
        skinTone = "tan",
        skinTexture = "FemaleBody01",
        skinColor = { r = 0.72, g = 0.50, b = 0.36 },
        hairModel = "StraightLong",
        hairColor = { r = 0.25, g = 0.12, b = 0.05 },
        beardModel = "",
        clothing = {
            { type = "Base.Hat_Cowboy", wornSlot = "Hat" },
            { type = "Base.Shirt_FormalWhite", wornSlot = "Torso_Upper" },
            { type = "Base.Trousers_Suit", wornSlot = "Legs" },
            { type = "Base.Shoes_Black", wornSlot = "Shoes" },
            { type = "Base.Bag_DuffelBag", wornSlot = "Back" },
        },
        items = {
            item("Base.Hat_Cowboy", "Hat"),
            item("Base.Shirt_FormalWhite", "Torso_Upper"),
            item("Base.Trousers_Suit", "Legs"),
            item("Base.Shoes_Black", "Shoes"),
            item("Base.Bag_DuffelBag", "Back"),
        },
        equipment = {},
    },
    ["dt.guard.shotgun"] = {
        role = "guard",
        archetypeID = "General",
        visualProfile = "dt_guard_shotgun",
        gender = "male",
        identities = {
            { forename = "Cal", surname = "Mercer", displayName = "Cal Mercer" },
            { forename = "Dane", surname = "Holt", displayName = "Dane Holt" },
        },
        skinTone = "olive",
        skinTexture = "MaleBody02",
        skinColor = { r = 0.58, g = 0.38, b = 0.25 },
        hairModel = "Short",
        hairColor = { r = 0.08, g = 0.05, b = 0.03 },
        beardModel = "ShortBoxedBeard",
        clothing = {
            { type = "Base.Hat_BalaclavaFace", wornSlot = "Hat" },
            { type = "Base.Jacket_PaddedDOWN", wornSlot = "Jacket" },
            { type = "Base.Trousers_Padded", wornSlot = "Legs" },
            { type = "Base.Shoes_BlackBoots", wornSlot = "Shoes" },
        },
        items = {
            item("Base.Hat_BalaclavaFace", "Hat"),
            item("Base.Jacket_PaddedDOWN", "Jacket"),
            item("Base.Trousers_Padded", "Legs"),
            item("Base.Shoes_BlackBoots", "Shoes"),
            item("Base.DoubleBarrelShotgun", nil, {
                equipSlot = "primary",
                equippedSlot = "primary",
            }),
            item("Base.ShotgunShells", nil, { quantity = 12, stack = 12 }),
        },
        equipment = {
            primaryFullType = "Base.DoubleBarrelShotgun",
        },
    },
    ["dt.guard.sidearm"] = {
        role = "guard",
        archetypeID = "General",
        visualProfile = "dt_guard_sidearm",
        gender = "female",
        identities = {
            { forename = "Nina", surname = "Cole", displayName = "Nina Cole" },
            { forename = "Tess", surname = "Ward", displayName = "Tess Ward" },
        },
        skinTone = "light",
        skinTexture = "FemaleBody03",
        skinColor = { r = 0.86, g = 0.68, b = 0.53 },
        hairModel = "Ponytail",
        hairColor = { r = 0.48, g = 0.08, b = 0.03 },
        beardModel = "",
        clothing = {
            { type = "Base.Hat_HardHat", wornSlot = "Hat" },
            { type = "Base.Vest_HighViz", wornSlot = "Torso_Upper" },
            { type = "Base.Trousers_Denim", wornSlot = "Legs" },
            { type = "Base.Shoes_WorkBoots", wornSlot = "Shoes" },
        },
        items = {
            item("Base.Hat_HardHat", "Hat"),
            item("Base.Vest_HighViz", "Torso_Upper"),
            item("Base.Trousers_Denim", "Legs"),
            item("Base.Shoes_WorkBoots", "Shoes"),
            item("Base.Pistol", nil, {
                equipSlot = "primary",
                equippedSlot = "primary",
            }),
            item("Base.Bullets9mm", nil, { quantity = 24, stack = 24 }),
        },
        equipment = {
            primaryFullType = "Base.Pistol",
        },
    },
}

function Presets.RegisterCoreArchetypes()
    local core = PsychopatzCore
    local actors = core and core.Actors or nil
    local archetypes = actors and actors.Archetypes or nil
    local presetID
    local definition
    local registered
    local reason
    local coreID
    if not archetypes or type(archetypes.Register) ~= "function" then
        return false, "core_archetype_registry_unavailable"
    end
    for presetID, definition in pairs(DEFINITIONS) do
        coreID = "dynamictrading." .. tostring(presetID)
        registered, reason = archetypes:Register({
            id = coreID,
            aliases = { presetID },
            label = presetID,
            sourceMod = "DynamicTrading",
            tags = { "dynamic_trading", definition.role },
            role = definition.role,
            visualProfile = definition.visualProfile,
            identity = {
                gender = definition.gender,
                profiles = copy(definition.identities),
            },
            appearance = appearanceFor(definition),
            inventory = {
                items = definition.items,
                equipment = definition.equipment,
            },
            extensions = {
                ["dynamictrading.preset"] = {
                    presetID = presetID,
                    role = definition.role,
                    presetVersion = Presets.SCHEMA_VERSION,
                },
            },
        })
        if not registered and reason ~= "already_registered"
            and core.LogWarn
        then
            core.LogWarn(
                "Core archetype registration failed for "
                    .. tostring(presetID) .. ": " .. tostring(reason)
            )
        end
        if not registered then
            return false, reason
        end
    end
    return true, "registered"
end

local function resolveCorePlan(
    presetID, identitySeed, actorID, identity, identityIndex
)
    local actors = PsychopatzCore and PsychopatzCore.Actors or nil
    local archetypes = actors and actors.Archetypes or nil
    if not archetypes or type(archetypes.ResolvePlan) ~= "function" then
        return nil
    end
    return archetypes:ResolvePlan(presetID, {
        actorId = actorID,
        identitySeed = identitySeed,
        identity = identity,
        identityIndex = identityIndex,
    })
end

local function chooseIdentity(definition, memberIndex)
    local identities = definition.identities or {}
    if #identities <= 0 then
        return {
            forename = "Trader",
            surname = "Guard",
            displayName = "Trader Guard",
            gender = definition.gender,
        }
    end
    return copy(identities[((memberIndex - 1) % #identities) + 1])
end

local function safePrefix(value)
    value = tostring(value or "dynamic_trading")
    value = string.gsub(value, "[^%w_:%-%.]", "_")
    if #value > 44 then value = string.sub(value, 1, 44) end
    return value
end

function Presets.Get(presetID)
    return DEFINITIONS[tostring(presetID or "")] and
        copy(DEFINITIONS[tostring(presetID)]) or nil
end

function Presets.List()
    local output = {}
    local actors = PsychopatzCore and PsychopatzCore.Actors or nil
    local archetypes = actors and actors.Archetypes or nil
    local definitions
    local extension
    if archetypes and type(archetypes.List) == "function" then
        definitions = archetypes:List()
        for _, definition in ipairs(definitions) do
            extension = definition.extensions
                and definition.extensions["dynamictrading.preset"] or nil
            if type(extension) == "table" and extension.presetID then
                output[#output + 1] = {
                    id = extension.presetID,
                    role = definition.role or extension.role,
                    visualProfile = definition.visualProfile,
                }
            end
        end
        if #output > 0 then
            table.sort(output, function(left, right)
                return tostring(left.id) < tostring(right.id)
            end)
            return output
        end
    end
    for presetID, definition in pairs(DEFINITIONS) do
        output[#output + 1] = {
            id = presetID,
            role = definition.role,
            visualProfile = definition.visualProfile,
        }
    end
    table.sort(output, function(left, right)
        return tostring(left.id) < tostring(right.id)
    end)
    return output
end

function Presets.PresetIDForMember(memberIndex)
    memberIndex = math.max(1, math.floor(tonumber(memberIndex) or 1))
    if memberIndex == 1 then return "dt.trader.caravan" end
    if memberIndex % 2 == 0 then return "dt.guard.shotgun" end
    return "dt.guard.sidearm"
end

function Presets.Resolve(presetID, memberIndex, identitySeed, actorID)
    local requestedID = tostring(presetID or "")
    local definition = DEFINITIONS[requestedID]
    memberIndex = math.max(1, math.floor(tonumber(memberIndex) or 1))
    local corePlan = resolveCorePlan(
        requestedID, identitySeed, actorID, nil, memberIndex
    )
    if not definition and not corePlan then
        return nil, "trader_preset_not_found"
    end

    if corePlan then
        local coreDefinition = corePlan.definition
        local extension = coreDefinition.extensions
            and coreDefinition.extensions["dynamictrading.preset"] or {}
        local identity = corePlan.identity
        local role = coreDefinition.role or extension.role or "trader"
        local legacyArchetypeID = definition
            and definition.archetypeID or "General"
        return {
            schemaVersion = Presets.SCHEMA_VERSION,
            presetID = requestedID,
            role = role,
            actorID = tostring(actorID or ""),
            identitySeed = identitySeed,
            identity = identity,
            isFemale = tostring(identity.gender or ""):lower() == "female",
            archetypeID = legacyArchetypeID,
            tacticalClass = "neutral",
            visualProfile = coreDefinition.visualProfile,
            appearance = corePlan.appearance,
            startingItems = corePlan.starterItems,
            inventoryAuthority = "canonical",
            equipment = corePlan.equipment,
            coreArchetypeID = corePlan.archetypeID,
            source = {
                ownerMod = "DynamicTrading",
                presetID = requestedID,
                presetVersion = Presets.SCHEMA_VERSION,
            },
        }
    end

    local identityDefinition = chooseIdentity(definition, memberIndex)
    local gender = identityDefinition.gender or definition.gender
    local identity = {
        schemaVersion = 1,
        identitySeed = identitySeed,
        archetypeID = definition.archetypeID,
        displayName = identityDefinition.displayName,
        gender = gender,
        survivor = {
            forename = identityDefinition.forename,
            surname = identityDefinition.surname,
            gender = gender,
            skinTexture = (gender == "female" and "FemaleBody01" or "MaleBody02"),
            skinColor = copy(definition.skinColor),
            hairModel = definition.hairModel,
            hairColor = copy(definition.hairColor),
            beardModel = gender == "female" and "" or definition.beardModel,
        },
    }
    local appearanceDefinition = copy(definition)
    appearanceDefinition.gender = gender
    appearanceDefinition.skinTexture = gender == "female"
        and "FemaleBody01" or "MaleBody02"
    if corePlan then
        identity = corePlan.identity
        appearanceDefinition = nil
    end
    local member = {
        schemaVersion = Presets.SCHEMA_VERSION,
        presetID = requestedID,
        role = definition.role,
        actorID = tostring(actorID or ""),
        identitySeed = identitySeed,
        identity = identity,
        isFemale = gender == "female",
        archetypeID = definition.archetypeID,
        tacticalClass = "neutral",
        visualProfile = definition.visualProfile,
        appearance = corePlan and corePlan.appearance
            or appearanceFor(appearanceDefinition),
        startingItems = corePlan and corePlan.starterItems
            or copy(definition.items),
        inventoryAuthority = "canonical",
        equipment = corePlan and corePlan.equipment
            or copy(definition.equipment),
        coreArchetypeID = corePlan and corePlan.archetypeID or nil,
        source = {
            ownerMod = "DynamicTrading",
            presetID = requestedID,
            presetVersion = Presets.SCHEMA_VERSION,
        },
    }
    return member
end

function Presets.BuildMembers(spec)
    spec = type(spec) == "table" and spec or {}
    local count = math.max(
        Presets.MIN_MEMBER_COUNT,
        math.min(
            Presets.MAX_MEMBER_COUNT,
            math.floor(tonumber(spec.memberCount) or Presets.DEFAULT_MEMBER_COUNT)
        )
    )
    local seed = spec.seed or (spec.generation and spec.generation.seed)
        or spec.actorPrefix or "dynamic_trading"
    local prefix = safePrefix(spec.actorPrefix or spec.requestID or "dt:trader")
    local memberSpecs = {}
    local actorIDs = {}
    local index
    for index = 1, count do
        local actorID = type(spec.actorIDs) == "table" and spec.actorIDs[index]
            or nil
        actorID = tostring(actorID or (prefix .. ":member:" .. tostring(index)))
        local presetID = Presets.PresetIDForMember(index)
        local memberSeed = tostring(seed) .. ":" .. presetID .. ":" .. tostring(index)
        local member, reason = Presets.Resolve(
            presetID, index, memberSeed, actorID)
        if not member then return nil, reason end
        member.extensions = member.extensions or {}
        local provider = tostring(spec.providerID or spec.provider or "")
        member.extensions[ACTOR_IDENTITY_EXTENSION] = {
            canonicalActorID = actorID,
            providerID = provider ~= "" and provider or nil,
            presenceState = provider == "DTAbstract"
                and "abstract" or nil,
            project = true,
            capabilities = {
                conversation = true,
                ["dynamictrading.trade"] = true,
            },
        }
        actorIDs[index] = actorID
        memberSpecs[index] = member
    end
    return {
        schemaVersion = Presets.SCHEMA_VERSION,
        seed = seed,
        actorIDs = actorIDs,
        memberSpecs = memberSpecs,
    }
end

if PsychopatzCore and PsychopatzCore.Actors
    and PsychopatzCore.Actors.Archetypes
then
    Presets.RegisterCoreArchetypes()
end

return Presets
