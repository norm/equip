#!/usr/bin/env bash

bold=$'\e'[1m
magenta=$'\e'[35m
cyan=$'\e'[36m
reset=$'\e'[0m

@test output_commands {
    run ./kitout.sh tests/parsing.kitfile
    echo "$output"

    [ ${#lines[@]} = 5 ]
    [ "${lines[0]}" == "    Hello world." ]
    [ "${lines[1]}" == "${cyan}    Debug output is formatted and coloured.${reset}" ]
    [ "${lines[2]}" == "    Indented commands work." ]
    [ "${lines[3]}" == "${cyan}    ${reset}" ]
    [ "${lines[4]}" == "    " ]
}

@test unknown_command {
    run ./kitout.sh tests/unknown.kitfile
    echo "$output"

    [ "${lines[0]}" == "${bold}${magenta}*** Unknown command: 'kronk'${reset}" ]
    [ $status -eq 1 ]
}
