from fastapi import FastAPI, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import sys
import os
from pathlib import Path
import io
from contextlib import redirect_stdout

import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Add ItemGenerator to path
ITEM_GENERATOR_DIR = Path(__file__).parent.parent.parent / "Scripts" / "ItemGenerator"
sys.path.append(str(ITEM_GENERATOR_DIR))

try:
    from src import load_vanilla_items, VANILLA_SCRIPTS_DIR, DISTRIBUTIONS_DIR
    from src.commons.vanilla_loader import get_property_value
    from src.ui.commands import update as run_update, add as run_add
    from src.ui.stats import count_registered_items, find_invalid_blacklist_ids, find_duplicate_blacklist_ids
    from src.parse import load_blacklist, is_item_blacklisted, get_blacklist_stats
except ImportError as e:
    logger.error(f"Error importing ItemGenerator modules: {e}")
    # Fallback or exit
    sys.exit(1)

app = FastAPI(title="Dynamic Trading Manager API")

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Models
class StatsResponse(BaseModel):
    total_vanilla: int
    registered: int
    unregistered: int
    coverage: float
    notifications: List[str]

class ItemBrief(BaseModel):
    id: str
    name: str
    category: Optional[str]
    is_registered: bool
    is_blacklisted: bool

class AddRequest(BaseModel):
    batch_size: int = 50

# Global state (cache items)
cached_vanilla_items = None

def get_items():
    global cached_vanilla_items
    if cached_vanilla_items is None:
        cached_vanilla_items = load_vanilla_items()
    return cached_vanilla_items

@app.get("/api/stats", response_model=StatsResponse)
async def get_stats():
    items = get_items()
    total_vanilla = len(items)
    registered = count_registered_items()
    unregistered = total_vanilla - registered
    coverage = (registered / total_vanilla * 100) if total_vanilla > 0 else 0
    
    notifications = []
    invalid_blacklist = find_invalid_blacklist_ids()
    if invalid_blacklist:
        notifications.append(f"{len(invalid_blacklist)} invalid item ID(s) in blacklist")
    
    return {
        "total_vanilla": total_vanilla,
        "registered": registered,
        "unregistered": unregistered,
        "coverage": round(coverage, 2),
        "notifications": notifications
    }

@app.get("/api/items")
async def list_items(search: Optional[str] = None, limit: int = 100, offset: int = 0):
    logger.info(f"Fetching items: search={search}, limit={limit}, offset={offset}")
    try:
        items = get_items()
        
        results = []
        # Simplified list for UI
        item_keys = list(items.keys())
        for item_id in item_keys[offset:offset+limit]:
            item_props = items[item_id]
            is_bl, _ = is_item_blacklisted(item_id)
            results.append({
                "id": item_id,
                "name": get_property_value(item_props, "DisplayName", item_id) or item_id,
                "is_blacklisted": bool(is_bl)
            })
        
        return {
            "total": len(items),
            "items": results
        }
    except Exception as e:
        logger.error(f"Error in list_items: {e}")
        return {"total": 0, "items": [], "error": str(e)}

@app.post("/api/actions/update")
async def trigger_update(background_tasks: BackgroundTasks):
    def update_task():
        items = get_items()
        run_update(items)
        
    background_tasks.add_task(update_task)
    return {"status": "update_started"}

@app.post("/api/actions/add")
async def trigger_add(request: AddRequest, background_tasks: BackgroundTasks):
    def add_task():
        items = get_items()
        run_add(items, request.batch_size)
        
    background_tasks.add_task(add_task)
    return {"status": "add_started", "batch_size": request.batch_size}

@app.get("/api/blacklist")
async def get_blacklist():
    return load_blacklist()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
