# Set PATH
export PATH=$HOME/.scripts:$PATH

# Initialize zoxide
eval "$(zoxide init zsh)"

# Source custom scripts
source $HOME/.scripts/fzf-git.sh

# Enable Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# Load Oh My Zsh
if [ -d "$ZSH" ]; then
  source $ZSH/oh-my-zsh.sh
fi

if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
  source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

# Enable syntax highlighting
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
  source "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Aliases
alias cp="cp -a"
alias ls="exa --across --group-directories-first"
alias la="exa --all --across --group-directories-first"
alias ll="exa -l --all -g --icons --git --no-user --classify --group-directories-first"
alias lt="exa --level=1 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
alias llt="exa --level=2 --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
alias lft="exa --icons --tree --git --git-ignore --no-user --no-permissions --group-directories-first -a"
alias hist=". hist"
alias tms="tms"
alias bash="zsh"

source <(ng completion script)
