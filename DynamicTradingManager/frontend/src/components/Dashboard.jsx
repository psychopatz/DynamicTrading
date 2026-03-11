import React, { useState, useEffect } from 'react';
import { Grid, Paper, Typography, Box, Alert } from '@mui/material';
import { getStats } from '../services/api';

const Dashboard = () => {
    const [stats, setStats] = useState(null);
    const [error, setError] = useState(null);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                const response = await getStats();
                setStats(response.data);
            } catch (err) {
                setError("Failed to connect to backend");
            }
        };
        fetchStats();
        const interval = setInterval(fetchStats, 5000);
        return () => clearInterval(interval);
    }, []);

    if (error) return <Alert severity="error">{error}</Alert>;
    if (!stats) return <Typography>Loading stats...</Typography>;

    return (
        <Box sx={{ flexGrow: 1, mt: 3 }}>
            <Grid container spacing={3}>
                <Grid item xs={12} sm={6} md={3}>
                    <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                        <Typography variant="h6">Total Vanilla</Typography>
                        <Typography variant="h4">{stats.total_vanilla}</Typography>
                    </Paper>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                    <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column', alignItems: 'center', bgcolor: 'success.light' }}>
                        <Typography variant="h6">Registered</Typography>
                        <Typography variant="h4">{stats.registered}</Typography>
                    </Paper>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                    <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column', alignItems: 'center', bgcolor: 'warning.light' }}>
                        <Typography variant="h6">Unregistered</Typography>
                        <Typography variant="h4">{stats.unregistered}</Typography>
                    </Paper>
                </Grid>
                <Grid item xs={12} sm={6} md={3}>
                    <Paper sx={{ p: 2, display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                        <Typography variant="h6">Coverage</Typography>
                        <Typography variant="h4">{stats.coverage}%</Typography>
                    </Paper>
                </Grid>
                {stats.notifications && stats.notifications.length > 0 && (
                    <Grid item xs={12}>
                        {stats.notifications.map((note, idx) => (
                            <Alert key={idx} severity="warning" sx={{ mb: 1 }}>{note}</Alert>
                        ))}
                    </Grid>
                )}
            </Grid>
        </Box>
    );
};

export default Dashboard;
