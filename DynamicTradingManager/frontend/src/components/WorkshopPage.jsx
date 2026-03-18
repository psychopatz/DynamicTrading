import React, { useState, useEffect, useRef } from 'react';
import { 
  Box, 
  Typography, 
  Paper, 
  Button, 
  TextField, 
  Stack, 
  Divider, 
  Alert,
  Grid,
  Snackbar,
  InputAdornment,
  IconButton,
  Switch,
  FormControlLabel,
  FormControl,
  InputLabel,
  Select,
  MenuItem,
  CircularProgress
} from '@mui/material';
import { 
  CloudUpload as UploadIcon, 
  Build as BuildIcon, 
  Person as PersonIcon, 
  Lock as LockIcon,
  Visibility as VisibilityIcon,
  VisibilityOff,
  Info as InfoIcon,
  Photo as PhotoIcon,
  Edit as EditIcon,
  Sync as SyncIcon
} from '@mui/icons-material';
import * as api from '../services/api';
import TaskConsole from './TaskConsole';

const WorkshopPage = () => {
  // Credentials
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  
  // Metadata
  const [metadata, setMetadata] = useState({
    title: '',
    description: '',
    tags: '',
    visibility: 0,
    id: ''
  });
  const [changenote, setChangenote] = useState('Mod update pushed via Dynamic Trading Manager');
  
  // Toggles
  const [updateFiles, setUpdateFiles] = useState(true);
  const [updateMetadata, setUpdateMetadata] = useState(false);
  const [updatePreview, setUpdatePreview] = useState(false);
  
  // UI State
  const [loading, setLoading] = useState(true);
  const [activeTaskId, setActiveTaskId] = useState(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'info' });
  const [previewUrl, setPreviewUrl] = useState(`http://localhost:8000/static/workshop/preview.png?t=${Date.now()}`);
  const fileInputRef = useRef(null);

  useEffect(() => {
    fetchMetadata();
  }, []);

  const fetchMetadata = async () => {
    setLoading(true);
    try {
      const res = await api.getWorkshopMetadata();
      setMetadata(res.data);
    } catch (err) {
      console.error('Failed to fetch workshop metadata:', err);
      setSnackbar({ open: true, message: 'Failed to load mod metadata from workshop.txt', severity: 'error' });
    } finally {
      setLoading(false);
    }
  };

  const handlePrepare = async () => {
    try {
      const res = await api.triggerWorkshopPrepare();
      if (res.data.success) {
        setSnackbar({ open: true, message: 'Staging directory prepared successfully', severity: 'success' });
      }
    } catch (err) {
      setSnackbar({ open: true, message: 'Failed to prepare staging', severity: 'error' });
    }
  };

  const handleImageUpload = async (event) => {
    const file = event.target.files[0];
    if (!file) return;

    const formData = new FormData();
    formData.append('file', file);

    try {
      await api.uploadWorkshopImage(formData);
      setPreviewUrl(`http://localhost:8000/static/workshop/preview.png?t=${Date.now()}`);
      setUpdatePreview(true);
      setSnackbar({ open: true, message: 'Preview image updated locally', severity: 'success' });
    } catch (err) {
      setSnackbar({ open: true, message: 'Failed to upload image', severity: 'error' });
    }
  };

  const handlePush = async () => {
    if (!username) {
      setSnackbar({ open: true, message: 'Steam Username is required', severity: 'warning' });
      return;
    }
    try {
      const payload = {
        username,
        password: password || undefined,
        changenote,
        update_files: updateFiles,
        update_metadata: updateMetadata,
        update_preview: updatePreview,
        ...(updateMetadata ? {
          title: metadata.title,
          description: metadata.description,
          tags: metadata.tags,
          visibility: metadata.visibility
        } : {})
      };

      const res = await api.triggerWorkshopPush(payload);
      if (res.data.task_id) {
        setActiveTaskId(res.data.task_id);
        setSnackbar({ open: true, message: 'Workshop Push task started', severity: 'info' });
      }
    } catch (err) {
        const errorMsg = err.response?.data?.detail || 'Failed to start push task';
        setSnackbar({ open: true, message: errorMsg, severity: 'error' });
    }
  };

  if (loading) {
    return (
      <Box sx={{ display: 'flex', justifyContent: 'center', py: 8 }}>
        <CircularProgress />
      </Box>
    );
  }

  return (
    <Box sx={{ py: 2 }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', mb: 4 }}>
        <Box sx={{ maxWidth: 800 }}>
          <Typography variant="h4" gutterBottom sx={{ fontWeight: 700 }}>
            Full-Fledged Workshop Manager
          </Typography>
          <Typography variant="body1" sx={{ color: 'text.secondary' }}>
            Control every aspect of your mod's Workshop presence. Edit metadata, upload new preview images, 
            and synchronize files all from one place.
          </Typography>
        </Box>
        <Button 
          variant="outlined" 
          color="primary" 
          startIcon={<VisibilityIcon />}
          onClick={() => window.open(`https://steamcommunity.com/sharedfiles/filedetails/?id=${metadata.id || '3635333613'}`, '_blank')}
          sx={{ borderRadius: 2, py: 1.5, px: 3, fontWeight: 700 }}
        >
          View on Steam Workshop
        </Button>
      </Box>

      <Grid container spacing={4}>
        {/* Left Column: Metadata & Details */}
        <Grid item xs={12} lg={8}>
          <Stack spacing={3}>
            {/* 1. Metadata Form */}
            <Paper elevation={2} sx={{ p: 4, borderRadius: 3 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h6" sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                  <EditIcon color="primary" />
                  Workshop Page Details
                </Typography>
                <FormControlLabel
                  control={<Switch checked={updateMetadata} onChange={(e) => setUpdateMetadata(e.target.checked)} color="primary" />}
                  label="Update Metadata on Push"
                />
              </Box>
              
              <Stack spacing={3}>
                <TextField 
                  label="Mod Title" 
                  fullWidth 
                  value={metadata.title}
                  onChange={(e) => setMetadata({...metadata, title: e.target.value})}
                  disabled={!updateMetadata}
                />
                
                <TextField 
                  label="Workshop Description (Steam BBCode)" 
                  fullWidth 
                  multiline
                  rows={10}
                  value={metadata.description}
                  onChange={(e) => setMetadata({...metadata, description: e.target.value})}
                  disabled={!updateMetadata}
                  placeholder="[h1]Title[/h1]\n[b]Bold Text[/b]\n[list][*]Point[/list]"
                />

                <Grid container spacing={2}>
                  <Grid item xs={12} sm={8}>
                    <TextField 
                      label="Tags (Semicolon separated)" 
                      fullWidth 
                      value={metadata.tags}
                      onChange={(e) => setMetadata({...metadata, tags: e.target.value})}
                      disabled={!updateMetadata}
                      placeholder="Build 42;Balance;Hardmode"
                    />
                  </Grid>
                  <Grid item xs={12} sm={4}>
                    <FormControl fullWidth disabled={!updateMetadata}>
                      <InputLabel>Visibility</InputLabel>
                      <Select
                        value={metadata.visibility}
                        label="Visibility"
                        onChange={(e) => setMetadata({...metadata, visibility: e.target.value})}
                      >
                        <MenuItem value={0}>Public</MenuItem>
                        <MenuItem value={1}>Friends Only</MenuItem>
                        <MenuItem value={2}>Private</MenuItem>
                      </Select>
                    </FormControl>
                  </Grid>
                </Grid>
              </Stack>
            </Paper>

            {/* 2. File Synchronization */}
            <Paper elevation={2} sx={{ p: 4, borderRadius: 3 }}>
              <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 3 }}>
                <Typography variant="h6" sx={{ display: 'flex', alignItems: 'center', gap: 1.5 }}>
                  <SyncIcon color="primary" />
                  File Synchronization
                </Typography>
                <FormControlLabel
                  control={<Switch checked={updateFiles} onChange={(e) => setUpdateFiles(e.target.checked)} color="primary" />}
                  label="Update Mod Files on Push"
                />
              </Box>
              <Typography variant="body2" color="text.secondary" paragraph>
                Preparation gathered only the required files (<code>Contents/</code>, <code>workshop.txt</code>, etc.) into the staging area.
              </Typography>
              <Button 
                variant="outlined" 
                onClick={handlePrepare}
                disabled={!updateFiles}
                startIcon={<BuildIcon />}
              >
                Prepare Content Staging
              </Button>
            </Paper>
          </Stack>
        </Grid>

        {/* Right Column: Preview & Push */}
        <Grid item xs={12} lg={4}>
          <Stack spacing={3}>
            {/* Preview Image */}
            <Paper elevation={2} sx={{ p: 3, borderRadius: 3 }}>
               <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 2 }}>
                <Typography variant="subtitle2" sx={{ fontWeight: 700, display: 'flex', alignItems: 'center', gap: 1 }}>
                  <PhotoIcon fontSize="small" color="primary" />
                  PREVIEW POSTER
                </Typography>
                <FormControlLabel
                  control={<Switch size="small" checked={updatePreview} onChange={(e) => setUpdatePreview(e.target.checked)} color="primary" />}
                  label="Sync Image"
                />
              </Box>
              
              <Box 
                sx={{ 
                  width: '100%', 
                  aspectRatio: '1/1', 
                  bgcolor: '#000', 
                  borderRadius: 2, 
                  overflow: 'hidden',
                  position: 'relative',
                  border: '1px solid #333',
                  mb: 2
                }}
              >
                <img 
                  src={previewUrl} 
                  alt="Mod Preview" 
                  style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                />
              </Box>
              <input 
                type="file" 
                accept="image/*.png" 
                style={{ display: 'none' }} 
                ref={fileInputRef} 
                onChange={handleImageUpload}
              />
              <Button 
                variant="outlined" 
                size="small" 
                fullWidth 
                onClick={() => fileInputRef.current.click()}
              >
                Upload New Image
              </Button>
            </Paper>

            <Paper elevation={4} sx={{ p: 3, borderRadius: 3, bgcolor: 'background.paper', border: '1px solid', borderColor: 'divider' }}>
              <Typography variant="subtitle2" gutterBottom sx={{ fontWeight: 700, mb: 1 }}>
                READY TO PUSH?
              </Typography>
              <Typography variant="caption" color="text.secondary" paragraph>
                Select exactly what you want to upload to Steam in this update:
              </Typography>
              
              <Stack spacing={1} sx={{ mb: 3 }}>
                <FormControlLabel
                  control={<Switch size="small" checked={updateFiles} onChange={(e) => setUpdateFiles(e.target.checked)} color="primary" />}
                  label={<Typography variant="body2">Include Mod Files (Contents/)</Typography>}
                />
                <FormControlLabel
                  control={<Switch size="small" checked={updateMetadata} onChange={(e) => setUpdateMetadata(e.target.checked)} color="primary" />}
                  label={<Typography variant="body2">Include Page Metadata (Title, Desc, Tags)</Typography>}
                />
                <FormControlLabel
                  control={<Switch size="small" checked={updatePreview} onChange={(e) => setUpdatePreview(e.target.checked)} color="primary" />}
                  label={<Typography variant="body2">Include Preview Image (preview.png)</Typography>}
                />
              </Stack>

              <Stack spacing={2}>
                <TextField 
                  label="Steam Username" 
                  size="small"
                  fullWidth 
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  InputProps={{
                    startAdornment: <InputAdornment position="start"><PersonIcon fontSize="small" /></InputAdornment>,
                  }}
                />
                <TextField 
                  label="Steam Password" 
                  type={showPassword ? 'text' : 'password'}
                  size="small"
                  fullWidth 
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  InputProps={{
                    startAdornment: <InputAdornment position="start"><LockIcon fontSize="small" /></InputAdornment>,
                    endAdornment: (
                      <InputAdornment position="end">
                        <IconButton onClick={() => setShowPassword(!showPassword)} edge="end" size="small">
                          {showPassword ? <VisibilityOff /> : <VisibilityIcon />}
                        </IconButton>
                      </InputAdornment>
                    ),
                  }}
                />
                <TextField 
                  label="Change Note" 
                  fullWidth 
                  multiline
                  rows={2}
                  value={changenote}
                  onChange={(e) => setChangenote(e.target.value)}
                />
                
                <Button 
                  variant="contained" 
                  color="secondary" 
                  fullWidth 
                  size="large"
                  startIcon={<UploadIcon />}
                  onClick={handlePush}
                  sx={{ py: 1.5, fontWeight: 700 }}
                  disabled={!updateFiles && !updateMetadata && !updatePreview}
                >
                  PUSH TO WORKSHOP
                </Button>
              </Stack>
            </Paper>

            <Alert severity="info" sx={{ borderRadius: 2 }}>
               <Typography variant="caption" sx={{ display: 'flex', alignItems: 'center', gap: 0.5 }}>
                 <InfoIcon fontSize="inherit" />
                 Your password is never stored on disk.
               </Typography>
            </Alert>
          </Stack>
        </Grid>
      </Grid>

      {activeTaskId && (
        <TaskConsole 
          taskId={activeTaskId} 
          onClose={() => setActiveTaskId(null)} 
        />
      )}

      <Snackbar 
        open={snackbar.open} 
        autoHideDuration={6000} 
        onClose={() => setSnackbar({ ...snackbar, open: false })}
      >
        <Alert severity={snackbar.severity} variant="filled" sx={{ width: '100%' }}>
          {snackbar.message}
        </Alert>
      </Snackbar>
    </Box>
  );
};

export default WorkshopPage;
