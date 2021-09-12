#!/usr/bin/env bash

bold=$'\e'[1m
yellow=$'\e'[33m
magenta=$'\e'[35m
reset=$'\e'[0m

@test symlink {
    [ ! -f /tmp/symlink.kitfile ]
    [ ! -f /tmp/exists ]

    run ./kitout.sh tests/symlink.kitfile
    echo "$output"

    [ $status -eq 1 ]

    [ -f /tmp/symlink.kitfile ]
    [ -L /tmp/symlink-to-symlink.kitfile ]
    [ "${lines[2]}" == "${yellow}=== symbolic linking '/tmp/symlink-to-symlink.kitfile' to '/tmp/symlink.kitfile'${reset}" ]

    [ -e /tmp/exists -a ! -L /tmp/exists ]
    [ "${lines[3]}" == "${yellow}=== symbolic linking '/tmp/exists' to '/tmp/symlink.kitfile'${reset}" ]
    [ "${lines[4]}" == "${bold}${magenta}*** cannot create symlink: '/tmp/exists' already exists${reset}" ]
}

function setup_file {
    teardown
}

function teardown {
    rm -f /tmp/symlink.kitfile /tmp/exists
}
