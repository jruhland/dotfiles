export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/jarrod/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration
export DEFAULT_USER=jarrod
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='vim'
fi

# ssh
export SSH_KEY_PATH="~/.ssh/id_rsa"

# Aliases
alias cat=bat
alias ls=exa
alias git=hub
alias k=kubecfg
alias d=docker
alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"
alias dc="docker-compose"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jarrod/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/jarrod/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/jarrod/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/jarrod/google-cloud-sdk/completion.zsh.inc'; fi

. /usr/local/etc/profile.d/z.sh


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
