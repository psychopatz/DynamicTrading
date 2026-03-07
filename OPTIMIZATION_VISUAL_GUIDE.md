# DynamicTrading V2 - Architecture & Optimization Visual Guide

---

## CURRENT ARCHITECTURE (What You Have Now)

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    SERVER (Single Authority)                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌───────────────────┐         ┌─────────────────────────┐  │
│  │ DTNPCManager      │         │ DynamicTrading_Roster   │  │
│  │ (Active Layer)    │         │ (Persistent Layer)      │  │
│  │                   │         │                         │  │
│  │ .Data[uuid]       │◄─────────│ .Souls[uuid]           │  │
│  │ ├─ uuid           │ Get/Save │ ├─ uuid                │  │
│  │ ├─ position       │         │ ├─ lastX, lastY        │  │
│  │ ├─ state          │         │ ├─ status              │  │
│  │ └─ brain          │         │ └─ return times        │  │
│  │                   │         │                         │  │
│  │ UUID → OutfitID   │         │ Survives resets        │  │
│  │ mapping           │         │                         │  │
│  └───────────────────┘         └─────────────────────────┘  │
│         ▲                                                    │
│         │ CheckForRespawn() every 3 sec                    │
│         │ CheckRosterSpawns() every 3 sec                 │
│         │                                                  │
│  ┌──────┴──────────────────────────────────────────────┐   │
│  │  Proximity Check: Player vs Brain.lastX/Y           │   │
│  │  If dist < 100 tiles AND same floor → SPAWN NPC     │   │
│  └───────────────────────────────────────────────────────┘   │
│                                                              │
└─────────────────────────────────────────────────────────────┘
         │
         │ sendServerCommand() BROADCAST TO ALL CLIENTS
         │
         ▼
┌─────────────────────────────────────────────────────────────┐
│              CLIENTS (Multiple Instances)                    │
├─────────────────────────────────────────────────────────────┤
│  Client A   │   Client B   │   Client C   │   Client D      │
│             │              │              │                 │
│ .NPCCache   │  .NPCCache   │  .NPCCache   │  .NPCCache      │
│ [uuid]      │  [uuid]      │  [uuid]      │  [uuid]         │
│ ├─ brain    │  ├─ brain    │  ├─ brain    │  ├─ brain       │
│ ├─ outfit   │  ├─ outfit   │  ├─ outfit   │  ├─ outfit      │
│ └─ zombie   │  └─ zombie   │  └─ zombie   │  └─ zombie      │
│             │              │              │                 │
│ Messages    │  Messages    │  Messages    │  Messages       │
│ received:   │  received:   │  received:   │  received:      │
│ ✓ All NPCs  │  ✓ All NPCs  │  ✓ All NPCs  │  ✓ All NPCs     │
│ ✓ All pos   │  ✓ All pos   │  ✓ All pos   │  ✓ All pos      │
│   updates   │    updates   │    updates   │    updates      │
│ ✓ All state │  ✓ All state │  ✓ All state │  ✓ All state    │
│   changes   │    changes   │    changes   │    changes      │
│             │              │              │                 │
└─────────────────────────────────────────────────────────────┘
```

### Message Flow (Current - Problematic)

```
Event: NPC spawns at position [100, 100]
│
├─► SyncToAllClients(zombie, brain)
│   │
│   └─► sendServerCommand("DTNPC", "SyncNPC", {
│       uuid = "...",
│       outfitID = 12345,
│       x = 100, y = 100, z = 0,
│       brain = {... full brain object ...}  ← ~2-3 KB
│   })
│
└─► Broadcast TO ALL 10 PLAYERS
    │
    ├─► Player A (5 tiles away) ✓ Needs update
    ├─► Player B (50 tiles away) ✓ Needs update
    ├─► Player C (150 tiles away) ✓ Needs update
    ├─► Player D (250 tiles away) ✓ Needs update
    ├─► Player E (500 tiles away) ✗ Doesn't need (wastes 2-3 KB)
    ├─► Player F (750 tiles away) ✗ Doesn't need (wastes 2-3 KB)
    ├─► Player G (1000 tiles away) ✗ Doesn't need (wastes 2-3 KB)
    ├─► Player H (1200 tiles away) ✗ Doesn't need (wastes 2-3 KB)
    ├─► Player I (1500 tiles away) ✗ Doesn't need (wastes 2-3 KB)
    └─► Player J (1800 tiles away) ✗ Doesn't need (wastes 2-3 KB)

Total: 10 messages, 6 are WASTED (60% overhead)
```

### Position Update Cycle (Every 6 seconds)

```
Time: 0:00 → NPC at [100, 100]
│
├─► BroadcastPosition(zombie, brain)
│   │
│   └─► sendServerCommand("DTNPC", "UpdatePosition", {
│       uuid = "...",
│       x = 100, y = 100, z = 0,
│       health = 100,
│       state = "Guard"
│   }) ← ~300 bytes
│
└─► Broadcast TO ALL 10 PLAYERS (6 wasted messages again)

Time: 0:06 → NPC moved to [102, 101]
│
├─► BroadcastPosition() again
│   └─► 10 messages × 300 bytes = 3 KB
│
└─► Repeat every 6 seconds...

Per minute: 10 broadcasts × 300 bytes = ~3 KB/min
Per player: ~300 bytes/min position data alone
```

---

## OPTIMIZATION TIER 1: DISTANCE-AWARE BROADCASTING

### Architecture Change (Minimal)

```
Server Proximity Check ADDED
│
└─► Before sending message:
    │
    ├─► For each player:
    │   ├─ Calculate: dist = √((npc.x - player.x)² + (npc.y - player.y)²)
    │   └─ If dist < 150 tiles AND same floor:
    │       └─► Send only to THIS player (targeted broadcast)
    │       └─► Skip this message for distant players
    │
    └─► Result: Only relevant players get messages
```

### Message Flow (After Optimization)

```
Event: NPC spawns at position [100, 100]
│
├─► SyncToAllClients(zombie, brain)
│   │
│   └─► BroadcastCommandWithTelemetry() ← NEW
│       │
│       └─► For each player:
│           │
│           ├─► Player A [5, 5]: dist = 5 ✓ Send
│           │   └─► sendServerCommand(playerA, "DTNPC", "SyncNPC", {...})
│           │
│           ├─► Player B [50, 50]: dist = 71 ✓ Send
│           │   └─► sendServerCommand(playerB, "DTNPC", "SyncNPC", {...})
│           │
│           ├─► Player C [200, 200]: dist = 283 ✗ Skip
│           ├─► Player D [300, 300]: dist = 424 ✗ Skip
│           ├─► Player E [500, 500]: dist = 707 ✗ Skip
│           ├─► Player F [750, 750]: dist = 1061 ✗ Skip
│           ├─► Player G [1000, 1000]: dist = 1414 ✗ Skip
│           ├─► Player H [1200, 1200]: dist = 1697 ✗ Skip
│           ├─► Player I [1500, 1500]: dist = 2121 ✗ Skip
│           └─► Player J [1800, 1800]: dist = 2546 ✗ Skip

Total: 10 messages, 2 sent, 8 saved ← 80% reduction!
```

### Benefits Visualization

```
BEFORE: Broadcast Model
┌────────────────────────────────────────────┐
│ 100 NPCs × 10 Players × 300 bytes every 6s│
│ = 30 KB × 10 = 300 KB/min per player      │
└────────────────────────────────────────────┘

AFTER: Distance-Aware Model
┌────────────────────────────────────────────┐
│ 100 NPCs (only ~7 nearby per player)       │
│ × 10 Players × 300 bytes every 6s          │
│ = 21 KB × 10 = ~30 KB/min per player      │
│                                            │
│ SAVINGS: 270 KB/min (~90%)                │
└────────────────────────────────────────────┘
```

---

## OPTIMIZATION TIER 1.2: DELTA SYNC VARIANTS

### Message Type Comparison

```
Message Type 1: Initial Spawn (SyncSimpleNPC)
┌─────────────────────────────────────────┐
│ {                                       │
│   syncType: "SIMPLE",                   │
│   uuid: "550e8400...",                  │
│   outfitID: 12345,                      │
│   x: 100, y: 100, z: 0,                │
│   name: "Bob",                          │
│   isFemale: false,                      │
│   visualID: 654321,                     │
│   state: "Guard"                        │
│ }                                       │
└─────────────────────────────────────────┘
Size: ~500 bytes (was 2-3 KB) ← 75% reduction


Message Type 2: State Change (SyncDeltaBrain)
┌─────────────────────────────────────────┐
│ {                                       │
│   syncType: "DELTA",                    │
│   uuid: "550e8400...",                  │
│   changes: {                            │
│     state: "Trading",                   │
│     health: 95                          │
│   }                                     │
│ }                                       │
└─────────────────────────────────────────┘
Size: ~100 bytes (was 2-3 KB) ← 95% reduction


Message Type 3: Position Update (UpdatePosition)
┌─────────────────────────────────────────┐
│ {                                       │
│   uuid: "550e8400...",                  │
│   x: 102, y: 101, z: 0,                │
│   health: 95,                           │
│   state: "Guard",                       │
│   velX: 0.5,  ← NEW: For interpolation │
│   velY: -0.3                            │
│ }                                       │
└─────────────────────────────────────────┘
Size: ~350 bytes (was 300, but fewer needed)


Message Type 4: Full Brain (SyncFullBrain)
┌─────────────────────────────────────────┐
│ {                                       │
│   syncType: "FULL",                     │
│   uuid: "550e8400...",                  │
│   brain: { ... complete object ... }    │
│ }                                       │
└─────────────────────────────────────────┘
Size: ~2-3 KB (use only for critical updates)
```

### Bandwidth Breakdown (With Tier 1 + 1.2)

```
Per Day (100 NPCs, 10 players):

Spawns (avg 10/day): 10 × 500 bytes × 10 players = 50 KB
State changes (avg 30/day): 30 × 100 bytes × 10 players = 30 KB
Position updates (every 6 sec):
  - 1440 min/day × 10 broadcasts/min × 350 bytes × 10 players
  - = 1440 × 35 KB = 50.4 MB
Joins (avg 5/day): 5 × 50 KB = 250 KB

TOTAL: ~50 MB/day (or ~35 KB/min average)

BEFORE these optimizations: ~432 MB/day (or 300 KB/min)
IMPROVEMENT: 88% reduction ✓
```

---

## OPTIMIZATION TIER 2: CLIENT-SIDE INTERPOLATION

### How It Works

```
SERVER BROADCASTS LESS FREQUENTLY (every 12 seconds instead of 6)
│
├─► Update 1: Time 0:00
│   ├─ Position: [100, 100]
│   ├─ Velocity: [+1.5 units/sec, -0.5 units/sec]
│   └─ Timestamp: 0
│
├─► ...Client-side prediction (6-12 seconds)...
│   │
│   └─► Client calculates:
│       ├─ At 0:03: [104.5, 98.5] (predicted)
│       ├─ At 0:06: [109, 97] (predicted)
│       ├─ At 0:09: [113.5, 95.5] (predicted)
│       └─ Movement appears smooth without server updates!
│
└─► Update 2: Time 0:12
    ├─ Position: [115, 94]
    ├─ Velocity: [+0.8 units/sec, -0.2 units/sec]
    └─ Timestamp: 12
        └─► Correct any drift from prediction and continue...
```

### Visual Comparison

```
WITHOUT Interpolation (Every 6 seconds):
├─► NPC at [100, 100] ◄ Teleport
├─ (invisible for 6 seconds)
├─► NPC at [112, 96] ◄ Teleport
├─ (invisible for 6 seconds)
├─► NPC at [124, 92] ◄ Teleport
└─ Jerky, stuttering appearance

WITH Interpolation (Every 12 seconds):
├─► NPC at [100, 100]
│   ├─ ~1sec later: appears at [101, 99.5]
│   ├─ ~2sec later: appears at [102, 99]
│   ├─ ~3sec later: appears at [103, 98.5]
│   ├─ ~6sec later: appears at [106, 97]
│   └─ ...smooth continuous movement...
├─► Update received: NPC at [112, 96]
│   └─ Correct position, continue interpolating...
└─ Smooth, natural appearance
```

### Benefits

```
Without Interpolation:
├─ Update frequency: Every 6 seconds
├─ Bandwidth: 300 KB/min per player
└─ Visual result: Jerky, stuttering NPCs

With Interpolation:
├─ Update frequency: Every 12 seconds ← 50% reduction!
├─ Bandwidth: 150 KB/min per player
└─ Visual result: Smooth, natural movement
```

---

## OPTIMIZATION TIER 2.2: INITIAL SYNC FILTERING

### Join Sequence

```
PLAYER JOINS SERVER (BEFORE optimization)
│
├─► Client: "OnCreatePlayer" event fires
│   └─► "I'm joining, give me all NPCs"
│
├─► sendClientCommand(player, "DTNPC", "RequestFullSync", {})
│
├─► Server receives RequestFullSync
│   │
│   └─► sendServerCommand(player, "DTNPC", "SyncAllNPCs", {
│       npcs = DTNPCManager.Data  ◄─ ALL 100-200 NPCs!
│   })
│
├─► Download: 100 NPCs × 2-3 KB = 200-300 KB
│   ├─ Network transfer time: 5-30 seconds (depends on connection)
│   └─ Player sees loading screens, stuttering
│
└─► After join, player sees NPCs even 500+ tiles away
    (but they're not visible/being used)

═══════════════════════════════════════════════════════════════

PLAYER JOINS SERVER (AFTER optimization)
│
├─► Client: "OnCreatePlayer" event fires
│   └─► "I'm joining at position [100, 100], give me nearby NPCs"
│
├─► sendClientCommand(player, "DTNPC", "RequestNearbySync", {
│   x = 100, y = 100, z = 0, radius = 200
│})
│
├─► Server receives RequestNearbySync
│   │
│   ├─► Filter: For each NPC in DTNPCManager.Data:
│   │   ├─ If dist < 200 tiles AND same floor:
│   │   │   └─ Include in nearbyNPCs
│   │   └─ Else: Skip
│   │
│   └─► sendServerCommand(player, "DTNPC", "SyncNearbyNPCs", {
│       npcs = nearbyNPCs  ◄─ Only ~10-20 NPCs!
│   })
│
├─► Download: 15 NPCs × 2-3 KB = 30-45 KB
│   ├─ Network transfer time: 1-3 seconds
│   └─ Player joins quickly
│
└─► As player explores, more NPCs load progressively
    via normal CheckRosterSpawns() proximity detection
```

### Bandwidth Comparison

```
Server with 100 NPCs, 10 players joining hourly

BEFORE:
├─ Per join: 300 KB
├─ 10 joins/hour: 3 MB
├─ 8 hours/day: 24 MB
└─ 30 days/month: 720 MB ← Major bandwidth spike!

AFTER:
├─ Per join: 30 KB (90% reduction!)
├─ 10 joins/hour: 300 KB
├─ 8 hours/day: 2.4 MB
└─ 30 days/month: 72 MB ← Manageable
```

---

## COMPLETE SYSTEM COMPARISON

### Current System (Before Optimizations)

```
┌──────────────────────────────────────────────────────────────────┐
│                       SERVER                                      │
│                                                                   │
│  Proximity Check: ✓ Implemented (100-tile range)                 │
│  CheckForRespawn: Every 3 seconds                                 │
│  CheckRosterSpawns: Every 3 seconds                               │
│                                                                   │
│  Network Layer:                                                  │
│  ├─ SyncToAllClients: BROADCAST to all players  ❌ Wasteful    │
│  ├─ BroadcastPosition: Every 6 sec to all       ❌ Wasteful    │
│  ├─ Initial Sync: Full roster on join           ❌ Wasteful    │
│  ├─ Message types: Only full brain              ❌ No compression│
│  └─ Update frequency: Uniform for all NPCs      ❌ Inefficient │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
         │                    │                      │
         │                    │                      │
         ▼                    ▼                      ▼
    [Player A]          [Player B]             [Player C]
    (Nearby)            (Far Away)             (Very Far)
    Get: All updates    Get: All updates       Get: All updates
    Need: Only nearby   Need: Nothing          Need: Nothing
    Wastage: 0%         Wastage: 100%          Wastage: 100%


BANDWIDTH: 300 KB/min per player ❌
SCALABILITY: Breaks at 20 players ❌
```

### After All Optimizations (Tiers 1-3)

```
┌──────────────────────────────────────────────────────────────────┐
│                       SERVER                                      │
│                                                                   │
│  Proximity Check: ✓ Implemented (100-tile range)                 │
│  CheckForRespawn: Every 3 seconds                                 │
│  CheckRosterSpawns: Every 3 seconds (only nearby NPCs)  ✓ Smart │
│                                                                   │
│  Network Layer:                                                  │
│  ├─ SyncToNearbyPlayers: TARGETED broadcasts  ✓ Smart          │
│  ├─ BroadcastPosition: Every 12 sec (interpol) ✓ Reduced      │
│  ├─ Initial Sync: Filtered by distance         ✓ Smart         │
│  ├─ Message types: Simple/Delta/Full variants  ✓ Compressed   │
│  └─ Update frequency: Smart (50-frequency)     ✓ Adaptive     │
│                                                                   │
│  Monitoring:                                                     │
│  ├─ Bandwidth per message type                 ✓ Tracked       │
│  ├─ Player-to-NPC visibility culling           ✓ Implemented  │
│  └─ Interpolation enable/disable toggle        ✓ Configurable │
│                                                                   │
└──────────────────────────────────────────────────────────────────┘
         │                    │                      │
         │                    │                      │
         ▼                    ▼                      ▼
    [Player A]          [Player B]             [Player C]
    (Nearby)            (Far Away)             (Very Far)
    Get: Nearby upd.    Get: Only join data    Get: Only join data
    Need: Nearby        Need: Nothing new      Need: Nothing new
    Wastage: 0%         Wastage: 5%            Wastage: 5%


BANDWIDTH: 30 KB/min per player ✓
SCALABILITY: Handles 50+ players smoothly ✓
```

---

## IMPLEMENTATION TIMELINE

### Week 1-2: Tier 1 & 1.2

```
Day 1-2: Foundation
├─ Create DTNPC_Manager_Broadcast.lua
└─ Test GetPlayersInRange() function

Day 3-4: Update Sync Functions
├─ Modify SyncToAllClients()
├─ Modify BroadcastPosition()
└─ Enable debug logging

Day 5: Test Phase 1
├─ Test: 10 NPCs, 5 players
├─ Verify: 80-90% message reduction
└─ Debug: Any desyncs

Day 6-7: Delta Sync
├─ Create sync variants (Simple, Delta, Full)
├─ Update client handlers
└─ Test: Message size reduction

Day 8: Validation
├─ Bandwidth before/after comparison
├─ Player experience check (no desyncs)
└─ Document findings
```

### Week 2-3: Tier 2

```
Day 9-10: Interpolation
├─ Create DTNPC_ClientInterpolation.lua
├─ Add velocity to UpdatePosition
└─ Test: Smooth movement

Day 11-12: Reduce Broadcast Frequency
├─ Change from 6 sec → 12 sec
├─ Test: Still smooth with interpolation
└─ Verify: 50% less position traffic

Day 13-14: Initial Sync Filtering
├─ Change RequestFullSync → RequestNearbySync
├─ Add server handler
└─ Test: Join time < 3 seconds

Day 15: Stress Test
├─ Test: 50 NPCs, 10 players
├─ Test: 100 NPCs, 20 players
└─ Measure: CPU usage, bandwidth
```

### Week 3-4: Tier 3 & Production

```
Day 16-19: Advanced Optimizations
├─ Smart distance-based frequency
├─ Message batching
├─ Visibility checks
└─ Comprehensive testing

Day 20: Documentation & Release
├─ Update changelog
├─ Document new features
├─ Create troubleshooting guide
└─ Release to test servers

Day 21-28: Monitoring & Tuning
├─ Collect feedback from testers
├─ Adjust constants based on real data
└─ Optimize further as needed
```

---

## EXPECTED RESULTS SUMMARY

| Metric | Before | After | Improvement |
|--------|--------|-------|-------------|
| **Bandwidth/Player** | 300 KB/min | 30 KB/min | 90% ↓ |
| **Join Data** | 200-600 KB | 20-60 KB | 90% ↓ |
| **Position Update Size** | 300 bytes | 350 bytes* | Same/Slight ↑ |
| **Update Frequency** | Every 6 sec | Every 12 sec | 50% ↓ |
| **State Change Size** | 2-3 KB | 100 bytes | 95% ↓ |
| **Server CPU (Broadcasts)** | High O(n×m) | Low O(m) | 70% ↓ |
| **Max Players Supported** | ~20 | ~100+ | 5x ↑ |

*Position updates are slightly larger due to velocity data, but sent half as often.

---

## KEY TAKEAWAY

```
┌─────────────────────────────────────────────────────┐
│  You have the RIGHT ARCHITECTURE                    │
│  But WRONG NETWORK IMPLEMENTATION                   │
│                                                     │
│  Fix:                                               │
│  1. Stop broadcasting to everyone (distance-aware) │
│  2. Send less data (delta sync)                    │
│  3. Let client predict movement (interpolation)   │
│                                                     │
│  Result:                                            │
│  • 90% bandwidth reduction                         │
│  • 5x better scalability                           │
│  • Same game experience, much better performance   │
│                                                     │
│  Timeline: 4 weeks, doable                         │
│  Risk: Low (optimizing, not redesigning)           │
│  Payoff: Transforms mod from broken to scalable   │
└─────────────────────────────────────────────────────┘
```

