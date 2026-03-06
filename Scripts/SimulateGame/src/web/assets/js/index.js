(async function () {
  const SG = window.SimulateGame;
  const data = await SG.loadData();

  const items = data.items || {};
  const archetypes = data.archetypes || {};
  const tradeMatrix = (data.day0 && data.day0.tradeMatrix) || {};
  const unservedItems = (data.day0 && data.day0.unservedItems) || [];
  const eventDefs = data.events || {};
  const allTags = SG.collectAllTags(data);

  let settings = SG.bindSettingsToggles(() => {
    settings = SG.getSettings();
    renderUnserved();
    updateDump();
  });

  const itemSelect = document.getElementById("itemSelect");
  const archetypeSelect = document.getElementById("archetypeSelect");

  Object.keys(items).sort().forEach((itemId) => {
    const opt = document.createElement("option");
    opt.value = itemId;
    opt.textContent = SG.formatItemLabel(itemId, items[itemId] || {}, settings);
    itemSelect.appendChild(opt);
  });

  Object.entries(archetypes).forEach(([archId, arch]) => {
    const opt = document.createElement("option");
    opt.value = archId;
    opt.textContent = `${archId} - ${arch.name}`;
    archetypeSelect.appendChild(opt);
  });

  const customRules = [];

  function itemDisplay(itemId) {
    return SG.formatItemLabel(itemId, items[itemId] || {}, settings);
  }

  function formattedItemRow(itemId, details) {
    return {
      text: `${itemDisplay(itemId)} | ${details}`,
      copyText: itemId,
      title: (items[itemId] || {}).source_file ? `Source: ${(items[itemId] || {}).source_file}` : "",
    };
  }

  function renderUnserved() {
    const rows = unservedItems.map((itemId) => {
      const tags = SG.formatTagList((items[itemId] || {}).tags || [], settings);
      return formattedItemRow(itemId, `Tags: ${tags || "n/a"}`);
    });
    SG.renderList(document.getElementById("unservedList"), rows);
  }

  renderUnserved();

  document.getElementById("checkTradeBtn").addEventListener("click", () => {
    const itemId = itemSelect.value;
    const archId = archetypeSelect.value;
    const resultNode = document.getElementById("tradeResult");

    if (!items[itemId]) {
      resultNode.textContent = "Unknown item id.";
      return;
    }
    if (!tradeMatrix[itemId] || !tradeMatrix[itemId][archId]) {
      resultNode.textContent = "No matrix result for selection.";
      return;
    }

    const base = tradeMatrix[itemId][archId];
    const itemDef = items[itemId];

    let rulePrice = 1.0;
    let ruleVol = 1.0;
    for (const rule of customRules) {
      if (SG.tagMatches(itemDef.tags || [], rule.tag)) {
        rulePrice *= rule.price;
        ruleVol *= rule.vol;
      }
    }

    const finalBuy = Math.ceil(base.buyPrice * rulePrice);
    const finalSell = Math.floor(base.sellPrice * rulePrice);

    resultNode.textContent = [
      `Item: ${itemDisplay(itemId)}`,
      `Archetype: ${archId}`,
      `Tradeable: ${base.tradeable}`,
      `Buy Price: ${SG.formatPrice(base.buyPrice)} -> ${SG.formatPrice(finalBuy)}`,
      `Sell Price: ${SG.formatPrice(base.sellPrice)} -> ${SG.formatPrice(finalSell)}`,
      `Tags: ${SG.formatTagList(itemDef.tags || [], settings) || "n/a"}`,
      `Rule Price Mult: ${rulePrice.toFixed(3)}`,
      `Rule Volume Mult: ${ruleVol.toFixed(3)}`,
      `Copy raw ID from list row copy button.`,
    ].join("\n");

    updateDump();
  });

  document.getElementById("filterBtn").addEventListener("click", () => {
    const raw = document.getElementById("tagFilterInput").value.trim();
    const required = raw.split(",").map((x) => x.trim()).filter(Boolean);

    const matched = Object.entries(items)
      .filter(([, itemDef]) => SG.matchesAllTags(itemDef.tags || [], required))
      .slice(0, 400)
      .map(([itemId, itemDef]) => {
        const details = `Base: ${SG.formatPrice(itemDef.base_price)} | Tags: ${SG.formatTagList(itemDef.tags || [], settings)}`;
        return formattedItemRow(itemId, details);
      });

    SG.renderList(document.getElementById("filterResult"), matched);
    updateDump();
  });

  document.getElementById("generateHypBtn").addEventListener("click", () => {
    const allocRaw = document.getElementById("hypAlloc").value;
    const forbidRaw = document.getElementById("hypForbid").value;
    const forbid = forbidRaw.split(",").map((x) => x.trim()).filter(Boolean);

    let allocations;
    try {
      allocations = JSON.parse(allocRaw);
    } catch (_err) {
      SG.renderList(document.getElementById("hypResult"), ["Invalid allocation JSON."]);
      return;
    }

    const picks = [];
    for (const alloc of allocations) {
      if (!Array.isArray(alloc.tags)) continue;
      const count = Number(alloc.count || 0);
      const candidates = Object.entries(items)
        .filter(([, itemDef]) => !SG.hasForbiddenTag(itemDef.tags || [], forbid))
        .filter(([, itemDef]) => SG.matchesAllTags(itemDef.tags || [], alloc.tags))
        .map(([itemId]) => itemId);

      for (let i = 0; i < count && candidates.length > 0; i += 1) {
        const pick = candidates[Math.floor(Math.random() * candidates.length)];
        picks.push(pick);
      }
    }

    const counts = {};
    picks.forEach((id) => { counts[id] = (counts[id] || 0) + 1; });

    const rows = Object.entries(counts)
      .sort((a, b) => b[1] - a[1])
      .map(([itemId, qty]) => {
        const details = `${SG.formatQty(qty)} | Base: ${SG.formatPrice((items[itemId] || {}).base_price)} | Tags: ${SG.formatTagList((items[itemId] || {}).tags || [], settings)}`;
        return formattedItemRow(itemId, details);
      });

    SG.renderList(document.getElementById("hypResult"), rows);
    updateDump();
  });

  function refreshRules() {
    const rows = customRules.map((r, i) => ({
      text: `#${i + 1} Tag: ${SG.formatTagLabel(r.tag, settings)} | Price x${r.price} | Volume x${r.vol}`,
      copyText: r.tag,
    }));
    SG.renderList(document.getElementById("eventRules"), rows);
  }

  document.getElementById("addEventRuleBtn").addEventListener("click", () => {
    const tag = document.getElementById("eventTag").value.trim();
    const price = Number(document.getElementById("eventPrice").value);
    const vol = Number(document.getElementById("eventVol").value);
    if (!tag || Number.isNaN(price) || Number.isNaN(vol)) return;
    customRules.push({ tag, price, vol });
    refreshRules();
    updateDump();
  });

  for (const eventId of data.day0.activeEventIds || []) {
    const eventDef = eventDefs[eventId];
    if (!eventDef) continue;
    for (const [tag, effect] of Object.entries(eventDef.effects || {})) {
      customRules.push({
        tag,
        price: typeof effect.price === "number" ? effect.price : 1.0,
        vol: typeof effect.vol === "number" ? effect.vol : 1.0,
      });
    }
  }
  refreshRules();

  function updateDump() {
    const itemInput = itemSelect.value;
    const dump = {
      counts: {
        totalItems: Object.keys(items).length,
        totalArchetypes: Object.keys(archetypes).length,
        totalEvents: Object.keys(eventDefs).length,
        totalTags: allTags.length,
      },
      selected: {
        itemLabel: itemInput && items[itemInput] ? itemDisplay(itemInput) : "",
        archetype: archetypeSelect.value,
        tagFilter: document.getElementById("tagFilterInput").value.trim(),
      },
      displaySettings: settings,
      customRules,
    };

    document.getElementById("indexDump").textContent = JSON.stringify(dump, null, 2);
  }

  updateDump();
})();
