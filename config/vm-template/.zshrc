# .zshrc for VM template - Minimal configuration
# This is a basic zsh configuration for the evan user
# Users can customize further after deployment

# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Basic options
setopt AUTO_CD              # cd by typing directory name
setopt CORRECT              # Suggest corrections for mistyped commands
setopt AUTO_PUSHD           # Make cd push old directory onto stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt EXTENDED_GLOB        # Extended globbing

# Completion system
autoload -Uz compinit
compinit

# Better completion
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case insensitive

# Prompt - simple and informative
# Shows: user@hostname:current_dir$
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f$ '

# Aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# Docker aliases (since all VMs use Docker)
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dlog='docker logs'
alias dexec='docker exec -it'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline'

# Safety aliases
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Utility functions
# Quickly cd to projects directory
projects() {
    cd ~/projects
}

# Show disk usage in human-readable format
disk() {
    df -h | grep -E '(Filesystem|/dev/)'
}

# Docker cleanup
docker-clean() {
    docker system prune -f
}

# Load additional local customizations if they exist
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
