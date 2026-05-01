rg_replace() {
  local search_term="$1"
  local replace_term="$2"
  local file
  local -a files

  if [[ -z "$search_term" || -z "$replace_term" ]]; then
    echo "Error: Missing arguments."
    echo "Usage: rg_replace <search_term> <replace_term>"
    return 1
  fi

  files=("${(@f)$(rg -l -- "$search_term")}")

  if (( ${#files} == 0 )); then
    echo "No files found containing '$search_term'."
    return 0
  fi

  for file in "${files[@]}"; do
    sed -i '' "s/$search_term/$replace_term/g" "$file"
  done

  echo "Replaced '$search_term' with '$replace_term' in:"
  for file in "${files[@]}"; do
    echo "  $file"
  done
}

git_replace() {
  local search_term="$1"
  local replace_term="$2"

  if [[ -z "$search_term" || -z "$replace_term" ]]; then
    echo "Error: Missing arguments."
    echo "Usage: git_replace <search_term> <replace_term>"
    return 1
  fi

  git grep -lz -- "$search_term" | xargs -0 sed -i '' "s/$search_term/$replace_term/g"

  echo "Replaced '$search_term' with '$replace_term' in tracked files."
}
