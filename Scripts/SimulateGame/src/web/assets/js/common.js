const SG_SETTINGS_KEY = "simulateGame.settings.v1";

async function loadData() {
  if (window.SIM_DATA) {
    return window.SIM_DATA;
  }

  if (window.location.protocol === "file:") {
    throw new Error(
      "Data unavailable in file:// mode. Rebuild output to generate assets/data/sim_data.js, or use the serve command."
    );
  }

  const res = await fetch("assets/data/sim_data.json");
  if (!res.ok) {
    throw new Error("Failed to load sim_data.json");
  }
  return res.json();
}

function getSettings() {
  const defaults = {
    sanitizeDisplay: true,
    showSourceFile: true,
  };

  try {
    const raw = localStorage.getItem(SG_SETTINGS_KEY);
    if (!raw) return defaults;
    return { ...defaults, ...JSON.parse(raw) };
  } catch (_err) {
    return defaults;
  }
}

function setSettings(next) {
  localStorage.setItem(SG_SETTINGS_KEY, JSON.stringify(next));
}

function bindSettingsToggles(onChange) {
  const settings = getSettings();

  const sanitizeToggle = document.getElementById("sanitizeToggle");
  if (sanitizeToggle) {
    sanitizeToggle.checked = !!settings.sanitizeDisplay;
    sanitizeToggle.addEventListener("change", () => {
      const next = getSettings();
      next.sanitizeDisplay = !!sanitizeToggle.checked;
      setSettings(next);
      if (onChange) onChange(next);
    });
  }

  const sourceToggle = document.getElementById("sourceToggle");
  if (sourceToggle) {
    sourceToggle.checked = !!settings.showSourceFile;
    sourceToggle.addEventListener("change", () => {
      const next = getSettings();
      next.showSourceFile = !!sourceToggle.checked;
      setSettings(next);
      if (onChange) onChange(next);
    });
  }

  return settings;
}

function prettyItemName(itemId) {
  if (!itemId) return "";
  const bare = itemId.includes(".") ? itemId.split(".").slice(1).join(".") : itemId;
  return bare
    .replace(/_/g, " ")
    .replace(/([a-z0-9])([A-Z])/g, "$1 $2")
    .replace(/\s+/g, " ")
    .trim();
}

function formatItemLabel(itemId, itemDef, settings) {
  const showSource = !!(settings && settings.showSourceFile);

  const pretty = prettyItemName(itemId);
  const primary = pretty;

  if (showSource && itemDef && itemDef.source_file) {
    return `${primary} <${itemDef.source_file}>`;
  }
  return primary;
}

function formatTagLabel(tag, settings) {
  if (!tag) return "";
  if (!(settings && settings.sanitizeDisplay)) return tag;

  return tag
    .split(".")
    .map((part) => part.replace(/([a-z0-9])([A-Z])/g, "$1 $2"))
    .join(" > ");
}

function formatTagList(tags, settings) {
  return (tags || []).map((tag) => formatTagLabel(tag, settings)).join(", ");
}

function formatPrice(value) {
  const num = Number(value || 0);
  return `$${num.toLocaleString()}`;
}

function formatQty(value) {
  return `Qty ${Number(value || 0).toLocaleString()}`;
}

function matchesAllTags(itemTags, requiredTags) {
  if (!requiredTags || requiredTags.length === 0) return false;
  return requiredTags.every((req) =>
    itemTags.some((tag) => tag === req || tag.startsWith(req + "."))
  );
}

function hasForbiddenTag(itemTags, forbiddenTags) {
  return forbiddenTags.some((forbid) =>
    itemTags.some((tag) => tag === forbid || tag.startsWith(forbid + "."))
  );
}

function eventMultipliersForItem(itemTags, events) {
  let priceMult = 1.0;
  let volMult = 1.0;

  for (const eventDef of events) {
    const effects = eventDef.effects || {};
    for (const tag of itemTags) {
      const effect = effects[tag];
      if (!effect) continue;
      if (typeof effect.price === "number") priceMult *= effect.price;
      if (typeof effect.vol === "number") volMult *= effect.vol;
    }
  }

  return { priceMult, volMult };
}

function dayToSeason(day) {
  const idx = Math.floor(day / 90) % 4;
  return ["Spring", "Summer", "Autumn", "Winter"][idx];
}

function tagMatches(itemTags, queryTag) {
  if (!queryTag) return false;
  return itemTags.some((tag) => tag === queryTag || tag.startsWith(queryTag + "."));
}

function collectAllTags(data) {
  const out = new Set();

  Object.keys(data.tags || {}).forEach((tag) => out.add(tag));
  Object.values(data.items || {}).forEach((itemDef) => {
    (itemDef.tags || []).forEach((tag) => out.add(tag));
  });

  return Array.from(out).sort();
}

function createCopyButton(text) {
  const btn = document.createElement("button");
  btn.type = "button";
  btn.className = "mini copy-btn";
  btn.textContent = "Copy";

  btn.addEventListener("click", async (ev) => {
    ev.preventDefault();
    ev.stopPropagation();
    try {
      await navigator.clipboard.writeText(String(text || ""));
      btn.textContent = "Copied";
      setTimeout(() => {
        btn.textContent = "Copy";
      }, 1000);
    } catch (_err) {
      btn.textContent = "Failed";
      setTimeout(() => {
        btn.textContent = "Copy";
      }, 1200);
    }
  });

  return btn;
}

function renderList(container, rows) {
  container.innerHTML = "";
  if (!rows.length) {
    container.textContent = "No results.";
    return;
  }

  for (const row of rows) {
    const rowText = typeof row === "string" ? row : String(row.text || "");
    const copyText = typeof row === "string" ? row : String(row.copyText || rowText);
    const rowTitle = typeof row === "string" ? "" : String(row.title || "");

    const div = document.createElement("div");
    div.className = "item item-row";
    if (rowTitle) div.title = rowTitle;

    const textNode = document.createElement("span");
    textNode.className = "item-text";
    textNode.textContent = rowText;

    div.appendChild(textNode);
    div.appendChild(createCopyButton(copyText));
    container.appendChild(div);
  }
}

window.SimulateGame = {
  loadData,
  getSettings,
  setSettings,
  bindSettingsToggles,
  prettyItemName,
  formatItemLabel,
  formatTagLabel,
  formatTagList,
  formatPrice,
  formatQty,
  createCopyButton,
  matchesAllTags,
  tagMatches,
  hasForbiddenTag,
  collectAllTags,
  eventMultipliersForItem,
  dayToSeason,
  renderList,
};
