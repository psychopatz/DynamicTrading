-- ==============================================================================
-- DTNPC_ProtectTargeting_Candidates.lua
-- Candidate merge and scoring helpers for DTNPC protect targeting.
-- ==============================================================================

DTNPCProtect = DTNPCProtect or {}
DTNPCProtect.Internal = DTNPCProtect.Internal or {}

local Internal = DTNPCProtect.Internal

local function upsertZombieCandidate(candidates, candidateMap, entry)
    local key = entry and entry.id
    if not key then
        return
    end

    local index = candidateMap[key]
    if index then
        local existing = candidates[index]
        existing.dist = math.min(existing.dist, entry.dist)
        existing.acquire = existing.acquire or entry.acquire
        existing.keep = existing.keep or entry.keep
        existing.isCurrent = existing.isCurrent or entry.isCurrent
        return
    end

    candidates[#candidates + 1] = entry
    candidateMap[key] = #candidates
end

local function getZombieCandidateCrowdStats(candidates, candidateIndex)
    local radius = tonumber(DTNPCProtect.CONFIG.MeleeCrowdRadius) or 1.8
    local radiusSq = radius * radius
    local candidate = candidates[candidateIndex]
    local count = 0
    local closest = 9999

    if not candidate then
        return 0, closest
    end

    for i = 1, #candidates do
        if i ~= candidateIndex then
            local other = candidates[i]
            local dx = other.x - candidate.x
            local dy = other.y - candidate.y
            local distSq = (dx * dx) + (dy * dy)
            if distSq <= radiusSq then
                local dist = math.sqrt(distSq)
                count = count + 1
                if dist < closest then
                    closest = dist
                end
            end
        end
    end

    return count, closest
end

local function getZombieCandidateScore(candidates, candidateIndex)
    local candidate = candidates[candidateIndex]
    if not candidate then
        return 9999
    end

    local crowdCount, crowdClosest = getZombieCandidateCrowdStats(candidates, candidateIndex)
    candidate.crowdCount = crowdCount
    candidate.crowdClosest = crowdClosest

    local score = candidate.dist
    local crowdPenalty = tonumber(DTNPCProtect.CONFIG.MeleeCrowdPenalty) or 0.8
    local closestPenalty = tonumber(DTNPCProtect.CONFIG.MeleeCrowdClosestPenalty) or 0.7
    score = score + (math.max(0, crowdCount - 1) * crowdPenalty)
    if crowdCount > 0 and crowdClosest <= 0.9 then
        score = score + closestPenalty
    end
    return score
end

local function chooseBestZombieCandidates(candidates, currentTargetID)
    local bestAcquire = nil
    local bestAcquireScore = nil
    local currentKeep = nil
    local currentKeepScore = nil

    for i = 1, #candidates do
        local candidate = candidates[i]
        local score = getZombieCandidateScore(candidates, i)

        if candidate.acquire and (bestAcquireScore == nil or score < bestAcquireScore) then
            bestAcquire = candidate
            bestAcquireScore = score
        end

        if candidate.keep and currentTargetID and candidate.id == currentTargetID then
            currentKeep = candidate
            currentKeepScore = score
        end
    end

    local stickyBias = tonumber(DTNPCProtect.CONFIG.StickyTargetScoreBias) or 0.45
    if currentKeep and (not bestAcquire or currentKeepScore <= (bestAcquireScore + stickyBias)) then
        return currentKeep, bestAcquire
    end

    return nil, bestAcquire
end

Internal.UpsertZombieCandidate = upsertZombieCandidate
Internal.ChooseBestZombieCandidates = chooseBestZombieCandidates
