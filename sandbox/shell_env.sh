
shell_identity() {
  # Returns a string repr of the current operating SHELL
  
  # Explanation: ps -o ppid= -p $$ gives you the parent process id of 
  # the current running process ie script
  # env_shell=$( ps -p `ps -o ppid= -p $$` -o comm= )
  # # ps -p...-o comm= tells you the name of the process passed with -p.

  echo $( ps -p `ps -o ppid= -p $$` -o comm= )
}
is_valid_shell() {
  str="$1"
  found=false
  for i in bash zsh
  do 
    echo "$i === $str"
    if [ "$i" = "$str" ] ; then
      found=true
    break
    fi
  done
  echo $found

  return $([ $found = true ] &&  echo 0 || echo 1)
}

is_available() {
  found=false
  for i in zsh bash 
  do 
    if "/usr/bin/env ${i}" "$@"; 
    then
      found=true
      break
    fi
  done
  return $([ $found = true ] &&  echo 0 || echo 1)
}

is_shell() {
  # Accepts a string argument of a name of shell :- Bash, Zsh
  shell_name=${1:-"bash"}
  
  shell_name=$(echo "$shell_name" | tr '[:upper:]' '[:lower:]')
  is_valid=$(is_valid_shell $shell_name )

  result=$([ $(shell_identity) = ${shell_name} ] &&  echo true || echo false)

  echo "${result}"
  return $([ "$(shell_identity)" = "bash" ] &&  echo 0 || echo 1)
}

is_bash() {
  shell_name=${1:-"bash"}
  result=$( is_shell "$shell_name" )

  echo ${result}
  return $([ "$result" = "true" ] &&  echo 0 || echo 1)
}

is_zsh() {
  shell_name=${1:-"zsh"}
  result=$(is_shell shell_name)

  echo ${result}
  return $([ "$result" = "true" ] &&  echo 0 || echo 1)
}
