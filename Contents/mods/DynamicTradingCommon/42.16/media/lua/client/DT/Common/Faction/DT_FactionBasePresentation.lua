DynamicTrading = DynamicTrading or {}
DynamicTrading.FactionBasePresentation = DynamicTrading.FactionBasePresentation or {}

local Presentation = DynamicTrading.FactionBasePresentation

local ROOM_PROFILES = {
    livingroom = {
        structures = {
            "Reclaimed Living Room",
            "Boarded Front Room",
            "Barricaded Family Den",
        },
        siteTypes = {
            "Safehouse",
            "Holdout",
            "Shelter",
        },
        flavors = {
            "A once-ordinary lounge now barricaded into a guarded command den.",
            "Couches, plywood, and firing angles have turned the old sitting room into a tense shelter.",
            "The main room has been stripped down into a practical refuge with watch lines on every entrance.",
        },
    },
    kitchen = {
        structures = {
            "Field Kitchen",
            "Ration Prep Room",
            "Scavenger Galley",
        },
        siteTypes = {
            "Mess Hall",
            "Supply Post",
            "Cookhouse",
        },
        flavors = {
            "Old counters and ration crates have been turned into a rough kitchen and supply corner.",
            "Pots, canned food, and scavenged burners crowd the room like a makeshift camp kitchen.",
            "The smell of grease and stale rations hangs over a cramped prep area kept alive by routine.",
        },
    },
    foyer = {
        structures = {
            "Barricaded Foyer",
            "Front Gate Hall",
            "Entry Chokepoint",
        },
        siteTypes = {
            "Checkpoint",
            "Watch Post",
            "Gatehouse",
        },
        flavors = {
            "The front entrance has been hardened into a tense checkpoint with eyes on every approach.",
            "Everything about the entry says nobody gets through without being noticed first.",
            "Scrap barriers and narrow sightlines make the doorway feel more like a border post than a home.",
        },
    },
    hall = {
        structures = {
            "Barricaded Hall",
            "Inner Chokepoint",
            "Guarded Corridor",
        },
        siteTypes = {
            "Checkpoint",
            "Transit Line",
            "Control Hall",
        },
        flavors = {
            "A narrow interior artery repurposed into a controlled choke point.",
            "The hallway has been stripped down into a kill lane with barely any wasted space.",
            "Traffic through the base is funneled through this corridor under constant supervision.",
        },
    },
    office = {
        structures = {
            "Operations Office",
            "Field Headquarters",
            "Command Suite",
        },
        siteTypes = {
            "Command Post",
            "Signal Room",
            "Operations Hub",
        },
        flavors = {
            "Dusty desks and scavenged radios make it feel more like a field HQ than a workplace.",
            "Old paperwork has given way to maps, batteries, and whatever passes for command planning now.",
            "The room feels lived in by organizers, runners, and people trying to stay one step ahead.",
        },
    },
    retail = {
        structures = {
            "Looted Retail Floor",
            "Shuttered Market Floor",
            "Stripped Sales Room",
        },
        siteTypes = {
            "Trading Front",
            "Exchange Point",
            "Market Post",
        },
        flavors = {
            "Shelving and shuttered windows frame a storefront now used as a guarded exchange point.",
            "Once a place for browsing, it now serves as a controlled floor for trade and rationing.",
            "The sales area has been repurposed into a practical front for deals, pickups, and inspection.",
        },
    },
    grocery = {
        structures = {
            "Stripped Grocery Floor",
            "Ration Hall",
            "Provision Floor",
        },
        siteTypes = {
            "Supply Post",
            "Provision Cache",
            "Storehouse",
        },
        flavors = {
            "The old stock aisles have been converted into ration space and a guarded supply cache.",
            "Empty shelves and boxed staples give the place the feel of a controlled food depot.",
            "What used to be a grocery now functions as a hard-guarded stock room for essentials.",
        },
    },
    diner = {
        structures = {
            "Dead Diner",
            "Last Stop Diner",
            "Grillhouse Canteen",
        },
        siteTypes = {
            "Mess Hall",
            "Canteen",
            "Rest Stop",
        },
        flavors = {
            "Cold booths and a dead grill now serve as a canteen for whoever still holds the block.",
            "The diner survives as a communal food point where meals and rumors travel together.",
            "Booths, cracked tile, and a silent kitchen now form a stubborn little canteen.",
        },
    },
    restaurant = {
        structures = {
            "Abandoned Restaurant",
            "Occupied Dining Hall",
            "Barricaded Eatery",
        },
        siteTypes = {
            "Mess Hall",
            "Gathering Hall",
            "Commons",
        },
        flavors = {
            "The dining floor has been converted into a communal hub for meals, planning, and watch shifts.",
            "Table service is gone, replaced by the blunt routine of feeding people and assigning work.",
            "The room now feels like a communal hall where every meal doubles as a briefing.",
        },
    },
    storefront = {
        structures = {
            "Shuttered Storefront",
            "Boarded Shopfront",
            "Locked Exchange Front",
        },
        siteTypes = {
            "Trading Front",
            "Hardpoint",
            "Front Office",
        },
        flavors = {
            "A once-open frontage now doubles as a hardpoint and a discreet meeting place.",
            "The facade still reads like a business, but the posture of the place is defensive first.",
            "Behind the shuttered front is a cautious little node for trade, meetings, and watch duty.",
        },
    },
    warehouse = {
        structures = {
            "Warehouse Cache",
            "Freight Depot",
            "Stockpile Hangar",
        },
        siteTypes = {
            "Supply Depot",
            "Logistics Yard",
            "Bulk Storage",
        },
        flavors = {
            "Wide floors and heavy walls make it ideal for stockpiles, work benches, and fallback positions.",
            "It feels built for volume: crates, fuel, spare parts, and the people needed to guard them.",
            "The place survives on space, structure, and the simple advantage of having room to stage supplies.",
        },
    },
    garage = {
        structures = {
            "Motor Pool",
            "Repair Bay",
            "Scavenger Garage",
        },
        siteTypes = {
            "Vehicle Yard",
            "Repair Site",
            "Transit Hub",
        },
        flavors = {
            "Tools, fuel cans, and half-stripped parts suggest a base that survives by keeping engines alive.",
            "Everything here points to mobility: patched vehicles, spare parts, and people who know how to improvise.",
            "The garage reads like a survival contract written in gasoline, rubber, and salvage.",
        },
    },
    bedroom = {
        structures = {
            "Crowded Bunkroom",
            "Shared Barracks",
            "Sleep Quarters",
        },
        siteTypes = {
            "Bunkhouse",
            "Barracks",
            "Dormitory",
        },
        flavors = {
            "Mattresses, lockers, and blackout curtains turn private space into shared barracks.",
            "The room has been compressed into a place for sleep, rotation, and very little privacy.",
            "Private space disappeared here a long time ago, replaced by orderly rows and exhaustion.",
        },
    },
    basement = {
        structures = {
            "Hidden Basement",
            "Belowground Refuge",
            "Cellar Holdout",
        },
        siteTypes = {
            "Undercroft",
            "Fallback Nest",
            "Shelter Cellar",
        },
        flavors = {
            "Low ceilings and poor light make it a quiet fallback nest for people who do not want to be seen.",
            "Down here, survival feels quieter, meaner, and more deliberate than it does above ground.",
            "The cellar serves as the kind of refuge meant for endurance rather than comfort.",
        },
    },
}

local GENERIC_PREFIXES = {
    "Reclaimed",
    "Fortified",
    "Improvised",
    "Occupied",
    "Barricaded",
}

local GENERIC_SITE_TYPES = {
    "Holdout",
    "Outpost",
    "Safehouse",
    "Strongpoint",
    "Shelter",
}

local GENERIC_FLAVOR_TEMPLATES = {
    "An improvised stronghold carved out of a former %s near %s.",
    "The place feels less like a building and more like a defended foothold built from a %s around %s.",
    "Whatever it used to be, this %s now serves as a hardened refuge on the edge of %s.",
    "A quiet little fortress built from a %s, held together by salvage, routine, and nerves near %s.",
}

local function trim(text)
    text = tostring(text or "")
    text = text:gsub("^%s+", "")
    text = text:gsub("%s+$", "")
    return text
end

local function titleCaseWord(word)
    word = trim(word)
    if word == "" then
        return ""
    end
    return string.upper(word:sub(1, 1)) .. string.lower(word:sub(2))
end

local function humanizeToken(text)
    text = trim(text)
    if text == "" then
        return "Unknown Structure"
    end

    text = text:gsub("%s*%(%-?%d+,%s*%-?%d+%)%s*$", "")
    text = text:gsub("([a-z])([A-Z])", "%1 %2")
    text = text:gsub("[_%-%./]+", " ")
    text = text:gsub("%s+", " ")

    local parts = {}
    for word in string.gmatch(text, "%S+") do
        parts[#parts + 1] = titleCaseWord(word)
    end

    if #parts == 0 then
        return "Unknown Structure"
    end

    return table.concat(parts, " ")
end

local function normalizeRoomKey(text)
    text = trim(text):lower()
    text = text:gsub("%s*%(%-?%d+,%s*%-?%d+%)%s*$", "")
    text = text:gsub("[^%w]", "")
    return text
end

local function stableHash(text)
    local hash = 0
    local normalized = tostring(text or "")

    for index = 1, #normalized do
        hash = (hash * 131 + string.byte(normalized, index)) % 2147483647
    end

    return hash
end

local function pickStable(list, seed, salt)
    if type(list) ~= "table" or #list == 0 then
        return nil
    end

    local offset = tonumber(seed) or 0
    offset = offset + (tonumber(salt) or 0)
    return list[(offset % #list) + 1]
end

local function getProfileSeed(faction, rawName)
    local home = type(faction) == "table" and type(faction.homeCoords) == "table" and faction.homeCoords or {}
    return stableHash(table.concat({
        tostring(faction and faction.id or ""),
        tostring(faction and faction.name or ""),
        tostring(rawName or ""),
        tostring(home.x or 0),
        tostring(home.y or 0),
        tostring(home.z or 0),
        tostring(faction and faction.playerOwned == true),
    }, "|"))
end

local function getGenericStructureName(baseName, seed)
    local normalizedBaseName = trim(baseName)
    if normalizedBaseName == "" or normalizedBaseName == "Unknown Structure" then
        return pickStable({
            "Hidden Safehouse",
            "Forgotten Holdout",
            "Makeshift Strongpoint",
            "Survivor Nest",
        }, seed, 17)
    end

    return tostring(pickStable(GENERIC_PREFIXES, seed, 11) or "Reclaimed") .. " " .. normalizedBaseName
end

function Presentation.GetBaseLabel(faction)
    local factionName = trim(faction and faction.name or "")
    if factionName == "" then
        factionName = "Unknown Faction"
    end

    if type(faction) == "table" and faction.playerOwned == true then
        return factionName .. " Colony"
    end

    return factionName .. " Hideout"
end

function Presentation.GetProfile(faction)
    local home = type(faction) == "table" and type(faction.homeCoords) == "table" and faction.homeCoords or {}
    local rawName = trim(home.name or "")
    local roomKey = normalizeRoomKey(rawName)
    local profile = ROOM_PROFILES[roomKey]
    local townName = trim(faction and faction.town or home.town or home.county or "the dead zone")
    local seed = getProfileSeed(faction, rawName)
    local baseName = humanizeToken(rawName)
    local structureName = profile and pickStable(profile.structures, seed, 19) or getGenericStructureName(baseName, seed)
    local siteType = profile and pickStable(profile.siteTypes, seed, 29)
        or pickStable(GENERIC_SITE_TYPES, seed, 31)
        or "Holdout"
    local flavor = profile and pickStable(profile.flavors, seed, 41)
        or string.format(
            tostring(pickStable(GENERIC_FLAVOR_TEMPLATES, seed, 47) or GENERIC_FLAVOR_TEMPLATES[1]),
            string.lower(baseName ~= "Unknown Structure" and baseName or structureName),
            townName
        )

    return {
        rawName = rawName ~= "" and rawName or "Unknown",
        roomKey = roomKey,
        structureName = structureName,
        baseName = structureName,
        siteType = siteType,
        flavor = flavor,
        label = Presentation.GetBaseLabel(faction),
    }
end

return Presentation
