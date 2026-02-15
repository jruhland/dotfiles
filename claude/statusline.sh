#!/usr/bin/env bash

input=$(cat)

MODEL=$(echo "$input" | jq -r ".model.display_name")
DIR=$(echo "$input" | jq -r ".workspace.current_dir")
PERCENT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)

RESET=$'\033[0m'
GRAY=$'\033[90m'
DIM=$'\033[2m'
RED=$'\033[31m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
CYAN=$'\033[36m'
WHITE=$'\033[97m'

# Context bar: 30 chars wide, compaction marker at 80%
BAR_WIDTH=30
COMPACTION=80
FILLED=$((PERCENT_USED * BAR_WIDTH / 100))
COMPACT_POS=$((COMPACTION * BAR_WIDTH / 100))

if [ "$PERCENT_USED" -lt 40 ]; then
  BAR_COLOR="$GREEN"
elif [ "$PERCENT_USED" -le 70 ]; then
  BAR_COLOR="$YELLOW"
else
  BAR_COLOR="$RED"
fi

BAR=""
for ((i = 0; i < BAR_WIDTH; i++)); do
  if [ "$i" -eq "$COMPACT_POS" ]; then
    BAR+="${DIM}│${RESET}"
  elif [ "$i" -lt "$FILLED" ]; then
    BAR+="${BAR_COLOR}━${RESET}"
  else
    BAR+="${GRAY}─${RESET}"
  fi
done

# Model name: use the raw model id, strip provider prefix, append context if non-default
MODEL_ID=$(echo "$input" | jq -r ".model.id")
SHORT_MODEL=$(echo "$MODEL_ID" | sed -E 's/^(claude-|anthropic\.claude-|us\.anthropic\.claude-|global\.anthropic\.claude-)//')

# Shortened path: first parent shortened, ellipsis, last 2 shortened parents + leaf
# /var/lib/.../for/a/while  or  ~/.../w/s/api-gateway
SHORT_DIR="$DIR"
if [[ "$DIR" == "$HOME"* && "$DIR" != "$HOME" ]]; then
  SHORT_DIR="~${DIR#"$HOME"}"
elif [ "$DIR" = "$HOME" ]; then
  SHORT_DIR="~"
fi

if [ "$SHORT_DIR" = "/" ]; then
  SHORTENED="/"
elif [ "$SHORT_DIR" = "~" ]; then
  SHORTENED="~"
else
  IFS='/' read -ra PARTS <<< "$SHORT_DIR"
  CLEAN=()
  for PART in "${PARTS[@]}"; do
    [ -n "$PART" ] && CLEAN+=("$PART")
  done
  COUNT=${#CLEAN[@]}
  LEAF="${CLEAN[$((COUNT - 1))]}"

  shorten_part() {
    local p="$1"
    if [ "$p" = "~" ]; then
      printf '%s' "~"
    elif [[ "$p" == .* ]]; then
      printf '%s' "${p:0:2}"
    else
      printf '%s' "${p:0:1}"
    fi
  }

  if [ "$COUNT" -eq 1 ]; then
    if [ "${CLEAN[0]}" = "~" ]; then
      SHORTENED="~"
    else
      SHORTENED="/$LEAF"
    fi
  elif [ "$COUNT" -le 4 ]; then
    SHORTENED=""
    for ((i = 0; i < COUNT; i++)); do
      P="${CLEAN[$i]}"
      if [ "$P" = "~" ]; then
        SHORTENED="~"
      elif [ "$i" -eq $((COUNT - 1)) ]; then
        SHORTENED+="/$P"
      else
        SHORTENED+="/$(shorten_part "$P")"
      fi
    done
  else
    FIRST="${CLEAN[0]}"
    if [ "$FIRST" = "~" ]; then
      SHORTENED="~"
    else
      SHORTENED="/$(shorten_part "$FIRST")"
    fi
    P2="${CLEAN[$((COUNT - 3))]}"
    P1="${CLEAN[$((COUNT - 2))]}"
    SHORTENED+="/.../$(shorten_part "$P2")/$(shorten_part "$P1")/$LEAF"
  fi
fi

# Git branch
BRANCH=""
if git rev-parse --git-dir >/dev/null 2>&1; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)
  if git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null; then
    DEFAULT_BRANCH="main"
  elif git show-ref --verify --quiet refs/remotes/origin/master 2>/dev/null; then
    DEFAULT_BRANCH="master"
  fi
  if [ -n "$CURRENT_BRANCH" ]; then
    if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
      BRANCH=" ${RED}${CURRENT_BRANCH}${RESET}"
    else
      BRANCH=" ${WHITE}${CURRENT_BRANCH}${RESET}"
    fi
  fi
fi

PIPE="${WHITE}|${RESET}"
if [ -n "$BRANCH" ]; then
  printf "[%s] %s%s%s %s %s%s%s %s%s" "$BAR" "$BAR_COLOR" "$SHORT_MODEL" "$RESET" "$PIPE" "$CYAN" "$SHORTENED" "$RESET" "$PIPE" "$BRANCH"
else
  printf "[%s] %s%s%s %s %s%s%s" "$BAR" "$BAR_COLOR" "$SHORT_MODEL" "$RESET" "$PIPE" "$CYAN" "$SHORTENED" "$RESET"
fi
