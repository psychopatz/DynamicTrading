#!/usr/bin/env bash
set -euo pipefail

ROOT="/home/psychopatz/Zomboid/Workshop/CurrencyExpanded/Contents/mods/CurrencyExpanded"

rg -n --pcre2 '"[A-Za-z][^"\n]*"' \
  "$ROOT/42.16/media/lua/client/Utils" \
  "$ROOT/42.16/media/lua/shared/CE/Common/InteractionStrings" \
  "$ROOT/42.16/media/lua/shared/CE/Common/Config" \
  "$ROOT/42.16/media/lua/shared/CE/Common/Text" \
  -g '*.lua' \
  -g '!**/server/**' \
  -g '!**/Translate/**' \
  | rg -v 'require "|pcall\(require|CurrencyExpanded"|DT/Common|CE/Common|Base\.|CE_|Wallet|ScratchTicket|Lottery|JACKPOT|WINNERS|PAYOUTS|SUCCESS|NONE|LOSE|WIN|HIGH|LOW|MEDIUM|EMPTY|ALREADY_SEARCHED|ALREADY_SCRATCHED|SCRATCHED|MoneyBundle|ClothesRustle|Loot|Trade"|Chat"|OnServerCommand|OnGameStart|OnGameBoot|OnFillInventoryObjectContextMenu|ISBaseTimedAction|ISInventoryTransferAction|Metabolics|__ce|^\s*--|Log\('
