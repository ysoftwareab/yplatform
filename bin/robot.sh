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
##   --position     Initial 0-indexed position: x, y and direction (orientation) of the robot e.g. "3 3 N"
##   --navigation   Navigation commands: L(eft) R(ight) F(orward)
##
##   -h, --help     Display this help and exit
##   -v, --version  Output version information and exit

ROOM_SIZE=
POSITION=
NAVIGATION=

ROOM_WIDTH=
ROOM_DEPTH=
MAX_POS_X=
MAX_POS_Y=
POS_X=
POS_Y=
POS_O=

function echo_x() {
    echo_err "$@"
    exit 1
}

function read_input_room_size() {
    [[ -n "${ROOM_SIZE}" ]] || read -r -p "--room-size " ROOM_SIZE
    [[ -n "${ROOM_SIZE}" ]] || echo_x "Room size is required."

    ROOM_WIDTH=$(echo "${ROOM_SIZE}" | cut -d" " -f1)
    ROOM_DEPTH=$(echo "${ROOM_SIZE}" | cut -d" " -f2)
    [[ "${ROOM_WIDTH}" =~ ^[0-9]+$ && "${ROOM_WIDTH}" -gt 0 ]] || echo_x "Room width ${ROOM_WIDTH} is not a positive integer."
    [[ "${ROOM_DEPTH}" =~ ^[0-9]+$ && "${ROOM_DEPTH}" -gt 0 ]] || echo_x "Room depth ${ROOM_DEPTH} is not a positive integer."

    MAX_POS_X="$(( ROOM_WIDTH - 1 ))"
    MAX_POS_Y="$(( ROOM_DEPTH - 1 ))"
}

function read_input_position() {
    [[ -n "${POSITION}" ]] || read -r -p "--position " POSITION
    [[ -n "${POSITION}" ]] || echo_x "Position is required."

    POS_X=$(echo "${POSITION}" | cut -d" " -f1)
    POS_Y=$(echo "${POSITION}" | cut -d" " -f2)
    POS_O=$(echo "${POSITION}" | cut -d" " -f3)
    [[ "${POS_X}" =~ ^[0-9]+$ ]] || echo_x "Position x ${POS_X} is not a positive integer."
    [[ "${POS_Y}" =~ ^[0-9]+$ ]] || echo_x "Position y ${POS_Y} is not a positive integer."
    [[ "${POS_X}" -lt "${ROOM_WIDTH}" ]] || echo_x "Position x ${POS_X} is larger than room width ${ROOM_WIDTH}."
    [[ "${POS_Y}" -lt "${ROOM_DEPTH}" ]] || echo_x "Position y ${POS_Y} is larger than room depth ${ROOM_DEPTH}."
    [[ "${POS_O}" =~ ^[NESW]$ ]] || echo_x "Orientation ${POS_O} is not a NESW."
    ORIENTATION=$(cat <<EOF
N0
E1
S2
W3
EOF
    )
    # NOTE converting to index for bit manipulation
    POS_O=$(echo "${ORIENTATION}" | grep "^${POS_O}" | head -c 2 | tail -c 1)
}

function read_input_navigation() {
    [[ -n "${NAVIGATION}" ]] || read -r -p "--navigation " NAVIGATION
    [[ -n "${NAVIGATION}" ]] || echo_x "Navigation is required."
    [[ "${NAVIGATION}" =~ ^[LRF]+$ ]] || echo_x "Navigation ${NAVIGATION} is not a sequence of LRF."
}

function read_input() {
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

    read_input_room_size
    read_input_position
    read_input_navigation
}

function main() {
    read_input

    # main
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
                        if [[ "${POS_Y}" = "0" ]]; then
                            echo_warn "Hit the wall!"
                        else
                            POS_Y="$(( POS_Y - 1 ))"
                        fi
                        ;;
                    1) # E
                        if [[ "${POS_X}" = "${MAX_POS_X}" ]]; then
                            echo_warn "Hit the wall!"
                        else
                            POS_X="$(( POS_X + 1 ))"
                        fi
                        ;;
                    2) # S
                        if [[ "${POS_Y}" = "${MAX_POS_Y}" ]]; then
                            echo_warn "Hit the wall!"
                        else
                            POS_Y="$(( POS_Y + 1 ))"
                        fi
                        ;;
                    3) # W
                        if [[ "${POS_X}" = "0" ]]; then
                            echo_warn "Hit the wall!"
                        else
                            POS_X="$(( POS_X - 1 ))"
                        fi
                        ;;
                    *)
                        echo_x "Unknown orientation ${POS_O}."
                        ;;
                esac
                ;;
            *)
                echo_x "Unknown command ${COMMAND}."
                ;;
        esac
        echo_info "${COMMAND} -> ${POS_X} ${POS_Y} ${POS_O}" # debug
    done

    POS_O=$(echo "${ORIENTATION}" | grep "${POS_O}$" | head -c 1)
    echo "Report: ${POS_X} ${POS_Y} ${POS_O}"
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || main "$@"
