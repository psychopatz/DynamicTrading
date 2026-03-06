(async function () {
  const SG = window.SimulateGame;
  const data = await SG.loadData();

  const items = data.items || {};
  const traderSamples = (data.day0 && data.day0.traderSamples) || {};
  const archetypes = data.archetypes || {};
  const descriptorRoots = new Set(["Origin", "Quality", "Rarity", "Theme"]);

  let settings = SG.bindSettingsToggles(() => {
    settings = SG.getSettings();
    renderRegistry();
    renderPool();
    renderTagTree();
    updateDump();
  });

  const allTags = SG.collectAllTags(data);
  const tagList = document.getElementById("itemsTagList");
  allTags.forEach((tag) => {
    const opt = document.createElement("option");
    opt.value = tag;
    tagList.appendChild(opt);
  });

  const poolArchetype = document.getElementById("poolArchetype");
  Object.entries(archetypes).forEach(([archId, arch]) => {
    const opt = document.createElement("option");
    opt.value = archId;
    opt.textContent = `${archId} - ${arch.name}`;
    poolArchetype.appendChild(opt);
  });

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

  function renderRegistry() {
    const query = document.getElementById("itemSearch").value.trim().toLowerCase();
    const tagQuery = document.getElementById("itemTagSearch").value.trim();

    const rows = Object.entries(items)
      .filter(([itemId, itemDef]) => {
        const hay = `${itemDisplay(itemId)}`.toLowerCase();
        const idPass = !query || hay.includes(query);
        const tagsPass = !tagQuery || SG.tagMatches(itemDef.tags || [], tagQuery);
        return idPass && tagsPass;
      })
      .sort((a, b) => itemDisplay(a[0]).localeCompare(itemDisplay(b[0])))
      .slice(0, 800)
      .map(([itemId, itemDef]) => {
        const details = `Base: ${SG.formatPrice(itemDef.base_price)} | ${SG.formatQty(itemDef.stock_min)}-${itemDef.stock_max} | Tags: ${SG.formatTagList(itemDef.tags || [], settings)}`;
        return formattedItemRow(itemId, details);
      });

    SG.renderList(document.getElementById("itemsRegistryList"), rows);
    updateDump();
  }

  function renderPool() {
    const archId = poolArchetype.value;
    const sample = traderSamples[archId] || { stock: {} };
    const stock = sample.stock || {};

    const rows = Object.entries(stock)
      .sort((a, b) => itemDisplay(a[0]).localeCompare(itemDisplay(b[0])))
      .map(([itemId, info]) => {
        const details = `${SG.formatQty(info.qty)} | Base: ${SG.formatPrice(info.basePrice)} | Tags: ${SG.formatTagList(info.tags || [], settings)}`;
        return formattedItemRow(itemId, details);
      });

    SG.renderList(document.getElementById("poolList"), rows);
    updateDump();
  }

  function makeTreeRoot() {
    return { full: "", itemIds: new Set(), children: {} };
  }

  function insertTag(rootNode, fullTag, itemId) {
    let node = rootNode;
    let path = "";
    for (const part of fullTag.split(".")) {
      path = path ? `${path}.${part}` : part;
      if (!node.children[part]) {
        node.children[part] = { full: path, itemIds: new Set(), children: {} };
      }
      node.children[part].itemIds.add(itemId);
      node = node.children[part];
    }
  }

  function buildTagTrees() {
    const primary = makeTreeRoot();
    const descriptors = makeTreeRoot();

    for (const [itemId, itemDef] of Object.entries(items)) {
      for (const fullTag of itemDef.tags || []) {
        const root = fullTag.split(".")[0];
        if (descriptorRoots.has(root)) {
          insertTag(descriptors, fullTag, itemId);
        } else {
          insertTag(primary, fullTag, itemId);
        }
      }
    }

    return { primary, descriptors };
  }

  function renderNodeList(container, nodeMap) {
    const keys = Object.keys(nodeMap).sort((a, b) => a.localeCompare(b));
    for (const key of keys) {
      const node = nodeMap[key];
      const hasChildren = Object.keys(node.children).length > 0;

      if (hasChildren) {
        const details = document.createElement("details");
        details.className = "tree-node";

        const summary = document.createElement("summary");
        summary.className = "tree-line";

        const text = document.createElement("span");
        text.textContent = `${SG.formatTagLabel(node.full, settings)} (${node.itemIds.size})`;

        const filterBtn = document.createElement("button");
        filterBtn.type = "button";
        filterBtn.className = "mini tag-chip";
        filterBtn.textContent = "Filter";
        filterBtn.addEventListener("click", (ev) => {
          ev.preventDefault();
          ev.stopPropagation();
          document.getElementById("itemTagSearch").value = node.full;
          renderRegistry();
        });

        summary.appendChild(text);
        summary.appendChild(filterBtn);
        details.appendChild(summary);

        const child = document.createElement("div");
        child.className = "tree-children";
        renderNodeList(child, node.children);
        details.appendChild(child);

        container.appendChild(details);
      } else {
        const row = document.createElement("div");
        row.className = "tree-line tree-leaf";

        const text = document.createElement("span");
        text.textContent = `${SG.formatTagLabel(node.full, settings)} (${node.itemIds.size})`;

        const filterBtn = document.createElement("button");
        filterBtn.type = "button";
        filterBtn.className = "mini tag-chip";
        filterBtn.textContent = "Filter";
        filterBtn.addEventListener("click", () => {
          document.getElementById("itemTagSearch").value = node.full;
          renderRegistry();
        });

        row.appendChild(text);
        row.appendChild(filterBtn);
        container.appendChild(row);
      }
    }
  }

  function renderTagTree() {
    const { primary, descriptors } = buildTagTrees();
    const rootNode = document.getElementById("tagTree");
    rootNode.innerHTML = "";

    const primaryWrap = document.createElement("details");
    primaryWrap.className = "tree-node";
    primaryWrap.open = true;
    primaryWrap.innerHTML = "<summary class='tree-line'>Core Tag Hierarchy</summary>";
    const primaryBody = document.createElement("div");
    primaryBody.className = "tree-children";
    renderNodeList(primaryBody, primary.children);
    primaryWrap.appendChild(primaryBody);

    const descWrap = document.createElement("details");
    descWrap.className = "tree-node";
    descWrap.innerHTML = "<summary class='tree-line'>Global Descriptor Tags (Origin, Quality, Rarity, Theme)</summary>";
    const descBody = document.createElement("div");
    descBody.className = "tree-children";
    renderNodeList(descBody, descriptors.children);
    descWrap.appendChild(descBody);

    rootNode.appendChild(primaryWrap);
    rootNode.appendChild(descWrap);
  }

  function updateDump() {
    const archId = poolArchetype.value;
    const sample = traderSamples[archId] || { stock: {} };
    const visibleCount = document.querySelectorAll("#itemsRegistryList .item").length;
    const dump = {
      totalItems: Object.keys(items).length,
      totalDynamicTags: allTags.length,
      descriptorRoots: Array.from(descriptorRoots),
      selectedPoolArchetype: archId,
      poolItemCount: Object.keys(sample.stock || {}).length,
      visibleRegistryRows: visibleCount,
      filters: {
        itemSearch: document.getElementById("itemSearch").value.trim(),
        tagSearch: document.getElementById("itemTagSearch").value.trim(),
      },
      displaySettings: settings,
    };
    document.getElementById("itemsDump").textContent = JSON.stringify(dump, null, 2);
  }

  document.getElementById("itemSearch").addEventListener("input", renderRegistry);
  document.getElementById("itemTagSearch").addEventListener("input", renderRegistry);
  poolArchetype.addEventListener("change", renderPool);

  renderRegistry();
  renderPool();
  renderTagTree();
})();
