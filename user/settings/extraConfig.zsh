# Kubectl completions (Note: kubectl plugin in oh-my-zsh already provides this)
source <(kubectl completion zsh)

# AMSTOOL completions
eval "$(_AMSTOOL_COMPLETE=zsh_source amstool)"

# Cargo (Rust)
export PATH="$HOME/.cargo/bin:$PATH"

# Go binaries
export PATH="$HOME/go/bin:$PATH"

# jenv
if command -v jenv >/dev/null 2>&1; then eval "$(jenv init -)"; fi

# Maven home
export M2_HOME="$(mvn --home --quiet)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# iTerm2 shell integration
[[ -s "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"

# Trunk
# [[ -s "$HOME/.cache/trunk/shell-hooks/zsh.rc" ]] && source "$HOME/.cache/trunk/shell-hooks/zsh.rc"

# Rye
[[ -s "$HOME/.rye/env" ]] && source "$HOME/.rye/env"

# ScaleFT/ASA completions
if [[ -s "$HOME/Library/Application\ Support/ScaleFT/sft_zsh_autocomplete" ]]; then
  export PROG=sft
  source "$HOME/Library/Application\ Support/ScaleFT/sft_zsh_autocomplete"
  unset PROG
fi

# Auto-attach tmux on interactive SSH login
# if command -v tmux >/dev/null 2>&1; then
#   if [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ]; then
#     tmux attach -t main || tmux new -s main
#   fi
# fi
# ---- tmux auto-attach on SSH, session = "<user>@<host>" ----
if command -v tmux >/dev/null 2>&1; then
  if [ -n "$SSH_CONNECTION" ] && [ -z "$TMUX" ] && [ -t 1 ]; then
    host="${HOSTNAME:-$(hostname -s 2>/dev/null || hostname)}"
    user="${USER:-$(id -un)}"
    sess="${user}@${host}"

    # Attach if exists, else create
    tmux has-session -t "$sess" 2>/dev/null \
      && exec tmux attach -t "$sess" \
      || exec tmux new -s "$sess"
  fi
fi

# Just completions
if command -v just >/dev/null 2>&1; then eval "$(just --completions zsh)"; fi

# Micromamba Conda
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !! (not really.. cuz, nix)
__conda_setup="$('$HOME/micromamba/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/micromamba/etc/profile.d/conda.sh" ]; then
        . "$HOME/micromamba/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/micromamba/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
