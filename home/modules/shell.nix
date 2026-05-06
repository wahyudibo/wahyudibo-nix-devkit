{ config, pkgs, ... }:

{
  # ── Shell ────────────────────────────────
  programs.zsh = {
    enable = true;

    enableCompletion = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
    };

    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -lh --git";
      tree = "eza --tree";
      cat = "bat";
      grep = "rg";
      find = "fd";
      c = "code .";
      e = "explorer.exe .";
    };

    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"

      # ── mise
      export PATH="$HOME/.mise/bin:$PATH"
      if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
      fi

      # ── zoxide
      eval "$(zoxide init zsh)"

      # ── tmux autostart
      if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ -n "$PS1" ]; then
        tmux attach-session -t main || tmux new-session -s main
      fi

      # ── tmux-sessionizer (tms)
      export TMS_CONFIG_FILE="$HOME/.config/tms/config.toml"

      # ── fzf
      export FZF_DEFAULT_OPTS="--height=80% --layout=reverse --border --preview='fzf-preview.sh {}'"
      export FZF_TMUX_OPTS="-p 80%,60%"

      # ── fzf-tab
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      # Optional: Disable default preview for fzf-tab to keep it light
      zstyle ':fzf-tab:*' fzf-command fzf

      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':fzf-tab:*' fzf-flags --preview-window=hidden:wrap

      # ── starship
      eval "$(starship init zsh)"
    '';
  };

  # ── Starship prompt
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./../../dotfiles/starship.toml;
}
