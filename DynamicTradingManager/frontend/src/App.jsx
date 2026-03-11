import React from 'react';
import { ThemeProvider, createTheme, CssBaseline, Container, Typography, Box, AppBar, Toolbar, Button } from '@mui/material';
import { BrowserRouter, Routes, Route, Link as RouterLink } from 'react-router-dom';
import Dashboard from './components/Dashboard';
import ItemsPage from './components/ItemsPage';
import SimulationDashboard from './components/Simulation/SimulationDashboard';

const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#90caf9',
    },
    secondary: {
      main: '#f48fb1',
    },
  },
});

function App() {
  return (
    <ThemeProvider theme={darkTheme}>
      <CssBaseline />
      <BrowserRouter>
          <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
            <AppBar position="static">
              <Toolbar>
                <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
                Dynamic Trading Manager
                </Typography>
                <Button color="inherit" component={RouterLink} to="/">Dashboard</Button>
                <Button color="inherit" component={RouterLink} to="/items">Vanilla Items</Button>
                <Button color="inherit" component={RouterLink} to="/simulation">Economy Simulation</Button>
              </Toolbar>
            </AppBar>
            <Container maxWidth="xl" sx={{ mt: 4, mb: 4, flexGrow: 1, display: 'flex', flexDirection: 'column' }}>
              <Routes>
                <Route path="/" element={<Dashboard />} />
                <Route path="/items" element={<ItemsPage />} />
                <Route path="/simulation" element={<SimulationDashboard />} />
              </Routes>
            </Container>
          </Box>
      </BrowserRouter>
    </ThemeProvider>
  );
}

export default App;
