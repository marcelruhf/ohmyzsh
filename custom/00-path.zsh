typeset -U path PATH
export BUN_INSTALL="$HOME/.bun"
path=(
  "$HOME/.rd/bin"
  "$HOME/.git-ai/bin"
  "$HOME/.local/bin"
  "$BUN_INSTALL/bin"
  $path
)
