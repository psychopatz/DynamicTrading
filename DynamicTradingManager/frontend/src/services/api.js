import axios from 'axios';

const api = axios.create({
  baseURL: 'http://localhost:8000/api',
});

export const getStats = () => api.get('/stats');
export const getItems = (params) => api.get('/items', { params });
export const triggerUpdate = () => api.post('/actions/update');
export const triggerAdd = (batchSize) => api.post('/actions/add', { batch_size: batchSize });
export const getBlacklist = () => api.get('/blacklist');

export default api;
