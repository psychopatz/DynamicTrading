#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-/home/psychopatz/Zomboid/Workshop/DynamicObjectives/Contents/mods/DynamicObjectives/42.16/media/lua}"

rg -n --glob '*.lua' \
  'ui:speak\(".*[A-Za-z]|text = ".*[A-Za-z]|message = ".*[A-Za-z]|addOption\(".*[A-Za-z]|setTitle\(".*[A-Za-z]|drawText\(".*[A-Za-z]|drawTextCentre\(".*[A-Za-z]|drawTextRight\(".*[A-Za-z]|ISButton:new\([^)]*".*[A-Za-z]|ISLabel:new\([^)]*".*[A-Za-z]' \
  "$ROOT/client/DO/UI/DO_MissionViewerWindow.lua" \
  "$ROOT/client/DO/UI/MissionViewer" \
  "$ROOT/client/DO/UI/DO_CompletionModal.lua" \
  "$ROOT/client/DO/UI/DO_ProgressModal.lua" \
  "$ROOT/client/DO/UI/DO_FailureModal.lua" \
  "$ROOT/client/DO/UI/DO_ObjectiveHUD.lua" \
  "$ROOT/shared/DO/Quests/QuestRuntime/QuestRuntime_Offers.lua" \
| rg -v 'DynamicObjectives\.Text\.Get|T\("DOCommon_|require "|derive\(|status == |type == |kind == |mode == |or "active"|or "done"|return value == nil|"\{|\}"|getTexture\("Item_|"objective_tracker"|"\[|\]"'
