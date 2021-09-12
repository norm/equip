#!/usr/bin/env bash

bold=$'\e'[1m
magenta=$'\e'[35m
reset=$'\e'[0m

@test brewfile {
    run ./kitout.sh tests/brewfile.kitfile
    echo "$output"
    [ "${lines[1]}" == "Using bats-core" ]
    [ "${lines[4]}" == "Using bats-core" ]
    [ "${lines[5]}" == "Installing gimme" ]
    [ "${lines[7]}" == "${bold}${magenta}*** brewfile 'i-dont-exist' does not exist${reset}" ]
    [ $status -eq 1 ]
}

function setup_file {
    brew update
    teardown
}

function teardown {
    brew uninstall --force gimme
}
