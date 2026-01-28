-- =============================================================================
-- FILE: media/lua/client/Debug/DT_BuildingFinder.lua
-- AUTHOR: Dynamic Trading Mod Team
-- PURPOSE: Visual interface to scan buildings, wilderness, and roads with county grouping
-- VERSION: 2.0 - Fixed and Enhanced
-- =============================================================================

-- Ensure DTM global exists
DTM = DTM or {}

-- =============================================================================
-- DEFINE THE CLASS
-- =============================================================================
DTM_DebugUI = ISCollapsableWindow:derive("DTM_DebugUI")

-- =============================================================================
-- UI SETUP
-- =============================================================================

function DTM_DebugUI:initialise()
    ISCollapsableWindow.initialise(self)
    self.title = "DTM: Building Scanner"
    self:setResizable(true)
    
    -- Track current filter mode
    self.currentFilter = "all" -- "all", "county"
    self.selectedCounty = nil
end

function DTM_DebugUI:onResize()
    ISCollapsableWindow.onResize(self)
    if not self.scanBtn or not self.teleportBtn then return end

    local pad = 10
    local btnH = 25
    
    -- Update button widths for three-button layout
    local btnWidth = (self:getWidth() - (pad * 4)) / 3
    
    self.scanBtn:setWidth(btnWidth)
    self.wildBtn:setX(self.scanBtn:getRight() + pad)
    self.wildBtn:setWidth(btnWidth)
    self.roadBtn:setX(self.wildBtn:getRight() + pad)
    self.roadBtn:setWidth(btnWidth)
    
    -- Filter dropdown stays below scan buttons
    self.filterCombo:setWidth(self:getWidth() - (pad * 2))
    
    -- Teleport & Track buttons anchored to bottom
    local bottomY = self:getHeight() - pad - btnH
    local trackY = bottomY
    local teleY = trackY - pad - btnH
    
    self.trackBtn:setY(trackY)
    self.trackBtn:setWidth(self:getWidth() - (pad * 2))
    
    self.teleportBtn:setY(teleY)
    self.teleportBtn:setWidth(self:getWidth() - (pad * 2))
    
    -- List Box stretches to fill middle
    local listY = self.filterCombo:getY() + self.filterCombo:getHeight() + pad
    local listH = teleY - listY - pad
    
    self.resultList:setHeight(listH)
    self.resultList:setWidth(self:getWidth() - (pad * 2))
end

function DTM_DebugUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local pad = 10
    local btnH = 25
    local btnWidth = (self.width - (pad * 4)) / 3

    -- 1. SCAN BUTTON
    self.scanBtn = ISButton:new(pad, self:titleBarHeight() + pad, btnWidth, btnH, "SCAN BUILDINGS", self, DTM_DebugUI.onScanClick)
    self.scanBtn:initialise()
    self.scanBtn:instantiate()
    self.scanBtn.borderColor = {r=1, g=1, b=1, a=0.5}
    self:addChild(self.scanBtn)

    -- 2. WILDERNESS BUTTON
    self.wildBtn = ISButton:new(self.scanBtn:getRight() + pad, self.scanBtn:getY(), btnWidth, btnH, "SCAN WILDERNESS", self, DTM_DebugUI.onWildernessClick)
    self.wildBtn:initialise()
    self.wildBtn:instantiate()
    self.wildBtn.borderColor = {r=0, g=0.8, b=0, a=0.5}
    self:addChild(self.wildBtn)

    -- 3. ROAD BUTTON
    self.roadBtn = ISButton:new(self.wildBtn:getRight() + pad, self.scanBtn:getY(), btnWidth, btnH, "SCAN ROADS", self, DTM_DebugUI.onRoadClick)
    self.roadBtn:initialise()
    self.roadBtn:instantiate()
    self.roadBtn.borderColor = {r=0.5, g=0.5, b=0.5, a=0.5}
    self:addChild(self.roadBtn)

    -- 4. COUNTY FILTER DROPDOWN
    local filterY = self.scanBtn:getY() + btnH + pad
    self.filterCombo = ISComboBox:new(pad, filterY, self.width - (pad * 2), btnH, self, DTM_DebugUI.onFilterChange)
    self.filterCombo:initialise()
    self.filterCombo:instantiate()
    self.filterCombo:addOption("All Locations")
    self:addChild(self.filterCombo)

    -- 5. LIST BOX
    local listY = self.filterCombo:getY() + btnH + pad
    local listH = self.height - listY - (btnH * 2) - (pad * 3)
    
    self.resultList = ISScrollingListBox:new(pad, listY, self.width - (pad * 2), listH)
    self.resultList:initialise()
    self.resultList:instantiate()
    self.resultList.itemheight = 35
    self.resultList.selected = 0
    self.resultList.joypadParent = self
    self.resultList.font = UIFont.Small
    self.resultList.drawBorder = true
    self.resultList.doDrawItem = self.drawBuildingItem
    self.resultList.onmousedown = function(item) self:onListMouseDown(item) end
    self:addChild(self.resultList)

    -- 6. TELEPORT BUTTON
    local teleY = self.resultList:getY() + self.resultList:getHeight() + pad
    self.teleportBtn = ISButton:new(pad, teleY, self.width - (pad * 2), btnH, "TELEPORT TO SELECTED", self, DTM_DebugUI.onTeleportClick)
    self.teleportBtn:initialise()
    self.teleportBtn:instantiate()
    self.teleportBtn.backgroundColor = {r=0, g=0.5, b=0, a=0.5}
    self:addChild(self.teleportBtn)

    -- 7. TRACK BUTTON
    local trackY = teleY + btnH + pad
    self.trackBtn = ISButton:new(pad, trackY, self.width - (pad * 2), btnH, "TRACK WITH MARKER", self, DTM_DebugUI.onTrackClick)
    self.trackBtn:initialise()
    self.trackBtn:instantiate()
    self.trackBtn.backgroundColor = {r=0.2, g=0.2, b=0.8, a=0.5}
    self:addChild(self.trackBtn)
    
    -- Store all scanned data for filtering
    self.allLocations = {}
end

-- =============================================================================
-- FILTER MANAGEMENT
-- =============================================================================

function DTM_DebugUI:updateFilterDropdown()
    -- Clear existing options
    self.filterCombo:clear()
    self.filterCombo:addOption("All Locations")
    
    -- Collect unique counties from current data
    local counties = {}
    for _, item in ipairs(self.allLocations) do
        local county = item.county or "Unknown"
        if not counties[county] then
            counties[county] = true
        end
    end
    
    -- Add counties to dropdown (sorted)
    local countyList = {}
    for county, _ in pairs(counties) do
        table.insert(countyList, county)
    end
    table.sort(countyList)
    
    for _, county in ipairs(countyList) do
        self.filterCombo:addOption(county)
    end
end

function DTM_DebugUI:onFilterChange()
    local selected = self.filterCombo:getOptionText(self.filterCombo.selected)
    
    self.resultList:clear()
    
    if selected == "All Locations" then
        -- Show all locations
        for _, data in ipairs(self.allLocations) do
            local label = self:formatLocationLabel(data)
            self.resultList:addItem(label, data)
        end
    else
        -- Filter by selected county
        for _, data in ipairs(self.allLocations) do
            if data.county == selected then
                local label = self:formatLocationLabel(data)
                self.resultList:addItem(label, data)
            end
        end
    end
end

function DTM_DebugUI:formatLocationLabel(data)
    local countyTag = data.county and ("[" .. data.county .. "] ") or ""
    
    -- If the town is the same as the county (Region), don't show it twice
    local townTag = ""
    if data.town and data.town ~= data.county then
        townTag = data.town .. " - "
    end
    
    local nameTag = data.name or "Unknown"
    
    if data.details and data.details.roomCount then
        return countyTag .. townTag .. nameTag .. " | Rooms: " .. data.details.roomCount
    else
        return countyTag .. townTag .. nameTag
    end
end

-- =============================================================================
-- SCAN LOGIC FUNCTIONS
-- =============================================================================

function DTM_DebugUI:onScanClick()
    self.resultList:clear()
    self.allLocations = {}
    
    -- Ensure client has everything loaded
    DTM.LoadBuildings()
    
    local metaGrid = getWorld():getMetaGrid()
    if not metaGrid then return end
    
    local buildings = metaGrid:getBuildings()
    local count = 0
    local minSize = (DTM.Config and DTM.Config.MinBuildingArea) or 50

    for i = 0, buildings:size() - 1 do
        local b = buildings:get(i)
        local w, h = b:getW(), b:getH()
        local area = w * h

        if area >= minSize then
            local bx, by = b:getX(), b:getY()
            
            -- Get enriched data
            local bKey = bx .. "," .. by
            local bData = DTM.BuildingLookup and DTM.BuildingLookup[bKey]
            
            if not bData then
                local details = DTM.GetBuildingDetails(b)
                bData = {
                    x = bx, y = by, w = w, h = h,
                    cx = math.floor(bx + (w/2)), cy = math.floor(by + (h/2)),
                    area = area, 
                    name = details.primaryRoom or "Building",
                    town = DTM.GetTownName(bx, by),
                    county = DTM.GetCountyName(bx, by),
                    details = details
                }
            end

            table.insert(self.allLocations, bData)
            
            count = count + 1
        end
    end
    
    -- Update filter dropdown with new data
    self:updateFilterDropdown()
    
    print("[DTM UI] Listed " .. count .. " buildings with county grouping.")
    
    -- Display all results initially
    for _, data in ipairs(self.allLocations) do
        local label = self:formatLocationLabel(data)
        self.resultList:addItem(label, data)
    end
end
    
function DTM_DebugUI:onWildernessClick()
    self.resultList:clear()
    self.allLocations = {}
    
    local wildPoints = DTM.ScanForWilderness()
    
    for _, wp in ipairs(wildPoints) do
        wp.county = DTM.GetCountyName(wp.x, wp.y)
        table.insert(self.allLocations, wp)
    end
    
    self:updateFilterDropdown()
    
    for _, data in ipairs(self.allLocations) do
        local label = self:formatLocationLabel(data)
        self.resultList:addItem(label, data)
    end
end

function DTM_DebugUI:onRoadClick()
    self.resultList:clear()
    self.allLocations = {}
    
    local roadPoints = DTM.ScanForRoads()
    
    for _, rp in ipairs(roadPoints) do
        rp.county = DTM.GetCountyName(rp.x, rp.y)
        table.insert(self.allLocations, rp)
    end
    
    -- Sort by County, then Town, then Name
    table.sort(self.allLocations, function(a, b)
        if a.county ~= b.county then
            return (a.county or "") < (b.county or "")
        elseif a.town ~= b.town then
            return (a.town or "") < (b.town or "")
        else
            return (a.name or "") < (b.name or "")
        end
    end)
    
    self:updateFilterDropdown()
    
    for _, data in ipairs(self.allLocations) do
        local label = self:formatLocationLabel(data)
        self.resultList:addItem(label, data)
    end
end

-- =============================================================================
-- DRAWING FUNCTIONS
-- =============================================================================

function DTM_DebugUI:drawBuildingItem(y, item, alt)
    if self.selected == item.index then
        self:drawRect(0, y, self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
    elseif alt then
        self:drawRect(0, y, self:getWidth(), self.itemheight - 1, 0.1, 0.1, 0.1, 0.5)
    end
    
    local data = item.item
    local topLabel = item.text
    local subLabel = string.format("Pos: %d, %d", data.cx or data.x, data.cy or data.y)
    
    if data.details and data.details.id then
        subLabel = subLabel .. " | ID: " .. data.details.id
    end
    
    -- Main Name
    self:drawText(topLabel, 10, y + 2, 1, 1, 1, 1, UIFont.Small)
    
    -- Details with color coding
    local color = {r=0.6, g=0.6, b=0.6, a=1}
    if data.details then
        if data.details.isAlarmed then 
            color = {r=1, g=0.3, b=0.3, a=1}
        elseif data.details.visited then 
            color = {r=0.3, g=1, b=0.3, a=1}
        end
    end
    
    self:drawText(subLabel, 15, y + 15, color.r, color.g, color.b, color.a, UIFont.Small)
    
    return y + self.itemheight
end

-- =============================================================================
-- MOUSE INTERACTION
-- =============================================================================

function DTM_DebugUI:onListMouseDown(item)
    -- Double-click detection
    local currentTime = getTimestampMs()
    if self.lastClickTime and (currentTime - self.lastClickTime) < 500 then
        -- Double click detected
        if item and item.item then
            self:doTeleport(item.item.cx or item.item.x, item.item.cy or item.item.y, 0)
        end
    end
    self.lastClickTime = currentTime
end

-- =============================================================================
-- ACTION BUTTONS
-- =============================================================================

function DTM_DebugUI:onTeleportClick()
    local item = self.resultList.items[self.resultList.selected]
    if not item then return end
    
    local data = item.item
    self:doTeleport(data.cx or data.x, data.cy or data.y, 0)
end

function DTM_DebugUI:onTrackClick()
    local item = self.resultList.items[self.resultList.selected]
    if not item then return end
    
    local data = item.item
    local markerID = "DT_Debug_Track_" .. (data.x or 0) .. "_" .. (data.y or 0)
    
    local desc = string.format("TRACKED: %s in %s, %s", 
        data.name or "Location", 
        data.town or "Unknown", 
        data.county or "Unknown County")
    
    if data.details and data.details.roomCount then
        desc = desc .. " (Rooms: " .. data.details.roomCount .. ")"
    end

    -- Use EventMarkerHandler if available
    if type(EventMarkerHandler) == "table" and type(EventMarkerHandler.set) == "function" then
        EventMarkerHandler.set(markerID, "friend.png", 3600, data.cx or data.x, data.cy or data.y, {r=0, g=1, b=0}, desc)
        if getPlayer() then 
            getPlayer():Say("Tracking: " .. (data.name or "Location"))
        end
    else
        if getPlayer() then 
            getPlayer():Say("EventMarkerHandler not available!")
        end
    end
end

-- =============================================================================
-- TELEPORT FUNCTION
-- =============================================================================

function DTM_DebugUI:doTeleport(x, y, z)
    local player = getPlayer()
    if not player then return end

    -- Sanitize inputs using math.floor to ensure integers
    local tx = math.floor(tonumber(x) or 0)
    local ty = math.floor(tonumber(y) or 0)
    local tz = math.floor(tonumber(z) or 0)

    if tx == 0 and ty == 0 then 
        print("[DTM UI] Teleport failed: Invalid coordinates (0,0).")
        return 
    end

    print("[DTM UI] Teleporting to: " .. tx .. ", " .. ty .. ", " .. tz)

    -- Use standard coordinate setters verified for Build 42.13
    player:setX(tx)
    player:setY(ty)
    player:setZ(tz)
end

-- =============================================================================
-- CONTEXT MENU INTEGRATION
-- =============================================================================

local function addDTMDebugOption(player, context, worldObjects)
    context:addOption("DTM: Building Scanner", nil, function()
        local ui = DTM_DebugUI:new(100, 100, 600, 650)
        ui:initialise()
        ui:addToUIManager()
        ui:onScanClick()
    end)
end

Events.OnFillWorldObjectContextMenu.Add(addDTMDebugOption)