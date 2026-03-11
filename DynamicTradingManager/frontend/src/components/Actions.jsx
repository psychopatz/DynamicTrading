import React, { useState } from 'react';
import { Button, Stack, TextField, Alert, Snackbar } from '@mui/material';
import { triggerUpdate, triggerAdd } from '../services/api';

const Actions = () => {
    const [batchSize, setBatchSize] = useState(50);
    const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'info' });

    const handleAction = async (actionFn, ...args) => {
        try {
            await actionFn(...args);
            setSnackbar({ open: true, message: 'Action started in background', severity: 'success' });
        } catch (err) {
            setSnackbar({ open: true, message: 'Failed to trigger action', severity: 'error' });
        }
    };

    return (
        <Stack direction="row" spacing={2} alignItems="center">
            <Button variant="contained" color="primary" onClick={() => handleAction(triggerUpdate)}>
                Update Registered Items
            </Button>
            <TextField 
                label="Batch Size" 
                type="number" 
                value={batchSize} 
                onChange={(e) => setBatchSize(parseInt(e.target.value))}
                size="small"
                sx={{ width: 120 }}
            />
            <Button variant="contained" color="secondary" onClick={() => handleAction(triggerAdd, batchSize)}>
                Add New Items
            </Button>
            <Snackbar 
                open={snackbar.open} 
                autoHideDuration={6000} 
                onClose={() => setSnackbar({ ...snackbar, open: false })}
            >
                <Alert severity={snackbar.severity} sx={{ width: '100%' }}>
                    {snackbar.message}
                </Alert>
            </Snackbar>
        </Stack>
    );
};

export default Actions;
