#!/usr/bin/env bash

cyan=$'\e'[36m
reset=$'\e'[0m

@test debug_command {
    run ./kitout.sh tests/parsing.kitfile
    echo "$output"

    [ ${#lines[@]} = 4 ]
    [ "${lines[0]}" == "Hello world." ]
    [ "${lines[1]}" == "${cyan}    Debug output is formatted and coloured.${reset}" ]
    [ "${lines[2]}" == "Indented commands work." ]
    [ "${lines[3]}" == "${cyan}    ${reset}" ]
    [ "${lines[4]}" == "" ]
}
