from fastapi import FastAPI, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import sys
import os
from pathlib import Path
import logging
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Import from local ItemManagement package
try:
    from ItemManagement import load_vanilla_items, VANILLA_SCRIPTS_DIR, DISTRIBUTIONS_DIR
    from ItemManagement.commons.vanilla_loader import get_property_value
    from ItemManagement.ui.commands import (
        update as run_update, 
        add as run_add,
        delete_all_items,
        list_properties,
        find_property,
        analyze_properties,
        analyze_spawns,
        rarity_stats,
        get_registered_items
    )
    from ItemManagement.ui.stats import count_registered_items, find_invalid_blacklist_ids
    from ItemManagement.parse import load_blacklist, is_item_blacklisted
    from ItemManagement.task_manager import manager
except ImportError as e:
    logger.error(f"Error importing ItemManagement modules: {e}")
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

class AddRequest(BaseModel):
    batch_size: int = 50

class FindPropertyRequest(BaseModel):
    property_name: str
    value_filter: Optional[str] = None
    chunk_limit: Optional[int] = 20

class ListPropertiesRequest(BaseModel):
    min_usage: int = 1
    chunk_limit: Optional[int] = 20

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
    try:
        items = get_items()
        registered_ids = get_registered_items() # Full set from Lua files
        
        results = []
        item_keys = list(items.keys())
        
        # Simple search
        if search:
            search = search.lower()
            item_keys = [k for k in item_keys if search in k.lower()]
            
        for item_id in item_keys[offset:offset+limit]:
            item_props = items[item_id]
            is_bl, _ = is_item_blacklisted(item_id, {})
            results.append({
                "id": item_id,
                "name": get_property_value(item_props, "DisplayName", item_id) or item_id,
                "is_blacklisted": bool(is_bl),
                "is_registered": item_id in registered_ids
            })
        
        return {
            "total": len(item_keys),
            "items": results
        }
    except Exception as e:
        logger.error(f"Error in list_items: {e}")
        return {"total": 0, "items": [], "error": str(e)}

# --- Task Routes ---

@app.get("/api/tasks")
async def list_tasks():
    return manager.list_tasks()

@app.get("/api/tasks/{task_id}")
async def get_task_status(task_id: str):
    task = manager.get_task(task_id)
    if not task:
        raise HTTPException(status_code=404, detail="Task not found")
    return task

@app.get("/api/tasks/{task_id}/logs")
async def get_task_logs(task_id: str, since: int = 0):
    return manager.get_logs(task_id, since)

# --- Action Routes (now using TaskManager) ---

@app.post("/api/actions/update")
async def trigger_update():
    items = get_items()
    task_id = manager.create_task("Update Items", run_update, items)
    return {"task_id": task_id}

@app.post("/api/actions/add")
async def trigger_add(request: AddRequest):
    items = get_items()
    task_id = manager.create_task(f"Add Items (Batch: {request.batch_size})", run_add, items, request.batch_size)
    return {"task_id": task_id}

@app.post("/api/actions/reset")
async def trigger_reset():
    task_id = manager.create_task("Reset Item Registry", delete_all_items, force=True)
    return {"task_id": task_id}

@app.post("/api/actions/list-properties")
async def trigger_list_properties(request: ListPropertiesRequest):
    task_id = manager.create_task(
        "List Properties", 
        list_properties, 
        VANILLA_SCRIPTS_DIR, 
        request.min_usage, 
        request.chunk_limit
    )
    return {"task_id": task_id}

@app.post("/api/actions/find-property")
async def trigger_find_property(request: FindPropertyRequest):
    task_id = manager.create_task(
        f"Find Property: {request.property_name}", 
        find_property, 
        VANILLA_SCRIPTS_DIR, 
        request.property_name, 
        request.value_filter, 
        request.chunk_limit
    )
    return {"task_id": task_id}

@app.post("/api/actions/analyze-spawns")
async def trigger_analyze_spawns():
    task_id = manager.create_task("Analyze Spawns", analyze_spawns, DISTRIBUTIONS_DIR, full_output=True)
    return {"task_id": task_id}

@app.post("/api/actions/rarity-stats")
async def trigger_rarity_stats():
    task_id = manager.create_task("Rarity Statistics", rarity_stats, DISTRIBUTIONS_DIR)
    return {"task_id": task_id}

@app.post("/api/actions/generate-docs")
async def trigger_generate_docs():
    task_id = manager.create_task("Generate Property Docs", analyze_properties, VANILLA_SCRIPTS_DIR)
    return {"task_id": task_id}

# --- Blacklist ---

@app.get("/api/blacklist")
async def get_blacklist():
    return load_blacklist()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
