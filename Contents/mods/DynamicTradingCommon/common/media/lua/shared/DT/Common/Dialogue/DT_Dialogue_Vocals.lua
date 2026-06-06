DynamicTrading = DynamicTrading or {}
DynamicTrading.Dialogue = DynamicTrading.Dialogue or {}
DynamicTrading.Dialogue.Vocals = DynamicTrading.Dialogue.Vocals or DynamicTrading.Dialogue.Sound or {}
DynamicTrading.Dialogue.Sound = DynamicTrading.Dialogue.Vocals

local Vocals = DynamicTrading.Dialogue.Vocals
Vocals.Internal = Vocals.Internal or {}

local Internal = Vocals.Internal

Internal.VariantPools = Internal.VariantPools or {
    Hurt = { "Blunt", "Scratch", "Lacerate" },
    Chat = { "Hey", "Psst", "Cmon", "Angry" },
    Sigh = { "Bored", "Relieved", "Sad" },
    Ambient = { "SneezeHeavy", "SneezeLight", "Hic", "Shiver", "Alone" },
    State = { "Smoke", "Vomit", "Sleep", "Exercise", "JumpHigh", "JumpLow" },
}

Internal.ValidCueTypes = Internal.ValidCueTypes or {
    Hurt = true,
    Incap = true,
    Death = true,
    Effort = true,
    Bandage = true,
    Chat = true,
    Sigh = true,
    Ambient = true,
    State = true,
}

Internal.StateCueMap = Internal.StateCueMap or {
    Attack = "Chat_Angry",
    AttackRange = "Chat_Angry",
    Bandage = "Bandage",
    CrowdRefuse = "Chat_Angry",
    Exercise = "State_Exercise",
    Exercising = "State_Exercise",
    Flee = "Sigh_Sad",
    Guard = "Chat_Hey",
    Incapacitated = "Incap",
    JumpHigh = "State_JumpHigh",
    JumpLow = "State_JumpLow",
    Looking = "Chat_Psst",
    NoAmmo = "Chat_Angry",
    ProtectAuto = "Chat_Angry",
    ProtectMelee = "Chat_Angry",
    ProtectRanged = "Chat_Angry",
    Reloading = "Chat_Angry",
    Resting = "Sigh_Relieved",
    Return = "Chat_Hey",
    Searching = "Chat_Psst",
    Sleep = "State_Sleep",
    Sleeping = "State_Sleep",
    Smoke = "State_Smoke",
    Smoking = "State_Smoke",
    Trading = "Chat_Cmon",
    Vomit = "State_Vomit",
    Working = "Chat",
}

Internal.StatusCueMap = Internal.StatusCueMap or {
    Companion = "Chat_Hey",
    Resting = "Sigh_Relieved",
    Trading = "Chat_Cmon",
    Working = "Chat",
}

Internal.SentimentCueMap = Internal.SentimentCueMap or {
    angry = "Chat_Angry",
    friendly = "Chat_Hey",
    hostile = "Chat_Angry",
    resting = "Sigh_Relieved",
    trading = "Chat_Cmon",
    warning = "Chat_Angry",
}

Internal.HookCueMap = Internal.HookCueMap or {
    angry = "Chat_Angry",
    bandit = "Chat_Angry",
    bye = "Sigh_Relieved",
    chat = "Chat",
    hostile = "Chat_Angry",
    trading = "Chat_Cmon",
    welcome = "Chat_Hey",
}

Internal.VoiceProfileCache = Internal.VoiceProfileCache or {}
Internal.SoundNameCache = Internal.SoundNameCache or {}
Internal.CooldownCache = Internal.CooldownCache or {}

local function getCurrentTime()
    if getTimeInMillis then
        return getTimeInMillis()
    end
    return 0
end

local function normalizeString(value)
    if value == nil then
        return nil
    end

    local normalized = tostring(value)
    if normalized == "" then
        return nil
    end

    return normalized
end

local function getSpeakerKey(zombie, npcData)
    if npcData then
        if npcData.uuid and npcData.uuid ~= "" then
            return tostring(npcData.uuid)
        end

        if npcData.name and npcData.name ~= "" and npcData.identitySeed ~= nil then
            return tostring(npcData.name) .. ":" .. tostring(npcData.identitySeed)
        end
    end

    if zombie then
        if zombie.getPersistentOutfitID then
            return "zombie:" .. tostring(zombie:getPersistentOutfitID())
        end
        if zombie.getID then
            return "zombie:" .. tostring(zombie:getID())
        end
    end

    return nil
end

local function containsToken(value, token)
    local safeValue = string.lower(normalizeString(value) or "")
    local safeToken = string.lower(normalizeString(token) or "")
    if safeValue == "" or safeToken == "" then
        return false
    end

    return string.find(safeValue, safeToken, 1, true) ~= nil
end

local function shouldThrottle(zombie, npcData, channel, cooldownMs)
    local safeCooldown = math.max(0, tonumber(cooldownMs) or 0)
    if safeCooldown <= 0 then
        return false
    end

    local speakerKey = getSpeakerKey(zombie, npcData)
    if not speakerKey then
        return false
    end

    local now = getCurrentTime()
    if now <= 0 then
        return false
    end

    local throttleKey = speakerKey .. "|" .. tostring(channel or "default")
    local lastTime = tonumber(Internal.CooldownCache[throttleKey]) or 0
    if lastTime > 0 and (now - lastTime) < safeCooldown then
        return true
    end

    Internal.CooldownCache[throttleKey] = now
    return false
end

local function pickVariant(baseCue, requestedVariant)
    if requestedVariant and requestedVariant ~= "" then
        return requestedVariant
    end

    local pool = Internal.VariantPools[baseCue]
    if not pool or #pool == 0 then
        return nil
    end

    return pool[ZombRand(#pool) + 1]
end

function Vocals.GetVoiceProfile(npcData)
    local seed = tonumber(npcData and npcData.identitySeed) or 1
    local isFemale = npcData and npcData.isFemale == true
    local voiceIndex = 1 + (seed % 4)
    local cacheKey = tostring(isFemale) .. ":" .. tostring(voiceIndex) .. ":" .. tostring(seed % 11)

    local cached = Internal.VoiceProfileCache[cacheKey]
    if cached then
        return cached
    end

    cached = {
        sex = isFemale and "Female" or "Male",
        voiceSet = "V" .. tostring(voiceIndex),
        microPitch = 0.95 + (seed % 11) * 0.01,
        cacheKey = cacheKey,
    }
    Internal.VoiceProfileCache[cacheKey] = cached
    return cached
end

local function getVoiceSetBasePitch(profile)
    local voiceSet = profile and tostring(profile.voiceSet or "") or ""
    if voiceSet == "V1" then
        return 0.95
    end
    if voiceSet == "V2" then
        return 1.00
    end
    if voiceSet == "V3" then
        return 1.05
    end
    if voiceSet == "V4" then
        return 1.10
    end
    return 1.00
end

function Vocals.ResolveVocalSoundName(npcData, cueType, options)
    local opts = type(options) == "table" and options or nil
    local explicitSoundName = opts and normalizeString(opts.soundName) or nil
    if explicitSoundName then
        return explicitSoundName, nil
    end

    local normalizedCue = normalizeString(cueType) or "Chat"
    if string.sub(normalizedCue, 1, 6) == "DTNPC_" then
        return normalizedCue, nil
    end

    local baseCue, variant = string.match(normalizedCue, "^([%a]+)_([%w]+)$")
    if not baseCue then
        baseCue = normalizedCue
    end

    if not Internal.ValidCueTypes[baseCue] then
        return nil, nil
    end

    variant = pickVariant(baseCue, variant or (opts and normalizeString(opts.variant) or nil))

    local profile = Vocals.GetVoiceProfile(npcData)
    local cacheKey = profile.cacheKey .. "|" .. baseCue .. "|" .. tostring(variant or "")
    local soundName = Internal.SoundNameCache[cacheKey]
    if soundName then
        return soundName, profile
    end

    soundName = "DTNPC_" .. profile.sex .. "_" .. profile.voiceSet .. "_" .. baseCue
    if variant then
        soundName = soundName .. "_" .. variant
    end

    Internal.SoundNameCache[cacheKey] = soundName
    return soundName, profile
end

local function collapseVariantPoolCue(cueType)
    local normalizedCue = normalizeString(cueType)
    if not normalizedCue then
        return cueType
    end

    local baseCue = string.match(normalizedCue, "^([%a]+)_[%w]+$")
    if not baseCue then
        return normalizedCue
    end

    if baseCue == "Chat" or baseCue == "Sigh" or baseCue == "Ambient" then
        return baseCue
    end

    return normalizedCue
end

function Vocals.PlayUISound(soundName, baseVolume)
    local safeSoundName = normalizeString(soundName)
    if not safeSoundName then
        return nil
    end

    local safeVolume = tonumber(baseVolume) or 1.0
    if DT_AudioManager and DT_AudioManager.PlayUISound then
        return DT_AudioManager.PlayUISound(safeSoundName, safeVolume)
    end

    if not getSoundManager then
        return nil
    end

    local soundManager = getSoundManager()
    if not soundManager or not soundManager.PlaySound then
        return nil
    end

    return soundManager:PlaySound(safeSoundName, false, safeVolume)
end

function Vocals.PlayVocal(zombie, npcData, cueType, options)
    if not zombie or not npcData then
        return nil
    end

    local opts = type(options) == "table" and options or nil
    if shouldThrottle(zombie, npcData, opts and opts.channel or cueType or "vocal", opts and opts.cooldownMs or 0) then
        return nil
    end

    local soundName, profile = Vocals.ResolveVocalSoundName(npcData, cueType, opts)
    if not soundName then
        return nil
    end

    local emitter = zombie.getEmitter and zombie:getEmitter() or nil
    if not emitter or not emitter.playSound then
        return nil
    end

    local soundID = emitter:playSound(soundName)
    local pitch = tonumber(opts and opts.pitch) or nil
    if pitch == nil and profile then
        pitch = getVoiceSetBasePitch(profile) * (tonumber(profile.microPitch) or 1.0)
    end
    if soundID and soundID ~= 0 and pitch and emitter.setPitch then
        emitter:setPitch(soundID, pitch)
    end

    return soundID
end

function Vocals.NormalizeHook(hook)
    local normalized = string.lower(normalizeString(hook) or "")
    if normalized == "" then
        return nil
    end

    return normalized
end

function Vocals.ResolveHookVocalType(npcData, hook)
    local normalizedHook = Vocals.NormalizeHook(hook)
    if not normalizedHook then
        return nil
    end

    return Internal.HookCueMap[normalizedHook]
end

function Vocals.ResolveDispositionHook(npcData, status, state, entry)
    local safeFactionID = tostring(npcData and npcData.factionID or entry and entry.factionID or "")
    local safeTradeCycleMode = tostring(npcData and npcData.tradeCycleMode or entry and entry.tradeCycleMode or "")

    if npcData and (
        npcData.isBandit == true
        or npcData.banditGroupID ~= nil
        or safeFactionID == "Bandits"
        or containsToken(status, "bandit")
        or containsToken(state, "bandit")
        or (type(entry) == "table" and entry.isBandit == true)
    ) then
        return "bandit"
    end

    if npcData and (
        npcData.isHostile == true
        or npcData.raidHostileFaction == true
        or safeTradeCycleMode == "hostile_bribe"
        or containsToken(status, "hostile")
        or containsToken(state, "hostile")
        or containsToken(state, "attack")
        or (type(entry) == "table" and entry.isHostile == true)
    ) then
        return "hostile"
    end

    if containsToken(state, "angry") or containsToken(status, "angry") then
        return "angry"
    end

    return nil
end

function Vocals.ResolveSpeechVocalType(npcData, text, sentiment, status, state, entry, hook)
    local explicitHook = hook
    if type(entry) == "table" then
        explicitHook = explicitHook or entry.vocalHook or entry.voiceHook or entry.hook
    end

    local hookCue = Vocals.ResolveHookVocalType(npcData, explicitHook)
    if hookCue then
        return hookCue
    end

    if type(entry) == "table" then
        local explicitCue = normalizeString(entry.vocalType or entry.voiceCue or entry.soundCue)
        if explicitCue then
            return explicitCue
        end

        if normalizeString(entry.soundName) then
            return nil
        end
    end

    local dispositionHook = Vocals.ResolveDispositionHook(npcData, status, state, entry)
    hookCue = Vocals.ResolveHookVocalType(npcData, dispositionHook)
    if hookCue then
        return hookCue
    end

    local stateCue = Internal.StateCueMap[normalizeString(state) or ""]
    if stateCue then
        return stateCue
    end

    local statusCue = Internal.StatusCueMap[normalizeString(status) or ""]
    if statusCue then
        return statusCue
    end

    local sentimentCue = Internal.SentimentCueMap[string.lower(normalizeString(sentiment) or "")]
    if sentimentCue then
        return sentimentCue
    end

    local lowerText = string.lower(normalizeString(text) or "")
    if lowerText ~= "" then
        if string.find(lowerText, "sigh", 1, true) then
            return "Sigh_Bored"
        end
        if string.find(lowerText, "reload", 1, true) then
            return "Chat_Angry"
        end
        if string.find(lowerText, "bye", 1, true) or string.find(lowerText, "goodbye", 1, true) then
            return Internal.HookCueMap.bye
        end
        if string.find(lowerText, "welcome", 1, true) or string.find(lowerText, "hello", 1, true) then
            return Internal.HookCueMap.welcome
        end
        if string.find(lowerText, "deal", 1, true) or string.find(lowerText, "trade", 1, true) then
            return Internal.HookCueMap.trading
        end
    end

    if npcData and npcData.isSleeping == true then
        return "State_Sleep"
    end

    return "Chat"
end

function Vocals.BuildSpeechAudio(npcData, options)
    local opts = type(options) == "table" and options or nil
    if not opts then
        return nil
    end

    local audio = {
        channel = opts.channel or "dialogue_vocals",
        cooldownMs = opts.cooldownMs or 0,
    }

    if opts.uiSound then
        audio.uiSound = opts.uiSound
        audio.uiVolume = opts.uiVolume or opts.volume
    end

    local entry = type(opts.entry) == "table" and opts.entry or nil
    audio.soundName = normalizeString(opts.soundName or (entry and entry.soundName) or nil)
    audio.vocalType = normalizeString(opts.vocalType or nil)

    if not audio.vocalType and not audio.soundName then
        audio.vocalType = Vocals.ResolveSpeechVocalType(
            npcData,
            opts.text,
            opts.sentiment,
            opts.status,
            opts.state,
            entry,
            opts.hook or opts.vocalHook or opts.voiceHook
        )
    end

    if opts.preferVariantPool == true or (opts.channel == "ambient_dialogue" and opts.preferVariantPool ~= false) then
        audio.preferVariantPool = true
    end

    if not audio.uiSound and not audio.vocalType and not audio.soundName then
        return nil
    end

    return audio
end

function Vocals.PlaySpeechAudio(zombie, npcData, audio)
    if type(audio) ~= "table" then
        return nil
    end

    if audio.uiSound then
        Vocals.PlayUISound(audio.uiSound, audio.uiVolume or audio.volume or 1.0)
    end

    if audio.vocalType or audio.soundName then
        local cueType = audio.vocalType or "Chat"
        if audio.preferVariantPool == true then
            cueType = collapseVariantPoolCue(cueType)
        end
        return Vocals.PlayVocal(zombie, npcData, cueType, audio)
    end

    return nil
end

function Vocals.BuildAmbientVocalType(npcData, text, sentiment, status, state, entry)
    return Vocals.ResolveSpeechVocalType(npcData, text, sentiment, status, state, entry, nil)
end
