-- ==============================================================================
-- ColonyEconomy/Horde/DT_HordeLogic.lua
-- Logic: Handles daily horde event checks and combat resolution per faction.
-- ==============================================================================

local HordeDefs = require "DT/Common/ColonyEconomy/Horde/DT_HordeDefs"

local HordeLogic = {}

--- Rolls for a horde event, and resolves combat if one occurs.
-- Returns faction (updated), bool (did a horde attack happen?), number (casualties)
function HordeLogic.ProcessHorde(faction, id, data)
    if not faction then return faction, false, 0 end
    if faction.factionType == "independent" then return faction, false, 0 end

    -- Initialize tracking variables on the faction
    faction.daysSinceLastHorde = (faction.daysSinceLastHorde or 0) + 1
    faction.nextHordeInterval = faction.nextHordeInterval or HordeDefs.RollNextAttackDays()
    
    if faction.daysSinceLastHorde < faction.nextHordeInterval then
        return faction, false, 0
    end
    
    -- Horde hits!
    faction.daysSinceLastHorde = 0
    faction.nextHordeInterval = HordeDefs.RollNextAttackDays()
    
    local config = HordeDefs.GetConfig()
    local sandboxHordeMult = DynamicTrading.Config.GetSandboxMult("ZombieThreatMult")
    local hordeSize = math.ceil(HordeDefs.RollHordeSize() * sandboxHordeMult)
    local remainingZombies = hordeSize
    local casualties = 0
    
    DynamicTrading.Log("Colony", "Horde", "Alert", "Horde of " .. hordeSize .. " zombies attacking " .. faction.name .. "!")

    faction.stockpile = faction.stockpile or {}
    
    -- Phase 1: Ammo Defense (1 ammo kills 1 zombie)
    local availableAmmo = faction.stockpile.ammo or 0
    if availableAmmo > 0 then
        local zombiesKilledByAmmo = math.min(availableAmmo, remainingZombies)
        faction.stockpile.ammo = availableAmmo - zombiesKilledByAmmo
        remainingZombies = remainingZombies - zombiesKilledByAmmo
        
        if remainingZombies <= 0 then
            DynamicTrading.Log("Colony", "Horde", "Resolve", faction.name .. " successfully gunned down all " .. hordeSize .. " zombies.")
            if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
                DynamicTrading.GameplayLogs.AddFactionEvent(id, DynamicTrading.GameplayEvents.HORDE_REPELLED, {hordeSize})
            end
            return faction, true, 0
        end
    end
    
    -- Phase 2: Barricade HP Buffer (Zombies breach defenses)
    if faction.buildings and faction.buildings.Barricade then
        local bar = faction.buildings.Barricade
        -- Only a Level 1+ barricade provides defense
        if bar.level > 0 and bar.hp > 0 then
            -- 1 zombie deals config damage
            local damagePotential = remainingZombies * config.BarricadeDamagePerZombie
            local actualDamage = math.min(bar.hp, damagePotential)
            
            bar.hp = bar.hp - actualDamage
            
            -- Calculate how many zombies were "held back" by the barricade
            local zombiesDefended = math.floor(actualDamage / config.BarricadeDamagePerZombie)
            remainingZombies = math.max(0, remainingZombies - zombiesDefended)
            
            if bar.hp <= 0 then
                DynamicTrading.Log("Colony", "Horde", "Resolve", "Barricade destroyed at " .. faction.name .. "!")
            end
            
            if remainingZombies <= 0 then
                DynamicTrading.Log("Colony", "Horde", "Resolve", "Barricade absorbed the remaining horde at " .. faction.name .. ".")
                if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
                    DynamicTrading.GameplayLogs.AddFactionEvent(id, DynamicTrading.GameplayEvents.HORDE_REPELLED, {hordeSize})
                end
                return faction, true, 0
            end
        end
    end
    
    -- Phase 3: Casualties (Defenses failed)
    if remainingZombies > 0 then
        casualties = math.ceil(remainingZombies / config.CasualtiesPerRemaining)
        if casualties < 1 then casualties = 1 end
        
        -- Cap casualties to total member count
        casualties = math.min(casualties, faction.memberCount)
        
        -- Deal damage
        if faction.playerOwned and DynamicTrading_Factions.ApplyPlayerFactionCasualties then
            casualties = DynamicTrading_Factions.ApplyPlayerFactionCasualties(id, casualties, "Zombie Horde")
            faction = data[id] -- update reference if recreated
        else
            faction.memberCount = faction.memberCount - casualties
            DynamicTrading_Roster.RemoveSoul(id, casualties)
        end
        DynamicTrading.Log("Colony", "Horde", "Resolve", "Defenses failed! " .. faction.name .. " suffered " .. casualties .. " casualties from " .. remainingZombies .. " breached zombies.")
        if DynamicTrading.GameplayLogs and DynamicTrading.GameplayLogs.AddFactionEvent then
            DynamicTrading.GameplayLogs.AddFactionEvent(id, DynamicTrading.GameplayEvents.HORDE_CASUALTIES, {casualties, remainingZombies})
        end
    end
    
    return faction, true, casualties
end

return HordeLogic
