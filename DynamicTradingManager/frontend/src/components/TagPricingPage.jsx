import React, { useEffect, useMemo, useState } from 'react';
import {
  Alert,
  Autocomplete,
  Box,
  Button,
  Chip,
  Collapse,
  Divider,
  List,
  ListItemButton,
  Paper,
  Slider,
  Stack,
  TextField,
  Typography,
} from '@mui/material';
import {
  addBlacklistItem,
  deleteItemOverride,
  getOverrides,
  getPricingConfig,
  getPricingTags,
  previewPricingTag,
  saveItemOverride,
  savePricingConfig,
} from '../services/api';

const SLIDER_MIN = -500;
const SLIDER_MAX = 500;
const CATEGORY_HUES = {
  Building: 28,
  Clothing: 218,
  Container: 186,
  Electronics: 198,
  Food: 122,
  Literature: 276,
  Medical: 5,
  Misc: 210,
  Resource: 40,
  Tool: 52,
  Weapon: 18,
};

const formatPrice = (value) => {
  const num = Number(value || 0);
  if (!Number.isFinite(num)) {
    return String(value ?? '');
  }
  return `${num > 0 ? '+' : ''}${num}`;
};

const buildTagTree = (catalog) => {
  const nodes = new Map();

  const ensureNode = (tag) => {
    if (!nodes.has(tag)) {
      const parts = tag.split('.');
      nodes.set(tag, {
        tag,
        label: parts[parts.length - 1],
        item_count: 0,
        current_addition: 0,
        domains: [],
        samples: [],
        children: [],
      });
    }
    return nodes.get(tag);
  };

  const sortedCatalog = [...catalog].sort((left, right) => {
    const depthDiff = left.tag.split('.').length - right.tag.split('.').length;
    if (depthDiff !== 0) {
      return depthDiff;
    }
    return left.tag.localeCompare(right.tag);
  });

  sortedCatalog.forEach((row) => {
    const parts = row.tag.split('.');
    for (let index = 0; index < parts.length; index += 1) {
      const path = parts.slice(0, index + 1).join('.');
      const node = ensureNode(path);

      if (index === parts.length - 1) {
        node.item_count = row.item_count || 0;
        node.current_addition = Number(row.current_addition || 0);
        node.domains = row.domains || [];
        node.samples = row.samples || [];
      }

      if (index > 0) {
        const parentPath = parts.slice(0, index).join('.');
        const parent = ensureNode(parentPath);
        if (!parent.children.some((child) => child.tag === path)) {
          parent.children.push(node);
        }
      }
    }
  });

  const sortChildren = (node) => {
    node.children.sort((left, right) => left.label.localeCompare(right.label));
    node.children.forEach(sortChildren);
  };

  const roots = Array.from(nodes.values()).filter((node) => !node.tag.includes('.'));
  roots.sort((left, right) => left.label.localeCompare(right.label));
  roots.forEach(sortChildren);
  return roots;
};

const filterTree = (nodes, query) => {
  if (!query) {
    return nodes;
  }

  const lowered = query.toLowerCase();
  return nodes.reduce((acc, node) => {
    const filteredChildren = filterTree(node.children || [], query);
    const matchesSelf = (
      node.tag.toLowerCase().includes(lowered)
      || (node.domains || []).some((domain) => domain.tag.toLowerCase().includes(lowered))
      || (node.samples || []).some((sample) => (
        sample.item_id.toLowerCase().includes(lowered) || sample.name.toLowerCase().includes(lowered)
      ))
    );

    if (!matchesSelf && !filteredChildren.length) {
      return acc;
    }

    acc.push({
      ...node,
      children: filteredChildren,
    });
    return acc;
  }, []);
};

const countNodes = (nodes) => nodes.reduce(
  (total, node) => total + 1 + countNodes(node.children || []),
  0,
);

const lineageForTag = (tag) => {
  if (!tag) {
    return [];
  }
  const parts = tag.split('.');
  return parts.map((_, index) => parts.slice(0, index + 1).join('.'));
};

const getTagTone = (tag) => {
  const parts = (tag || 'Misc').split('.');
  const root = parts[0] || 'Misc';
  const depth = Math.max(0, parts.length - 1);
  const hue = CATEGORY_HUES[root] ?? CATEGORY_HUES.Misc;
  const lightness = Math.max(20, 38 - (depth * 6));

  return {
    bg: `hsla(${hue}, 74%, ${lightness}%, 0.18)`,
    bgStrong: `hsla(${hue}, 78%, ${Math.max(24, lightness + 6)}%, 0.3)`,
    border: `hsla(${hue}, 78%, ${Math.min(82, lightness + 24)}%, 0.45)`,
    text: `hsl(${hue}, 90%, ${Math.min(92, lightness + 48)}%)`,
    muted: `hsla(${hue}, 82%, ${Math.min(88, lightness + 28)}%, 0.76)`,
  };
};

const makeOverrideDraft = (row, existingOverride) => ({
  itemId: row.item_id,
  basePrice: existingOverride?.basePrice ?? '',
  stockMin: existingOverride?.stockRange?.min ?? '',
  stockMax: existingOverride?.stockRange?.max ?? '',
  tags: Array.isArray(existingOverride?.tags) ? existingOverride.tags : [],
  currentPrice: row.preview_price,
  currentStockMin: row.preview_stock_min ?? row.stock_min,
  currentStockMax: row.preview_stock_max ?? row.stock_max,
  currentTags: row.tags || [],
});

const TagPricingPage = () => {
  const [config, setConfig] = useState(null);
  const [catalog, setCatalog] = useState([]);
  const [overridesByItem, setOverridesByItem] = useState({});
  const [search, setSearch] = useState('');
  const [selectedTag, setSelectedTag] = useState('');
  const [pendingAddition, setPendingAddition] = useState(0);
  const [previewData, setPreviewData] = useState(null);
  const [status, setStatus] = useState({ type: '', message: '' });
  const [loadingCatalog, setLoadingCatalog] = useState(true);
  const [loadingPreview, setLoadingPreview] = useState(false);
  const [saving, setSaving] = useState(false);
  const [expandedTags, setExpandedTags] = useState({});
  const [blacklistingItemId, setBlacklistingItemId] = useState('');
  const [overrideDraft, setOverrideDraft] = useState(null);

  const loadPage = async (keepSelection = true) => {
    setLoadingCatalog(true);
    setStatus({ type: '', message: '' });
    try {
      const [configRes, tagRes, overridesRes] = await Promise.all([
        getPricingConfig(),
        getPricingTags(),
        getOverrides(),
      ]);
      const nextConfig = configRes.data;
      const nextCatalog = tagRes.data?.tags || [];
      const nextOverridesByItem = overridesRes.data?.by_item || {};

      setConfig(nextConfig);
      setCatalog(nextCatalog);
      setOverridesByItem(nextOverridesByItem);

      const fallbackTag = nextCatalog[0]?.tag || '';
      const nextSelectedTag = keepSelection && selectedTag && nextCatalog.some((row) => row.tag === selectedTag)
        ? selectedTag
        : fallbackTag;

      setSelectedTag(nextSelectedTag);
      if (nextSelectedTag) {
        setPendingAddition(Number(nextConfig?.tag_price_additions?.[nextSelectedTag] || 0));
      }
    } catch (err) {
      setStatus({ type: 'error', message: err?.response?.data?.detail || 'Failed to load tag pricing data.' });
    } finally {
      setLoadingCatalog(false);
    }
  };

  useEffect(() => {
    loadPage(false);
  }, []);

  useEffect(() => {
    if (!selectedTag || !config) {
      return undefined;
    }

    const saved = Number(config?.tag_price_additions?.[selectedTag] || 0);
    const nextAddition = Number.isFinite(pendingAddition) ? pendingAddition : saved;
    const timer = window.setTimeout(async () => {
      setLoadingPreview(true);
      try {
        const res = await previewPricingTag({
          tag: selectedTag,
          addition: nextAddition,
          limit: 40,
        });
        setPreviewData(res.data);
      } catch (err) {
        setPreviewData(null);
        setStatus((current) => ({
          ...current,
          type: 'error',
          message: err?.response?.data?.detail || 'Failed to preview tag pricing.',
        }));
      } finally {
        setLoadingPreview(false);
      }
    }, 250);

    return () => window.clearTimeout(timer);
  }, [selectedTag, pendingAddition, config]);

  useEffect(() => {
    if (!selectedTag || !config) {
      return;
    }
    setPendingAddition(Number(config?.tag_price_additions?.[selectedTag] || 0));
    setExpandedTags((current) => {
      const next = { ...current };
      lineageForTag(selectedTag).forEach((tag) => {
        next[tag] = true;
      });
      return next;
    });
  }, [selectedTag, config]);

  const tree = useMemo(() => buildTagTree(catalog), [catalog]);
  const filteredTree = useMemo(() => filterTree(tree, search.trim()), [tree, search]);
  const visibleNodeCount = useMemo(() => countNodes(filteredTree), [filteredTree]);
  const catalogByTag = useMemo(() => {
    const map = new Map();
    catalog.forEach((row) => {
      map.set(row.tag, row);
    });
    return map;
  }, [catalog]);
  const selectedCatalogRow = catalogByTag.get(selectedTag) || null;
  const tagOptions = useMemo(() => catalog.map((row) => row.tag), [catalog]);

  const lineage = useMemo(() => lineageForTag(selectedTag), [selectedTag]);
  const compoundRows = useMemo(() => lineage.map((tag) => {
    const savedValue = Number(config?.tag_price_additions?.[tag] || 0);
    const pendingValue = tag === selectedTag ? Number(pendingAddition || 0) : savedValue;
    return {
      tag,
      savedValue,
      pendingValue,
    };
  }), [config, lineage, pendingAddition, selectedTag]);
  const savedCompoundTotal = compoundRows.reduce((total, row) => total + row.savedValue, 0);
  const pendingCompoundTotal = compoundRows.reduce((total, row) => total + row.pendingValue, 0);
  const hasUnsavedChange = Number(pendingAddition || 0) !== Number(config?.tag_price_additions?.[selectedTag] || 0);

  const toggleExpanded = (tag) => {
    setExpandedTags((current) => ({
      ...current,
      [tag]: !current[tag],
    }));
  };

  const handleSave = async () => {
    if (!config || !selectedTag) {
      return;
    }

    setSaving(true);
    setStatus({ type: '', message: '' });
    try {
      const nextConfig = {
        ...config,
        tag_price_additions: {
          ...(config.tag_price_additions || {}),
        },
      };

      const nextValue = Number(pendingAddition || 0);
      if (Math.abs(nextValue) < 1e-9) {
        delete nextConfig.tag_price_additions[selectedTag];
      } else {
        nextConfig.tag_price_additions[selectedTag] = nextValue;
      }

      const res = await savePricingConfig(nextConfig);
      setConfig(res.data);
      setStatus({ type: 'success', message: `Saved ${selectedTag} to the backend config. Parent values still compound into child tags.` });
      await loadPage(true);
    } catch (err) {
      setStatus({ type: 'error', message: err?.response?.data?.detail || 'Failed to save tag pricing.' });
    } finally {
      setSaving(false);
    }
  };

  const handleReset = () => {
    if (!selectedTag || !config) {
      return;
    }
    setPendingAddition(Number(config?.tag_price_additions?.[selectedTag] || 0));
  };

  const handleExpandAll = () => {
    const next = {};
    catalog.forEach((row) => {
      next[row.tag] = true;
    });
    setExpandedTags(next);
  };

  const handleCollapseAll = () => {
    setExpandedTags({});
  };

  const openOverrideEditor = (row) => {
    setOverrideDraft(makeOverrideDraft(row, overridesByItem[row.item_id]));
  };

  const closeOverrideEditor = () => {
    setOverrideDraft(null);
  };

  const handleSaveItemOverride = async () => {
    if (!overrideDraft) {
      return;
    }

    const payload = {
      item_id: overrideDraft.itemId,
    };

    if (overrideDraft.basePrice !== '') {
      const value = Number(overrideDraft.basePrice);
      if (!Number.isFinite(value) || value < 0) {
        setStatus({ type: 'error', message: 'Override price must be a non-negative number.' });
        return;
      }
      payload.base_price = value;
    }

    if (overrideDraft.stockMin !== '') {
      const value = Number(overrideDraft.stockMin);
      if (!Number.isInteger(value) || value < 0) {
        setStatus({ type: 'error', message: 'Override stock min must be a non-negative whole number.' });
        return;
      }
      payload.stock_min = value;
    }

    if (overrideDraft.stockMax !== '') {
      const value = Number(overrideDraft.stockMax);
      if (!Number.isInteger(value) || value < 0) {
        setStatus({ type: 'error', message: 'Override stock max must be a non-negative whole number.' });
        return;
      }
      payload.stock_max = value;
    }

    if (
      payload.stock_min !== undefined
      && payload.stock_max !== undefined
      && payload.stock_min > payload.stock_max
    ) {
      setStatus({ type: 'error', message: 'Override stock min cannot be greater than stock max.' });
      return;
    }

    if ((overrideDraft.tags || []).length) {
      payload.tags = overrideDraft.tags;
    }

    if (
      payload.base_price === undefined
      && payload.stock_min === undefined
      && payload.stock_max === undefined
      && !payload.tags
    ) {
      setStatus({ type: 'error', message: 'Add at least one override field before saving.' });
      return;
    }

    setSaving(true);
    setStatus({ type: '', message: '' });
    try {
      const res = await saveItemOverride(payload);
      setOverridesByItem(res.data?.overrides?.reduce?.((acc, entry) => {
        if (entry?.item) {
          acc[entry.item] = entry;
        }
        return acc;
      }, {}) || overridesByItem);
      setStatus({ type: 'success', message: `Saved override for ${overrideDraft.itemId}.` });
      closeOverrideEditor();
      await loadPage(true);
    } catch (err) {
      setStatus({ type: 'error', message: err?.response?.data?.detail || 'Failed to save item override.' });
    } finally {
      setSaving(false);
    }
  };

  const handleDeleteItemOverride = async (itemId) => {
    if (!itemId) {
      return;
    }

    setSaving(true);
    setStatus({ type: '', message: '' });
    try {
      const res = await deleteItemOverride(itemId);
      setOverridesByItem(res.data?.overrides?.reduce?.((acc, entry) => {
        if (entry?.item) {
          acc[entry.item] = entry;
        }
        return acc;
      }, {}) || {});
      setStatus({ type: 'success', message: `Deleted override for ${itemId}.` });
      if (overrideDraft?.itemId === itemId) {
        closeOverrideEditor();
      }
      await loadPage(true);
    } catch (err) {
      setStatus({ type: 'error', message: err?.response?.data?.detail || 'Failed to delete item override.' });
    } finally {
      setSaving(false);
    }
  };

  const handleBlacklistItem = async (itemId) => {
    if (!itemId) {
      return;
    }

    setBlacklistingItemId(itemId);
    setStatus({ type: '', message: '' });
    try {
      await addBlacklistItem(itemId);
      setStatus({ type: 'success', message: `${itemId} was added to the blacklist.` });
      if (overrideDraft?.itemId === itemId) {
        closeOverrideEditor();
      }
      await loadPage(true);
    } catch (err) {
      setStatus({ type: 'error', message: err?.response?.data?.detail || 'Failed to add item to blacklist.' });
    } finally {
      setBlacklistingItemId('');
    }
  };

  const renderNodes = (nodes, depth = 0) => nodes.map((node) => {
    const hasChildren = (node.children || []).length > 0;
    const expanded = search.trim() ? true : Boolean(expandedTags[node.tag] ?? depth === 0);
    const tone = getTagTone(node.tag);

    return (
      <Box key={node.tag}>
        <ListItemButton
          selected={node.tag === selectedTag}
          onClick={() => setSelectedTag(node.tag)}
          sx={{
            py: 1.1,
            pl: 1.5 + (depth * 2),
            borderLeft: depth > 0 ? `1px solid ${tone.border}` : 'none',
            bgcolor: node.tag === selectedTag ? tone.bgStrong : tone.bg,
            '&:hover': {
              bgcolor: tone.bgStrong,
            },
          }}
        >
          <Stack direction="row" spacing={1.25} alignItems="flex-start" sx={{ width: '100%' }}>
            {hasChildren ? (
              <Button
                size="small"
                variant="text"
                onClick={(event) => {
                  event.stopPropagation();
                  toggleExpanded(node.tag);
                }}
                sx={{ minWidth: 28, px: 0.5, color: tone.text }}
              >
                {expanded ? '-' : '+'}
              </Button>
            ) : (
              <Box sx={{ width: 28, pt: 0.6, textAlign: 'center', color: tone.muted }}>
                .
              </Box>
            )}

            <Box sx={{ flexGrow: 1, minWidth: 0 }}>
              <Stack direction={{ xs: 'column', md: 'row' }} justifyContent="space-between" spacing={1}>
                <Box sx={{ minWidth: 0 }}>
                  <Typography variant="body1" noWrap sx={{ color: tone.text }}>
                    {node.label}
                  </Typography>
                  <Typography variant="caption" sx={{ color: tone.muted }}>
                    {node.tag}
                  </Typography>
                </Box>
                <Stack direction="row" spacing={0.75} flexWrap="wrap" useFlexGap justifyContent="flex-end">
                  <Chip
                    label={`${node.item_count || 0} items`}
                    size="small"
                    variant="outlined"
                    sx={{ bgcolor: tone.bg, borderColor: tone.border, color: tone.text }}
                  />
                  {!!node.current_addition && (
                    <Chip
                      label={`Saved ${formatPrice(node.current_addition)}`}
                      size="small"
                      sx={{ bgcolor: tone.bgStrong, borderColor: tone.border, color: tone.text }}
                    />
                  )}
                </Stack>
              </Stack>
            </Box>
          </Stack>
        </ListItemButton>

        {hasChildren ? (
          <Collapse in={expanded} timeout="auto" unmountOnExit>
            {renderNodes(node.children, depth + 1)}
          </Collapse>
        ) : null}
      </Box>
    );
  });

  const selectedTone = getTagTone(selectedTag);

  return (
    <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', lg: '0.95fr 1.25fr' }, gap: 3 }}>
      <Paper elevation={3} sx={{ p: 3, minHeight: 760, display: 'flex', flexDirection: 'column' }}>
        <Stack spacing={2}>
          <Box>
            <Typography variant="h4" gutterBottom>
              Tag Pricing
            </Typography>
            <Typography variant="body2" color="text.secondary">
              Browse dynamic pricing tags as a collapsible hierarchy. Root tags like `Food` compound into `Food.NonPerishable` and `Food.NonPerishable.Canned`.
            </Typography>
          </Box>

          {status.message ? (
            <Alert severity={status.type || 'info'}>
              {status.message}
            </Alert>
          ) : null}

          <TextField
            label="Search categories, domains, or samples"
            value={search}
            onChange={(event) => setSearch(event.target.value)}
            placeholder="Food.NonPerishable"
          />

          <Stack direction="row" justifyContent="space-between" alignItems="center">
            <Typography variant="body2" color="text.secondary">
              {loadingCatalog ? 'Loading tags...' : `${visibleNodeCount} visible nodes`}
            </Typography>
            <Stack direction="row" spacing={1}>
              <Button variant="outlined" onClick={handleExpandAll} disabled={loadingCatalog}>
                Expand All
              </Button>
              <Button variant="outlined" onClick={handleCollapseAll} disabled={loadingCatalog}>
                Collapse All
              </Button>
              <Button variant="outlined" onClick={() => loadPage(true)} disabled={loadingCatalog || saving}>
                Reload
              </Button>
            </Stack>
          </Stack>
        </Stack>

        <List dense sx={{ mt: 2, overflow: 'auto', borderRadius: 2, bgcolor: 'rgba(255,255,255,0.03)' }}>
          {renderNodes(filteredTree)}
        </List>
      </Paper>

      <Stack spacing={3}>
        <Paper elevation={3} sx={{ p: 3 }}>
          {selectedTag ? (
            <Stack spacing={2.5}>
              <Box>
                <Typography variant="overline" color="text.secondary">Selected Tag</Typography>
                <Typography variant="h4" sx={{ color: selectedTone.text }}>{selectedTag}</Typography>
                <Typography variant="body2" color="text.secondary">
                  Editing a parent category raises or lowers the whole branch. Editing the selected node adds another layer on top of its inherited chain.
                </Typography>
              </Box>

              <Stack direction={{ xs: 'column', md: 'row' }} spacing={2} alignItems={{ xs: 'stretch', md: 'center' }}>
                <Box sx={{ flexGrow: 1, px: 1 }}>
                  <Typography variant="body2" color="text.secondary" sx={{ mb: 1 }}>
                    Flat price addition
                  </Typography>
                  <Slider
                    value={Number(pendingAddition || 0)}
                    min={SLIDER_MIN}
                    max={SLIDER_MAX}
                    step={1}
                    valueLabelDisplay="auto"
                    onChange={(_, value) => setPendingAddition(Array.isArray(value) ? value[0] : value)}
                    sx={{ color: selectedTone.text }}
                  />
                </Box>
                <TextField
                  label="Exact amount"
                  type="number"
                  value={Number(pendingAddition || 0)}
                  onChange={(event) => setPendingAddition(Number(event.target.value || 0))}
                  sx={{ width: { xs: '100%', md: 160 } }}
                />
                <Stack direction="row" spacing={1}>
                  <Button variant="outlined" onClick={handleReset} disabled={!hasUnsavedChange || saving}>
                    Reset
                  </Button>
                  <Button variant="contained" onClick={handleSave} disabled={saving || !selectedTag || !config || !hasUnsavedChange}>
                    {saving ? 'Saving...' : 'Save'}
                  </Button>
                </Stack>
              </Stack>

              <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
                <Chip label={`Pending ${formatPrice(pendingAddition)}`} color={hasUnsavedChange ? 'warning' : 'default'} />
                <Chip label={`Saved ${formatPrice(config?.tag_price_additions?.[selectedTag] || 0)}`} variant="outlined" />
                <Chip label={`${selectedCatalogRow?.item_count || 0} matching items`} variant="outlined" />
              </Stack>

              <Divider />

              <Box>
                <Typography variant="subtitle1" gutterBottom>Compound Chain</Typography>
                <Typography variant="body2" color="text.secondary" sx={{ mb: 1.5 }}>
                  Every saved value in this path stacks into the selected branch and all of its children.
                </Typography>
                <Stack spacing={1}>
                  {compoundRows.map((row) => {
                    const tone = getTagTone(row.tag);
                    return (
                      <Box
                        key={row.tag}
                        sx={{
                          display: 'flex',
                          justifyContent: 'space-between',
                          gap: 2,
                          p: 1.2,
                          borderRadius: 2,
                          bgcolor: tone.bg,
                          border: `1px solid ${tone.border}`,
                        }}
                      >
                        <Typography variant="body2" sx={{ color: tone.text }}>
                          {row.tag}
                        </Typography>
                        <Typography variant="body2" sx={{ color: tone.muted }}>
                          {formatPrice(row.pendingValue)}
                          {row.pendingValue !== row.savedValue ? ` (${formatPrice(row.savedValue)} saved)` : ''}
                        </Typography>
                      </Box>
                    );
                  })}
                </Stack>
                <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap sx={{ mt: 1.5 }}>
                  <Chip label={`Saved chain ${formatPrice(savedCompoundTotal)}`} variant="outlined" />
                  <Chip label={`Preview chain ${formatPrice(pendingCompoundTotal)}`} color={hasUnsavedChange ? 'warning' : 'default'} />
                </Stack>
              </Box>

              <Divider />

              <Box>
                <Typography variant="subtitle1" gutterBottom>Affected Domains</Typography>
                <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
                  {(previewData?.domains || selectedCatalogRow?.domains || []).map((domain) => {
                    const tone = getTagTone(domain.tag);
                    return (
                      <Chip
                        key={`${selectedTag}-${domain.tag}`}
                        label={`${domain.tag} (${domain.count})`}
                        variant="outlined"
                        sx={{ bgcolor: tone.bg, borderColor: tone.border, color: tone.text }}
                      />
                    );
                  })}
                </Stack>
              </Box>

              <Box>
                <Typography variant="subtitle1" gutterBottom>Sample Items</Typography>
                <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
                  {(selectedCatalogRow?.samples || []).map((sample) => (
                    <Chip key={`${selectedTag}-${sample.item_id}`} label={`${sample.name} (${sample.item_id})`} variant="outlined" />
                  ))}
                </Stack>
              </Box>
            </Stack>
          ) : (
            <Typography color="text.secondary">
              Select a category tag to start tuning additive pricing.
            </Typography>
          )}
        </Paper>

        <Paper elevation={3} sx={{ p: 3, minHeight: 420 }}>
          <Stack direction="row" justifyContent="space-between" alignItems="center" sx={{ mb: 2 }}>
            <Box>
              <Typography variant="h5">Preview</Typography>
              <Typography variant="body2" color="text.secondary">
                Live comparison for the selected category branch and the current slider value.
              </Typography>
            </Box>
            <Chip
              label={loadingPreview ? 'Refreshing preview...' : `Avg ${previewData?.stats?.avg_current_price || 0} -> ${previewData?.stats?.avg_preview_price || 0}`}
              color={loadingPreview ? 'warning' : 'default'}
              variant="outlined"
            />
          </Stack>

          {previewData ? (
            <Stack spacing={1.25}>
              {(previewData.items || []).map((row) => {
                const tone = getTagTone(row.primary_tag);
                const existingOverride = overridesByItem[row.item_id];
                const isEditingOverride = overrideDraft?.itemId === row.item_id;

                return (
                  <Box
                    key={`${row.item_id}-${selectedTag}`}
                    sx={{
                      display: 'grid',
                      gap: 1.5,
                      p: 1.25,
                      borderRadius: 2,
                      bgcolor: tone.bg,
                      border: `1px solid ${tone.border}`,
                    }}
                  >
                    <Stack
                      direction={{ xs: 'column', md: 'row' }}
                      justifyContent="space-between"
                      spacing={1.5}
                      alignItems={{ xs: 'flex-start', md: 'center' }}
                    >
                      <Box>
                        <Typography variant="body1" sx={{ color: tone.text }}>{row.name}</Typography>
                        <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap sx={{ mt: 0.5 }}>
                          <Chip
                            label={row.primary_tag}
                            size="small"
                            variant="outlined"
                            sx={{ bgcolor: tone.bgStrong, borderColor: tone.border, color: tone.text }}
                          />
                          {existingOverride?.basePrice !== undefined ? (
                            <Chip label={`Price ${existingOverride.basePrice}`} size="small" color="warning" />
                          ) : null}
                          {existingOverride?.stockRange ? (
                            <Chip
                              label={`Stock ${existingOverride.stockRange.min ?? row.stock_min}-${existingOverride.stockRange.max ?? row.stock_max}`}
                              size="small"
                              color="warning"
                            />
                          ) : null}
                          {Array.isArray(existingOverride?.tags) ? (
                            <Chip label={`Tags ${existingOverride.tags.length}`} size="small" color="warning" />
                          ) : null}
                        </Stack>
                        <Typography variant="caption" sx={{ color: tone.muted, display: 'block', mt: 0.75 }}>
                          {row.item_id}
                        </Typography>
                      </Box>

                      <Stack direction={{ xs: 'column', sm: 'row' }} spacing={1.5} alignItems={{ xs: 'flex-start', sm: 'center' }}>
                        <Box>
                          <Typography variant="body2" sx={{ color: tone.muted }}>
                            Price {row.current_price} {'->'} {row.preview_price}
                          </Typography>
                          <Typography variant="caption" sx={{ color: tone.muted }}>
                            Stock {row.stock_min}-{row.stock_max}
                          </Typography>
                        </Box>
                        <Typography
                          variant="body2"
                          sx={{ color: row.delta > 0 ? 'warning.light' : row.delta < 0 ? 'success.light' : tone.muted }}
                        >
                          {formatPrice(row.delta)}
                        </Typography>
                        <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
                          <Button
                            variant="outlined"
                            size="small"
                            color="error"
                            onClick={() => handleBlacklistItem(row.item_id)}
                            disabled={blacklistingItemId === row.item_id}
                          >
                            {blacklistingItemId === row.item_id ? 'Blacklisting...' : 'Blacklist'}
                          </Button>
                          <Button
                            variant="outlined"
                            size="small"
                            onClick={() => openOverrideEditor(row)}
                          >
                            {isEditingOverride ? 'Editing Override' : 'Edit Override'}
                          </Button>
                          {existingOverride ? (
                            <Button
                              variant="outlined"
                              size="small"
                              onClick={() => handleDeleteItemOverride(row.item_id)}
                              disabled={saving}
                            >
                              Delete Override
                            </Button>
                          ) : null}
                        </Stack>
                      </Stack>
                    </Stack>

                    {isEditingOverride ? (
                      <Stack spacing={1.25} sx={{ pt: 0.5 }}>
                        <Stack direction={{ xs: 'column', md: 'row' }} spacing={1}>
                          <TextField
                            label={`Forced price (current ${overrideDraft.currentPrice})`}
                            type="number"
                            value={overrideDraft.basePrice}
                            onChange={(event) => setOverrideDraft((current) => ({ ...current, basePrice: event.target.value }))}
                            sx={{ width: { xs: '100%', md: 220 } }}
                          />
                          <TextField
                            label={`Stock min (current ${overrideDraft.currentStockMin})`}
                            type="number"
                            value={overrideDraft.stockMin}
                            onChange={(event) => setOverrideDraft((current) => ({ ...current, stockMin: event.target.value }))}
                            sx={{ width: { xs: '100%', md: 180 } }}
                          />
                          <TextField
                            label={`Stock max (current ${overrideDraft.currentStockMax})`}
                            type="number"
                            value={overrideDraft.stockMax}
                            onChange={(event) => setOverrideDraft((current) => ({ ...current, stockMax: event.target.value }))}
                            sx={{ width: { xs: '100%', md: 180 } }}
                          />
                        </Stack>

                        <Autocomplete
                          multiple
                          options={tagOptions}
                          value={overrideDraft.tags}
                          onChange={(_, value) => setOverrideDraft((current) => ({ ...current, tags: value }))}
                          renderTags={(value, getTagProps) => value.map((option, index) => (
                            <Chip
                              {...getTagProps({ index })}
                              key={`${overrideDraft.itemId}-${option}`}
                              label={option}
                              size="small"
                              sx={{
                                bgcolor: getTagTone(option).bg,
                                borderColor: getTagTone(option).border,
                                color: getTagTone(option).text,
                              }}
                              variant="outlined"
                            />
                          ))}
                          renderInput={(params) => (
                            <TextField
                              {...params}
                              label="Override tags"
                              placeholder="Choose discovered tags"
                              helperText={`Current tags: ${(overrideDraft.currentTags || []).join(', ') || 'None'}`}
                            />
                          )}
                        />

                        <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
                          <Button
                            variant="outlined"
                            size="small"
                            onClick={() => setOverrideDraft((current) => ({ ...current, tags: [...current.currentTags] }))}
                          >
                            Load Current Tags
                          </Button>
                          <Button
                            variant="outlined"
                            size="small"
                            onClick={() => setOverrideDraft((current) => ({ ...current, tags: [] }))}
                          >
                            Clear Tag Override
                          </Button>
                          <Button
                            variant="contained"
                            size="small"
                            onClick={handleSaveItemOverride}
                            disabled={saving}
                          >
                            {saving ? 'Saving...' : 'Save Override'}
                          </Button>
                          <Button
                            variant="outlined"
                            size="small"
                            onClick={closeOverrideEditor}
                            disabled={saving}
                          >
                            Cancel
                          </Button>
                        </Stack>
                      </Stack>
                    ) : null}
                  </Box>
                );
              })}
            </Stack>
          ) : (
            <Typography color="text.secondary">
              Preview data will appear here once a tag is selected.
            </Typography>
          )}
        </Paper>
      </Stack>
    </Box>
  );
};

export default TagPricingPage;
