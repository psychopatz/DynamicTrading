from fastapi import FastAPI, BackgroundTasks, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict, Any, Union
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
    from ItemManagement import load_vanilla_items, VANILLA_SCRIPTS_DIR, DISTRIBUTIONS_DIR, generate_tags, calculate_price, get_stat
    from ItemManagement.commons.vanilla_loader import get_property_value, get_translated_name
    from ItemManagement.commons.lua_handler.records import tags_list_to_dict
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
    batch_size: Union[int, str] = 50

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
async def list_items(
    search: Optional[str] = None, 
    status: Optional[str] = None,
    tag: Optional[str] = None,
    min_weight: Optional[float] = None,
    max_weight: Optional[float] = None,
    min_price: Optional[int] = None,
    max_price: Optional[int] = None,
    limit: int = 100, 
    offset: int = 0
):
    try:
        items = get_items()
        registered_ids = get_registered_items() # Full set from Lua files
        
        filtered_results = []
        item_keys = list(items.keys())
        
        for item_id in item_keys:
            props = items[item_id]
            is_bl, _ = is_item_blacklisted(item_id, {})
            
            # Extract metadata
            tags_list = generate_tags(item_id, props)
            tags_dict = tags_list_to_dict(tags_list)
            price = calculate_price(item_id, props, tags_dict)
            weight = get_stat(props, "Weight", 0.5)
            
            item_name = get_translated_name(item_id, props)
            
            # Application of filters
            if search and search.lower() not in item_name.lower() and search.lower() not in item_id.lower():
                continue
                
            if status:
                if status == "registered" and item_id not in registered_ids:
                    continue
                elif status == "unregistered" and (item_id in registered_ids or is_bl):
                    continue
                elif status == "blacklisted" and not is_bl:
                    continue
                    
            if tag:
                # Match if tag exists within any tag string in the array
                if not any(tag.lower() in t.lower() for t in tags_list):
                    continue
                    
            if min_weight is not None and weight < min_weight:
                continue
            if max_weight is not None and weight > max_weight:
                continue
            if min_price is not None and price < min_price:
                continue
            if max_price is not None and price > max_price:
                continue
            
            filtered_results.append({
                "id": item_id,
                "name": item_name,
                "is_blacklisted": bool(is_bl),
                "is_registered": item_id in registered_ids,
                "price": int(price),
                "tags": tags_list,
                "weight": float(weight)
            })
            
        total = len(filtered_results)
        
        # Paginate correctly after slicing
        paginated_results = filtered_results[offset:offset+limit]
        
        return {
            "total": total,
            "items": paginated_results
        }
    except Exception as e:
        logger.error(f"Error in list_items: {e}")
        return {"total": 0, "items": [], "error": str(e)}

@app.get("/api/tags")
async def list_unique_tags():
    try:
        items = get_items()
        unique_tags = set()
        
        for item_id, props in items.items():
            tags_list = generate_tags(item_id, props)
            for tag in tags_list:
                unique_tags.add(tag)
                
        return {"tags": sorted(list(unique_tags))}
    except Exception as e:
        logger.error(f"Error fetching tags: {e}")
        return {"tags": [], "error": str(e)}

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

# --- Simulation ---

try:
    from Simulation.config import BuildConfig, default_paths
    from Simulation.export.database_builder import build_database
except ImportError as e:
    logger.error(f"Error importing Simulation modules: {e}")

@app.get("/api/simulation/data")
async def get_simulation_data():
    try:
        paths = default_paths()
        config = BuildConfig()
        payload = build_database(paths, config)
        return payload
    except Exception as e:
        logger.error(f"Error generating simulation data: {e}")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
