#!/bin/sh

declare -A SCRIPT

SCRIPT[AUTHOR]="ᗪ闩ᐯ🝗 廾ㄖ㇄ᗪ🝗𝓝"
SCRIPT[DESCRIPTION]="Environmental Script Settings"

SCRIPT[FILE_BASE]="$(basename "${0}" )"
SCRIPT[FILE_NAME]="${SCRIPT[FILE_BASE]%.*}"
SCRIPT[FILE_EXTN]="${SCRIPT[FILE_BASE]##*.}"

SCRIPT[PATH_BASE]="$(realpath "$0")"
SCRIPT[PATH_ABSL]="$(dirname "$(realpath "$0")")"
SCRIPT[PATH_RELT]="$(dirname "$0")"
SCRIPT[PATH_WORK]="$(pwd)"

# SCRIPT[LOG_FORMAT]="+%F|%T"
# SCRIPT[LOG_FORMAT]="+%y/%m/%d@%H:%M:%S"
# SCRIPT[LOG_FORMAT]="--iso-8601=seconds"
SCRIPT[LOG_FORMAT]="+%Y-%m-%d %H:%M:%S"

SCRIPT[SOUT_FILE]="$(dirname "$(realpath "$0")")/${SCRIPT[FILE_NAME]%.*}.access.log"
SCRIPT[SERR_FILE]="$(dirname "$(realpath "$0")")/${SCRIPT[FILE_NAME]%.*}.error.log"
SCRIPT[COMB_FILE]="$(dirname "$(realpath "$0")")/${SCRIPT[FILE_NAME]%.*}.comined.log"

# array::print() {
#     declare -n __arr="$1"
#     for k in "${!__arr[@]}"; do 
#         printf "%s = %s\n" "$k" "${__arr[$k]}"; 
#     done
# }
# array::print SCRIPT
