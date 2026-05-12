-- ==============================================================================
-- DTNPC_Debug_SoundUI.lua
-- UI for testing NPC vocalizations with customizable identity and gender.
-- ==============================================================================

require "ISUI/ISCollapsableWindow"
require "ISUI/ISPanel"
require "ISUI/ISButton"
require "ISUI/ISLabel"
require "ISUI/ISTextEntryBox"
require "ISUI/ISComboBox"

DTNPC_Debug_SoundUI = ISCollapsableWindow:derive("DTNPC_Debug_SoundUI")
DTNPC_Debug_SoundUI.instance = nil

function DTNPC_Debug_SoundUI:initialise()
    ISCollapsableWindow.initialise(self)
    self:setTitle("Vocal System UI")
    self:setResizable(false)
end

function DTNPC_Debug_SoundUI:createChildren()
    ISCollapsableWindow.createChildren(self)

    local th = self:titleBarHeight()
    local pad = 10
    local y = th + pad

    -- Seed
    local lblSeed = ISLabel:new(pad, y, 20, "Identity Seed (Number):", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(lblSeed)
    
    self.entrySeed = ISTextEntryBox:new("123", pad + 150, y, 100, 20)
    self.entrySeed:initialise()
    self.entrySeed:instantiate()
    self.entrySeed:setOnlyNumbers(true)
    self:addChild(self.entrySeed)

    local btnRand = ISButton:new(pad + 260, y, 60, 20, "Rand", self, function(self)
        self.entrySeed:setText(tostring(ZombRand(1000)))
    end)
    btnRand:initialise()
    self:addChild(btnRand)

    y = y + 30

    -- Gender
    local lblGender = ISLabel:new(pad, y, 20, "Gender:", 1, 1, 1, 1, UIFont.Small, true)
    self:addChild(lblGender)

    self.comboGender = ISComboBox:new(pad + 150, y, 100, 20, self, nil)
    self.comboGender:initialise()
    self.comboGender:addOption("Male")
    self.comboGender:addOption("Female")
    self:addChild(self.comboGender)

    y = y + 40

    local btnWidth = 310
    local btnHeight = 24

    local function constructNpcData()
        local seedStr = self.entrySeed:getText() or ""
        local seed = tonumber(seedStr) or 0
        local isFemale = self.comboGender.selected == 2
        return {
            identitySeed = seed,
            isFemale = isFemale,
            name = "Test UI NPC"
        }
    end

    local function getSoundResolver()
        return DynamicTrading and DynamicTrading.Dialogue and DynamicTrading.Dialogue.Vocals
    end

    local function addTestBtn(label, cueType)
        local btn = ISButton:new(pad, y, btnWidth, btnHeight, label, self, function(self)
            local npcData = constructNpcData()
            local Vocals = getSoundResolver()
            if not Vocals then return end

            local soundName, profile = Vocals.ResolveVocalSoundName(npcData, cueType)
            if not soundName then return end

            local p = getSpecificPlayer(0)
            if p then
                local emitter = getWorld():getFreeEmitter(p:getX(), p:getY(), p:getZ())
                if emitter then
                    local id = emitter:playSound(soundName)
                    local basePitch = 1.0
                    if profile.voiceSet == "V1" then basePitch = 0.95
                    elseif profile.voiceSet == "V2" then basePitch = 1.00
                    elseif profile.voiceSet == "V3" then basePitch = 1.05
                    elseif profile.voiceSet == "V4" then basePitch = 1.10
                    end
                    
                    local finalPitch = basePitch * (profile.microPitch or 1.0)
                    
                    if id and id ~= 0 and emitter.setPitch then
                        pcall(function() emitter:setPitch(id, finalPitch) end)
                    end
                end
                
                if p.setHaloNote then
                    local genderStr = npcData.isFemale and "(Female)" or "(Male)"
                    local voiceSet = (profile and profile.voiceSet) or "Unknown"
                    p:setHaloNote("UI SFX: " .. voiceSet .. " " .. genderStr, 255, 255, 255, 300)
                end
            end
        end)
        btn:initialise()
        self:addChild(btn)
        
        y = y + btnHeight + 5
        return btn
    end

    local lblHurt = ISLabel:new(pad, y, 20, "--- Combat Sounds ---", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(lblHurt)
    y = y + 25

    addTestBtn("Test Hurt Sound", "Hurt")
    addTestBtn("Test Incap Sound", "Incap")
    addTestBtn("Test Death Sound", "Death")
    addTestBtn("Test Effort Sound", "Effort")
    addTestBtn("Test Bandage", "Bandage")

    y = y + 10
    local lblAmbient = ISLabel:new(pad, y, 20, "--- Ambient & Chat ---", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(lblAmbient)
    y = y + 25

    addTestBtn("Test Hey (Chat Pool)", "Chat")
    addTestBtn("Test Sigh (Sigh Pool)", "Sigh")
    addTestBtn("Test Sneeze (Ambient Pool)", "Ambient")
    addTestBtn("Test State (Jump/Sleep/Smoke)", "State")
    addTestBtn("Test Specific: Angry", "Chat_Angry")

    y = y + 10
    local lblUtils = ISLabel:new(pad, y, 20, "--- Utilities ---", 0.8, 0.8, 0.8, 1, UIFont.Small, true)
    self:addChild(lblUtils)
    y = y + 25

    local btnDump = ISButton:new(pad, y, btnWidth, btnHeight, "Dump All Audio Keys to file", self, function(self)
        local allSounds = getFMODEventPathList()
        local fileWriter = getFileWriter("DT_Audio_Dump.txt", true, false)
        if fileWriter then
            fileWriter:write("========== DT AUDIO DUMP ==========\n")
            if allSounds then
                fileWriter:write("Found " .. tostring(allSounds:size()) .. " sound events.\n\n")
                for i = 0, allSounds:size() - 1 do
                    fileWriter:write(tostring(allSounds:get(i)) .. "\n")
                end
            end
            fileWriter:close()
            local p = getSpecificPlayer(0)
            if p and p.setHaloNote then
                local path = Core.getMyDocumentFolder() .. "/Lua/DT_Audio_Dump.txt"
                p:setHaloNote("Saved to " .. path, 100, 255, 100, 300)
            end
        end
    end)
    btnDump:initialise()
    btnDump.backgroundColor = {r=0, g=0.3, b=0, a=1}
    self:addChild(btnDump)
    y = y + btnHeight + 5

    self:setHeight(y + 20)
end

function DTNPC_Debug_SoundUI:close()
    self:setVisible(false)
    self:removeFromUIManager()
    DTNPC_Debug_SoundUI.instance = nil
end

function DTNPC_Debug_SoundUI.ToggleWindow()
    if DTNPC_Debug_SoundUI.instance then
        DTNPC_Debug_SoundUI.instance:close()
        return
    end

    local width = 340
    local height = 500
    local x = (getCore():getScreenWidth() - width) / 2
    local y = (getCore():getScreenHeight() - height) / 2

    local ui = DTNPC_Debug_SoundUI:new(x, y, width, height)
    ui:initialise()
    ui:addToUIManager()
    DTNPC_Debug_SoundUI.instance = ui
end

function DTNPC_Debug_SoundUI:new(x, y, width, height)
    local o = ISCollapsableWindow:new(x, y, width, height)
    setmetatable(o, self)
    self.__index = self
    return o
end
