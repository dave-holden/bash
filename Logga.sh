
. ./libs/colours.sh
. ./settings/flat.sh

Logga() {

  LOGGA_NEWLINE="\n"
  # Initialize Logga
  LOGGA_IS_DEBUG="${DEBUG:-false}"
  LOGGA_IS_DIAG="${DIAG:-false}"
  LOGGA_IS_DRYRUN="${DRYRUN:-false}"
  LOGGA_SHOW_ICONS="${SHOW_ICONS:-false}"

  # Find the rows and columns
  LOGGA_TERM_WIDTH="$( tput cols )"
  LOGGA_TERM_HEIGHT="$( tput lines )"

  LOGGA_PAGE_WIDTH="${1:-80}"

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
    EXIT
    ERR
    HUP
    INT
    QUIT
    ABRT
    KILL
    # ALRM
    # TERM
  )
  LOGGA_ERROR_CODESx=(
    [1]="Catchall for general errors"
    [2]="Misuse of shell builtins"
    [126]="Cannot execute command"
    [127]="Command not found"
    [128]="Invalid argument to exit command"
    # [128+n]="Fatal error signal 'n'"
    # 130	Bash script terminated by Control-C
    # 255*	Exit status out of range
  )
  LOGGA_ERROR_CODES=(
    # https://itsfoss.com/linux-exit-codes/
    [0]="Command executed with no errors"
    [1]="Catchall for general errors"
    [2]="Incorrect command (or argument) usage"
    [126]="Permission denied (or) unable to execute"
    [127]="Command not found, or PATH error"
    [128]="Invalid argument to exit command"
    # [128+n]="Fatal error signal 'n'"
    [130]="Termination by Ctrl+C or SIGINT"
    [137]="The SIGKILL signal kills the process instantly"
    [143]="SIGTERM a process is killed without specifying arguments"
    # 130	Bash script terminated by Control-C

  # 255*	Exit status out of range
  )
  Logga::Setup
}

Logga::Setup() {
  # Setup vars, traps, screen
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
  set -u  # -o nounset    # Treats unset or undefined variables as an error when substituting
                          # (during parameter expansion). Does not apply to special parameters
                          # such as wildcard **`*`** or **`@`**.                                                                 |

  ## The return value of a pipeline is the status of the last command that had a non-zero status upon exit.
  ## If no command had a non-zero status upon exit, the value is zero.                                                                  |
  # # Use last non-zero exit code in a pipeline
  set -o pipefail

  set -Eeuo pipefail

  Logga::EnableTraps 'Logga::ErrorHandler'

  Logga::Diag "Starting Logga::Setup"

  Logga::FlushLogFile

  if [ "${LOGGA_FILE_LOGGING}" = true ]; then
    Logga::Diag "Logging To File Enabled - Info"
  else
    Logga::Diag "Logging To File Disabled - Info"
  fi

  LOGGA_REDIRECT_OUTPUT="${REDIRECT_OUTPUT:-false}"
  # echo "LOGGA_REDIRECT_OUTPUT :: ${LOGGA_REDIRECT_OUTPUT}" >& $( tty )

  Logga::RedirectOutput "${LOGGA_REDIRECT_OUTPUT}"

  if [ "${LOGGA_IS_DIAG}" = true ] ; then
    # [ "${LOGGA_IS_DEBUG}" = true ] && Logga::Diag "Starting \"${SCRIPT_FILE_BASE}\""
    [ "${LOGGA_IS_DIAG}" = "true" ] && Logga::Diag "Diagnostic set to TRUE" || Logga::Diag "Diagnostic set to FALSE"
    [ "${LOGGA_IS_DRYRUN}" = "true" ] && Logga::Diag "DryRun set to TRUE" || Logga::Diag "DryRun set to FALSE"
    Logga::Output
  fi
}

Logga::GetErrorMessage() {
  errorCode="${1}"
  local errorDesc="${LOGGA_ERROR_CODES[${errorCode}]}"
  echo "${errorDesc}"
}
Logga::ErrorHandler() {
  # file_name="${0}"
  signal="${1}"
  status="${2}"
  Logga::Print "%-20s %s\n" "status" ":: ${status}"
  Logga::Output "Logga::ErrorHandler : 0 : ${status} - STATUS"
  error_msg=$( Logga::GetErrorMessage "${status}" )
  line_no="${3}"
  bash_line_no="${4}"
  command="${5}"
  function_name="${6}"
  source_file="${7}"
  file="${8}"
  Logga::Print "%-20s %s\n" "error_msg :: ${error_msg}"
  Logga::Print "%-20s %s\n" "line_no" ":: ${line_no}"
  Logga::Print "%-20s %s\n" "bash_line_no" ":: ${bash_line_no}"
  Logga::Print "%-20s %s\n" "command" ":: ${command}"
  Logga::Print "%-20s %s\n" "function_name" ":: ${function_name}"
  Logga::Print "%-20s %s\n" "source_file" ":: ${source_file}"
  Logga::Print "%-20s %s\n" "file" ":: ${file}"
  Logga::Output ""
  Logga::Output "Logga::ErrorHandler : 0 : ${0} - FILE"

  Logga::Output "Logga::ErrorHandler : 1 : ${1} - SIGNAL CODE"
  Logga::Output "Logga::ErrorHandler : 2 : ${2} - EXIT CODE"
  Logga::Output "Logga::ErrorHandler : 3 : ${3} - LINENO[*] - The line number in the script or shell function currently executing"
  Logga::Output "Logga::ErrorHandler : 4 : ${4} - BASH_LINENO - is the line number in the source file"
  Logga::Output "Logga::ErrorHandler : 5 : ${5} - BASH_COMMAND - command currently being executed or about to be executed, unless the shell is executing a command as the result of a trap"
  Logga::Output "Logga::ErrorHandler : 6 : ${6} - FUNCNAME[*] - array variable containing the names of all shell functions currently in the execution call stack"
  Logga::Output "Logga::ErrorHandler : 7 : ${7} - BASH_SOURCE - source filenames where"
  Logga::Output "Logga::ErrorHandler : 8 : ${8} - FILE"

  Logga::DisableTraps
}

Logga::EnableTraps() {
  # Enable errtrace or the error trap handler will not work as expected
  set -o errtrace   # Ensure the error trap handler is inherited

  params='${?} ${LINENO[*]} ${BASH_LINENO} ${BASH_COMMAND} ${FUNCNAME[*]} ${BASH_SOURCE[0]} ${0}'

  func="${1}"

  for signal in "${LOGGA_SIGNALS[@]}"; do
    trap "${func} ${signal} ${params}" "${signal}"
  done
}
Logga::DisableTraps() {
  # echo "Logga::DisableTraps :: " >& $( tty )

  # Disable errtrace
  set +o errtrace

  for sig in "${LOGGA_SIGNALS[@]}"; do
    # echo "Logga::DisableTraps :: sig : ${sig}" >& $( tty )
    trap - "${sig}"
  done
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
    Logga::Output "${typeStyled} ${logMsg}"
  elif [ "${curType}" = "HEADER" ]; then
    echo "Logga::ToConsole" >& $( tty )
    Logga::LineCenter "${logMsg}" "#" "#" " "
  else
    width=$(( "${LOGGA_LEVEL_LENGTH}" + "${#curColor}" + "${#NORMAL}" ))
    printf -v typeStyled "[ %-${width}s%*s ] %s" "${curColor}${curType}${NORMAL}"
    Logga::Output "${typeStyled} ${logMsg}"
  fi

}

Logga::CmdExists() {
  cmd="${1}"
  defaultValue=127        # Error code for missing command
  found="${defaultValue}"

  if command -v $cmd >/dev/null 2>&1 ; then
  # if command -v -- "$cmd" > /dev/null 2>&1; then
    # found=0
    echo "0"
    return
  fi

  echo "${found}"
}
Logga::TestError() {
  Logga::Output "Logga::TestError"
  # thing=$( echo (( 0 / 1 )) )
  thing=$( (( 0 / 1 )) )
  err="${?}"
  Logga::Output "Logga::TestError :: thing : ${thing}"
  Logga::Output "Logga::TestError :: err : ${err}"
  result=$(( 0 / 1))
  Logga::Output "Logga::TestError :: result :1: ${result}"
  result=$(( 1 / 0 ))
  Logga::Output "Logga::TestError :: result :2: ${result}"
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
        echo "${respMsg}"
        return "${respCode}"
      fi
    fi
  else
    errMsg="$( Logga::GetErrorMessage $errCode )"
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
  # tput hpa 0  >&3
  tput hpa 0 &> $(tty)
  # clear to end of line
  tput el &> $(tty)
  # tput el >&3
}
Logga::ResetLine() {
  tput hpa 0 &> $(tty)
  # tput hpa 0  >&3
  # clear to end of line
  tput el &> $(tty)
  # tput el >&3
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

  # Logga::SlashSpinner "${1}"
  # Logga::SlashSpinner "${1}" "${2}"
  Logga::GridSpinner "${1}" "${2}"
  # Logga:: "${*}"
}

Logga::hasTerm() {
  local terms="$1"
  shift

  for term in $terms; do
    for arg; do

      if [[ $arg == "$term" ]]; then
        # echo "yes"
        return 0
      fi
    done
  done
  return 1
}

Logga::Contains() {
  thing="${1}"
  value="${2}"

  # str='some text with @ in it'
  # if [[ $str == *['!'@#\$%^\&*()_+]* ]]
  # then
  #   echo "It contains one of those" >& $( tty )
  # fi

  # value=88.90%
  # thing=*[%]*

  case $value in
    "${thing}")
      echo "${value} found in thing ${thing}"
    ;;
    *[!%.0123456789]* | *%*%* | *.*.*) ;;
    ?*%) echo matches >& $( tty ) ;;
  esac
}
# Output
Logga::Outputv2() {
  Logga::Print "%s\n" "${*}"
}

Logga::Print() {

  [[ "${BASHPID}" -eq "${$}" ]] && local in_subshell=false || local in_subshell=true
  if Logga::hasTerm '-v --verbose' "${@}" ; then

    local flag="${1}"
    declare -n var_name=$2
    shift 2

    if [[ "${#@}" -gt "1" && "${*}" == *"%"* ]]; then
      local format="${1}"
      shift
    else
      local format="%s"
    fi
    local string=( "${@}" )
    printf $flag var_name "${format}" "${string[@]}"
    # echo "${var_name}"
  else
    if [[ "${#@}" -gt "1" && "${*}" == *"%"* ]]; then
      local format="${1}"
      shift
    else
      local format="%s"
    fi
    local string=( "${@}" )

    if "${in_subshell}" ; then
      printf "${format}" "${string[@]}"
    else
      printf "${format}" "${string[@]}" >& "$( tty )"
    fi
  fi
}

Logga::Terminal() {
  # Output text var to respsecitve File Descriptor
  # printf '%s' "${*}" >& "$(tty)"
  Logga::Print "${@}"
}
Logga::Output() {
  Logga::Print "%s\n" "${@}"
}
# Formatting
Logga::Padding() {
  local char="${1:- }"
  local length="${2:-${LOGGA_PAGE_WIDTH}}"
  local start="${3:-1}"
  local padding
  printf -v padding -- "%0.s${char}" $(seq $start $length)
  # Logga::Print "%s\n" "${padding}"
  # Logga::Terminal "${padding}"
  # Logga::Output "${padding}"
  echo "${padding}"
}

Logga::LineCenter() {
  echo "Logga::LineCenter" >& $( tty )
  local msg="${1}"
  local prefix="${2}"
  local suffix="${3}"
  local max_width="${4:-${LOGGA_PAGE_WIDTH}}"
  local char="${5:- }"


  termMsgWidth=$(( "${max_width}" - ( "${#prefix}" + "${#msg}" + "${#suffix}"  ) -4 ))
  termWidthLeft="$(( ${termMsgWidth} / 2 ))"
  termWidthRight="$(( ${termMsgWidth} - ${termWidthLeft} ))"

  # totalCalc="$(( ${#prefix} + ${termWidthLeft} + ${#msg} + ${termWidthRight} + ${#suffix} ))"

  termWidthLeftPad=$( Logga::Padding "${char}" "${termWidthLeft}")
  termWidthRightPad=$( Logga::Padding "${char}" "${termWidthRight}")

  printf -v msg "%s %s %s %s %s\n"  "$prefix" "${termWidthLeftPad}" "${msg}" "${termWidthRightPad}" "${suffix}"

  logga::Terminal "${msg}"
}

Logga::TestFDs() {
  Logga::Output "Logga::TestFDs"
  for i in {0..5}
  do
    [ -t "${i}" ] && Logga::Display "${i} Open" || Logga::Display "${i} Closed"
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
Logga::ServiceExists() {
  printf "ServiceExists"
  # $( (sudo systemctl is-active docker ) 2>&1
}

Logga::RepoExists() {
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
    errMsg="$( Logga::GetErrorMessage $errCode )"
    Logga::Fatal "${errMsg} : '$cmd'"
  fi
}
