


is_zsh() {
  shell_name=${1:-"zsh"}
  result=$(is_shell shell_name)

  echo ${result}
  return $([ "$result" = "true" ] &&  echo 0 || echo 1)
}
