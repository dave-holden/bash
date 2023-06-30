
# Utils / spinners.sh

cursorBack() {
  echo -en "\033[$1D"
}


stop_spinner() {
  tput cnorm
}

grid_spinner() {

  trap stop_spinner SIGINT SIGTERM ERR EXIT
  local PID=$!
  local x=0
  local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
  tput civis

  while kill -0 $PID 2>/dev/null; do
    local x=$(((x + 3) % ${#spin}))
    printf "\r%s" "${spin:$x:3}"
    cursorBack
    sleep .1
  done

  stop_spinner
  wait $PID # capture exit code
  return $?
}

slash_spinner() {
  # trap stop_spinner EXIT
  PID=$!
  local i=1
  local spin="/-\|"
  tput civis

  while kill -0 $PID 2>/dev/null; do
  # echo "A: ${#spin}"
  # echo "B: ((i++))"
    printf "\b${spin:((i++))%${#spin}:1}"
    cursorBack
    sleep .1
  done

  stop_spinner
  wait $PID # capture exit code
  return $?
}
