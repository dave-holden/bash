
. ./libs/colours.sh
. ./settings/flat.sh

Logga() {

  # Initialize Logga
  LOGGA_IS_DEBUG="${DEBUG:-false}"
  LOGGA_IS_DIAG="${DIAG:-false}"
  LOGGA_IS_DRYRUN="${DRYRUN:-false}"
  LOGGA_SHOW_ICONS="${SHOW_ICONS:-false}"

  # Find the rows and columns
  LOGGA_TERM_WIDTH="$( tput cols )"
  LOGGA_TERM_HEIGHT="$( tput lines )"

  declare -gA LOGGA_LEVELS LOGGA_COLORS LOGGA_ICONS LOGGA_ICONS_ALT

  LOGGA_LEVEL="VERBOSE"
  LOGGA_FILE_LOGGING="${LOGGA_FILE_LOGGING:-true}"

  LOGGA_LEVELS=(
    [FATAL]=0
    [ERROR]=1
    [WARNING]=2
    [SUCCESS]=3
    [INFO]=4
    [HEADER]=5
    [VERBOSE]=6
    [DIAG]=7
    [DEBUG]=9
    [SILENT]=10
    [TOFILE]=11
  )
  LOGGA_ORDER=(
    FATAL
    ERROR
    WARNING
    SUCCESS
    INFO
    HEADER
    VERBOSE
    DIAG
    DEBUG
    SILENT
    TOFILE
  )
  LOGGA_COLORS=(
    [FATAL]="${BOLD}${UNDERLINE}${RED}"
    [ERROR]="${BOLD}${RED}"
    [WARNING]="${BOLD}${YELLOW}"
    [INFO]="${BOLD}${GREEN}"
    [SUCCESS]="${BOLD}${CYAN}"
    [HEADER]="${BOLD}${WHITE}${UNDERLINE}"
    [VERBOSE]="${MAGENTA}"
    [DIAG]="${MAGENTA}"
    [DEBUG]="${BOLD}${MAGENTA}"
    [SILENT]=""
    [TOFILE]=""
  )
  LOGGA_ICONS=(
    [FATAL]="✘"
    [ERROR]="✗"
    [WARNING]="⚠"
    [SUCCESS]="✔"
    [INFO]="ℹ"
    [HEADER]="➽"
    [VERBOSE]="❋"
    [DIAG]="🔍"
    [DEBUG]="🪓"
    [SILENT]="🤫"
    [TOFILE]=""
  )
  # shellcheck disable=SC2034
  LOGGA_ICONS_ALT=(
    [FATAL]="🔥"
    [ERROR]="🚧"
    [WARNING]="🚦"
    [SUCCESS]="🏆"
    [INFO]="ℹ💬"
    [HEADER]="👀"
    [VERBOSE]="📚"
    [DIAG]="🔍"
    [DEBUG]="🪓"
    [SILENT]="🤔"
    [TOFILE]="📎"
  )
  LOGGA_SIGNALS=(
    # EXIT
    ERR
    HUP
    INT
    QUIT
    ABRT
    KILL
    ALRM
    # TERM
  )

  LOGGA_ERROR_CODES=(
    [1]="Catchall for general errors"
    [2]="Misuse of shell builtins"
    [126]="Cannot execute command"
    [127]="Command not found"
    [128]="Invalid argument to exit command"
    # [128+n]="Fatal error signal 'n'"
    # 130	Bash script terminated by Control-C
    # 255*	Exit status out of range
  )
  Logga::Setup
}

Logga::Setup() {
  # Setup vars, traps, screen
  Logga::Diag "Starting Logga::Setup"

  Logga::FlushLogFile

  shopt -s extglob

  if [ "${LOGGA_IS_DEBUG}" = true ]; then
    set -xv
    shopt -s extdebug
  fi

  # # Exit on error. Append '||true' if you expect an error
  set -e  # -o errexit    # Instructs a shell to exit if a command fails, i.e., if it outputs a non-zero exit status
  # # Trap errors in subshells and functions
  set -E  # -o errtrace   # Causes shell functions to inherit the ERR trap.
  set -T  # -o functrace  # Causes shell functions to inherit the DEBUG trap.

  ## The return value of a pipeline is the status of the last command that had a non-zero status upon exit.
  ## If no command had a non-zero status upon exit, the value is zero.                                                                  |
  # # Use last non-zero exit code in a pipeline
  set -o pipefail

  Logga::enableTraps 'Logga::TearDown "${LINENO}" "${BASH_LINENO}" "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}" "${?}"' "${LOGGA_SIGNALS[@]}"

  if [ "${LOGGA_FILE_LOGGING}" = true ]; then
    Logga::Diag "Logging To File Enabled - Info"
  else
    Logga::Diag "Logging To File Disabled - Info"
  fi

  trap '[ "$?" -eq 0 ] || Logga::Output "EXITED :: ${0}"' EXIT

  Logga::RedirectOutput true

  if [ "${LOGGA_IS_DIAG}" = true ] ; then
    # [ "${LOGGA_IS_DEBUG}" = true ] && Logga::Diag "Starting \"${SCRIPT_FILE_BASE}\""
    [ "${LOGGA_IS_DIAG}" = "true" ] && Logga::Diag "Diagnostic set to TRUE" || Logga::Diag "Diagnostic set to FALSE"
    [ "${LOGGA_IS_DRYRUN}" = "true" ] && Logga::Diag "DryRun set to TRUE" || Logga::Diag "DryRun set to FALSE"
    Logga::Output
  fi
}

Logga::ErrorMessage() {
  local errCode=$1
  local desc="${LOGGA_ERROR_CODES[$errCode]}"
  echo "${desc}"
}
Logga::CheckErrors() {
  errCde="${1}"
  errMsg="${2}"
  errCde="${LOGGA_ERROR_CODES[${1}]}"
  Logga::Debug "Logga::CheckErrors :: respCode : ${respCode}"
  Logga::Debug "Logga::CheckErrors :: respMsg  : ${respMsg}"
  Logga::Debug "Logga::CheckErrors :: errCde : ${errCde}"
  # Logga::Output "Logga::CheckErrors :: $ 0 :LINENO: $0"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 1 :BASH_LINENO: $1"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 2 :BASH_COMMAND: $2"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 3 :FUNCNAME: $3"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 4 :ZERO: $4"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 5 :BASH_SOURCE: $5"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 6 : $6"    # $ 0 :: Display
  Logga::Debug "Logga::CheckErrors :: $ F0 : ${FUNCNAME[0]}"
  Logga::Debug "Logga::CheckErrors :: $ F1 : ${FUNCNAME[1]}"
  Logga::Debug "Logga::CheckErrors :: $ F2 : ${FUNCNAME[2]}"
  Logga::Debug "Logga::CheckErrors :: $ L0 : ${LINENO[0]}"
  Logga::Debug "Logga::CheckErrors :: $ L1 : ${LINENO[1]}"
  Logga::Debug "Logga::CheckErrors :: $ L2 : ${LINENO[2]}"
  Logga::Debug "Logga::CheckErrors :: $ B0 : ${BASH_LINENO[0]}"
  Logga::Debug "Logga::CheckErrors :: $ B1 : ${BASH_LINENO[1]}"
  Logga::Debug "Logga::CheckErrors :: $ B2 : ${BASH_LINENO[2]}"
  Logga::Debug "Logga::CheckErrors :2: errCde : ${errCde}" >&2

  if [ "${1}" -ne "0" ]; then
    Logga::Warning "Logga::CheckErrors :: ${2}"
  fi
}

Logga::enableTraps() {
  # Enable errtrace or the error trap handler will not work as expected
  set -o errtrace   # Ensure the error trap handler is inherited
  func="${1}";
  shift
  # assign all traps
  for sig in "${@}"; do
    LOGGA_SIGNALS+=( "${sig}" )
    trap '${func} ${sig}' "${sig}"
  done
}
Logga::disableTraps() {
  # Disable errtrace
  set +o errtrace
  func="${1}";
  shift
  # remove all traps
  for sig in "${@}"; do
    LOGGA_SIGNALS+=( "${sig}" )
    trap - "${sig}"
  done
}
Logga::TearDown() {
  # return 0
  # Logga::disableTraps EXIT ERR HUP INT QUIT ABRT KILL ALRM TERM
  Logga::Debug - "${LOGGA_SIGNALS[@]}"
  Logga::Debug "^"

  # Logga::Output "Logga::TearDown : LOGGA_SIGNALS :${LOGGA_SIGNALS[*]}"
  Logga::Debug
  declare -a params=( "${@}" )
  Logga::Debug "Logga::TearDown : params :: ${#@} -> ${params[*]}"

  Logga::Debug
  sig="${params[-1]}"
  Logga::Debug "Logga::TearDown : sig :: ${#sig} -> >${sig}<"

  signal="${LOGGA_SIGNALS[${sig}]}"
  Logga::Debug "Logga::TearDown : signal :: ${#signal} -> ${signal}"
  Logga::Debug

  # Logga::Output "all :: ${all}"
  # signal="${@[#${all}:-1]}"
  # Logga::Output "signal :: ${signal}"
  # declare -a args
  # args="$@"
  # declare -a args="${@[@]}"
  # declare -a args="$@[@]"

  Logga::Debug
  # declare -a args="${@}"

  # Logga::Output "ARGS :: ${#args} -> ${#args}"
  # for thing in "${@}"; do
  # for param in "$@"; do
  #   Logga::Print '==>%s<==\n' "$param"
  # done
  # Logga::Output
  for thing in "${@}"; do
    Logga::Debug "Logga::TearDown : thing : args : ${thing}"
  done
  Logga::Debug
  for thing in "$!@"; do
    Logga::Debug "Logga::TearDown : thing : args : ${thing}"
  done

  Logga::Debug "Logga::TearDown : $ 0 :LINENO: $0"    # $ 0 :: Display
  Logga::Debug "Logga::TearDown :  $ 1 :BASH_LINENO: $1"    # $ 0 :: Display
  Logga::Debug "Logga::TearDown :  $ 2 :BASH_COMMAND: $2"    # $ 0 :: Display
  Logga::Debug "Logga::TearDown :  $ 3 :FUNCNAME: $3"    # $ 0 :: Display
  Logga::Debug "Logga::TearDown :  $ 4 :ZERO: $4"    # $ 0 :: Display
  Logga::Debug "Logga::TearDown :  $ 5 :BASH_SOURCE: $5"    # $ 0 :: Display
  Logga::Debug "Logga::TearDown :  $ 6 :: $6"    # $ 0 :: Display
  lineNo="${LINENO}"
  Logga::Debug "Logga::TearDown :  lineNo : ${lineNo}"
  bashNo="${BASH_LINENO}"
  Logga::Debug "Logga::TearDown :  bashNo : ${bashNo}"
  bashCmd="${BASH_COMMAND}"
  Logga::Debug "Logga::TearDown :  bashCmd : ${bashCmd}"
  funcName="${FUNCNAME}"
  Logga::Debug "Logga::TearDown :  funcName : ${funcName}"
  thing="${0}"
  Logga::Debug "Logga::TearDown :  thing : ${thing}"
  bashSource="${BASH_SOURCE}"
  Logga::Debug "Logga::TearDown :  bashSource : ${bashSource}"
  Logga::Debug "Logga::TearDown :  $ F0 : ${FUNCNAME[0]}"
  Logga::Debug "Logga::TearDown :  $ F1 : ${FUNCNAME[1]}"
  Logga::Debug "Logga::TearDown :  $ F2 : ${FUNCNAME[2]}"
  Logga::Debug "Logga::TearDown :  $ L0 : ${LINENO[0]}"
  Logga::Debug "Logga::TearDown :  $ L1 : ${LINENO[1]}"
  Logga::Debug "Logga::TearDown :  $ L2 : ${LINENO[2]}"
  Logga::Debug "Logga::TearDown :  $ B0 : ${BASH_LINENO[0]}"
  Logga::Debug "Logga::TearDown :  $ B1 : ${BASH_LINENO[1]}"
  Logga::Debug "Logga::TearDown :  $ B2 : ${BASH_LINENO[2]}"

  [ "${LOGGA_IS_DEBUG}" = true ] && {
    Logga::Padding "="
  }
  # Logga::RestoreOutput
}
Logga::RequiredArgs() {
  if [ "$1" -ne "${2}" ] ; then
    Logga::Fatal "\"${FUNCNAME[1]}\" requires ${1} argument(s), but ${2} supplied :- '${3}'";
    exit 1
  fi
}
Logga::FlushLogFile() {
  [[ -n "${SCRIPT_SERR_FILE}" && ! -d "${SCRIPT_SERR_FILE}" ]] && : > "${SCRIPT_SERR_FILE}"
}
Logga::IsSourced() {
  if [ -n "$ZSH_VERSION" ]; then
    case $ZSH_EVAL_CONTEXT in *:file:*)
      return 0;;
    esac
  else  # Add additional POSIX-compatible shell names here, if needed.
    case ${0##*/} in dash|-dash|bash|-bash|ksh|-ksh|sh|-sh)
      return 0;;
    esac
  fi
  return 1  # NOT sourced.
 }
Logga::IsUrl() {
  Logga::RequiredArgs "1" "${#}" "${*}"
  [ $( echo "${1}" | grep -E '^https.*' ) ] && return 0 || return 1
}
Logga::UrlExists() {
  Logga::RequiredArgs "1" "${#}" "${*}"

  respMsg=$( curl -s -L -o /dev/null -w "%{response_code}" "${1}" )
  respCode="${?}"

  # [ "${LOGGA_IS_DEBUG}" = true ] && {
  #   Logga::Verbose "Logga::UrlExists"
  #   [ "${respCode}" -ne "0" ] && Logga::Output "Logga::UrlExists : respCode : ${respCode} FAILED" || Logga::Output "Logga::UrlExists : respCode : ${respCode} PASSED"
  #   [ "${respMsg}" -ne "200" ] && Logga::Output "Logga::UrlExists : respCode : NOT 200" || Logga::Output "Logga::UrlExists : respCode : EQ 200"
  # }

  # if [ "${respCode}" -ne 0 ] || [ "${respMsg}" -ne "200" ]; then
  #   Logga::Error "in UrlExists : (${respCode}) - ${respMsg}"
  #   return 1
  # fi

  echo "${respMsg}"
  return 0
}
Logga::FolderExists() {
  Logga::RequiredArgs "1" "${#}" "${*}"

  [ -d "${1}" ]
}
Logga::FolderIsEmpty() {
  # Logga::Output "Logga::FolderIsEmpty"
  Logga::RequiredArgs "1" "${#}" "${*}"

  # if [ "$(find "${targetPathName}" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0 ]; then
  #     echo "Directory is empty" >&3
  # else
  #     echo "Directory is not empty" >&3
  # fi
  # [ "$(find "${1}" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0 ] && Logga::Output "EMPTY" || Logga::Output "FULL"
  # [ "$(find "${1}" -mindepth 1 -maxdepth 1 | wc -l)" ]
  [ "$(find "${1}" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0 ]
  # "$(find "${1}" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0
}
Logga::GetRepoName() {
  Logga::RequiredArgs "1" "${#}" "${*}"
  basename "${1}" ".git"
}
Logga::Silent() {
  Logga::Log SILENT "${@}"
}
Logga::ToFile() {
  type="${1:-TOFILE}"
  shift
  Logga::Log ${type} "${@}"
}
Logga::Fatal() {
  Logga::Log Fatal "${@}"
}
Logga::Error() {
  Logga::Log ERROR "${@}"
}
Logga::Warning() {
  Logga::Log WARNING "${*}"
}
Logga::Success() {
  Logga::Log SUCCESS "${@}"
  Logga::Output
}
Logga::Info() {
  Logga::Log Info "${*}"
}
Logga::Header() {
  Logga::Log HEADER "${@}"
  Logga::Output
}
Logga::Verbose() {
  Logga::Log VERBOSE "${@}"
}
Logga::Diag() {
  if [ "${LOGGA_IS_DIAG}" = "true" ]; then
    Logga::Log Diag "${@}"
  fi
}
Logga::Debug() {
  if [ "${LOGGA_IS_DEBUG}" = "true" ]; then
    Logga::Log Debug "${@}"
  fi
}
Logga::Log() {
  Logga::RequiredArgs "2" "${#}" "${@}"

  local passedType="${1}"
  local logMsg="${2}"
  local customType="${3}"

  local curLevel curType logLevel

  logLevel="${LOGGA_LEVELS[${LOGGA_LEVEL}]}"
  curType=$( echo "${passedType}" | tr '[:lower:]' '[:upper:]' )
  curLevel="${LOGGA_LEVELS[${curType}]}"

  if [ "${curLevel}" -le "${logLevel}" ]; then
    Logga::ToConsole "${logMsg}"
  elif [ "${curLevel}" -eq ${LOGGA_LEVELS[DIAG]} ] && [ "${LOGGA_IS_DIAG}" = "true" ]; then
    Logga::ToConsole "${logMsg}"
  elif [ "${curLevel}" -eq ${LOGGA_LEVELS[DEBUG]} ] && [ "${LOGGA_IS_DEBUG}" = "true" ]; then
    Logga::ToConsole "${logMsg}"
  fi

  logMsg="$(echo -e "${logMsg}" | tr -c -s '[:alnum:][:blank:][=]' ' ' | sed -e 's/^[[:space:]]*//')"
  Logga::ToLogFile "${logMsg}"
}
Logga::ToLogFile() {
  local logDate
  logDate="$(date "${SCRIPT_LOG_FORMAT:---iso-8601=seconds}")"

  printf -v typeStyled "[ %-$( Logga::MaxLevelNameLength )s%*s ]" "${curType}"

  local logOutput="${logDate} ${typeStyled} ${logMsg}"

  echo "${logOutput}" >> "${SCRIPT_SERR_FILE}"
}
Logga::ToConsole() {
  local curColor="${LOGGA_COLORS[${curType}]}"
  LOGGA_LEVEL_LENGTH=$( Logga::MaxLevelNameLength )

  if [ "${LOGGA_SHOW_ICONS}" = true ]; then
    curIcon="${LOGGA_ICONS[${curType}]}"
    width=$(( "${LOGGA_LEVEL_LENGTH}" + (${#curColor} * 2) + (${#NORMAL} * 2) + (${#curIcon} * 2 ) + 2 ))
    printf -v typeStyled "[ %-${width}s%*s ] %s" "${curColor}${curIcon}${NORMAL} ${curColor}${curType}${NORMAL}"
  else
    width=$(( "${LOGGA_LEVEL_LENGTH}" + "${#curColor}" + "${#NORMAL}" ))
    printf -v typeStyled "[ %-${width}s%*s ] %s" "${curColor}${curType}${NORMAL}"
  fi
  Logga::Output "${typeStyled} ${logMsg}"
}

Logga::CmdExists() {
  cmd="${1}"
  defaultValue=127        # Error code for missing command
  found="${defaultValue}"

  # if command -v $cmd >/dev/null 2>&1 ; then
  # if command -v -- "$cmd" > /dev/null 2>&1; then
  #   # found=0
  #   echo "0"
  #   return
  # fi

  if type -- $cmd > /dev/null 2>&1 ; then
  # Logga::Output "COMMAND NOT FOUND"
    # found=0
    echo "0"
    return
  # else
    # Logga::Output "COMMAND NOT FOUND"
  fi

  # if hash "${cmd}" > /dev/null 2>&1 ; then
  #   # found=0
  #   echo "0"
  #   return
  # fi

  # if typeset -f "${cmd}" > /dev/null 2>&1 ; then
  #   # found=0
  #   echo "0"
  #   return
  # fi

  echo "${found}"
}
Logga::ServiceExists() {
  printf "ServiceExists"
}
Logga::ExecCmd() {
  local cmd="${1}";

  errCode=$( Logga::CmdExists "${cmd}" )

  if [ "${errCode}" -eq "0" ] ; then

    if [ $LOGGA_IS_DRYRUN = "true" ]; then
      Logga::Info "Dryrun command: ${cmd} ${options}"
      sleep 3 &
      Logga::ShowSpinner $!

    else
      respMsg="$( eval "${*}" > /dev/null 2>&1 )"
      respCode="${?}"

      if [ "${respCode}" -ne "0" ] ; then
        # echo "${respMsg}" >&2
        # Logga::ToFile "${respMsg}"
        Logga::Error "respMsg :: ${respMsg}"
        return "${respCode}"
      fi
    fi
  else
    errMsg="$( Logga::ErrorMessage $errCode )"
    Logga::Fatal "${errMsg} : '$cmd'"
    return 1
  fi
}
Logga::Join() {
  local sep="$1"; shift
	local out
  printf -v out "${sep//%/%%}%s" "$@"
	echo "${out#$sep}"
}

Logga::MaxLevelNameLength() {
  printf "%s\n" "${LOGGA_ORDER[@]}" | wc -L
}

# Spinners
Logga::CursorBack() {
  printf -v msg '%b' "\033[${1:-1}D" # move the cursor back $1 places, default 1
  Logga::Terminal "${msg}"
}
Logga::HideCursor() {
  printf -v msg '%b' "\033[?25l"  # hides the cursor
  Logga::Terminal "${msg}"
}
Logga::ShowCursor() {
  printf -v msg '%b' "\033[?25h"  # show the cursor
  Logga::Terminal "${msg}"
}
Logga::ClearLine() {
  # \033[<N>A - Move the cursor up N lines
  # \033[K    - Erase to end of line
  printf -v msg '%b' "\033[1A\33[K"
  # printf -v msg '%b%b' "\033[1A" "\33[2K"
  Logga::Terminal "${msg}"
}
Logga::PositionLeft() {
  tput hpa 0  >&3
  # clear to end of line
  # tput el &> $(tty)
  tput el >&3
}
Logga::ResetLine() {
  # tput hpa 0 &> $(tty)
  tput hpa 0  >&3
  # clear to end of line
  # tput el &> $(tty)
  tput el >&3
  Logga::Terminal "${*}"
}
Logga::ClearScreen() {
  Logga::Output "Logga::ClearScreen"
  # \033 stands for ESC (ANSI value 27).
  # ESC [ is a kind of escape sequence called Control Sequence Introducer (CSI).
  # CSI commands starts with ESC[ followed by zero or more parameters.
  # \033[H (ie, ESC[H) and \033[J are CSI codes.
  # \033[H moves the cursor to the top left corner of the screen (ie, the first column of the first row in the screen).
  # and
  # \033[J clears the part of the screen from the cursor to the end of the screen.
}
Logga::SlashSpinner() {
  # Logga::Terminal "Logga::SlashSpinner"
  # trap Logga::StopSpinner EXIT
  PID=$!
  local i=1
  local spin="/-\|"
  # Logga::Terminal "Logga::SlashSpinner - ${spin}"

  Logga::HideCursor
  # Logga::Terminal "Running... "

  while kill -0 $PID 2>/dev/null; do
    Logga::Print "${spin:((i++))%${#spin}:1}"
    Logga::CursorBack 1
    sleep .1
  done

  Logga::ShowCursor
  Logga::Output "Done!"

  wait $PID # capture exit code
  return $?
}
Logga::GridSpinner() {
  # trap stop_spinner SIGINT SIGTERM ERR EXIT
  # Logga::Display "Logga::GridSpinner :: ${1} --- ${2} << ${!}"
  # Logga::Terminal "Logga::GridSpinner"
  local PID=$!
  local x=0
  local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
  # local msg="${}"
  # startMsg="${1:-Running... }"
  # endMsg="${2:-Done!}"
  startMsg="${1}"
  endMsg="${2}"

  Logga::HideCursor
  Logga::Print "${startMsg}"
  while kill -0 $PID 2>/dev/null; do
    local x=$(((x + 3) % ${#spin}))
    # thing="${spin:$x:3}"
    output="${YELLOW}${spin:$x:3}${NORMAL}"
    # Logga::Print "${spin:$x:3}"
    # Logga::Print "${YELLOW}${spin:$x:3}${NORMAL}"
    length=$(( "${#output} + ${#startMsg}" + "1"))
    # Logga::Output "calc :: ${#output} + ${#startMsg} = ${length} - ${output}"
    Logga::Print "${output}"
    Logga::CursorBack 1
    # Logga::CursorBack "${length}"
    # Logga::PositionLeft
    sleep .1
  done

  Logga::ShowCursor
  Logga::Output "${endMsg}"
  # sleep  &
  Logga::ClearLine

  wait $PID # capture exit code
  return $?
}
# shellcheck disable=SC2034
Logga::MoonSpinner() {
  emoji_new_moon=🌑
  emoji_waxing_crescent_moon=🌒
  emoji_first_quarter_moon=🌓
  emoji_waxing_gibbous_moon=🌔
  emoji_full_moon=🌕
  emoji_waning_gibbous_moon=🌖
  emoji_last_quarter_moon=🌗
  emoji_waning_crescent_moon=🌘
}
Logga::ShowSpinner() {
  startMsg="${1:-Starting...}"
  endMsg="${2:-Ended!}"
  # Logga::Display "Logga::ShowSpinner :: ${1} : ${2} > "
  # Logga::SlashSpinner "${1}"
  # Logga::SlashSpinner "${1}" "${2}"
  Logga::GridSpinner "${1}" "${2}"
  # Logga:: "${*}"
}

# Output
Logga::Display() {
  # Seperate 'output' method for testing
  #  || -p /dev/stdout
  # determine if a "format" parameter was passed in or not
  # generate the text var
  if [ "${#}" -ge "2" ]; then
    format="${1}"
    shift
    printf -v msg "${format}" "${*}"
  else
    printf -v msg "${*}"
  fi
  # Output text var to respsecitve File Descriptor
  if [[ -t "3" ]] ; then
    printf '%s' "${msg}" >&3
  else
    printf '%s' "${msg}"
  fi
}
Logga::Terminal() {
  # Output text var to respsecitve File Descriptor

  # if [[ -t "3" || -p /dev/stdin ]] ; then
  #   printf '%s' "${*}" >&3
  # else
  #   printf '%s' "${*}"
  # fi
  printf '%s' "${*}" >&$(tty)
}
Logga::Print() {
  # determine if a "format" parameter was passed in or not
  # generate the text var
  # echo "MAIN" >&$(tty)
  if [ "${#}" -ge "2" ]; then
    format="${1}"
    shift
    printf -v msg "${format}" "${*}"
  else
    printf -v msg '%s' "${*}"
  fi
  Logga::Terminal "${msg}"
}
Logga::Output() {
  Logga::Print "%s\n" "${*}"
}
Logga::TestFDs() {
  Logga::Display "Logga::TestFDs"
  for i in {0..5}
  do
    [ -t "${i}" ] && Logga::Display "${i} Open" || Logga::Display "${i} Closed"
  done
}


# Formatting
Logga::Padding() {
  local padChar="${1:- }"
  local padLen="${2:-${LOGGA_TERM_WIDTH}}"

  for ((i = "${3:-1}" ; i <= "${padLen}" ; i++)); do
    Logga::Terminal "${padChar}"
  done
}

Logga::RedirectOutput() {
  if "${1}" ; then
    Logga::Debug "Logga::RedirectOutput - ACTIVE\n"
    # redirect
    exec 3>&1 4>&2 1>"${SCRIPT_SERR_FILE}" 2>/dev/null
    stty -icanon time 0 min 0
  else
    Logga::Debug "Logga::RedirectOutput - INACTIVE\n"
  fi
}
Logga::RestoreOutput() {
  echo "Logga::RestoreOutput"
  if [[ -t "3" || -p /dev/stdin ]]; then
    Logga::Output "Logga::RestoreOutput in TERMINAL"
    # restore
    exec 1>&3 2>&4
    stty sane
  fi
}

# Logga::CloneRepoX() {
#   all="${*}"
#   Logga::Output "Logga::CloneRepo :ALL 1 : ${all}"

#   local sourceURL="${1}";
#   local targetFolder="${2}"
# }

# Logga::ReadKey() {
#     read -t5 -n1 -r -p 'Press any key or wait five seconds...' key
#     if [ "$?" -eq "0" ]; then
#         echo 'A key was pressed.'
#     else
#         echo 'Five seconds passed. Continuing...'
#     fi
# }
Logga::ExecuteX() {
  all="${*}"

  local cmd="${1}";
  shift
  options="${*}"

  errormessage=$( eval "${cmd} ${options}" 2>&1 $var > /dev/null )

  result="${?}"
}
Logga::RepoExistsX() {
  all="${*}"

  local cmd="${1}";
  shift
  options="${*}"

  errCode=$( Logga::CmdExists "${cmd}" )

  if [ "${errCode}" -eq "0" ] ; then

    if [ $LOGGA_IS_DRYRUN = "true" ]; then

      Logga::Info "Dryrun command: ${cmd} ${options}"

    else

      errorMessage=$(curl -s -w '%{http_code}' "${all}" -o /dev/null )
      result="${?}"

      [ "${result}" -eq 0 ] && Logga::Output "Logga::RepoExists : Result Is Zero" || Logga::Output "Logga::RepoExists : Result Is NOT Zero"

      if [ ${errorMessage} -eq 200 ]; then
        Logga::Output $errorMessage
      else
        Logga::Output "${errormessage}"
      fi
    fi
  else
    errMsg="$( Logga::ErrorMessage $errCode )"
    Logga::Fatal "${errMsg} : '$cmd'"
  fi
}
