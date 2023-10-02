#!/usr/bin/env bash

source ./BASH/formatting/colours.sh
source ./Script/settings/flat.bash

Logga() {
  # Initialize Logga
  Logga::Setup
}

Logga::Setup() {
  # Setup vars, traps, screen
  Logga::Output "Setup"
  Logga:FlushLogFile

  LOGGA_DRY_RUN=false

  LOGGA_LEVEL="INFO"
  LOGGA_DEBUG_LEVEL="${DEBUG:-0}";

  LOGGA_SHOW_COLOURS=true
  LOGGA_SHOW_ICONS=false
  LOGGA_LEVEL_LENGTH=8

  LOGGA_STDINP=0
  LOGGA_STDOUT=1
  LOGGA_STDERR=2
  LOGGA_OUTPUT=3
  LOGGA_ALTOUT=4
  LOGGA_HIDE_OUTPUT=/dev/null
  LOGGA_PADDING="$(printf '%0.1s' " "{1..500})"

  # Find the rows and columns
  LOGGA_TERM_WIDTH="$(tput cols)"
  LOGGA_TERM_HEIGHT="$(tput lines)"

  declare -gA LOGGA_LEVELS LOGGA_COLORS LOGGA_ICONS
  declare -ga LOGGA_ORDER

  LOGGA_LEVELS=(
      [FATAL]=0 
      [ERROR]=1 
      [WARNING]=2 
      [SUCCESS]=3 
      [INFO]=4 
      [HEADER]=5 
      [VERBOSE]=6 
      [DEBUG]=7 
  )
  LOGGA_ORDER=(
      FATAL 
      ERROR 
      WARNING 
      SUCCESS 
      INFO 
      HEADER 
      VERBOSE 
      DEBUG 
  )
  LOGGA_COLORS=(
      [FATAL]="${BOLD}${UNDERLINE}${RED}" 
      [ERROR]="${BOLD}${RED}" 
      [WARNING]="${BOLD}${YELLOW}" 
      [SUCCESS]="${BOLD}${CYAN}" 
      [INFO]="${BOLD}${GREEN}" 
      [HEADER]="${BOLD}${WHITE}${UNDERLINE}" 
      [VERBOSE]="${MAGENTA}" 
      [DEBUG]="${BOLD}${MAGENTA}" 
  )
  LOGGA_ICONS=(
      [FATAL]="✘" 
      [ERROR]="✗" 
      [WARNING]="⚠" 
      [INFO]="ℹ" 
      [SUCCESS]="✔" 
      [HEADER]="➽" 
      [VERBOSE]="❋" 
      [DEBUG]="⛏" 
  )

  clear && Logga::_Center "Logga Active!"

  # if [[ -v DEBUGGER ]]; then
  #   shopt -s extdebug

  # else
  #   # # Exit on error. Append '||true' if you expect an error
  #   # set -e  # -o errexit    # Instructs a shell to exit if a command fails, i.e., if it outputs a non-zero exit status
  #   # # set -e    # same as: `set -o errexit`

  #   # # Trap errors in subshells and functions
  #   set -E  # -o errtrace   # Causes shell functions to inherit the ERR trap.
  #   # # set -E    # same as: `set -o errtrace`

  #   # set -eE   # same as: `set -o errexit -o errtrace`

  #   set -T  # -o functrace  # Causes shell functions to inherit the DEBUG trap.
    
  #   ## The return value of a pipeline is the status of the last command that had a non-zero status upon exit. 
  #   ## If no command had a non-zero status upon exit, the value is zero.                                                                  |
  #   # # Use last non-zero exit code in a pipeline
  #   set -o pipefail
  # fi

  # trap '_trapCleanup_ ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM

  # trap 'Logga::SetUpError "$LINENO" "$?"' ERR
  # trap 'Logga::TearDown "$LINENO" "$?"' EXIT
  # trap '_trapCleanup_ ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM
  # Logga::Output "Setting FDs"
  # trap 'Logga::TearDown ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM
  # trap 'Logga::TearDown' SIGINT
  # trap 'Logga::TearDown ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM

  Logga::Traps 'LoggaTearDown "${LINENO}" "${BASH_LINENO}" "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT HUP INT QUIT ABRT KILL ALRM TERM
  # Logga::Traps 'LoggaTearDown' SIGINT

  # stty -icanon time 0 min 0

  # # make file descriptor 3 a copy of stdout
  # # make file descriptor 4 a copy of stderr
  # # redirect-append stdout to file ${SCRIPT_SERR_FILE}
  # # make stderr a copy of stdout
  # exec 3>&1 4>&2 1>"${SCRIPT_SERR_FILE}" 2>&1
  # # exec OUTPUT>&STDOUT ALTOUT>&STDERR STDOUT>"${SCRIPT_SERR_FILE}" STDERR>&STDOUT

  # # I want the script to write stdout and stderr to the /tmp/output.log as well as 
  # # display in console while it is running. How should the redirection look like?

  # # Redirect stdout to a tee -a /tmp/output.log command using process substitution. 
  # # Then redirect stderr to stdout. Example:
  # # exec 1> >( tee -a "${SCRIPT_SERR_FILE}" ) 2>&1
}

Logga::Await() {
  Logga::Output "Logga::Await"
  while true; do
    read input
    
    if [ "$input" = "a" ]; then 
      echo "hello world"           
    fi
  done
}

Logga::Traps() {
  Logga::Output "Logga::Traps : ${#@} == ${*}\n"

  func="${1}"; 
  # args="${2}"

  Logga::Output "Logga::Traps : func : ${func}"
  # Logga::Output "args :${args}: ${#args[@]}"
  Logga::Output ""

  # shift; 
  shift
  Logga::Output "Remainder :: ${#@} == ${*}"
  # Logga::Output "LINENO :: ${LINENO}"
  # Logga::Output "ERROR_LINENO :: ${ERROR_LINENO}"
  for sig in "${@}"; do
    # $args[$sig]=$sig
    # Logga::Output "sig :: ${sig}"
    Logga::Output "${func} ${sig}"
    # trap "sig=${sig};${func} " "${sig}"
    trap "${func} ${sig}" "${sig}"
    # trap "ERROR_LINENO=$LINENO;sig=${sig};$func" "$sig"
    # trap 'ERROR_LINENO=$LINENO;sig=${sig};$func' "$sig"
  done
  Logga::Output '= = = = = = = = = = = = = = = = = = = ='
}

LoggaTearDown() {
  # trap 'Logga::TearDown ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT INT TERM SIGINT SIGQUIT SIGTERM
  # Logga::Output "TearDown : $ 0 : $0" # ./Logging/Logga.sh
  # Logga::Output "TearDown : $ 1 : $1" # 1
  # Logga::Output "TearDown : $ 2 : $2" # 295
  # Logga::Output "TearDown : $ 3 : $3" # read input
  # Logga::Output "TearDown : $ 4 : $4" # Logga::Await Logga::Line main
  # Logga::Output "TearDown : $ 5 : $5" # ./Logging/Logga.sh
  # Logga::Output "TearDown : $ 6 : $6" # ./Logging/Logga.sh
  # Logga::Output "TearDown : $ 7 : $7" # 
  # Logga::Traps 'Logga::TearDown ${LINENO} ${BASH_LINENO} "${BASH_COMMAND}" "${FUNCNAME[*]}" "${0}" "${BASH_SOURCE[0]}"' EXIT HUP INT QUIT ABRT KILL ALRM TERM
  # Logga::Output ""
  Logga::Output "\nTearDown : $ @ : ${@}"
  Logga::Output "TearDown : $ 0 : ${0}" # ./Logging/Logga.sh
  Logga::Output "TearDown : $ 1 : ${1}" # 1
  Logga::Output "TearDown : $ 2 : ${2}" # 327
  Logga::Output "TearDown : $ 3 : ${3}" # read input
  Logga::Output "TearDown : $ 4 : ${4}" # Logga::Await Logga::Line main
  Logga::Output "TearDown : $ 5 : ${5}" # ./Logging/Logga.sh
  Logga::Output "TearDown : $ 6 : ${6}" # ./Logging/Logga.sh
  Logga::Output "TearDown : $ 7 : ${7}" # 
  local signal="${SIGNALS[${1}]}"
  Logga::Output "TearDown : signal : ${signal}"              # 196

  Logga::Output "TearDown : LINENO : ${LINENO[0]}"              # 196
  Logga::Output "TearDown : BASH_LINENO : ${BASH_LINENO[*]}"    # 1 330 424 0
  Logga::Output "TearDown : BASH_COMMAND : ${BASH_COMMAND[*]}"  # read input
  Logga::Output "TearDown : FUNCNAME : ${FUNCNAME[*]}"          # Logga::TearDown Logga::Await Logga::Line main
  Logga::Output "TearDown : BASH_SOURCE : ${BASH_SOURCE[*]}"    # ./Logging/Logga.sh ./Logging/Logga.sh ./Logging/Logga.sh ./Logging/Logga.sh

  # stty sane
  # exec 1>&3 2>&4

  exit 0
}

Logga:FlushLogFile() {
  # [[ -n $1 && ! -d $1 ]] && : > "$1"
  # truncate -s 0 "${SCRIPT_SERR_FILE}"
  [[ -n "${SCRIPT_SERR_FILE}" && ! -d "${SCRIPT_SERR_FILE}" ]] && : > "${SCRIPT_SERR_FILE}"
}

Logga::Log() {
  # Logga::Output  '. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . '
  # Logga::Output "Log :: FUNCNAME : ${FUNCNAME[*]}\n"

  [ $# -lt 2 ] && Logga::Fatal "Missing required argument to ${FUNCNAME[1]}"

  local logMsg=$2
  local logLine=$3
  # Logga::Output "Log :: logMsg :: ${logMsg}"
  # Logga::Output "Log :: logLine :: ${logLine}"

  local logLevel="${LOGGA_LEVELS[${LOGGA_LEVEL}]}"
  local curType=$(echo "$1" | tr '[:lower:]' '[:upper:]' )
  local curLevel="${LOGGA_LEVELS[${curType}]}"

  if [ "${curLevel}" -le "${logLevel}" ]; then
    # printf -v msg "Log :: curLevel ${curType} (${curLevel}) LE LOGLEVEL ${LOGLEVEL} (${logLevel})"
    # Logga::Output "Log :: msg ${msg}"
    Logga::ToConsole "${logMsg}"
    Logga::ToLogFile "${logMsg}"
  else
    # printf -v msg "Log :: curLevel ${curType} (${curLevel}) GE LOGLEVEL ${LOGLEVEL} (${logLevel})"  
    # Logga::Output "Log :: msg ${msg}"
    Logga::ToConsole "${logMsg}"
  fi
}

Logga::ToConsole() {

  [ $# -lt 1 ] && Logga::Fatal "Missing required argument to ${FUNCNAME[0]}"

  local logMessage="${1}"
  local curColor="${LOGGA_COLORS[${curType}]}"

  if [ "${LOGGA_SHOW_ICONS}" = true ]; then
    curIcon="${LOGGA_ICONS[${curType}]}"
    # Logga::Output "ToConsole :: curIcon :: >${curIcon}< - ${#curIcon}"

    width=$(( ${LOGGA_LEVEL_LENGTH} + ${#curColor} + ${#NORMAL} ))
    # Logga::Output "ToConsole :: width : ${width}"
      
    width=$(( ${LOGGA_LEVEL_LENGTH} + (${#curColor} * 2) + (${#NORMAL} * 2) + ${#curIcon} ))
      
    # Logga::Output "ToConsole :: width : ${width}"
    printf -v typeStyled "[ %-${width}s%*s ] %s" "${curColor}${curIcon}${NORMAL} ${curColor}${curType}${NORMAL} "
  else
    width=$(( ${LOGGA_LEVEL_LENGTH} + ${#curColor} + ${#NORMAL} ))
    # Logga::Output "ToConsole :: width : ${width}"
    printf -v typeStyled "[ %-${width}s%*s ] %s" "${curColor}${curType}${NORMAL} "
  fi
  Logga::Output "${typeStyled} ${logMessage}"
}

Logga::ToLogFile() {
  local logDate="$(date "${SCRIPT_LOG_FORMAT}")"
  printf -v typeStyled "[ %-${LOGGA_LEVEL_LENGTH}s%*s ]" "${curType}"

  local logOutput="${logDate} ${typeStyled} ${logMsg}"

  # Logga::Output "ToLogFile :: logOutput :: >${logOutput}<"
  printf "${logOutput}\n"
}

Logga::Fatal() {
  Logga::Log Fatal "${@}"
}
Logga::Error() {
  Logga::Log ERROR "${@}"
}
ogga::Warning() {
  Logga::Log WARNING "${@}"
}
Logga::Success() {
  Logga::Log SUCCESS "${@}"
}
Logga::Info() {
  Logga::Log Info "${@}"
}
Logga::Verbose() {
  Logga::Log VERBOSE "${@}"
}
Logga::Debug() {
  Logga::Log Debug "${@}"
}

Logga::Output() {
  if [[ -t "3" || -p /dev/stdin ]]
  then
    # printf "Logga::Output :interactive: ${@}\n" >&3
    # echo -e "${@}\n" >&3
    printf "${@}\n" >&3
  else
    # printf "Logga::Output :non-interactive: ${@}\n"
    printf "${@}\n"
  fi
}

Logga::Line() {
  # printf 'Today is %(%F)T\n' -1
  # number=1234567890
  # printf "%'d\n" $number
  # character="a"
  # printf "%d\n" "'$character"
  # # printf -v padding '%0.1s' ={1..500}"
  # Logga::Output "Setup :: padding : \n${padding}"

  # Logga::Output "Line :: # : ${#}"
  # Logga::Output "Line :: @ : ${@}"
  # Logga::Output "Line :: 1 : ${1}"
  # Logga::Output "Line :: 2 : ${2}"

  # [ $# -lt 2 ] && Logga::Fatal 'Missing required argument to Logga::Line'
  
  Logga::Output "Line :: termHeight : ${LOGGA_TERM_HEIGHT}"
  Logga::Output "Line :: termWidth : ${LOGGA_TERM_WIDTH}"

  # # Write specified log level data to logfile
  # case "${LOGLEVEL:-ERROR}" in
  #   ALL | all | All)
  #     echo "_writeToLog_"
  #   ;;
  #   OFF | off)
  #     return 0
  #     ;;
  #   *)
  #     if [[ ${_alertType} =~ ^(error|fatal) ]]; then
  #         Logga::Output "_writeToLog_"
  #     fi
  #     ;;
  # esac

  # Logga::Output '------------------------------------ Right -------------------------------------'
  # Logga::Output '================================================================================'
}

Logga::_Center() {
  local str="${1}"
  local width="${2:-$LOGGA_TERM_WIDTH}"
  local calc1="$(( ( ${width} - 2 - ${#str} ) / 2 ))"
  local calc2="$(( ( ${width} - 1 - ${#str} ) / 2 ))"

  printf -v alignCenter '%*.*s %s %*.*s' 0 "$calc1" "${LOGGA_PADDING}" "${str}" 0 "${calc2}" "${LOGGA_PADDING}"
  Logga::Output "${alignCenter}"
}

Logga::_Left() {
  local str="${1}"
  local width="${2:-$LOGGA_TERM_WIDTH}"
  local calc1="$(( ( ${width} - 1 - ${#str} ) ))"
  printf -v alignLeft '%s %*.*s' "${str}" 0 "${calc1}" "${LOGGA_PADDING}"
  Logga::Output "${alignLeft}"
}

Logga::_Right() {
  local str="${1}"
  local width="${2:-$LOGGA_TERM_WIDTH}"
  local calc2="$(( ( ${width} - 1 - ${#str} ) ))"
  printf -v alignRight '%*.*s %s' 0 "$calc2" "${LOGGA_PADDING}" "${str}"
  Logga::Output "${alignRight}"
}

Logga::Header() {
  Logga::Output "Logga::Header"

  # Logga::Log header "Header :: ${@}"
}

Logga::_Across() {
  age=55
  name="Dave"
  width=40
  local str="${1}"
  printf -v across "%s %-*s%s\n" "[OK]" "$((width - ${#3}))" "$name" "$age"
  Logga::Output "${across}"
}

echo '----------------------------------------------------------------------'

Logga

# Logga::Output '------------------------------------ Right -------------------------------------'
# Logga::Output '================================================================================'
# Logga::Fatal "This is Fatal"
# Logga::Error "This is Error"
# Logga::Warning "This is Warning"
# Logga::Success "This is Success"
# Logga::Info "This is Info"
# Logga::Verbose "This is Verbose"
# Logga::Debug "This is Debug"

# Logga::_Center "This is the CENTER!"

# Logga::_Left "This is the LEFT"

# Logga::_Right "This is the RIGHT"

# Logga::_Across "This is Across"

# Logga::Line "This is the Center"


Logga::Await


# Logga::Log "This is a direct Log!?!"
# Logga::Header "This is a Header!!!"

# trap 'err $LINENO' EXIT ERR
# trap 'failure "${BASH_LINENO}" "$LINENO" "${FUNCNAME[*]:-script}" "$?" "$BASH_COMMAND"' ERR
# # trap 'echo "exit at line $LINENO"' EXIT
# trap 'echo "error at line $LINENO" "$BASH_LINENO" "$BASH_COMMAND" "ERR" "$?"' ERR
# trap 'simple_handler "$LINENO" "$?";Logga::SimpleError "$LINENO" "$?"' ERR
# trap 'Logga::SimpleError "$LINENO" "$?"' ERR
# trap 'exit_func "$LINENO" "$?"' EXIT 

# echo '----------------------------------------------------------------------'
# trap_with_arg() {
#     func="$1" ; shift
#     for sig ; do
#         trap "$func $sig" "$sig"
#     done
# }

# func_trap() {
#     echo "Trapped: $1"
# }

# trap_with_arg func_trap INT TERM EXIT

# echo "Send signals to PID $$ and type [enter] when done."
# read # Wait so the script doesn't exit.
