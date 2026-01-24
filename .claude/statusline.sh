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

BRANCH=""

if git rev-parse --git-dir >/dev/null 2>&1; then
  BRANCH="| $(git branch --show-current 2>/dev/null)"
fi

# Color coding for context percentage
if [ "$PERCENT_USED" -lt 40 ]; then
  COLOR="\033[32m" # Green
elif [ "$PERCENT_USED" -le 70 ]; then
  COLOR="\033[33m" # Yellow
else
  COLOR="\033[31m" # Red
fi
RESET="\033[0m"

printf "[%s] Context: ${COLOR}%d%%${RESET} %s" "$MODEL" "$PERCENT_USED" "$BRANCH"
