(async function () {
  const SG = window.SimulateGame;
  const data = await SG.loadData();

  const items = data.items || {};
  const archetypes = data.archetypes || {};
  const events = data.events || {};
  const allTags = SG.collectAllTags(data);

  let settings = SG.bindSettingsToggles(() => {
    settings = SG.getSettings();
    updateDump(state.cachedActiveIds || []);
  });

  const state = {
    day: 0,
    activeFlash: {},
    lastFlashDay: -10,
    cachedActiveIds: [...(data.day0.activeEventIds || [])],
  };

  const eventConfig = data.config;

  const archetypeSelect = document.getElementById("timelineArchetype");
  Object.entries(archetypes).forEach(([archId, arch]) => {
    const opt = document.createElement("option");
    opt.value = archId;
    opt.textContent = `${archId} - ${arch.name}`;
    archetypeSelect.appendChild(opt);
  });

  const tagList = document.getElementById("timelineTagList");
  allTags.forEach((tag) => {
    const opt = document.createElement("option");
    opt.value = tag;
    tagList.appendChild(opt);
  });

  function canSpawn(eventDef) {
    const src = eventDef.can_spawn_source || "";
    if (src.includes("AllowHardcoreEvents")) return true;
    return true;
  }

  function conditionPass(eventDef) {
    const kind = eventDef.condition_kind;
    if (!kind || kind === "none") return true;
    if (kind === "season") return SG.dayToSeason(state.day) === eventDef.condition_value;
    if (kind === "nights_gt" || kind === "days_gt") return state.day > Number(eventDef.condition_value || 0);
    return true;
  }

  function computeActiveEventIds() {
    for (const [eventId, expires] of Object.entries(state.activeFlash)) {
      if (state.day >= expires) delete state.activeFlash[eventId];
    }

    const active = new Set(Object.keys(state.activeFlash));
    const flashCandidates = [];

    for (const [eventId, eventDef] of Object.entries(events)) {
      if (eventDef.event_type === "flash") {
        if (canSpawn(eventDef)) flashCandidates.push(eventId);
      } else if (eventDef.event_type === "meta" || eventDef.event_type === "seasonal") {
        if (conditionPass(eventDef)) active.add(eventId);
      }
    }

    const activeFlashCount = Object.keys(state.activeFlash).length;
    const daysSince = state.day - state.lastFlashDay;
    if (
      activeFlashCount < Number(eventConfig.max_flash_events) &&
      daysSince >= Number(eventConfig.event_frequency_days) &&
      flashCandidates.length
    ) {
      const roll = 1 + Math.floor(Math.random() * 100);
      if (roll <= Number(eventConfig.event_chance_percent)) {
        const pick = flashCandidates[Math.floor(Math.random() * flashCandidates.length)];
        state.activeFlash[pick] = state.day + Number(eventConfig.flash_duration_days);
        state.lastFlashDay = state.day;
        active.add(pick);
      } else {
        state.lastFlashDay = state.day - (Number(eventConfig.event_frequency_days) - 1);
      }
    }

    return Array.from(active).sort();
  }

  function render() {
    document.getElementById("dayCounter").textContent = String(state.day);
    document.getElementById("seasonCounter").textContent = SG.dayToSeason(state.day);

    state.cachedActiveIds = computeActiveEventIds();

    const rows = state.cachedActiveIds.map((eventId) => {
      const ev = events[eventId];
      return {
        text: `${eventId} [${ev.event_type}] ${ev.name}`,
        copyText: eventId,
      };
    });
    SG.renderList(document.getElementById("activeEvents"), rows);
    updateDump(state.cachedActiveIds);
  }

  function probe() {
    const archId = archetypeSelect.value;
    const monitorTag = document.getElementById("timelineTag").value.trim();
    if (!archetypes[archId]) return;

    const activeDefs = (state.cachedActiveIds || []).map((id) => events[id]).filter(Boolean);

    const matchingItems = Object.entries(items)
      .filter(([, itemDef]) => SG.tagMatches(itemDef.tags || [], monitorTag))
      .slice(0, 50);

    let priceMult = 1.0;
    let volMult = 1.0;
    for (const ev of activeDefs) {
      for (const [tag, effect] of Object.entries(ev.effects || {})) {
        if (monitorTag === tag || monitorTag.startsWith(tag + ".") || tag.startsWith(monitorTag + ".")) {
          if (typeof effect.price === "number") priceMult *= effect.price;
          if (typeof effect.vol === "number") volMult *= effect.vol;
        }
      }
    }

    const lines = [
      `Day ${state.day} / ${SG.dayToSeason(state.day)}`,
      `Archetype: ${archId}`,
      `Monitor Tag: ${SG.formatTagLabel(monitorTag, settings)}`,
      `Active Events: ${(state.cachedActiveIds || []).join(", ") || "none"}`,
      `Tag Price Mult: ${priceMult.toFixed(3)}`,
      `Tag Volume Mult: ${volMult.toFixed(3)}`,
      `Matching Items: ${matchingItems.length}`,
      `Raw IDs available via copy buttons in list views.`,
    ];

    for (const [itemId, itemDef] of matchingItems.slice(0, 15)) {
      lines.push(`- ${SG.formatItemLabel(itemId, itemDef, settings)} | Tags: ${SG.formatTagList(itemDef.tags || [], settings)}`);
    }

    document.getElementById("probeOutput").textContent = lines.join("\n");
    updateDump(state.cachedActiveIds);
  }

  function updateDump(activeIds) {
    const dump = {
      day: state.day,
      season: SG.dayToSeason(state.day),
      selectedArchetype: archetypeSelect.value,
      timelineTag: SG.formatTagLabel(document.getElementById("timelineTag").value.trim(), settings),
      activeEventIds: activeIds,
      flashState: state.activeFlash,
      displaySettings: settings,
      counts: {
        totalEvents: Object.keys(events).length,
        totalItems: Object.keys(items).length,
        totalTags: allTags.length,
      },
    };
    document.getElementById("timelineDump").textContent = JSON.stringify(dump, null, 2);
  }

  document.getElementById("advance1").addEventListener("click", () => {
    state.day += 1;
    render();
  });

  document.getElementById("advance5").addEventListener("click", () => {
    state.day += 5;
    render();
  });

  document.getElementById("resetTimeline").addEventListener("click", () => {
    state.day = 0;
    state.activeFlash = {};
    state.lastFlashDay = -10;
    render();
  });

  document.getElementById("runProbe").addEventListener("click", probe);
  document.getElementById("timelineTag").addEventListener("input", () => updateDump(state.cachedActiveIds || []));
  archetypeSelect.addEventListener("change", () => updateDump(state.cachedActiveIds || []));

  render();
})();
