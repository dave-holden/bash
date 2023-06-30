
# Utils / colors.sh
colours() {
  if which 'tput' > /dev/null; then
    # Foreground Colours
    FG_BLACK=$( tput setaf 0 );
    FG_RED=$( tput setaf 1 );
    FG_GREEN=$( tput setaf 2 );
    FG_YELLOW=$( tput setaf 3 );
    FG_BLUE=$( tput setaf 4 );
    FG_MAGENTA=$( tput setaf 5 );
    FG_CYAN=$( tput setaf 6 );
    FG_WHITE=$( tput setaf 7 );

    FG_RESET=$( tput sgr0 );
  else
    FG_BLACK='';
    FG_RED='';
    FG_GREEN='';
    FG_YELLOW='';
    FG_BLUE='';
    FG_MAGENTA='';
    FG_CYAN='';
    FG_WHITE=$( tput setaf 7 );

    FG_RESET=$( tput sgr0 );
  fi
}

# Utils / text-formats.sh
text_formats() {
  # Text Formatting
  if which 'tput' > /dev/null; then
    TXT_BOLD=$( tput bold )
    TXT_ULINE=$( tput smul )
    TXT_BLINK=$( tput blink )

    TXT_RESET=$( tput sgr0 )
  else
    TXT_BOLD=''
    TXT_ULINE=''
    TXT_BLINK=''

    TXT_RESET=''
  fi
}

