#!/usr/bin/env bash

input=$(cat)

MODEL=$(echo "$input" | jq -r ".model.display_name")
# use like: ${DIR##*/}
DIR=$(echo "$input" | jq -r ".workspace.current_dir")
CONTEXT_SIZE=$(echo "$input" | jq -r ".context_window.context_window_size")
USAGE=$(echo "$input" | jq ".context_window.current_usage")

if [ "$USAGE" != "null" ]; then
  CURRENT_TOKENS=$(echo "$USAGE" | jq '.input_tokens + .output_tokens + .cache_creation_input_tokens + .cache_read_input_tokens')
  PERCENT_USED=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))
else
  PERCENT_USED=0
fi

RESET="\033[0m"
GRAY="\033[37m"
RED="\033[31m"

BRANCH=""
BRANCH_COLOR="$GRAY"

if git rev-parse --git-dir >/dev/null 2>&1; then
  CURRENT_BRANCH=$(git branch --show-current 2>/dev/null)

  if git show-ref --verify --quiet refs/remotes/origin/main 2>/dev/null; then
    DEFAULT_BRANCH="main"
  elif git show-ref --verify --quiet refs/remotes/origin/master 2>/dev/null; then
    DEFAULT_BRANCH="master"
  fi

  if [ -n "$CURRENT_BRANCH" ]; then
    BRANCH="| $CURRENT_BRANCH"
    if [ "$CURRENT_BRANCH" = "$DEFAULT_BRANCH" ]; then
      BRANCH_COLOR="$RED"
    fi
  fi
fi

# Color coding for context percentage
if [ "$PERCENT_USED" -lt 40 ]; then
  PERCENT_COLOR="\033[32m" # Green
elif [ "$PERCENT_USED" -le 70 ]; then
  PERCENT_COLOR="\033[33m" # Yellow
else
  PERCENT_COLOR="$RED"
fi

printf "${GRAY}[%s]${RESET} ${PERCENT_COLOR}%d%%${RESET} | %s ${BRANCH_COLOR}%s${RESET}" "$MODEL" "$PERCENT_USED" "${DIR##*/}" "$BRANCH"
