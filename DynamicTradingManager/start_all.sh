#!/bin/bash
# Start All (Backend & Frontend) Script

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Starting Backend and Frontend..."

# Run backend in background
"$SCRIPT_DIR/start_backend.sh" &
BACKEND_PID=$!

# Run frontend
"$SCRIPT_DIR/start_frontend.sh"

# When frontend stops, kill backend too
kill $BACKEND_PID
