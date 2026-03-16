import React, { useCallback, useDeferredValue, useEffect, useMemo, useState } from 'react';
import {
  Alert,
  Autocomplete,
  Box,
  Button,
  Chip,
  Divider,
  Paper,
  Stack,
  TextField,
  Typography,
} from '@mui/material';
import AddCircleOutlineIcon from '@mui/icons-material/AddCircleOutline';
import DeleteOutlineIcon from '@mui/icons-material/DeleteOutline';
import KeyboardArrowDownIcon from '@mui/icons-material/KeyboardArrowDown';
import KeyboardArrowRightIcon from '@mui/icons-material/KeyboardArrowRight';
import { getArchetypeEditorData, saveArchetypeAllocations } from '../services/api';

const DRAG_MIME = 'application/x-dt-archetype-entry';

const allocationKey = (entry) => {
  if (entry.kind === 'item') {
    return `item:${entry.item_id}`;
  }
  return `tag:${(entry.tags || []).join('|')}`;
};

const cloneAllocations = (allocations = []) => allocations.map((entry) => ({
  kind: entry.kind,
  count: Number(entry.count || 1),
  tags: Array.isArray(entry.tags) ? [...entry.tags] : undefined,
  item_id: entry.item_id,
  item_name: entry.item_name,
  label: entry.label,
  matched_item_count: Number(entry.matched_item_count || 0),
  sample_items: Array.isArray(entry.sample_items) ? [...entry.sample_items] : [],
}));

const normalizeAllocationsForSave = (allocations = []) => allocations.map((entry) => {
  if (entry.kind === 'item') {
    return {
      kind: 'item',
      item_id: entry.item_id,
      count: Math.max(1, Number(entry.count || 1)),
    };
  }

  return {
    kind: 'tag',
    tags: Array.isArray(entry.tags) ? entry.tags.filter(Boolean) : [],
    count: Math.max(1, Number(entry.count || 1)),
  };
});

const buildTagTree = (rows) => {
  const nodeMap = new Map();

  const ensureNode = (tag) => {
    if (!nodeMap.has(tag)) {
      const parts = tag.split('.');
      nodeMap.set(tag, {
        tag,
        label: parts[parts.length - 1],
        children: [],
        meta: null,
      });
    }
    return nodeMap.get(tag);
  };

  rows.forEach((row) => {
    const parts = row.tag.split('.');
    const node = ensureNode(row.tag);
    node.meta = row;

    for (let index = 1; index < parts.length; index += 1) {
      const parentTag = parts.slice(0, index).join('.');
      const childTag = parts.slice(0, index + 1).join('.');
      const parent = ensureNode(parentTag);
      const child = ensureNode(childTag);
      if (!parent.children.some((candidate) => candidate.tag === child.tag)) {
        parent.children.push(child);
      }
    }
  });

  const sortNode = (node) => {
    node.children.sort((left, right) => left.label.localeCompare(right.label));
    node.children.forEach(sortNode);
  };

  const roots = Array.from(nodeMap.values()).filter((node) => !node.tag.includes('.'));
  roots.sort((left, right) => left.label.localeCompare(right.label));
  roots.forEach(sortNode);
  return roots;
};

const filterTree = (nodes, query) => {
  if (!query) {
    return nodes;
  }

  const lowered = query.toLowerCase();

  return nodes.reduce((acc, node) => {
    const filteredChildren = filterTree(node.children || [], query);
    const sampleHit = (node.meta?.sample_items || []).some((sample) => (
      sample.item_id.toLowerCase().includes(lowered)
      || sample.name.toLowerCase().includes(lowered)
    ));
    const matchesSelf = node.tag.toLowerCase().includes(lowered) || sampleHit;

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

function TagBranch({
  node,
  depth,
  expandedTags,
  onToggle,
  onAddTag,
  onDragStart,
  forceExpand = false,
}) {
  const hasChildren = Boolean(node.children?.length);
  const isExpanded = forceExpand || Boolean(expandedTags[node.tag] ?? depth === 0);
  const itemCount = node.meta?.item_count || 0;
  const coveredCount = node.meta?.covered_item_count || 0;

  const handleAdd = () => {
    if (!node.meta) {
      return;
    }
    onAddTag(node.meta);
  };

  return (
    <Box sx={{ pl: depth ? 2 : 0, borderLeft: depth ? '1px solid rgba(255,255,255,0.08)' : 'none', ml: depth ? 0.75 : 0 }}>
      <Stack
        direction="row"
        spacing={1}
        alignItems="center"
        sx={{
          py: 0.75,
          px: 1,
          borderRadius: 2,
          bgcolor: 'rgba(255,255,255,0.03)',
          border: '1px solid rgba(255,255,255,0.06)',
          mb: 0.75,
        }}
      >
        <Box sx={{ width: 28, display: 'grid', placeItems: 'center' }}>
          {hasChildren ? (
            <Button size="small" onClick={() => onToggle(node.tag)} sx={{ minWidth: 28, p: 0.25 }}>
              {isExpanded ? <KeyboardArrowDownIcon fontSize="small" /> : <KeyboardArrowRightIcon fontSize="small" />}
            </Button>
          ) : null}
        </Box>

        <Box
          draggable={Boolean(node.meta)}
          onDragStart={(event) => {
            if (!node.meta) {
              return;
            }
            onDragStart(event, node.meta);
          }}
          sx={{
            flexGrow: 1,
            minWidth: 0,
            cursor: node.meta ? 'grab' : 'default',
          }}
        >
          <Typography variant="body2" sx={{ fontWeight: 700 }}>
            {node.tag}
          </Typography>
          {node.meta ? (
            <Typography variant="caption" color="text.secondary">
              {itemCount} matching items, {coveredCount} already covered
            </Typography>
          ) : null}
        </Box>

        {node.meta ? (
          <Button size="small" variant="outlined" startIcon={<AddCircleOutlineIcon />} onClick={handleAdd}>
            Add
          </Button>
        ) : null}
      </Stack>

      {hasChildren && isExpanded ? (
        <Box>
          {node.children.map((child) => (
            <TagBranch
              key={child.tag}
              node={child}
              depth={depth + 1}
              expandedTags={expandedTags}
              onToggle={onToggle}
              onAddTag={onAddTag}
              onDragStart={onDragStart}
              forceExpand={forceExpand}
            />
          ))}
        </Box>
      ) : null}
    </Box>
  );
}

const ArchetypeEditorPage = () => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [status, setStatus] = useState({ type: '', message: '' });
  const [selectedArchetypeId, setSelectedArchetypeId] = useState('');
  const [draftAllocations, setDraftAllocations] = useState([]);
  const [expandedTags, setExpandedTags] = useState({});
  const [tagSearch, setTagSearch] = useState('');
  const [selectedItem, setSelectedItem] = useState(null);

  const deferredTagSearch = useDeferredValue(tagSearch);

  const applyPayload = useCallback((payload, preferredArchetypeId = '') => {
    setData(payload);
    const archetypes = payload?.archetypes || [];
    const selected = archetypes.find((row) => row.archetype_id === preferredArchetypeId) || archetypes[0] || null;
    setSelectedArchetypeId(selected?.archetype_id || '');
    setDraftAllocations(cloneAllocations(selected?.allocations || []));
  }, []);

  const loadData = useCallback(async (preferredArchetypeId = '') => {
    setLoading(true);
    setStatus({ type: '', message: '' });
    try {
      const response = await getArchetypeEditorData();
      applyPayload(response.data, preferredArchetypeId);
    } catch (error) {
      setStatus({
        type: 'error',
        message: error?.response?.data?.detail || 'Failed to load archetype editor data.',
      });
    } finally {
      setLoading(false);
    }
  }, [applyPayload]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  const selectedArchetype = useMemo(
    () => data?.archetypes?.find((row) => row.archetype_id === selectedArchetypeId) || null,
    [data, selectedArchetypeId],
  );

  const savedSnapshot = useMemo(
    () => JSON.stringify(normalizeAllocationsForSave(selectedArchetype?.allocations || [])),
    [selectedArchetype],
  );
  const draftSnapshot = useMemo(
    () => JSON.stringify(normalizeAllocationsForSave(draftAllocations)),
    [draftAllocations],
  );
  const isDirty = savedSnapshot !== draftSnapshot;

  const availableTagMap = useMemo(() => {
    const map = new Map();
    (data?.available_tags || []).forEach((row) => {
      map.set(row.tag, row);
    });
    return map;
  }, [data]);

  const tagTree = useMemo(
    () => buildTagTree(data?.available_tags || []),
    [data],
  );
  const filteredTagTree = useMemo(
    () => filterTree(tagTree, deferredTagSearch.trim()),
    [tagTree, deferredTagSearch],
  );

  const addOrIncrementAllocation = useCallback((entry) => {
    setDraftAllocations((current) => {
      const key = allocationKey(entry);
      const existingIndex = current.findIndex((row) => allocationKey(row) === key);
      if (existingIndex >= 0) {
        return current.map((row, index) => (
          index === existingIndex
            ? { ...row, count: Math.max(1, Number(row.count || 1) + Number(entry.count || 1)) }
            : row
        ));
      }
      return [...current, { ...entry, count: Math.max(1, Number(entry.count || 1)) }];
    });
  }, []);

  const addTagAllocation = useCallback((tagRow) => {
    addOrIncrementAllocation({
      kind: 'tag',
      tags: [tagRow.tag],
      label: tagRow.tag,
      count: 1,
      matched_item_count: Number(tagRow.item_count || 0),
      sample_items: tagRow.sample_items || [],
    });
  }, [addOrIncrementAllocation]);

  const addItemAllocation = useCallback((item) => {
    if (!item) {
      return;
    }

    addOrIncrementAllocation({
      kind: 'item',
      item_id: item.item_id,
      item_name: item.name,
      label: item.item_id,
      count: 1,
      matched_item_count: 1,
      sample_items: [{ item_id: item.item_id, name: item.name }],
    });
  }, [addOrIncrementAllocation]);

  const handleDragStart = useCallback((event, payload) => {
    event.dataTransfer.effectAllowed = 'copy';
    event.dataTransfer.setData(DRAG_MIME, JSON.stringify({
      kind: 'tag',
      tag: payload.tag,
    }));
  }, []);

  const handleDrop = useCallback((event) => {
    event.preventDefault();
    const raw = event.dataTransfer.getData(DRAG_MIME);
    if (!raw) {
      return;
    }

    try {
      const payload = JSON.parse(raw);
      if (payload.kind === 'tag' && payload.tag && availableTagMap.has(payload.tag)) {
        addTagAllocation(availableTagMap.get(payload.tag));
      }
    } catch (error) {
      setStatus({ type: 'error', message: 'Unable to read dragged tag payload.' });
    }
  }, [addTagAllocation, availableTagMap]);

  const handleSelectArchetype = (nextId) => {
    if (nextId === selectedArchetypeId) {
      return;
    }
    if (isDirty && !window.confirm('Switch archetypes and discard unsaved allocation changes?')) {
      return;
    }

    const nextArchetype = data?.archetypes?.find((row) => row.archetype_id === nextId);
    setSelectedArchetypeId(nextId);
    setDraftAllocations(cloneAllocations(nextArchetype?.allocations || []));
    setStatus({ type: '', message: '' });
  };

  const handleSave = async () => {
    if (!selectedArchetypeId) {
      return;
    }

    setSaving(true);
    setStatus({ type: '', message: '' });
    try {
      const response = await saveArchetypeAllocations(
        selectedArchetypeId,
        normalizeAllocationsForSave(draftAllocations),
      );
      applyPayload(response.data.data, selectedArchetypeId);
      setStatus({ type: 'success', message: `Saved allocations for ${selectedArchetype?.name || selectedArchetypeId}.` });
    } catch (error) {
      setStatus({
        type: 'error',
        message: error?.response?.data?.detail || 'Failed to save archetype allocations.',
      });
    } finally {
      setSaving(false);
    }
  };

  const updateAllocationCount = (index, value) => {
    setDraftAllocations((current) => current.map((entry, entryIndex) => (
      entryIndex === index
        ? { ...entry, count: value === '' ? '' : Math.max(1, Number(value)) }
        : entry
    )));
  };

  const removeAllocation = (index) => {
    setDraftAllocations((current) => current.filter((_, entryIndex) => entryIndex !== index));
  };

  return (
    <Box sx={{ display: 'grid', gridTemplateColumns: { xs: '1fr', lg: '320px 1fr' }, gap: 3 }}>
      <Paper elevation={3} sx={{ p: 2.5, minHeight: 720 }}>
        <Typography variant="h5" gutterBottom>
          Archetypes
        </Typography>
        <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
          Pick a trader archetype, then drag tags into its allocation list or add item IDs directly.
        </Typography>

        {data?.meta ? (
          <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap sx={{ mb: 2 }}>
            <Chip size="small" label={`${data.meta.archetype_count} archetypes`} />
            <Chip size="small" label={`${data.meta.tag_count} tags`} />
            <Chip size="small" label={`${data.meta.uncovered_tag_count} uncovered`} color="warning" variant="outlined" />
          </Stack>
        ) : null}

        <Stack spacing={1}>
          {(data?.archetypes || []).map((archetype) => (
            <Button
              key={archetype.archetype_id}
              variant={archetype.archetype_id === selectedArchetypeId ? 'contained' : 'outlined'}
              color={archetype.archetype_id === selectedArchetypeId ? 'primary' : 'inherit'}
              onClick={() => handleSelectArchetype(archetype.archetype_id)}
              sx={{ justifyContent: 'space-between', px: 1.5, py: 1.2 }}
            >
              <Box sx={{ textAlign: 'left' }}>
                <Typography variant="body2" sx={{ fontWeight: 700 }}>
                  {archetype.name}
                </Typography>
                <Typography variant="caption" sx={{ opacity: 0.8 }}>
                  {archetype.archetype_id}
                </Typography>
              </Box>
              <Chip
                size="small"
                label={`${archetype.allocation_count} rows`}
                color={archetype.archetype_id === selectedArchetypeId ? 'secondary' : 'default'}
              />
            </Button>
          ))}
        </Stack>
      </Paper>

      <Stack spacing={3}>
        <Paper elevation={3} sx={{ p: 3 }}>
          <Stack direction={{ xs: 'column', lg: 'row' }} spacing={3} alignItems={{ xs: 'stretch', lg: 'flex-start' }}>
            <Box sx={{ flex: 1.05, minWidth: 0 }}>
              <Stack direction="row" justifyContent="space-between" alignItems="center" sx={{ mb: 2 }}>
                <Box>
                  <Typography variant="h4">
                    Archetype Allocation Editor
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    Tree view of all available tags from the item registry. Drag from here into the selected archetype.
                  </Typography>
                </Box>
                <Button variant="outlined" onClick={() => loadData(selectedArchetypeId)} disabled={loading || saving}>
                  Reload
                </Button>
              </Stack>

              {status.message ? (
                <Alert severity={status.type || 'info'} sx={{ mb: 2 }}>
                  {status.message}
                </Alert>
              ) : null}

              <TextField
                fullWidth
                label="Search tags or sample items"
                value={tagSearch}
                onChange={(event) => setTagSearch(event.target.value)}
                sx={{ mb: 2 }}
              />

              <Paper
                variant="outlined"
                sx={{
                  p: 1.25,
                  height: 560,
                  overflow: 'auto',
                  bgcolor: 'rgba(255,255,255,0.02)',
                }}
              >
                {loading ? (
                  <Typography color="text.secondary">Loading available tags...</Typography>
                ) : filteredTagTree.length ? (
                  filteredTagTree.map((node) => (
                    <TagBranch
                      key={node.tag}
                      node={node}
                      depth={0}
                      expandedTags={expandedTags}
                      onToggle={(tag) => setExpandedTags((current) => ({ ...current, [tag]: !current[tag] }))}
                      onAddTag={addTagAllocation}
                      onDragStart={handleDragStart}
                      forceExpand={Boolean(deferredTagSearch.trim())}
                    />
                  ))
                ) : (
                  <Typography color="text.secondary">No tags matched this search.</Typography>
                )}
              </Paper>
            </Box>

            <Box sx={{ flex: 1, minWidth: 0 }}>
              <Stack direction="row" justifyContent="space-between" alignItems="flex-start" sx={{ mb: 2 }}>
                <Box>
                  <Typography variant="h5">
                    {selectedArchetype?.name || 'Select an archetype'}
                  </Typography>
                  <Typography variant="body2" color="text.secondary">
                    {selectedArchetype?.archetype_id || 'No archetype selected'}
                  </Typography>
                  {selectedArchetype?.source_file ? (
                    <Typography variant="caption" color="text.secondary">
                      {selectedArchetype.source_file}
                    </Typography>
                  ) : null}
                </Box>

                <Button
                  variant="contained"
                  onClick={handleSave}
                  disabled={!selectedArchetypeId || saving || loading}
                >
                  {saving ? 'Saving...' : 'Save Allocations'}
                </Button>
              </Stack>

              <Paper
                variant="outlined"
                onDragOver={(event) => event.preventDefault()}
                onDrop={handleDrop}
                sx={{
                  p: 2,
                  mb: 2,
                  borderStyle: 'dashed',
                  bgcolor: 'rgba(144,202,249,0.08)',
                }}
              >
                <Typography variant="subtitle1" sx={{ fontWeight: 700 }}>
                  Drop Tags Here
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Drag from the tag tree, or use the Add buttons, and new rows will be appended here.
                </Typography>
              </Paper>

              <Stack spacing={1.25} sx={{ maxHeight: 470, overflow: 'auto', pr: 0.5 }}>
                {draftAllocations.length ? (
                  draftAllocations.map((entry, index) => (
                    <Paper key={`${allocationKey(entry)}-${index}`} variant="outlined" sx={{ p: 1.5 }}>
                      <Stack direction={{ xs: 'column', md: 'row' }} spacing={1.5} justifyContent="space-between">
                        <Box sx={{ minWidth: 0, flexGrow: 1 }}>
                          <Stack direction="row" spacing={1} alignItems="center" flexWrap="wrap" useFlexGap sx={{ mb: 0.75 }}>
                            <Chip
                              size="small"
                              label={entry.kind === 'item' ? 'Item ID' : 'Tag'}
                              color={entry.kind === 'item' ? 'secondary' : 'primary'}
                              variant="outlined"
                            />
                            <Typography variant="body1" sx={{ fontWeight: 700, wordBreak: 'break-word' }}>
                              {entry.kind === 'item' ? entry.item_id : (entry.tags || []).join(' + ')}
                            </Typography>
                          </Stack>

                          {entry.kind === 'item' && entry.item_name ? (
                            <Typography variant="body2" color="text.secondary" sx={{ mb: 0.75 }}>
                              {entry.item_name}
                            </Typography>
                          ) : null}

                          <Typography variant="caption" color="text.secondary">
                            Matches {entry.matched_item_count || 0} item{Number(entry.matched_item_count || 0) === 1 ? '' : 's'}
                          </Typography>

                          {entry.sample_items?.length ? (
                            <Stack direction="row" spacing={0.75} flexWrap="wrap" useFlexGap sx={{ mt: 1 }}>
                              {entry.sample_items.map((sample) => (
                                <Chip
                                  key={`${entry.kind}-${sample.item_id}`}
                                  size="small"
                                  variant="outlined"
                                  label={`${sample.name} (${sample.item_id})`}
                                />
                              ))}
                            </Stack>
                          ) : null}
                        </Box>

                        <Stack direction="row" spacing={1} alignItems="center">
                          <TextField
                            label="Count"
                            size="small"
                            type="number"
                            value={entry.count}
                            onChange={(event) => updateAllocationCount(index, event.target.value)}
                            onBlur={() => updateAllocationCount(index, Math.max(1, Number(entry.count || 1)))}
                            sx={{ width: 110 }}
                            inputProps={{ min: 1 }}
                          />
                          <Button
                            color="error"
                            variant="outlined"
                            startIcon={<DeleteOutlineIcon />}
                            onClick={() => removeAllocation(index)}
                          >
                            Remove
                          </Button>
                        </Stack>
                      </Stack>
                    </Paper>
                  ))
                ) : (
                  <Typography color="text.secondary">
                    No allocation rows yet. Drop tags here or add item IDs below.
                  </Typography>
                )}
              </Stack>

              <Divider sx={{ my: 2.5 }} />

              <Typography variant="h6" gutterBottom>
                Add Item ID
              </Typography>
              <Typography variant="body2" color="text.secondary" sx={{ mb: 1.5 }}>
                Explicit item rows are useful for one-off stock picks that should always be reachable.
              </Typography>

              <Stack direction={{ xs: 'column', md: 'row' }} spacing={1.5}>
                <Autocomplete
                  fullWidth
                  options={data?.item_catalog || []}
                  value={selectedItem}
                  onChange={(_, value) => setSelectedItem(value)}
                  getOptionLabel={(option) => `${option.item_id} - ${option.name}`}
                  renderInput={(params) => <TextField {...params} label="Item ID" placeholder="Base.Axe" />}
                  isOptionEqualToValue={(option, value) => option.item_id === value.item_id}
                />
                <Button
                  variant="outlined"
                  startIcon={<AddCircleOutlineIcon />}
                  onClick={() => {
                    addItemAllocation(selectedItem);
                    setSelectedItem(null);
                  }}
                >
                  Add Item
                </Button>
              </Stack>
            </Box>
          </Stack>
        </Paper>

        <Paper elevation={3} sx={{ p: 3 }}>
          <Typography variant="h5" gutterBottom>
            Tags Not Currently Accessible
          </Typography>
          <Typography variant="body2" color="text.secondary" sx={{ mb: 2 }}>
            These tags exist on real items, but no current archetype allocation reaches them yet. Click or drag them into the selected archetype to cover those gaps.
          </Typography>

          <Stack direction="row" spacing={1} flexWrap="wrap" useFlexGap>
            {(data?.uncovered_tags || []).map((tagRow) => (
              <Chip
                key={tagRow.tag}
                label={`${tagRow.tag} (${tagRow.item_count})`}
                color="warning"
                variant="outlined"
                onClick={() => addTagAllocation(tagRow)}
                draggable
                onDragStart={(event) => handleDragStart(event, tagRow)}
                sx={{ cursor: 'grab' }}
              />
            ))}
          </Stack>

          {!data?.uncovered_tags?.length ? (
            <Typography color="text.secondary">Every available tag is currently reachable by at least one archetype allocation.</Typography>
          ) : null}
        </Paper>
      </Stack>
    </Box>
  );
};

export default ArchetypeEditorPage;
