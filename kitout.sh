#!/usr/bin/env -S bash -euo pipefail

VERSION=0.1

# ANSI sequences
bold="\e[1m"
magenta="\e[35m"
reset="\e[0m"

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
}

function usage {
    cat << EOF | sed -e 's/^        //'
        Usage:

        kitout [-h|help]
            show this usage information

        kitout -v|version
            show the version number
EOF
    exit "${1:-0}"
}

function show_version {
    echo kitout version $VERSION
    exit 0
}

function error {
    printf "${bold}${magenta}*** ${1}${reset}\n" >&2
}

main "$@"
