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
      # Disable XON/XOFF flow control so Ctrl+S never hard-freezes the terminal
      setopt NO_FLOW_CONTROL

      # Reduce escape-sequence timeout from 400ms to 100ms.
      # Prevents ZLE from appearing frozen while waiting to decide if a lone ESC
      # (e.g. from tmux focus-events) is the start of a longer sequence.
      KEYTIMEOUT=10

      export PATH="$HOME/.local/bin:$PATH"

      # ── mise
      export PATH="$HOME/.mise/bin:$PATH"
      if command -v mise >/dev/null 2>&1; then
        eval "$(mise activate zsh)"
      fi

      # Print a blank line before each prompt via precmd so the newline is
      # outside $PROMPT — keeps ZLE's height calculation correct for multi-line pastes
      _blank_line_precmd() { print }
      precmd_functions+=(_blank_line_precmd)

      # ── tmux autostart
      if command -v tmux >/dev/null 2>&1 && [ -z "$TMUX" ] && [ -n "$PS1" ]; then
        tmux attach-session -t main || tmux new-session -s main
      fi

      # ── tmux-sessionizer (tms)
      export TMS_CONFIG_FILE="$HOME/.config/tms/config.toml"

      # ── fzf
      export FZF_DEFAULT_OPTS="--height=80% --layout=reverse --border --preview='fzf-preview.sh {}'"
      export FZF_TMUX_OPTS="-p 80%,60%"

      # ── tmux focus-events: bind \e[I so ZLE handles it cleanly instead of
      # waiting KEYTIMEOUT ms for a sequence that never completes
      zle -N _noop_widget
      _noop_widget() {}
      bindkey '\e[I' _noop_widget   # focus-in  (\e[I)
      bindkey '\e[O' _noop_widget   # focus-out (\e[O — distinct from SS3 \eO)

      # ── fzf-tab
      source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh

      zstyle ':fzf-tab:*' fzf-command fzf
      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':fzf-tab:*' fzf-flags --preview-window=hidden:wrap
    '';
  };

  # ── Starship prompt
  programs.starship.enable = true;
  xdg.configFile."starship.toml".source = ./../../dotfiles/starship.toml;
}
