#!/usr/bin/env bash

bold=$'\e'[1m
magenta=$'\e'[35m
reset=$'\e'[0m

@test kitout_is_executable {
    run ./kitout.sh
    echo "$output"

    [ "${lines[0]}" == "Usage:" ]
    [ $status -eq 1 ]
}

@test kitout_explicit_help_not_error {
    run ./kitout.sh -h
    echo "$output"

    [ "${lines[0]}" == "Usage:" ]
    [ $status -eq 0 ]

    run ./kitout.sh help
    echo "$output"

    [ "${lines[0]}" == "Usage:" ]
    [ $status -eq 0 ]
}

@test kitout_shows_version {
    run ./kitout.sh -v
    echo "$output"

    [ "${lines[0]}" == "kitout version 0.5" ]
    [ $status -eq 0 ]

    run ./kitout.sh version
    echo "$output"

    [ "${lines[0]}" == "kitout version 0.5" ]
    [ $status -eq 0 ]
}

@test kitout_with_nonexistent_kitfile {
    run ./kitout.sh i-dont-exist
    echo "$output"

    [ "${lines[0]}" == "${bold}${magenta}*** Kitfile does not exist: i-dont-exist${reset}" ]
    [ $status -eq 1 ]
}
