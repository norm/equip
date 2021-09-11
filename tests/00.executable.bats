#!/usr/bin/env bash

bold=$'\e'[1m
magenta=$'\e'[35m
reset=$'\e'[0m

@test kitout_is_executable {
    run ./kitout.sh
    echo "$output"

    [ "${lines[0]}" == "${bold}${magenta}*** Kitout does nothing, yet.${reset}" ]
    [ $status -eq 1 ]
}
