-- ==============================================================================
-- Position update handlers for client-side network sync modules.
-- ==============================================================================

DTNPCClient = DTNPCClient or {}
DTNPC_ClientSync = DTNPC_ClientSync or {}

local ClientSync = DTNPC_ClientSync

ClientSync.Network = ClientSync.Network or {}

local Network = ClientSync.Network
local Helpers = Network.Helpers or {}
local Handlers = Network.Handlers or {}

Network.Modules = Network.Modules or {}
Network.Helpers = Helpers
Network.Handlers = Handlers

if Network.Modules.CommandUpdate then
    return
end

Network.Modules.CommandUpdate = true

local function applyRemoteLocomotion(zombie, args)
    if not zombie or not args or args.isMoving == nil then
        return
    end

    local moving = args.isMoving == true
    local isRunning = args.isRunning == true
    local isCrawling = args.isCrawling == true or tostring(args.state or "") == "Incapacitated"
    local moveAnim = moving and (args.moveAnim or (isCrawling and "Crawl" or (isRunning and "Run" or "Walk"))) or ""
    local animSpeed = tonumber(args.animSpeed)
        or (moving and (isCrawling and 0.28 or (isRunning and 1.2 or 1.0)) or 0.0)
    local walkType = args.walkType ~= nil and tostring(args.walkType) or (moving and not isCrawling and "1" or "")
    local dtWalkType = args.dtWalkType ~= nil and tostring(args.dtWalkType) or (isCrawling and "Crawl" or moveAnim)

    zombie:setVariable("DTNPC", true)
    zombie:setVariable("bBecomeCrawler", false)
    zombie:setVariable("bCrawling", false)
    zombie:setVariable("FallOnFront", false)
    zombie:setVariable("bMoving", moving)
    zombie:setVariable("isMoving", moving)
    zombie:setVariable("DTNPCMoveAnim", moveAnim)
    zombie:setVariable("DTWalkType", dtWalkType)
    zombie:setVariable("Speed", animSpeed)
    zombie:setVariable("DTNPCAnimSpeed", animSpeed)
    zombie:setVariable("MovementSpeed", animSpeed)
    zombie:setVariable("WalkSpeed", moving and math.max(0.1, animSpeed) or 0.0)
    zombie:setVariable("RunSpeed", moving and math.max(0.1, animSpeed) or 0.0)
    zombie:setRunning(isRunning and moving)
    zombie:setVariable("WalkType", walkType)

    if zombie.setWalkType and (moveAnim == "Walk" or moveAnim == "Run") then
        pcall(zombie.setWalkType, zombie, moveAnim)
    end
    if zombie.setSpeedMod then
        pcall(zombie.setSpeedMod, zombie, 1)
    end
end

function Handlers.HandleUpdatePosition(args)
    if not args or not args.uuid then
        return
    end

    local uuid = args.uuid
    local cached = DTNPCClient.NPCCache[uuid]
    local bodyInstanceID = Helpers.ResolveBodyInstanceID(args)

    Helpers.RecordInterpolation(uuid, args.x, args.y, args.z)

    if cached and cached.npcData then
        cached.npcData.lastX = math.floor(args.x)
        cached.npcData.lastY = math.floor(args.y)
        cached.npcData.lastZ = math.floor(args.z)
        cached.npcData.combatHealth = type(cached.npcData.combatHealth) == "table" and cached.npcData.combatHealth or {}

        if args.health then
            cached.npcData.health = args.health
        end
        if args.combatHealthCurrent ~= nil then
            cached.npcData.combatHealth.current = args.combatHealthCurrent
        end
        if args.combatHealthMax ~= nil then
            cached.npcData.combatHealth.max = args.combatHealthMax
        end
        if args.combatHealthEnabled ~= nil then
            cached.npcData.combatHealth.enabled = args.combatHealthEnabled == true
        end
        if args.combatHealthBandageActive ~= nil then
            cached.npcData.combatHealth.activeBandage = args.combatHealthBandageActive == true
        end
        if args.combatHealthBandageDirty ~= nil then
            cached.npcData.combatHealth.bandageDirty = args.combatHealthBandageDirty == true
        end
        if args.combatHealthBandageTier ~= nil then
            cached.npcData.combatHealth.bandageTier = args.combatHealthBandageTier
        end
        if args.combatHealthBandageItemFullType ~= nil then
            cached.npcData.combatHealth.bandageItemFullType = args.combatHealthBandageItemFullType
        end
        if args.state then
            cached.npcData.state = args.state
        end
        if args.status then
            cached.npcData.status = args.status
        end
        if args.combatOrder ~= nil then
            cached.npcData.combatOrder = args.combatOrder
        end
        if args.guardCombatOrder ~= nil then
            cached.npcData.guardCombatOrder = args.guardCombatOrder
        end
        if args.guardAttackMode ~= nil then
            cached.npcData.guardAttackMode = args.guardAttackMode
        end
        if args.protectNoticeSerial ~= nil then
            cached.npcData.protectNoticeSerial = args.protectNoticeSerial
        end
        if args.protectNoticeText ~= nil then
            cached.npcData.protectNoticeText = args.protectNoticeText
        end
        if args.protectNoticeSentiment ~= nil then
            cached.npcData.protectNoticeSentiment = args.protectNoticeSentiment
        end
        if args.protectNoticeDialogueStatus ~= nil then
            cached.npcData.protectNoticeDialogueStatus = args.protectNoticeDialogueStatus
        end
        if args.protectNoticeDialogueState ~= nil then
            cached.npcData.protectNoticeDialogueState = args.protectNoticeDialogueState
        end
        if bodyInstanceID then
            DTNPCClient.BodyInstanceIDToUUID[bodyInstanceID] = uuid
            cached.npcData.currentBodyInstanceID = bodyInstanceID
        end

        local zombie = Helpers.FindZombieByIdentifiers(uuid, bodyInstanceID)
        if zombie then
            local zombieData = DTNPC.GetData(zombie)
            if zombieData then
                zombieData.combatHealth = type(zombieData.combatHealth) == "table" and zombieData.combatHealth or {}
                if args.state then
                    zombieData.state = args.state
                end
                if args.health then
                    zombieData.health = args.health
                end
                if args.combatHealthCurrent ~= nil then
                    zombieData.combatHealth.current = args.combatHealthCurrent
                end
                if args.combatHealthMax ~= nil then
                    zombieData.combatHealth.max = args.combatHealthMax
                end
                if args.combatHealthEnabled ~= nil then
                    zombieData.combatHealth.enabled = args.combatHealthEnabled == true
                end
                if args.combatHealthBandageActive ~= nil then
                    zombieData.combatHealth.activeBandage = args.combatHealthBandageActive == true
                end
                if args.combatHealthBandageDirty ~= nil then
                    zombieData.combatHealth.bandageDirty = args.combatHealthBandageDirty == true
                end
                if args.combatHealthBandageTier ~= nil then
                    zombieData.combatHealth.bandageTier = args.combatHealthBandageTier
                end
                if args.combatHealthBandageItemFullType ~= nil then
                    zombieData.combatHealth.bandageItemFullType = args.combatHealthBandageItemFullType
                end
                if args.status then
                    zombieData.status = args.status
                end
                if args.combatOrder ~= nil then
                    zombieData.combatOrder = args.combatOrder
                end
                if args.guardCombatOrder ~= nil then
                    zombieData.guardCombatOrder = args.guardCombatOrder
                end
                if args.guardAttackMode ~= nil then
                    zombieData.guardAttackMode = args.guardAttackMode
                end
                if args.protectNoticeSerial ~= nil then
                    zombieData.protectNoticeSerial = args.protectNoticeSerial
                end
                if args.protectNoticeText ~= nil then
                    zombieData.protectNoticeText = args.protectNoticeText
                end
                if args.protectNoticeSentiment ~= nil then
                    zombieData.protectNoticeSentiment = args.protectNoticeSentiment
                end
                if args.protectNoticeDialogueStatus ~= nil then
                    zombieData.protectNoticeDialogueStatus = args.protectNoticeDialogueStatus
                end
                if args.protectNoticeDialogueState ~= nil then
                    zombieData.protectNoticeDialogueState = args.protectNoticeDialogueState
                end
            end

            if not DTNPCClient.LocalControlled[uuid] then
                DTNPCClient.ReconcilePosition(zombie, args.x, args.y, args.z)
                applyRemoteLocomotion(zombie, args)
            end
        end

        if args.state then
            cached.lastReportedState = cached.lastReportedState or {}
            cached.lastReportedState.state = args.state
        end
        if args.combatOrder ~= nil then
            cached.lastReportedState = cached.lastReportedState or {}
            cached.lastReportedState.combatOrder = args.combatOrder
        end
        if args.guardCombatOrder ~= nil then
            cached.lastReportedState = cached.lastReportedState or {}
            cached.lastReportedState.guardCombatOrder = args.guardCombatOrder
        end
        if args.protectNoticeSerial ~= nil then
            cached.lastReportedState = cached.lastReportedState or {}
            cached.lastReportedState.protectNoticeSerial = args.protectNoticeSerial
        end
    end

    Helpers.TrackNPCSystems(nil, cached and cached.npcData or nil, uuid, bodyInstanceID)

    if (args.health or args.combatHealthCurrent ~= nil) and DTNPCClient.MarkNPCCombatForHealthBars then
        DTNPCClient.MarkNPCCombatForHealthBars(uuid, nil, cached and cached.npcData or nil, bodyInstanceID)
    end
end
