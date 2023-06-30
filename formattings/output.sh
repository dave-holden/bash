
# Utils / Notifications
msg_clear() {
  # local msg="$1"
  echo -e "${FG_RESET}"
  sleep .5s
}

# This function displays an informational message with a Blue color.
msg_info() {
  local msg="$1"
  echo -e "${FG_BLUE}${msg}${FG_RESET}"
  msg_clear
}

# This function displays a success message with a green color.
msg_ok() {
  local msg="$1"
  echo -e "${FG_CYAN}${msg}${FG_RESET}"
  msg_clear
}

# This function displays an informational message with a Yellow color.
msg_warn() {
  local msg="$1"
  echo -e "${FG_YELLOW}${msg}${FG_RESET}"
  msg_clear
}

# This function displays an error message with a red color.
msg_error() {
  local msg="$1"
  echo -e "${FG_RED}${msg}${FG_RESET}"
  msg_clear
}
