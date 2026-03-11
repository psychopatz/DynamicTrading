import React, { useState, useEffect, useRef, useMemo } from 'react';
import { 
  Paper, 
  Typography, 
  Box, 
  Checkbox, 
  FormControlLabel, 
  IconButton, 
  CircularProgress,
  useTheme
} from '@mui/material';
import ContentCopyIcon from '@mui/icons-material/ContentCopy';
import ClearIcon from '@mui/icons-material/Clear';
import DeleteIcon from '@mui/icons-material/Delete';
import RefreshIcon from '@mui/icons-material/Refresh';
import PauseIcon from '@mui/icons-material/Pause';
import PlayArrowIcon from '@mui/icons-material/PlayArrow';
import { List } from 'react-window';
import { getDebugLogs } from '../services/api';

const ConsolePage = () => {
  const [logs, setLogs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [onlyDT, setOnlyDT] = useState(false);
  const [autoScroll, setAutoScroll] = useState(true);
  const [isPaused, setIsPaused] = useState(false);
  const [selectedIndices, setSelectedIndices] = useState(new Set());
  const [isDragging, setIsDragging] = useState(false);
  const [dragAction, setDragAction] = useState(null); // 'select' or 'deselect'
  
  const listRef = useRef(null);
  const nextOffsetRef = useRef(null);
  const containerRef = useRef(null);

  const fetchLogs = async (isInitial = false) => {
    try {
      const params = {
        limit: isInitial ? 1000 : 500,
        only_dt: onlyDT,
        offset: isInitial ? null : nextOffsetRef.current
      };

      const response = await getDebugLogs(params);
      const { logs: newLogs, next_offset } = response.data;

      if (next_offset !== undefined) {
        nextOffsetRef.current = next_offset;
      }
      
      if (newLogs && newLogs.length > 0) {
        if (isInitial) {
          setLogs(newLogs);
        } else if (!isPaused) {
          setLogs(prev => [...prev, ...newLogs]);
        }
      }
    } catch (error) {
      console.error("Error fetching logs:", error);
    } finally {
      if (isInitial) setLoading(false);
    }
  };

  useEffect(() => {
    fetchLogs(true);
    const interval = setInterval(() => {
      if (!isPaused) fetchLogs();
    }, 2000);

    return () => clearInterval(interval);
  }, [onlyDT, isPaused]);

  // Handle auto-scroll
  useEffect(() => {
    if (listRef.current && autoScroll && !isPaused && logs.length > 0) {
      if (typeof listRef.current.scrollToRow === 'function') {
        listRef.current.scrollToRow({ index: logs.length - 1, align: 'end' });
      }
    }
  }, [logs.length, autoScroll, isPaused]);

  const clearLogs = () => {
    setLogs([]);
    setSelectedIndices(new Set());
  };

  const clearSelection = () => {
    setSelectedIndices(new Set());
  };

  useEffect(() => {
    const handleMouseUp = () => {
      setIsDragging(false);
      setDragAction(null);
    };
    window.addEventListener('mouseup', handleMouseUp);
    return () => window.removeEventListener('mouseup', handleMouseUp);
  }, []);

  const handleSelectionStart = (index, currentSelected) => {
    setIsDragging(true);
    const newAction = currentSelected ? 'deselect' : 'select';
    setDragAction(newAction);
    
    setSelectedIndices(prev => {
      const next = new Set(prev);
      if (newAction === 'select') next.add(index);
      else next.delete(index);
      return next;
    });
  };

  const handleSelectionEnter = (index) => {
    if (!isDragging || !dragAction) return;

    setSelectedIndices(prev => {
      if (dragAction === 'select' && prev.has(index)) return prev;
      if (dragAction === 'deselect' && !prev.has(index)) return prev;

      const next = new Set(prev);
      if (dragAction === 'select') next.add(index);
      else next.delete(index);
      return next;
    });
  };


  const copySelected = () => {
    const selectedLogs = Array.from(selectedIndices)
      .sort((a, b) => a - b)
      .map(index => {
        const log = logs[index];
        const time = log.timestamp ? new Date(parseInt(log.timestamp)).toLocaleTimeString() : '???';
        return `[${time}] ${log.type.toUpperCase()}: ${log.message}`;
      })
      .join('\n');
    
    if (selectedLogs) {
      navigator.clipboard.writeText(selectedLogs);
      // Optional: Show toast
    }
  };

  const getLogColor = (type) => {
    if (!type) return '#e0e0e0';
    switch (type.toLowerCase()) {
      case 'error': return '#ff5252';
      case 'warning': return '#ffb142';
      case 'lua': return '#4ade80';
      default: return '#e0e0e0';
    }
  };

  // rowComponent receives rowProps from List
  const LogRow = ({ index, style, selectedIndices, handleSelectionStart, handleSelectionEnter }) => {
    const log = logs[index];
    if (!log) return null;
    const isSelected = selectedIndices.has(index);

    return (
      <div 
        style={{ ...style, display: 'flex', alignItems: 'center' }}
        onMouseEnter={() => handleSelectionEnter(index)}
      >
        <Checkbox 
          size="small"
          checked={isSelected}
          onMouseDown={(e) => {
            e.preventDefault(); // Prevent text selection while dragging checkboxes
            handleSelectionStart(index, isSelected);
          }}
          sx={{ 
            p: 0, 
            mr: 1, 
            color: '#444', 
            '&.Mui-checked': { color: '#bbb' },
            transform: 'scale(0.8)',
            cursor: 'pointer'
          }}
        />
        <Box sx={{ 
          display: 'flex', 
          width: '100%', 
          borderLeft: `3px solid ${getLogColor(log.type)}`, 
          pl: 1,
          fontFamily: 'Consolas, Monaco, "Andale Mono", "Ubuntu Mono", monospace',
          fontSize: '0.85rem',
          lineHeight: '1.2rem',
          overflow: 'hidden',
          whiteSpace: 'nowrap',
          bgcolor: isSelected ? 'rgba(255, 255, 255, 0.08)' : 'transparent',
          userSelect: 'text',
          pointerEvents: 'auto'
        }}>
          <Typography 
            component="span" 
            sx={{ 
              color: '#888', 
              fontSize: '0.75rem', 
              mr: 1,
              fontFamily: 'inherit',
              flexShrink: 0,
              minWidth: '85px'
            }}
          >
            [{log.timestamp ? new Date(parseInt(log.timestamp)).toLocaleTimeString() : '???'}]
          </Typography>
          <Typography 
            component="span" 
            sx={{ 
              color: getLogColor(log.type), 
              fontWeight: 'bold',
              mr: 1,
              fontSize: '0.75rem',
              fontFamily: 'inherit',
              flexShrink: 0
            }}
          >
            {(log.type || 'General').toUpperCase()}:
          </Typography>
          <Typography 
            component="span" 
            sx={{ 
              color: '#d4d4d4',
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              fontFamily: 'inherit'
            }}
          >
            {log.message}
          </Typography>
        </Box>
      </div>
    );
  };

  return (
    <Box sx={{ height: 'calc(100vh - 160px)', display: 'flex', flexDirection: 'column' }}>
      <Box sx={{ mb: 2, display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
        <Typography variant="h4">System Console ({logs.length})</Typography>
        <Box sx={{ display: 'flex', alignItems: 'center', gap: 2 }}>
          <FormControlLabel
            control={
              <Checkbox 
                checked={onlyDT} 
                onChange={(e) => {
                  setOnlyDT(e.target.checked);
                  nextOffsetRef.current = null;
                  setLogs([]);
                  setLoading(true);
                }} 
              />
            }
            label="DT Only"
          />
          <FormControlLabel
            control={
              <Checkbox 
                checked={autoScroll} 
                onChange={(e) => setAutoScroll(e.target.checked)} 
              />
            }
            label="Auto-scroll"
          />
          <IconButton 
            onClick={copySelected} 
            color="primary" 
            disabled={selectedIndices.size === 0}
            title={`Copy ${selectedIndices.size} selected lines`}
          >
            <ContentCopyIcon />
          </IconButton>
          <IconButton 
            onClick={clearSelection} 
            color="error" 
            disabled={selectedIndices.size === 0}
            title="Clear Selection"
          >
            <ClearIcon sx={{ fontSize: '1.2rem' }} />
          </IconButton>
          <IconButton onClick={() => setIsPaused(!isPaused)} color={isPaused ? "warning" : "primary"}>
            {isPaused ? <PlayArrowIcon /> : <PauseIcon />}
          </IconButton>
          <IconButton onClick={() => fetchLogs(true)} color="primary">
            <RefreshIcon />
          </IconButton>
          <IconButton onClick={clearLogs} color="error">
            <DeleteIcon />
          </IconButton>
        </Box>
      </Box>

      <Paper 
        elevation={3} 
        sx={{ 
          flexGrow: 1, 
          bgcolor: '#1e1e1e', 
          p: 1, 
          position: 'relative',
          overflow: 'hidden',
          minHeight: '200px'
        }}
        ref={containerRef}
      >
        {loading ? (
          <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%' }}>
            <CircularProgress />
          </Box>
        ) : logs.length === 0 ? (
          <Typography sx={{ color: '#888', fontStyle: 'italic', p: 2 }}>No logs found...</Typography>
        ) : (
          <Box sx={{ height: '100%', width: '100%', position: 'absolute', top: 0, left: 0 }}>
            <AutoSizer>
              {({ height, width }) => (
                height > 0 && width > 0 ? (
                  <List
                    style={{ height, width, overflowX: 'hidden' }}
                    rowCount={logs.length}
                    rowHeight={22}
                    rowComponent={LogRow}
                    rowProps={{ selectedIndices, handleSelectionStart, handleSelectionEnter }} 
                    listRef={listRef}
                  />
                ) : (
                  <Box sx={{ p: 2, color: '#888' }}>Initializing container...</Box>
                )
              )}
            </AutoSizer>
          </Box>
        )}
      </Paper>
    </Box>
  );
};

// Simple AutoSizer if not installed, but usually it comes with virtualization packages
// I'll check package.json again or just install it
const AutoSizer = ({ children }) => {
  const [size, setSize] = useState({ height: 0, width: 0 });
  const ref = useRef();

  useEffect(() => {
    const observer = new ResizeObserver(entries => {
      for (let entry of entries) {
        setSize({
          height: entry.contentRect.height,
          width: entry.contentRect.width
        });
      }
    });

    if (ref.current) {
      observer.observe(ref.current);
      // Trigger initial size
      const rect = ref.current.getBoundingClientRect();
      setSize({ height: rect.height, width: rect.width });
    }
    return () => observer.disconnect();
  }, []);

  return (
    <div ref={ref} style={{ height: '100%', width: '100%' }}>
      {children(size)}
    </div>
  );
};

export default ConsolePage;
