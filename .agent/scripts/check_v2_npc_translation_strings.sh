#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-Contents/mods/DynamicTradingV2/42.16/media/lua}"

rg -n --glob '*.lua' \
  'ui:speak\(".*[A-Za-z]|text = ".*[A-Za-z]|message = ".*[A-Za-z]|addOption\(".*[A-Za-z]|setTitle\(".*[A-Za-z]|drawText\(".*[A-Za-z]|:Say\(".*[A-Za-z]|setHaloNote\(".*[A-Za-z]' \
  "$ROOT/client/DT/V2/NPC" \
  "$ROOT/shared/DT/V2/NPC" \
| rg -v '\.T\(|DynamicTrading\.Text\.Get|currentOffer\.choiceLabels|offer\.(offer|details|decline|unavailable)|helpers\.pickDialogueLine|plan and plan|debugLabel = |author or |sound or '
