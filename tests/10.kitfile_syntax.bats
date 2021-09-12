#!/usr/bin/env bash

bold=$'\e'[1m
green=$'\e'[32m
magenta=$'\e'[35m
cyan=$'\e'[36m
reset=$'\e'[0m

@test output_commands {
    run ./kitout.sh tests/parsing.kitfile
    echo "$output"

    [ ${#lines[@]} = 7 ]
    [ "${lines[0]}" == "    Hello world." ]
    [ "${lines[1]}" == "${cyan}    Debug output is formatted and coloured.${reset}" ]
    [ "${lines[2]}" == "    Indented commands work." ]
    [ "${lines[3]}" == "${cyan}    ${reset}" ]
    [ "${lines[4]}" == "    " ]
    [ "${lines[5]}" == "${green}=== A section header ==========================================================${reset}" ]
    [ "${lines[6]}" == "${green}===============================================================================${reset}" ]
}

@test unknown_command {
    run ./kitout.sh tests/unknown.kitfile
    echo "$output"

    [ "${lines[0]}" == "${bold}${magenta}*** Unknown command: 'kronk'${reset}" ]
    [ $status -eq 1 ]
}
