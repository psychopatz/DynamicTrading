import React, { useState, useEffect } from 'react';
import { Table, TableBody, TableCell, TableContainer, TableHead, TableRow, Paper, TablePagination, Link } from '@mui/material';
import { getItems } from '../services/api';

const ItemTable = () => {
    const [items, setItems] = useState([]);
    const [total, setTotal] = useState(0);
    const [page, setPage] = useState(0);
    const [rowsPerPage, setRowsPerPage] = useState(10);

    const fetchItems = async () => {
        try {
            const response = await getItems({
                limit: rowsPerPage,
                offset: page * rowsPerPage
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
        fetchItems();
    }, [page, rowsPerPage]);

    const handleChangePage = (event, newPage) => {
        setPage(newPage);
    };

    const handleChangeRowsPerPage = (event) => {
        setRowsPerPage(parseInt(event.target.value, 10));
        setPage(0);
    };

    return (
        <Paper>
            <TableContainer>
                <Table size="small">
                    <TableHead>
                        <TableRow>
                            <TableCell>Item ID</TableCell>
                            <TableCell>Display Name</TableCell>
                            <TableCell>Status</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {items.map((item) => (
                            <TableRow key={item.id}>
                                <TableCell>{item.id}</TableCell>
                                <TableCell>{item.name}</TableCell>
                                <TableCell>
                                    {item.is_blacklisted ? (
                                        <span style={{ color: '#f44336' }}>🚫 Blacklisted</span>
                                    ) : item.is_registered ? (
                                        <span style={{ color: '#4caf50' }}>✅ Registered</span>
                                    ) : (
                                        <span style={{ color: '#ff9800' }}>⏳ Unregistered</span>
                                    )}
                                </TableCell>
                            </TableRow>
                        ))}
                    </TableBody>
                </Table>
            </TableContainer>
            <TablePagination
                rowsPerPageOptions={[5, 10, 25, 50]}
                component="div"
                count={total}
                rowsPerPage={rowsPerPage}
                page={page}
                onPageChange={handleChangePage}
                onRowsPerPageChange={handleChangeRowsPerPage}
            />
        </Paper>
    );
};

export default ItemTable;
