#!/usr/bin/env -S bash -euo pipefail

# ANSI sequences
bold="\e[1m"
magenta="\e[35m"
reset="\e[0m"

function main {
    error "Kitout does nothing, yet."
    exit 1
}

function error {
    printf "${bold}${magenta}*** ${1}${reset}\n" >&2
}

main
