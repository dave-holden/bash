
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

colors() {
  if [ -n TPUT_FOUND ]; then
    # Define foreground colours

    FG_BLACK=$( tput setaf 0 );     FGB=$FG_BLACK;     # \033[30m
    FG_RED=$( tput setaf 1 );       FGR=$FG_RED;       # \033[31m
    FG_GREEN=$( tput setaf 2 );     FGG=$FG_GREEN;     # \033[32m
    FG_YELLOW=$( tput setaf 3 );    FGY=$FG_YELLOW;    # \033[33m
    FG_BLUE=$( tput setaf 4 );      FGBL=$FG_BLUE;     # \033[34m
    FG_MAGENTA=$( tput setaf 5 );   FGM=$FG_MAGENTA;   # \033[35m
    FG_CYAN=$( tput setaf 6 );      FGC=$FG_CYAN;      # \033[36m
    FG_WHITE=$( tput setaf 7 );     FGW=$FG_WHITE;     # \033[37m

    # Define background colours
    BG_BLACK=$(tput setab 0);       BGB=$BG_BLACK;     # \033[40m
    BG_RED=$(tput setab 1);         BGR=$BG_RED;       # \033[41m
    BG_GREEN=$(tput setab 2);       BGG=$BG_GREEN;     # \033[42m
    BG_YELLOW=$(tput setab 3);      BGY=$BG_YELLOW;    # \033[43m
    BG_BLUE=$(tput setab 4);        BGBL=$BG_BLUE;     # \033[44m
    BG_MAGENTA=$(tput setab 5);     BGM=$BG_MAGENTA;   # \033[45m
    BG_CYAN=$(tput setab 6);        BGC=$BG_CYAN;      # \033[46m
    BG_WHITE=$(tput setab 7);       BGW=$BG_WHITE;     # \033[47m
    
    RESET=$( tput sgr0 );           NORMAL=$RESET;    # \033[0m
  else

    # Define default foreground Colours
    FG_BLACK=''                     FGB=$FG_BLACK;
    FG_RED=''                       FGR=$FG_RED;
    FG_GREEN=''                     FGG=$FG_GREEN;
    FG_YELLOW=''                    FGY=$FG_YELLOW;
    FG_BLUE=''                      FGBL=$FG_BLUE;
    FG_MAGENTA=''                   FGM=$FG_MAGENTA;
    FG_CYAN=''                      FGC=$FG_CYAN;
    FG_WHITE=''                     FGW=$FG_WHITE;
    
    # Define default background colours
    BG_BLACK=''                     BGB=$BG_BLACK;
    BG_RED=''                       BGR=$BG_RED;
    BG_GREEN=''                     BGG=$BG_GREEN;
    BG_YELLOW=''                    BGY=$BG_YELLOW;
    BG_BLUE=''                      BGBL=$BG_BLUE;
    BG_MAGENTA=''                   BGM=$BG_MAGENTA;
    BG_CYAN=''                      BGC=$BG_CYAN;
    BG_WHITE=''                     BGW=$BG_WHITE;

    RESET=''                        NORMAL=$RESET;
  fi
}

# Colors / text-formats.sh
text_formats() {

  # Define text formatting
  if [ -n TPUT_FOUND ]; then
    TXT_BOLD=$( tput bold );        TB=$TXT_BOLD;
    TXT_DIM=$( tput dim );          TD=$TXT_DIM;
    TXT_ITALICS=$( tput sitm );     TI=$TXT_ITALICS;
    TXT_ULINE=$( tput smul );       TU=$TXT_ULINE;
    TXT_BLINK=$( tput blink );      TBL=$TXT_BLINK;
    TXT_INVERT=$( tput rev );       TIV=$TXT_INVERT;
    TXT_INVISIBLE=$( tput invis );  TINV=$TXT_INVISIBLE;

    RESET=$( tput sgr0 );           NORMAL=$RESET;    # \033[0m
  else
    # Define default text formatting
    TXT_BOLD=''                     TB=$TXT_BOLD;
    TXT_DIM=''                      TD=$TXT_DIM;
    TXT_ITALICS=''                  TI=$TXT_ITALICS;
    TXT_ULINE=''                    TU=$TXT_ULINE;
    TXT_BLINK=''                    TBL=$TXT_BLINK;
    TXT_INVERT=''                   TIV=$TXT_INVERT;
    TXT_INVISIBLE=''                TINV=$TXT_INVISIBLE;

    RESET=''                        NORMAL=$RESET;
  fi
}

# Setup foreground colour functions
RED() { printf "%s\\n" "${FG_RED}${1}${NORMAL}"; }
GREEN() { printf "%s\\n" "${FG_GREEN}${1}${NORMAL}"; }
YELLOW() { printf "%s\\n" "${FG_YELLOW}${1}${NORMAL}"; }
BLUE() { printf "%s\\n" "${FG_BLUE}${1}${NORMAL}"; }
MAGENTA() { printf "%s\\n" "${MAGENTA}${1}${NORMAL}"; }
CYAN() { printf "%s\\n" "${CYAN}${1}${NORMAL}"; }
WHITE() { printf "%s\\n" "${WHITE}${1}${NORMAL}"; }

# Setup background colour functions
BG_RED() { printf "%s\\n" "${BG_RED}${1}${NORMAL}"; }
BG_GREEN() { printf "%s\\n" "${BG_GREEN}${1}${NORMAL}"; }
BG_YELLOW() { printf "%s\\n" "${BG_YELLOW}${1}${NORMAL}"; }
BG_BLUE() { printf "%s\\n" "${BG_BLUE}${1}${NORMAL}"; }
BG_MAGENTA() { printf "%s\\n" "${BG_MAGENTA}${1}${NORMAL}"; }
BG_CYAN() { printf "%s\\n" "${BG_CYAN}${1}${NORMAL}"; }
BG_WHITE() { printf "%s\\n" "${BG_WHITE}${1}${NORMAL}"; }

# Setup text formattion functions
BOLD() { printf "%s\\n" "${TXT_BOLD}${1}${TXT_RESET}"; }
DIM() { printf "%s\\n" "${TXT_DIM}${1}${TXT_RESET}"; }
ITALICS() { printf "%s\\n" "${TXT_ITALICS}${1}${TXT_RESET}"; }
UNDERLINE() { printf "%s\\n" "${TXT_ULINE}${1}${TXT_RESET}"; }
BLINK() { printf "%s\\n" "${TXT_BLINK}${1}${TXT_RESET}"; }
INVERT() { printf "%s\\n" "${TXT_INVERT}${1}${TXT_RESET}"; }
INVISIBLE() { printf "%s\\n" "${TXT_INVISIBLE}${1}${TXT_RESET}"; }

COLORS=( 
  "RED" "GREEN" "YELLOW" "BLUE" "MAGENTA" "CYAN" "WHITE" 
  "BG_RED" "BG_GREEN" "BG_YELLOW" "BG_BLUE" "BG_MAGENTA" 
  "BG_CYAN" "BG_WHITE"
)
FORMATS=( "BOLD" "DIM" "ITALICS" "UNDERLINE" "BLINK" "INVERT" "INVISIBLE")

Display() { 
  # Attempts to return string formatted according to 
  # COLORS / STYLES passed in,
  # Any unmatched string is added to the "message" to be displayed

  declare -a text methods
  declare message

  # get arguments passed to method
  args=( "$@" )
  # Ensure atleast one element is passed in - could be just "text"
  if [ ${#args} -eq 0 ]; then
    echo "no arguments"
    exit 1
  fi

  # get index + 1 of arguments passed to method
  counter=1    
  len=$(( ${#args} + 1 ))

  while [ "$counter" -lt $len ]; do
    # get string element from array, per index counter
    value=${args[$counter]}

    # convert string element to Upper-Case
    value_upper=$(tr '[:lower:]' '[:upper:]' <<< $value)

    # Check if upper case color / format value exists in array
    if [[ "${COLORS[*]}" =~ "${value_upper}" || "${FORMATS[*]}" =~ "${value_upper}" ]]; then
      # de-dupe methods
      if ! [[ " ${methods[*]} " =~ ${value_upper} ]]; then
        methods+=( "$value_upper" )
      fi
    else
      text+=$value
    fi
    (( counter++ ))
  done

  # Join array elements, concatinate space delimited
  response=$(IFS=' '; echo "${text[*]}")
  
  # Iterate over any methods
  for method in "${methods[@]}"
  do
    response=$( $method $response )
  done

  echo ${response}
}
stripDisplay() {
  # Remove escape codes - colors / styles - from string.
  # echo $(echo "$spaced" | sed  $'s/\033[[][^A-Za-z]*[A-Za-z]//g')
  echo "$(sed $'s/\033[[][^A-Za-z]*[A-Za-z]//g' <<< "$@")"
}