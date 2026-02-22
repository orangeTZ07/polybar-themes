#!/usr/bin/env bash
set -euo pipefail

current_desktop="$(xprop -root _NET_CURRENT_DESKTOP | awk '{print $3}')"
active_window="$(xprop -root _NET_ACTIVE_WINDOW | awk '{print $5}')"
window_ids="$(xprop -root _NET_CLIENT_LIST_STACKING | sed -e 's/.*# //' -e 's/,//g')"

colors_file="${COLORS_FILE:-$HOME/.config/polybar/docky/colors.ini}"
primary_color="$(awk -F '=' '/^[[:space:]]*primary[[:space:]]*=/{gsub(/[[:space:]]*/, "", $2); print $2; exit}' "$colors_file" 2>/dev/null || true)"
active_color="${ACTIVE_COLOR:-$primary_color}"

icons=()

for id in $window_ids; do
  desk="$(xprop -id "$id" _NET_WM_DESKTOP 2>/dev/null | awk '{print $3}')"
  if [ -z "$desk" ]; then
    continue
  fi
  if [ "$desk" != "$current_desktop" ] && [ "$desk" != "-1" ]; then
    continue
  fi

  if xprop -id "$id" _NET_WM_STATE 2>/dev/null | grep -q "_NET_WM_STATE_SKIP_TASKBAR"; then
    continue
  fi

  class="$(xprop -id "$id" WM_CLASS 2>/dev/null | awk -F '"' '{print $(NF-1)}')"
  class_lc="$(printf "%s" "$class" | tr '[:upper:]' '[:lower:]')"

  case "$class_lc" in
    firefox) icon="" ;;
    chromium|google-chrome|google-chrome-stable) icon="" ;;
    code|code-oss|vscode|codium) icon="" ;;
    alacritty|kitty|termite|urxvt|xterm|xfce4-terminal|gnome-terminal) icon="" ;;
    thunar|pcmanfm|nautilus|dolphin) icon="" ;;
    clash*|clash-verge|clash-verge-rev) icon="" ;;
    qq|linuxqq) icon="" ;;
    wechat|wechat.exe) icon="" ;;
    cherry-studio|cherrystudio) icon="" ;;
    hmcl) icon="" ;;
    telegramdesktop) icon="" ;;
    discord) icon="" ;;
    *) icon="" ;;
  esac

  if [ -n "$active_color" ] && [ "$id" = "$active_window" ]; then
    icon="%{F$active_color}%{u$active_color}%{+u}${icon}%{-u}%{u-}%{F-}"
  fi

  icons+=("$icon")
done

printf "%s\n" "${icons[*]}"
