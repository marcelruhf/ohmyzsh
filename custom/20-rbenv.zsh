if [[ -o interactive ]] && command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi
