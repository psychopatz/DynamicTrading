(async function () {
  const SG = window.SimulateGame;
  const data = await SG.loadData();

  const items = data.items || {};
  const archetypes = data.archetypes || {};
  const events = data.events || {};
  const tradeMatrix = (data.day0 && data.day0.tradeMatrix) || {};
  const traderSamples = (data.day0 && data.day0.traderSamples) || {};
  const allTags = SG.collectAllTags(data);
  const eventConfig = data.config;

  let settings = SG.bindSettingsToggles(() => {
    settings = SG.getSettings();
    renderSimulator();
    updateDump(state.cachedActiveIds || []);
  });

  const state = {
    day: 0,
    activeFlash: {},
    lastFlashDay: -10,
    cachedActiveIds: [...(data.day0.activeEventIds || [])],
  };

  const simState = {
    wallet: 1000,
    selectedTrader: "",
    stock: {},
    inventory: {},
    forcedEventIds: [],
  };

  const simTrader = document.getElementById("simTrader");
  const simEventSelect = document.getElementById("simEventSelect");

  Object.entries(archetypes).forEach(([archId, arch]) => {
    const opt = document.createElement("option");
    opt.value = archId;
    opt.textContent = `${archId} - ${arch.name}`;
    simTrader.appendChild(opt);
  });

  Object.entries(events).forEach(([eventId, eventDef]) => {
    const opt = document.createElement("option");
    opt.value = eventId;
    opt.textContent = `${eventId} [${eventDef.event_type}] ${eventDef.name}`;
    simEventSelect.appendChild(opt);
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

  function getEffectiveEventIds() {
    return Array.from(new Set([...(state.cachedActiveIds || []), ...simState.forcedEventIds]));
  }

  function getEffectiveEventDefs() {
    return getEffectiveEventIds().map((id) => events[id]).filter(Boolean);
  }

  function itemDisplay(itemId) {
    return SG.formatItemLabel(itemId, items[itemId] || {}, settings);
  }

  function itemTags(itemId) {
    return SG.formatTagList((items[itemId] || {}).tags || [], settings) || "n/a";
  }

  function cloneStock(stock) {
    const out = {};
    for (const [itemId, info] of Object.entries(stock || {})) out[itemId] = { ...info };
    return out;
  }

  function baseBuyFor(itemId, archId) {
    if (tradeMatrix[itemId] && tradeMatrix[itemId][archId]) return Number(tradeMatrix[itemId][archId].buyPrice || 1);
    return Math.max(1, Math.ceil(Number((items[itemId] || {}).base_price || 1)));
  }

  function baseSellFor(itemId, archId) {
    if (tradeMatrix[itemId] && tradeMatrix[itemId][archId]) return Number(tradeMatrix[itemId][archId].sellPrice || 0);
    return Math.max(0, Math.floor(Number((items[itemId] || {}).base_price || 1) * 0.5));
  }

  function eventPriceMult(itemDef) {
    let mult = 1.0;
    for (const ev of getEffectiveEventDefs()) {
      for (const [tag, effect] of Object.entries(ev.effects || {})) {
        if (SG.tagMatches(itemDef.tags || [], tag) && typeof effect.price === "number") mult *= effect.price;
      }
    }
    return mult;
  }

  function finalBuyFor(itemId) {
    const base = baseBuyFor(itemId, simState.selectedTrader);
    return Math.max(1, Math.ceil(base * eventPriceMult(items[itemId] || { tags: [] })));
  }

  function finalSellFor(itemId) {
    const base = baseSellFor(itemId, simState.selectedTrader);
    return Math.max(0, Math.floor(base * eventPriceMult(items[itemId] || { tags: [] })));
  }

  function resetSimulator(fullReset) {
    if (fullReset) {
      simState.wallet = Number(document.getElementById("simWallet").value || 1000);
      simState.selectedTrader = simTrader.value;
      simState.inventory = {};
      simState.forcedEventIds = [];
    }

    const sample = traderSamples[simState.selectedTrader] || { stock: {} };
    simState.stock = cloneStock(sample.stock);
    renderSimulator();
  }

  function buyItem(itemId) {
    const slot = simState.stock[itemId];
    if (!slot || slot.qty <= 0) return;

    const price = finalBuyFor(itemId);
    if (simState.wallet < price) return;

    slot.qty -= 1;
    simState.wallet -= price;
    simState.inventory[itemId] = (simState.inventory[itemId] || 0) + 1;
    renderSimulator();
  }

  function sellItem(itemId) {
    const qty = simState.inventory[itemId] || 0;
    if (qty <= 0) return;

    const price = finalSellFor(itemId);
    simState.wallet += price;
    simState.inventory[itemId] = qty - 1;
    if (simState.inventory[itemId] <= 0) delete simState.inventory[itemId];

    if (!simState.stock[itemId]) {
      simState.stock[itemId] = {
        qty: 0,
        basePrice: Number((items[itemId] || {}).base_price || 1),
        isExpert: false,
        tags: (items[itemId] || {}).tags || [],
      };
    }
    simState.stock[itemId].qty += 1;

    renderSimulator();
  }

  function renderTimelineState() {
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
  }

  function renderSimulator() {
    const effectiveEventIds = getEffectiveEventIds();
    const eventRows = effectiveEventIds.map((eventId) => {
      const ev = events[eventId];
      const forced = simState.forcedEventIds.includes(eventId) ? " (forced)" : "";
      return {
        text: `${eventId} [${ev.event_type}] ${ev.name}${forced}`,
        copyText: eventId,
      };
    });
    SG.renderList(document.getElementById("simActiveEvents"), eventRows);

    const q = document.getElementById("simSearch").value.trim().toLowerCase();
    const stockRows = Object.entries(simState.stock)
      .filter(([itemId, info]) => {
        const hay = `${itemDisplay(itemId)}`.toLowerCase();
        return info.qty > 0 && (!q || hay.includes(q));
      })
      .sort((a, b) => itemDisplay(a[0]).localeCompare(itemDisplay(b[0])))
      .slice(0, 500);

    const stockNode = document.getElementById("simStockList");
    stockNode.innerHTML = "";
    for (const [itemId, info] of stockRows) {
      const row = document.createElement("div");
      row.className = "line-actions";

      const text = document.createElement("div");
      text.textContent = `${itemDisplay(itemId)} | ${SG.formatQty(info.qty)} | Buy: ${SG.formatPrice(finalBuyFor(itemId))} | Sell: ${SG.formatPrice(finalSellFor(itemId))} | Tags: ${itemTags(itemId)}`;
      if ((items[itemId] || {}).source_file) text.title = `Source: ${(items[itemId] || {}).source_file}`;

      const actions = document.createElement("div");
      actions.className = "row-actions";
      actions.appendChild(SG.createCopyButton(itemId));

      const btn = document.createElement("button");
      btn.type = "button";
      btn.className = "mini";
      btn.textContent = "Buy +1";
      btn.addEventListener("click", () => buyItem(itemId));
      actions.appendChild(btn);

      row.appendChild(text);
      row.appendChild(actions);
      stockNode.appendChild(row);
    }

    const invRows = Object.entries(simState.inventory)
      .sort((a, b) => itemDisplay(a[0]).localeCompare(itemDisplay(b[0])));

    const invNode = document.getElementById("simInvList");
    invNode.innerHTML = "";
    if (!invRows.length) {
      invNode.textContent = "No inventory.";
    } else {
      for (const [itemId, qty] of invRows) {
        const row = document.createElement("div");
        row.className = "line-actions";

        const text = document.createElement("div");
        text.textContent = `${itemDisplay(itemId)} | ${SG.formatQty(qty)} | Sell: ${SG.formatPrice(finalSellFor(itemId))} | Tags: ${itemTags(itemId)}`;

        const actions = document.createElement("div");
        actions.className = "row-actions";
        actions.appendChild(SG.createCopyButton(itemId));

        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "mini";
        btn.textContent = "Sell +1";
        btn.addEventListener("click", () => sellItem(itemId));
        actions.appendChild(btn);

        row.appendChild(text);
        row.appendChild(actions);
        invNode.appendChild(row);
      }
    }

    const traderName = (archetypes[simState.selectedTrader] || {}).name || "Unknown";
    document.getElementById("simStatus").textContent = [
      `Day: ${state.day}`,
      `Trader: ${traderName}`,
      `Wallet: ${SG.formatPrice(simState.wallet)}`,
      `Visible Stock Rows: ${stockRows.length}`,
      `Inventory Rows: ${Object.keys(simState.inventory).length}`,
      `Timeline Events: ${(state.cachedActiveIds || []).join(", ") || "none"}`,
      `Forced Events: ${simState.forcedEventIds.join(", ") || "none"}`,
    ].join("\n");

    updateDump(state.cachedActiveIds || []);
  }

  function updateDump(activeIds) {
    const dump = {
      day: state.day,
      season: SG.dayToSeason(state.day),
      activeEventIds: activeIds,
      forcedEventIds: simState.forcedEventIds,
      simulator: {
        traderId: simState.selectedTrader,
        wallet: simState.wallet,
        stockCount: Object.keys(simState.stock).length,
        inventoryCount: Object.keys(simState.inventory).length,
      },
      displaySettings: settings,
      counts: {
        totalEvents: Object.keys(events).length,
        totalItems: Object.keys(items).length,
        totalTags: allTags.length,
      },
    };
    document.getElementById("simulatorDump").textContent = JSON.stringify(dump, null, 2);
  }

  document.getElementById("advance1").addEventListener("click", () => {
    state.day += 1;
    renderTimelineState();
    renderSimulator();
  });

  document.getElementById("advance5").addEventListener("click", () => {
    state.day += 5;
    renderTimelineState();
    renderSimulator();
  });

  document.getElementById("resetTimeline").addEventListener("click", () => {
    state.day = 0;
    state.activeFlash = {};
    state.lastFlashDay = -10;
    renderTimelineState();
    renderSimulator();
  });

  simTrader.addEventListener("change", () => {
    simState.selectedTrader = simTrader.value;
    resetSimulator(false);
  });

  document.getElementById("simWallet").addEventListener("change", () => {
    simState.wallet = Number(document.getElementById("simWallet").value || simState.wallet || 1000);
    renderSimulator();
  });

  document.getElementById("simSearch").addEventListener("input", renderSimulator);

  document.getElementById("simAddEventBtn").addEventListener("click", () => {
    const eventId = simEventSelect.value;
    if (!eventId) return;
    if (!simState.forcedEventIds.includes(eventId)) simState.forcedEventIds.push(eventId);
    renderSimulator();
  });

  document.getElementById("simResetBtn").addEventListener("click", () => {
    resetSimulator(true);
  });

  simState.selectedTrader = simTrader.value;
  resetSimulator(true);
  renderTimelineState();
  renderSimulator();
})();
