#!/usr/bin/env bash

export HOME=$BATS_TEST_TMPDIR
teardown

bold=$'\e'[1m
magenta=$'\e'[35m
reset=$'\e'[0m

@test brewfile {
    [ ! -d $HOME/install-test ]

    run ./kitout.sh tests/install.kitfile
    echo "$output"

    [ $status -eq 1 ]
    [ "${lines[2]}" == "${bold}${magenta}*** 'i-dont-exist' does not exist${reset}" ]

    [ -d $HOME/install-test ]
    [ -f $HOME/install-test/file ]
    [ $(stat -f'%p' $HOME/install-test/file) = '100715' ]
    [ ! -f $HOME/install-test/nope ]
}

function teardown {
    rm -rf $HOME/install-test
}
