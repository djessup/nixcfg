# Kubectl completions - REMOVED: kubectl plugin in oh-my-zsh already provides this
# source <(kubectl completion zsh)

# AMSTOOL completions - loaded after compinit (oh-my-zsh handles compinit)
if command -v amstool >/dev/null 2>&1; then
  eval "$(_AMSTOOL_COMPLETE=zsh_source amstool)" 2>/dev/null
fi

# Cargo (Rust)
export PATH="$HOME/.cargo/bin:$PATH"

# Go binaries
export PATH="$HOME/go/bin:$PATH"

# jenv - lazy-loaded
# Unset wrapper function before initialization to prevent recursion
_jenv_init() {
  unset -f jenv
  if command -v jenv >/dev/null 2>&1; then
    eval "$(jenv init -)"
  fi
  unfunction _jenv_init 2>/dev/null || true
}
# Trigger on first jenv command
jenv() { _jenv_init; jenv "$@"; }

# Maven home - lazy-loaded
_maven_home() {
  unset -f mvn
  if command -v mvn >/dev/null 2>&1 && [[ -z "$M2_HOME" ]]; then
    export M2_HOME="$(command mvn --home --quiet)"
  fi
  unfunction _maven_home 2>/dev/null || true
}
# Trigger on first mvn command
mvn() { _maven_home; mvn "$@"; }

# NVM - lazy-loaded (saves ~1.2s on startup)
export NVM_DIR="$HOME/.nvm"
# Unset all wrapper functions before loading nvm.sh to prevent circular dependencies
_nvm_init() {
  unset -f nvm node npm npx
  if [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]]; then
    \. "/opt/homebrew/opt/nvm/nvm.sh"
  fi
  unfunction _nvm_init 2>/dev/null || true
}
# Lazy-load on first use of node, npm, npx, or nvm
node() { _nvm_init; node "$@"; }
npm() { _nvm_init; npm "$@"; }
npx() { _nvm_init; npx "$@"; }
nvm() { _nvm_init; nvm "$@"; }

# SDKMAN - lazy-loaded
export SDKMAN_DIR="$HOME/.sdkman"
_sdkman_init() {
  unset -f sdk
  if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
    source "$HOME/.sdkman/bin/sdkman-init.sh"
  fi
  unfunction _sdkman_init 2>/dev/null || true
}
# Trigger on first sdk command
sdk() { _sdkman_init; sdk "$@"; }

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

# Just completions - loaded after compinit (oh-my-zsh handles compinit)
if command -v just >/dev/null 2>&1; then
  eval "$(just --completions zsh)" 2>/dev/null
fi

# Micromamba Conda - lazy-loaded
_conda_init() {
  unset -f conda
  if [[ -z "$CONDA_DEFAULT_ENV" ]]; then
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
  fi
  unfunction _conda_init 2>/dev/null || true
}
# Trigger on first conda command
conda() { _conda_init; conda "$@"; }
