# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

source $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

plugins=(fzf mise zoxide)

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nvim'
  export TERM='xterm'
else
  export EDITOR='nvim'
fi


export BAT_THEME="Catpuccin-Mocha"
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
HISTORY_IGNORE="(ls|cd|pwd|z|exit)*"

setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt APPEND_HISTORY
setopt HIST_NO_STORE
setopt HIST_REDUCE_BLANKS

# git spice completions
eval "$(gs shell completion zsh)"

# Additional aliases are found in $ZSH_CUSTOM/aliases.zsh
alias claude="/Users/jarrod/.claude/local/claude"
