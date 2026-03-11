#!/bin/bash
# Start Frontend Script

cd "$(dirname "$0")/frontend" || exit

if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

echo "Starting Frontend..."
npm run dev
