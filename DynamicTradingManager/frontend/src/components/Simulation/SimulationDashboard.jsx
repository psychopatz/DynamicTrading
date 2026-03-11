import React, { useState, useEffect } from 'react';
import { 
  Box, Typography, Paper, CircularProgress, Alert, 
  Grid, Card, CardContent, Tabs, Tab, Table, TableBody, TableCell, 
  TableContainer, TableHead, TableRow, Chip
} from '@mui/material';
import { 
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer,
  LineChart, Line
} from 'recharts';
import { getSimulationData } from '../../services/api';

function TabPanel(props) {
  const { children, value, index, ...other } = props;
  return (
    <div role="tabpanel" hidden={value !== index} {...other}>
      {value === index && (
        <Box sx={{ p: 3 }}>
          {children}
        </Box>
      )}
    </div>
  );
}

export default function SimulationDashboard() {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [tabValue, setTabValue] = useState(0);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      const response = await getSimulationData();
      setData(response.data);
      setError(null);
    } catch (err) {
      console.error(err);
      setError('Failed to fetch simulation data. Is the backend running?');
    } finally {
      setLoading(false);
    }
  };

  const handleTabChange = (event, newValue) => {
    setTabValue(newValue);
  };

  if (loading) {
    return (
      <Box display="flex" justifyContent="center" alignItems="center" minHeight="50vh">
        <CircularProgress />
      </Box>
    );
  }

  if (error) {
    return <Alert severity="error">{error}</Alert>;
  }

  if (!data) return null;

  // Prepare Data for Charts
  const { day0, items, archetypes, events } = data;
  const { traderSamples, tradeMatrix, unservedItems, activeEventIds, season } = day0;

  // Archetype Stock Data for Chart
  const stockChartData = Object.entries(traderSamples).map(([archId, sample]) => {
    const totalQty = Object.values(sample.stock).reduce((sum, item) => sum + item.qty, 0);
    const uniqueItems = Object.keys(sample.stock).length;
    return {
      name: sample.name,
      totalQty,
      uniqueItems
    };
  });

  return (
    <Box sx={{ width: '100%' }}>
      <Typography variant="h4" gutterBottom sx={{ fontWeight: 'bold' }}>
        Economy Simulation Dashboard
      </Typography>
      
      <Grid container spacing={3} sx={{ mb: 4 }}>
        <Grid item xs={12} md={4}>
          <Card elevation={3} sx={{ height: '100%' }}>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>Current Season</Typography>
              <Typography variant="h5">{season}</Typography>
            </CardContent>
          </Card>
        </Grid>
        <Grid item xs={12} md={8}>
          <Card elevation={3} sx={{ height: '100%' }}>
            <CardContent>
              <Typography color="textSecondary" gutterBottom>Active Events</Typography>
              <Box sx={{ display: 'flex', gap: 1, flexWrap: 'wrap', mt: 1 }}>
                {activeEventIds.length > 0 ? (
                  activeEventIds.map(id => (
                    <Chip key={id} label={events[id]?.name || id} color="primary" />
                  ))
                ) : (
                  <Typography variant="body1">None</Typography>
                )}
              </Box>
            </CardContent>
          </Card>
        </Grid>
      </Grid>

      <Paper elevation={3} sx={{ width: '100%' }}>
        <Box sx={{ borderBottom: 1, borderColor: 'divider' }}>
          <Tabs value={tabValue} onChange={handleTabChange} variant="fullWidth">
            <Tab label="Trader Stock Overview" />
            <Tab label="Item Trade Matrix" />
            <Tab label="Unserved Items" />
          </Tabs>
        </Box>
        
        <TabPanel value={tabValue} index={0}>
          <Typography variant="h6" gutterBottom>Simulated Market Volume by Trader</Typography>
          <Box sx={{ height: 400, width: '100%', mt: 2 }}>
            <ResponsiveContainer>
              <BarChart data={stockChartData} margin={{ top: 20, right: 30, left: 20, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" opacity={0.2} />
                <XAxis dataKey="name" />
                <YAxis yAxisId="left" orientation="left" stroke="#8884d8" />
                <YAxis yAxisId="right" orientation="right" stroke="#82ca9d" />
                <Tooltip contentStyle={{ backgroundColor: '#333', borderColor: '#444' }} />
                <Legend />
                <Bar yAxisId="left" dataKey="totalQty" name="Total Item Qty" fill="#8884d8" radius={[4, 4, 0, 0]} />
                <Bar yAxisId="right" dataKey="uniqueItems" name="Unique Items" fill="#82ca9d" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </Box>
        </TabPanel>

        <TabPanel value={tabValue} index={1}>
          <Typography variant="h6" gutterBottom>Sample Item Prices</Typography>
          <TableContainer component={Paper} elevation={1} sx={{ maxHeight: 600 }}>
            <Table stickyHeader size="small">
              <TableHead>
                <TableRow>
                  <TableCell>Item ID</TableCell>
                  <TableCell>Base Price</TableCell>
                  {Object.values(archetypes).map(arch => (
                    <TableCell key={arch.archetype_id} align="right">{arch.name}</TableCell>
                  ))}
                </TableRow>
              </TableHead>
              <TableBody>
                {Object.entries(tradeMatrix).slice(0, 50).map(([itemId, row]) => (
                  <TableRow key={itemId} hover>
                    <TableCell>{itemId}</TableCell>
                    <TableCell>{items[itemId]?.base_price || 0}</TableCell>
                    {Object.keys(archetypes).map(archId => {
                      const data = row[archId];
                      return (
                        <TableCell key={archId} align="right" sx={{ 
                          color: data.tradeable ? 'success.main' : 'text.disabled',
                          fontWeight: data.tradeable ? 'bold' : 'normal'
                         }}>
                          {data.tradeable ? `B:${data.buyPrice} S:${data.sellPrice}` : '-'}
                        </TableCell>
                      );
                    })}
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </TableContainer>
          <Typography variant="caption" sx={{ mt: 1, display: 'block' }}>Showing first 50 items for performance.</Typography>
        </TabPanel>

        <TabPanel value={tabValue} index={2}>
          <Typography variant="h6" gutterBottom>Items Missing from All Traders</Typography>
          <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 1 }}>
            {unservedItems.length > 0 ? (
              unservedItems.map(item => (
                <Chip key={item} label={item} variant="outlined" />
              ))
            ) : (
              <Alert severity="success">All items are served by at least one trader!</Alert>
            )}
          </Box>
        </TabPanel>

      </Paper>
    </Box>
  );
}
