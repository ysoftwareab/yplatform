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
##   --doc          Print documentation and exit
##   --notes        Print notes and exit
##   -h, --help     Display this help and exit
##   -v, --version  Output version information and exit

function doc() {
    cat <<EOF
In order to evaluate your programming skills, we ask you to solve the following
task. The task is solved in a programming language of your choice.

We ask you to deliver the solution in the same quality as you would provide a
delivery to a customer. You may not use other people’s code or code libraries
to resolve the task. That is, the solution can only contain references to the
standard libraries of your language, as well as any third party libraries for unit
tests.

We are interested in your competence in several areas, including:

• Your chosen language
• Programming paradigms related to your selection of programming language
• Software design and architecture
• Tests
• User interfaces

Your solution to the programming assignment will form the basis of the conver-
sation during the technical interview. Highlight what you are good at. If you
feel certain parts could have been resolved better if you had more time, then
comment on that too.

From the time you receive the assignment, you usually have one week to submit
your solution. The solution can be submitted via for example GitHub or as a
zip file.

Task: Robot programming

Your task is to program the controller to a robot. It’s a simple robot that can
walk around in a room where the floor is represented as a number of fields in a
wire mesh. Input is first two numbers, which tells the robot how big the room is:

5 7

Which means that the room is 5 fields wide and is 7 fields deep.

The size of the room follows two digits and one letter indicating the starting
position of the robot and its orientation in space. For example:

3 3 N

Which means that the robot is in field (3, 3) and faces north. Subsequently, the
robot receives a number of navigation commands in the form of characters. The
following commands shall be implemented:

• L Turn left
• R Turn right
• F Walk forward

Example:

LFFRFRFRFF

After the last command is received, the robot must report which field it is in
and what direction it is facing.

Example:

5 5
1 2 N
RFRFFRFRF
Report: 1 3 N

5 5
0 0 E
RFLFFLRF
Report: 3 1 E

EOF
    exit 1
}

function notes() {
    cat <<EOF
# TLDR

'bin/robot.sh --doc' shows the task documentation.

'bin/robot.sh --notes' shows these notes.

'make robot' runs all robot executions (functional tests) and
checks that given robot/X.in, the result robot/X.run is the same as the expected robot/X.out.

'make robot/X.run' runs only a specific robot execution.

'make test/robot.sh' runs the unit tests.

# WHY BASH?

Portability, simplicity and integration with other software following the "do one thing well" philosophy.
If you are doing *nix development, then it's impossible not to run into bash scripts.
But it is be possible not to ever run into <insert modern generic language of choice>.
Modern languages are also fast evolving so in many situations you need specific versions of their runtime, specific to your script.
Many times you require dependencies to be installed, for instance to integrate with the filesystem or
other CLI utilities via stdin/stdout/stderr, making it even more prone to failure.
I avoid all of this at all costs for well-scoped/utility software, and stick to bash,
and only ocasionally to standalone widely-compatible no-dependencies  nodejs scripts.
PS: I did have a hidden purpose as well. Despite the rivers of bash scripts that I wrote, I never got to test them with Bats.
So I used this task also to learn Bats.

# WAYS OF WORKING

I started with a skeleton of the script, until I managed to get the simplest happy case green.
Once that was done, I switched over to automating running functional tests.
Came back and "finished" the script so that the functional tests pass.
At this point, the script "works" (tm).
Depending on the script, I may consider it also "done" (tm). In this case though, I went ahead
and implemented an automation to run unit tests. This in turn made the script more modular, and random improvements were made.
With every change, I could detect regressions thanks to the functional tests.
The current tests are not enough (due to time), but it's worth mentioning that the goal isn't to increase coverage,
as it is to target more cornercases.

# USER INTERFACE

For various reasons, I implemented two interfaces: a stdin and a parametrized interface.
The former helps with automations, while the latter helps with manual/human invocations.

# HITTING THE WALL

As far as I can see, there's an undefined behaviour: what happens when the robot is told to navigate outside of the room i.e. into the wall.
Nothing happens, or the execution should just stop, or ? I went with the former because it's the closest to reality.
But it is still an assumption. In the real world, it's worth noting that assumption is the root of evil.

# DELIVERY

Due to available time, I took a big shortcut. The task mentions to deliver the software as you would to a real customer.
The way that I do that can be seen in https://github.com/rokmoln/http-lambda for instance.
But for this task, I simply coded a solution inside support-firecloud which would allow me to access the necessary tools for shellscripts/makefiles/CI.
It is also worth mentioning that part of the delivery should also be the git history
since more often than not it helps future maintainers to understand esotheric knowledge via 'git blame',
but this task's git history is to be ignored.
I am otherwise quite pedantic about it when I'm not on parental leave :) with many rewordings, reorderings, squashes/fixups,
which is probably why I'm on this commit leaderboard for Sweden https://commits.top/sweden.html #facepalm #stupidmetrics.

# HIGHLIGHTS

* Keep It Simple Stupid
* integration with previous work (support-firecloud tooling)
* skeleton for docs/tests

EOF
    exit 1
}

# ------------------------------------------------------------------------------

DEBUG=

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

function echo_debug() {
    [[ -n "${DEBUG}" ]] || return 0
    ${CI_ECHO} "[DEBU]" "$@"
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
            --debug)
                DEBUG=true
                shift
                ;;
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
            --doc)
                doc
                ;;
            --notes)
                notes
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

function execute_command() {
    COMMAND="$1"
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
}

function main() {
    read_input "$@"

    # main
    echo_debug "_ -> ${POS_X} ${POS_Y} ${POS_O}"

    while [[ -n "${NAVIGATION}" ]]; do
        COMMAND="${NAVIGATION:0:1}"
        NAVIGATION="${NAVIGATION:1}"
        execute_command "${COMMAND}"
        echo_debug "${COMMAND} -> ${POS_X} ${POS_Y} ${POS_O}"
    done

    POS_O=$(echo "${ORIENTATION}" | grep "${POS_O}$" | head -c 1)
    echo "Report: ${POS_X} ${POS_Y} ${POS_O}"
}

[[ "${BASH_SOURCE[0]}" != "${0}" ]] || main "$@"
