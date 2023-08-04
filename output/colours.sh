
# Utils / colors.sh

# Check if 'tput' command exists
TPUT_FOUND=$( which tput ) > /dev/null

if [ -n TPUT_FOUND ]; then
  # Define constants if tput is available
  NUM_COLORS=$(tput colors)        # Number of colours, e.g. '8' or '256'
  TERM_ROWS=$(tput lines)          # Number of lines in the terminal
  TERM_COLS=$(tput cols)            # Number of columns in the terminal
else
  # Else, set defaults 
  NUM_COLORS=0
  TERM_ROWS=0
  TERM_COLS=0
fi

# colors() {
  if [ -n TPUT_FOUND ]; then
    # Define foreground colours

    FG_BLACK=$( tput setaf 0 );     BLACK=$FG_BLACK;      # \033[30m
    FG_RED=$( tput setaf 1 );       RED=$FG_RED;          # \033[31m
    FG_GREEN=$( tput setaf 2 );     GREEN=$FG_GREEN;      # \033[32m
    FG_YELLOW=$( tput setaf 3 );    YELLOW=$FG_YELLOW;    # \033[33m
    FG_BLUE=$( tput setaf 4 );      BLUE=$FG_BLUE;        # \033[34m
    FG_MAGENTA=$( tput setaf 5 );   MAGENTA=$FG_MAGENTA;  # \033[35m
    FG_CYAN=$( tput setaf 6 );      CYAN=$FG_CYAN;        # \033[36m
    FG_WHITE=$( tput setaf 7 );     WHITE=$FG_WHITE;      # \033[37m

    # Define background colours
    BG_BLACK=$(tput setab 0);                             # \033[40m
    BG_RED=$(tput setab 1);                               # \033[41m
    BG_GREEN=$(tput setab 2);                             # \033[42m
    BG_YELLOW=$(tput setab 3);                            # \033[43m
    BG_BLUE=$(tput setab 4);                              # \033[44m
    BG_MAGENTA=$(tput setab 5);                           # \033[45m
    BG_CYAN=$(tput setab 6);                              # \033[46m
    BG_WHITE=$(tput setab 7);                             # \033[47m
    RESET=$( tput sgr0 );           NORMAL=$RESET         # \033[0m

  else

    # Define default foreground Colours
    FG_BLACK=''                     BLACK=$FG_BLACK;
    FG_RED=''                       RED=$FG_RED;
    FG_GREEN=''                     GREEN=$FG_GREEN;
    FG_YELLOW=''                    YELLOW=$FG_YELLOW;
    FG_BLUE=''                      BLUE=$FG_BLUE;
    FG_MAGENTA=''                   MAGENTA=$FG_MAGENTA;
    FG_CYAN=''                      CYAN=$FG_CYAN;
    FG_WHITE=''                     WHITE=$FG_WHITE;
    
    # Define default background colours
    BG_BLACK=''
    BG_RED=''
    BG_GREEN=''
    BG_YELLOW=''
    BG_BLUE=''
    BG_MAGENTA=''
    BG_CYAN=''
    BG_WHITE=''
    RESET='';                       NORMAL=$RESET;
  fi
# }

# Colors / text-formats.sh
# text_formats() {

  # Define text formatting
  if [ -n TPUT_FOUND ]; then
    TXT_BOLD=$( tput bold );        BOLD=$TXT_BOLD;
    TXT_DIM=$( tput dim );          DIM=$TXT_DIM;
    TXT_ITALICS=$( tput sitm );     ITALICS=$TXT_ITALICS;
    TXT_ULINE=$( tput smul );       ULINE=$TXT_ULINE;
    TXT_BLINK=$( tput blink );      BLINK=$TXT_BLINK;
    TXT_INVERT=$( tput rev );       INVERT=$TXT_INVERT;
    TXT_INVISIBLE=$( tput invis );  INVISIBLE=$TXT_INVISIBLE;

    RESET=$( tput sgr0 );           NORMAL=$RESET;    # \033[0m
  else
    # Define default text formatting
    TXT_BOLD=''                     BOLD=$TXT_BOLD;
    TXT_DIM=''                      DIM=$TXT_DIM;
    TXT_ITALICS=''                  ITALICS=$TXT_ITALICS;
    TXT_ULINE=''                    ULINE=$TXT_ULINE;
    TXT_BLINK=''                    BLINK=$TXT_BLINK;
    TXT_INVERT=''                   INVERT=$TXT_INVERT;
    TXT_INVISIBLE=''                INVISIBLE=$TXT_INVISIBLE;

    RESET=''                        NORMAL=$RESET;
  fi
# }

COLORS=( 
  "FG_RED" "FG_GREEN" "FG_YELLOW" "FG_BLUE" "FG_MAGENTA" 
  "FG_CYAN" "FG_WHITE"  
  "BG_RED" "BG_GREEN" "BG_YELLOW" "BG_BLUE" "BG_MAGENTA" 
  "BG_CYAN" "BG_WHITE"
)
FORMATS=( "BOLD" "DIM" "ITALICS" "UNDERLINE" "BLINK" "INVERT" "INVISIBLE")

Foutput() {
  # return string formatted according to 
  declare -a text
  declare messages styles

  # Ensure atleast one element is passed in - could be just "text"
  if [ ${#} -eq 0 ]; then
    echo "Error: ${FUNCNAME[0]} requires arguments"
    echo -e "\n ${FUNCNAME[0]} \"Some text\""
    echo " Or"
    echo -e " ${FUNCNAME[0]} [COLORS / STYLES] \"Some text\""
    echo " eg ${FUNCNAME[0]} FG_RED Bold \"Some text\""
    echo
    exit 1
  fi

  while [ $# -gt 0 ]; do
    # get string element from array, per index counter
    value="${1}"
    # convert string element to Upper-Case
    value_upper="$(tr '[:lower:]' '[:upper:]' <<< $value)"

    # Check if upper case color / format value exists in array
    if [[ "${COLORS[*]}" =~ "${value_upper}" || "${FORMATS[*]}" =~ "${value_upper}" ]]; then
      # de-dupe methods
      if ! [[ " ${styles[*]} " =~ ${value_upper} ]]; then
        styles+="${!value_upper}"
      fi
    else
      text+=( "${value}" )
    fi

    shift
  done
# Concatinate message elements, space delimited
  message="$(IFS=' '; echo "${text[*]}")"

  # Apply styles to message and reset/normalize styling
  message="${styles}${message}${NORMAL}"
  echo ${message}
}

stripDisplay() {
  # Remove escape codes - colors / styles - from string.
  echo "$(sed $'s/\033[[][^A-Za-z]*[A-Za-z]//g' <<< "$@")"
}

escape_chars() {

  local content="${1}"
  shift
  for char in "$@"; do
    content="${content//${char}/\\${char}}"
  done

  echo "${content}"
}

echo_var() {
    local var="${1}"
    local content="${2}"
    local escaped="$(escape_chars "${content}" "\\" '"')"

    echo "${var}=\"${escaped}\""
}

# (return 0 2>/dev/null) && {
#     echo "COLOURS IS SOURCED"; 
#     colors; 
#     text_formats
# } || echo "COLOURS NOT SOURCED"
