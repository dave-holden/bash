#!/usr/bin/env sh



SCRIPT[AUTHOR]="ᗪ闩ᐯ🝗 廾ㄖ㇄ᗪ🝗𝓝"
SCRIPT[DESCRIPTION]="Bash template for bash/shell scripts"

SCRIPT_FILE_BASE="$(basename "${0}" )"
SCRIPT_FILE_NAME="${SCRIPT_FILE_BASE%.*}"
SCRIPT_FILE_EXTN="${SCRIPT_FILE_BASE##*.}"

SCRIPT_PATH_BASE="$(realpath "$0")"
SCRIPT_PATH_ABSL="$(dirname "$(realpath "$0")")"
SCRIPT_PATH_RELT="$(dirname "$0")"
SCRIPT_PATH_WORK="$(pwd)"

# SCRIPT_LOG_FORMAT="+%F|%T"
# SCRIPT_LOG_FORMAT="+%y/%m/%d@%H:%M:%S"
# SCRIPT_LOG_FORMAT="--iso-8601=seconds"
SCRIPT_LOG_FORMAT="+%Y-%m-%d %H:%M:%S"

SCRIPT_SOUT_FILE="$(dirname "$(realpath "$0")")/${SCRIPT_FILE_NAME}.access.log"
SCRIPT_SERR_FILE="$(dirname "$(realpath "$0")")/${SCRIPT_FILE_NAME}.error.log"
SCRIPT_COMB_FILE="$(dirname "$(realpath "$0")")/${SCRIPT_FILE_NAME}.comined.log"
