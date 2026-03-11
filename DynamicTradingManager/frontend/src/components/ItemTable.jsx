import React, { useState, useEffect } from 'react';
import { 
    Table, 
    TableBody, 
    TableCell, 
    TableContainer, 
    TableHead, 
    TableRow, 
    Paper, 
    TablePagination, 
    Link, 
    Chip, 
    TextField, 
    InputAdornment, 
    Box,
    Typography
} from '@mui/material';
import SearchIcon from '@mui/icons-material/Search';
import { getItems } from '../services/api';

const ItemTable = () => {
    const [items, setItems] = useState([]);
    const [total, setTotal] = useState(0);
    const [page, setPage] = useState(0);
    const [rowsPerPage, setRowsPerPage] = useState(10);
    const [search, setSearch] = useState('');

    const fetchItems = async () => {
        try {
            const response = await getItems({
                limit: rowsPerPage,
                offset: page * rowsPerPage,
                search: search
            });
            if (response.data && response.data.items) {
                setItems(response.data.items);
                setTotal(response.data.total || 0);
            } else {
                setItems([]);
                setTotal(0);
            }
        } catch (err) {
            console.error("Fetch error:", err);
            setItems([]);
            setTotal(0);
        }
    };

    useEffect(() => {
        const timer = setTimeout(() => {
            fetchItems();
        }, 300); // Debounce search
        return () => clearTimeout(timer);
    }, [page, rowsPerPage, search]);

    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };

    const handleChangeRowsPerPage = (event) => {
        setRowsPerPage(parseInt(event.target.value, 10));
        setPage(0);
    };

    const handleSearchChange = (event) => {
        setSearch(event.target.value);
        setPage(0);
    };

    const getTagColor = (tag) => {
        if (tag.startsWith('Rarity.Common')) return 'default';
        if (tag.startsWith('Rarity.Uncommon')) return 'primary';
        if (tag.startsWith('Rarity.Rare')) return 'secondary';
        if (tag.startsWith('Rarity.Legendary')) return 'warning';
        if (tag.startsWith('Quality.Broken')) return 'error';
        return 'default';
    };

    return (
        <Box>
            <Box sx={{ p: 2, display: 'flex', justifyContent: 'flex-end' }}>
                <TextField
                    size="small"
                    variant="outlined"
                    placeholder="Search items..."
                    value={search}
                    onChange={handleSearchChange}
                    InputProps={{
                        startAdornment: (
                            <InputAdornment position="start">
                                <SearchIcon />
                            </InputAdornment>
                        ),
                    }}
                    sx={{ width: 300 }}
                />
            </Box>
            <TableContainer component={Paper} sx={{ boxShadow: 'none' }}>
                <Table size="small" stickyHeader>
                    <TableHead>
                        <TableRow>
                            <TableCell sx={{ fontWeight: 'bold' }}>Item ID</TableCell>
                            <TableCell sx={{ fontWeight: 'bold' }}>Display Name</TableCell>
                            <TableCell sx={{ fontWeight: 'bold' }}>Price</TableCell>
                            <TableCell sx={{ fontWeight: 'bold' }}>Weight</TableCell>
                            <TableCell sx={{ fontWeight: 'bold' }}>Tags</TableCell>
                            <TableCell sx={{ fontWeight: 'bold' }}>Status</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {items.length === 0 ? (
                            <TableRow>
                                <TableCell colSpan={6} align="center" sx={{ py: 3 }}>
                                    <Typography color="textSecondary">No items found</Typography>
                                </TableCell>
                            </TableRow>
                        ) : (
                            items.map((item) => (
                                <TableRow key={item.id} hover>
                                    <TableCell sx={{ fontFamily: 'monospace', fontSize: '0.8rem' }}>{item.id}</TableCell>
                                    <TableCell>{item.name}</TableCell>
                                    <TableCell>${item.price}</TableCell>
                                    <TableCell>{item.weight}kg</TableCell>
                                    <TableCell>
                                        <Box sx={{ display: 'flex', flexWrap: 'wrap', gap: 0.5 }}>
                                            {item.tags?.map(tag => (
                                                <Chip 
                                                    key={tag} 
                                                    label={tag} 
                                                    size="small" 
                                                    variant="outlined"
                                                    color={getTagColor(tag)}
                                                    sx={{ fontSize: '0.65rem', height: 20 }}
                                                />
                                            ))}
                                        </Box>
                                    </TableCell>
                                    <TableCell>
                                        {item.is_blacklisted ? (
                                            <Chip label="Blacklisted" size="small" color="error" variant="soft" />
                                        ) : item.is_registered ? (
                                            <Chip label="Registered" size="small" color="success" variant="soft" />
                                        ) : (
                                            <Chip label="Unregistered" size="small" color="warning" variant="soft" />
                                        )}
                                    </TableCell>
                                </TableRow>
                            ))
                        )}
                    </TableBody>
                </Table>
            </TableContainer>
            <TablePagination
                rowsPerPageOptions={[5, 10, 25, 50, 100]}
                component="div"
                count={total}
                rowsPerPage={rowsPerPage}
                page={page}
                onPageChange={handleChangePage}
                onRowsPerPageChange={handleChangeRowsPerPage}
            />
        </Box>
    );
};

export default ItemTable;
