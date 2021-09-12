#!/usr/bin/env bash

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

    [ "${lines[0]}" == "kitout version 0.3" ]
    [ $status -eq 0 ]

    run ./kitout.sh version
    echo "$output"

    [ "${lines[0]}" == "kitout version 0.3" ]
    [ $status -eq 0 ]
}
