#!/usr/bin/env python3
from __future__ import annotations

import argparse
import http.server
import socketserver
import sys
from pathlib import Path

if __package__ is None or __package__ == "":
    sys.path.insert(0, str(Path(__file__).parent))

from src.config import BuildConfig, default_paths
from src.export.database_builder import build_database, write_database
from src.web.generator import generate_web_site


def build(project_root: Path) -> Path:
    paths = default_paths(project_root)
    config = BuildConfig()

    payload = build_database(paths, config)
    write_database(
        payload,
        paths.output_data / "sim_data.json",
        paths.output_data / "sim_data.js",
    )
    generate_web_site(project_root / "Scripts/SimulateGame/src/web", paths.output_web)
    return paths.output_web


def serve(web_root: Path, port: int) -> None:
    handler = http.server.SimpleHTTPRequestHandler
    with socketserver.TCPServer(("127.0.0.1", port), handler) as httpd:
        print(f"SimulateGame serving: http://127.0.0.1:{port}/")
        print("Press Ctrl+C to stop")
        try:
            import os

            os.chdir(web_root)
            httpd.serve_forever()
        except KeyboardInterrupt:
            pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="SimulateGame toolkit")
    parser.add_argument("command", choices=["build", "serve"], help="Command to run")
    parser.add_argument("--port", type=int, default=8765, help="Port for serve")
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    project_root = Path(__file__).resolve().parents[2]

    web_root = build(project_root)
    print(f"Built SimulateGame output at: {web_root}")

    if args.command == "serve":
        serve(web_root, args.port)


if __name__ == "__main__":
    main()
