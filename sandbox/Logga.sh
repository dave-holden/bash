

. ./BASH/formatting/colours.sh
. ./Script/settings/flat.bash

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
  fi

  # if [ -v DEBUGGER ]; then
  #   shopt -s extdebug
  # else
    # # Exit on error. Append '||true' if you expect an error
    set -e  # -o errexit    # Instructs a shell to exit if a command fails, i.e., if it outputs a non-zero exit status
    # # Trap errors in subshells and functions
    set -E  # -o errtrace   # Causes shell functions to inherit the ERR trap.
    set -T  # -o functrace  # Causes shell functions to inherit the DEBUG trap.

    ## The return value of a pipeline is the status of the last command that had a non-zero status upon exit.
    ## If no command had a non-zero status upon exit, the value is zero.                                                                  |
    # # Use last non-zero exit code in a pipeline
    set -o pipefail
  # fi

  Logga::Diag "LOGGA_FILE_LOGGING :: ${LOGGA_FILE_LOGGING}"

  # Logga::Traps 'Logga::TearDown "${LINENO}" "${BASH_LINENO}" "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}" "${?}"' EXIT HUP INT QUIT ABRT KILL ALRM TERM
  # EXIT ERR HUP INT QUIT ABRT KILL ALRM TERM
  Logga::Output "LOGGA_SIGNALS :: ${LOGGA_SIGNALS[*]}"
  Logga::enableTraps 'Logga::TearDown "${LINENO}" "${BASH_LINENO}" "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}" "${?}"' "${LOGGA_SIGNALS[@]}"

  if [ "${LOGGA_FILE_LOGGING}" = true ]; then
    Logga::Diag "Logging To File Enabled - Info"
  else
    Logga::Diag "Logging To File Disabled - Info"
    # # Logga::Traps 'Logga::TearDown "${LINENO}" "${BASH_LINENO}" "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}" "${?}"' EXIT HUP INT QUIT ABRT KILL ALRM TERM
    # Logga::enableTraps 'Logga::TearDown "${LINENO}" "${BASH_LINENO}" "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}" "${?}"' EXIT ERR HUP INT QUIT ABRT KILL ALRM TERM
  fi

  # trap '[ "$$" != "$BASHPID" ] && Logga::Output "Script running in background" || Logga::Output "Script running in foreground"' SIGINT
  # trap 'Logga::Output "$(date): Script exited"' EXIT # >> /var/log/myscript.log
  trap '[ "$?" -eq 0 ] || Logga::Output "EXITED :: ${0}"' EXIT

  # Logga::RedirectOutput false
  # Logga::RedirectOutput true

  # unset killed_by
  # trap 'killed_by=INT;exit' INT
  # trap 'killed_by=TERM;exit' TERM
  # trap '
  #   ret=$?
  #   if [ -n "$killed_by" ]; then
  #     echo >&2 "Ouch! Killed by $killed_by"
  #     exit 1
  #   elif [ "$ret" -ne 0 ]; then
  #     echo >&2 "Died with error code $ret"
  #   fi' EXIT

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
  Logga::Output "Logga::CheckErrors :: errCde : ${errCde}"
  Logga::Output "Logga::CheckErrors :: errMsg : ${errMsg}"
  # exit "${errCde}"
  exit 127
  errCde="${LOGGA_ERROR_CODES[${1}]}"
  Logga::Output "Logga::CheckErrors :: respCode : ${respCode}"
  Logga::Output "Logga::CheckErrors :: respMsg  : ${respMsg}"
  Logga::Output "Logga::CheckErrors :: errCde : ${errCde}"
  # Logga::Output "Logga::CheckErrors :: $ 0 :LINENO: $0"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 1 :BASH_LINENO: $1"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 2 :BASH_COMMAND: $2"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 3 :FUNCNAME: $3"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 4 :ZERO: $4"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 5 :BASH_SOURCE: $5"    # $ 0 :: Display
  # Logga::Output "Logga::CheckErrors :: $ 6 : $6"    # $ 0 :: Display
  Logga::Output "Logga::CheckErrors :: $ F0 : ${FUNCNAME[0]}"
  Logga::Output "Logga::CheckErrors :: $ F1 : ${FUNCNAME[1]}"
  Logga::Output "Logga::CheckErrors :: $ F2 : ${FUNCNAME[2]}"
  Logga::Output "Logga::CheckErrors :: $ L0 : ${LINENO[0]}"
  Logga::Output "Logga::CheckErrors :: $ L1 : ${LINENO[1]}"
  Logga::Output "Logga::CheckErrors :: $ L2 : ${LINENO[2]}"
  Logga::Output "Logga::CheckErrors :: $ B0 : ${BASH_LINENO[0]}"
  Logga::Output "Logga::CheckErrors :: $ B1 : ${BASH_LINENO[1]}"
  Logga::Output "Logga::CheckErrors :: $ B2 : ${BASH_LINENO[2]}"
  echo "Logga::CheckErrors :2: errCde : ${errCde}" >&2

  if [ "${1}" -ne "0" ]; then
    Logga::Warning "Logga::CheckErrors :: ${2}"
  fi
}

Logga::enableTraps() {
  # Enable errtrace or the error trap handler will not work as expected
  set -o errtrace   # Ensure the error trap handler is inherited
  func="${1}";
  shift
  for sig in "${@}"; do
    LOGGA_SIGNALS+=( "${sig}" )
    trap '${func} ${sig}' "${sig}"
  done
}
Logga::disableTraps() {
  set +o errtrace
  func="${1}";
  shift
  for sig in "${@}"; do
    LOGGA_SIGNALS+=( "${sig}" )
    trap - "${sig}"
  done
}
Logga::TearDown() {
  return 0
  # Logga::disableTraps EXIT ERR HUP INT QUIT ABRT KILL ALRM TERM
  Logga::disableTraps - "${LOGGA_SIGNALS[@]}"
  Logga::Padding "^"

  # Logga::Output "Logga::TearDown : LOGGA_SIGNALS :${LOGGA_SIGNALS[*]}"
  Logga::Output
  declare -a params=( "${@}" )
  Logga::Output "Logga::TearDown : params :: ${#@} -> ${params[*]}"

  Logga::Output
  sig="${params[-1]}"
  Logga::Output "Logga::TearDown : sig :: ${#sig} -> >${sig}<"

  signal="${LOGGA_SIGNALS[${sig}]}"
  Logga::Output "Logga::TearDown : signal :: ${#signal} -> ${signal}"
  Logga::Output

  # Logga::Output "all :: ${all}"
  # signal="${@[#${all}:-1]}"
  # Logga::Output "signal :: ${signal}"
  # declare -a args
  # args="$@"
  # declare -a args="${@[@]}"
  # declare -a args="$@[@]"

  Logga::Output
  # declare -a args="${@}"

  # Logga::Output "ARGS :: ${#args} -> ${#args}"
  # for thing in "${@}"; do
  # for param in "$@"; do
  #   Logga::Print '==>%s<==\n' "$param"
  # done
  # Logga::Output
  for thing in "${@}"; do
    Logga::Output "Logga::TearDown : thing : args : ${thing}"
  done
  Logga::Output
  for thing in "$!@"; do
    Logga::Output "Logga::TearDown : thing : args : ${thing}"
  done

  # # argsLen="${#@}"
  # # Logga::Output "ARGS :: ${argsLen} -> ${args}"
  # # for(( i=0; i<argsLen; i++ )); do
  # #   Logga::Output "Other :: ${i}"
  # # done
  # # for i in ${!@[@]}; do
  # #   Logga::Output "element $i is ${@[$i]}"
  # # done

  # all="${*}"
  # Logga::Output "TearDown : all : ${#all} :: ${all}"
  # # signal="${0[@]: -1}"
  # # Logga::Output "TearDown : signal : ${signal}"

  #   # for i in {0..5}
  # # for ((i = "${3:-1}" ; i <= "${padLen}" ; i++)); do
  # for thing in "${@}"; do
  #   Logga::Output "thing :: ${thing}"
  # done

  Logga::Output "Logga::TearDown : $ 0 :LINENO: $0"    # $ 0 :: Display
  Logga::Output "Logga::TearDown :  $ 1 :BASH_LINENO: $1"    # $ 0 :: Display
  Logga::Output "Logga::TearDown :  $ 2 :BASH_COMMAND: $2"    # $ 0 :: Display
  Logga::Output "Logga::TearDown :  $ 3 :FUNCNAME: $3"    # $ 0 :: Display
  Logga::Output "Logga::TearDown :  $ 4 :ZERO: $4"    # $ 0 :: Display
  Logga::Output "Logga::TearDown :  $ 5 :BASH_SOURCE: $5"    # $ 0 :: Display
  Logga::Output "Logga::TearDown :  $ 6 :: $6"    # $ 0 :: Display
  lineNo="${LINENO}"
  Logga::Output "Logga::TearDown :  lineNo : ${lineNo}"
  bashNo="${BASH_LINENO}"
  Logga::Output "Logga::TearDown :  bashNo : ${bashNo}"
  bashCmd="${BASH_COMMAND}"
  Logga::Output "Logga::TearDown :  bashCmd : ${bashCmd}"
  funcName="${FUNCNAME}"
  Logga::Output "Logga::TearDown :  funcName : ${funcName}"
  thing="${0}"
  Logga::Output "Logga::TearDown :  thing : ${thing}"
  bashSource="${BASH_SOURCE}"
  Logga::Output "Logga::TearDown :  bashSource : ${bashSource}"
  Logga::Output "Logga::TearDown :  $ F0 : ${FUNCNAME[0]}"
  Logga::Output "Logga::TearDown :  $ F1 : ${FUNCNAME[1]}"
  Logga::Output "Logga::TearDown :  $ F2 : ${FUNCNAME[2]}"
  Logga::Output "Logga::TearDown :  $ L0 : ${LINENO[0]}"
  Logga::Output "Logga::TearDown :  $ L1 : ${LINENO[1]}"
  Logga::Output "Logga::TearDown :  $ L2 : ${LINENO[2]}"
  Logga::Output "Logga::TearDown :  $ B0 : ${BASH_LINENO[0]}"
  Logga::Output "Logga::TearDown :  $ B1 : ${BASH_LINENO[1]}"
  Logga::Output "Logga::TearDown :  $ B2 : ${BASH_LINENO[2]}"

  Logga::Padding "="
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

  if [ "${respCode}" -ne 0 ] || [ "${respMsg}" -ne "200" ]; then
    Logga::Error "in UrlExists : (${respCode}) - ${respMsg}"
    return 1
  fi

  echo "${respMsg}"
  return 0
}
Logga::FolderExists() {
  # Logga::Output "========================================"
  Logga::RequiredArgs "1" "${#}" "${*}"
  # [ -d "${1}" ] && Logga::Output "Logga::FolderExists :: FOUND : ${1}" || Logga::Output "Logga::FolderExists :: NOT FOUND : ${1}"
  # [ -d "${1}" ] && return "0" || Logga::Output "1"
  [ -d "${1}" ]
  # # [ -d "${1}" ] && echo "FolderExists :: found >&2 ${1}" >&2 || echo "FolderExists :: not found >&2 ${1}" >&2
  # [ -d "${1}" ] && echo "found 0" >&2 || echo "not found 0" >&2
  # [ -d "${1}" ] && echo "0" >&2 || echo "1" >&2
  # # Logga::Output "${?}"
  # # return "0"
  # # [ -d "${1}" ] && return 0 || return 1
}
Logga::GetRepoName() {
  Logga::RequiredArgs "1" "${#}" "${*}"
  basename "${1}" ".git"
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
  echo "Logga::Header - 1" >&1
  Logga::Terminal "Logga::Header - 2"
  Logga::Output "ERE"
  Logga::Log HEADER "${@}"
  Logga::Output
}
Logga::Verbose() {
  Logga::Log VERBOSE "${@}"
}
Logga::Diag() {
  # Logga::Output "Logga::Diag"
  # if [ $LOGGA_IS_DIAG = "true" ]; then
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
  # Logga::Output "Logga::Log"
  # Logga::Output "Logga::Log : ${#@} - >${@}<"
  # Logga::Output "Logga::Log : ${#*} - >${*}<"
  # Logga::Output "Logga::Log : # : ${#}"
  # Logga::Output "Logga::Log : * : ${1}"
  Logga::RequiredArgs "2" "${#}" "${@}"
  # [ $# -lt 2 ] && Logga::Fatal "Missing required argument to ${FUNCNAME[1]}";
  local passedType=$1
  local logMsg=$2

  local curLevel curType logLevel

  # Logga::Output "Logga::Log :: passedType : ${passedType}"
  # Logga::Output "Logga::Log :: logMsg : ${logMsg}"
  # Logga::Output "Logga::Log :: logLine : ${logLine}"
  # Logga::Output "Logga::Log :: LOGGA_LEVEL : ${LOGGA_LEVEL}"
  # Logga::Output "Logga::Log :: LOGGA_LEVELS : ${LOGGA_LEVELS[*]}"

  logLevel="${LOGGA_LEVELS[${LOGGA_LEVEL}]}"
  curType=$( echo "${passedType}" | tr '[:lower:]' '[:upper:]' )
  curLevel="${LOGGA_LEVELS[${curType}]}"

  # Logga::Output "Logga::Log :: logLevel : ${logLevel}"
  # Logga::Output "Logga::Log :: curType : ${curType}"
  # Logga::Output "Logga::Log :: curLevel : ${curLevel}"

  # [ "${curLevel}" -le "${logLevel}" ] && Logga::Output "${curLevel} LE ${logLevel}" || Logga::Output "${curLevel} GT ${logLevel}"
  # [ "${LOGGA_IS_DIAG}" = true ] && Logga::Output "Logga::Log :: ToConsole" || Logga::Output "Logga::Log :: NOT ToConsole"

  # if [[ "${curLevel}" -le "${logLevel}" ]]; then
  if [ "${curLevel}" -le "${logLevel}" ]; then
    # Logga::Output "LOGGING"
    # [ "${LOGGA_IS_DIAG}" = true ] && Logga::Diag "Logga::Log :: ToConsole"
    Logga::ToConsole "${logMsg}"
  elif [ "${curLevel}" -eq ${LOGGA_LEVELS[DIAG]} ] && [ "${LOGGA_IS_DIAG}" = "true" ]; then
    Logga::ToConsole "${logMsg}"
  elif [ "${curLevel}" -eq ${LOGGA_LEVELS[DEBUG]} ] && [ "${LOGGA_IS_DEBUG}" = "true" ]; then
    Logga::ToConsole "${logMsg}"
  fi

  # if [ "${LOGGA_FILE_LOGGING}" ]; then
    # Logga::Output "Log To File Enabled"
  logMsg="$(echo -e "${logMsg}" | tr -c -s '[:alnum:][:blank:][=]' ' ' | sed -e 's/^[[:space:]]*//')"
  Logga::ToLogFile "${logMsg}"
  # else
  #   Logga::Output "Log To File Disabled"
  # fi
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

  # Logga::Output "Logga::ToConsole :: curType : ${curType}"

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
Logga::ExecCmd() {
  local cmd="${1}";

  errCode=$( Logga::CmdExists "${cmd}" )

  if [ "${errCode}" -eq "0" ] ; then

    if [ $LOGGA_IS_DRYRUN = "true" ]; then
      Logga::Info "Dryrun command: ${cmd} ${options}"
      sleep 3 &
      Logga::ShowSpinner $!

    else
      # set +e
      # sleep 3 &

      # respMsg=$( eval "${cmd} ${options}" > /dev/null 2>&1 )
      # respMsg=$( eval "${cmd} ${options}" > /dev/null )
      # respMsg="$( eval "${*}" > /dev/null 2>&1 & Logga::ShowSpinner $! )"
      respMsg="$( eval "${*}" > /dev/null 2>&1 )"

      # eval "${*}" > /dev/null 2>&1 &
      # Logga::ShowSpinner $!

      # respMsg="$( eval ${cmd} ${options} )"
      # respMsg="$( eval \"${cmd} ${options}\" )"
      respCode="${?}"
      # set -e

      if [ "${#respCode}" -ne 0 ] ; then
        echo "${respMsg}" >&2
        return "${respCode}"
      fi
    fi
  else
    errMsg="$( Logga::ErrorMessage $errCode )"
    Logga::Fatal "${errMsg} : '$cmd'"
    return 1
  fi
}

Logga::ExecuteX() {
  all="${*}"

  Logga::Output "Logga::ExecCmd :ALL 2 : ${all}"
  local cmd="${1}";
  shift
  options="${*}"
  Logga::Output "Logga::Execute :: cmd ${cmd}"
  # set +e
      # errormessage=$( exec "${all}" 2>&1 )
      # errormessage=$( "${all}" 2>&1 $var > /dev/null )

      # Logga::Output "errormessage : ${errormessage} - ${errormessage[*]}"
      # errormessage=$( eval "${all}" > /dev/null 2>&1 $var  )
      # errormessage=$( "${all}" 2>&1 $var > /dev/null )
      # Logga::Output "errormessage : ${errormessage} - ${errormessage[*]}"

      # all="curl -s -L -o /dev/null -w %{response_code} https://github.com/zdharma-continuum/fast-syntax-highlighting"

      # thing=$( sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" "" --unattended 2>&1 $var > /dev/null )
      # Logga::Output "thing :: ${thing}"

      # errormessage=$( eval "${cmd} ${options}" 2>&1 $var > /dev/null )
      # HTTP_RESPONSE=$( eval "${cmd} ${options}" > /dev/null )
      errormessage=$( eval "${cmd} ${options}" 2>&1 $var > /dev/null )

      # -o /dev/null

      # HTTP_RESPONSE=$( eval "${cmd} ${options}"  )

      # {
      #   errormessage=$( $all 2>&1 >&3 3>&- );
      #   Logga::Output "Logga::ExecCmd :: errormessage : ${errormessage} - ${errormessage[*]}"
      # } 3>&1

      result="${?}"
  # set -e

      Logga::Output "# --------------------------------------------"

      Logga::Output "Logga::Execute :: var ${var}"

      Logga::Output "Logga::Execute :: resp ${resp}"
      Logga::Output "Logga::Execute :: err ${err}"
      Logga::Output "Logga::Execute :: result ${result}"

      Logga::Output "Logga::Execute :: errormessage : ${errormessage} - ${errormessage[*]}"
      Logga::Output "# ^-------------------------------------------"
      # exit 0
}
Logga::RepoExistsX() {
  all="${*}"
  Logga::Output "Logga::RepoExists :ALL 1 : ${all}"

  local cmd="${1}";
  shift
  options="${*}"

  errCode=$( Logga::CmdExists "${cmd}" )

  if [ "${errCode}" -eq "0" ] ; then

    if [ $LOGGA_IS_DRYRUN = "true" ]; then

      Logga::Info "Dryrun command: ${cmd} ${options}"

    else
      Logga::Output "Logga::RepoExists :: Not Dry ERE"

      # set +e
      # exec 3>&1
      # errorMessage=$( eval "${all}" )
      # errorMessage=$( eval "${cmd} ${options}" )
      # errorMessage=$( eval "${cmd} ${options}" 2>&1 $var )
      # errorMessage=$( ( eval "${cmd} ${options}" 1>&2 ) 2>&1 )
      # errorMessage=$( ( eval "${cmd} ${options}" ) 2>&1 )
      # eval "${cmd} ${options}"
      # errormessage=$( eval "${cmd} ${options}" 2>&1 $var > /dev/null )

      errorMessage=$(curl -s -w '%{http_code}' "${all}" -o /dev/null )
      result="${?}"
      # set -e

      # {
      #   errormessage=$( $all 2>&1 >&3 3>&- );
      #   Logga::Output "Logga::ExecCmd :: errormessage : ${errormessage} - ${errormessage[*]}"
      # } 3>&1
      [ "${result}" -eq 0 ] && Logga::Output "Logga::RepoExists : Result Is Zero" || Logga::Output "Logga::RepoExists : Result Is NOT Zero"
      Logga::Output "# --------------------------------------------"
      # $LOGGA_IS_DIAG = true &&
      Logga::Output "Logga::RepoExists :: var ${var}"
      # $LOGGA_IS_DIAG = true &&
      Logga::Output "Logga::RepoExists :: resp ${resp}"
      Logga::Output "Logga::RepoExists :: err ${err}"
      Logga::Output "Logga::RepoExists :: result ${result}"
      # $LOGGA_IS_DIAG = true &&
      Logga::Output "Logga::RepoExists :: errormessage : ${errormessage} - ${errormessage[*]}"
      Logga::Output "# ^-------------------------------------------"
      # exit 0

      if [ ${errorMessage} -eq 200 ]; then
        echo $errorMessage
      else
        echo "${errormessage}"
      fi
    fi
  else
    errMsg="$( Logga::ErrorMessage $errCode )"
    Logga::Fatal "${errMsg} : '$cmd'"
  fi
}
Logga::CloneRepoX() {
  all="${*}"
  Logga::Output "Logga::CloneRepo :ALL 1 : ${all}"

  local sourceURL="${1}";
  local targetFolder="${2}"
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
Logga::SlashSpinner() {
  # trap Logga::StopSpinner EXIT
  PID=$!
  local i=1
  local spin="/-\|"

  Logga::HideCursor
  Logga::Print "Running... "

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

  local PID=$!
  local x=0
  local spin='⣾⣽⣻⢿⡿⣟⣯⣷'
  # local msg="${}"
  startMsg="${1:-Running... }"
  endMsg="${2:-Done!}"

  Logga::HideCursor
  Logga::Print "${startMsg}"

  while kill -0 $PID 2>/dev/null; do
    local x=$(((x + 3) % ${#spin}))
    Logga::Print "${spin:$x:3}"
    Logga::CursorBack 1
    sleep .1
  done

  Logga::ShowCursor
  Logga::Output "${endMsg}"
  # sleep  &
  # Logga::ClearLine

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
  # startMsg="${1:-Starting...}"
  # endMsg="${2:-Ended!}"
  # Logga::Display "Logga::ShowSpinner :: ${1} : ${2} > "
  # Logga::SlashSpinner "${1}"
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
    # printf 'Display -3> %s\n' "${msg}" >&3
    printf '%s' "${msg}" >&3
  else
    # printf 'Display -1> %s\n' "${msg}"
    printf '%s' "${msg}"
  fi
}
Logga::Terminal() {
  # Output text var to respsecitve File Descriptor
  # [ -t "3" ] && Logga::Display "Logga::Terminal -> 3 : (${#}) [${*}]\n\n" || Logga::Display "Logga::Terminal -> 1 : (${#}) [${*}]\n\n"
  if [[ -t "3" || -p /dev/stdin ]] ; then
    printf 'Terminal -3> %s' "${*}" >&3
    printf '%s' "${*}" >&3
  else
    printf 'Terminal -1> %s' "${*}"
    printf '%s' "${*}"
  fi
}
Logga::Print() {
  # determine if a "format" parameter was passed in or not
  # generate the text var
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
  # Logga::Output "Logga::Padding : padChar : >${padChar}<"
  # Logga::Output "Logga::Padding : padLen : >${padLen}<"
  # # printf -v actual '%0.1s' "${padChar}" "{1..${padLen}}"
  # # printf -v actual '%0.1s' "${padChar}{1..$padLen}"
  # # printf -v actual "%0.1s" "${padChar}{1..%s}" "${padLen}"
  # Logga::Output "Logga::Padding : actual : ${actual}"
  for ((i = "${3:-1}" ; i <= "${padLen}" ; i++)); do
    Logga::Terminal "${padChar}"
  done
}

Logga::RedirectOutput() {
  echo "Logga::RedirectOutput"
  if "${1}" ; then
    Logga::Display "Logga::RedirectOutput - ACTIVE\n"
    # redirect
    exec 3>&1 4>&2 1>"${SCRIPT_SERR_FILE}" 2>/dev/null
    stty -icanon time 0 min 0
  else
    Logga::Display "Logga::RedirectOutput - INACTIVE\n"
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
