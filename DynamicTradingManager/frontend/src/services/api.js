import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8000/api',
});

// Stats & Items
export const getStats = () => api.get('/stats');
export const getItems = (params) => api.get('/items', { params });

// Actions
export const triggerUpdate = () => api.post('/actions/update');
export const triggerAdd = (batchSize) => api.post('/actions/add', { batch_size: batchSize });
export const triggerReset = () => api.post('/actions/reset');
export const triggerListProperties = (minUsage) => api.post('/actions/list-properties', { min_usage: minUsage });
export const triggerFindProperty = (propName, valueFilter) => api.post('/actions/find-property', { property_name: propName, value_filter: valueFilter });
export const triggerAnalyzeSpawns = () => api.post('/actions/analyze-spawns');
export const triggerRarityStats = () => api.post('/actions/rarity-stats');
export const triggerGenerateDocs = () => api.post('/actions/generate-docs');

// Tasks & Logs
export const getTasks = () => api.get('/tasks');
export const getTaskStatus = (id) => api.get(`/tasks/${id}`);
export const getTaskLogs = (id, since = 0) => api.get(`/tasks/${id}/logs`, { params: { since } });

// Misc
export const getBlacklist = () => api.get('/blacklist');

export default api;
