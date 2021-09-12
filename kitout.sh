#!/usr/bin/env -S bash -euo pipefail

VERSION=0.2

# ANSI sequences
bold="\e[1m"
cyan="\e[36m"
magenta="\e[35m"
reset="\e[0m"

errors_occured=0


function main {
    while getopts "hv" option; do
        case $option in
            v)      show_version ;;
            ?|h)    usage ;;
        esac
    done
    shift $(( OPTIND-1 ))

    [ -z "${1:-}" ] && usage 1
    [ "${1}" = 'help' ] && usage
    [ "${1}" = 'version' ] && show_version

    for argument in "$@"; do
        process_kitfile "$argument"
    done

    [ $errors_occured -gt 0 ] && exit 1
    exit 0
}

function usage {
    cat << EOF | sed -e 's/^        //'
        Usage:

        kitout [-h|help]
            show this usage information

        kitout -v|version
            show the version number

        kitout kitfile [kitfile ...]
            runs commands listed in the kitfile(s)

        Suitfiles are documented on GitHub:
        https://github.com/norm/kitout/blob/v${VERSION}/documentation/kitfile.markdown
EOF
    exit "${1:-0}"
}

function show_version {
    echo kitout version $VERSION
    exit 0
}

function debug_output {
    printf "${cyan}    ${*}${reset}\n" >&2
}

function error {
    printf "${bold}${magenta}*** ${1}${reset}\n" >&2
    let "errors_occured = errors_occured + 1"
}

function process_kitfile {
    while read command argument; do
        case "$command" in
            \#|'')  : ;;
            echo)   echo "$argument" ;;
            debug)  debug_output "$argument" ;;

            *)      error "Unknown command: '$command'" ;;
        esac
    done < <(cat "$1")
}

main "$@"
