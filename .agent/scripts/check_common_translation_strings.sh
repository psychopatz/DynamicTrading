#!/usr/bin/env bash
set -euo pipefail

ROOT="${1:-Contents/mods/DynamicTradingCommon/42.16/media/lua/client}"

rg -n --glob '*.lua' \
  'ui:speak\(".*[A-Za-z]|text = ".*[A-Za-z]|message = ".*[A-Za-z]|addOption\(".*[A-Za-z]|setTitle\(".*[A-Za-z]|drawText\(".*[A-Za-z]|:Say\(".*[A-Za-z]|setHaloNote\(".*[A-Za-z]|ISButton:new\([^)]*".*[A-Za-z]|ISLabel:new\([^)]*".*[A-Za-z]' \
  "$ROOT/DT/Common/UI/Trading" \
  "$ROOT/DT/Common/Contacts/DT_TraderContacts" \
  "$ROOT/DT/UI/Faction" \
| rg -v '\.T\(|DynamicTrading\.Text\.Get|sound or |hook = |tag = |state == |status == |transactionKind == |command == |return "Small"|return "Medium"|return "Large"|derive\(|require "|contains\("DynamicColonies"|setOverlayMode\("trading"|setAnimationProfile\("trading"|overlayStyle = "trading"|archetype or "General"|or "Male"|or "Female"|or "legacy"|or "3d"|or "unknown"' \
| rg -v 'T\("DTCommon_|T\("DTNPC_|T\("'
