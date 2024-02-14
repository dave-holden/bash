#!/usr/bin/env sh

example1() {
    # [ -d "${OMZ_HOME}" ] && Logga::Output "Found ${OMZ_HOME}" || Logga::Output "NOT  ${OMZ_HOME}"
  # Logga::Output "install_OMZ"
  # Logga::Print '%s\n' "install_OMZ"
  # Logga::Output "Logga::Output"
  # Logga::Print "Logga::Print"
  # exit
  # thing="$( command -v "zsh" 2>&1 $var > /dev/null )"
  Logga::Output "COLUMNS :: ${COLUMNS}"
  string="dave"
  printf -v test1 "%$(( ( ${COLUMNS} - ${#string}) / 2 ))s\n" "$string"
  Logga::Print "${#test1} - ${#string}"
  Logga::Print "%$(( ( ${COLUMNS} - ${#string} ) / 2 ))s\n" "$string"

  Logga::Across
  # other="${?}"
  Logga::Output "install_OMZ :: LOGGA_TERM_WIDTH : ${LOGGA_TERM_WIDTH}"
  # Logga::Output "install_OMZ :: thing : ${thing}"
  # Logga::Output "install_OMZ :: other : ${other}"

  # remove_OMZ
  # Logga::Left "Logga::Left"
  # Logga::Right "Logga::Right"

  # columns="$(tput cols)"
  # Logga::Output "install_OMZ :: columns : ${columns}"
  Logga::Print '|%.6s|' "ere"

  # Logga::CalcLeftRight "Middle" "${LOGGA_TERM_WIDTH}"
  # Logga::LineCenter "Center"
  # Logga::LineCenter "Center" "LEFT"
  # Logga::LineCenter "Center" "" "RIGHT"

  Logga::CenteredBkUp "Logga::Center"
  Logga::Output " - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -"
  exit 0

}
