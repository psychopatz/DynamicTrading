#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-/home/psychopatz/Zomboid/Workshop/DynamicColonies/Contents/mods/DynamicColonies/42.16/media/lua/client}"

rg -n --glob '*.lua' \
  'ui:speak\(".*[A-Za-z]|text = ".*[A-Za-z]|message = ".*[A-Za-z]|addOption\(".*[A-Za-z]|setTitle\(".*[A-Za-z]|drawText\(".*[A-Za-z]|:Say\(".*[A-Za-z]|ISButton:new\([^)]*".*[A-Za-z]|ISLabel:new\([^)]*".*[A-Za-z]' \
  "$ROOT/DC/UI/Colony/MainWindow" \
  "$ROOT/DC/UI/Colony/SupplyWindow" \
  "$ROOT/DC/UI/Colony/DC_CompanionLootModal.lua" \
  "$ROOT/DC/UI/Colony/DC_ColonyQuantityModal.lua" \
  "$ROOT/DC/UI/Colony/Gatherer/DC_GathererConfigModal.lua" \
  "$ROOT/DC/UI/Faction/DC_PlayerFactionNameModal.lua" \
  "$ROOT/DC/UI/Faction/FactionInfoWindow/DC_FactionInfoWindow.lua" \
| rg -v 'DC\.Text\.Get|T\("DCCommon_|require "|derive\(|command == |state == |status == |jobType == |or "inventory"|or "warehouse"|or "provisions"|or "player"|or "worker"|"\[debug\] Get Item"' \
| rg -v 'promptText = args\.promptText|title = args\.title|confirmLabel = args\.confirmLabel'
