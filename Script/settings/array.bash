#!/bin/zsh

declare -A SCRIPT

# SCRIPT[AUTHOR]="ᗪ闩ᐯ🝗 廾ㄖ㇄ᗪ🝗𝓝"
# SCRIPT[DESCRIPTION]="Bash template for bash/shell scripts"
# SCRIPT[REPO_URL]="https://raw.githubusercontent.com/dave-holden/bash/main/template.sh"

SCRIPT[FILE_BASE]="$(basename "${0}" )"
SCRIPT[FILE_NAME]="${SCRIPT[FILE_BASE]%.*}"
SCRIPT[FILE_EXTN]="${SCRIPT[FILE_BASE]##*.}"

SCRIPT[PATH_BASE]="$(realpath "$0")"
SCRIPT[PATH_ABSL]="$(dirname "$(realpath "$0")")"
SCRIPT[PATH_RELT]="$(dirname "$0")"
SCRIPT[PATH_WORK]="$(pwd)"
SCRIPT[LOG_FORMAT]="+%F %T"

SCRIPT[SOUT_FILE]="$(dirname "$(realpath "$0")")/${SCRIPT[FILE_NAME]%.*}.access.log"
SCRIPT[SERR_FILE]="$(dirname "$(realpath "$0")")/${SCRIPT[FILE_NAME]%.*}.error.log"
SCRIPT[COMB_FILE]="$(dirname "$(realpath "$0")")/${SCRIPT[FILE_NAME]%.*}.comined.log"
echo '--------------------------------------------------------'

echo "SCRIPT[FILE_BASE] :: ${SCRIPT[FILE_BASE]}"
echo "SCRIPT[FILE_NAME] :: ${SCRIPT[FILE_NAME]}"
echo "SCRIPT[FILE_EXTN] :: ${SCRIPT[FILE_EXTN]}"

echo "SCRIPT[PATH_BASE] :: ${SCRIPT[PATH_BASE]}"
echo "SCRIPT[PATH_ABSL] :: ${SCRIPT[PATH_ABSL]}"
echo "SCRIPT[PATH_RELT] :: ${SCRIPT[PATH_RELT]}"
echo "SCRIPT[PATH_WORK] :: ${SCRIPT[PATH_WORK]}"

echo "SCRIPT[SOUT_FILE] :: ${SCRIPT[SOUT_FILE]}"
echo "SCRIPT[SERR_FILE] :: ${SCRIPT[SERR_FILE]}"
echo "SCRIPT[COMB_FILE] :: ${SCRIPT[COMB_FILE]}"


# array::print() {
#     declare -n __arr="$1"
#     for k in "${!__arr[@]}"; do 
#         printf "%s = %s\n" "$k" "${__arr[$k]}"; 
#     done
# }
# array::print SCRIPT
