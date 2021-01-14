#!/usr/bin/env bash
set -euo pipefail

SUPPORT_FIRECLOUD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source ${SUPPORT_FIRECLOUD_DIR}/sh/common.inc.sh

#- robot 1.0
## Usage: robot OPTIONS...
## Report back the position and the direction of the robot.
## All missing inputs can be piped via stdin in the order below.
##
##   --room-size    Room's size: width and depth e.g. "5 7"
##   --position     Initial position: x, y and direction (orientation) of the robot e.g. "3 3 N"
##   --navigation   Navigation commands e.g. L(eft) R(ight) F(orward)
##
##   -h, --help     Display this help and exit
##   -v, --version  Output version information and exit

ROOM_SIZE=
POSITION=
NAVIGATION=

while [[ $# -gt 0 ]]; do
    case "$1" in
        --room-size)
            ROOM_SIZE=$2
            shift 2
            ;;
        --position)
            POSITION=$2
            shift 2
            ;;
        --navigation)
            NAVIGATION=$2
            shift 2
            ;;
        -h|--help)
            sh_script_usage
            ;;
        -v|--version)
            sh_script_version
            ;;
        -* )
            sh_script_usage
            ;;
        *)
            break
            ;;
    esac
done

[[ -n "${ROOM_SIZE}" ]] || read -r -p "--room-size " ROOM_SIZE
[[ -n "${POSITION}" ]] || read -r -p "--position " POSITION
[[ -n "${NAVIGATION}" ]] || read -r -p "--navigation " NAVIGATION

# parse input
ORIENTATION=$(cat <<EOF
N0
E1
S2
W3
EOF
)
ROOM_WIDTH=$(echo "${ROOM_SIZE}" | cut -d" " -f1)
ROOM_DEPTH=$(echo "${ROOM_SIZE}" | cut -d" " -f2)

POS_X=$(echo "${POSITION}" | cut -d" " -f1)
POS_Y=$(echo "${POSITION}" | cut -d" " -f2)
POS_O=$(echo "${POSITION}" | cut -d" " -f3)

# assert input
[[ "${ROOM_WIDTH}" =~ ^[0-9]+$ ]] || { echo_err "Room width ${ROOM_WIDTH} is not a positive integer."; exit 1; }
[[ "${ROOM_DEPTH}" =~ ^[0-9]+$ ]] || { echo_err "Room depth ${ROOM_DEPTH} is not a positive integer."; exit 1; }
[[ "${POS_X}" =~ ^[0-9]+$ ]] || { echo_err "Position x ${POS_X} is not a positive integer."; exit 1; }
[[ "${POS_Y}" =~ ^[0-9]+$ ]] || { echo_err "Position y ${POS_Y} is not a positive integer."; exit 1; }
[[ "${POS_O}" =~ ^[NESW]$ ]] || { echo_err "Orientation ${POS_O} is not a NESW."; exit 1; }
[[ "${NAVIGATION}" =~ ^[LRF]+$ ]] || { echo_err "Navigation ${NAVIGATION} is not a sequence of LRF."; exit 1; }

[[ "${POS_X}" -lt "${ROOM_WIDTH}" ]] || { echo_err "Position x ${POS_X} is larger than room width ${ROOM_WIDTH}."; exit 1; }
[[ "${POS_Y}" -lt "${ROOM_DEPTH}" ]] || { echo_err "Position y ${POS_Y} is larger than room depth ${ROOM_DEPTH}."; exit 1; }

# main
MAX_POS_X="$(( ROOM_WIDTH - 1 ))"
MAX_POS_Y="$(( ROOM_DEPTH - 1 ))"
# NOTE converting to index for bit manipulation
POS_O=$(echo "${ORIENTATION}" | grep "^${POS_O}" | head -c 2 | tail -c 1)

echo_info "_ -> ${POS_X} ${POS_Y} ${POS_O}" # debug

while [[ -n "${NAVIGATION}" ]]; do
    COMMAND="${NAVIGATION:0:1}"
    NAVIGATION="${NAVIGATION:1}"
    case "${COMMAND}" in
        L)
            POS_O="$(( POS_O - 1 ))"
            [[ "${POS_O}" != "-1" ]] || POS_O=3
            ;;
        R)
            POS_O="$(( POS_O + 1 ))"
            [[ "${POS_O}" != "4" ]] || POS_O=0
            ;;
        F)
            case "${POS_O}" in
                0) # N
                    [[ "${POS_Y}" = "0" ]] || POS_Y="$(( POS_Y - 1 ))"
                    ;;
                1) # E
                    [[ "${POS_X}" = "${MAX_POS_X}" ]] || POS_X="$(( POS_X + 1 ))"
                    ;;
                2) # S
                    [[ "${POS_Y}" = "${MAX_POS_Y}" ]] || POS_Y="$(( POS_Y + 1 ))"
                    ;;
                3) # W
                    [[ "${POS_X}" = "0" ]] || POS_X="$(( POS_X - 1 ))"
                    ;;
                *)
                    echo_err "Unknown orientation ${POS_O}."
                    exit 1
                    ;;
            esac
            ;;
        *)
            echo_err "Unknown command ${COMMAND}."
            exit 1
            ;;
    esac
    echo_info "${COMMAND} -> ${POS_X} ${POS_Y} ${POS_O}" # debug
done

POS_O=$(echo "${ORIENTATION}" | grep "${POS_O}$" | head -c 1)
echo "Report: ${POS_X} ${POS_Y} ${POS_O}"
