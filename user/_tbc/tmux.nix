{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    extraConfig = ''
      # Prefix key configuration
      # Change prefix from C-b (Ctrl+b) to C-u (Ctrl+u)
      unbind C-b
      set -g prefix C-u
      # Double-press prefix to switch to last window
      bind-key u last-window
      # Press prefix+e to send literal C-u to applications
      bind-key e send-prefix

      # Terminal settings
      # Use 256-colour terminal mode for better colour support
      set -g default-terminal "tmux-256color"
      # Enable true colour and italic support for xterm terminals
      set -as terminal-overrides ',xterm*:Tc:sitm=\E[3m'
      # Enable RGB colour support for all terminals
      set -sg terminal-overrides ",*:RGB"

      # Increase scrollback buffer to 20000 lines
      set -g history-limit 20000

      # Automatically renumber windows when one is closed
      set -g renumber-windows on

      # Start window and pane numbering from 1 instead of 0
      set -g base-index 1
      setw -g pane-base-index 1

      # Resize windows when attached clients change size
      setw -g aggressive-resize on

      # Reduce delay when pressing escape key (0ms)
      set -sg escape-time 0

      # Pane navigation (vi-style)
      # Use h/j/k/l to navigate between panes
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      # Reload tmux configuration
      bind r source-file ~/.tmux.conf

      # Pane resizing (with prefix)
      # Resize panes by 3 lines/columns using prefix + Ctrl + direction
      bind C-j resize-pane -D 3
      bind C-k resize-pane -U 3
      bind C-l resize-pane -R 3
      bind C-h resize-pane -L 3

      # Window splitting and creation
      # Split windows maintaining current directory
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      # Create new window in current directory
      bind c new-window -c "#{pane_current_path}"

      # Disable mouse support
      setw -g mouse off

      # Copy mode configuration (vi-style)
      setw -g mode-keys vi
      # Use 'v' to start visual selection in copy mode
      bind-key -T copy-mode-vi 'v' send -X begin-selection
      # Use 'y' to copy selection to macOS clipboard (pbcopy)
      bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "pbcopy"

      # Status bar configuration
      # Position status bar at bottom
      set -g status-position bottom
      # Status bar colours (dark background, muted foreground)
      set -g status-bg colour234
      set -g status-fg colour137
      # Empty left side of status bar
      set -g status-left ""
      # Right side shows date (DD/MM) and time (HH:MM:SS)
      set -g status-right '#[fg=colour233,bg=colour241,bold] %d/%m #[fg=colour233,bg=colour245,bold] %H:%M:%S '
      set -g status-right-length 50
      set -g status-left-length 20
      setw -g mode-keys vi

      # Window status format
      # Current window: bright colours with window number, name, and flags
      setw -g window-status-current-format ' #I#[fg=colour250]:#[fg=colour255]#W#[fg=colour50]#F '
      # Other windows: muted colours
      setw -g window-status-format ' #I#[fg=colour237]:#[fg=colour250]#W#[fg=colour244]#F '
    '';
  };
}
