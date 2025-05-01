export TERM=xterm-256color
export LANG=en_US.UTF-8

source <(kubectl completion zsh)

# AMSTOOL completions
eval "$(_AMSTOOL_COMPLETE=zsh_source amstool)"

# jenv
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# iTerm2 shell integration
[[ -s "$HOME/.iterm2_shell_integration.zsh" ]] && source "$HOME/.iterm2_shell_integration.zsh"

# Trunk
[[ -s "$HOME/.cache/trunk/shell-hooks/zsh.rc" ]] && source "$HOME/.cache/trunk/shell-hooks/zsh.rc"

# UV binary installs to ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# ScaleFT/ASA completions
if [[ -s "$HOME/Library/Application\ Support/ScaleFT/sft_zsh_autocomplete" ]]; then
  export PROG=sft
  source "$HOME/Library/Application Support/ScaleFT/sft_zsh_autocomplete"
  unset PROG
fi