require "ISUI/Maps/ISWorldMap"

DynamicTrading = DynamicTrading or {}
DynamicTrading.MapDisplay = DynamicTrading.MapDisplay or {}

local MapDisplay = DynamicTrading.MapDisplay

if isServer() and not isClient() then
    return MapDisplay
end

MapDisplay.DEFAULT_UPDATE_TICKS = MapDisplay.DEFAULT_UPDATE_TICKS or 90
MapDisplay.DEFAULT_REQUEST_TICKS = MapDisplay.DEFAULT_REQUEST_TICKS or 600
MapDisplay.providers = MapDisplay.providers or {}
MapDisplay.hiddenMaps = MapDisplay.hiddenMaps or {}

local function getLocalPlayer()
    if getSpecificPlayer then
        return getSpecificPlayer(0)
    end
    return getPlayer and getPlayer() or nil
end

local function ensureHiddenMap(playerObj)
    if not playerObj or not ISWorldMap then
        return nil
    end

    local playerNum = playerObj:getPlayerNum()
    local existing = MapDisplay.hiddenMaps[playerNum]
    if existing and existing.javaObject then
        return existing
    end

    local map = ISWorldMap:new(0, 0, 10, 10)
    map:initialise()
    map:instantiate()
    map.character = playerObj
    map.playerNum = playerNum
    map:initDataAndStyle()
    map:setVisible(false)

    MapDisplay.hiddenMaps[playerNum] = map
    return map
end

local function getSymbolsAPI(playerObj)
    local map = ensureHiddenMap(playerObj)
    if not map or not map.mapAPI then
        return nil
    end

    local symbols = map.mapAPI:getSymbolsAPIv2()
    if symbols and symbols.initDefaultAnnotations and not map.dtMapDisplayAnnotationsReady then
        symbols:initDefaultAnnotations()
        map.dtMapDisplayAnnotationsReady = true
    end
    return symbols
end

local function normalizeOwnedSymbolIDs(symbolIDs)
    local normalized = {}
    if type(symbolIDs) ~= "table" then
        return normalized
    end

    for key, value in pairs(symbolIDs) do
        if type(key) == "number" and type(value) == "string" and value ~= "" then
            normalized[value] = true
        elseif type(key) == "string" and type(value) == "string" and value ~= "" then
            normalized[value] = true
        elseif type(key) == "string" and value then
            normalized[key] = true
        end
    end

    return normalized
end

local function getProviderOwnedSymbolIDs(provider, state)
    if not provider then
        return {}
    end

    local symbolIDs = nil
    if provider.getOwnedSymbolIDs then
        symbolIDs = provider.getOwnedSymbolIDs(state)
    else
        symbolIDs = provider.ownedSymbolIDs or provider.symbolIDs
    end

    return normalizeOwnedSymbolIDs(symbolIDs)
end

local function clearProviderSymbols(symbols, ownedSymbolIDs)
    if not symbols or not next(ownedSymbolIDs or {}) then
        return
    end

    for index = symbols:getSymbolCount() - 1, 0, -1 do
        local symbol = symbols:getSymbolByIndex(index)
        if symbol and symbol.getSymbolID then
            local symbolID = symbol:getSymbolID()
            if symbolID and ownedSymbolIDs[symbolID] then
                symbols:removeSymbolByIndex(index)
            end
        end
    end
end

local function drawMarkers(symbols, markers)
    for _, marker in ipairs(markers or {}) do
        if marker and marker.symbolID and marker.x ~= nil and marker.y ~= nil then
            local symbol = symbols:addTexture(
                tostring(marker.symbolID),
                math.floor(tonumber(marker.x) or 0),
                math.floor(tonumber(marker.y) or 0)
            )
            if symbol then
                symbol:setAnchor(tonumber(marker.anchorX) or 0.5, tonumber(marker.anchorY) or 0.5)
                symbol:setRGBA(
                    tonumber(marker.r) or 1,
                    tonumber(marker.g) or 1,
                    tonumber(marker.b) or 1,
                    tonumber(marker.a) or 1
                )
                symbol:setScale(tonumber(marker.scale) or ((ISMap and ISMap.SCALE) or 1))
                symbol:setVisible(marker.visible ~= false)
            end
        end
    end
end

function MapDisplay.GetProviderState(providerID)
    local entry = providerID and MapDisplay.providers[providerID] or nil
    return entry and entry.state or nil
end

function MapDisplay.RegisterProvider(providerID, provider)
    if not providerID or providerID == "" or type(provider) ~= "table" then
        return nil
    end

    local existing = MapDisplay.providers[providerID] or {}
    existing.id = providerID
    existing.provider = provider
    existing.state = existing.state or {}
    existing.state.providerID = providerID
    MapDisplay.providers[providerID] = existing
    return existing.state
end

function MapDisplay.UnregisterProvider(providerID)
    local entry = providerID and MapDisplay.providers[providerID] or nil
    if not entry then
        return
    end

    local playerObj = getLocalPlayer()
    local symbols = playerObj and getSymbolsAPI(playerObj) or nil
    clearProviderSymbols(symbols, getProviderOwnedSymbolIDs(entry.provider, entry.state))
    MapDisplay.providers[providerID] = nil
end

local function updateProviderSync(provider, state, playerObj)
    if not provider or not provider.requestSync then
        return
    end

    state.requestCounter = (tonumber(state.requestCounter) or 0) + 1

    local requestInterval = math.max(
        1,
        math.floor(tonumber(provider.requestIntervalTicks) or MapDisplay.DEFAULT_REQUEST_TICKS)
    )
    local shouldRequest = state.requestCounter >= requestInterval

    if provider.shouldRequestSync and provider.shouldRequestSync(playerObj, state) then
        shouldRequest = true
    end

    if shouldRequest then
        state.requestCounter = 0
        provider.requestSync(playerObj, state)
    end
end

local function updateProviderMarkers(symbols, provider, state, playerObj)
    if not provider then
        return
    end

    state.updateCounter = (tonumber(state.updateCounter) or 0) + 1

    local updateInterval = math.max(
        1,
        math.floor(tonumber(provider.updateIntervalTicks) or MapDisplay.DEFAULT_UPDATE_TICKS)
    )
    if state.updateCounter < updateInterval then
        return
    end

    state.updateCounter = 0

    local ownedSymbolIDs = getProviderOwnedSymbolIDs(provider, state)
    clearProviderSymbols(symbols, ownedSymbolIDs)

    if provider.isEnabled and not provider.isEnabled(playerObj, state) then
        return
    end

    local markers = provider.getMarkers and provider.getMarkers(playerObj, state) or {}
    drawMarkers(symbols, markers)
end

local function providerNeedsMarkerUpdate(provider, state)
    if not provider then
        return false
    end

    local updateInterval = math.max(
        1,
        math.floor(tonumber(provider.updateIntervalTicks) or MapDisplay.DEFAULT_UPDATE_TICKS)
    )
    return ((tonumber(state.updateCounter) or 0) + 1) >= updateInterval
end

local function onServerCommand(module, command, args)
    for _, entry in pairs(MapDisplay.providers or {}) do
        local provider = entry and entry.provider or nil
        local state = entry and entry.state or nil
        if provider and provider.onServerCommand then
            provider.onServerCommand(module, command, args, state)
        end
    end
end

function MapDisplay.OnTick()
    local playerObj = getLocalPlayer()
    if not playerObj then
        return
    end

    local hasProviders = false
    local needsMarkerPass = false
    for _, entry in pairs(MapDisplay.providers or {}) do
        hasProviders = true
        updateProviderSync(entry.provider, entry.state, playerObj)
        if providerNeedsMarkerUpdate(entry.provider, entry.state) then
            needsMarkerPass = true
        end
    end

    if not hasProviders or not needsMarkerPass then
        return
    end

    local symbols = getSymbolsAPI(playerObj)
    if not symbols then
        return
    end

    for _, entry in pairs(MapDisplay.providers or {}) do
        updateProviderMarkers(symbols, entry.provider, entry.state, playerObj)
    end
end

if not MapDisplay.eventsAdded then
    Events.OnServerCommand.Add(onServerCommand)
    Events.OnTick.Add(MapDisplay.OnTick)
    MapDisplay.eventsAdded = true
end

return MapDisplay
