import React from 'react';
import { ThemeProvider, createTheme, CssBaseline, Container, Typography, Box, AppBar, Toolbar } from '@mui/material';
import Dashboard from './components/Dashboard';
import Actions from './components/Actions';
import ItemTable from './components/ItemTable';

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
      <Box sx={{ display: 'flex', flexDirection: 'column', minHeight: '100vh' }}>
        <AppBar position="static">
          <Toolbar>
            <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
            Dynamic Trading Manager
            </Typography>
          </Toolbar>
        </AppBar>
        <Container maxWidth="lg" sx={{ mt: 4, mb: 4, flexGrow: 1 }}>
          <Dashboard />
          <Box sx={{ my: 4 }}>
            <Actions />
          </Box>
          <Typography variant="h5" sx={{ mb: 2 }}>Vanilla Items</Typography>
          <ItemTable />
        </Container>
      </Box>
    </ThemeProvider>
  );
}

export default App;
