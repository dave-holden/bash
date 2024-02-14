#!/bin/zsh

# SCRIPT[AUTHOR]="ᗪ闩ᐯ🝗 廾ㄖ㇄ᗪ🝗𝓝"
# SCRIPT[DESCRIPTION]="Script vars forshell"
# SCRIPT[REPO_URL]="https://raw.githubusercontent.com/dave-holden/bash/main/template.sh"

SCRIPT_FILE_BASE="$(basename "${0}" )"
SCRIPT_FILE_NAME="${SCRIPT_FILE_BASE%.*}"
SCRIPT_FILE_EXTN="${SCRIPT_FILE_BASE##*.}"

SCRIPT_PATH_BASE="$(realpath "$0")"
SCRIPT_PATH_ABSL="$(dirname "$(realpath "$0")")"
SCRIPT_PATH_RELT="$(dirname "$0")"
SCRIPT_PATH_WORK="$(pwd)"

# SCRIPT_LOG_FORMAT="+%F|%T"
# SCRIPT_LOG_FORMAT="+%y/%m/%d@%H:%M:%S"
SCRIPT_LOG_FORMAT="--iso-8601=seconds"
SCRIPT_LOG_FORMAT="+%Y-%m-%d %H:%M:%S"
# echo "DATE_TIME_FORMAT :: ${DATE_TIME_FORMAT}"
# date="$(date "${DATE_TIME_FORMAT}")";
# echo "DATE_TIME_FORMAT :: ${date}"

# date_format="${BASHLOG_DATE_FORMAT:-+%F %T}";
# echo "date_format :: ${date_format}"
# date="$(date "${date_format}")";
# echo "date :: ${date}"
# date_s="$(date "+%s")";
# echo -e "date_s :: ${date_s}\n"
# now=$(date --iso-8601=seconds)
# echo "[${now}] Logfile for"


SCRIPT_SOUT_FILE="$(dirname "$(realpath "$0")")/${SCRIPT_FILE_NAME}.access.log"
SCRIPT_SERR_FILE="$(dirname "$(realpath "$0")")/${SCRIPT_FILE_NAME}.error.log"
SCRIPT_COMB_FILE="$(dirname "$(realpath "$0")")/${SCRIPT_FILE_NAME}.comined.log"

# echo '--------------------------------------------------------'

# echo "SCRIPT_FILE_BASE :: ${SCRIPT_FILE_BASE}"
# echo "SCRIPT_FILE_NAME :: ${SCRIPT_FILE_NAME}"
# echo "SCRIPT_FILE_EXTN :: ${SCRIPT_FILE_EXTN}"

# echo "SCRIPT_PATH_BASE :: ${SCRIPT_PATH_BASE}"
# echo "SCRIPT_PATH_ABSL :: ${SCRIPT_PATH_ABSL}"
# echo "SCRIPT_PATH_RELT :: ${SCRIPT_PATH_RELT}"
# echo "SCRIPT_PATH_WORK :: ${SCRIPT_PATH_WORK}"

# echo "SCRIPT_SOUT_FILE :: ${SCRIPT_SOUT_FILE}"
# echo "SCRIPT_SERR_FILE :: ${SCRIPT_SERR_FILE}"
# echo "SCRIPT_COMB_FILE :: ${SCRIPT_COMB_FILE}"
