is_shell() {
  # Accepts a string argument of a name of shell :- Bash, Zsh
  
  shell_name=${1:-"bash"}
  
  shell_name=$(echo "$shell_name" | tr '[:upper:]' '[:lower:]')
  is_valid=$(is_valid_shell $shell_name )

  # if  ! $(is_valid_shell $shell_name ) ;
  # then
  #   echo "Error: Invalid shell name passed to 'is_shell' ${shell_name}"
  #   exit 1
  # fi
  result=$([ $(shell_identity) = ${shell_name} ] &&  echo true || echo false)

  echo ${result}
  return $([ "$(shell_identity)" = "bash" ] &&  echo 0 || echo 1)
}
