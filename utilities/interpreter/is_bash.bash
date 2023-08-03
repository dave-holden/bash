


is_bash() {
  shell_name=${1:-"bash"}
  result=$( is_shell "$shell_name" )

  echo ${result}
  return $([ "$result" = "true" ] &&  echo 0 || echo 1)
}