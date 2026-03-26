# ── ~/.zshrc ────────────────────────────────

# Shell options
setopt EXTENDED_HISTORY       # store timestamps in history
setopt SHARE_HISTORY          # share history between terminals
setopt AUTO_CD                # cd by just typing dir name
setopt AUTO_PUSHD             # pushd on cd
setopt HIST_IGNORE_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt INC_APPEND_HISTORY
setopt NO_BEEP

# PATH + mise
export MISE_ROOT="$HOME/.mise"
export PATH="$MISE_ROOT/bin:$PATH"
if command -v mise >/dev/null 2>&1; then
    eval "$(mise hook zsh)"
fi

# Starship prompt
eval "$(starship init zsh)"

# Zinit: minimal plugin manager
if ! command -v zinit >/dev/null 2>&1; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
fi

# minimal plugins
zinit light zdharma-continuum/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions

# Modern navigation tools
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
# fzf completions (managed by nix, paths auto-resolved)
if [ -f "$(nix eval nixpkgs.fzf --raw)/share/fzf/completion.zsh" ]; then
    source "$(nix eval nixpkgs.fzf --raw)/share/fzf/completion.zsh"
fi
if [ -f "$(nix eval nixpkgs.fzf --raw)/share/fzf/key-bindings.zsh" ]; then
    source "$(nix eval nixpkgs.fzf --raw)/share/fzf/key-bindings.zsh"
fi

# zoxide
eval "$(zoxide init zsh)"

# Aliases
alias ls="eza --icons --group-directories-first"
alias ll="eza -lh --git"
alias tree="eza --tree"
alias cat="bat"
alias grep="rg"
alias find="fd"

# History search keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# TMUX
export TMUX_PLUGIN_MANAGER_PATH="$HOME/.tmux/plugins"
[ -f "$TMUX_PLUGIN_MANAGER_PATH/tpm/tpm" ] && source "$TMUX_PLUGIN_MANAGER_PATH/tpm/tpm"

# Editor / Terminal
export EDITOR='nvim'
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export TERM="xterm-256color"

# GUI
export DISPLAY=$(ip route list default | awk '{print $3}'):0
export LIBGL_ALWAYS_INDIRECT=1