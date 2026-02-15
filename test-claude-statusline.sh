#!/usr/bin/env bash

SL=~/.claude/statusline.sh
PAD=$(sed -n 's/^run_case "\([^"]*\)".*/\1/p' "$0" | awk '{ if (length > m) m = length } END { print m + 2 }')

run_case() {
  local label="$1" json="$2"
  printf "\033[2m%-${PAD}s\033[0m " "$label"
  echo "$json" | bash "$SL"
  echo
}

section() {
  printf "\n\033[1;95m── %s ──\033[0m\n\n" "$1"
}

j() {
  local pct="$1" model_id="$2" dir="$3" size="${4:-200000}"
  printf '{"model":{"id":"%s","display_name":"x"},"workspace":{"current_dir":"%s"},"context_window":{"used_percentage":%s,"context_window_size":%s}}' \
    "$model_id" "$dir" "$pct" "$size"
}

# Run outside any git repo
cd /tmp

# ─────────────────────────────────────────────────────────────────────────────
section "Context Bar Colors"
# ─────────────────────────────────────────────────────────────────────────────

run_case "0%   green start"          "$(j 0   claude-sonnet-4     /tmp)"
run_case "1%   green low"            "$(j 1   claude-sonnet-4     /tmp)"
run_case "20%  green mid"            "$(j 20  claude-sonnet-4     /tmp)"
run_case "39%  green last"           "$(j 39  claude-sonnet-4     /tmp)"
run_case "40%  yellow start"         "$(j 40  claude-sonnet-4     /tmp)"
run_case "55%  yellow mid"           "$(j 55  claude-sonnet-4     /tmp)"
run_case "70%  yellow last"          "$(j 70  claude-sonnet-4     /tmp)"
run_case "71%  red start"            "$(j 71  claude-sonnet-4     /tmp)"
run_case "80%  compaction marker"    "$(j 80  claude-sonnet-4     /tmp)"
run_case "92%  red high"             "$(j 92  claude-sonnet-4     /tmp)"
run_case "100% maxed out"            "$(j 100 claude-sonnet-4     /tmp)"

# ─────────────────────────────────────────────────────────────────────────────
section "Edge Cases (percentage)"
# ─────────────────────────────────────────────────────────────────────────────

run_case "0%   null pct fallback"    '{"model":{"id":"claude-sonnet-4","display_name":"x"},"workspace":{"current_dir":"/tmp"},"context_window":{"context_window_size":200000}}'
run_case "45%  fractional 45.7"      "$(j 45.7 claude-sonnet-4    /tmp)"

# ─────────────────────────────────────────────────────────────────────────────
section "Model ID Prefix Stripping"
# ─────────────────────────────────────────────────────────────────────────────

run_case "10%  claude-*"             "$(j 10  claude-sonnet-4                          /tmp)"
run_case "30%  anthropic.claude-*"   "$(j 30  anthropic.claude-opus-4-6                /tmp 1000000)"
run_case "50%  us.anthropic.*"       "$(j 50  us.anthropic.claude-sonnet-4-20250514-v1:0 /tmp)"
run_case "70%  global.anthropic.*"   "$(j 70  global.anthropic.claude-opus-4-6         /tmp 1000000)"

# ─────────────────────────────────────────────────────────────────────────────
section "Path Shortening"
# ─────────────────────────────────────────────────────────────────────────────

run_case "5%   /"                    "$(j 5   claude-sonnet-4     /)"
run_case "10%  ~"                    "$(j 10  claude-sonnet-4     /Users/jarrod)"
run_case "15%  /tmp (1-seg)"         "$(j 15  claude-sonnet-4     /tmp)"
run_case "20%  /e/nginx (2-seg)"     "$(j 20  claude-sonnet-4     /etc/nginx)"
run_case "25%  /u/local (2-seg)"     "$(j 25  claude-sonnet-4     /usr/local)"
run_case "30%  /u/l/bin (3-seg)"     "$(j 30  claude-sonnet-4     /usr/local/bin)"
run_case "35%  /v/l/a/out (4-seg)"   "$(j 35  claude-sonnet-4     /var/log/app/out)"
run_case "40%  ~/src (2-seg home)"   "$(j 40  claude-sonnet-4     /Users/jarrod/src)"
run_case "45%  ~/s/myapp (3-seg)"    "$(j 45  claude-haiku-3-5    /Users/jarrod/src/myapp)"
run_case "50%  ~/s/w/backend (4-seg)" "$(j 50 claude-opus-4-6     /Users/jarrod/src/work/backend 1000000)"
run_case "55%  ~/.../w/s/gw (5-seg)" "$(j 55  claude-opus-4-6     /Users/jarrod/src/projects/work/services/api-gateway 1000000)"
run_case "60%  /o/.../g/1/lib (6-no-home)" "$(j 60 claude-haiku-3-5 /opt/homebrew/Cellar/go/1.22/libexec)"
run_case "70%  ~/.../g/o/repo (6-home)" "$(j 70 claude-opus-4-6   /Users/jarrod/go/src/github.com/org/repo 1000000)"
run_case "92%  /v/.../f/a/while (15)" "$(j 92 claude-opus-4-6     /var/lib/some/deeply/nested/folder/structure/that/goes/on/and/on/for/a/while 1000000)"

# ─────────────────────────────────────────────────────────────────────────────
section "Dotfile Segments"
# ─────────────────────────────────────────────────────────────────────────────

run_case "15%  ~/.c/nvim"            "$(j 15  claude-sonnet-4     /Users/jarrod/.config/nvim)"
run_case "30%  ~/.l/s/zsh"           "$(j 30  claude-sonnet-4     /Users/jarrod/.local/share/zsh)"
run_case "50%  ~/.d/claude"          "$(j 50  claude-opus-4-6     /Users/jarrod/.dotfiles/claude 1000000)"
run_case "70%  /r/.ssh (outside ~)"  "$(j 70  claude-sonnet-4     /root/.ssh)"

# ─────────────────────────────────────────────────────────────────────────────
section "Git Branches"
# ─────────────────────────────────────────────────────────────────────────────

GIT_TMPDIR=$(mktemp -d)
trap 'rm -rf "$GIT_TMPDIR"' EXIT

make_repo() {
  local dir="$1"
  mkdir -p "$dir"
  git -C "$dir" init -q
  git -C "$dir" commit -q --allow-empty -m "init"
}

git_json() {
  local pct="$1" dir="$2"
  printf '{"model":{"id":"claude-opus-4-6","display_name":"x"},"workspace":{"current_dir":"%s"},"context_window":{"used_percentage":%s,"context_window_size":1000000}}' \
    "$dir" "$pct"
}

# 1) on main, origin/main exists -> red
REPO="$GIT_TMPDIR/repo-main"
make_repo "$REPO"
git -C "$REPO" branch -m main
git -C "$REPO" remote add origin "$REPO"
git -C "$REPO" fetch -q origin 2>/dev/null
cd "$REPO"
run_case "15%  main (red)"           "$(git_json 15 "$REPO")"

# 2) on master, origin/master exists -> red
REPO="$GIT_TMPDIR/repo-master"
make_repo "$REPO"
git -C "$REPO" branch -m master
git -C "$REPO" remote add origin "$REPO"
git -C "$REPO" fetch -q origin 2>/dev/null
cd "$REPO"
run_case "30%  master (red)"         "$(git_json 30 "$REPO")"

# 3) feature branch, origin/main exists -> white
REPO="$GIT_TMPDIR/repo-feature"
make_repo "$REPO"
git -C "$REPO" branch -m main
git -C "$REPO" remote add origin "$REPO"
git -C "$REPO" fetch -q origin 2>/dev/null
git -C "$REPO" checkout -q -b feat/cool-stuff
cd "$REPO"
run_case "45%  feature (white)"      "$(git_json 45 "$REPO")"

# 4) detached HEAD -> no branch shown
REPO="$GIT_TMPDIR/repo-detached"
make_repo "$REPO"
HEAD_SHA=$(git -C "$REPO" rev-parse HEAD)
git -C "$REPO" checkout -q "$HEAD_SHA"
cd "$REPO"
run_case "60%  detached (sha)"       "$(git_json 60 "$REPO")"

# 5) on a branch but no remote at all -> white
REPO="$GIT_TMPDIR/repo-no-remote"
make_repo "$REPO"
git -C "$REPO" branch -m dev
cd "$REPO"
run_case "75%  no remote (white)"    "$(git_json 75 "$REPO")"

# 6) on main but no remote -> white (DEFAULT_BRANCH unset)
REPO="$GIT_TMPDIR/repo-main-no-remote"
make_repo "$REPO"
git -C "$REPO" branch -m main
cd "$REPO"
run_case "90%  main no remote (white)"  "$(git_json 90 "$REPO")"
